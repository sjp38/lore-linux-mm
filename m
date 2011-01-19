Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 63AA96B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 07:52:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A81D63EE0C1
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:52:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 91F4B45DE4E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:52:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E76145DE4F
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:52:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E9B4EF8001
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:52:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16FD21DB803B
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:52:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is not allowed
In-Reply-To: <20110118101547.GF27152@csn.ul.ie>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <20110118101547.GF27152@csn.ul.ie>
Message-Id: <20110119214908.2830.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 19 Jan 2011 21:52:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2084,7 +2084,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >  			struct zone *preferred_zone;
> >  
> >  			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
> > -							NULL, &preferred_zone);
> > +						&cpuset_current_mems_allowed,
> > +						&preferred_zone);
> >  			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
> 
> This part looks fine and a worthwhile fix all on its own.

No. Memcg reclaim should be cared cpuset-wall. Please look at shrink_zones().
And, Now I don't think checking only preferred zone is good idea. zone congestion
makes pageout() failure and makes lots lru rotation than necessary.

Following patch care all related zones, but keep sleep 0.1 seconds at maximum.

---
 mm/vmscan.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 55f5c0e..6b453d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1868,6 +1868,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 {
 	struct zoneref *z;
 	struct zone *zone;
+	long timeout = HZ/10;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -1886,6 +1887,32 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 
 		shrink_zone(priority, zone, sc);
 	}
+
+	/* No heavy pressure. */
+	if (priority >= DEF_PRIORITY - 2)
+		return;
+
+	/* Obviously we didn't issue IO. */
+	if (sc->nr_scanned == 0)
+		return;
+
+	/* Other tasks are freezed. IO congestion is no matter. */
+	if (sc->hibernation_mode)
+		return;
+
+	/* Take a nap, wait for some writeback to complete */
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+					gfp_zone(sc->gfp_mask), sc->nodemask) {
+		if (!populated_zone(zone))
+			continue;
+		if (scanning_global_lru(sc) &&
+		    !cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+			continue;
+
+		timeout = wait_iff_congested(zone, BLK_RW_ASYNC, timeout);
+		if (!timeout)
+			break;
+	}
 }
 
 static bool zone_reclaimable(struct zone *zone)
@@ -1993,16 +2020,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
 			sc->may_writepage = 1;
 		}
-
-		/* Take a nap, wait for some writeback to complete */
-		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    priority < DEF_PRIORITY - 2) {
-			struct zone *preferred_zone;
-
-			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
-							NULL, &preferred_zone);
-			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
-		}
 	}
 
 out:
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
