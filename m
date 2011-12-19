Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 693426B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 08:26:21 -0500 (EST)
Date: Mon, 19 Dec 2011 13:26:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111219132615.GL3487@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <20111217160822.GA10064@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111217160822.GA10064@barrios-laptop.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Dec 18, 2011 at 01:08:22AM +0900, Minchan Kim wrote:
> On Wed, Dec 14, 2011 at 03:41:33PM +0000, Mel Gorman wrote:
> > It was observed that scan rates from direct reclaim during tests
> > writing to both fast and slow storage were extraordinarily high. The
> > problem was that while pages were being marked for immediate reclaim
> > when writeback completed, the same pages were being encountered over
> > and over again during LRU scanning.
> > 
> > This patch isolates file-backed pages that are to be reclaimed when
> > clean on their own LRU list.
> 
> Please include your test result about reducing CPU usage.
> It makes this separate LRU list how vaule is.
> 

It's in the leader. The writebackCPDevicevfat tests should that System
CPU goes from 46.40 seconds to 4.44 seconds with this patch applied.

> > <SNIP>
> >
> > diff --git a/mm/swap.c b/mm/swap.c
> > index a91caf7..9973975 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -39,6 +39,7 @@ int page_cluster;
> >  
> >  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> >  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> > +static DEFINE_PER_CPU(struct pagevec, lru_putback_immediate_pvecs);
> >  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
> >  
> >  /*
> > @@ -255,24 +256,80 @@ static void pagevec_move_tail(struct pagevec *pvec)
> >  }
> >  
> >  /*
> > + * Similar pair of functions to pagevec_move_tail except it is called when
> > + * moving a page from the LRU_IMMEDIATE to one of the [in]active_[file|anon]
> > + * lists
> > + */
> > +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +
> > +	if (PageLRU(page)) {
> > +		enum lru_list lru = page_lru(page);
> > +		list_move(&page->lru, &zone->lru[lru].list);
> > +	}
> > +}
> > +
> > +static void pagevec_putback_immediate(struct pagevec *pvec)
> > +{
> > +	pagevec_lru_move_fn(pvec, pagevec_putback_immediate_fn, NULL);
> > +}
> > +
> > +/*
> >   * Writeback is about to end against a page which has been marked for immediate
> >   * reclaim.  If it still appears to be reclaimable, move it to the tail of the
> >   * inactive list.
> >   */
> >  void rotate_reclaimable_page(struct page *page)
> >  {
> > +	struct zone *zone = page_zone(page);
> > +	struct list_head *page_list;
> > +	struct pagevec *pvec;
> > +	unsigned long flags;
> > +
> > +	page_cache_get(page);
> > +	local_irq_save(flags);
> > +	__mod_zone_page_state(zone, NR_IMMEDIATE, -1);
> > +
> 
> I am not sure underflow never happen.
> We do SetPageReclaim at several places but dont' increase NR_IMMEDIATE.
> 

In those cases, we do not move the page to the immedate list either.
During one test I was recording /proc/vmstat every 10 seconds and never
saw an underflow.

> >  	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
> >  	    !PageUnevictable(page) && PageLRU(page)) {
> > -		struct pagevec *pvec;
> > -		unsigned long flags;
> >  
> > -		page_cache_get(page);
> > -		local_irq_save(flags);
> >  		pvec = &__get_cpu_var(lru_rotate_pvecs);
> >  		if (!pagevec_add(pvec, page))
> >  			pagevec_move_tail(pvec);
> > -		local_irq_restore(flags);
> > +	} else {
> > +		pvec = &__get_cpu_var(lru_putback_immediate_pvecs);
> > +		if (!pagevec_add(pvec, page))
> > +			pagevec_putback_immediate(pvec);
> 
> Nitpick about naming.

Naming is important.

> It doesn't say immediate is from or to. So I got confused
> which is source. I know comment of function already say it
> but good naming can reduce unnecessary comment.
> How about pagevec_putback_from_immediate_list?
> 

Sure. Done.

> > +	}
> > +
> > +	/*
> > +	 * There is a potential race that if a page is set PageReclaim
> > +	 * and moved to the LRU_IMMEDIATE list after writeback completed,
> > +	 * it can be left on the LRU_IMMEDATE list with no way for
> > +	 * reclaim to find it.
> > +	 *
> > +	 * This race should be very rare but count how often it happens.
> > +	 * If it is a continual race, then it's very unsatisfactory as there
> > +	 * is no guarantee that rotate_reclaimable_page() will be called
> > +	 * to rescue these pages but finding them in page reclaim is also
> > +	 * problematic due to the problem of deciding when the right time
> > +	 * to scan this list is.
> > +	 */
> > +	page_list = &zone->lru[LRU_IMMEDIATE].list;
> > +	if (!zone_page_state(zone, NR_IMMEDIATE) && !list_empty(page_list)) {
> 
> How about this
> 
> if (zone_page_state(zone, NR_IMMEDIATE)) {
> 	page_list = &zone->lru[LRU_IMMEDIATE].list;
> 	if (!list_empty(page_list))
> ...
> ...
> }
> 
> It can reduce a unnecessary reference.
> 

Ok, it mucks up the indentation a bit but with some renaming it looks
reasonable.

> > +		struct page *page;
> > +
> > +		spin_lock(&zone->lru_lock);
> > +		while (!list_empty(page_list)) {
> > +			page = list_entry(page_list->prev, struct page, lru);
> > +			list_move(&page->lru, &zone->lru[page_lru(page)].list);
> > +			__count_vm_event(PGRESCUED);
> > +		}
> > +		spin_unlock(&zone->lru_lock);
> >  	}
> > +
> > +	local_irq_restore(flags);
> >  }
> >  
> >  static void update_page_reclaim_stat(struct zone *zone, struct page *page,
> > @@ -475,6 +532,13 @@ static void lru_deactivate_fn(struct page *page, void *arg)
> >  		 * is _really_ small and  it's non-critical problem.
> >  		 */
> >  		SetPageReclaim(page);
> > +
> > +		/*
> > +		 * Move to the LRU_IMMEDIATE list to avoid being scanned
> > +		 * by page reclaim uselessly.
> > +		 */
> > +		list_move_tail(&page->lru, &zone->lru[LRU_IMMEDIATE].list);
> > +		__mod_zone_page_state(zone, NR_IMMEDIATE, 1);
> 
> It mekes below count of PGDEACTIVATE wrong in lru_deactivate_fn.
> Before this patch, all is from active to inacive so it was right.
> But with this patch, it can be from acdtive to immediate.
> 

I do not quite understand. PGDEACTIVATE is incremented if the page was
active and this is checked before the move to the immediate LRU. Whether
it moves to the immediate LRU or the end of the inactive list, it is
still a deactivation. What's wrong with incrementing the count if it
moves from active to immediate?

==== CUT HERE ====
mm: Isolate pages for immediate reclaim on their own LRU fix

Rename pagevec_putback_immediate_fn to pagevec_putback_from_immediate_fn
for clarity and alter flow of rotate_reclaimable_page() slightly to
avoid an unnecessary list reference.

This is a fix to the patch
mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in mmotm.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/swap.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 9973975..dfe67eb 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -260,7 +260,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
  * moving a page from the LRU_IMMEDIATE to one of the [in]active_[file|anon]
  * lists
  */
-static void pagevec_putback_immediate_fn(struct page *page, void *arg)
+static void pagevec_putback_from_immediate_fn(struct page *page, void *arg)
 {
 	struct zone *zone = page_zone(page);
 
@@ -270,9 +270,9 @@ static void pagevec_putback_immediate_fn(struct page *page, void *arg)
 	}
 }
 
