Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B78F6440941
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 18:16:11 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k3so123280707ita.4
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 15:16:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v20si3382975ite.0.2017.07.14.15.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 15:16:11 -0700 (PDT)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 5/6] mm: parallelize clear_gigantic_page
Date: Fri, 14 Jul 2017 15:16:12 -0700
Message-Id: <1500070573-3948-6-git-send-email-daniel.m.jordan@oracle.com>
In-Reply-To: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
References: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Parallelize clear_gigantic_page, which zeroes any page size larger than
8M (e.g. 1G on x86 or 2G on SPARC).

Performance results (the default number of threads is 4; higher thread
counts shown for context only):

Machine: SPARC T7-4, 1024 cpus, 504G memory
Test:    Clear a range of gigantic pages

nthread   speedup   size (GiB)   min time (s)   stdev
      1                     50           7.77    0.02
      2     1.97x           50           3.95    0.04
      4     3.85x           50           2.02    0.05
      8     6.27x           50           1.24    0.10
     16     9.84x           50           0.79    0.06

      1                    100          15.50    0.07
      2     1.91x          100           8.10    0.05
      4     3.48x          100           4.45    0.07
      8     5.18x          100           2.99    0.05
     16     7.79x          100           1.99    0.12

      1                    200          31.03    0.15
      2     1.88x          200          16.47    0.02
      4     3.37x          200           9.20    0.14
      8     5.16x          200           6.01    0.19
     16     7.04x          200           4.41    0.06

Machine:  Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 cpus, 1T memory
Test:    Clear a range of gigantic pages

nthread   speedup   size (GiB)   min time (s)   stdev
      1                    100          41.13    0.03
      2     2.03x          100          20.26    0.14
      4     4.28x          100           9.62    0.09
      8     8.39x          100           4.90    0.05
     16    10.44x          100           3.94    0.03

      1                    200          89.68    0.35
      2     2.21x          200          40.64    0.18
      4     4.64x          200          19.33    0.32
      8     8.99x          200           9.98    0.04
     16    11.27x          200           7.96    0.04

      1                    400         188.20    1.57
      2     2.30x          400          81.84    0.09
      4     4.63x          400          40.62    0.26
      8     8.92x          400          21.09    0.50
     16    11.78x          400          15.97    0.25

      1                    800         434.91    1.81
      2     2.54x          800         170.97    1.46
      4     4.98x          800          87.38    1.91
      8    10.15x          800          42.86    2.59
     16    12.99x          800          33.48    0.83

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/memory.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index bb11c47..073745f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -68,6 +68,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/ktask.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -4294,27 +4295,45 @@ void __might_fault(const char *file, int line)
 #endif
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
-static void clear_gigantic_page(struct page *page,
-				unsigned long addr,
-				unsigned int pages_per_huge_page)
+
+struct cgp_args {
+	struct page	*base_page;
+	unsigned long	addr;
+};
+
+static int clear_gigantic_page_chunk(unsigned long start, unsigned long end,
+				     struct cgp_args *args)
 {
-	int i;
-	struct page *p = page;
+	struct page *base_page = args->base_page;
+	struct page *p = base_page;
+	unsigned long addr = args->addr;
+	unsigned long i;
 
 	might_sleep();
-	for (i = 0; i < pages_per_huge_page;
-	     i++, p = mem_map_next(p, page, i)) {
+	for (i = start; i < end; ++i) {
 		cond_resched();
 		clear_user_highpage(p, addr + i * PAGE_SIZE);
+
+		p = mem_map_next(p, base_page, i);
 	}
+
+	return KTASK_RETURN_SUCCESS;
 }
+
 void clear_huge_page(struct page *page,
 		     unsigned long addr, unsigned int pages_per_huge_page)
 {
 	int i;
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
-		clear_gigantic_page(page, addr, pages_per_huge_page);
+		struct cgp_args args = {page, addr};
+		struct ktask_node node = {0, pages_per_huge_page,
+					  page_to_nid(page)};
+		DEFINE_KTASK_CTL_RANGE(ctl, clear_gigantic_page_chunk, &args,
+				       KTASK_BPGS_MINCHUNK, GFP_KERNEL, 0);
+
+		ktask_run_numa(&node, 1, &ctl);
+
 		return;
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
