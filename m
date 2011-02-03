Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7A6198D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 07:56:20 -0500 (EST)
Date: Thu, 3 Feb 2011 13:56:11 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] memcg: simplify the way memory limits are checked
Message-ID: <20110203125611.GC2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
 <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
 <20110131144131.6733aa3a.akpm@linux-foundation.org>
 <20110201000455.GB19534@cmpxchg.org>
 <20110131162448.e791f0ae.akpm@linux-foundation.org>
 <20110203125357.GA2286@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110203125357.GA2286@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since transparent huge pages, checking whether memory cgroups are
below their limits is no longer enough, but the actual amount of
chargeable space is important.

To not have more than one limit-checking interface, replace
memory_cgroup_check_under_limit() and memory_cgroup_check_margin()
with a single memory_cgroup_margin() that returns the chargeable space
and leaves the comparison to the callsite.

Soft limits are now checked the other way round, by using the already
existing function that returns the amount by which soft limits are
exceeded: res_counter_soft_limit_excess().

Also remove all the corresponding functions on the res_counter side
that are now no longer used.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/res_counter.h |   72 ++++++++----------------------------------
 mm/memcontrol.c             |   49 ++++++++++-------------------
 2 files changed, 31 insertions(+), 90 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index bf1f01b..c9d625c 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -129,20 +129,22 @@ int __must_check res_counter_charge(struct res_counter *counter,
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
-static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
-{
-	if (cnt->usage < cnt->limit)
-		return true;
-
-	return false;
-}
-
-static inline bool res_counter_soft_limit_check_locked(struct res_counter *cnt)
+/**
+ * res_counter_margin - calculate chargeable space of a counter
+ * @cnt: the counter
+ *
+ * Returns the difference between the hard limit and the current usage
+ * of resource counter @cnt.
+ */
+static inline unsigned long long res_counter_margin(struct res_counter *cnt)
 {
-	if (cnt->usage <= cnt->soft_limit)
-		return true;
+	unsigned long long margin;
+	unsigned long flags;
 
-	return false;
+	spin_lock_irqsave(&cnt->lock, flags);
+	margin = cnt->limit - cnt->usage;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return margin;
 }
 
 /**
@@ -167,52 +169,6 @@ res_counter_soft_limit_excess(struct res_counter *cnt)
 	return excess;
 }
 
-/*
- * Helper function to detect if the cgroup is within it's limit or
- * not. It's currently called from cgroup_rss_prepare()
- */
-static inline bool res_counter_check_under_limit(struct res_counter *cnt)
-{
-	bool ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	ret = res_counter_limit_check_locked(cnt);
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return ret;
-}
-
-/**
- * res_counter_check_margin - check if the counter allows charging
- * @cnt: the resource counter to check
- * @bytes: the number of bytes to check the remaining space against
- *
- * Returns a boolean value on whether the counter can be charged
- * @bytes or whether this would exceed the limit.
- */
-static inline bool res_counter_check_margin(struct res_counter *cnt,
-					    unsigned long bytes)
-{
-	bool ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	ret = cnt->limit - cnt->usage >= bytes;
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return ret;
-}
-
-static inline bool res_counter_check_within_soft_limit(struct res_counter *cnt)
-{
-	bool ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&cnt->lock, flags);
-	ret = res_counter_soft_limit_check_locked(cnt);
-	spin_unlock_irqrestore(&cnt->lock, flags);
-	return ret;
-}
-
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23b14188..e1ab9c3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -504,11 +504,6 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *mem)
 	}
 }
 
-static inline unsigned long mem_cgroup_get_excess(struct mem_cgroup *mem)
-{
-	return res_counter_soft_limit_excess(&mem->res) >> PAGE_SHIFT;
-}
-
 static struct mem_cgroup_per_zone *
 __mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
 {
@@ -1101,33 +1096,21 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 #define mem_cgroup_from_res_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
-static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
-{
-	if (do_swap_account) {
-		if (res_counter_check_under_limit(&mem->res) &&
-			res_counter_check_under_limit(&mem->memsw))
-			return true;
-	} else
-		if (res_counter_check_under_limit(&mem->res))
-			return true;
-	return false;
-}
-
 /**
- * mem_cgroup_check_margin - check if the memory cgroup allows charging
- * @mem: memory cgroup to check
- * @bytes: the number of bytes the caller intends to charge
+ * mem_cgroup_margin - calculate chargeable space of a memory cgroup
+ * @mem: the memory cgroup
  *
- * Returns a boolean value on whether @mem can be charged @bytes or
- * whether this would exceed the limit.
+ * Returns the maximum amount of memory @mem can be charged with, in
+ * bytes.
  */
-static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
+static unsigned long long mem_cgroup_margin(struct mem_cgroup *mem)
 {
-	if (!res_counter_check_margin(&mem->res, bytes))
-		return false;
-	if (do_swap_account && !res_counter_check_margin(&mem->memsw, bytes))
-		return false;
-	return true;
+	unsigned long long margin;
+
+	margin = res_counter_margin(&mem->res);
+	if (do_swap_account)
+		margin = min(margin, res_counter_margin(&mem->memsw));
+	return margin;
 }
 
 static unsigned int get_swappiness(struct mem_cgroup *memcg)
@@ -1394,7 +1377,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	bool noswap = reclaim_options & MEM_CGROUP_RECLAIM_NOSWAP;
 	bool shrink = reclaim_options & MEM_CGROUP_RECLAIM_SHRINK;
 	bool check_soft = reclaim_options & MEM_CGROUP_RECLAIM_SOFT;
-	unsigned long excess = mem_cgroup_get_excess(root_mem);
+	unsigned long excess;
+
+	excess = res_counter_soft_limit_excess(&root_mem->res) >> PAGE_SHIFT;
 
 	/* If memsw_is_minimum==1, swap-out is of-no-use. */
 	if (root_mem->memsw_is_minimum)
@@ -1451,9 +1436,9 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 			return ret;
 		total += ret;
 		if (check_soft) {
-			if (res_counter_check_within_soft_limit(&root_mem->res))
+			if (!res_counter_soft_limit_excess(&root_mem->res))
 				return total;
-		} else if (mem_cgroup_check_under_limit(root_mem))
+		} else if (mem_cgroup_margin(root_mem))
 			return 1 + total;
 	}
 	return total;
@@ -1872,7 +1857,7 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
 					      gfp_mask, flags);
-	if (mem_cgroup_check_margin(mem_over_limit, csize))
+	if (mem_cgroup_margin(mem_over_limit) >= csize)
 		return CHARGE_RETRY;
 	/*
 	 * Even though the limit is exceeded at this point, reclaim
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
