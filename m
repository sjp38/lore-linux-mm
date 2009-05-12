Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 270376B005A
	for <linux-mm@kvack.org>; Mon, 11 May 2009 22:50:34 -0400 (EDT)
Date: Tue, 12 May 2009 10:50:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090512025058.GA7518@localhost>
References: <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090507134410.0618b308.akpm@linux-foundation.org> <20090508081608.GA25117@localhost> <20090508125859.210a2a25.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508125859.210a2a25.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sat, May 09, 2009 at 03:58:59AM +0800, Andrew Morton wrote:
> On Fri, 8 May 2009 16:16:08 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > vmscan: make mapped executable pages the first class citizen
> > 
> > Protect referenced PROT_EXEC mapped pages from being deactivated.
> > 
> > PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to some
> > currently running executables and their linked libraries, they shall really be
> > cached aggressively to provide good user experiences.
> > 
> 
> The patch seems reasonable but the changelog and the (non-existent)
> design documentation could do with a touch-up.

Sure, I expanded the changelog a lot :-)

> > 
> > --- linux.orig/mm/vmscan.c
> > +++ linux/mm/vmscan.c
> > @@ -1233,6 +1233,7 @@ static void shrink_active_list(unsigned 
> >  	unsigned long pgscanned;
> >  	unsigned long vm_flags;
> >  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
> > +	LIST_HEAD(l_active);
> >  	LIST_HEAD(l_inactive);
> >  	struct page *page;
> >  	struct pagevec pvec;
> > @@ -1272,8 +1273,13 @@ static void shrink_active_list(unsigned 
> >  
> >  		/* page_referenced clears PageReferenced */
> >  		if (page_mapping_inuse(page) &&
> > -		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
> > +		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
> >  			pgmoved++;
> > +			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> > +				list_add(&page->lru, &l_active);
> > +				continue;
> > +			}
> > +		}
> 
> What we're doing here is to identify referenced, file-backed active
> pages.  We clear their referenced bit and give than another trip around
> the active list.  So if they aren't referenced during that additional
> pass, they will get deactivated next time they are scanned, yes?  It's
> a fairly high-level design/heuristic thing which needs careful
> commenting, please.

OK. I tried to explain the logic behind the code with the following comments:

+                       /*
+                        * Identify referenced, file-backed active pages and
+                        * give them one more trip around the active list. So
+                        * that executable code get better chances to stay in
+                        * memory under moderate memory pressure.  Anon pages
+                        * are ignored, since JVM can create lots of anon
+                        * VM_EXEC pages.
+                        */


> 
> Also, the change makes this comment:
> 
> 	spin_lock_irq(&zone->lru_lock);
> 	/*
> 	 * Count referenced pages from currently used mappings as
> 	 * rotated, even though they are moved to the inactive list.
> 	 * This helps balance scan pressure between file and anonymous
> 	 * pages in get_scan_ratio.
> 	 */
> 	reclaim_stat->recent_rotated[!!file] += pgmoved;
> 
> inaccurate.

Good catch, I'll just remove the stale "even though they are moved to
the inactive list".
 								
> >  		list_add(&page->lru, &l_inactive);
> >  	}
> > @@ -1282,7 +1288,6 @@ static void shrink_active_list(unsigned 
> >  	 * Move the pages to the [file or anon] inactive list.
> >  	 */
> >  	pagevec_init(&pvec, 1);
> > -	lru = LRU_BASE + file * LRU_FILE;
> >  
> >  	spin_lock_irq(&zone->lru_lock);
> >  	/*
> > @@ -1294,6 +1299,7 @@ static void shrink_active_list(unsigned 
> >  	reclaim_stat->recent_rotated[!!file] += pgmoved;
> >  
> >  	pgmoved = 0;  /* count pages moved to inactive list */
> > +	lru = LRU_BASE + file * LRU_FILE;
> >  	while (!list_empty(&l_inactive)) {
> >  		page = lru_to_page(&l_inactive);
> >  		prefetchw_prev_lru_page(page, &l_inactive, flags);
> > @@ -1316,6 +1322,29 @@ static void shrink_active_list(unsigned 
> >  	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> >  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> >  	__count_vm_events(PGDEACTIVATE, pgmoved);
> > +
> > +	pgmoved = 0;  /* count pages moved back to active list */
> > +	lru = LRU_ACTIVE + file * LRU_FILE;
> > +	while (!list_empty(&l_active)) {
> > +		page = lru_to_page(&l_active);
> > +		prefetchw_prev_lru_page(page, &l_active, flags);
> > +		VM_BUG_ON(PageLRU(page));
> > +		SetPageLRU(page);
> > +		VM_BUG_ON(!PageActive(page));
> > +
> > +		list_move(&page->lru, &zone->lru[lru].list);
> > +		mem_cgroup_add_lru_list(page, lru);
> > +		pgmoved++;
> > +		if (!pagevec_add(&pvec, page)) {
> > +			spin_unlock_irq(&zone->lru_lock);
> > +			if (buffer_heads_over_limit)
> > +				pagevec_strip(&pvec);
> > +			__pagevec_release(&pvec);
> > +			spin_lock_irq(&zone->lru_lock);
> > +		}
> > +	}
> 
> The copy-n-pasting here is unfortunate.  But I expect that if we redid
> this as a loop, the result would be a bit ugly - the pageActive
> handling gets in the way.

Yup. I introduced a function for the two mostly duplicated code blocks.
 
> > +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> 
> Is it just me, is is all this stuff:
> 
> 	lru = LRU_ACTIVE + file * LRU_FILE;
> 	...
> 	foo(NR_LRU_BASE + lru);
> 
> really hard to read?

Yes, it seems hacky, but can hardly be reduced because the full code is

  	lru = LRU_ACTIVE + file * LRU_FILE;
  	...
        foo(lru);
        ...
  	bar(NR_LRU_BASE + lru);

> 
> Now.  How do we know that this patch improves Linux?

Hmm, it seems hard to get measurable performance numbers.

But we know that the running executable code is precious and shall be
protected, and the patch protects them in this way:

        before patch: will be reclaimed if not referenced in I
        after  patch: will be reclaimed if not referenced in I+A
where
        A = time to fully scan the active   file LRU
        I = time to fully scan the inactive file LRU

Note that normally A >> I.

Therefore this patch greatly prolongs the in-cache time of executable code,
when there are moderate memory pressures.


Followed are the three updated patches.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
