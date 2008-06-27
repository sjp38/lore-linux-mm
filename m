Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5RFJBS3009868
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:19:12 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5RFJB4x177532
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 09:19:11 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5RFJAjA028462
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 09:19:11 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 27 Jun 2008 20:49:06 +0530
Message-Id: <20080627151906.31664.7247.sendpatchset@balbir-laptop>
In-Reply-To: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
Subject: [RFC 5/5] Memory controller soft limit reclaim on contention
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Setup the soft limit control data structures in the memory controller. The
prio_heap data structure is used. Memory contention is detected in
__alloc_pages_internal(). Prior to calling try_to_free_pages(), the code
now tries to free memory from memory groups above their soft limit. This
happens in the mem_cgroup_reclaim_on_contention() routine. This routine
pulls out cgroups from a max heap (ordered by the size by which they exceed
their soft limit) and reclaims from them.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/memcontrol.h  |    7 +++
 include/linux/res_counter.h |   16 ++++++
 mm/memcontrol.c             |  101 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c             |    9 +++
 4 files changed, 132 insertions(+), 1 deletion(-)

diff -puN mm/memcontrol.c~memory-controller-soft-limit-reclaim-on-contention mm/memcontrol.c
--- linux-2.6.26-rc5/mm/memcontrol.c~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/memcontrol.c	2008-06-27 20:43:10.000000000 +0530
@@ -25,6 +25,7 @@
 #include <linux/page-flags.h>
 #include <linux/backing-dev.h>
 #include <linux/bit_spinlock.h>
+#include <linux/prio_heap.h>
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
@@ -39,6 +40,18 @@
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 static struct kmem_cache *page_cgroup_cache __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
+#define MEM_CGROUP_HEAP_SHIFT		7
+#define MEM_CGROUP_HEAP_SIZE		(1 << MEM_CGROUP_HEAP_SHIFT)
+
+/*
+ * Create a heap of memory controller structures. The heap is reverse
+ * sorted by size. This heap is used for implementing soft limits. Our
+ * current heap implementation does not allow dynamic heap updates, but
+ * eventually, the costliest controller (over it's soft limit should
+ * be on top of the heap).
+ */
+struct ptr_heap mem_cgroup_heap;
+spinlock_t mem_cgroup_heap_lock;	/* One more lock for a global heap */
 
 /*
  * Statistics for memory cgroup.
@@ -129,6 +142,7 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	int	on_heap;	/* Are we on the soft limit group */
 	/*
 	 * statistics.
 	 */
@@ -590,6 +604,20 @@ static int mem_cgroup_charge_common(stru
 	}
 	page_assign_page_cgroup(page, pc);
 
+	if (!res_counter_check_under_soft_limit(&mem->res)) {
+		spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
+		if (!mem->on_heap) {
+			struct mem_cgroup *old_mem;
+
+			old_mem = heap_insert(&mem_cgroup_heap, mem,
+						HEAP_REP_LEAF);
+			mem->on_heap = 1;
+			if (old_mem)
+				old_mem->on_heap = 0;
+		}
+		spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
+	}
+
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);
 	__mem_cgroup_add_list(mz, pc);
@@ -715,6 +743,65 @@ void mem_cgroup_uncharge_cache_page(stru
 }
 
 /*
+ * When the soft limit is exceeded, look through the heap and start
+ * reclaiming from all groups over thier soft limit
+ */
+unsigned long mem_cgroup_reclaim_on_contention(gfp_t gfp_mask)
+{
+	unsigned long nr_reclaimed = 0;
+	struct mem_cgroup *mem;
+	unsigned long flags;
+	int i, count;
+
+
+	for (i = MEM_CGROUP_HEAP_SHIFT; i >= 0; i--) {
+		count = MEM_CGROUP_HEAP_SIZE >> i;
+		mem = mem_cgroup_from_task(current);
+
+		spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
+		if (!res_counter_check_under_soft_limit(&mem->res)) {
+			/*
+			 * The current task might already be over it's soft
+			 * limit and trying to aggressively grow. We check to
+			 * see if it the memory group associated with the
+			 * current task is on the heap when the current group
+			 * is over it's soft limit. If not, we add it
+			 */
+			if (!mem->on_heap) {
+				struct mem_cgroup *old_mem;
+
+				old_mem = heap_insert(&mem_cgroup_heap, mem,
+							HEAP_REP_LEAF);
+				mem->on_heap = 1;
+				if (old_mem)
+					old_mem->on_heap = 0;
+			}
+		}
+
+		while (count-- &&
+			((mem = heap_delete_max(&mem_cgroup_heap)) != NULL)) {
+			BUG_ON(!mem->on_heap);
+			spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
+			nr_reclaimed += try_to_free_mem_cgroup_pages(mem,
+								gfp_mask);
+			cond_resched();
+			spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
+			mem->on_heap = 0;
+			/*
+			 * What should be the basis of breaking out?
+			 */
+			if (nr_reclaimed)
+				goto done;
+		}
+done:
+		spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
+		if (!mem)
+			break;
+	}
+	return nr_reclaimed;
+}
+
+/*
  * Before starting migration, account against new page.
  */
 int mem_cgroup_prepare_migration(struct page *page, struct page *newpage)
