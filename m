Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72DCB6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 20:59:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so334314994pfb.7
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:59:28 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 79si2981435pfs.104.2017.01.26.17.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 17:59:27 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 75so23700001pgf.3
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:59:27 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mm/memblock: use NUMA_NO_NODE instead of MAX_NUMNODES as default node_id
Date: Fri, 27 Jan 2017 09:59:21 +0800
Message-Id: <20170127015922.36249-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

According to commit <b115423357e0> ('mm/memblock: switch to use
NUMA_NO_NODE instead of MAX_NUMNODES'), MAX_NUMNODES is not preferred as an
node_id indicator.

This patch use NUMA_NO_NODE as the default node_id for memblock.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 arch/x86/mm/numa.c | 6 +++---
 mm/memblock.c      | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 3f35b48d1d9d..4366242356c5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -506,7 +506,7 @@ static void __init numa_clear_kernel_node_hotplug(void)
 	 *   reserve specific pages for Sandy Bridge graphics. ]
 	 */
 	for_each_memblock(reserved, mb_region) {
-		if (mb_region->nid != MAX_NUMNODES)
+		if (mb_region->nid != NUMA_NO_NODE)
 			node_set(mb_region->nid, reserved_nodemask);
 	}
 
@@ -633,9 +633,9 @@ static int __init numa_init(int (*init_func)(void))
 	nodes_clear(node_online_map);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
-				  MAX_NUMNODES));
+				  NUMA_NO_NODE));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.reserved,
-				  MAX_NUMNODES));
+				  NUMA_NO_NODE));
 	/* In case that parsing SRAT failed. */
 	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
 	numa_reset_distance();
diff --git a/mm/memblock.c b/mm/memblock.c
index d0f2c9632187..7d27566cee11 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -292,7 +292,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 		type->regions[0].base = 0;
 		type->regions[0].size = 0;
 		type->regions[0].flags = 0;
-		memblock_set_region_node(&type->regions[0], MAX_NUMNODES);
+		memblock_set_region_node(&type->regions[0], NUMA_NO_NODE);
 	}
 }
 
@@ -616,7 +616,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 		     (unsigned long long)base + size - 1,
 		     0UL, (void *)_RET_IP_);
 
-	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
+	return memblock_add_range(&memblock.memory, base, size, NUMA_NO_NODE, 0);
 }
 
 /**
@@ -734,7 +734,7 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 		     (unsigned long long)base + size - 1,
 		     0UL, (void *)_RET_IP_);
 
-	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
+	return memblock_add_range(&memblock.reserved, base, size, NUMA_NO_NODE, 0);
 }
 
 /**
@@ -1684,7 +1684,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 		size = rgn->size;
 		flags = rgn->flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-		if (memblock_get_region_node(rgn) != MAX_NUMNODES)
+		if (memblock_get_region_node(rgn) != NUMA_NO_NODE)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
