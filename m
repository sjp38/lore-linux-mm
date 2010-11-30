Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E88C6B0088
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:50:26 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/4] Add per cgroup reclaim watermarks.
Date: Mon, 29 Nov 2010 22:49:43 -0800
Message-Id: <1291099785-5433-3-git-send-email-yinghan@google.com>
In-Reply-To: <1291099785-5433-1-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The per cgroup kswapd is invoked at mem_cgroup_charge when the cgroup's memory
usage above a threshold--low_wmark. Then the kswapd thread starts to reclaim
pages in a priority loop similar to global algorithm. The kswapd is done if the
memory usage below a threshold--high_wmark.

The per cgroup background reclaim is based on the per cgroup LRU and also adds
per cgroup watermarks. There are two watermarks including "low_wmark" and
"high_wmark", and they are calculated based on the limit_in_bytes(hard_limit)
for each cgroup. Each time the hard_limit is change, the corresponding wmarks
are re-calculated. Since memory controller charges only user pages, there is
no need for a "min_wmark". The current calculation of wmarks is a function of
"memory.min_free_kbytes" which could be adjusted by writing different values
into the new api. This is added mainly for debugging purpose.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h  |    1 +
 include/linux/res_counter.h |   88 ++++++++++++++++++++++++++++++-
 kernel/res_counter.c        |   26 ++++++++--
 mm/memcontrol.c             |  123 +++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                 |   10 ++++
 5 files changed, 238 insertions(+), 10 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 159a076..90fe7fe 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -76,6 +76,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..eed12c5 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -39,6 +39,16 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
