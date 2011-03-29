Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBD218D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:40:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CF9413EE0C0
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:40:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B62B745DE6D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:40:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8896045DE6A
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:40:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78EF61DB8041
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:40:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 35DC01DB803C
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 19:40:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/4] vmscan: all_unreclaimable() use zone->all_unreclaimable as the name
In-Reply-To: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
References: <20110329193953.2B7E.A69D9226@jp.fujitsu.com>
Message-Id: <20110329194044.2B82.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 29 Mar 2011 19:40:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

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
variables nor protected by lock. Therefore zones can become a state
of zone->page_scanned=0 and zone->all_unreclaimable=1. In this case,
current all_unreclaimable() return false even though
zone->all_unreclaimabe=1.

Is this ignorable minor issue? No. Unfortunatelly, x86 has very
small dma zone and it become zone->all_unreclamble=1 easily. and
if it become all_unreclaimable=1, it never restore all_unreclaimable=0.
Why? if all_unreclaimable=1, vmscan only try DEF_PRIORITY reclaim and
a-few-lru-pages>>DEF_PRIORITY always makes 0. that mean no page scan
at all!

Eventually, oom-killer never works on such systems. That said, we
can't use zone->pages_scanned for this purpose. This patch restore
all_unreclaimable() use zone->all_unreclaimable as old. and in addition,
to add oom_killer_disabled check to avoid reintroduce the issue of
commit d1908362.

Reported-by: Andrey Vagin <avagin@openvz.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f73b865..c3c095d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -41,6 +41,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/oom.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1988,17 +1989,12 @@ static bool zone_reclaimable(struct zone *zone)
 	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
 }
 
-/*
- * As hibernation is going on, kswapd is freezed so that it can't mark
- * the zone into all_unreclaimable. It can't handle OOM during hibernation.
- * So let's check zone's unreclaimable in direct reclaim as well as kswapd.
- */
+/* All zones in zonelist are unreclaimable? */
 static bool all_unreclaimable(struct zonelist *zonelist,
 		struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
-	bool all_unreclaimable = true;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2006,13 +2002,11 @@ static bool all_unreclaimable(struct zonelist *zonelist,
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
-		if (zone_reclaimable(zone)) {
-			all_unreclaimable = false;
-			break;
-		}
+		if (!zone->all_unreclaimable)
+			return false;
 	}
 
-	return all_unreclaimable;
+	return true;
 }
 
 /*
@@ -2108,6 +2102,14 @@ out:
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
 
+	/*
+	 * As hibernation is going on, kswapd is freezed so that it can't mark
+	 * the zone into all_unreclaimable. Thus bypassing all_unreclaimable
+	 * check.
+	 */
+	if (oom_killer_disabled)
+		return 0;
+
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
-- 
1.7.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
