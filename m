Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ADE546B0055
	for <linux-mm@kvack.org>; Tue, 12 May 2009 04:17:36 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2410132wfa.11
        for <linux-mm@kvack.org>; Tue, 12 May 2009 01:17:51 -0700 (PDT)
Date: Tue, 12 May 2009 17:17:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
Message-Id: <20090512171729.3fe475d1.minchan.kim@barrios-desktop>
In-Reply-To: <20090512025246.GC7518@localhost>
References: <20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
	<20090508125859.210a2a25.akpm@linux-foundation.org>
	<20090512025246.GC7518@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 10:52:46 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

That is great explanation. :)

Now, we just need any numbers. 
But, as you know, It is difficult to get the numbers for various workloads. 

I don't know it is job of you or us ?? 
MM tree is always not stable. It's place to test freely for various workloads.

If we can justify patch at least, we can test it after merge once. 
(Of course, It depends on Andrew )
After long testing without any regresssions, we can merge this into linus tree. 

I think this patch is enough. 

Wu Fengguang 
Please, resend this patch series with modifying 'merge duplicate code in shrink_active_list' patch. 

Thanks for your great effort. :)

> Protect referenced PROT_EXEC mapped pages from being deactivated.
> 
> PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
> currently running executables and their linked libraries, they shall really be
> cached aggressively to provide good user experiences.
> 
> Thanks to Johannes Weiner for the advice to reuse the VMA walk in
> page_referenced() to get the PROT_EXEC bit.
> 
> 
> [more details]
> 
> ( The consequences of this patch will have to be discussed together with
>   Rik van Riel's recent patch "vmscan: evict use-once pages first". )
> 
> ( Some of the good points and insights are taken into this changelog.
>   Thanks to all the involved people for the great LKML discussions. )
> 
> the problem
> -----------
> 
> For a typical desktop, the most precious working set is composed of
> *actively accessed*
> 	(1) memory mapped executables
> 	(2) and their anonymous pages
> 	(3) and other files
> 	(4) and the dcache/icache/.. slabs
> while the least important data are
> 	(5) infrequently used or use-once files
> 
> For a typical desktop, one major problem is busty and large amount of (5)
> use-once files flushing out the working set.
> 
> Inside the working set, (4) dcache/icache have already been too sticky ;-)
> So we only have to care (2) anonymous and (1)(3) file pages.
> 
> anonymous pages
> ---------------
> Anonymous pages are effectively immune to the streaming IO attack, because we
> now have separate file/anon LRU lists. When the use-once files crowd into the
> file LRU, the list's "quality" is significantly lowered. Therefore the scan
> balance policy in get_scan_ratio() will choose to scan the (low quality) file
> LRU much more frequently than the anon LRU.
> 
> file pages
> ----------
> Rik proposed to *not* scan the active file LRU when the inactive list grows
> larger than active list. This guarantees that when there are use-once streaming
> IO, and the working set is not too large(so that active_size < inactive_size),
> the active file LRU will *not* be scanned at all. So the not-too-large working
> set can be well protected.
> 
> But there are also situations where the file working set is a bit large so that
> (active_size >= inactive_size), or the streaming IOs are not purely use-once.
> In these cases, the active list will be scanned slowly. Because the current
> shrink_active_list() policy is to deactivate active pages regardless of their
> referenced bits. The deactivated pages become susceptible to the streaming IO
> attack: the inactive list could be scanned fast (500MB / 50MBps = 10s) so that
> the deactivated pages don't have enough time to get re-referenced. Because a
> user tend to switch between windows in intervals from seconds to minutes.
> 
> This patch holds mapped executable pages in the active list as long as they
> are referenced during each full scan of the active list.  Because the active
> list is normally scanned much slower, they get longer grace time (eg. 100s)
> for further references, which better matches the pace of user operations.
> 
> side effects
> ------------
> 
> This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
> but in a much smaller and well targeted scope.
> 
> One may worry about some one to abuse the PROT_EXEC heuristic.  But as
> Andrew Morton stated, there are other tricks to getting that sort of boost.
> 
> Another concern is the PROT_EXEC mapped pages growing large in rare cases,
> and therefore hurting reclaim efficiency. But a sane application targeted for
> large audience will never use PROT_EXEC for data mappings. If some home made
> application tries to abuse that bit, it shall be aware of the consequences,
> which won't be disastrous even in the worst case.
> 
> CC: Elladan <elladan@eskimo.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/vmscan.c |   41 +++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 39 insertions(+), 2 deletions(-)
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
> @@ -1272,8 +1273,21 @@ static void shrink_active_list(unsigned 
>  
>  		/* page_referenced clears PageReferenced */
>  		if (page_mapping_inuse(page) &&
> -		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
> +		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
>  			pgmoved++;
> +			/*
> +			 * Identify referenced, file-backed active pages and
> +			 * give them one more trip around the active list. So
> +			 * that executable code get better chances to stay in
> +			 * memory under moderate memory pressure.  Anon pages
> +			 * are ignored, since JVM can create lots of anon
> +			 * VM_EXEC pages.
> +			 */
> +			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> +				list_add(&page->lru, &l_active);
> +				continue;
> +			}
> +		}
>  
>  		list_add(&page->lru, &l_inactive);
>  	}
> @@ -1282,7 +1296,6 @@ static void shrink_active_list(unsigned 
>  	 * Move the pages to the [file or anon] inactive list.
>  	 */
>  	pagevec_init(&pvec, 1);
> -	lru = LRU_BASE + file * LRU_FILE;
>  
>  	spin_lock_irq(&zone->lru_lock);
>  	/*
> @@ -1294,6 +1307,7 @@ static void shrink_active_list(unsigned 
>  	reclaim_stat->recent_rotated[!!file] += pgmoved;
>  
>  	pgmoved = 0;  /* count pages moved to inactive list */
> +	lru = LRU_BASE + file * LRU_FILE;
>  	while (!list_empty(&l_inactive)) {
>  		page = lru_to_page(&l_inactive);
>  		prefetchw_prev_lru_page(page, &l_inactive, flags);
> @@ -1316,6 +1330,29 @@ static void shrink_active_list(unsigned 
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
> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +
>  	spin_unlock_irq(&zone->lru_lock);
>  	if (buffer_heads_over_limit)
>  		pagevec_strip(&pvec);


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
