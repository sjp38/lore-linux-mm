Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12726900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 19:24:46 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V5 02/10] Add per memcg reclaim watermarks
Date: Fri, 15 Apr 2011 16:23:27 -0700
Message-Id: <1302909815-4362-3-git-send-email-yinghan@google.com>
In-Reply-To: <1302909815-4362-1-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
until the usage is lower than the high_wmark.

Each watermark is calculated based on the hard_limit(limit_in_bytes) for each
memcg. Each time the hard_limit is changed, the corresponding wmarks are
re-calculated. Since memory controller charges only user pages, there is
no need for a "min_wmark". The current calculation of wmarks is based on
individual tunable low/high_wmark_distance, which are set to 0 by default.

changelog v5..v4:
1. rename res_counter_low_wmark_limit_locked().
2. rename res_counter_high_wmark_limit_locked().

changelog v4..v3:
1. remove legacy comments
2. rename the res_counter_check_under_high_wmark_limit
3. replace the wmark_ratio per-memcg by individual tunable for both wmarks.
4. add comments on low/high_wmark
5. add individual tunables for low/high_wmarks and remove wmark_ratio
6. replace the mem_cgroup_get_limit() call by res_count_read_u64(). The first
one returns large value w/ swapon.

changelog v3..v2:
1. Add VM_BUG_ON() on couple of places.
2. Remove the spinlock on the min_free_kbytes since the consequence of reading
stale data.
3. Remove the "min_free_kbytes" API and replace it with wmark_ratio based on
hard_limit.

changelog v2..v1:
1. Remove the res_counter_charge on wmark due to performance concern.
2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate commit.
3. Calculate the min_free_kbytes automatically based on the limit_in_bytes.
4. make the wmark to be consistant with core VM which checks the free pages
instead of usage.
5. changed wmark to be boolean

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h  |    1 +
 include/linux/res_counter.h |   78 +++++++++++++++++++++++++++++++++++++++++++
 kernel/res_counter.c        |    6 +++
 mm/memcontrol.c             |   48 ++++++++++++++++++++++++++
 4 files changed, 133 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5a5ce70..3ece36d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -82,6 +82,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index c9d625c..669f199 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -39,6 +39,14 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
+	 * the limit that reclaim triggers.
+	 */
+	unsigned long long low_wmark_limit;
+	/*
+	 * the limit that reclaim stops.
+	 */
+	unsigned long long high_wmark_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -55,6 +63,9 @@ struct res_counter {
 
 #define RESOURCE_MAX (unsigned long long)LLONG_MAX
 
+#define CHARGE_WMARK_LOW	0x01
+#define CHARGE_WMARK_HIGH	0x02
+
 /**
  * Helpers to interact with userspace
  * res_counter_read_u64() - returns the value of the specified member.
@@ -92,6 +103,8 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_WMARK_LIMIT,
+	RES_HIGH_WMARK_LIMIT
 };
 
 /*
@@ -147,6 +160,24 @@ static inline unsigned long long res_counter_margin(struct res_counter *cnt)
 	return margin;
 }
 
+static inline bool
+res_counter_under_high_wmark_limit_check_locked(struct res_counter *cnt)
+{
+	if (cnt->usage < cnt->high_wmark_limit)
+		return true;
+
+	return false;
+}
+
+static inline bool
+res_counter_under_low_wmark_limit_check_locked(struct res_counter *cnt)
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
@@ -169,6 +200,30 @@ res_counter_soft_limit_excess(struct res_counter *cnt)
 	return excess;
 }
 
+static inline bool
+res_counter_under_low_wmark_limit(struct res_counter *cnt)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_under_low_wmark_limit_check_locked(cnt);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
+static inline bool
+res_counter_under_high_wmark_limit(struct res_counter *cnt)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_under_high_wmark_limit_check_locked(cnt);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
@@ -214,4 +269,27 @@ res_counter_set_soft_limit(struct res_counter *cnt,
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
index 34683ef..206a724 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -19,6 +19,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
 	counter->soft_limit = RESOURCE_MAX;
+	counter->low_wmark_limit = RESOURCE_MAX;
+	counter->high_wmark_limit = RESOURCE_MAX;
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
index 4407dd0..1ec4014 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -272,6 +272,12 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+	/*
+	 * used to calculate the low/high_wmarks based on the limit_in_bytes.
+	 */
+	u64 high_wmark_distance;
+	u64 low_wmark_distance;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -813,6 +819,25 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
 	return (mem == root_mem_cgroup);
 }
 
+static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
+{
+	u64 limit;
+
+	limit = res_counter_read_u64(&mem->res, RES_LIMIT);
+	if (mem->high_wmark_distance == 0) {
+		res_counter_set_low_wmark_limit(&mem->res, limit);
+		res_counter_set_high_wmark_limit(&mem->res, limit);
+	} else {
+		u64 low_wmark, high_wmark;
+
+		low_wmark = limit - mem->low_wmark_distance;
+		high_wmark = limit - mem->high_wmark_distance;
+
+		res_counter_set_low_wmark_limit(&mem->res, low_wmark);
+		res_counter_set_high_wmark_limit(&mem->res, high_wmark);
+	}
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -3205,6 +3230,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 			else
 				memcg->memsw_is_minimum = false;
 		}
+		setup_per_memcg_wmarks(memcg);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -3264,6 +3290,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 			else
 				memcg->memsw_is_minimum = false;
 		}
+		setup_per_memcg_wmarks(memcg);
 		mutex_unlock(&set_limit_mutex);
 
 		if (!ret)
@@ -4521,6 +4548,27 @@ static void __init enable_swap_cgroup(void)
 }
 #endif
 
+/*
+ * We use low_wmark and high_wmark for triggering per-memcg kswapd.
+ * The reclaim is triggered by low_wmark (usage > low_wmark) and stopped
+ * by high_wmark (usage < high_wmark).
+ */
+int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
+				int charge_flags)
+{
+	long ret = 0;
+	int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
+
+	VM_BUG_ON((charge_flags & flags) == flags);
+
+	if (charge_flags & CHARGE_WMARK_LOW)
+		ret = res_counter_under_low_wmark_limit(&mem->res);
+	if (charge_flags & CHARGE_WMARK_HIGH)
+		ret = res_counter_under_high_wmark_limit(&mem->res);
+
+	return ret;
+}
+
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
