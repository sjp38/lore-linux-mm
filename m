Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id E84406B0275
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:43 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i1-v6so7901757ywd.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:43 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r132-v6si26801412ybc.409.2018.11.05.08.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:42 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 12/13] mm: parallelize clear_gigantic_page
Date: Mon,  5 Nov 2018 11:55:57 -0500
Message-Id: <20181105165558.11698-13-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Parallelize clear_gigantic_page, which zeroes any page size larger than
8M (e.g. 1G on x86).

Performance results (the default number of threads is 4; higher thread
counts shown for context only):

Machine:  Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 CPUs, 1T memory
Test:     Clear a range of gigantic pages (triggered via fallocate)

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

The speedups are mostly due to the fact that more threads can use more
memory bandwidth.  The loop we're stressing on the x86 chip in this test
is clear_page_erms, which tops out at a bandwidth of 2550 MiB/s with one
thread.  We get the same bandwidth per thread for 2, 4, or 8 threads,
but at 16 threads the per-thread bandwidth drops to 1420 MiB/s.

However, the performance also improves over a single thread because of
the ktask threads' NUMA awareness (ktask migrates worker threads to the
node local to the work being done).  This becomes a bigger factor as the
amount of pages to zero grows to include memory from multiple nodes, so
that speedups increase as the size increases.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/memory.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 15c417e8e31d..445d06537905 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,6 +69,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
 #include <linux/oom.h>
+#include <linux/ktask.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -4415,19 +4416,28 @@ static inline void process_huge_page(
 	}
 }
 
-static void clear_gigantic_page(struct page *page,
-				unsigned long addr,
-				unsigned int pages_per_huge_page)
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
 
 static void clear_subpage(unsigned long addr, int idx, void *arg)
@@ -4444,7 +4454,13 @@ void clear_huge_page(struct page *page,
 		~(((unsigned long)pages_per_huge_page << PAGE_SHIFT) - 1);
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
-		clear_gigantic_page(page, addr, pages_per_huge_page);
+		struct cgp_args args = {page, addr};
+		struct ktask_node node = {0, pages_per_huge_page,
+					  page_to_nid(page)};
+		DEFINE_KTASK_CTL(ctl, clear_gigantic_page_chunk, &args,
+				 KTASK_MEM_CHUNK);
+
+		ktask_run_numa(&node, 1, &ctl);
 		return;
 	}
 
-- 
2.19.1
