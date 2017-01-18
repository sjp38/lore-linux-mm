Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB5EB6B0266
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:16:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z128so5724860pfb.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 22:16:23 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id x3si26808748pfi.274.2017.01.17.22.16.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 22:16:23 -0800 (PST)
From: Miles Chen <miles.chen@mediatek.com>
Subject: [PATCH] mm/memblock.c: remove unnecessary log and clean up
Date: Wed, 18 Jan 2017 14:16:05 +0800
Message-ID: <1484720165-25403-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

There is no variable named flags in memblock_add() and memblock_reserve()
so remove it from the log messages.
This patch also cleans up the type casting for phys_addr_t by using
%pa to print them.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/memblock.c | 54 +++++++++++++++++++++++++-----------------------------
 1 file changed, 25 insertions(+), 29 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..8683f02 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -611,10 +611,10 @@ int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
-		     (unsigned long long)base,
-		     (unsigned long long)base + size - 1,
-		     0UL, (void *)_RET_IP_);
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("memblock_add: [%pa-%pa] %pF\n",
+		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.memory, base, size, MAX_NUMNODES, 0);
 }
@@ -718,10 +718,10 @@ int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 
 int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
-		     (unsigned long long)base,
-		     (unsigned long long)base + size - 1,
-		     (void *)_RET_IP_);
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("   memblock_free: [%pa-%pa] %pF\n",
+		     &base, &end, (void *)_RET_IP_);
 
 	kmemleak_free_part_phys(base, size);
 	return memblock_remove_range(&memblock.reserved, base, size);
@@ -729,10 +729,10 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] flags %#02lx %pF\n",
-		     (unsigned long long)base,
-		     (unsigned long long)base + size - 1,
-		     0UL, (void *)_RET_IP_);
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("memblock_reserve: [%pa-%pa] %pF\n",
+		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
 }
@@ -1202,8 +1202,8 @@ phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys
 	alloc = __memblock_alloc_base(size, align, max_addr);
 
 	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
+		panic("ERROR: Failed to allocate %pa bytes below %pa.\n",
+		      &size, &max_addr);
 
 	return alloc;
 }
@@ -1673,7 +1673,7 @@ phys_addr_t __init_memblock memblock_get_current_limit(void)
 
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
 {
-	unsigned long long base, size;
+	phys_addr_t base, end, size;
 	unsigned long flags;
 	int idx;
 	struct memblock_region *rgn;
@@ -1685,23 +1685,24 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 
 		base = rgn->base;
 		size = rgn->size;
+		end = base + size - 1;
 		flags = rgn->flags;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		if (memblock_get_region_node(rgn) != MAX_NUMNODES)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
-		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s flags: %#lx\n",
-			name, idx, base, base + size - 1, size, nid_buf, flags);
+		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s flags: %#lx\n",
+			name, idx, &base, &end, &size, nid_buf, flags);
 	}
 }
 
 void __init_memblock __memblock_dump_all(void)
 {
 	pr_info("MEMBLOCK configuration:\n");
-	pr_info(" memory size = %#llx reserved size = %#llx\n",
-		(unsigned long long)memblock.memory.total_size,
-		(unsigned long long)memblock.reserved.total_size);
+	pr_info(" memory size = %pa reserved size = %pa\n",
+		&memblock.memory.total_size,
+		&memblock.reserved.total_size);
 
 	memblock_dump(&memblock.memory, "memory");
 	memblock_dump(&memblock.reserved, "reserved");
@@ -1727,19 +1728,14 @@ static int memblock_debug_show(struct seq_file *m, void *private)
 	struct memblock_type *type = m->private;
 	struct memblock_region *reg;
 	int i;
+	phys_addr_t end;
 
 	for (i = 0; i < type->cnt; i++) {
 		reg = &type->regions[i];
-		seq_printf(m, "%4d: ", i);
-		if (sizeof(phys_addr_t) == 4)
-			seq_printf(m, "0x%08lx..0x%08lx\n",
-				   (unsigned long)reg->base,
-				   (unsigned long)(reg->base + reg->size - 1));
-		else
-			seq_printf(m, "0x%016llx..0x%016llx\n",
-				   (unsigned long long)reg->base,
-				   (unsigned long long)(reg->base + reg->size - 1));
+		end = reg->base + reg->size - 1;
 
+		seq_printf(m, "%4d: ", i);
+		seq_printf(m, "%pa..%pa\n", &reg->base, &end);
 	}
 	return 0;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
