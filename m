Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43A4C6B061A
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 16:39:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r29so56589398pfi.7
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 13:39:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l36si21032700plg.74.2017.08.02.13.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 13:39:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 07/15] mm: defining memblock_virt_alloc_try_nid_raw
Date: Wed,  2 Aug 2017 16:38:16 -0400
Message-Id: <1501706304-869240-8-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

A new variant of memblock_virt_alloc_* allocations:
memblock_virt_alloc_try_nid_raw()
    - Does not zero the allocated memory
    - Does not panic if request cannot be satisfied

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/bootmem.h | 11 ++++++++++
 mm/memblock.c           | 53 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 57 insertions(+), 7 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index e223d91b6439..0a0a37f3e292 100644
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
diff --git a/mm/memblock.c b/mm/memblock.c
index e6df054e3180..bdf31f207fa4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1327,7 +1327,6 @@ static void * __init memblock_virt_alloc_internal(
 	return NULL;
 done:
 	ptr = phys_to_virt(alloc);
-	memset(ptr, 0, size);
 
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
@@ -1341,6 +1340,38 @@ static void * __init memblock_virt_alloc_internal(
 }
 
 /**
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
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, (void *)_RET_IP_);
+
+	return memblock_virt_alloc_internal(size, align,
+					    min_addr, max_addr, nid);
+}
+
+/**
  * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
@@ -1351,8 +1382,8 @@ static void * __init memblock_virt_alloc_internal(
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
@@ -1362,11 +1393,17 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
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
@@ -1380,7 +1417,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
+ * Public panicking version of memblock_virt_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
  * and panics if the request can not be satisfied.
  *
@@ -1399,8 +1436,10 @@ void * __init memblock_virt_alloc_try_nid(
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
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
