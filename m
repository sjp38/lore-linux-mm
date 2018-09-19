Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 584538E0007
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:08:42 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i11-v6so5195676wrr.10
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:08:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42-v6sor15010060wrb.38.2018.09.19.03.08.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 03:08:41 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 4/5] mm/memory_hotplug: Simplify node_states_check_changes_online
Date: Wed, 19 Sep 2018 12:08:18 +0200
Message-Id: <20180919100819.25518-5-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-1-osalvador@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
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
---
 mm/memory_hotplug.c | 71 +++++++++++++++++------------------------------------
 1 file changed, 23 insertions(+), 48 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 131c08106d54..ab3c1de18c5d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -687,61 +687,36 @@ static void node_states_check_changes_online(unsigned long nr_pages,
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
+	 * zone_for_pfn_range() can only return a zone within
+	 * (0..ZONE_NORMAL] or ZONE_MOVABLE.
+	 * If the zone is within the range (0..ZONE_NORMAL],
+	 * we need to check if:
+	 * 1) We need to set the node for N_NORMAL_MEMORY
+	 * 2) On CONFIG_HIGHMEM systems, we need to also set
+	 *    the node for N_HIGH_MEMORY.
+	 * 3) On !CONFIG_HIGHMEM, we can disregard N_HIGH_MEMORY,
+	 *    as N_HIGH_MEMORY falls back to N_NORMAL_MEMORY.
 	 */
-	if (N_MEMORY == N_NORMAL_MEMORY)
-		zone_last = ZONE_MOVABLE;
 
-	/*
-	 * if the memory to be online is in a zone of 0...zone_last, and
-	 * the zones of 0...zone_last don't have memory before online, we will
-	 * need to set the node to node_states[N_NORMAL_MEMORY] after
-	 * the memory is online.
-	 */
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_NORMAL_MEMORY))
-		arg->status_change_nid_normal = nid;
-	else
-		arg->status_change_nid_normal = -1;
-
-#ifdef CONFIG_HIGHMEM
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
+	if (zone_idx(zone) <= ZONE_NORMAL) {
+		if (!node_state(nid, N_NORMAL_MEMORY))
+			arg->status_change_nid_normal = nid;
+		else
+			arg->status_change_nid_normal = -1;
 
-	if (zone_idx(zone) <= zone_last && !node_state(nid, N_HIGH_MEMORY))
-		arg->status_change_nid_high = nid;
-	else
-		arg->status_change_nid_high = -1;
-#else
-	/*
-	 * When !CONFIG_HIGHMEM, N_HIGH_MEMORY equals N_NORMAL_MEMORY
-	 * so setting the node for N_NORMAL_MEMORY is enough.
-	 */
-	arg->status_change_nid_high = -1;
-#endif
+		if (IS_ENABLED(CONFIG_HIGHMEM)) {
+			if (!node_state(nid, N_HIGH_MEMORY))
+				arg->status_change_nid_high = nid;
+		} else
+			arg->status_change_nid_high = -1;
+	}
 
 	/*
-	 * if the node don't have memory befor online, we will need to
-	 * set the node to node_states[N_MEMORY] after the memory
-	 * is online.
+	 * if the node doesn't have memory before onlining it, we will need
+	 * to set the node to node_states[N_MEMORY] after the memory
+	 * gets onlined.
 	 */
 	if (!node_state(nid, N_MEMORY))
 		arg->status_change_nid = nid;
-- 
2.13.6
