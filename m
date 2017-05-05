Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 365C16B02F4
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:03:32 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 67so13212905itx.11
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:03:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a138si26862733ioe.4.2017.05.05.10.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:03:31 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v3 2/9] mm: defining memblock_virt_alloc_try_nid_raw
Date: Fri,  5 May 2017 13:03:09 -0400
Message-Id: <1494003796-748672-3-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

A new version of memblock_virt_alloc_* allocations:
- Does not zero the allocated memory
- Does not panic if request cannot be satisfied

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 include/linux/bootmem.h |    3 +++
 mm/memblock.c           |   46 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 962164d..4e0f08b 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -160,6 +160,9 @@ extern int reserve_bootmem_node(pg_data_t *pgdat,
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
 
 /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
+void *memblock_virt_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
+				      phys_addr_t min_addr,
+				      phys_addr_t max_addr, int nid);
 void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t min_addr,
 		phys_addr_t max_addr, int nid);
diff --git a/mm/memblock.c b/mm/memblock.c
index 696f06d..7fdc555 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1271,7 +1271,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 static void * __init memblock_virt_alloc_internal(
 				phys_addr_t size, phys_addr_t align,
 				phys_addr_t min_addr, phys_addr_t max_addr,
-				int nid)
+				int nid, bool zero)
 {
 	phys_addr_t alloc;
 	void *ptr;
@@ -1322,7 +1322,8 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return NULL;
 done:
 	ptr = phys_to_virt(alloc);
-	memset(ptr, 0, size);
+	if (zero)
+		memset(ptr, 0, size);
 
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
@@ -1336,6 +1337,37 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
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
+	return memblock_virt_alloc_internal(size, align,
+					   min_addr, max_addr, nid, false);
+}
+
+/**
  * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
@@ -1346,8 +1378,8 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
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
@@ -1361,7 +1393,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	return memblock_virt_alloc_internal(size, align, min_addr,
-					     max_addr, nid);
+					     max_addr, nid, true);
 }
 
 /**
@@ -1375,7 +1407,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * Public panicking version of _memblock_virt_alloc_try_nid_nopanic()
+ * Public panicking version of memblock_virt_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
  * and panics if the request can not be satisfied.
  *
@@ -1393,7 +1425,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
 		     (u64)max_addr, (void *)_RET_IP_);
 	ptr = memblock_virt_alloc_internal(size, align,
-					   min_addr, max_addr, nid);
+					   min_addr, max_addr, nid, true);
 	if (ptr)
 		return ptr;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
