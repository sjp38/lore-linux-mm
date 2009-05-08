Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 075F56B0088
	for <linux-mm@kvack.org>; Fri,  8 May 2009 16:05:48 -0400 (EDT)
Date: Fri, 8 May 2009 12:58:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
Message-Id: <20090508125859.210a2a25.akpm@linux-foundation.org>
In-Reply-To: <20090508081608.GA25117@localhost>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: hannes@cmpxchg.org, peterz@infradead.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 May 2009 16:16:08 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> vmscan: make mapped executable pages the first class citizen
> 
> Protect referenced PROT_EXEC mapped pages from being deactivated.
> 
> PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
> currently running executables and their linked libraries, they shall really be
> cached aggressively to provide good user experiences.
> 

The patch seems reasonable but the changelog and the (non-existent)
design documentation could do with a touch-up.

> 
> --- linux.orig/mm/vmscan.c
> +++ linux/mm/vmscan.c
> @@ -1233,6 +1233,7 @@ static void shrink_active_list(unsigned 
>  	unsigned long pgscanned;
>  	unsigned long vm_flags;
>  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
> +	LIST_HEAD(l_active);
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
>  	struct pagevec pvec;
> @@ -1272,8 +1273,13 @@ static void shrink_active_list(unsigned 
>  
>  		/* page_referenced clears PageReferenced */
>  		if (page_mapping_inuse(page) &&
> -		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
> +		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
>  			pgmoved++;
> +			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> +				list_add(&page->lru, &l_active);
> +				continue;
> +			}
> +		}

What we're doing here is to identify referenced, file-backed active
pages.  We clear their referenced bit and give than another trip around
the active list.  So if they aren't referenced during that additional
pass, they will get deactivated next time they are scanned, yes?  It's
a fairly high-level design/heuristic thing which needs careful
commenting, please.


Also, the change makes this comment:

	spin_lock_irq(&zone->lru_lock);
	/*
	 * Count referenced pages from currently used mappings as
	 * rotated, even though they are moved to the inactive list.
	 * This helps balance scan pressure between file and anonymous
	 * pages in get_scan_ratio.
	 */
	reclaim_stat->recent_rotated[!!file] += pgmoved;

inaccurate.
								
>  		list_add(&page->lru, &l_inactive);
>  	}
> @@ -1282,7 +1288,6 @@ static void shrink_active_list(unsigned 
>  	 * Move the pages to the [file or anon] inactive list.
>  	 */
>  	pagevec_init(&pvec, 1);
> -	lru = LRU_BASE + file * LRU_FILE;
>  
>  	spin_lock_irq(&zone->lru_lock);
>  	/*
> @@ -1294,6 +1299,7 @@ static void shrink_active_list(unsigned 
>  	reclaim_stat->recent_rotated[!!file] += pgmoved;
>  
>  	pgmoved = 0;  /* count pages moved to inactive list */
> +	lru = LRU_BASE + file * LRU_FILE;
>  	while (!list_empty(&l_inactive)) {
>  		page = lru_to_page(&l_inactive);
>  		prefetchw_prev_lru_page(page, &l_inactive, flags);
> @@ -1316,6 +1322,29 @@ static void shrink_active_list(unsigned 
>  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
>  	__count_vm_events(PGDEACTIVATE, pgmoved);
> +
> +	pgmoved = 0;  /* count pages moved back to active list */
> +	lru = LRU_ACTIVE + file * LRU_FILE;
> +	while (!list_empty(&l_active)) {
> +		page = lru_to_page(&l_active);
> +		prefetchw_prev_lru_page(page, &l_active, flags);
> +		VM_BUG_ON(PageLRU(page));
> +		SetPageLRU(page);
> +		VM_BUG_ON(!PageActive(page));
> +
> +		list_move(&page->lru, &zone->lru[lru].list);
> +		mem_cgroup_add_lru_list(page, lru);
> +		pgmoved++;
> +		if (!pagevec_add(&pvec, page)) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			if (buffer_heads_over_limit)
> +				pagevec_strip(&pvec);
> +			__pagevec_release(&pvec);
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +	}

The copy-n-pasting here is unfortunate.  But I expect that if we redid
this as a loop, the result would be a bit ugly - the pageActive
handling gets in the way.

> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);

Is it just me, is is all this stuff:

	lru = LRU_ACTIVE + file * LRU_FILE;
	...
	foo(NR_LRU_BASE + lru);

really hard to read?



Now.  How do we know that this patch improves Linux?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
