Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id F21DC6B003A
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:21 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so5974107pab.12
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:21 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 06/23] mm/memblock: Add memblock early memory allocation apis
Date: Sat, 12 Oct 2013 17:58:49 -0400
Message-ID: <1381615146-20342-7-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Introduce memblock early memory allocation APIs which allow to support
LPAE extension on 32 bits archs. More over, this is the next step
to get rid of NO_BOOTMEM memblock wrapper(nobootmem.c) and directly use
memblock APIs.

The proposed interface will became active if both CONFIG_HAVE_MEMBLOCK
and CONFIG_NO_BOOTMEM are specified by arch. In case !CONFIG_NO_BOOTMEM,
the memblock() wrappers will fallback to the existing bootmem apis so
that arch's noy converted to NO_BOOTMEM continue to work as is.

The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE is
kept same.

TODO: Now the free_all_bootmem() function is used as is from NO_BOOTMEM
allocator. Can be moved to memblock file once we remove the no-bootmem.c

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 include/linux/bootmem.h |   72 ++++++++++++++++++++++++++++++
 mm/memblock.c           |  114 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 186 insertions(+)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 55d52fb..33b27bb 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -141,6 +141,78 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
+
+#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
+
+/* FIXME: use MEMBLOCK_ALLOC_* variants here */
+#define BOOTMEM_ALLOC_ACCESSIBLE	0
+#define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
+
+/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
+void *memblock_early_alloc_try_nid_nopanic(int nid, phys_addr_t size,
+		phys_addr_t align, phys_addr_t from, phys_addr_t max_addr);
+void *memblock_early_alloc_try_nid(int nid, phys_addr_t size,
+		phys_addr_t align, phys_addr_t from, phys_addr_t max_addr);
+void __memblock_free_early(phys_addr_t base, phys_addr_t size);
+void __memblock_free_late(phys_addr_t base, phys_addr_t size);
+
+#define memblock_early_alloc(x) \
+	memblock_early_alloc_try_nid(MAX_NUMNODES, x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_align(x, align) \
+	memblock_early_alloc_try_nid(MAX_NUMNODES, x, align, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_nopanic(x) \
+	memblock_early_alloc_try_nid_nopanic(MAX_NUMNODES, x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_pages(x) \
+	memblock_early_alloc_try_nid(MAX_NUMNODES, x, PAGE_SIZE, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_pages_nopanic(x) \
+	memblock_early_alloc_try_nid_nopanic(MAX_NUMNODES, x, PAGE_SIZE, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_node(nid, x) \
+	memblock_early_alloc_try_nid(nid, x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+#define memblock_early_alloc_node_nopanic(nid, x) \
+	memblock_early_alloc_try_nid_nopanic(nid, x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT, BOOTMEM_ALLOC_ACCESSIBLE)
+
+#define memblock_free_early(x, s)		__memblock_free_early(x, s)
+#define memblock_free_early_nid(nid, x, s)	__memblock_free_early(x, s)
+#define memblock_free_late(x, s)		__memblock_free_late(x, s)
+
+#else
+
+/* Fall back to all the existing bootmem APIs */
+#define memblock_early_alloc(x) \
+	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_align(x, align) \
+	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_nopanic(x) \
+	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_pages(x) \
+	__alloc_bootmem(MAX_NUMNODES, x, PAGE_SIZE)
+#define memblock_early_alloc_pages_nopanic(x) \
+	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_node(nid, x) \
+	__alloc_bootmem_node(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_node_nopanic(nid, x) \
+	__alloc_bootmem_node_nopanic(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT)
+#define memblock_early_alloc_try_nid(nid, size, align, from, max_addr) \
+		__alloc_bootmem_node_high(NODE_DATA(nid), size, align, from)
+#define memblock_early_alloc_try_nid_nopanic(nid, size, align, from, max_addr) \
+		___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align, \
+			from, max_addr)
+#define memblock_free_early(x, s)	free_bootmem(x, s)
+#define memblock_free_early_nid(nid, x, s) \
+			free_bootmem_node(NODE_DATA(nid), x, s)
+#define memblock_free_late(x, s)	free_bootmem_late(x, s)
+
+#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
+
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/memblock.c b/mm/memblock.c
index 0ac412a..c67f4bb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,6 +20,8 @@
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
+#include "internal.h"
+
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 
@@ -822,6 +824,118 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+static void * __init _memblock_early_alloc_try_nid_nopanic(int nid,
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t from, phys_addr_t max_addr)
+{
+	phys_addr_t alloc;
+	void *ptr;
+
+	if (WARN_ON_ONCE(slab_is_available())) {
+		if (nid == MAX_NUMNODES)
+			return kzalloc(size, GFP_NOWAIT);
+		else
+			return kzalloc_node(size, GFP_NOWAIT, nid);
+	}
+
+	if (WARN_ON(!align))
+		align = __alignof__(long long);
+
+	/* align @size to avoid excessive fragmentation on reserved array */
+	size = round_up(size, align);
+
+again:
+	alloc = memblock_find_in_range_node(from, max_addr, size, align, nid);
+	if (alloc)
+		goto done;
+
+	if (nid != MAX_NUMNODES) {
+		alloc =
+			memblock_find_in_range_node(from, max_addr, size,
+						    align, MAX_NUMNODES);
+		if (alloc)
+			goto done;
+	}
+
+	if (from) {
+		from = 0;
+		goto again;
+	} else {
+		goto error;
+	}
+
+done:
+	memblock_reserve(alloc, size);
+	ptr = phys_to_virt(alloc);
+	memset(ptr, 0, size);
+
+	/*
+	 * The min_count is set to 0 so that bootmem allocated blocks
+	 * are never reported as leaks.
+	 */
+	kmemleak_alloc(ptr, size, 0, 0);
+
+	return ptr;
+
+error:
+	return NULL;
+}
+
+void * __init memblock_early_alloc_try_nid_nopanic(int nid,
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t from, phys_addr_t max_addr)
+{
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+			__func__, (u64)size, (u64)align, nid, (u64)from,
+			(u64)max_addr, (void *)_RET_IP_);
+	return _memblock_early_alloc_try_nid_nopanic(nid, size,
+						align, from, max_addr);
+}
+
+void * __init memblock_early_alloc_try_nid(int nid,
+			phys_addr_t size, phys_addr_t align,
+			phys_addr_t from, phys_addr_t max_addr)
+{
+	void *ptr;
+
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+			__func__, (u64)size, (u64)align, nid, (u64)from,
+			(u64)max_addr, (void *)_RET_IP_);
+	ptr = _memblock_early_alloc_try_nid_nopanic(nid, size,
+					align, from, max_addr);
+	if (ptr)
+		return ptr;
+
+	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
+		__func__, (u64)size, (u64)align, nid, (u64)from, (u64)max_addr);
+	return NULL;
+}
+
+void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
+{
+	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+			__func__, (u64)base, (u64)base + size,
+			(void *)_RET_IP_);
+	kmemleak_free_part(__va(base), size);
+	__memblock_remove(&memblock.reserved, base, size);
+}
+
+void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
+{
+	u64 cursor, end;
+
+	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+			__func__, (u64)base, (u64)base + size,
+			(void *)_RET_IP_);
+	kmemleak_free_part(__va(base), size);
+	cursor = PFN_UP(base);
+	end = PFN_DOWN(base + size);
+
+	for (; cursor < end; cursor++) {
+		__free_pages_bootmem(pfn_to_page(cursor), 0);
+		totalram_pages++;
+	}
+}
 
 /*
  * Remaining API functions
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
