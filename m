Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 86BA26B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 08:00:35 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id 5so1918457pdd.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 05:00:34 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V5 7/8] memcg: don't account root memcg page stats if only root exists
Date: Thu,  1 Aug 2013 20:00:07 +0800
Message-Id: <1375358407-10777-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, gthelen@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

If memcg is enabled and no non-root memcg exists, all allocated pages
belongs to root and wil go through root memcg statistics routines. So in order
to reduce overheads after adding memcg dirty/writeback accounting in hot paths,
we use jump label to patch the accounting related functions in or out when not
used. If no non-root memcg comes to life, we do not need to accquire moving
locks and update page stats.

But to keep stats of root memcg correct in the long run, we transfer global numbers
to it when the first non-root memcg is created, and since then the root will begin
to do accounting as usual. In addition to this, we also need to take care of
memcg_stat_show() if only root memcg exists.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 include/linux/memcontrol.h |   18 ++++++++
 mm/memcontrol.c            |  108 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 122 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ccd35d8..c66163b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -55,6 +55,13 @@ struct mem_cgroup_reclaim_cookie {
 };
 
 #ifdef CONFIG_MEMCG
+
+extern struct static_key memcg_inuse_key;
+static inline bool mem_cgroup_in_use(void)
+{
+	return static_key_false(&memcg_inuse_key);
+}
+
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
  * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
@@ -159,7 +166,10 @@ static inline void mem_cgroup_begin_update_page_stat(struct page *page,
 {
 	if (mem_cgroup_disabled())
 		return;
+
 	rcu_read_lock();
+	if (!mem_cgroup_in_use())
+		return;
 	*locked = false;
 	if (atomic_read(&memcg_moving))
 		__mem_cgroup_begin_update_page_stat(page, locked, flags);
@@ -172,6 +182,10 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 {
 	if (mem_cgroup_disabled())
 		return;
+	if (!mem_cgroup_in_use()) {
+		rcu_read_unlock();
+		return;
+	}
 	if (*locked)
 		__mem_cgroup_end_update_page_stat(page, flags);
 	rcu_read_unlock();
@@ -215,6 +229,10 @@ void mem_cgroup_print_bad_page(struct page *page);
 #endif
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
+static inline bool mem_cgroup_in_use(void)
+{
+	return false;
+}
 
 static inline int mem_cgroup_newpage_charge(struct page *page,
 					struct mm_struct *mm, gfp_t gfp_mask)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 54da686..8928bd4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -463,6 +463,13 @@ enum res_type {
 #define MEM_CGROUP_RECLAIM_SHRINK_BIT	0x1
 #define MEM_CGROUP_RECLAIM_SHRINK	(1 << MEM_CGROUP_RECLAIM_SHRINK_BIT)
 
+/* static_key is used for marking memcg in use or not. We use this jump label
+ * to patch some memcg page stat accounting code in or out.
+ * The key will be increased when non-root memcg is created, and be decreased
+ * when memcg is destroyed.
+ */
+struct static_key memcg_inuse_key;
+
 /*
  * The memcg_create_mutex will be held whenever a new cgroup is created.
  * As a consequence, any change that needs to protect against new child cgroups
@@ -630,10 +637,22 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
+static void disarm_inuse_keys(struct mem_cgroup *memcg)
+{
+	if (!mem_cgroup_is_root(memcg))
+		static_key_slow_dec(&memcg_inuse_key);
+}
+
+static void arm_inuse_keys(void)
+{
+	static_key_slow_inc(&memcg_inuse_key);
+}
+
 static void disarm_static_keys(struct mem_cgroup *memcg)
 {
 	disarm_sock_keys(memcg);
 	disarm_kmem_keys(memcg);
+	disarm_inuse_keys(memcg);
 }
 
 static void drain_all_stock_async(struct mem_cgroup *memcg);
@@ -851,6 +870,9 @@ static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
 	spin_unlock(&memcg->pcp_counter_lock);
 
 	put_online_cpus();
+
+	if (val < 0)
+		val = 0;
 	return val;
 }
 
@@ -2298,12 +2320,14 @@ void mem_cgroup_update_page_stat(struct page *page,
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
-	unsigned long uninitialized_var(flags);
 
 	if (mem_cgroup_disabled())
 		return;
 
 	VM_BUG_ON(!rcu_read_lock_held());
+	if (!mem_cgroup_in_use())
+		return;
+
 	memcg = pc->mem_cgroup;
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
@@ -5431,12 +5455,37 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	struct mem_cgroup *mi;
 	unsigned int i;
-
+	struct stats {
+		unsigned long file_mapped;
+		unsigned long dirty;
+		unsigned long writeback;
+	} root_stats;
+	bool use_global = false;
+
+	/* If only root memcg exist, we should borrow some page stats
+	 * from global state.
+	 */
+	if (!mem_cgroup_in_use() && mem_cgroup_is_root(memcg)) {
+		use_global = true;
+		root_stats.file_mapped = global_page_state(NR_FILE_MAPPED);
+		root_stats.dirty = global_page_state(NR_FILE_DIRTY);
+		root_stats.writeback = global_page_state(NR_WRITEBACK);
+	}
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
 			continue;
-		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
-			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
+		if (use_global && i == MEM_CGROUP_STAT_FILE_MAPPED)
+			seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+					root_stats.file_mapped * PAGE_SIZE);
+		else if (use_global && i == MEM_CGROUP_STAT_FILE_DIRTY)
+			seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+					root_stats.dirty * PAGE_SIZE);
+		else if (use_global && i == MEM_CGROUP_STAT_WRITEBACK)
+			seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+					root_stats.writeback * PAGE_SIZE);
+		else
+			seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
+				mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
 	}
 
 	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
