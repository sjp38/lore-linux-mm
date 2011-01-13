Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16CE76B00E8
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:04:18 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/5] Add per cgroup reclaim watermarks.
Date: Thu, 13 Jan 2011 14:00:32 -0800
Message-Id: <1294956035-12081-3-git-send-email-yinghan@google.com>
In-Reply-To: <1294956035-12081-1-git-send-email-yinghan@google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The per cgroup kswapd is invoked when the cgroup's free memory (limit - usage)
is less than a threshold--low_wmark. Then the kswapd thread starts to reclaim
pages in a priority loop similar to global algorithm. The kswapd is done if the
free memory is above a threshold--high_wmark.

The per cgroup background reclaim is based on the per cgroup LRU and also adds
per cgroup watermarks. There are two watermarks including "low_wmark" and
"high_wmark", and they are calculated based on the limit_in_bytes(hard_limit)
for each cgroup. Each time the hard_limit is changed, the corresponding wmarks
are re-calculated. Since memory controller charges only user pages, there is
no need for a "min_wmark". The current calculation of wmarks is a function of
"memory.min_free_kbytes" which could be adjusted by writing different values
into the new api. This is added mainly for debugging purpose.

Change log v2...v1:
1. Remove the res_counter_charge on wmark due to performance concern.
2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate commit.
3. Calculate the min_free_kbytes automatically based on the limit_in_bytes.
4. make the wmark to be consistant with core VM which checks the free pages
instead of usage.
5. changed wmark to be boolean

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h  |    1 +
 include/linux/res_counter.h |   83 +++++++++++++++++++++++++++++++++++++++++++
 kernel/res_counter.c        |    6 +++
 mm/memcontrol.c             |   73 +++++++++++++++++++++++++++++++++++++
 4 files changed, 163 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3433784..80a605f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -93,6 +93,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..10b7e59 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -39,6 +39,15 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
+	 * the limit that reclaim triggers. it is the free count
+	 * (limit - usage)
+	 */
+	unsigned long long low_wmark_limit;
+	/*
+	 * the limit that reclaim stops. it is the free count
+	 */
+	unsigned long long high_wmark_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -55,6 +64,9 @@ struct res_counter {
 
 #define RESOURCE_MAX (unsigned long long)LLONG_MAX
 
+#define CHARGE_WMARK_LOW	0x02
+#define CHARGE_WMARK_HIGH	0x04
+
 /**
  * Helpers to interact with userspace
  * res_counter_read_u64() - returns the value of the specified member.
@@ -92,6 +104,8 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_WMARK_LIMIT,
+	RES_HIGH_WMARK_LIMIT
 };
 
 /*
@@ -145,6 +159,28 @@ static inline bool res_counter_soft_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline bool
+res_counter_high_wmark_limit_check_locked(struct res_counter *cnt)
+{
+	unsigned long long free = cnt->limit - cnt->usage;
+
+	if (free <= cnt->high_wmark_limit)
+		return false;
+
+	return true;
+}
+
+static inline bool
+res_counter_low_wmark_limit_check_locked(struct res_counter *cnt)
+{
+	unsigned long long free = cnt->limit - cnt->usage;
+
+	if (free <= cnt->low_wmark_limit)
+		return false;
+
+	return true;
+}
+
 /**
  * Get the difference between the usage and the soft limit
  * @cnt: The counter
@@ -193,6 +229,30 @@ static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
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
@@ -238,4 +298,27 @@ res_counter_set_soft_limit(struct res_counter *cnt,
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
index c7eaa37..f68bd63 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -19,6 +19,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
 	counter->soft_limit = RESOURCE_MAX;
+	counter->low_wmark_limit = 0;
+	counter->high_wmark_limit = 0;
 	counter->parent = parent;
 }
 
@@ -103,6 +105,10 @@ res_counter_member(struct res_counter *counter, int member)
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
index f6e0987..5508d94 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -290,6 +290,7 @@ struct mem_cgroup {
 	spinlock_t pcp_counter_lock;
 
 	wait_queue_head_t *kswapd_wait;
+	unsigned long min_free_kbytes;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -378,6 +379,7 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(void);
+static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -818,6 +820,45 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+void setup_per_memcg_wmarks(struct mem_cgroup *mem)
+{
+	unsigned long min_free_kbytes;
+
+	min_free_kbytes = get_min_free_kbytes(mem);
+	if (min_free_kbytes == 0) {
+		u64 limit;
+
+		limit = mem_cgroup_get_limit(mem);
+		res_counter_set_low_wmark_limit(&mem->res, limit);
+		res_counter_set_high_wmark_limit(&mem->res, limit);
+	} else {
+		unsigned long long low_wmark, high_wmark;
+		unsigned long long tmp = min_free_kbytes << 10;
+
+		low_wmark = tmp + (tmp >> 2);
+		high_wmark = tmp + (tmp >> 1);
+		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
+		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
+	}
+}
+
+void init_per_memcg_wmarks(struct mem_cgroup *mem)
+{
+	unsigned long min_free_kbytes;
+	u64 limit_kbytes;
+
+	limit_kbytes = mem_cgroup_get_limit(mem) >> 10;
+	min_free_kbytes = int_sqrt(limit_kbytes * 16);
+	if (min_free_kbytes < 128)
+		min_free_kbytes = 128;
+	if (min_free_kbytes > 65536)
+		min_free_kbytes = 65536;
+
+	mem->min_free_kbytes = min_free_kbytes;
+	setup_per_memcg_wmarks(mem);
+
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -1403,6 +1444,22 @@ unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
 	return value;
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
@@ -3310,6 +3367,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			else
 				memcg->memsw_is_minimum = false;
 		}
+		init_per_memcg_wmarks(memcg);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -3369,6 +3427,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 			else
 				memcg->memsw_is_minimum = false;
 		}
+		init_per_memcg_wmarks(memcg);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -4744,6 +4803,19 @@ static void __init enable_swap_cgroup(void)
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
@@ -4834,6 +4906,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
+	mem->min_free_kbytes = 0;
 	mutex_init(&mem->thresholds_lock);
 	return &mem->css;
 free_out:
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
