Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD89D6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 11:08:30 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so614563wib.11
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 08:08:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hv5si30000634wib.1.2014.07.22.08.08.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 08:08:28 -0700 (PDT)
Date: Tue, 22 Jul 2014 17:08:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140722150825.GA4517@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140719173911.GA1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat 19-07-14 13:39:11, Johannes Weiner wrote:
> On Fri, Jul 18, 2014 at 05:12:54PM +0200, Miklos Szeredi wrote:
> > On Fri, Jul 18, 2014 at 4:45 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > I assumed the source page would always be new, according to this part
> > > in fuse_try_move_page():
> > >
> > >         /*
> > >          * This is a new and locked page, it shouldn't be mapped or
> > >          * have any special flags on it
> > >          */
> > >         if (WARN_ON(page_mapped(oldpage)))
> > >                 goto out_fallback_unlock;
> > >         if (WARN_ON(page_has_private(oldpage)))
> > >                 goto out_fallback_unlock;
> > >         if (WARN_ON(PageDirty(oldpage) || PageWriteback(oldpage)))
> > >                 goto out_fallback_unlock;
> > >         if (WARN_ON(PageMlocked(oldpage)))
> > >                 goto out_fallback_unlock;
> > >
> > > However, it's in the page cache and I can't really convince myself
> > > that it's not also on the LRU.  Miklos, I have trouble pinpointing
> > > where oldpage is instantiated exactly and what state it might be in -
> > > can it already be on the LRU?
> > 
> > oldpage comes from ->readpages() (*NOT* ->readpage()), i.e. readahead.
> > 
> > AFAICS it is added to the LRU in read_cache_pages(), so it looks like
> > it is definitely on the LRU at that point.

OK, so my understanding of the code was wrong :/ and staring at it for
quite a while didn't help much. The fuse code is so full of indirection
it makes my head spin. So what is the exact state of old and new pages?
Both might be on LRU, ok, but can both of them be charged to a memcg?
Possibly different memcgs?

How should we test this code path, Miklos?

