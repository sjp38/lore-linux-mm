Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id CC94D6B0038
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:28:09 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id e4so2967885wiv.0
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:28:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id wa6si7980980wjc.50.2014.02.10.09.28.06
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 09:28:07 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 2/4] memblock: add memblock_virt_alloc_nid_nopanic()
Date: Mon, 10 Feb 2014 12:27:46 -0500
Message-Id: <1392053268-29239-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

From: Luiz capitulino <lcapitulino@redhat.com>

This function tries to allocate memory from the specified node only (vs.
automatically trying other nodes on failure).

This is going to be used by HugeTLB boot-time allocation code in next
commits.

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 include/linux/bootmem.h |  4 ++++
 mm/memblock.c           | 31 +++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

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
index b0c7b2e..9130d4b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1153,6 +1153,37 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
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
+					     max_addr, nid,
+					     ALLOC_SPECIFIED_NODE_ONLY);
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
