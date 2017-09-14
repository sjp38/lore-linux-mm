Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 311AC6B025E
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 18:36:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p87so1064913pfj.4
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:36:14 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 33si13158473pla.343.2017.09.14.15.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 15:36:12 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v8 05/11] mm: defining memblock_virt_alloc_try_nid_raw
Date: Thu, 14 Sep 2017 18:35:11 -0400
Message-Id: <20170914223517.8242-6-pasha.tatashin@oracle.com>
In-Reply-To: <20170914223517.8242-1-pasha.tatashin@oracle.com>
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

* A new variant of memblock_virt_alloc_* allocations:
memblock_virt_alloc_try_nid_raw()
    - Does not zero the allocated memory
    - Does not panic if request cannot be satisfied

* optimize early system hash allocations

Clients can call alloc_large_system_hash() with flag: HASH_ZERO to specify
that memory that was allocated for system hash needs to be zeroed,
otherwise the memory does not need to be zeroed, and client will initialize
it.

If memory does not need to be zero'd, call the new
memblock_virt_alloc_raw() interface, and thus improve the boot performance.

* debug for raw alloctor

When CONFIG_DEBUG_VM is enabled, this patch sets all the memory that is
returned by memblock_virt_alloc_try_nid_raw() to ones to ensure that no
places excpect zeroed memory.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/bootmem.h | 27 ++++++++++++++++++++++
 mm/memblock.c           | 60 +++++++++++++++++++++++++++++++++++++++++++------
 mm/page_alloc.c         | 15 ++++++-------
 3 files changed, 87 insertions(+), 15 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index e223d91b6439..ea30b3987282 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -160,6 +160,9 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
 
 /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
+void *memblock_virt_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
+				      phys_addr_t min_addr,
+				      phys_addr_t max_addr, int nid);
 void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t min_addr,
 		phys_addr_t max_addr, int nid);
@@ -176,6 +179,14 @@ static inline void * __init memblock_virt_alloc(
 					    NUMA_NO_NODE);
 }
 
+static inline void * __init memblock_virt_alloc_raw(
+					phys_addr_t size,  phys_addr_t align)
+{
+	return memblock_virt_alloc_try_nid_raw(size, align, BOOTMEM_LOW_LIMIT,
+					    BOOTMEM_ALLOC_ACCESSIBLE,
+					    NUMA_NO_NODE);
+}
+
 static inline void * __init memblock_virt_alloc_nopanic(
 					phys_addr_t size, phys_addr_t align)
 {
@@ -257,6 +268,14 @@ static inline void * __init memblock_virt_alloc(
 	return __alloc_bootmem(size, align, BOOTMEM_LOW_LIMIT);
 }
 
+static inline void * __init memblock_virt_alloc_raw(
+					phys_addr_t size,  phys_addr_t align)
+{
+	if (!align)
+		align = SMP_CACHE_BYTES;
+	return __alloc_bootmem_nopanic(size, align, BOOTMEM_LOW_LIMIT);
+}
+
 static inline void * __init memblock_virt_alloc_nopanic(
 					phys_addr_t size, phys_addr_t align)
 {
@@ -309,6 +328,14 @@ static inline void * __init memblock_virt_alloc_try_nid(phys_addr_t size,
 					  min_addr);
 }
 
+static inline void * __init memblock_virt_alloc_try_nid_raw(
+			phys_addr_t size, phys_addr_t align,
+			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
+{
+	return ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align,
+				min_addr, max_addr);
+}
+
 static inline void * __init memblock_virt_alloc_try_nid_nopanic(
 			phys_addr_t size, phys_addr_t align,
 			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
diff --git a/mm/memblock.c b/mm/memblock.c
index 91205780e6b1..1f299fb1eb08 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1327,7 +1327,6 @@ static void * __init memblock_virt_alloc_internal(
 	return NULL;
 done:
 	ptr = phys_to_virt(alloc);
-	memset(ptr, 0, size);
 
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
@@ -1340,6 +1339,45 @@ static void * __init memblock_virt_alloc_internal(
 	return ptr;
 }
 
+/**
+ * memblock_virt_alloc_try_nid_raw - allocate boot memory block without zeroing
+ * memory and without panicking
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @min_addr: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * Public function, provides additional debug information (including caller
+ * info), if enabled. Does not zero allocated memory, does not panic if request
+ * cannot be satisfied.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+void * __init memblock_virt_alloc_try_nid_raw(
+			phys_addr_t size, phys_addr_t align,
+			phys_addr_t min_addr, phys_addr_t max_addr,
+			int nid)
+{
+	void *ptr;
+
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, (void *)_RET_IP_);
+
+	ptr = memblock_virt_alloc_internal(size, align,
+					   min_addr, max_addr, nid);
+#ifdef CONFIG_DEBUG_VM
+	if (ptr && size > 0)
+		memset(ptr, 0xff, size);
+#endif
+	return ptr;
+}
+
 /**
  * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1351,8 +1389,8 @@ static void * __init memblock_virt_alloc_internal(
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * Public version of _memblock_virt_alloc_try_nid_nopanic() which provides
- * additional debug information (including caller info), if enabled.
+ * Public function, provides additional debug information (including caller
+ * info), if enabled. This function zeroes the allocated memory.
  *
  * RETURNS:
  * Virtual address of allocated memory block on success, NULL on failure.
@@ -1362,11 +1400,17 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
 {
+	void *ptr;
+
 	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
-	return memblock_virt_alloc_internal(size, align, min_addr,
-					     max_addr, nid);
+
+	ptr = memblock_virt_alloc_internal(size, align,
+					   min_addr, max_addr, nid);
+	if (ptr)
+		memset(ptr, 0, size);
+	return ptr;
 }
 
 /**
@@ -1380,7 +1424,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
+ * Public panicking version of memblock_virt_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
  * and panics if the request can not be satisfied.
  *
@@ -1399,8 +1443,10 @@ void * __init memblock_virt_alloc_try_nid(
 		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
-	if (ptr)
+	if (ptr) {
+		memset(ptr, 0, size);
 		return ptr;
+	}
 
 	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx\n",
 	      __func__, (u64)size, (u64)align, nid, (u64)min_addr,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d132c801d2c1..a8dbd405ed94 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7299,18 +7299,17 @@ void *__init alloc_large_system_hash(const char *tablename,
 
 	log2qty = ilog2(numentries);
 
-	/*
-	 * memblock allocator returns zeroed memory already, so HASH_ZERO is
-	 * currently not used when HASH_EARLY is specified.
-	 */
 	gfp_flags = (flags & HASH_ZERO) ? GFP_ATOMIC | __GFP_ZERO : GFP_ATOMIC;
 	do {
 		size = bucketsize << log2qty;
-		if (flags & HASH_EARLY)
-			table = memblock_virt_alloc_nopanic(size, 0);
-		else if (hashdist)
+		if (flags & HASH_EARLY) {
+			if (flags & HASH_ZERO)
+				table = memblock_virt_alloc_nopanic(size, 0);
+			else
+				table = memblock_virt_alloc_raw(size, 0);
+		} else if (hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
-		else {
+		} else {
 			/*
 			 * If bucketsize is not a power-of-two, we may free
 			 * some pages at the end of hash table which
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