+	 * the limit that reclaim triggers. TODO: res_counter in mem
+	 * or wmark_limit.
+	 */
+	unsigned long long low_wmark_limit;
+	/*
+	 * the limit that reclaim stops. TODO: res_counter in mem or
+	 * wmark_limit.
+	 */
+	unsigned long long high_wmark_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -55,6 +65,10 @@ struct res_counter {
 
 #define RESOURCE_MAX (unsigned long long)LLONG_MAX
 
+#define CHARGE_WMARK_MIN	0x01
+#define CHARGE_WMARK_LOW	0x02
+#define CHARGE_WMARK_HIGH	0x04
+
 /**
  * Helpers to interact with userspace
  * res_counter_read_u64() - returns the value of the specified member.
@@ -92,6 +106,8 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_WMARK_LIMIT,
+	RES_HIGH_WMARK_LIMIT
 };
 
 /*
@@ -112,9 +128,10 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
  */
 
 int __must_check res_counter_charge_locked(struct res_counter *counter,
-		unsigned long val);
+		unsigned long val, int charge_flags);
 int __must_check res_counter_charge(struct res_counter *counter,
-		unsigned long val, struct res_counter **limit_fail_at);
+		unsigned long val, int charge_flags,
+		struct res_counter **limit_fail_at);
 
 /*
  * uncharge - tell that some portion of the resource is released
@@ -145,6 +162,24 @@ static inline bool res_counter_soft_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline bool
+res_counter_high_wmark_limit_check_locked(struct res_counter *cnt)
+{
+	if (cnt->usage < cnt->high_wmark_limit)
+		return true;
+
+	return false;
+}
+
+static inline bool
+res_counter_low_wmark_limit_check_locked(struct res_counter *cnt)
+{
+	if (cnt->usage < cnt->low_wmark_limit)
+		return true;
+
+	return false;
+}
+
 /**
  * Get the difference between the usage and the soft limit
  * @cnt: The counter
@@ -193,6 +228,30 @@ static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
 	return ret;
 }
 
+static inline bool
+res_counter_check_under_low_wmark_limit(struct res_counter *cnt)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_low_wmark_limit_check_locked(cnt);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
+static inline bool
+res_counter_check_under_high_wmark_limit(struct res_counter *cnt)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_high_wmark_limit_check_locked(cnt);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
@@ -220,6 +279,8 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
 	spin_lock_irqsave(&cnt->lock, flags);
 	if (cnt->usage <= limit) {
 		cnt->limit = limit;
+		cnt->low_wmark_limit = limit;
+		cnt->high_wmark_limit = limit;
 		ret = 0;
 	}
 	spin_unlock_irqrestore(&cnt->lock, flags);
@@ -238,4 +299,27 @@ res_counter_set_soft_limit(struct res_counter *cnt,
 	return 0;
 }
 
+static inline int
+res_counter_set_high_wmark_limit(struct res_counter *cnt,
+				unsigned long long wmark_limit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->high_wmark_limit = wmark_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
+static inline int
+res_counter_set_low_wmark_limit(struct res_counter *cnt,
+				unsigned long long wmark_limit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->low_wmark_limit = wmark_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index c7eaa37..a524349 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -19,12 +19,26 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
 	counter->soft_limit = RESOURCE_MAX;
+	counter->low_wmark_limit = RESOURCE_MAX;
+	counter->high_wmark_limit = RESOURCE_MAX;
 	counter->parent = parent;
 }
 
-int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
+int res_counter_charge_locked(struct res_counter *counter, unsigned long val,
+				int charge_flags)
 {
-	if (counter->usage + val > counter->limit) {
+	unsigned long long limit = 0;
+
+	if (charge_flags & CHARGE_WMARK_LOW)
+		limit = counter->low_wmark_limit;
+
+	if (charge_flags & CHARGE_WMARK_HIGH)
+		limit = counter->high_wmark_limit;
+
+	if (charge_flags & CHARGE_WMARK_MIN)
+		limit = counter->limit;
+
+	if (counter->usage + val > limit) {
 		counter->failcnt++;
 		return -ENOMEM;
 	}
@@ -36,7 +50,7 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 }
 
 int res_counter_charge(struct res_counter *counter, unsigned long val,
-			struct res_counter **limit_fail_at)
+			int charge_flags, struct res_counter **limit_fail_at)
 {
 	int ret;
 	unsigned long flags;
@@ -46,7 +60,7 @@ int res_counter_charge(struct res_counter *counter, unsigned long val,
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
-		ret = res_counter_charge_locked(c, val);
+		ret = res_counter_charge_locked(c, val, charge_flags);
 		spin_unlock(&c->lock);
 		if (ret < 0) {
 			*limit_fail_at = c;
@@ -103,6 +117,10 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return &counter->soft_limit;
+	case RES_LOW_WMARK_LIMIT:
+		return &counter->low_wmark_limit;
+	case RES_HIGH_WMARK_LIMIT:
+		return &counter->high_wmark_limit;
 	};
 
 	BUG();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dca3590..a0c6ed9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -265,6 +265,7 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 	wait_queue_head_t *kswapd_wait;
+	unsigned long min_free_kbytes;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -370,6 +371,7 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
+static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -796,6 +798,32 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+void setup_per_memcg_wmarks(struct mem_cgroup *mem)
+{
+	u64 limit;
+	unsigned long min_free_kbytes;
+
+	min_free_kbytes = get_min_free_kbytes(mem);
+	limit = mem_cgroup_get_limit(mem);
+	if (min_free_kbytes == 0) {
+		res_counter_set_low_wmark_limit(&mem->res, limit);
+		res_counter_set_high_wmark_limit(&mem->res, limit);
+	} else {
+		unsigned long page_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+		unsigned long lowmem_pages = 2048;
+		unsigned long low_wmark, high_wmark;
+		u64 tmp;
+
+		tmp = (u64)page_min * limit;
+		do_div(tmp, lowmem_pages);
+
+		low_wmark = tmp + (tmp >> 1);
+		high_wmark = tmp + (tmp >> 2);
+		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
+		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
+	}
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -1148,6 +1176,22 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
 	return swappiness;
 }
 
+static unsigned long get_min_free_kbytes(struct mem_cgroup *memcg)
+{
+	struct cgroup *cgrp = memcg->css.cgroup;
+	unsigned long min_free_kbytes;
+
+	/* root ? */
+	if (cgrp == NULL || cgrp->parent == NULL)
+		return 0;
+
+	spin_lock(&memcg->reclaim_param_lock);
+	min_free_kbytes = memcg->min_free_kbytes;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	return min_free_kbytes;
+}
+
 static void mem_cgroup_start_move(struct mem_cgroup *mem)
 {
 	int cpu;
@@ -1844,12 +1888,13 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	unsigned long flags = 0;
 	int ret;
 
-	ret = res_counter_charge(&mem->res, csize, &fail_res);
+	ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_MIN, &fail_res);
 
 	if (likely(!ret)) {
 		if (!do_swap_account)
 			return CHARGE_OK;
-		ret = res_counter_charge(&mem->memsw, csize, &fail_res);
+		ret = res_counter_charge(&mem->memsw, csize, CHARGE_WMARK_MIN,
+					&fail_res);
 		if (likely(!ret))
 			return CHARGE_OK;
 
@@ -3733,6 +3778,37 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 mem_cgroup_min_free_read(struct cgroup *cgrp, struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+
+	return get_min_free_kbytes(memcg);
+}
+
+static int mem_cgroup_min_free_write(struct cgroup *cgrp, struct cftype *cfg,
+				     u64 val)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *parent;
+
+	if (cgrp->parent == NULL)
+		return -EINVAL;
+
+	parent = mem_cgroup_from_cont(cgrp->parent);
+
+	cgroup_lock();
+
+	spin_lock(&memcg->reclaim_param_lock);
+	memcg->min_free_kbytes = val;
+	spin_unlock(&memcg->reclaim_param_lock);
+
+	cgroup_unlock();
+
+	setup_per_memcg_wmarks(memcg);
+	return 0;
+
+}
+
 static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 {
 	struct mem_cgroup_threshold_ary *t;
@@ -4024,6 +4100,21 @@ static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	mutex_unlock(&memcg_oom_mutex);
 }
 
