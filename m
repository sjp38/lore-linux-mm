Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B7C396B0070
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 02:01:16 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 15/23 V2] memory_hotplug: fix missing nodemask management
Date: Thu, 2 Aug 2012 14:01:20 +0800
Message-Id: <1343887288-8866-16-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

Currently memory_hotplug only manages the node_states[N_HIGH_MEMORY],
it forgot to manage node_states[N_NORMAL_MEMORY]. fix it.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 Documentation/memory-hotplug.txt |    2 +-
 mm/memory_hotplug.c              |   23 +++++++++++++++++++++--
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 6d0c251..89f21b2 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -382,7 +382,7 @@ struct memory_notify {
 
 start_pfn is start_pfn of online/offline memory.
 nr_pages is # of pages of online/offline memory.
-status_change_nid is set node id when N_HIGH_MEMORY of nodemask is (will be)
+status_change_nid is set node id when N_MEMORY of nodemask is (will be)
 set/clear. It means a new(memoryless) node gets new memory by online and a
 node loses all memory. If this is -1, then nodemask status is not changed.
 If status_changed_nid >= 0, callback should create/discard structures for the
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 427bb29..c44b39e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -522,8 +522,18 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
+		enum zone_type zoneid = zone_idx(zone);
+
 		kswapd_run(zone_to_nid(zone));
-		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
+
+		node_set_state(nid, N_MEMORY);
+		if (zoneid <= ZONE_NORMAL && N_NORMAL_MEMORY != N_MEMORY)
+			node_set_state(nid, N_NORMAL_MEMORY);
+#ifdef CONFIG_HIGMEM
+		if (zoneid <= ZONE_HIGHMEM && N_HIGH_MEMORY != N_MEMORY)
+			node_set_state(nid, N_HIGH_MEMORY);
+#endif
+
 	}
 
 	vm_total_pages = nr_free_pagecache_pages();
@@ -966,7 +976,16 @@ repeat:
 	init_per_zone_wmark_min();
 
 	if (!node_present_pages(node)) {
-		node_clear_state(node, N_HIGH_MEMORY);
+		enum zone_type zoneid = zone_idx(zone);
+
+		node_clear_state(node, N_MEMORY);
+		if (zoneid <= ZONE_NORMAL && N_NORMAL_MEMORY != N_MEMORY)
+			node_clear_state(node, N_NORMAL_MEMORY);
+#ifdef CONFIG_HIGMEM
+		if (zoneid <= ZONE_HIGHMEM && N_HIGH_MEMORY != N_MEMORY)
+			node_clear_state(node, N_HIGH_MEMORY);
+#endif
+
 		kswapd_stop(node);
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
