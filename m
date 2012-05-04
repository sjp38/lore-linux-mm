Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 9306E6B00F2
	for <linux-mm@kvack.org>; Fri,  4 May 2012 14:55:42 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 1/2] memblock: Add _THIS_IP off the caller to memblock debug statements and size in kB.
Date: Fri,  4 May 2012 14:49:41 -0400
Message-Id: <1336157382-14548-2-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1336157382-14548-1-git-send-email-konrad.wilk@oracle.com>
References: <1336157382-14548-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tj@kernel.org, hpa@linux.intel.com, yinghai@kernel.org, paul.gortmaker@windriver.com, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

-memblock_reserve: [0x0000003fefb000-0x0000003fefc000] (4kB) __alloc_memory_core_early+0x65/0x70
-memblock_reserve: [0x0000003fafb000-0x0000003fefb000] (4096kB) __alloc_memory_core_early+0x65/0x70
-memblock_reserve: [0x0000003fafaf00-0x0000003fafafd8] (0kB) __alloc_memory_core_early+0x65/0x70
-memblock_reserve: [0x0000003f6faf00-0x0000003fafaf00] (4096kB) __alloc_memory_core_early+0x65/0x70
-memblock_reserve: [0x0000003e400000-0x0000003f600000] (18432kB) __alloc_memory_core_early+0x65/0x70
-memblock_reserve: [0x0000003f6f9000-0x0000003f6fa000] (4kB) __alloc_memory_core_early+0x65/0x70
.. snip..
-   memblock_free: [0x0000003f3c0000-0x0000003f600000] (2304kB) free_bootmem+0xd/0xf
-   memblock_free: [0x0000003f6faf00-0x0000003fafaf00] (4096kB) free_bootmem+0xd/0xf
-   memblock_free: [0x0000003fafb000-0x0000003fefb000] (4096kB) free_bootmem+0xd/0xf
+memblock_reserve: [0x0000003fefb000-0x0000003fefc000] __alloc_memory_core_early+0x5c/0x64
+memblock_reserve: [0x0000003fafb000-0x0000003fefb000] __alloc_memory_core_early+0x5c/0x64
+memblock_reserve: [0x0000003fafaf00-0x0000003fafafd8] __alloc_memory_core_early+0x5c/0x64
+memblock_reserve: [0x0000003f6faf00-0x0000003fafaf00] __alloc_memory_core_early+0x5c/0x64
+memblock_reserve: [0x0000003e400000-0x0000003f600000] __alloc_memory_core_early+0x5c/0x64
.. snip..
+   memblock_free: [0x0000003f3c0000-0x0000003f600000] free_bootmem+0x9/0xb
+   memblock_free: [0x0000003f6faf00-0x0000003fafaf00] free_bootmem+0x9/0xb
+   memblock_free: [0x0000003fafb000-0x0000003fefb000] free_bootmem+0x9/0xb

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/memblock.h |    6 +++-
 mm/memblock.c            |   14 +++++++-----
 mm/nobootmem.c           |   50 ++++++++++++++++++++++++++-------------------
 3 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index a6bb102..2a1ec82 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -57,8 +57,10 @@ void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
-int memblock_free(phys_addr_t base, phys_addr_t size);
-int memblock_reserve(phys_addr_t base, phys_addr_t size);
+int __memblock_free(phys_addr_t base, phys_addr_t size, void *caller);
+#define memblock_free(base, size) __memblock_free(base, size, (void *)_RET_IP_)
+int __memblock_reserve(phys_addr_t base, phys_addr_t size, void *caller);
+#define memblock_reserve(base, size) __memblock_reserve(base, size, (void *)_RET_IP_)
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
diff --git a/mm/memblock.c b/mm/memblock.c
index a44eab3..3e97b07 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -502,24 +502,26 @@ int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
 	return __memblock_remove(&memblock.memory, base, size);
 }
 
-int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
+int __init_memblock __memblock_free(phys_addr_t base, phys_addr_t size, void *caller)
 {
-	memblock_dbg("   memblock_free: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("   memblock_free: [%#016llx-%#016llx] (%lukB) %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size,
-		     (void *)_RET_IP_);
+		     (unsigned long)(size >> 10),
+		     caller);
 
 	return __memblock_remove(&memblock.reserved, base, size);
 }
 
-int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
+int __init_memblock __memblock_reserve(phys_addr_t base, phys_addr_t size, void *caller)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
 
