Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0F3896B007E
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:02:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I927gO005359
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 18:02:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 629AE45DE57
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:02:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CE1E45DE51
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:02:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A570DEF8002
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:02:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2896F1DB8037
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 18:02:06 +0900 (JST)
Date: Fri, 18 Sep 2009 18:00:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 8/11]memcg: remove unused macro and adds commentary
Message-Id: <20090918180000.f0c2a54c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
	<20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch does
  - adds more commentary for commentless fileds.
  - remove unused flags as MEM_CGROUP_CHARGE_TYPE_FORCE and PCGF_XXX
  - Upadte comments for charge_type. Especially SWAPOUT and DROP is
    a not easy charge type to understand.
  - moved mem_cgroup_is_root() to head position.
    (after mem_cgroup_from_xxx functions)
  - move  MEM_CGROUP_MAX_RECLAIM_LOOPS near to other macros for reclaim. 

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   84 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 56 insertions(+), 28 deletions(-)

Index: mmotm-2.6.31-Sep17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep17.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep17/mm/memcontrol.c
@@ -89,12 +89,16 @@ struct mem_cgroup_stat {
  */
 struct mem_cgroup_per_zone {
 	/*
-	 * spin_lock to protect the per cgroup LRU
+	 *  LRU fields are guarded by zone->lru_lock.
 	 */
 	struct list_head	lists[NR_LRU_LISTS];
 	unsigned long		count[NR_LRU_LISTS];
-
+	/*
+	 * Reclaim stat is used for recording statistics of LRU behavior.
+	 * This is used by vmscan.c under zone->lru_lock
+	 */
 	struct zone_reclaim_stat reclaim_stat;
+	/* for softlimit tree management */
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long long	usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
@@ -166,55 +170,66 @@ struct mem_cgroup {
 	spinlock_t reclaim_param_lock;
 
 	int	prev_priority;	/* for recording reclaim priority */
+	unsigned int	swappiness; /* a vmscan parameter (see vmscan.c) */
 
 	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
 	 * reclaimed from.
 	 */
 	int last_scanned_child;
+
+	/* true if hierarchical page accounting is ued in this memcg. */
+	bool use_hierarchy;
+
 	/*
-	 * Should the accounting and control be hierarchical, per subtree?
+	 * For recording jiffies of the last OOM under this memcg.
+	 * This is used by mem_cgroup_oom_called() which is called by
+	 * pagefault_out_of_memory() for checking OOM was system-wide or
+	 * memcg local.
 	 */
-	bool use_hierarchy;
+
 	unsigned long	last_oom_jiffies;
+	/*
+	 * Private refcnt. This is mainly used by swap accounting
+	 * Because we don't move swap account at destroy(), mem_cgroup
+	 * object must be alive as zombie until all references from
+	 * swap disappears.
+	 */
 	atomic_t	refcnt;
 
-	unsigned int	swappiness;
-
-	/* set when res.limit == memsw.limit */
+	/*
+	 * set when res.limit == memsw.limit. If this is true, swapout
+	 * will be no help for reducing the usage.
+	 */
 	bool		memsw_is_minimum;
 
 	/*
-	 * statistics. This must be placed at the end of memcg.
+	 * per-cpu statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
 
 /*
- * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
- * limit reclaim to prevent infinite loops, if they ever occur.
+ * Types of charge/uncharge. memcg's behavior is depends on these types.
+ * SWAPOUT is for mem+swap accounting. It's used when a page is dropped
+ * from memory but there is a valid reference in swap. DROP means
+ * a page is removed from swap cache and no reference from swap itself.
  */
-#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
 
 enum charge_type {
-	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
-	MEM_CGROUP_CHARGE_TYPE_MAPPED,
+	MEM_CGROUP_CHARGE_TYPE_CACHE = 0, /* used when charges for cache */
+	MEM_CGROUP_CHARGE_TYPE_MAPPED,  /* used when charges for anon */
 	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
-	MEM_CGROUP_CHARGE_TYPE_FORCE,	/* used by force_empty */
 	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
 	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
 	NR_CHARGE_TYPE,
 };
 
-/* only for here (for easy reading.) */
-#define PCGF_CACHE	(1UL << PCG_CACHE)
-#define PCGF_USED	(1UL << PCG_USED)
-#define PCGF_LOCK	(1UL << PCG_LOCK)
-/* Not used, but added here for completeness */
-#define PCGF_ACCT	(1UL << PCG_ACCT)
-
-/* for encoding cft->private value on file */
+/*
+ * Because mem_cgroup has 2 contorls, mem & mem+swap. There are control files
+ * of similar functions. We use following encoding macro for controls files'
+ * type. These will be used for encoding cft->private value on file
+ */
 #define _MEM			(0)
 #define _MEMSWAP		(1)
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -231,6 +246,13 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
 #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
+/*
+ * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
+ * limit reclaim to prevent infinite loops, if they ever occur.
+ */
+#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
+#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -287,6 +309,17 @@ static struct mem_cgroup *try_get_mem_cg
 	return mem;
 }
 
+
+/*
+ * Because we dont' do "charge/uncharge" in root cgroup, some
+ * special handling is used.
+ */
+static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
+{
+	return (mem == root_mem_cgroup);
+}
+
+
 /*
  * Functions for acceccing cpu local statistics. modification should be
  * done under preempt disabled. __mem_cgroup_xxx functions are for low level.
@@ -657,11 +690,6 @@ static int mem_cgroup_walk_tree(struct m
 	return ret;
 }
 
-static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
-{
-	return (mem == root_mem_cgroup);
-}
-
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
