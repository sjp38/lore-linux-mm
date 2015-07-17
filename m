Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 38770280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:22:11 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so37991581wib.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:22:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 10si19220090wjr.158.2015.07.17.05.22.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 05:22:09 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/3] mm, meminit: replace rwsem with completion
Date: Fri, 17 Jul 2015 13:22:02 +0100
Message-Id: <1437135724-20110-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1437135724-20110-1-git-send-email-mgorman@suse.de>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolai Stange <nicstange@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Nicolai Stange <nicstange@gmail.com>

Commit 0e1cc95b4cc7 ("mm: meminit: finish initialisation of struct pages
before basic setup") introduced a rwsem to signal completion of the
initialization workers.

Lockdep complains about possible recursive locking:
  =============================================
  [ INFO: possible recursive locking detected ]
  4.1.0-12802-g1dc51b8 #3 Not tainted
  ---------------------------------------------
  swapper/0/1 is trying to acquire lock:
  (pgdat_init_rwsem){++++.+},
    at: [<ffffffff8424c7fb>] page_alloc_init_late+0xc7/0xe6

  but task is already holding lock:
  (pgdat_init_rwsem){++++.+},
    at: [<ffffffff8424c772>] page_alloc_init_late+0x3e/0xe6

Replace the rwsem by a completion together with an atomic
"outstanding work counter".

[peterz@infradead.org: Barrier removal on the grounds of being pointless]
[mgorman@suse.de: Applied review feedback]
Signed-off-by: Nicolai Stange <nicstange@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 506eac8b38af..a69e78c396a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -18,7 +18,6 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/interrupt.h>
-#include <linux/rwsem.h>
 #include <linux/pagemap.h>
 #include <linux/jiffies.h>
 #include <linux/bootmem.h>
@@ -1062,7 +1061,15 @@ static void __init deferred_free_range(struct page *page,
 		__free_pages_boot_core(page, pfn, 0);
 }
 
-static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
+/* Completion tracking for deferred_init_memmap() threads */
+static atomic_t pgdat_init_n_undone __initdata;
+static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
+
+static inline void __init pgdat_init_report_one_done(void)
+{
+	if (atomic_dec_and_test(&pgdat_init_n_undone))
+		complete(&pgdat_init_all_done_comp);
+}
 
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
@@ -1079,7 +1086,7 @@ static int __init deferred_init_memmap(void *data)
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	if (first_init_pfn == ULONG_MAX) {
-		up_read(&pgdat_init_rwsem);
+		pgdat_init_report_one_done();
 		return 0;
 	}
 
@@ -1179,7 +1186,8 @@ free_range:
 
 	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
 					jiffies_to_msecs(jiffies - start));
-	up_read(&pgdat_init_rwsem);
+
+	pgdat_init_report_one_done();
 	return 0;
 }
 
@@ -1187,14 +1195,14 @@ void __init page_alloc_init_late(void)
 {
 	int nid;
 
+	/* There will be num_node_state(N_MEMORY) threads */
+	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
 	for_each_node_state(nid, N_MEMORY) {
-		down_read(&pgdat_init_rwsem);
 		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
 	}
 
 	/* Block until all are initialised */
-	down_write(&pgdat_init_rwsem);
-	up_write(&pgdat_init_rwsem);
+	wait_for_completion(&pgdat_init_all_done_comp);
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
