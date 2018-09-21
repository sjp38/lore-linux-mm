Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 516378E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 09:26:45 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v1-v6so2457679wmh.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:26:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8-v6sor10922075wrs.28.2018.09.21.06.26.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 06:26:43 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v2 3/4] mm/memory_hotplug: Simplify node_states_check_changes_online
Date: Fri, 21 Sep 2018 15:26:33 +0200
Message-Id: <20180921132634.10103-4-osalvador@techadventures.net>
In-Reply-To: <20180921132634.10103-1-osalvador@techadventures.net>
References: <20180921132634.10103-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

While looking at node_states_check_changes_online, I stumbled
upon some confusing things.

Right after entering the function, we find this:

if (N_MEMORY == N_NORMAL_MEMORY)
        zone_last = ZONE_MOVABLE;

This is wrong.
N_MEMORY cannot really be equal to N_NORMAL_MEMORY.
My guess is that this wanted to be something like:

if (N_NORMAL_MEMORY == N_HIGH_MEMORY)

to check if we have CONFIG_HIGHMEM.

Later on, in the CONFIG_HIGHMEM block, we have:

if (N_MEMORY == N_HIGH_MEMORY)
        zone_last = ZONE_MOVABLE;

Again, this is wrong, and will never be evaluated to true.

Besides removing these wrong if statements, I simplified
the function a bit.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Suggested-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
---
 mm/memory_hotplug.c | 57 +++++++----------------------------------------------
 1 file changed, 7 insertions(+), 50 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 561c44761f95..eadd149eb7bc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -687,62 +687,19 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 	struct zone *zone, struct memory_notify *arg)
 {
 	int nid = zone_to_nid(zone);
-	enum zone_type zone_last = ZONE_NORMAL;
 
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
 
-	/*
-	 * if the memory to be online is in a zone of 0...zone_last, and
-	 * the zones of 0...zone_last don't have memory before online, we will
-	 * need to set the node to node_states[N_NORMAL_MEMORY] after
-	 * the memory is online.
-	 */
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
+	if (!node_state(nid, N_MEMORY))
+		arg->status_change_nid = nid;
+	if (zone_idx(zone) <= ZONE_NORMAL && !node_state(nid, N_NORMAL_MEMORY))
 		arg->status_change_nid_normal = nid;
-	else
-		arg->status_change_nid_normal = -1;
-
 #ifdef CONFIG_HIGHMEM
-	/*
-	 * If we have movable node, node_states[N_HIGH_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_HIGHMEM,
-	 * set zone_last to ZONE_HIGHMEM.
-	 *
-	 * If we don't have movable node, node_states[N_NORMAL_MEMORY]
-	 * contains nodes which have zones of 0...ZONE_MOVABLE,
-	 * set zone_last to ZONE_MOVABLE.
-	 */
-	zone_last = ZONE_HIGHMEM;
-	if (N_MEMORY == N_HIGH_MEMORY)
-		zone_last = ZONE_MOVABLE;
-
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_HIGH_MEMORY))
+	if (zone_idx(zone) <= N_HIGH_MEMORY && !node_state(nid, N_HIGH_MEMORY))
 		arg->status_change_nid_high = nid;
-	else
-		arg->status_change_nid_high = -1;
-#else
-	arg->status_change_nid_high = arg->status_change_nid_normal;
 #endif
-
-	/*
-	 * if the node don't have memory befor online, we will need to
-	 * set the node to node_states[N_MEMORY] after the memory
-	 * is online.
-	 */
-	if (!node_state(nid, N_MEMORY))
-		arg->status_change_nid = nid;
-	else
-		arg->status_change_nid = -1;
 }
 
 static void node_states_set_node(int node, struct memory_notify *arg)
-- 
2.13.6
