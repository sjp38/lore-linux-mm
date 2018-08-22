Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB5D46B23B0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:36 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v11-v6so733243wrn.19
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b190-v6sor341566wma.69.2018.08.22.02.32.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:35 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 5/5] mm/memory_hotplug: Simplify node_states_check_changes_offline
Date: Wed, 22 Aug 2018 11:32:26 +0200
Message-Id: <20180822093226.25987-6-osalvador@techadventures.net>
In-Reply-To: <20180822093226.25987-1-osalvador@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patch tries to simplify node_states_check_changes_offline
and make the code more understandable by:

- Removing the if (N_MEMORY == N_NORMAL_MEMORY) wrong statement
- Removing the if (N_MEMORY == N_HIGH_MEMORY) wrong statement
- Re-structure the code a bit
- Removing confusing comments

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 81 ++++++++++++++++++++++-------------------------------
 1 file changed, 33 insertions(+), 48 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 006a7b817724..b45bc681e6db 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1487,51 +1487,40 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	enum zone_type zt, zone_last = ZONE_NORMAL;
 
 	/*
-	 * If we have HIGHMEM or movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_NORMAL,
-	 * set zone_last to ZONE_NORMAL.
-	 *
-	 * If we don't have HIGHMEM nor movable node,
-	 * node_states[N_NORMAL_MEMORY] contains nodes which have zones of
-	 * 0...ZONE_MOVABLE, set zone_last to ZONE_MOVABLE.
+	 * If the current zone is whithin (0..ZONE_NORMAL],
+	 * check if the amount of pages that are going to be
+	 * offlined is above or equal to the sum of the present
+	 * pages of these zones.
+	 * If that happens, we need to take this node out of
+	 * node_state[N_NORMAL_MEMORY]
 	 */
-	if (N_MEMORY == N_NORMAL_MEMORY)
-		zone_last = ZONE_MOVABLE;
+	if (zone_idx(zone) <= zone_last) {
+		for (zt = 0; zt <= zone_last; zt++)
+			present_pages += pgdat->node_zones[zt].present_pages;
 
-	/*
-	 * check whether node_states[N_NORMAL_MEMORY] will be changed.
-	 * If the memory to be offline is in a zone of 0...zone_last,
-	 * and it is the last present memory, 0...zone_last will
-	 * become empty after offline , thus we can determind we will
-	 * need to clear the node from node_states[N_NORMAL_MEMORY].
-	 */
-	for (zt = 0; zt <= zone_last; zt++)
-		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
-		arg->status_change_nid_normal = zone_to_nid(zone);
-	else
-		arg->status_change_nid_normal = -1;
+		if (nr_pages >= present_pages)
+			arg->status_change_nid_normal = zone_to_nid(zone);
+		else
+			arg->status_change_nid_normal = -1;
+	}
 
 #ifdef CONFIG_HIGHMEM
 	/*
-	 * If we have movable node, node_states[N_HIGH_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_HIGHMEM,
-	 * set zone_last to ZONE_HIGHMEM.
-	 *
-	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_MOVABLE,
-	 * set zone_last to ZONE_MOVABLE.
+	 * If the current zone is whithin (0..ZONE_HIGHMEM], check if
+	 * the amount of pages that are going to be offlined is above
+	 * or equal to the sum of the present pages of these zones.
+	 * If that happens, we need to take this node out of
+	 * node_state[N_HIGH_MEMORY]
 	 */
-	zone_last = ZONE_HIGHMEM;
-	if (N_MEMORY == N_HIGH_MEMORY)
-		zone_last = ZONE_MOVABLE;
-
-	for (; zt <= zone_last; zt++)
+	if (zone_idx(zone) <= ZONE_HIGHMEM) {
+		zt = ZONE_HIGHMEM;
 		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
-		arg->status_change_nid_high = zone_to_nid(zone);
-	else
-		arg->status_change_nid_high = -1;
+
+		if (nr_pages >= present_pages)
+			arg->status_change_nid_high = zone_to_nid(zone);
+		else
+			arg->status_change_nid_high = -1;
+	}
 #else
 	/*
 	 * When !CONFIG_HIGHMEM, N_HIGH_MEMORY equals N_NORMAL_MEMORY
@@ -1541,18 +1530,14 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 #endif
 
 	/*
-	 * node_states[N_HIGH_MEMORY] contains nodes which have 0...ZONE_MOVABLE
+	 * Count pages from ZONE_MOVABLE as well.
+	 * If the amount of pages that are going to be offlined is above
+	 * or equal the sum of the present pages of all zones, we need
+	 * to remove this node from node_state[N_MEMORY]
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