+static int mem_cgroup_wmark_read(struct cgroup *cgrp,
+	struct cftype *cft,  struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+	unsigned long low_wmark, high_wmark;
+
+	low_wmark = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
+	high_wmark = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
+
+	cb->fill(cb, "memcg_low_wmark", low_wmark);
+	cb->fill(cb, "memcg_high_wmark", high_wmark);
+
+	return 0;
+}
+
 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
 	struct cftype *cft,  struct cgroup_map_cb *cb)
 {
@@ -4127,6 +4218,15 @@ static struct cftype mem_cgroup_files[] = {
 		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
+	{
+		.name = "min_free_kbytes",
+		.write_u64 = mem_cgroup_min_free_write,
+		.read_u64 = mem_cgroup_min_free_read,
+	},
+	{
+		.name = "reclaim_wmarks",
+		.read_map = mem_cgroup_wmark_read,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -4308,6 +4408,19 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
+				int charge_flags)
+{
+	long ret = 0;
+
+	if (charge_flags & CHARGE_WMARK_LOW)
+		ret = res_counter_check_under_low_wmark_limit(&mem->res);
+	if (charge_flags & CHARGE_WMARK_HIGH)
+		ret = res_counter_check_under_high_wmark_limit(&mem->res);
+
+	return ret;
+}
+
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
@@ -4450,10 +4563,12 @@ static int mem_cgroup_do_precharge(unsigned long count)
 		 * are still under the same cgroup_mutex. So we can postpone
 		 * css_get().
 		 */
-		if (res_counter_charge(&mem->res, PAGE_SIZE * count, &dummy))
+		if (res_counter_charge(&mem->res, PAGE_SIZE * count,
+					CHARGE_WMARK_MIN, &dummy))
 			goto one_by_one;
 		if (do_swap_account && res_counter_charge(&mem->memsw,
-						PAGE_SIZE * count, &dummy)) {
+						PAGE_SIZE * count,
+						CHARGE_WMARK_MIN, &dummy)) {
 			res_counter_uncharge(&mem->res, PAGE_SIZE * count);
 			goto one_by_one;
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e08005e..6d5702b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -46,6 +46,8 @@
 
 #include <linux/swapops.h>
 
+#include <linux/res_counter.h>
+
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -2127,11 +2129,19 @@ static int sleeping_prematurely(struct kswapd *kswapd, int order,
 {
 	int i;
 	pg_data_t *pgdat = kswapd->kswapd_pgdat;
+	struct mem_cgroup *mem = kswapd->kswapd_mem;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return 1;
 
+	if (mem) {
+		if (!mem_cgroup_watermark_ok(kswapd->kswapd_mem,
+						CHARGE_WMARK_HIGH))
+			return 1;
+		return 0;
+	}
+
 	/* If after HZ/10, a zone is below the high mark, it's premature */
 	for (i = 0; i < pgdat->nr_zones; i++) {
 		struct zone *zone = pgdat->node_zones + i;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
