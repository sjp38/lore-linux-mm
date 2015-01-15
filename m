Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id F2B376B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:56:14 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so16416175wgh.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:56:14 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id a5si11740133wix.30.2015.01.15.09.56.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 09:56:13 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id hi2so19528934wib.2
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:56:13 -0800 (PST)
Date: Thu, 15 Jan 2015 18:56:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH cgroup/for-3.19-fixes] cgroup: implement
 cgroup_subsys->unbind() callback
Message-ID: <20150115175609.GG7008@dhcp22.suse.cz>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <20150110214316.GF25319@htj.dyndns.org>
 <20150111205543.GA5480@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150111205543.GA5480@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Sun 11-01-15 15:55:43, Johannes Weiner wrote:
> From d527ba1dbfdb58e1f7c7c4ee12b32ef2e5461990 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Sun, 11 Jan 2015 10:29:05 -0500
> Subject: [patch] mm: memcontrol: zap outstanding cache/swap references during
>  unbind
> 
> Cgroup core assumes that any outstanding css references after
> offlining are temporary in nature, and e.g. mount waits for them to
> disappear and release the root cgroup.  But leftover page cache and
> swapout records in an offlined memcg are only dropped when the pages
> get reclaimed under pressure or the swapped out pages get faulted in
> from other cgroups, and so those cgroup operations can hang forever.
> 
> Implement the ->unbind() callback to actively get rid of outstanding
> references when cgroup core wants them gone.  Swap out records are
> deleted, such that the swap-in path will charge those pages to the
> faulting task. 

OK, that makes sense to me.

> Page cache pages are moved to the root memory cgroup.

OK, this is better than reclaiming them.

[...]
> +static void unbind_lru_list(struct mem_cgroup *memcg,
> +			    struct zone *zone, enum lru_list lru)
> +{
> +	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> +	struct list_head *list = &lruvec->lists[lru];
> +
> +	while (!list_empty(list)) {
> +		unsigned int nr_pages;
> +		unsigned long flags;
> +		struct page *page;
> +
> +		spin_lock_irqsave(&zone->lru_lock, flags);
> +		if (list_empty(list)) {
> +			spin_unlock_irqrestore(&zone->lru_lock, flags);
> +			break;
> +		}
> +		page = list_last_entry(list, struct page, lru);

taking lru_lock for each page calls for troubles. The lock would bounce
like crazy. It shouldn't be a big problem to list_move to a local list
and then work on that one without the lock. Those pages wouldn't be
visible for the reclaim but that would be only temporary. Or if that is
not acceptable then just batch at least some number of pages (popular
SWAP_CLUSTER_MAX).

> +		if (!get_page_unless_zero(page)) {
> +			list_move(&page->lru, list);
> +			spin_unlock_irqrestore(&zone->lru_lock, flags);
> +			continue;
> +		}
> +		BUG_ON(!PageLRU(page));
> +		ClearPageLRU(page);
> +		del_page_from_lru_list(page, lruvec, lru);
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +
> +		compound_lock(page);
> +		nr_pages = hpage_nr_pages(page);
> +
> +		if (!mem_cgroup_move_account(page, nr_pages,
> +					     memcg, root_mem_cgroup)) {
> +			/*
> +			 * root_mem_cgroup page counters are not used,
> +			 * otherwise we'd have to charge them here.
> +			 */
> +			page_counter_uncharge(&memcg->memory, nr_pages);
> +			if (do_swap_account)
> +				page_counter_uncharge(&memcg->memsw, nr_pages);
> +			css_put_many(&memcg->css, nr_pages);
> +		}
> +
> +		compound_unlock(page);
> +
> +		putback_lru_page(page);
> +	}
> +}
> +
> +static void unbind_work_fn(struct work_struct *work)
> +{
> +	struct cgroup_subsys_state *css;
> +retry:
> +	drain_all_stock(root_mem_cgroup);
> +
> +	rcu_read_lock();
> +	css_for_each_child(css, &root_mem_cgroup->css) {
> +		struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +
> +		/* Drop references from swap-out records */
> +		if (do_swap_account) {
> +			long zapped;
> +
> +			zapped = swap_cgroup_zap_records(memcg->css.id);
> +			page_counter_uncharge(&memcg->memsw, zapped);
> +			css_put_many(&memcg->css, zapped);
> +		}
> +
> +		/* Drop references from leftover LRU pages */
> +		css_get(css);
> +		rcu_read_unlock();
> +		atomic_inc(&memcg->moving_account);
> +		synchronize_rcu();

Why do we need this? Who can migrate to/from offline memcgs? 

> +		while (page_counter_read(&memcg->memory) -
> +		       page_counter_read(&memcg->kmem) > 0) {
> +			struct zone *zone;
> +			enum lru_list lru;
> +
> +			lru_add_drain_all();
> +
> +			for_each_zone(zone)
> +				for_each_lru(lru)
> +					unbind_lru_list(memcg, zone, lru);
> +
> +			cond_resched();
> +		}
> +		atomic_dec(&memcg->moving_account);
> +		rcu_read_lock();
> +		css_put(css);
> +	}
> +	rcu_read_unlock();
> +	/*
> +	 * Swap-in is racy:
> +	 *
> +	 * #0                        #1
> +	 *                           lookup_swap_cgroup_id()
> +	 *                           rcu_read_lock()
> +	 *                           mem_cgroup_lookup()
> +	 *                           css_tryget_online()
> +	 *                           rcu_read_unlock()
> +	 * cgroup_kill_sb()
> +	 *   !css_has_online_children()
> +	 *     ->unbind()
> +	 *                           page_counter_try_charge()
> +	 *                           css_put()
> +	 *                             css_free()
> +	 *                           pc->mem_cgroup = dead memcg
> +	 *                           add page to lru
> +	 *
> +	 * Loop until until all references established from previously
> +	 * existing swap-out records have been transferred to pages on
> +	 * the LRU and then uncharged from there.
> +	 */
> +	if (!list_empty(&root_mem_cgroup->css.children)) {

But what if kmem pages pin the memcg? We would loop for ever. Or am I
missing something?

> +		msleep(10);
> +		goto retry;
> +	}
> +}
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
