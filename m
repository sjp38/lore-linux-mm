Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 265A16B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:02:45 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id b15so5387657eek.29
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:02:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x43si7419694eey.166.2014.02.13.17.02.43
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:02:43 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 2/4] memblock: add memblock_virt_alloc_nid_nopanic()
Date: Thu, 13 Feb 2014 20:02:06 -0500
Message-Id: <1392339728-13487-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, rientjes@google.com

From: Luiz capitulino <lcapitulino@redhat.com>

This function tries to allocate memory from the specified node only (vs.
falling back to other nodes).

This is going to be used by HugeTLB boot-time allocation code in next
commits.

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 include/linux/bootmem.h |  4 ++++
 mm/memblock.c           | 30 ++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index db51fe4..6961b11 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -153,6 +153,10 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t min_addr,
 		phys_addr_t max_addr, int nid);
+void * __init memblock_virt_alloc_nid_nopanic(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid);
 void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
 		phys_addr_t min_addr, phys_addr_t max_addr, int nid);
 void __memblock_free_early(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index f3821ef..2a5d72e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1157,6 +1157,36 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 }
 
 /**
+ * memblock_virt_alloc_nid_nopanic - allocate boot memory block from
+ * specified node
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @min_addr: the lower bound of the memory region from where the allocation
+ *	  is preferred (phys address)
+ * @max_addr: the upper bound of the memory region from where the allocation
+ *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      allocate only from memory limited by memblock.current_limit value
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * This function tries to allocate memory from @nid only. It @nid doesn't
+ * have enough memory, this function returns failure.
+ *
+ * RETURNS:
+ * Virtual address of allocated memory block on success, NULL on failure.
+ */
+void * __init memblock_virt_alloc_nid_nopanic(
+				phys_addr_t size, phys_addr_t align,
+				phys_addr_t min_addr, phys_addr_t max_addr,
+				int nid)
+{
+	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=0x%llx max_addr=0x%llx %pF\n",
+		     __func__, (u64)size, (u64)align, nid, (u64)min_addr,
+		     (u64)max_addr, (void *)_RET_IP_);
+	return memblock_virt_alloc_internal(size, align, min_addr,
+					     max_addr, nid, __GFP_THISNODE);
+}
+
+/**
  * memblock_virt_alloc_try_nid - allocate boot memory block with panicking
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