> I see, thanks!
> 
> Then we need charge migration to lock the page like I proposed.  But
> it's not enough: we also need to exclude isolation and putback while
> we uncharge it, and make sure that if it was on the LRU it's moved to
> the correct lruvec (the root memcg's):
> 
> ---
> From ce51bdcf02bee94a1f1049864b1665c2d9830281 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 18 Jul 2014 09:48:42 -0400
> Subject: [patch] mm: memcontrol: rewrite uncharge API fix - page cache
>  migration
> 
> It was known that the target page in migration could be on the LRU -
> clarify this in mem_cgroup_migrate() and correct the VM_BUG_ON_PAGE().
> 
> However, during page cache replacement, the source page can also be on
> the LRU, and two things need to be considered:
> 
> 1. charge moving can race and change pc->mem_cgroup from under us:
> grab the page lock in mem_cgroup_move_account() to prevent that.
>
> 2. the lruvec of the page changes as we uncharge it, and putback can
> race with us: grab the lru lock and isolate the page iff on LRU to
> prevent races and to ensure the page is on the right lruvec afterward.
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>

I am not sure this is appropriate as I didn't consider old page being on
LRU. I only didn't like VM_BUG_ON_PAGE without lru_care for newpage part
because this was known to blow up.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> ---
>  mm/memcontrol.c | 83 +++++++++++++++++++++++++++++++++++++++------------------
>  1 file changed, 57 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9db142d83b5c..b7c9a202dee9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2696,13 +2696,42 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	return memcg;
>  }
>  
> +static void lock_page_lru(struct page *page, int *isolated)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	spin_lock_irq(&zone->lru_lock);
> +	if (PageLRU(page)) {
> +		struct lruvec *lruvec;
> +
> +		lruvec = mem_cgroup_page_lruvec(page, zone);
> +		ClearPageLRU(page);
> +		del_page_from_lru_list(page, lruvec, page_lru(page));
> +		*isolated = 1;
> +	} else
> +		*isolated = 0;
> +}
> +
> +static void unlock_page_lru(struct page *page, int isolated)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	if (isolated) {
> +		struct lruvec *lruvec;
> +
> +		lruvec = mem_cgroup_page_lruvec(page, zone);
> +		VM_BUG_ON_PAGE(PageLRU(page), page);
> +		SetPageLRU(page);
> +		add_page_to_lru_list(page, lruvec, page_lru(page));
> +	}
> +	spin_unlock_irq(&zone->lru_lock);
> +}
> +
>  static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			  unsigned int nr_pages, bool lrucare)
>  {
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct zone *uninitialized_var(zone);
> -	bool was_on_lru = false;
> -	struct lruvec *lruvec;
> +	int isolated;
>  
>  	VM_BUG_ON_PAGE(PageCgroupUsed(pc), page);
>  	/*
> @@ -2714,16 +2743,8 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
>  	 * may already be on some other mem_cgroup's LRU.  Take care of it.
>  	 */
> -	if (lrucare) {
> -		zone = page_zone(page);
> -		spin_lock_irq(&zone->lru_lock);
> -		if (PageLRU(page)) {
> -			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
> -			ClearPageLRU(page);
> -			del_page_from_lru_list(page, lruvec, page_lru(page));
> -			was_on_lru = true;
> -		}
> -	}
> +	if (lrucare)
> +		lock_page_lru(page, &isolated);
>  
>  	/*
>  	 * Nobody should be changing or seriously looking at
> @@ -2742,15 +2763,8 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	pc->mem_cgroup = memcg;
>  	pc->flags = PCG_USED | PCG_MEM | (do_swap_account ? PCG_MEMSW : 0);
>  
> -	if (lrucare) {
> -		if (was_on_lru) {
> -			lruvec = mem_cgroup_zone_lruvec(zone, pc->mem_cgroup);
> -			VM_BUG_ON_PAGE(PageLRU(page), page);
> -			SetPageLRU(page);
> -			add_page_to_lru_list(page, lruvec, page_lru(page));
> -		}
> -		spin_unlock_irq(&zone->lru_lock);
> -	}
> +	if (lrucare)
> +		unlock_page_lru(page, isolated);
>  
>  	local_irq_disable();
>  	mem_cgroup_charge_statistics(memcg, page, nr_pages);
> @@ -3450,9 +3464,17 @@ static int mem_cgroup_move_account(struct page *page,
>  	if (nr_pages > 1 && !PageTransHuge(page))
>  		goto out;
>  
> +	/*
> +	 * Prevent mem_cgroup_migrate() from looking at pc->mem_cgroup
> +	 * of its source page while we change it: page migration takes
> +	 * both pages off the LRU, but page cache replacement doesn't.
> +	 */
> +	if (!trylock_page(page))
> +		goto out;
> +
>  	ret = -EINVAL;
>  	if (!PageCgroupUsed(pc) || pc->mem_cgroup != from)
> -		goto out;
> +		goto out_unlock;
>  
>  	move_lock_mem_cgroup(from, &flags);
>  
> @@ -3487,6 +3509,8 @@ static int mem_cgroup_move_account(struct page *page,
>  	mem_cgroup_charge_statistics(from, page, -nr_pages);
>  	memcg_check_events(from, page);
>  	local_irq_enable();
> +out_unlock:
> +	unlock_page(page);
>  out:
>  	return ret;
>  }
> @@ -6614,7 +6638,7 @@ void mem_cgroup_uncharge_list(struct list_head *page_list)
>   * mem_cgroup_migrate - migrate a charge to another page
>   * @oldpage: currently charged page
>   * @newpage: page to transfer the charge to
> - * @lrucare: page might be on LRU already
> + * @lrucare: both pages might be on the LRU already
>   *
>   * Migrate the charge from @oldpage to @newpage.
>   *
> @@ -6625,11 +6649,12 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  {
>  	unsigned int nr_pages = 1;
>  	struct page_cgroup *pc;
> +	int isolated;
>  
>  	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
>  	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> -	VM_BUG_ON_PAGE(PageLRU(oldpage), oldpage);
> -	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);
> +	VM_BUG_ON_PAGE(!lrucare && PageLRU(oldpage), oldpage);
> +	VM_BUG_ON_PAGE(!lrucare && PageLRU(newpage), newpage);
>  	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
>  
>  	if (mem_cgroup_disabled())
> @@ -6648,8 +6673,14 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
>  	}
>  
> +	if (lrucare)
> +		lock_page_lru(oldpage, &isolated);
> +
>  	pc->flags = 0;
>  
> +	if (lrucare)
> +		unlock_page_lru(oldpage, isolated);
> +
>  	local_irq_disable();
>  	mem_cgroup_charge_statistics(pc->mem_cgroup, oldpage, -nr_pages);
>  	memcg_check_events(pc->mem_cgroup, oldpage);
> -- 
> 2.0.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