@@ -5464,6 +5513,14 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
 			continue;
 		for_each_mem_cgroup_tree(mi, memcg)
 			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
+
+		if (use_global && i == MEM_CGROUP_STAT_FILE_MAPPED)
+			val += root_stats.file_mapped * PAGE_SIZE;
+		else if (use_global && i == MEM_CGROUP_STAT_FILE_DIRTY)
+			val += root_stats.dirty * PAGE_SIZE;
+		else if (use_global && i == MEM_CGROUP_STAT_WRITEBACK)
+			val += root_stats.writeback * PAGE_SIZE;
+
 		seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
 	}
 
@@ -6303,6 +6360,49 @@ mem_cgroup_css_online(struct cgroup *cont)
 	}
 
 	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
+	if (!error) {
+		if (!mem_cgroup_in_use()) {
+			/* I'm the first non-root memcg, move global stats to root memcg.
+			 * Memcg creating is serialized by cgroup locks(cgroup_mutex),
+			 * so the mem_cgroup_in_use() checking is safe.
+			 *
+			 * We use global_page_state() to get global page stats, but
+			 * because of the optimized inc/dec functions in SMP while
+			 * updating each zone's stats, We may lose some numbers
+			 * in a stock(zone->pageset->vm_stat_diff) which brings some
+			 * inaccuracy. But places where kernel use these page stats to
+			 * steer next decision e.g. dirty page throttling or writeback
+			 * also use global_page_state(), so here it's enough too.
+			 */
+			spin_lock(&root_mem_cgroup->pcp_counter_lock);
+			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_MAPPED] =
+						global_page_state(NR_FILE_MAPPED);
+			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_FILE_DIRTY] =
+						global_page_state(NR_FILE_DIRTY);
+			root_mem_cgroup->stats_base.count[MEM_CGROUP_STAT_WRITEBACK] =
+						global_page_state(NR_WRITEBACK);
+			spin_unlock(&root_mem_cgroup->pcp_counter_lock);
+		}
+
+		/*
+		 * memcg_inuse_key is used for checking whether non-root memcg
+		 * is created or not. To avoid race among page stat updating,
+		 * non-root memcg creating and move accounting, we should do
+		 * page stat updating under rcu_read_lock():
+		 *
+		 *	CPU-A			    CPU-B
+		 * rcu_read_lock()
+		 *
+		 * if (memcg_inuse_key)          arm_inuse_keys()
+		 *    update memcg page stat     synchronize_rcu()
+		 *
+		 * rcu_read_unlock()
+		 *				start move here and move accounting
+		 */
+		arm_inuse_keys();
+		synchronize_rcu();
+	}
+
 	mutex_unlock(&memcg_create_mutex);
 	return error;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
