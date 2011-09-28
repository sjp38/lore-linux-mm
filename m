Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 510469000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:01:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CB5CA3EE0C3
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:01:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEACE45DF4A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:01:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA3845DF48
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:01:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D3B4E08001
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:01:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC1AD1DB803E
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 17:01:11 +0900 (JST)
Date: Wed, 28 Sep 2011 17:00:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/9] kstaled: minimalistic implementation.
Message-Id: <20110928170020.50883337.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317170947-17074-5-git-send-email-walken@google.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-5-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, 27 Sep 2011 17:49:02 -0700
Michel Lespinasse <walken@google.com> wrote:


> +static unsigned int kstaled_scan_seconds;
> +static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
> +
> +static unsigned kstaled_scan_page(struct page *page)
> +{
> +	bool is_locked = false;
> +	bool is_file;
> +	struct page_referenced_info info;
> +	struct page_cgroup *pc;
> +	struct idle_page_stats *stats;
> +	unsigned nr_pages;
> +
> +	/*
> +	 * Before taking the page reference, check if the page is
> +	 * a user page which is not obviously unreclaimable
> +	 * (we will do more complete checks later).
> +	 */
> +	if (!PageLRU(page) ||
> +	    (!PageCompound(page) &&
> +	     (PageMlocked(page) ||
> +	      (page->mapping == NULL && !PageSwapCache(page)))))
> +		return 1;

Hmm... if you find a page PageCompound(page) && !PageLRU(page),
this returns "1". Is it ok and you'll have no race with khugepaged ?

> +
> +	if (!get_page_unless_zero(page))
> +		return 1;
> +
> +	/* Recheck now that we have the page reference. */
> +	if (unlikely(!PageLRU(page)))
> +		goto out;
> +	nr_pages = 1 << compound_trans_order(page);
> +	if (PageMlocked(page))
> +		goto out;
> +
> +	/*
> +	 * Anon and SwapCache pages can be identified without locking.
> +	 * For all other cases, we need the page locked in order to
> +	 * dereference page->mapping.
> +	 */
> +	if (PageAnon(page) || PageSwapCache(page))
> +		is_file = false;
> +	else if (!trylock_page(page)) {
> +		/*
> +		 * We need to lock the page to dereference the mapping.
> +		 * But don't risk sleeping by calling lock_page().
> +		 * We don't want to stall kstaled, so we conservatively
> +		 * count locked pages as unreclaimable.
> +		 */
> +		goto out;
> +	} else {
> +		struct address_space *mapping = page->mapping;
> +
> +		is_locked = true;
> +
> +		/*
> +		 * The page is still anon - it has been continuously referenced
> +		 * since the prior check.
> +		 */
> +		VM_BUG_ON(PageAnon(page) || mapping != page_rmapping(page));
> +
> +		/*
> +		 * Check the mapping under protection of the page lock.
> +		 * 1. If the page is not swap cache and has no mapping,
> +		 *    shrink_page_list can't do anything with it.
> +		 * 2. If the mapping is unevictable (as in SHM_LOCK segments),
> +		 *    shrink_page_list can't do anything with it.
> +		 * 3. If the page is swap cache or the mapping is swap backed
> +		 *    (as in shmem), consider it a swappable page.
> +		 * 4. If the backing dev has indicated that it does not want
> +		 *    its pages sync'd to disk (as in ramfs), take this as
> +		 *    a hint that its pages are not reclaimable.
> +		 * 5. Otherwise, consider this as a file page reclaimable
> +		 *    through standard pageout.
> +		 */
> +		if (!mapping && !PageSwapCache(page))
> +			goto out;
> +		else if (mapping_unevictable(mapping))
> +			goto out;
> +		else if (PageSwapCache(page) ||
> +			 mapping_cap_swap_backed(mapping))
> +			is_file = false;
> +		else if (!mapping_cap_writeback_dirty(mapping))
> +			goto out;
> +		else
> +			is_file = true;
> +	}
> +
> +	/* Find out if the page is idle. Also test for pending mlock. */
> +	page_referenced_kstaled(page, is_locked, &info);
> +	if ((info.pr_flags & PR_REFERENCED) || (info.vm_flags & VM_LOCKED))
> +		goto out;
> +
> +	/* Locate kstaled stats for the page's cgroup. */
> +	pc = lookup_page_cgroup(page);
> +	if (!pc)
> +		goto out;

This !pc check is not required.

> +	lock_page_cgroup(pc);
> +	if (!PageCgroupUsed(pc))
> +		goto unlock_page_cgroup_out;
> +	stats = &pc->mem_cgroup->idle_scan_stats;
> +
> +	/* Finally increment the correct statistic for this page. */
> +	if (!(info.pr_flags & PR_DIRTY) &&
> +	    !PageDirty(page) && !PageWriteback(page))
> +		stats->idle_clean += nr_pages;
> +	else if (is_file)
> +		stats->idle_dirty_file += nr_pages;
> +	else
> +		stats->idle_dirty_swap += nr_pages;
> +
> + unlock_page_cgroup_out:
> +	unlock_page_cgroup(pc);
> +

unlock_page_out:
	unlock_page(page);
out:
	put_page(page);

?

Hm, btw, if you put 'stats' into per-zone struct of memcg,
you'll have a chance to get per-node/zone idle stats.
you don't want it ?




> + out:
> +	if (is_locked)
> +		unlock_page(page);
> +	put_page(page);
> +
> +	return nr_pages;
> +}
> +
> +static void kstaled_scan_node(pg_data_t *pgdat)
> +{
> +	unsigned long flags;
> +	unsigned long pfn, end;
> +
> +	pgdat_resize_lock(pgdat, &flags);
> +

pgdat_resize_lock() is a spin lock irq disabling..so
IRQ will be blocked while you do scanning.

I think lock_memory_hotplug() will be better and I think it's enough.


> +	pfn = pgdat->node_start_pfn;
> +	end = pfn + pgdat->node_spanned_pages;
> +
> +	while (pfn < end) {
> +		if (need_resched()) {
> +			pgdat_resize_unlock(pgdat, &flags);
> +			cond_resched();
> +			pgdat_resize_lock(pgdat, &flags);
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +			/* abort if the node got resized */
> +			if (pfn < pgdat->node_start_pfn ||
> +			    end > (pgdat->node_start_pfn +
> +				   pgdat->node_spanned_pages))
> +				goto abort;
> +#endif
> +		}
> +
> +		pfn += pfn_valid(pfn) ?
> +			kstaled_scan_page(pfn_to_page(pfn)) : 1;

There is a server which has following node layout as:

pfn 0 <---------------------------------------------> max_pfn
      node0 node1 node2 node3 node0 node1 node2 node3

Then, you may scan pages multiple times. please check node id.



> +	}
> +
> +abort:
> +	pgdat_resize_unlock(pgdat, &flags);
> +}
> +
> +static int kstaled(void *dummy)
> +{
> +	while (1) {
> +		int scan_seconds;
> +		int nid;
> +		struct mem_cgroup *memcg;
> +
> +		wait_event_interruptible(kstaled_wait,
> +				 (scan_seconds = kstaled_scan_seconds) > 0);
> +		/*
> +		 * We use interruptible wait_event so as not to contribute
> +		 * to the machine load average while we're sleeping.
> +		 * However, we don't actually expect to receive a signal
> +		 * since we run as a kernel thread, so the condition we were
> +		 * waiting for should be true once we get here.
> +		 */
> +		BUG_ON(scan_seconds <= 0);
> +
> +		for_each_mem_cgroup_all(memcg)
> +			memset(&memcg->idle_scan_stats, 0,
> +			       sizeof(memcg->idle_scan_stats));
> +
> +		for_each_node_state(nid, N_HIGH_MEMORY)
> +			kstaled_scan_node(NODE_DATA(nid));
> +
> +		for_each_mem_cgroup_all(memcg) {
> +			write_seqcount_begin(&memcg->idle_page_stats_lock);
> +			memcg->idle_page_stats = memcg->idle_scan_stats;
> +			memcg->idle_page_scans++;
> +			write_seqcount_end(&memcg->idle_page_stats_lock);
> +		}
> +
> +		schedule_timeout_interruptible(scan_seconds * HZ);

Hm, timeout is the best trigger ?




> +	}
> +
> +	BUG();
> +	return 0;	/* NOT REACHED */
> +}
> +
> +static ssize_t kstaled_scan_seconds_show(struct kobject *kobj,
> +					 struct kobj_attribute *attr,
> +					 char *buf)
> +{
> +	return sprintf(buf, "%u\n", kstaled_scan_seconds);
> +}
> +
> +static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
> +					  struct kobj_attribute *attr,
> +					  const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long input;
> +
> +	err = kstrtoul(buf, 10, &input);
> +	if (err)
> +		return -EINVAL;
> +	kstaled_scan_seconds = input;
> +	wake_up_interruptible(&kstaled_wait);
> +	return count;
> +}
> +

How the user should calculated the scan interval ?
Can't this be selected in (semi-)automatic way ?

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
