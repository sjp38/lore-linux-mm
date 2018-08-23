Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 998266B2961
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 05:44:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v1-v6so4208600wmh.4
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 02:44:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u14-v6sor1488854wrp.14.2018.08.23.02.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 02:44:45 -0700 (PDT)
Date: Thu, 23 Aug 2018 11:44:43 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC PATCH 5/5] mm/memory_hotplug: Simplify
 node_states_check_changes_offline
Message-ID: <20180823094443.GA14924@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
 <20180822093226.25987-6-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822093226.25987-6-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 22, 2018 at 11:32:26AM +0200, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
> 
> This patch tries to simplify node_states_check_changes_offline
> and make the code more understandable by:
> 
> - Removing the if (N_MEMORY == N_NORMAL_MEMORY) wrong statement
> - Removing the if (N_MEMORY == N_HIGH_MEMORY) wrong statement
> - Re-structure the code a bit
> - Removing confusing comments
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

I realized I made a mistake here.
I was not counting the present pages correctly.
I will send a new version after the merge-windows gets closed.

Sorry for the noise

For the sake of clarity, the patch should have been:


---

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 006a7b817724..bca11da4e11f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1487,23 +1487,12 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	enum zone_type zt, zone_last = ZONE_NORMAL;
 
 	/*
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
-
-	/*
-	 * check whether node_states[N_NORMAL_MEMORY] will be changed.
-	 * If the memory to be offline is in a zone of 0...zone_last,
-	 * and it is the last present memory, 0...zone_last will
-	 * become empty after offline , thus we can determind we will
-	 * need to clear the node from node_states[N_NORMAL_MEMORY].
+	 * If the current zone is whithin (0..ZONE_NORMAL],
+	 * check if the amount of pages that are going to be
+	 * offlined is above or equal to the sum of the present
+	 * pages of these zones.
+	 * If that happens, we need to take this node out of
+	 * node_state[N_NORMAL_MEMORY]
 	 */
 	for (zt = 0; zt <= zone_last; zt++)
 		present_pages += pgdat->node_zones[zt].present_pages;
@@ -1514,21 +1503,15 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 
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
-		present_pages += pgdat->node_zones[zt].present_pages;
-	if (zone_idx(zone) <= zone_last && nr_pages >= present_pages)
+	zt = ZONE_HIGHMEM;
+	present_pages += pgdat->node_zones[zt].present_pages;
+	if (zone_idx(zone) <= zt && nr_pages >= present_pages)
 		arg->status_change_nid_high = zone_to_nid(zone);
 	else
 		arg->status_change_nid_high = -1;
@@ -1541,18 +1524,14 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
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
Oscar Salvador
SUSE L3
