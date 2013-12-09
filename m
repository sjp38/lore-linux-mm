Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD8736B00F8
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:52:01 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so3305755qcy.9
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:52:01 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id kb1si9569842qeb.113.2013.12.09.13.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:52:00 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation apis
Date: Mon, 9 Dec 2013 16:50:41 -0500
Message-ID: <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Introduce memblock memory allocation APIs which allow to support
PAE or LPAE extension on 32 bits archs where the physical memory
start address can be beyond 4GB. In such cases, existing bootmem
APIs which operate on 32 bit addresses won't work and needs
memblock layer which operates on 64 bit addresses.

So we add equivalent APIs so that we can replace usage of bootmem
with memblock interfaces. Architectures already converted to
NO_BOOTMEM use these new memblock interfaces. The architectures
which are still not converted to NO_BOOTMEM continue to function
as is because we still maintain the fal lback option of bootmem
back-end supporting these new interfaces. So no functional change
as such.

In long run, once all the architectures moves to NO_BOOTMEM, we
can get rid of bootmem layer completely. This is one step to remove
the core code dependency with bootmem and also gives path for
architectures to move away from bootmem.

The proposed interface will became active if both
CONFIG_HAVE_MEMBLOCK and CONFIG_NO_BOOTMEM are specified by arch.
In case !CONFIG_NO_BOOTMEM, the memblock() wrappers will fallback
to the existing bootmem apis so that arch's not converted to
NO_BOOTMEM continue to work as is.

