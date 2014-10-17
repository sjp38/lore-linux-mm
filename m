Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8DF6B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:28:54 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so490658pdi.10
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 02:28:54 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id te6si580252pbc.227.2014.10.17.02.28.49
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 02:28:53 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH v2 2/4] (CMA_AGGRESSIVE) Add new function shrink_all_memory_for_cma
Date: Fri, 17 Oct 2014 17:28:04 +0800
Message-ID: <1413538084-15743-1-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1471435.6q4YYkTopF@vostro.rjw.lan>
References: <1471435.6q4YYkTopF@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, lauraa@codeaurora.org, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>

Update this patch according to the comments from Rafael.

Function shrink_all_memory_for_cma try to free `nr_to_reclaim' of memory.
CMA aggressive shrink function will call this functon to free `nr_to_reclaim' of
memory.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/vmscan.c | 58 +++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 43 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..658dc8d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3404,6 +3404,28 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
+#if defined CONFIG_HIBERNATION || defined CONFIG_CMA_AGGRESSIVE
+static unsigned long __shrink_all_memory(struct scan_control *sc)
+{
+	struct reclaim_state reclaim_state;
+	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc->gfp_mask);
+	struct task_struct *p = current;
+	unsigned long nr_reclaimed;
+
+	p->flags |= PF_MEMALLOC;
+	lockdep_set_current_reclaim_state(sc->gfp_mask);
+	reclaim_state.reclaimed_slab = 0;
+	p->reclaim_state = &reclaim_state;
+
+	nr_reclaimed = do_try_to_free_pages(zonelist, sc);
+
+	p->reclaim_state = NULL;
+	lockdep_clear_current_reclaim_state();
+	p->flags &= ~PF_MEMALLOC;
+
+	return nr_reclaimed;
+}
+
 #ifdef CONFIG_HIBERNATION
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
@@ -3415,7 +3437,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
@@ -3425,24 +3446,31 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.may_swap = 1,
 		.hibernation_mode = 1,
 	};
-	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
-	struct task_struct *p = current;
-	unsigned long nr_reclaimed;
-
-	p->flags |= PF_MEMALLOC;
-	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	return __shrink_all_memory(&sc);
+}
+#endif /* CONFIG_HIBERNATION */
 
-	p->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
-	p->flags &= ~PF_MEMALLOC;
+#ifdef CONFIG_CMA_AGGRESSIVE
+/*
+ * Try to free `nr_to_reclaim' of memory, system-wide, for CMA aggressive
+ * shrink function.
+ */
+void shrink_all_memory_for_cma(unsigned long nr_to_reclaim)
+{
+	struct scan_control sc = {
+		.nr_to_reclaim = nr_to_reclaim,
+		.gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_HIGHMEM,
+		.priority = DEF_PRIORITY,
+		.may_writepage = !laptop_mode,
+		.may_unmap = 1,
+		.may_swap = 1,
+	};
 
-	return nr_reclaimed;
+	__shrink_all_memory(&sc);
 }
-#endif /* CONFIG_HIBERNATION */
+#endif /* CONFIG_CMA_AGGRESSIVE */
+#endif /* CONFIG_HIBERNATION || CONFIG_CMA_AGGRESSIVE */
 
 /* It's optimal to keep kswapds on the same CPUs as their memory, but
    not required for correctness.  So if the last cpu in a node goes
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
