Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4858D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 07:06:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2D9A53EE0B5
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:05:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD9145DE5E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:05:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD2D445DE56
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:05:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C1018E38004
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:05:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB8BE08003
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:05:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <20110322194721.B05E.A69D9226@jp.fujitsu.com>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com> <20110322194721.B05E.A69D9226@jp.fujitsu.com>
Message-Id: <20110322200523.B061.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 22 Mar 2011 20:05:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

all_unreclaimable check in direct reclaim has been introduced at 2.6.19
by following commit.

	2006 Sep 25; commit 408d8544; oom: use unreclaimable info

And it went through strange history. firstly, following commit broke
the logic unintentionally.

	2008 Apr 29; commit a41f24ea; page allocator: smarter retry of
				      costly-order allocations

Two years later, I've found obvious meaningless code fragment and
restored original intention by following commit.

	2010 Jun 04; commit bb21c7ce; vmscan: fix do_try_to_free_pages()
				      return value when priority==0

But, the logic didn't works when 32bit highmem system goes hibernation
and Minchan slightly changed the algorithm and fixed it .

	2010 Sep 22: commit d1908362: vmscan: check all_unreclaimable
				      in direct reclaim path

But, recently, Andrey Vagin found the new corner case. Look,

	struct zone {
	  ..
	        int                     all_unreclaimable;
	  ..
	        unsigned long           pages_scanned;
	  ..
	}

zone->all_unreclaimable and zone->pages_scanned are neigher atomic
variables nor protected by lock. Therefore a zone can become a state
of zone->page_scanned=0 and zone->all_unreclaimable=1. In this case,
current all_unreclaimable() return false even though
zone->all_unreclaimabe=1.

Is this ignorable minor issue? No. Unfortunatelly, x86 has very
small dma zone and it become zone->all_unreclamble=1 easily. and
if it becase all_unreclaimable, it never return all_unreclaimable=0
beucase it typicall don't have reclaimable pages.

Eventually, oom-killer never works on such systems.  Let's remove
this problematic logic completely.

Reported-by: Andrey Vagin <avagin@openvz.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   36 +-----------------------------------
 1 files changed, 1 insertions(+), 35 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 060e4c1..254aada 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1989,33 +1989,6 @@ static bool zone_reclaimable(struct zone *zone)
 }
 
 /*
- * As hibernation is going on, kswapd is freezed so that it can't mark
- * the zone into all_unreclaimable. It can't handle OOM during hibernation.
- * So let's check zone's unreclaimable in direct reclaim as well as kswapd.
- */
-static bool all_unreclaimable(struct zonelist *zonelist,
-		struct scan_control *sc)
-{
-	struct zoneref *z;
-	struct zone *zone;
-	bool all_unreclaimable = true;
-
-	for_each_zone_zonelist_nodemask(zone, z, zonelist,
-			gfp_zone(sc->gfp_mask), sc->nodemask) {
-		if (!populated_zone(zone))
-			continue;
-		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-			continue;
-		if (zone_reclaimable(zone)) {
-			all_unreclaimable = false;
-			break;
-		}
-	}
-
-	return all_unreclaimable;
-}
-
-/*
  * This is the main entry point to direct page reclaim.
  *
  * If a full scan of the inactive list fails to free enough memory then we
@@ -2105,14 +2078,7 @@ out:
 	delayacct_freepages_end();
 	put_mems_allowed();
 
-	if (sc->nr_reclaimed)
-		return sc->nr_reclaimed;
-
-	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
-		return 1;
-
-	return 0;
+	return sc->nr_reclaimed;
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
