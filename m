Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD986B007B
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:16:48 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so3777866pab.38
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:16:48 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id uv6si14194587pbc.255.2014.10.22.07.16.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 22 Oct 2014 07:16:45 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDU00F0PNNVUQ20@mailout2.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Oct 2014 23:16:43 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH v2 1/2] mm: cma: split cma-reserved in dmesg log
Date: Wed, 22 Oct 2014 19:36:34 +0530
Message-id: <1413986796-19732-1-git-send-email-pintu.k@samsung.com>
In-reply-to: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, riel@redhat.com, pintu.k@samsung.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, mina86@mina86.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

When the system boots up, in the dmesg logs we can see
the memory statistics along with total reserved as below.
Memory: 458840k/458840k available, 65448k reserved, 0K highmem

When CMA is enabled, still the total reserved memory remains the same.
However, the CMA memory is not considered as reserved.
But, when we see /proc/meminfo, the CMA memory is part of free memory.
This creates confusion.
This patch corrects the problem by properly subtracting the CMA reserved
memory from the total reserved memory in dmesg logs.

Below is the dmesg snapshot from an arm based device with 512MB RAM and
12MB single CMA region.

Before this change:
Memory: 458840k/458840k available, 65448k reserved, 0K highmem

After this change:
Memory: 458840k/458840k available, 53160k reserved, 12288k cma-reserved, 0K highmem

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>
---
v2: Moved totalcma_pages extern declaration to linux/cma.h
    Removed CONFIG_CMA while show cma-reserved, from page_alloc.c
    Moved totalcma_pages declaration to page_alloc.c, so that if will be visible 
    in non-CMA cases.
 include/linux/cma.h |    1 +
 mm/cma.c            |    1 +
 mm/page_alloc.c     |    6 ++++--
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 0430ed0..0b75896 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -15,6 +15,7 @@
 
 struct cma;
 
+extern unsigned long totalcma_pages;
 extern phys_addr_t cma_get_base(struct cma *cma);
 extern unsigned long cma_get_size(struct cma *cma);
 
diff --git a/mm/cma.c b/mm/cma.c
index 963bc4a..8435762 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -288,6 +288,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (ret)
 		goto err;
 
+	totalcma_pages += (size / PAGE_SIZE);
 	pr_info("Reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
 		(unsigned long)base);
 	return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd73f9a..ababbd8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -110,6 +110,7 @@ static DEFINE_SPINLOCK(managed_page_count_lock);
 
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
+unsigned long totalcma_pages __read_mostly;
 /*
  * When calculating the number of globally allowed dirty pages, there
  * is a certain number of per-zone reserves that should not be
@@ -5520,7 +5521,7 @@ void __init mem_init_print_info(const char *str)
 
 	pr_info("Memory: %luK/%luK available "
 	       "(%luK kernel code, %luK rwdata, %luK rodata, "
-	       "%luK init, %luK bss, %luK reserved"
+	       "%luK init, %luK bss, %luK reserved, %luK cma-reserved"
 #ifdef	CONFIG_HIGHMEM
 	       ", %luK highmem"
 #endif
@@ -5528,7 +5529,8 @@ void __init mem_init_print_info(const char *str)
 	       nr_free_pages() << (PAGE_SHIFT-10), physpages << (PAGE_SHIFT-10),
 	       codesize >> 10, datasize >> 10, rosize >> 10,
 	       (init_data_size + init_code_size) >> 10, bss_size >> 10,
-	       (physpages - totalram_pages) << (PAGE_SHIFT-10),
+	       (physpages - totalram_pages - totalcma_pages) << (PAGE_SHIFT-10),
+	       totalcma_pages << (PAGE_SHIFT-10),
 #ifdef	CONFIG_HIGHMEM
 	       totalhigh_pages << (PAGE_SHIFT-10),
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
