Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 50DD76B007B
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:28:55 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id n7so196629qcx.19
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:28:55 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id kb1si45165490qeb.113.2013.12.02.18.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:28:54 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Date: Mon, 2 Dec 2013 21:27:23 -0500
Message-ID: <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Introduce memblock memory allocation APIs which allow to support
PAE or LPAE extension on 32 bits archs where the physical memory start
address can be beyond 4GB. In such cases, existing bootmem APIs which
operate on 32 bit addresses won't work and needs memblock layer which
operates on 64 bit addresses.

So we add equivalent APIs so that we can replace usage of bootmem
with memblock interfaces. Architectures already converted to NO_BOOTMEM
use these new interfaces and other which still uses bootmem, these new
APIs just fallback to exiting bootmem APIs. So no functional change as
such.

In long run, once all the achitectures moves to NO_BOOTMEM, we can get rid of
bootmem layer completely. This is one step to remove the core code dependency
with bootmem and also gives path for architectures to move away from bootmem.

The proposed interface will became active if both CONFIG_HAVE_MEMBLOCK
and CONFIG_NO_BOOTMEM are specified by arch. In case !CONFIG_NO_BOOTMEM,
the memblock() wrappers will fallback to the existing bootmem apis so
that arch's not converted to NO_BOOTMEM continue to work as is.

The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE is
kept same.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 include/linux/bootmem.h |   88 +++++++++++++++++++++
 mm/memblock.c           |  195 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 283 insertions(+)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 55d52fb..d333ac4 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -141,6 +141,94 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