-static void pagevec_putback_immediate(struct pagevec *pvec)
+static void pagevec_putback_from_immediate(struct pagevec *pvec)
 {
-	pagevec_lru_move_fn(pvec, pagevec_putback_immediate_fn, NULL);
+	pagevec_lru_move_fn(pvec, pagevec_putback_from_immediate_fn, NULL);
 }
 
 /*
@@ -283,7 +283,7 @@ static void pagevec_putback_immediate(struct pagevec *pvec)
 void rotate_reclaimable_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
-	struct list_head *page_list;
+	struct list_head *list;
 	struct pagevec *pvec;
 	unsigned long flags;
 
@@ -300,7 +300,7 @@ void rotate_reclaimable_page(struct page *page)
 	} else {
 		pvec = &__get_cpu_var(lru_putback_immediate_pvecs);
 		if (!pagevec_add(pvec, page))
-			pagevec_putback_immediate(pvec);
+			pagevec_putback_from_immediate(pvec);
 	}
 
 	/*
@@ -316,17 +316,21 @@ void rotate_reclaimable_page(struct page *page)
 	 * problematic due to the problem of deciding when the right time
 	 * to scan this list is.
 	 */
-	page_list = &zone->lru[LRU_IMMEDIATE].list;
-	if (!zone_page_state(zone, NR_IMMEDIATE) && !list_empty(page_list)) {
+	if (!zone_page_state(zone, NR_IMMEDIATE)) {
 		struct page *page;
-
-		spin_lock(&zone->lru_lock);
-		while (!list_empty(page_list)) {
-			page = list_entry(page_list->prev, struct page, lru);
-			list_move(&page->lru, &zone->lru[page_lru(page)].list);
-			__count_vm_event(PGRESCUED);
+		list = &zone->lru[LRU_IMMEDIATE].list;
+		
+		if (!list_empty(list)) {
+			spin_lock(&zone->lru_lock);
+			while (!list_empty(list)) {
+				int lru;
+				page = list_entry(list->prev, struct page, lru);
+				lru = page_lru(page);
+				list_move(&page->lru, &zone->lru[lru].list);
+				__count_vm_event(PGRESCUED);
+			}
+			spin_unlock(&zone->lru_lock);
 		}
-		spin_unlock(&zone->lru_lock);
 	}
 
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
