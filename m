Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 092EB8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:08:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g3-v6so2826680wrr.11
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:08:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g11-v6sor9504931wmg.19.2018.09.19.03.08.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 03:08:41 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 5/5] mm/memory_hotplug: Clean up node_states_check_changes_offline
Date: Wed, 19 Sep 2018 12:08:19 +0200
Message-Id: <20180919100819.25518-6-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-1-osalvador@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch, as the previous one, gets rid of the wrong if statements.
While at it, I realized that the comments are sometimes very confusing,
to say the least, and wrong.
For example:

---
zone_last = ZONE_MOVABLE;

/*
 * check whether node_states[N_HIGH_MEMORY] will be changed
 * If we try to offline the last present @nr_pages from the node,
 * we can determind we will need to clear the node from
 * node_states[N_HIGH_MEMORY].
 */

for (; zt <= zone_last; zt++)
	present_pages += pgdat->node_zones[zt].present_pages;
if (nr_pages >= present_pages)
	arg->status_change_nid = zone_to_nid(zone);
else
	arg->status_change_nid = -1;
---

In case the node gets empry, it must be removed from N_MEMORY.
We already check N_HIGH_MEMORY a bit above within the CONFIG_HIGHMEM
ifdef code.
Not to say that status_change_nid is for N_MEMORY, and not for
N_HIGH_MEMORY.

So I re-wrote some of the comments to what I think is better.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 71 +++++++++++++++++++++--------------------------------
 1 file changed, 28 insertions(+), 43 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ab3c1de18c5d..15ecf3d7a554 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1485,51 +1485,36 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	unsigned long present_pages = 0;
-	enum zone_type zt, zone_last = ZONE_NORMAL;
+	enum zone_type zt;
 
 	/*
-	 * If we have HIGHMEM or movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_NORMAL,
-	 * set zone_last to ZONE_NORMAL.
-	 *
-	 * If we don't have HIGHMEM nor movable node,
-	 * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
-	 * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 * Check whether node_states[N_NORMAL_MEMORY] will be changed.
+	 * If the memory to be offline is within the range
+	 * [0..ZONE_NORMAL], and it is the last present memory there,
+	 * the zones in that range will become empty after the offlining,
+	 * thus we can determine that we need to clear the node from
+	 * node_states[N_NORMAL_MEMORY].
 	 */
-	if (N_MEMORY == N_NORMAL_MEMORY)
-		zone_last = ZONE_MOVABLE;
-
-	/*
-	 * check whether node_states[N_NORMAL_MEMORY] will be changed.
-	 * If the memory to be offline is in a zone of 0...zone_last,
-	 * and it is the last present memory, 0...zone_last will
-	 * become empty after offline , thus we can determind we will
-	 * need to clear the node from node_states[N_NORMAL_MEMORY].
-	 */
-	for (zt = 0; zt <= zone_last; zt++)
+	for (zt = 0; zt <= ZONE_NORMAL; zt++)
 		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+	if (zone_idx(zone) <= ZONE_NORMAL && nr_pages >= present_pages)
 		arg->status_change_nid_normal = zone_to_nid(zone);
 	else
 		arg->status_change_nid_normal = -1;
 
 #ifdef CONFIG_HIGHMEM
 	/*
-	 * If we have movable node, node_states[N_HIGH_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_HIGHMEM,
-	 * set zone_last to ZONE_HIGHMEM.
-	 *
-	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_MOVABLE,
-	 * set zone_last to ZONE_MOVABLE.
+	 * node_states[N_HIGH_MEMORY] contains nodes which
+	 * have normal memory or high memory.
+	 * Here we add the present_pages belonging to ZONE_HIGHMEM.
+	 * If the zone is within the range of [0..ZONE_HIGHMEM), and
+	 * we determine that the zones in that range become empty,
+	 * we need to clear the node for N_HIGH_MEMORY.
 	 */
-	zone_last = ZONE_HIGHMEM;
-	if (N_MEMORY == N_HIGH_MEMORY)
-		zone_last = ZONE_MOVABLE;
+	zt = ZONE_HIGHMEM;
+	present_pages += pgdat->node_zones[zt].present_pages;
 
-	for (; zt <= zone_last; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+	if (zone_idx(zone) <= zt && nr_pages >= present_pages)
 		arg->status_change_nid_high = zone_to_nid(zone);
 	else
 		arg->status_change_nid_high = -1;
@@ -1542,18 +1527,18 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 #endif
 
 	/*
-	 * node_states[N_HIGH_MEMORY] contains nodes which have 0...ZONE_MOVABLE
+	 * We have accounted the pages from [0..ZONE_NORMAL), and
+	 * in case of CONFIG_HIGHMEM the pages from ZONE_HIGHMEM
+	 * as well.
+	 * Here we count the possible pages from ZONE_MOVABLE.
+	 * If after having accounted all the pages, we see that the nr_pages
+	 * to be offlined is over or equal to the accounted pages,
+	 * we know that the node will become empty, and so, we can clear
+	 * it for N_MEMORY as well.
 	 */
-	zone_last = ZONE_MOVABLE;
+	zt = ZONE_MOVABLE;
+	present_pages += pgdat->node_zones[zt].present_pages;
 
-	/*
-	 * check whether node_states[N_HIGH_MEMORY] will be changed
-	 * If we try to offline the last present @nr_pages from the node,
-	 * we can determind we will need to clear the node from
-	 * node_states[N_HIGH_MEMORY].
-	 */
-	for (; zt <= zone_last; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
 	if (nr_pages >= present_pages)
 		arg->status_change_nid = zone_to_nid(zone);
 	else
-- 
2.13.6
