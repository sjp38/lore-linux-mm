Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3EB78E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:08:40 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b186-v6so3047872wmh.8
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:08:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l23-v6sor9496244wmc.6.2018.09.19.03.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 03:08:39 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH 1/5] mm/memory_hotplug: Spare unnecessary calls to node_set_state
Date: Wed, 19 Sep 2018 12:08:15 +0200
Message-Id: <20180919100819.25518-2-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-1-osalvador@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, david@redhat.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, yasu.isimatu@gmail.com, malat@debian.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

In node_states_check_changes_online, we check if the node will
have to be set for any of the N_*_MEMORY states after the pages
have been onlined.

Later on, we perform the activation in node_states_set_node.
Currently, in node_states_set_node we set the node to N_MEMORY
unconditionally.
This means that we call node_set_state for N_MEMORY every time
pages go online, but we only need to do it if the node has not yet been
set for N_MEMORY.

Fix this by checking status_change_nid.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b703e9d..63facfc57224 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -753,7 +753,8 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
-	node_set_state(node, N_MEMORY);
+	if (arg->status_change_nid >= 0)
+		node_set_state(node, N_MEMORY);
 }
 
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
-- 
2.13.6
