Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A89146B006E
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 23:36:19 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so2436039pde.20
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 20:36:19 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id rf9si17524319pbc.221.2014.10.15.20.36.17
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 20:36:18 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 2/4] (CMA_AGGRESSIVE) Add argument hibernation to function shrink_all_memory
Date: Thu, 16 Oct 2014 11:35:49 +0800
Message-ID: <1413430551-22392-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, lauraa@codeaurora.org, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>

Function shrink_all_memory try to free `nr_to_reclaim' of memory.
CMA_AGGRESSIVE_SHRINK function will call this functon to free `nr_to_reclaim' of
memory.  It need different scan_control with current caller function
hibernate_preallocate_memory.

If hibernation is true, the caller is hibernate_preallocate_memory.
if not, the caller is CMA alloc function.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/swap.h    |  3 ++-
 kernel/power/snapshot.c |  2 +-
 mm/vmscan.c             | 19 +++++++++++++------
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 37a585b..9f2cb43 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -335,7 +335,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
-extern unsigned long shrink_all_memory(unsigned long nr_pages);
+extern unsigned long shrink_all_memory(unsigned long nr_pages,
+				       bool hibernation);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 791a618..a00fc35 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1657,7 +1657,7 @@ int hibernate_preallocate_memory(void)
 	 * NOTE: If this is not done, performance will be hurt badly in some
 	 * test cases.
 	 */
-	shrink_all_memory(saveable - size);
+	shrink_all_memory(saveable - size, true);
 
 	/*
 	 * The number of saveable pages in memory was too high, so apply some
diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..fdcfa30 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3404,7 +3404,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
-#ifdef CONFIG_HIBERNATION
+#if defined CONFIG_HIBERNATION || defined CONFIG_CMA_AGGRESSIVE
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
  * freed pages.
@@ -3413,22 +3413,29 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
  * LRU order by reclaiming preferentially
  * inactive > active > active referenced > active mapped
  */
-unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
+unsigned long shrink_all_memory(unsigned long nr_to_reclaim, bool hibernation)
 {
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
-		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.priority = DEF_PRIORITY,
-		.may_writepage = 1,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.hibernation_mode = 1,
 	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
 
+	if (hibernation) {
+		sc.hibernation_mode = 1;
+		sc.may_writepage = 1;
+		sc.gfp_mask = GFP_HIGHUSER_MOVABLE;
+	} else {
+		sc.hibernation_mode = 0;
+		sc.may_writepage = !laptop_mode;
+		sc.gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_HIGHMEM;
+	}
+
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
@@ -3442,7 +3449,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	return nr_reclaimed;
 }
-#endif /* CONFIG_HIBERNATION */
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
