Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5F66B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 03:41:21 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so4624920pab.6
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 00:41:21 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id y5si643895pdm.95.2014.10.20.00.41.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 20 Oct 2014 00:41:20 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDQ00GICG0HDF70@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 20 Oct 2014 16:41:05 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH] mm: cma: split cma-reserved in dmesg log
Date: Mon, 20 Oct 2014 13:03:10 +0530
Message-id: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, vdavydov@parallels.com, nasa4836@gmail.com, ddstreet@ieee.org, m.szyprowski@samsung.com, pintu.k@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, lauraa@codeaurora.org, gioh.kim@lge.com, rientjes@google.com, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

When the system boots up, in the dmesg logs we can see
the memory statistics along with total reserved as below.
Memory: 458840k/458840k available, 65448k reserved, 0K highmem

When CMA is enabled, still the total reserved memory remains the same.
However, the CMA memory is not considered as reserved.
But, when we see /proc/meminfo, the CMA memory is part of free memory.
This creates confusion.
This patch corrects the problem by properly substracting the CMA reserved
memory from the total reserved memory in dmesg logs.

Below is the dmesg snaphot from an arm based device with 512MB RAM and
12MB single CMA region.

Before this change:
Memory: 458840k/458840k available, 65448k reserved, 0K highmem

After this change:
Memory: 458840k/458840k available, 53160k reserved, 12288k cma-reserved, 0K highmem

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
---
 include/linux/swap.h | 3 +++
 mm/cma.c             | 2 ++
 mm/page_alloc.c      | 8 ++++++++
 3 files changed, 13 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 37a585b..beb84be 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -295,6 +295,9 @@ static inline void workingset_node_shadows_dec(struct radix_tree_node *node)
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
+#ifdef CONFIG_CMA
+extern unsigned long totalcma_pages;
+#endif
 extern unsigned long dirty_balance_reserve;
 extern unsigned long nr_free_buffer_pages(void);
 extern unsigned long nr_free_pagecache_pages(void);
diff --git a/mm/cma.c b/mm/cma.c
index 963bc4a..73fe7be 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -45,6 +45,7 @@ struct cma {
 static struct cma cma_areas[MAX_CMA_AREAS];
 static unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
+unsigned long totalcma_pages __read_mostly;
 
 phys_addr_t cma_get_base(struct cma *cma)
 {
@@ -288,6 +289,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (ret)
 		goto err;
 
+	totalcma_pages += (size / PAGE_SIZE);
 	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
 		(unsigned long)base);
 	return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd73f9a..c6165ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5521,6 +5521,9 @@ void __init mem_init_print_info(const char *str)
 	pr_info("Memory: %luK/%luK available "
 	       "(%luK kernel code, %luK rwdata, %luK rodata, "
 	       "%luK init, %luK bss, %luK reserved"
+#ifdef CONFIG_CMA
+		", %luK cma-reserved"
+#endif
 #ifdef	CONFIG_HIGHMEM
 	       ", %luK highmem"
 #endif
@@ -5528,7 +5531,12 @@ void __init mem_init_print_info(const char *str)
 	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
 	       codesize >> 10, datasize >> 10, rosize >> 10,
 	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
+#ifdef CONFIG_CMA
+	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
+	       totalcma_pages << (PAGE_SHIFT-10),
+#else
 	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
+#endif
 #ifdef	CONFIG_HIGHMEM
 	       totalhigh_pages << (PAGE_SHIFT-10),
 #endif
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
