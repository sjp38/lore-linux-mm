Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id F05FC6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:39:06 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so5066010yhn.18
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:39:06 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id k1si18083468yhm.143.2013.12.11.06.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 06:39:05 -0800 (PST)
From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 2/2] mm/memblock: print phys_addr_t using %pa
Date: Wed, 11 Dec 2013 17:36:14 +0200
Message-ID: <1386776175-23779-2-git-send-email-grygorii.strashko@ti.com>
In-Reply-To: <1386776175-23779-1-git-send-email-grygorii.strashko@ti.com>
References: <1386776175-23779-1-git-send-email-grygorii.strashko@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: santosh.shilimkar@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

printk supports %pa format specifier to print phys_addr_t type values,
so use it instead of %#010llx/0x%llx/0x%08lx and drop corresponding
type casting.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---

It's additional change on top of the memblock series 
https://lkml.org/lkml/2013/12/9/715

 mm/memblock.c |   85 +++++++++++++++++++++++++++------------------------------
 1 file changed, 40 insertions(+), 45 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 974f0d3..71b11d9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -308,7 +308,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 {
 	struct memblock_region *new_array, *old_array;
 	phys_addr_t old_alloc_size, new_alloc_size;
-	phys_addr_t old_size, new_size, addr;
+	phys_addr_t old_size, new_size, addr, end_addr;
 	int use_slab = slab_is_available();
 	int *in_slab;
 
@@ -369,9 +369,9 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 		return -1;
 	}
 
-	memblock_dbg("memblock: %s is doubled to %ld at [%#010llx-%#010llx]",
-			memblock_type_name(type), type->max * 2, (u64)addr,
-			(u64)addr + new_size - 1);
+	end_addr = addr + new_size - 1;
+	memblock_dbg("memblock: %s is doubled to %ld at [%pa-%pa]",
+		     memblock_type_name(type), type->max * 2, &addr, &end_addr);
 
 	/*
 	 * Found space, we now need to move the array over before we add the
@@ -657,10 +657,10 @@ int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 
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
 
 	return __memblock_remove(&memblock.reserved, base, size);
 }
@@ -668,11 +668,10 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
+	phys_addr_t end = base + size - 1;
 
-	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
-		     (unsigned long long)base,
-		     (unsigned long long)base + size - 1,
-		     (void *)_RET_IP_);
+	memblock_dbg("memblock_reserve: [%pa-%pa] %pF\n",
+		     &base, &end, (void *)_RET_IP_);
 
 	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
 }
@@ -926,8 +925,8 @@ phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys
 	alloc = __memblock_alloc_base(size, align, max_addr);
 
 	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
+		panic("ERROR: Failed to allocate %pa bytes below %pa.\n",
+		      &size, &max_addr);
 
 	return alloc;
 }
@@ -1060,9 +1059,9 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
 {
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
+	memblock_dbg("%s: %pa bytes align=%pa nid=%d\n\tfrom=%pa max_addr=%pa %pF\n",
+		     __func__, &size, &align, nid, &min_addr,
+		     &max_addr, (void *)_RET_IP_);
 	return memblock_virt_alloc_internal(size, align, min_addr,
 					     max_addr, nid);
 }
@@ -1092,17 +1091,16 @@ void * __init memblock_virt_alloc_try_nid(
 {
 	void *ptr;
 
-	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
-		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-		     (u64)max_addr, (void *)_RET_IP_);
+	memblock_dbg("%s: %pa bytes align=%pa nid=%d\n\tfrom=%pa max_addr=%pa %pF\n",
+		     __func__, &size, &align, nid, &min_addr,
+		     &max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
 	if (ptr)
 		return ptr;
 
-	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
-	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
-	      (u64)max_addr);
+	panic("%s: Failed to allocate %pa bytes align=%pa nid=%d from=%pa max_addr=%pa\n",
+	      __func__, &size, &align, nid, &min_addr, &max_addr);
 	return NULL;
 }
 
@@ -1116,9 +1114,10 @@ void * __init memblock_virt_alloc_try_nid(
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 {
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-		     __func__, (u64)base, (u64)base + size - 1,
-		     (void *)_RET_IP_);
+	phys_addr_t end = base + size - 1;
+
+	memblock_dbg("%s: [%pa-%pa] %pF\n",
+		     __func__, &base, &end, (void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
 	__memblock_remove(&memblock.reserved, base, size);
 }
@@ -1134,11 +1133,11 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
  */
 void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
-	u64 cursor, end;
+	phys_addr_t cursor, end;
 
-	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
-		     __func__, (u64)base, (u64)base + size - 1,
-		     (void *)_RET_IP_);
+	end = base + size - 1;
+	memblock_dbg("%s: [%pa-%pa] %pF\n",
+		     __func__, &base, &end, (void *)_RET_IP_);
 	kmemleak_free_part(__va(base), size);
 	cursor = PFN_UP(base);
 	end = PFN_DOWN(base + size);
@@ -1328,7 +1327,7 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 
 static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
 {
-	unsigned long long base, size;
+	phys_addr_t base, size, end;
 	int i;
 
 	pr_info(" %s.cnt  = 0x%lx\n", name, type->cnt);
@@ -1339,22 +1338,23 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 
 		base = rgn->base;
 		size = rgn->size;
+		end = base + size - 1;
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 		if (memblock_get_region_node(rgn) != MAX_NUMNODES)
 			snprintf(nid_buf, sizeof(nid_buf), " on node %d",
 				 memblock_get_region_node(rgn));
 #endif
-		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s\n",
-			name, i, base, base + size - 1, size, nid_buf);
+		pr_info(" %s[%#x]\t[%pa-%pa], %pa bytes%s\n",
+			name, i, &base, &end, &size, nid_buf);
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
@@ -1382,17 +1382,12 @@ static int memblock_debug_show(struct seq_file *m, void *private)
 	int i;
 
 	for (i = 0; i < type->cnt; i++) {
+		phys_addr_t end;
+
 		reg = &type->regions[i];
+		end = reg->base + reg->size - 1;
 		seq_printf(m, "%4d: ", i);
-		if (sizeof(phys_addr_t) == 4)
-			seq_printf(m, "0x%08lx..0x%08lx\n",
-				   (unsigned long)reg->base,
-				   (unsigned long)(reg->base + reg->size - 1));
-		else
-			seq_printf(m, "0x%016llx..0x%016llx\n",
-				   (unsigned long long)reg->base,
-				   (unsigned long long)(reg->base + reg->size - 1));
-
+		seq_printf(m, "%pa..%pa\n", &reg->base, &end);
 	}
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
