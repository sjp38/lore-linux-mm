Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADC8E6B23AE
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:35 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v11-v6so733186wrn.19
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19-v6sor299891wmb.88.2018.08.22.02.32.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:34 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 3/5] mm/memory_hotplug: Simplify node_states_check_changes_online
Date: Wed, 22 Aug 2018 11:32:24 +0200
Message-Id: <20180822093226.25987-4-osalvador@techadventures.net>
In-Reply-To: <20180822093226.25987-1-osalvador@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

While looking at node_states_check_changes_online, I saw some
confusing things I am not sure how it was supposed to work.

Right after entering the function, we find this:

if (N_MEMORY == N_NORMAL_MEMORY)
	zone_last = ZONE_MOVABLE;

This, unless I am missing something really obvious, is wrong.
N_MEMORY cannot really be equal to N_NORMAL_MEMORY.
My guess is that this wanted to be something like:

if (N_NORMAL_MEMORY == N_HIGH_MEMORY)

to check if we have CONFIG_HIGHMEM.

Later on, in the CONFIG_HICHMEM block, we have:

if (N_MEMORY == N_HIGH_MEMORY)
	zone_last = ZONE_MOVABLE;

This is also wrong, and will never be evaluated to true.

The thing is that besides this, the function can be simplified a bit.

- If the zone is whithin (0..ZONE_NORMAL], we need to set the node
  for node_state[N_NORMAL_MEMORY]
- If we have CONFIG_HIGHMEM, and the zone is within (0..ZONE_NORMAL],
  we need to set the node for node_state[N_HIGH_MEMORY], as
  N_HIGH_MEMORY stands for regular or high memory.
- Finally, we set the node for node_states[N_MEMORY].
  ZONE_MOVABLE ends up there.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 44 +++++++++++++-------------------------------
 1 file changed, 13 insertions(+), 31 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 1cfd0b5a9cc7..0f2cf6941224 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -680,46 +680,28 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	struct zone *zone, struct memory_notify *arg)
 {
 	int nid = zone_to_nid(zone);
-	enum zone_type zone_last = ZONE_NORMAL;
 
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
-	 * if the memory to be online is in a zone of 0...zone_last, and
-	 * the zones of 0...zone_last don't have memory before online, we will
-	 * need to set the node to node_states[N_NORMAL_MEMORY] after
-	 * the memory is online.
+	 * node_states[N_NORMAL_MEMORY] contains nodes which have
+	 * zones from (0..ZONE_NORMAL]
+	 * We can start checking if the current zone is in that range
+	 * and if so, if the node needs to be set to node_states[N_NORMAL_MEMORY]
+	 * after memory is online.
 	 */
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
+	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
 		arg->status_change_nid_normal = nid;
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
+	 * The current zone cannot be ZONE_HIGHMEM, as zone_for_pfn_range
+	 * can only return (0..ZONE_NORMAL] or ZONE_MOVABLE.
+	 * N_HIGH_MEMORY stands for regular or high memory, so if the zone
+	 * is within the range (0..ZONE_NORMAL], we have to set the node
+	 * for N_HIGH_MEMORY as well.
 	 */
-	zone_last = ZONE_HIGHMEM;
-	if (N_MEMORY == N_HIGH_MEMORY)
-		zone_last = ZONE_MOVABLE;
-
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_HIGH_MEMORY))
+	if (zone_idx(zone) < ZONE_HIGHMEM && !node_state(nid, N_HIGH_MEMORY))
 		arg->status_change_nid_high = nid;
 	else
 		arg->status_change_nid_high = -1;
@@ -732,7 +714,7 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 #endif
 
 	/*
-	 * if the node don't have memory befor online, we will need to
+	 * if the node don't have memory before online, we will need to
 	 * set the node to node_states[N_MEMORY] after the memory
 	 * is online.
 	 */
-- 
2.13.6
