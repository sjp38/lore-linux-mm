Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9550B6B23AC
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:32:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v24-v6so1324387wmh.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:32:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7-v6sor394537wrn.87.2018.08.22.02.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 02:32:33 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [RFC PATCH 1/5] mm/memory_hotplug: Spare unnecessary calls to node_set_state
Date: Wed, 22 Aug 2018 11:32:22 +0200
Message-Id: <20180822093226.25987-2-osalvador@techadventures.net>
In-Reply-To: <20180822093226.25987-1-osalvador@techadventures.net>
References: <20180822093226.25987-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, malat@debian.org, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

In node_states_check_changes_online, we check if the node will
have to be set for any of the N_*_MEMORY states after the pages
have been onlined.

Later on, we perform the activation in node_states_set_node.
Currently, in node_states_set_node we set the node to N_MEMORY
unconditionally.
This means that we will call node_set_state for N_MEMORY every time
pages go online, but we only need to do it if the node has not yet been
set for N_MEMORY.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 60b67f09956e..4a89915e1467 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -746,7 +746,8 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
-	node_set_state(node, N_MEMORY);
+	if (arg->status_change_nid >= 0)
+		node_set_state(node, N_MEMORY);
 }
 
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
-- 
2.13.6