+
+#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
+
+/* FIXME: use MEMBLOCK_ALLOC_* variants here */
+#define BOOTMEM_ALLOC_ACCESSIBLE	0
+#define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
+
+/*
+ * FIXME: use NUMA_NO_NODE instead of MAX_NUMNODES when bootmem/nobootmem code
+ * will be removed.
+ * It can't be done now, because when MEMBLOCK or NO_BOOTMEM are not enabled
+ * all calls of the new API will be redirected to bottmem/nobootmem where
+ * MAX_NUMNODES is widely used.
+ * Also, memblock core APIs __next_free_mem_range_rev() and
+ * __next_free_mem_range() would need to be updated, and as result we will
+ * need to re-check/update all direct calls of memblock_alloc_xxx()
+ * APIs (including nobootmem).
+ */
+
+/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
+void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
+		phys_addr_t align, phys_addr_t from,
+		phys_addr_t max_addr, int nid);
+void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+		phys_addr_t from, phys_addr_t max_addr, int nid);
+void __memblock_free_early(phys_addr_t base, phys_addr_t size);
+void __memblock_free_late(phys_addr_t base, phys_addr_t size);
+
+#define memblock_virt_alloc(x) \
+	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
+				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+#define memblock_virt_alloc_align(x, align) \
+	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
+				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
+#define memblock_virt_alloc_nopanic(x) \
+	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
+					     BOOTMEM_LOW_LIMIT, \
+					     BOOTMEM_ALLOC_ACCESSIBLE, \
+					     MAX_NUMNODES)
+#define memblock_virt_alloc_align_nopanic(x, align) \
+	memblock_virt_alloc_try_nid_nopanic(x, align, \
+					     BOOTMEM_LOW_LIMIT, \
+					     BOOTMEM_ALLOC_ACCESSIBLE, \
+					     MAX_NUMNODES)
+#define memblock_virt_alloc_node(x, nid) \
+	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
+				     BOOTMEM_ALLOC_ACCESSIBLE, nid)
+#define memblock_virt_alloc_node_nopanic(x, nid) \
+	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
+					     BOOTMEM_LOW_LIMIT, \
+					     BOOTMEM_ALLOC_ACCESSIBLE, nid)
+
+#define memblock_free_early(x, s)		__memblock_free_early(x, s)
+#define memblock_free_early_nid(x, s, nid)	__memblock_free_early(x, s)
+#define memblock_free_late(x, s)		__memblock_free_late(x, s)
+
+#else
+
+#define BOOTMEM_ALLOC_ACCESSIBLE	0
+
+
+/* Fall back to all the existing bootmem APIs */
+#define memblock_virt_alloc(x) \
+	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_align(x, align) \
+	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_nopanic(x) \
+	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_align_nopanic(x, align) \
+	__alloc_bootmem_nopanic(x, align, BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_node(x, nid) \
+	__alloc_bootmem_node(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_node_nopanic(x, nid) \
+	__alloc_bootmem_node_nopanic(NODE_DATA(nid), x, SMP_CACHE_BYTES, \
+			BOOTMEM_LOW_LIMIT)
+#define memblock_virt_alloc_try_nid(size, align, from, max_addr, nid) \
+		__alloc_bootmem_node_high(NODE_DATA(nid), size, align, from)
+#define memblock_virt_alloc_try_nid_nopanic(size, align, from, max_addr, nid) \
+		___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align, \
+			from, max_addr)
+#define memblock_free_early(x, s)	free_bootmem(x, s)
+#define memblock_free_early_nid(x, s, nid) \
+			free_bootmem_node(NODE_DATA(nid), x, s)
+#define memblock_free_late(x, s)	free_bootmem_late(x, s)
+
+#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
+
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/memblock.c b/mm/memblock.c
index 1d15e07..3311fbb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -21,6 +21,9 @@
 #include <linux/memblock.h>
 
 #include <asm-generic/sections.h>
+#include <asm/io.h>
+
+#include "internal.h"
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
@@ -933,6 +936,198 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+/**
+ * _memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @from: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * The @from limit is dropped if it can not be satisfied and the allocation
+ * will fall back to memory below @from.
+ *
+ * Allocation may fall back to any node in the system if the specified node
+ * can not hold the requested memory.
+ *
+ * The phys address of allocated boot memory block is converted to virtual and
+ * allocated memory is reset to 0.
+ *
+ * In addition, function sets sets the min_count for allocated boot memory block
+ * to 0 so that it is never reported as leaks.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+static void * __init _memblock_virt_alloc_try_nid_nopanic(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t from, phys_addr_t max_addr,
+				int nid)
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
+	if (!align)
+		align = SMP_CACHE_BYTES;
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
+		alloc = memblock_find_in_range_node(from, max_addr, size,
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
+/**
+ * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @from: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
+ * additional debug information (including caller info), if enabled.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+void * __init memblock_virt_alloc_try_nid_nopanic(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t from, phys_addr_t max_addr,
+				int nid)
+{
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)from,
+		     (u64)max_addr, (void *)_RET_IP_);
+	return _memblock_virt_alloc_try_nid_nopanic(size,
+						align, from, max_addr, nid);
+}
+
+/**
+ * memblock_virt_alloc_try_nid - allocate boot memory block with panicking
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @from: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %MAX_NUMNODES for any node
+ *
+ * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
+ * which provides debug information (including caller info), if enabled,
+ * and panics if the request can not be satisfied.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+void * __init memblock_virt_alloc_try_nid(
+			phys_addr_t size, phys_addr_t align,
+			phys_addr_t from, phys_addr_t max_addr,
+			int nid)
+{
+	void *ptr;
+
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)from,
+		     (u64)max_addr, (void *)_RET_IP_);
+	ptr = _memblock_virt_alloc_try_nid_nopanic(size,
+					align, from, max_addr, nid);
+	if (ptr)
+		return ptr;
+
+	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
+	      __func__, (u64)size, (u64)align, nid, (u64)from, (u64)max_addr);
+	return NULL;
+}
+
+/**
+ * __memblock_free_early - free boot memory block
+ * @base: phys starting address of the  boot memory block
+ * @size: size of the boot memory block in bytes
+ *
+ * Free boot memory block previously allocated by memblock_virt_alloc_xx() API.
+ * The freeing memory will not be released to the buddy allocator.
+ */
+void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
+{
+	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+		     __func__, (u64)base, (u64)base + size - 1,
+		     (void *)_RET_IP_);
+	kmemleak_free_part(__va(base), size);
+	__memblock_remove(&memblock.reserved, base, size);
+}
+
+/*
+ * __memblock_free_late - free bootmem block pages directly to buddy allocator
+ * @addr: phys starting address of the  boot memory block
+ * @size: size of the boot memory block in bytes
+ *
+ * This is only useful when the bootmem allocator has already been torn
+ * down, but we are still initializing the system.  Pages are released directly
+ * to the buddy allocator, no bootmem metadata is updated because it is gone.
+ */
+void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
+{
+	u64 cursor, end;
+
+	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
+		     __func__, (u64)base, (u64)base + size - 1,
+		     (void *)_RET_IP_);
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
