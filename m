Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4719E28029D
	for <linux-mm@kvack.org>; Sun,  5 Jul 2015 20:17:35 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so270030988wiw.0
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 17:17:34 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id tm3si27313325wjc.126.2015.07.05.17.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Jul 2015 17:17:33 -0700 (PDT)
Received: by wiclp1 with SMTP id lp1so6643167wic.0
        for <linux-mm@kvack.org>; Sun, 05 Jul 2015 17:17:33 -0700 (PDT)
From: Nicolai Stange <nicstange@gmail.com>
Subject: [PATCH] mm/page_alloc: deferred meminit: replace rwsem with completion
Date: Mon, 06 Jul 2015 02:17:30 +0200
Message-ID: <87k2uecf6t.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 0e1cc95b4cc7
  ("mm: meminit: finish initialisation of struct pages before basic setup")
introduced a rwsem to signal completion of the initialization workers.

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

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 mm/page_alloc.c | 34 +++++++++++++++++++++++++++-------
 1 file changed, 27 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 506eac8..3886e66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -18,7 +18,9 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/interrupt.h>
-#include <linux/rwsem.h>
+#include <linux/completion.h>
+#include <linux/atomic.h>
+#include <asm/barrier.h>
 #include <linux/pagemap.h>
 #include <linux/jiffies.h>
 #include <linux/bootmem.h>
@@ -1062,7 +1064,20 @@ static void __init deferred_free_range(struct page *page,
 		__free_pages_boot_core(page, pfn, 0);
 }
 
-static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
+/* counter and completion tracking outstanding deferred_init_memmap()
+   threads */
+static atomic_t pgdat_init_n_undone __initdata;
+static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
+
+static inline void __init pgdat_init_report_one_done(void)
+{
+	/* Write barrier is paired with read barrier in
+	   page_alloc_init_late(). It makes all writes visible to
+	   readers seeing our decrement on pgdat_init_n_undone. */
+	smp_wmb();
+	if (atomic_dec_and_test(&pgdat_init_n_undone))
+		complete(&pgdat_init_all_done_comp);
+}
 
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
@@ -1079,7 +1094,7 @@ static int __init deferred_init_memmap(void *data)
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	if (first_init_pfn == ULONG_MAX) {
-		up_read(&pgdat_init_rwsem);
+		pgdat_init_report_one_done();
 		return 0;
 	}
 
@@ -1179,7 +1194,8 @@ free_range:
 
 	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
 					jiffies_to_msecs(jiffies - start));
-	up_read(&pgdat_init_rwsem);
+
+	pgdat_init_report_one_done();
 	return 0;
 }
 
@@ -1187,14 +1203,18 @@ void __init page_alloc_init_late(void)
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
+
+	/* Paired with write barrier in deferred_init_memmap(),
+	   ensures a consistent view of all its writes. */
+	smp_rmb();
 }
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