The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE
is kept same.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 include/linux/bootmem.h |  151 ++++++++++++++++++++++++++++++++++++
 mm/memblock.c           |  198 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 349 insertions(+)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 55d52fb..1c9aa0e 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -141,6 +141,157 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
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
+void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
+		phys_addr_t align, phys_addr_t min_addr,
+		phys_addr_t max_addr, int nid);
+void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+		phys_addr_t min_addr, phys_addr_t max_addr, int nid);
+void __memblock_free_early(phys_addr_t base, phys_addr_t size);
+void __memblock_free_late(phys_addr_t base, phys_addr_t size);
+
+static inline void * __init memblock_virt_alloc(
+					phys_addr_t size,  phys_addr_t align)
+{
+	return memblock_virt_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
+					    BOOTMEM_ALLOC_ACCESSIBLE,
+					    NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_virt_alloc_nopanic(
+					phys_addr_t size, phys_addr_t align)
+{
+	return memblock_virt_alloc_try_nid_nopanic(size, align,
+						    BOOTMEM_LOW_LIMIT,
+						    BOOTMEM_ALLOC_ACCESSIBLE,
+						    NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_virt_alloc_from_nopanic(
+		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
+{
+	return memblock_virt_alloc_try_nid_nopanic(size, align, min_addr,
+						    BOOTMEM_ALLOC_ACCESSIBLE,
+						    NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_virt_alloc_node(
+						phys_addr_t size, int nid)
+{
+	return memblock_virt_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
+					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
+}
+
+static inline void * __init memblock_virt_alloc_node_nopanic(
+						phys_addr_t size, int nid)
+{
+	return memblock_virt_alloc_try_nid_nopanic(size, 0, BOOTMEM_LOW_LIMIT,
+						    BOOTMEM_ALLOC_ACCESSIBLE,
+						    nid);
+}
+
+static inline void __init memblock_free_early(
+					phys_addr_t base, phys_addr_t size)
+{
+	__memblock_free_early(base, size);
+}
+
+static inline void __init memblock_free_early_nid(
+				phys_addr_t base, phys_addr_t size, int nid)
+{
+	__memblock_free_early(base, size);
+}
+
+static inline void __init memblock_free_late(
+					phys_addr_t base, phys_addr_t size)
+{
+	__memblock_free_late(base, size);
+}
+
+#else
+
+#define BOOTMEM_ALLOC_ACCESSIBLE	0
+
+
+/* Fall back to all the existing bootmem APIs */
+static inline void * __init memblock_virt_alloc(
+					phys_addr_t size,  phys_addr_t align)
+{
+	if (!align)
+		align = SMP_CACHE_BYTES;
+	return __alloc_bootmem(size, align, BOOTMEM_LOW_LIMIT);
+}
+
+static inline void * __init memblock_virt_alloc_nopanic(
+					phys_addr_t size, phys_addr_t align)
+{
+	if (!align)
+		align = SMP_CACHE_BYTES;
+	return __alloc_bootmem_nopanic(size, align, BOOTMEM_LOW_LIMIT);
+}
+
+static inline void * __init memblock_virt_alloc_from_nopanic(
+		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
+{
+	return __alloc_bootmem_nopanic(size, align, min_addr);
+}
+
+static inline void * __init memblock_virt_alloc_node(
+						phys_addr_t size, int nid)
+{
+	return __alloc_bootmem_node(NODE_DATA(nid), size, SMP_CACHE_BYTES,
+				     BOOTMEM_LOW_LIMIT);
+}
+
+static inline void * __init memblock_virt_alloc_node_nopanic(
+						phys_addr_t size, int nid)
+{
+	return __alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
+					     SMP_CACHE_BYTES,
+					     BOOTMEM_LOW_LIMIT);
+}
+
+static inline void * __init memblock_virt_alloc_try_nid(phys_addr_t size,
+	phys_addr_t align, phys_addr_t min_addr, phys_addr_t max_addr, int nid)
+{
+	return __alloc_bootmem_node_high(NODE_DATA(nid), size, align,
+					  min_addr);
+}
+
+static inline void * __init memblock_virt_alloc_try_nid_nopanic(
+			phys_addr_t size, phys_addr_t align,
+			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
+{
+	return ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align,
+				min_addr, max_addr);
+}
+
+static inline void __init memblock_free_early(
+					phys_addr_t base, phys_addr_t size)
+{
+	free_bootmem(base, size);
+}
+
+static inline void __init memblock_free_early_nid(
+				phys_addr_t base, phys_addr_t size, int nid)
+{
+	free_bootmem_node(NODE_DATA(nid), base, size);
+}
+
+static inline void __init memblock_free_late(
+					phys_addr_t base, phys_addr_t size)
+{
+	free_bootmem_late(base, size);
+}
+#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
+
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/memblock.c b/mm/memblock.c
index 900057b..d03d50a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -21,6 +21,9 @@
 #include <linux/memblock.h>
 
 #include <asm-generic/sections.h>
+#include <linux/io.h>
+
+#include "internal.h"
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
@@ -943,6 +946,201 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
+/**
+ * memblock_virt_alloc_internal - allocate boot memory block
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @min_addr: the lower bound of the memory region to allocate (phys address)
+ * @max_addr: the upper bound of the memory region to allocate (phys address)
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * The @min_addr limit is dropped if it can not be satisfied and the allocation
+ * will fall back to memory below @min_addr. Also, allocation may fall back
+ * to any node in the system if the specified node can not
+ * hold the requested memory.
+ *
+ * The allocation is performed from memory region limited by
+ * memblock.current_limit if @max_addr == %BOOTMEM_ALLOC_ACCESSIBLE.
+ *
+ * The memory block is aligned on SMP_CACHE_BYTES if @align == 0.
+ *
+ * The phys address of allocated boot memory block is converted to virtual and
+ * allocated memory is reset to 0.
+ *
+ * In addition, function sets the min_count to 0 using kmemleak_alloc for
+ * allocated boot memory block, so that it is never reported as leaks.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+static void * __init memblock_virt_alloc_internal(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid)
+{
+	phys_addr_t alloc;
+	void *ptr;
+
+	if (nid == MAX_NUMNODES)
+		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
+			__func__);
+
+	if (WARN_ON_ONCE(slab_is_available()))
+		return kzalloc_node(size, GFP_NOWAIT, nid);
+
+	if (!align)
+		align = SMP_CACHE_BYTES;
+
+	/* align @size to avoid excessive fragmentation on reserved array */
+	size = round_up(size, align);
+
+again:
+	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
+					    nid);
+	if (alloc)
+		goto done;
+
+	if (nid != NUMA_NO_NODE) {
+		alloc = memblock_find_in_range_node(size, align, min_addr,
+						    max_addr,  NUMA_NO_NODE);
+		if (alloc)
+			goto done;
+	}
+
+	if (min_addr) {
+		min_addr = 0;
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
+ * @min_addr: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
+ * additional debug information (including caller info), if enabled.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+void * __init memblock_virt_alloc_try_nid_nopanic(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid)
+{
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, (void *)_RET_IP_);
+	return memblock_virt_alloc_internal(size, align, min_addr,
+					     max_addr, nid);
+}
+
+/**
+ * memblock_virt_alloc_try_nid - allocate boot memory block with panicking
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @min_addr: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
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
+			phys_addr_t min_addr, phys_addr_t max_addr,
+			int nid)
+{
+	void *ptr;
+
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, (void *)_RET_IP_);
+	ptr = memblock_virt_alloc_internal(size, align,
+					   min_addr, max_addr, nid);
+	if (ptr)
+		return ptr;
+
+	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
+	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+	      (u64)max_addr);
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
