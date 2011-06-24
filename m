Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E854F900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 07:44:49 -0400 (EDT)
Date: Fri, 24 Jun 2011 12:44:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: sandy bridge kswapd0 livelock with pagecache
Message-ID: <20110624114444.GP9396@suse.de>
References: <20110621130756.GH9396@suse.de>
 <4E00A96D.8020806@draigBrady.com>
 <20110622094401.GJ9396@suse.de>
 <4E01C19F.20204@draigBrady.com>
 <20110623114646.GM9396@suse.de>
 <4E0339CF.8080407@draigBrady.com>
 <20110623152418.GN9396@suse.de>
 <4E035C8B.1080905@draigBrady.com>
 <20110623165955.GO9396@suse.de>
 <4E039334.7090502@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4E039334.7090502@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: P?draig Brady <P@draigBrady.com>
Cc: linux-mm@kvack.org

On Thu, Jun 23, 2011 at 08:25:40PM +0100, P?draig Brady wrote:
> On 23/06/11 17:59, Mel Gorman wrote:
> > On Thu, Jun 23, 2011 at 04:32:27PM +0100, P?draig Brady wrote:
> >> On 23/06/11 16:24, Mel Gorman wrote:
> >>>
> >>> Theory 2 it is then. This is to be applied on top of the patch for
> >>> theory 1.
> >>>
> >>> ==== CUT HERE ====
> >>> mm: vmscan: Prevent kswapd doing excessive work when classzone is unreclaimable
> >>
> >> No joy :(
> >>
> > 
> > Joy is indeed rapidly fleeing the vicinity.
> > 
> > Check /proc/sys/vm/laptop_mode . If it's set, unset it and try again.
> 
> It was not set
> 
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index dce95dd..c8c0f5a 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2426,19 +2426,19 @@ loop_again:
> >  			 * zone has way too many pages free already.
> >  			 */
> >  			if (!zone_watermark_ok_safe(zone, order,
> > -					8*high_wmark_pages(zone), end_zone, 0))
> 
> Note 8 was not in my tree.
> Manually applied patch makes no difference :(
> Well maybe kswapd0 started spinning a little later.
> 

Gack :)

On further reflection "mm: vmscan: Prevent kswapd doing excessive
work when classzone is unreclaimable" was off but it was along the
right lines in that the balancing classzone was not being considered
when going to sleep.

The following is a patch against mainline 2.6.38.8 and is a
roll-up of four separate patches that includes a new modification to
sleeping_prematurely. Because the stack I am working off has changed
significantly, it's far easier if you apply this on top of a vanilla
fedora branch of 2.6.38 and test rather than trying to backout and
reapply. Depending on when you checked out or if you have applied the
BALANCE_GAP patch yourself, it might collide with 8*high_wmark_pages
but the resolution should be straight-forward.

Thanks for persisting.

==== CUT HERE ====
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a74bf72..da45335 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2261,7 +2261,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		return true;
 
 	/* Check the watermark levels */
-	for (i = 0; i < pgdat->nr_zones; i++) {
+	for (i = 0; i <= classzone_idx; i++) {
 		struct zone *zone = pgdat->node_zones + i;
 
 		if (!populated_zone(zone))
@@ -2279,7 +2279,7 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 		}
 
 		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							classzone_idx, 0))
+							i, 0))
 			all_zones_ok = false;
 		else
 			balanced += zone->present_pages;
@@ -2381,7 +2381,6 @@ loop_again:
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
 				end_zone = i;
-				*classzone_idx = i;
 				break;
 			}
 		}
@@ -2426,19 +2425,19 @@ loop_again:
 			 * zone has way too many pages free already.
 			 */
 			if (!zone_watermark_ok_safe(zone, order,
-					8*high_wmark_pages(zone), end_zone, 0))
-				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_scanned += sc.nr_scanned;
-
-			if (zone->all_unreclaimable)
-				continue;
-			if (nr_slab == 0 &&
-			    !zone_reclaimable(zone))
-				zone->all_unreclaimable = 1;
+					8*high_wmark_pages(zone), end_zone, 0)) {
+				shrink_zone(priority, zone, &sc); 
+
+				reclaim_state->reclaimed_slab = 0;
+				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
+							lru_pages);
+				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				total_scanned += sc.nr_scanned;
+
+				if (nr_slab == 0 && !zone_reclaimable(zone))
+					zone->all_unreclaimable = 1;
+			}
+
 			/*
 			 * If we've done a decent amount of scanning and
 			 * the reclaim ratio is low, start doing writepage
@@ -2448,6 +2447,12 @@ loop_again:
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 
+			if (zone->all_unreclaimable) {
+				if (end_zone && end_zone == i)
+					end_zone--;
+				continue;
+			}
+
 			if (!zone_watermark_ok_safe(zone, order,
 					high_wmark_pages(zone), end_zone, 0)) {
 				all_zones_ok = 0;
@@ -2626,8 +2631,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzone_idx)
  */
 static int kswapd(void *p)
 {
-	unsigned long order;
-	int classzone_idx;
+	unsigned long order, new_order;
+	int classzone_idx, new_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 
@@ -2657,17 +2662,23 @@ static int kswapd(void *p)
 	tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
 	set_freezable();
 
-	order = 0;
-	classzone_idx = MAX_NR_ZONES - 1;
+	order = new_order = 0;
+	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
 	for ( ; ; ) {
-		unsigned long new_order;
-		int new_classzone_idx;
 		int ret;
 
-		new_order = pgdat->kswapd_max_order;
-		new_classzone_idx = pgdat->classzone_idx;
-		pgdat->kswapd_max_order = 0;
-		pgdat->classzone_idx = MAX_NR_ZONES - 1;
+		/*
+		 * If the last balance_pgdat was unsuccessful it's unlikely a
+		 * new request of a similar or harder type will succeed soon
+		 * so consider going to sleep on the basis we reclaimed at
+		 */
+		if (classzone_idx >= new_classzone_idx && order == new_order) {
+			new_order = pgdat->kswapd_max_order;
+			new_classzone_idx = pgdat->classzone_idx;
+			pgdat->kswapd_max_order =  0;
+			pgdat->classzone_idx = pgdat->nr_zones - 1;
+		}
+
 		if (order < new_order || classzone_idx > new_classzone_idx) {
 			/*
 			 * Don't sleep if someone wants a larger 'order'
@@ -2680,7 +2691,7 @@ static int kswapd(void *p)
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order = 0;
-			pgdat->classzone_idx = MAX_NR_ZONES - 1;
+			pgdat->classzone_idx = pgdat->nr_zones - 1;
 		}
 
 		ret = try_to_freeze();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
