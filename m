Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7FE196B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:37:32 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so73422tia.8
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 16:37:29 -0800 (PST)
Date: Wed, 11 Feb 2009 09:37:15 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
Message-ID: <20090211003715.GB6422@barrios-desktop>
References: <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com> <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210215811.7010.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210162052.GB2371@cmpxchg.org> <2f11576a0902101241j5a006e09w46ecdbdb9c77e081@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0902101241j5a006e09w46ecdbdb9c77e081@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 11, 2009 at 05:41:21AM +0900, KOSAKI Motohiro wrote:
> >>  {
> >>       struct zone *zone;
> >> -     unsigned long nr_to_scan, ret = 0;
> >> +     unsigned long nr_to_scan;
> >>       enum lru_list l;
> >
> > Basing it on swsusp-clean-up-shrink_all_zones.patch probably makes it
> > easier for Andrew to pick it up.
> 
> ok, thanks.
> 
> >>                       reclaim_state.reclaimed_slab = 0;
> >> -                     shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> >> -                     ret += reclaim_state.reclaimed_slab;
> >> -             } while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
> >> +                     shrink_slab(nr_pages, sc.gfp_mask,
> >> +                                 global_lru_pages());
> >> +                     sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> >> +             } while (sc.nr_reclaimed < nr_pages &&
> >> +                      reclaim_state.reclaimed_slab > 0);
> >
> > :(
> >
> > Is this really an improvement?  `ret' is better to read than
> > `sc.nr_reclaimed'.
> 
> I know it's debetable thing.
> but I still think code consistency is important than variable name preference.

How about this ?

I followed do_try_to_free_pages coding style.
It use both 'sc->nr_reclaimed' and 'ret'.
It can support code consistency and readability. 

So, I think it would be better.  
If you don't mind, I will resend with your sign-off.

Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   43 +++++++++++++++++++++++++------------------
 1 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a27c44..989062a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2048,16 +2048,16 @@ unsigned long global_lru_pages(void)
 #ifdef CONFIG_PM
 /*
  * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
- * from LRU lists system-wide, for given pass and priority, and returns the
- * number of reclaimed pages
+ * from LRU lists system-wide, for given pass and priority.
  *
  * For pass > 3 we also try to shrink the LRU lists that contain a few pages
  */
-static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
+static void shrink_all_zones(unsigned long nr_pages, int prio,
 				      int pass, struct scan_control *sc)
 {
 	struct zone *zone;
 	unsigned long nr_to_scan, ret = 0;
+	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	enum lru_list l;
 
 	for_each_zone(zone) {
@@ -2082,15 +2082,14 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 				nr_to_scan = min(nr_pages,
 					zone_page_state(zone,
 							NR_LRU_BASE + l));
-				ret += shrink_list(l, nr_to_scan, zone,
+				nr_reclaimed += shrink_list(l, nr_to_scan, zone,
 								sc, prio);
-				if (ret >= nr_pages)
-					return ret;
-			}
+				if (nr_reclaimed >= nr_pages) 
+					break;
 		}
 	}
 
-	return ret;
+	sc->nr_reclaimed = nr_reclaimed;
 }
 
 /*
@@ -2127,9 +2126,11 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 		if (!reclaim_state.reclaimed_slab)
 			break;
 
-		ret += reclaim_state.reclaimed_slab;
-		if (ret >= nr_pages)
+		sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		if (sc.nr_reclaimed >= nr_pages) {
+			ret = sc.nr_reclaimed;
 			goto out;
+		}
 
 		nr_slab -= reclaim_state.reclaimed_slab;
 	}
@@ -2152,19 +2153,23 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 		}
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
-			unsigned long nr_to_scan = nr_pages - ret;
+			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
 
 			sc.nr_scanned = 0;
-			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
-			if (ret >= nr_pages)
+			shrink_all_zones(nr_to_scan, prio, pass, &sc);
+			if (sc.nr_reclaimed >= nr_pages) {
+				ret = sc.nr_reclaimed;
 				goto out;
+			}
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
 					global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-			if (ret >= nr_pages)
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+			if (sc.nr_reclaimed >= nr_pages) {
+				ret = sc.nr_reclaimed;
 				goto out;
+			}
 
 			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
 				congestion_wait(WRITE, HZ / 10);
@@ -2175,14 +2180,16 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	 * If ret = 0, we could not shrink LRUs, but there may be something
 	 * in slab caches
 	 */
-	if (!ret) {
+	if (!sc.nr_reclaimed) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
-			ret += reclaim_state.reclaimed_slab;
-		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
+			sc.nr_reclaimed += reclaim_state.reclaimed_slab;
+		} while (sc.nr_reclaimed < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
 
+	ret = sc.nr_reclaimed;
+
 out:
 	current->reclaim_state = NULL;
 
-- 
1.5.4.3

-- 

Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
