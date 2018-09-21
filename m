Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 492B08E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:26:46 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id z11-v6so2454891wma.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:26:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z10-v6sor4152858wmb.1.2018.09.21.06.26.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 06:26:44 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v2 4/4] mm/memory_hotplug: Clean up node_states_check_changes_offline
Date: Fri, 21 Sep 2018 15:26:34 +0200
Message-Id: <20180921132634.10103-5-osalvador@techadventures.net>
In-Reply-To: <20180921132634.10103-1-osalvador@techadventures.net>
References: <20180921132634.10103-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch, as the previous one, gets rid of the wrong if statements.
While at it, I realized that the comments are sometimes very confusing,
to say the least, and wrong.
For example:

___
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
___

In case the node gets empry, it must be removed from N_MEMORY.
We already check N_HIGH_MEMORY a bit above within the CONFIG_HIGHMEM
ifdef code.
Not to say that status_change_nid is for N_MEMORY, and not for
N_HIGH_MEMORY.

So I re-wrote some of the comments to what I think is better.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
---
 mm/memory_hotplug.c | 80 +++++++++++++++++++----------------------------------
 1 file changed, 29 insertions(+), 51 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index eadd149eb7bc..f19b63f024c9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1463,75 +1463,53 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	unsigned long present_pages = 0;
-	enum zone_type zt, zone_last = ZONE_NORMAL;
+	enum zone_type zt;
 
-	/*
-	 * If we have HIGHMEM or movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_NORMAL,
-	 * set zone_last to ZONE_NORMAL.
-	 *
-	 * If we don't have HIGHMEM nor movable node,
-	 * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
-	 * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
-	 */
-	if (N_MEMORY == N_NORMAL_MEMORY)
-		zone_last = ZONE_MOVABLE;
+	arg->status_change_nid = -1;	
+	arg->status_change_nid_normal = -1;
+	arg->status_change_nid_high = -1;
 
 	/*
-	 * check whether node_states[N_NORMAL_MEMORY] will be changed.
-	 * If the memory to be offline is in a zone of 0...zone_last,
-	 * and it is the last present memory, 0...zone_last will
-	 * become empty after offline , thus we can determind we will
-	 * need to clear the node from node_states[N_NORMAL_MEMORY].
+	 * Check whether node_states[N_NORMAL_MEMORY] will be changed.
+	 * If the memory to be offline is within the range
+	 * [0..ZONE_NORMAL], and it is the last present memory there,
+	 * the zones in that range will become empty after the offlining,
+	 * thus we can determine that we need to clear the node from
+	 * node_states[N_NORMAL_MEMORY].
 	 */
-	for (zt = 0; zt <= zone_last; zt++)
+	for (zt = 0; zt <= ZONE_NORMAL; zt++)
 		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+	if (zone_idx(zone) <= ZONE_NORMAL && nr_pages >= present_pages)
 		arg->status_change_nid_normal = zone_to_nid(zone);
-	else
-		arg->status_change_nid_normal = -1;
 
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
-
-	for (; zt <= zone_last; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+	present_pages += pgdat->node_zones[ZONE_HIGHMEM].present_pages;
+	if (zone_idx(zone) <= ZONE_HIGHMEM && nr_pages >= present_pages)
 		arg->status_change_nid_high = zone_to_nid(zone);
-	else
-		arg->status_change_nid_high = -1;
-#else
-	arg->status_change_nid_high = arg->status_change_nid_normal;
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
+	present_pages += pgdat->node_zones[ZONE_MOVABLE].present_pages;
 
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
-	else
-		arg->status_change_nid = -1;
 }
 
 static void node_states_clear_node(int node, struct memory_notify *arg)
-- 
2.13.6