@@ -1052,6 +1139,17 @@ static void mem_cgroup_free(struct mem_c
 		vfree(mem);
 }
 
+static int mem_cgroup_compare_soft_limits(void *p1, void *p2)
+{
+	struct mem_cgroup *mem1 = (struct mem_cgroup *)p1;
+	struct mem_cgroup *mem2 = (struct mem_cgroup *)p2;
+	unsigned long long delta1, delta2;
+
+	delta1 = res_counter_soft_limit_delta(&mem1->res);
+	delta2 = res_counter_soft_limit_delta(&mem2->res);
+
+	return delta1 > delta2;
+}
 
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
@@ -1062,6 +1160,9 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
+		heap_init(&mem_cgroup_heap, MEM_CGROUP_HEAP_SIZE, GFP_KERNEL,
+				mem_cgroup_compare_soft_limits);
+		spin_lock_init(&mem_cgroup_heap_lock);
 	} else {
 		mem = mem_cgroup_alloc();
 		if (!mem)
diff -puN include/linux/memcontrol.h~memory-controller-soft-limit-reclaim-on-contention include/linux/memcontrol.h
--- linux-2.6.26-rc5/include/linux/memcontrol.h~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
+++ linux-2.6.26-rc5-balbir/include/linux/memcontrol.h	2008-06-27 20:43:10.000000000 +0530
@@ -38,6 +38,7 @@ extern void mem_cgroup_move_lists(struct
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 extern int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask);
+extern unsigned long mem_cgroup_reclaim_on_contention(gfp_t gfp_mask);
 
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
@@ -163,6 +164,12 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static inline unsigned long mem_cgroup_reclaim_on_contention(gfp_t gfp_mask)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff -puN mm/vmscan.c~memory-controller-soft-limit-reclaim-on-contention mm/vmscan.c
diff -puN mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention mm/page_alloc.c
--- linux-2.6.26-rc5/mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
+++ linux-2.6.26-rc5-balbir/mm/page_alloc.c	2008-06-27 20:43:10.000000000 +0530
@@ -1669,7 +1669,14 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	/*
+	 * First try to reclaim from memory control groups that have
+	 * exceeded their soft limit
+	 */
+	did_some_progress = mem_cgroup_reclaim_on_contention(gfp_mask);
+	if (!did_some_progress)
+		did_some_progress = try_to_free_pages(zonelist, order,
+							gfp_mask);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
diff -puN kernel/res_counter.c~memory-controller-soft-limit-reclaim-on-contention kernel/res_counter.c
diff -puN include/linux/res_counter.h~memory-controller-soft-limit-reclaim-on-contention include/linux/res_counter.h
--- linux-2.6.26-rc5/include/linux/res_counter.h~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
+++ linux-2.6.26-rc5-balbir/include/linux/res_counter.h	2008-06-27 20:43:10.000000000 +0530
@@ -163,6 +163,22 @@ static inline bool res_counter_check_und
 	return ret;
 }
 
+/*
+ * Return the delta between soft_limit and usage
+ */
+static inline
+unsigned long long res_counter_soft_limit_delta(struct res_counter *cnt)
+{
+	unsigned long long ret, delta;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	delta = cnt->usage - cnt->soft_limit;
+	ret = delta > 0 ? delta : 0;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
