Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 9AD766B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 03:04:10 -0500 (EST)
From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] memcg: implement low limits
MIME-Version: 1.0
Message-Id: <8121361952156@webcorp1g.yandex-team.ru>
Date: Wed, 27 Feb 2013 12:02:36 +0400
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner-Arquette <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Hi, all!

I've implemented low limits for memory cgroups. The primary goal was to add an ability 
to protect some memory from reclaiming without using mlock(). A kind of "soft mlock()".

I think this patch will be helpful when it's necessary to protect production processes from
memory-wasting backup processes.

--

Low limits for memory cgroup can be used to limit memory pressure on it.
If memory usage of a cgroup is under it's low limit, it will not be
affected by global reclaim. If it reaches it's low limit from above,
the reclaiming speed will be dropped exponentially.

Low limits don't affect soft reclaim.
Also, it's possible that a cgroup with memory usage under low limit
will be reclaimed slowly on very low scanning priorities.

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
---
 include/linux/memcontrol.h  |    7 +++++
 include/linux/res_counter.h |   17 +++++++++++
 kernel/res_counter.c        |    2 ++
 mm/memcontrol.c             |   67 +++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                 |    5 ++++
 5 files changed, 98 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d6183f0..33e233f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -183,6 +183,8 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
+unsigned int mem_cgroup_low_limit_scale(struct lruvec *lruvec);
+
 void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 					     enum vm_event_item idx)
@@ -365,6 +367,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	return 0;
 }
 
+static inline unsigned int mem_cgroup_low_limit_scale(struct lruvec *lruvec)
+{
+	return 0;
+}
+
 static inline void mem_cgroup_split_huge_fixup(struct page *head)
 {
 }
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 5ae8456..df3510d 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -39,6 +39,10 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
+	 * the secured guaranteed minimal limit of resource
+	 */
+	unsigned long long low_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -87,6 +91,7 @@ enum {
 	RES_LIMIT,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_LOW_LIMIT,
 };
 
 /*
@@ -223,4 +228,16 @@ res_counter_set_soft_limit(struct res_counter *cnt,
 	return 0;
 }
 
+static inline int
+res_counter_set_low_limit(struct res_counter *cnt,
+			   unsigned long long low_limit)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->low_limit = low_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index ff55247..ebfefc1 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -135,6 +135,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return &counter->soft_limit;
+	case RES_LOW_LIMIT:
+		return &counter->low_limit;
 	};
 
 	BUG();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 53b8201..d8e6ee6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1743,6 +1743,53 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			 NULL, "Memory cgroup out of memory");
 }
 
+/*
+ * If a cgroup is under low limit or enough close to it,
+ * decrease speed of page scanning.
+ *
+ * mem_cgroup_low_limit_scale() returns a number
+ * from range [0, DEF_PRIORITY - 2], which is used
+ * in the reclaim code as a scanning priority modifier.
+ *
+ * If the low limit is not set, it returns 0;
+ *
+ * usage - low_limit > usage / 8  => 0
+ * usage - low_limit > usage / 16 => 1
+ * usage - low_limit > usage / 32 => 2
+ * ...
+ * usage - low_limit > usage / (2 ^ DEF_PRIORITY - 3) => DEF_PRIORITY - 3
+ * usage < low_limit => DEF_PRIORITY - 2
+ *
+ */
+unsigned int mem_cgroup_low_limit_scale(struct lruvec *lruvec)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *memcg;
+	unsigned long long low_limit;
+	unsigned long long usage;
+	unsigned int i;
+
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	memcg = mz->memcg;
+	if (!memcg)
+		return 0;
+
+	low_limit = res_counter_read_u64(&memcg->res, RES_LOW_LIMIT);
+	if (!low_limit)
+		return 0;
+
+	usage = res_counter_read_u64(&memcg->res, RES_USAGE);
+
+	if (usage < low_limit)
+		return DEF_PRIORITY - 2;
+
+	for (i = 0; i < DEF_PRIORITY - 2; i++)
+		if (usage - low_limit > (usage >> (i + 3)))
+			break;
+
+	return i;
+}
+
 static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
 					gfp_t gfp_mask,
 					unsigned long flags)
@@ -5116,6 +5163,20 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 		else
 			ret = -EINVAL;
 		break;
+	case RES_LOW_LIMIT:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		/*
+		 * For memsw, low limits (as also soft limits, see upper)
+		 * are hard to implement in terms of semantics,
+		 * for now, we support soft limits for control without swap
+		 */
+		if (type == _MEM)
+			ret = res_counter_set_low_limit(&memcg->res, val);
+		else
+			ret = -EINVAL;
+		break;
 	default:
 		ret = -EINVAL; /* should be BUG() ? */
 		break;
@@ -5798,6 +5859,12 @@ static struct cftype mem_cgroup_files[] = {
 		.read = mem_cgroup_read,
 	},
 	{
+		.name = "low_limit_in_bytes",
+		.private = MEMFILE_PRIVATE(_MEM, RES_LOW_LIMIT),
+		.write_string = mem_cgroup_write,
+		.read = mem_cgroup_read,
+	},
+	{
 		.name = "failcnt",
 		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
 		.trigger = mem_cgroup_reset,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 88c5fed..9c1c702 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1660,6 +1660,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	bool force_scan = false;
 	unsigned long ap, fp;
 	enum lru_list lru;
+	unsigned int low_limit_scale = 0;
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -1779,6 +1780,9 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
+	if (global_reclaim(sc))
+		low_limit_scale = mem_cgroup_low_limit_scale(lruvec);
+
 	for_each_evictable_lru(lru) {
 		int file = is_file_lru(lru);
 		unsigned long size;
@@ -1786,6 +1790,7 @@ out:
 
 		size = get_lru_size(lruvec, lru);
 		scan = size >> sc->priority;
+		scan >>= low_limit_scale;
 
 		if (!scan && force_scan)
 			scan = min(size, SWAP_CLUSTER_MAX);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
