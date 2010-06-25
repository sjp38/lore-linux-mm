Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 44D9F6B01B2
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 05:13:28 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5P9DPYr025004
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 25 Jun 2010 18:13:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 274FB45DE51
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 18:13:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 07BD045DE4F
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 18:13:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E2C621DB803C
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 18:13:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A03E71DB8038
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 18:13:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: recalculate lru_pages on each priority
Message-Id: <20100625181221.805A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 25 Jun 2010 18:13:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

shrink_zones() need relatively long time. and lru_pages can be
changed dramatically while shrink_zones().
then, lru_pages need recalculate on each priority.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0c961f1..0ebfe12 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1785,7 +1785,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	bool all_unreclaimable;
 	unsigned long total_scanned = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
@@ -1796,18 +1795,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
-	/*
-	 * mem_cgroup will not do shrink_slab.
-	 */
-	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-				continue;
-
-			lru_pages += zone_reclaimable_pages(zone);
-		}
-	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
@@ -1819,6 +1806,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * over limit cgroups
 		 */
 		if (scanning_global_lru(sc)) {
+			unsigned long lru_pages = 0;
+			for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+					continue;
+
+				lru_pages += zone_reclaimable_pages(zone);
+			}
+
 			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
 			if (reclaim_state) {
 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