-	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
+	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] (%lukB) %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size,
-		     (void *)_RET_IP_);
+		     (unsigned long)(size >> 10),
+		     caller);
 
 	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index e53bb8a..fe9b251 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -16,6 +16,7 @@
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/kernel.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
@@ -33,7 +34,7 @@ unsigned long min_low_pfn;
 unsigned long max_pfn;
 
 static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
-					u64 goal, u64 limit)
+					u64 goal, u64 limit, void *caller)
 {
 	void *ptr;
 	u64 addr;
@@ -47,7 +48,7 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 
 	ptr = phys_to_virt(addr);
 	memset(ptr, 0, size);
-	memblock_reserve(addr, size);
+	__memblock_reserve(addr, size, caller);
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
 	 * are never reported as leaks.
@@ -175,7 +176,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
 	kmemleak_free_part(__va(physaddr), size);
-	memblock_free(physaddr, size);
+	__memblock_free(physaddr, size, (void *)_RET_IP_);
 }
 
 /**
@@ -190,13 +191,14 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
 	kmemleak_free_part(__va(addr), size);
-	memblock_free(addr, size);
+	__memblock_free(addr, size, (void *)_RET_IP_);
 }
 
 static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 					unsigned long align,
 					unsigned long goal,
-					unsigned long limit)
+					unsigned long limit,
+					void *caller)
 {
 	void *ptr;
 
@@ -205,7 +207,7 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 
 restart:
 
-	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, limit);
+	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align, goal, limit, caller);
 
 	if (ptr)
 		return ptr;
@@ -236,13 +238,14 @@ void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 {
 	unsigned long limit = -1UL;
 
-	return ___alloc_bootmem_nopanic(size, align, goal, limit);
+	return ___alloc_bootmem_nopanic(size, align, goal, limit, (void *)_RET_IP_);
 }
 
 static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
-					unsigned long goal, unsigned long limit)
+					unsigned long goal, unsigned long limit,
+					void *caller)
 {
-	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
+	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit, caller);
 
 	if (mem)
 		return mem;
@@ -271,8 +274,7 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
 	unsigned long limit = -1UL;
-
-	return ___alloc_bootmem(size, align, goal, limit);
+	return ___alloc_bootmem(size, align, goal, limit, (void *)_RET_IP_);
 }
 
 /**
@@ -290,8 +292,9 @@ void * __init __alloc_bootmem(unsigned long size, unsigned long align,
  *
  * The function panics if the request can not be satisfied.
  */
-void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
+void * __init ____alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				     unsigned long align, unsigned long goal,
+				     void *caller)
 {
 	void *ptr;
 
@@ -300,23 +303,28 @@ void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 
 again:
 	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-					 goal, -1ULL);
+					 goal, -1ULL, caller);
 	if (ptr)
 		return ptr;
 
 	ptr = __alloc_memory_core_early(MAX_NUMNODES, size, align,
-					goal, -1ULL);
+					goal, -1ULL, caller);
 	if (!ptr && goal) {
 		goal = 0;
 		goto again;
 	}
 	return ptr;
 }
+void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
+				   unsigned long align, unsigned long goal)
+{
+	return ____alloc_bootmem_node(pgdat, size, align, goal, (void *)_RET_IP_);
+}
 
 void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
-	return __alloc_bootmem_node(pgdat, size, align, goal);
+	return ____alloc_bootmem_node(pgdat, size, align, goal, (void *)_RET_IP_);
 }
 
 #ifdef CONFIG_SPARSEMEM
@@ -337,7 +345,7 @@ void * __init alloc_bootmem_section(unsigned long size,
 	limit = section_nr_to_pfn(section_nr + 1) << PAGE_SHIFT;
 
 	return __alloc_memory_core_early(early_pfn_to_nid(pfn), size,
-					 SMP_CACHE_BYTES, goal, limit);
+					 SMP_CACHE_BYTES, goal, limit, (void *)_RET_IP_);
 }
 #endif
 
@@ -350,7 +358,7 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 	ptr =  __alloc_memory_core_early(pgdat->node_id, size, align,
-						 goal, -1ULL);
+						 goal, -1ULL, (void *)_RET_IP_);
 	if (ptr)
 		return ptr;
 
@@ -377,7 +385,7 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
+	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT, (void *)_RET_IP_);
 }
 
 /**
@@ -404,10 +412,10 @@ void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
+				goal, ARCH_LOW_ADDRESS_LIMIT, (void *)_RET_IP_);
 	if (ptr)
 		return ptr;
 
 	return  __alloc_memory_core_early(MAX_NUMNODES, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
+				goal, ARCH_LOW_ADDRESS_LIMIT, (void *)_RET_IP_);
 }
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
