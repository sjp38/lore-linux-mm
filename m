Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D43F328027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:15:12 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so30808379wgm.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:12 -0700 (PDT)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id fj6si24908898wib.55.2015.07.15.04.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:15:10 -0700 (PDT)
Received: by wgkl9 with SMTP id l9so30755136wgk.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/5] memcg: export struct mem_cgroup
Date: Wed, 15 Jul 2015 13:14:41 +0200
Message-Id: <1436958885-18754-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

mem_cgroup structure is defined in mm/memcontrol.c currently which
means that the code outside of this file has to use external API even
for trivial access stuff.

This patch exports mm_struct with its dependencies and makes some of the
exported functions inlines. This even helps to reduce the code size a bit
(make defconfig + CONFIG_MEMCG=y)

text		data    bss     dec     	 hex 	filename
12355346        1823792 1089536 15268674         e8fb42 vmlinux.before
12354970        1823792 1089536 15268298         e8f9ca vmlinux.after

This is not much (370B) but better than nothing. We also save a function
call in some hot paths like callers of mem_cgroup_count_vm_event which is
used for accounting.

The patch doesn't introduce any functional changes.

[vdavykov@parallels.com: inline memcg_kmem_is_active]
[vdavykov@parallels.com: do not expose type outside of CONFIG_MEMCG]
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 369 +++++++++++++++++++++++++++++++++++++++++----
 include/linux/swap.h       |  10 +-
 include/net/sock.h         |  28 ----
 mm/memcontrol.c            | 314 +-------------------------------------
 mm/memory-failure.c        |   2 +-
 mm/slab_common.c           |   2 +-
 mm/vmscan.c                |   2 +-
 7 files changed, 349 insertions(+), 378 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 73b02b0a8f60..42f118ae04cf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -23,6 +23,10 @@
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
 #include <linux/jump_label.h>
+#include <linux/page_counter.h>
+#include <linux/vmpressure.h>
+#include <linux/mmzone.h>
+#include <linux/writeback.h>
 
 struct mem_cgroup;
 struct page;
@@ -67,12 +71,221 @@ enum mem_cgroup_events_index {
 	MEMCG_NR_EVENTS,
 };
 
+/*
+ * Per memcg event counter is incremented at every pagein/pageout. With THP,
+ * it will be incremated by the number of pages. This counter is used for
+ * for trigger some periodic events. This is straightforward and better
+ * than using jiffies etc. to handle periodic memcg event.
+ */
+enum mem_cgroup_events_target {
+	MEM_CGROUP_TARGET_THRESH,
+	MEM_CGROUP_TARGET_SOFTLIMIT,
+	MEM_CGROUP_TARGET_NUMAINFO,
+	MEM_CGROUP_NTARGETS,
+};
+
+/*
+ * Bits in struct cg_proto.flags
+ */
+enum cg_proto_flags {
+	/* Currently active and new sockets should be assigned to cgroups */
+	MEMCG_SOCK_ACTIVE,
+	/* It was ever activated; we must disarm static keys on destruction */
+	MEMCG_SOCK_ACTIVATED,
+};
+
+struct cg_proto {
+	struct page_counter	memory_allocated;	/* Current allocated memory. */
+	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
+	int			memory_pressure;
+	long			sysctl_mem[3];
+	unsigned long		flags;
+	/*
+	 * memcg field is used to find which memcg we belong directly
+	 * Each memcg struct can hold more than one cg_proto, so container_of
+	 * won't really cut.
+	 *
+	 * The elegant solution would be having an inverse function to
+	 * proto_cgroup in struct proto, but that means polluting the structure
+	 * for everybody, instead of just for memcg users.
+	 */
+	struct mem_cgroup	*memcg;
+};
+
 #ifdef CONFIG_MEMCG
+struct mem_cgroup_stat_cpu {
+	long count[MEM_CGROUP_STAT_NSTATS];
+	unsigned long events[MEMCG_NR_EVENTS];
+	unsigned long nr_page_events;
+	unsigned long targets[MEM_CGROUP_NTARGETS];
+};
+
+struct mem_cgroup_reclaim_iter {
+	struct mem_cgroup *position;
+	/* scan generation, increased every round-trip */
+	unsigned int generation;
+};
+
+/*
+ * per-zone information in memory controller.
+ */
+struct mem_cgroup_per_zone {
+	struct lruvec		lruvec;
+	unsigned long		lru_size[NR_LRU_LISTS];
+
+	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
+
+	struct rb_node		tree_node;	/* RB tree node */
+	unsigned long		usage_in_excess;/* Set to the value by which */
+						/* the soft limit is exceeded*/
+	bool			on_tree;
+	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
+						/* use container_of	   */
+};
+
+struct mem_cgroup_per_node {
+	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
+};
+
+struct mem_cgroup_threshold {
+	struct eventfd_ctx *eventfd;
+	unsigned long threshold;
+};
+
+/* For threshold */
+struct mem_cgroup_threshold_ary {
+	/* An array index points to threshold just below or equal to usage. */
+	int current_threshold;
+	/* Size of entries[] */
+	unsigned int size;
+	/* Array of thresholds */
+	struct mem_cgroup_threshold entries[0];
+};
+
+struct mem_cgroup_thresholds {
+	/* Primary thresholds array */
+	struct mem_cgroup_threshold_ary *primary;
+	/*
+	 * Spare threshold array.
+	 * This is needed to make mem_cgroup_unregister_event() "never fail".
+	 * It must be able to store at least primary->size - 1 entries.
+	 */
+	struct mem_cgroup_threshold_ary *spare;
+};
+
+/*
+ * The memory controller data structure. The memory controller controls both
+ * page cache and RSS per cgroup. We would eventually like to provide
+ * statistics based on the statistics developed by Rik Van Riel for clock-pro,
+ * to help the administrator determine what knobs to tune.
+ */
+struct mem_cgroup {
+	struct cgroup_subsys_state css;
+
+	/* Accounted resources */
+	struct page_counter memory;
+	struct page_counter memsw;
+	struct page_counter kmem;
+
+	/* Normal memory consumption range */
+	unsigned long low;
+	unsigned long high;
+
+	unsigned long soft_limit;
+
+	/* vmpressure notifications */
+	struct vmpressure vmpressure;
+
+	/* css_online() has been completed */
+	int initialized;
+
+	/*
+	 * Should the accounting and control be hierarchical, per subtree?
+	 */
+	bool use_hierarchy;
+
+	/* protected by memcg_oom_lock */
+	bool		oom_lock;
+	int		under_oom;
+
+	int	swappiness;
+	/* OOM-Killer disable */
+	int		oom_kill_disable;
+
+	/* protect arrays of thresholds */
+	struct mutex thresholds_lock;
+
+	/* thresholds for memory usage. RCU-protected */
+	struct mem_cgroup_thresholds thresholds;
+
+	/* thresholds for mem+swap usage. RCU-protected */
+	struct mem_cgroup_thresholds memsw_thresholds;
+
+	/* For oom notifier event fd */
+	struct list_head oom_notify;
+
+	/*
+	 * Should we move charges of a task when a task is moved into this
+	 * mem_cgroup ? And what type of charges should we move ?
+	 */
+	unsigned long move_charge_at_immigrate;
+	/*
+	 * set > 0 if pages under this cgroup are moving to other cgroup.
+	 */
+	atomic_t		moving_account;
+	/* taken only while moving_account > 0 */
+	spinlock_t		move_lock;
+	struct task_struct	*move_lock_task;
+	unsigned long		move_lock_flags;
+	/*
+	 * percpu counter.
+	 */
+	struct mem_cgroup_stat_cpu __percpu *stat;
+	spinlock_t pcp_counter_lock;
+
+#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
+	struct cg_proto tcp_mem;
+#endif
+#if defined(CONFIG_MEMCG_KMEM)
+        /* Index in the kmem_cache->memcg_params.memcg_caches array */
+	int kmemcg_id;
+	bool kmem_acct_activated;
+	bool kmem_acct_active;
+#endif
+
+	int last_scanned_node;
+#if MAX_NUMNODES > 1
+	nodemask_t	scan_nodes;
+	atomic_t	numainfo_events;
+	atomic_t	numainfo_updating;
+#endif
+
+#ifdef CONFIG_CGROUP_WRITEBACK
+	struct list_head cgwb_list;
+	struct wb_domain cgwb_domain;
+#endif
+
+	/* List of events which userspace want to receive */
+	struct list_head event_list;
+	spinlock_t event_list_lock;
+
+	struct mem_cgroup_per_node *nodeinfo[0];
+	/* WARNING: nodeinfo must be the last member here */
+};
 extern struct cgroup_subsys_state *mem_cgroup_root_css;
 
-void mem_cgroup_events(struct mem_cgroup *memcg,
+/**
+ * mem_cgroup_events - count memory events against a cgroup
+ * @memcg: the memory cgroup
+ * @idx: the event index
+ * @nr: the number of events to account for
+ */
+static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 		       enum mem_cgroup_events_index idx,
-		       unsigned int nr);
+		       unsigned int nr)
+{
+	this_cpu_add(memcg->stat->events[idx], nr);
+}
 
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
 
@@ -90,15 +303,31 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
-bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
-			      struct mem_cgroup *root);
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
-extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
+static inline
+struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
+	return css ? container_of(css, struct mem_cgroup, css) : NULL;
+}
+
+struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
+				   struct mem_cgroup *,
+				   struct mem_cgroup_reclaim_cookie *);
+void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
+
+static inline bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
+			      struct mem_cgroup *root)
+{
+	if (root == memcg)
+		return true;
+	if (!root->use_hierarchy)
+		return false;
+	return cgroup_is_descendant(memcg->css.cgroup, root->css.cgroup);
+}
 
 static inline bool mm_match_cgroup(struct mm_struct *mm,
 				   struct mem_cgroup *memcg)
@@ -114,22 +343,65 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return match;
 }
 
-extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 extern struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
 
-struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
-				   struct mem_cgroup *,
-				   struct mem_cgroup_reclaim_cookie *);
-void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
+static inline bool mem_cgroup_disabled(void)
+{
+	if (memory_cgrp_subsys.disabled)
+		return true;
+	return false;
+}
 
 /*
  * For memory reclaim.
  */
-int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
-bool mem_cgroup_lruvec_online(struct lruvec *lruvec);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
-unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
-void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
+
+void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
+		int nr_pages);
+
+static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled())
+		return true;
+
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	memcg = mz->memcg;
+
+	return !!(memcg->css.flags & CSS_ONLINE);
+}
+
+static inline
+unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
+{
+	struct mem_cgroup_per_zone *mz;
+
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	return mz->lru_size[lru];
+}
+
+static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
+{
+	unsigned long inactive_ratio;
+	unsigned long inactive;
+	unsigned long active;
+	unsigned long gb;
+
+	inactive = mem_cgroup_get_lru_size(lruvec, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_ANON);
+
+	gb = (inactive + active) >> (30 - PAGE_SHIFT);
+	if (gb)
+		inactive_ratio = int_sqrt(10 * gb);
+	else
+		inactive_ratio = 1;
+
+	return inactive * inactive_ratio < active;
+}
+
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
@@ -156,18 +428,26 @@ bool mem_cgroup_oom_synchronize(bool wait);
 extern int do_swap_account;
 #endif
 
-static inline bool mem_cgroup_disabled(void)
-{
-	if (memory_cgrp_subsys.disabled)
-		return true;
-	return false;
-}
-
 struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page);
-void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
-				 enum mem_cgroup_stat_index idx, int val);
 void mem_cgroup_end_page_stat(struct mem_cgroup *memcg);
 
+/**
+ * mem_cgroup_update_page_stat - update page state statistics
+ * @memcg: memcg to account against
+ * @idx: page state item to account
+ * @val: number of pages (positive or negative)
+ *
+ * See mem_cgroup_begin_page_stat() for locking requirements.
+ */
+static inline void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
+				 enum mem_cgroup_stat_index idx, int val)
+{
+	VM_BUG_ON(!rcu_read_lock_held());
+
+	if (memcg)
+		this_cpu_add(memcg->stat->count[idx], val);
+}
+
 static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
@@ -184,13 +464,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
-void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 					     enum vm_event_item idx)
 {
+	struct mem_cgroup *memcg;
+
 	if (mem_cgroup_disabled())
 		return;
-	__mem_cgroup_count_vm_event(mm, idx);
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!memcg))
+		goto out;
+
+	switch (idx) {
+	case PGFAULT:
+		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
+		break;
+	case PGMAJFAULT:
+		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
+		break;
+	default:
+		BUG();
+	}
+out:
+	rcu_read_unlock();
 }
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
@@ -275,12 +573,6 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
-static inline struct cgroup_subsys_state
-		*mem_cgroup_css(struct mem_cgroup *memcg)
-{
-	return NULL;
-}
-
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
@@ -444,7 +736,10 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
-bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+{
+	return memcg->kmem_acct_active;
+}
 
 /*
  * In general, we'll do everything in our power to not incur in any overhead
@@ -463,7 +758,15 @@ void __memcg_kmem_commit_charge(struct page *page,
 				       struct mem_cgroup *memcg, int order);
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
-int memcg_cache_id(struct mem_cgroup *memcg);
+/*
+ * helper for acessing a memcg's index. It will be used as an index in the
+ * child cache array in kmem_cache, and also to derive its name. This function
+ * will return -1 when this is not a kmem-limited memcg.
+ */
+static inline int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return memcg ? memcg->kmemcg_id : -1;
+}
 
 struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
 void __memcg_kmem_put_cache(struct kmem_cache *cachep);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9a7adfb85e22..e617b3eefc8a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -352,7 +352,15 @@ extern void check_move_unevictable_pages(struct page **, int nr_pages);
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
 #ifdef CONFIG_MEMCG
-extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
+static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
+{
+	/* root ? */
+	if (mem_cgroup_disabled() || !memcg->css.parent)
+		return vm_swappiness;
+
+	return memcg->swappiness;
+}
+
 #else
 static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898ec8c67..35628cf42044 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1041,34 +1041,6 @@ struct proto {
 #endif
 };
 
-/*
- * Bits in struct cg_proto.flags
- */
-enum cg_proto_flags {
-	/* Currently active and new sockets should be assigned to cgroups */
-	MEMCG_SOCK_ACTIVE,
-	/* It was ever activated; we must disarm static keys on destruction */
-	MEMCG_SOCK_ACTIVATED,
-};
-
-struct cg_proto {
-	struct page_counter	memory_allocated;	/* Current allocated memory. */
-	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
-	int			memory_pressure;
-	long			sysctl_mem[3];
-	unsigned long		flags;
-	/*
-	 * memcg field is used to find which memcg we belong directly
-	 * Each memcg struct can hold more than one cg_proto, so container_of
-	 * won't really cut.
-	 *
-	 * The elegant solution would be having an inverse function to
-	 * proto_cgroup in struct proto, but that means polluting the structure
-	 * for everybody, instead of just for memcg users.
-	 */
-	struct mem_cgroup	*memcg;
-};
-
 int proto_register(struct proto *prot, int alloc_slab);
 void proto_unregister(struct proto *prot);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c554f6e..a3543dedc153 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -111,56 +111,10 @@ static const char * const mem_cgroup_lru_names[] = {
 	"unevictable",
 };
 
-/*
- * Per memcg event counter is incremented at every pagein/pageout. With THP,
- * it will be incremated by the number of pages. This counter is used for
- * for trigger some periodic events. This is straightforward and better
- * than using jiffies etc. to handle periodic memcg event.
- */
-enum mem_cgroup_events_target {
-	MEM_CGROUP_TARGET_THRESH,
-	MEM_CGROUP_TARGET_SOFTLIMIT,
-	MEM_CGROUP_TARGET_NUMAINFO,
-	MEM_CGROUP_NTARGETS,
-};
 #define THRESHOLDS_EVENTS_TARGET 128
 #define SOFTLIMIT_EVENTS_TARGET 1024
 #define NUMAINFO_EVENTS_TARGET	1024
 
-struct mem_cgroup_stat_cpu {
-	long count[MEM_CGROUP_STAT_NSTATS];
-	unsigned long events[MEMCG_NR_EVENTS];
-	unsigned long nr_page_events;
-	unsigned long targets[MEM_CGROUP_NTARGETS];
-};
-
-struct reclaim_iter {
-	struct mem_cgroup *position;
-	/* scan generation, increased every round-trip */
-	unsigned int generation;
-};
-
-/*
- * per-zone information in memory controller.
- */
-struct mem_cgroup_per_zone {
-	struct lruvec		lruvec;
-	unsigned long		lru_size[NR_LRU_LISTS];
-
-	struct reclaim_iter	iter[DEF_PRIORITY + 1];
-
-	struct rb_node		tree_node;	/* RB tree node */
-	unsigned long		usage_in_excess;/* Set to the value by which */
-						/* the soft limit is exceeded*/
-	bool			on_tree;
-	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
-						/* use container_of	   */
-};
-
-struct mem_cgroup_per_node {
-	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
-};
-
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
  * their hierarchy representation
@@ -181,32 +135,6 @@ struct mem_cgroup_tree {
 
 static struct mem_cgroup_tree soft_limit_tree __read_mostly;
 
-struct mem_cgroup_threshold {
-	struct eventfd_ctx *eventfd;
-	unsigned long threshold;
-};
-
-/* For threshold */
-struct mem_cgroup_threshold_ary {
-	/* An array index points to threshold just below or equal to usage. */
-	int current_threshold;
-	/* Size of entries[] */
-	unsigned int size;
-	/* Array of thresholds */
-	struct mem_cgroup_threshold entries[0];
-};
-
-struct mem_cgroup_thresholds {
-	/* Primary thresholds array */
-	struct mem_cgroup_threshold_ary *primary;
-	/*
-	 * Spare threshold array.
-	 * This is needed to make mem_cgroup_unregister_event() "never fail".
-	 * It must be able to store at least primary->size - 1 entries.
-	 */
-	struct mem_cgroup_threshold_ary *spare;
-};
-
 /* for OOM */
 struct mem_cgroup_eventfd_list {
 	struct list_head list;
@@ -256,113 +184,6 @@ struct mem_cgroup_event {
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
-/*
- * The memory controller data structure. The memory controller controls both
- * page cache and RSS per cgroup. We would eventually like to provide
- * statistics based on the statistics developed by Rik Van Riel for clock-pro,
- * to help the administrator determine what knobs to tune.
- */
-struct mem_cgroup {
-	struct cgroup_subsys_state css;
-
-	/* Accounted resources */
-	struct page_counter memory;
-	struct page_counter memsw;
-	struct page_counter kmem;
-
-	/* Normal memory consumption range */
-	unsigned long low;
-	unsigned long high;
-
-	unsigned long soft_limit;
-
-	/* vmpressure notifications */
-	struct vmpressure vmpressure;
-
-	/* css_online() has been completed */
-	int initialized;
-
-	/*
-	 * Should the accounting and control be hierarchical, per subtree?
-	 */
-	bool use_hierarchy;
-
-	/* protected by memcg_oom_lock */
-	bool		oom_lock;
-	int		under_oom;
-
-	int	swappiness;
-	/* OOM-Killer disable */
-	int		oom_kill_disable;
-
-	/* protect arrays of thresholds */
-	struct mutex thresholds_lock;
-
-	/* thresholds for memory usage. RCU-protected */
-	struct mem_cgroup_thresholds thresholds;
-
-	/* thresholds for mem+swap usage. RCU-protected */
-	struct mem_cgroup_thresholds memsw_thresholds;
-
-	/* For oom notifier event fd */
-	struct list_head oom_notify;
-
-	/*
-	 * Should we move charges of a task when a task is moved into this
-	 * mem_cgroup ? And what type of charges should we move ?
-	 */
-	unsigned long move_charge_at_immigrate;
-	/*
-	 * set > 0 if pages under this cgroup are moving to other cgroup.
-	 */
-	atomic_t		moving_account;
-	/* taken only while moving_account > 0 */
-	spinlock_t		move_lock;
-	struct task_struct	*move_lock_task;
-	unsigned long		move_lock_flags;
-	/*
-	 * percpu counter.
-	 */
-	struct mem_cgroup_stat_cpu __percpu *stat;
-	spinlock_t pcp_counter_lock;
-
-#if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
-	struct cg_proto tcp_mem;
-#endif
-#if defined(CONFIG_MEMCG_KMEM)
-        /* Index in the kmem_cache->memcg_params.memcg_caches array */
-	int kmemcg_id;
-	bool kmem_acct_activated;
-	bool kmem_acct_active;
-#endif
-
-	int last_scanned_node;
-#if MAX_NUMNODES > 1
-	nodemask_t	scan_nodes;
-	atomic_t	numainfo_events;
-	atomic_t	numainfo_updating;
-#endif
-
-#ifdef CONFIG_CGROUP_WRITEBACK
-	struct list_head cgwb_list;
-	struct wb_domain cgwb_domain;
-#endif
-
-	/* List of events which userspace want to receive */
-	struct list_head event_list;
-	spinlock_t event_list_lock;
-
-	struct mem_cgroup_per_node *nodeinfo[0];
-	/* WARNING: nodeinfo must be the last member here */
-};
-
-#ifdef CONFIG_MEMCG_KMEM
-bool memcg_kmem_is_active(struct mem_cgroup *memcg)
-{
-	return memcg->kmem_acct_active;
-}
-#endif
-
 /* Stuffs for move charges at task migration. */
 /*
  * Types of charges to be moved.
@@ -423,11 +244,6 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
-struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
-{
-	return s ? container_of(s, struct mem_cgroup, css) : NULL;
-}
-
 /* Some nice accessors for the vmpressure. */
 struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
 {
@@ -593,11 +409,6 @@ mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
 	return &memcg->nodeinfo[nid]->zoneinfo[zid];
 }
 
-struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
-{
-	return &memcg->css;
-}
-
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
@@ -876,14 +687,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 }
 
-unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	struct mem_cgroup_per_zone *mz;
-
-	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
-	return mz->lru_size[lru];
-}
-
 static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 						  int nid,
 						  unsigned int lru_mask)
@@ -1031,7 +834,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
-	struct reclaim_iter *uninitialized_var(iter);
+	struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
 	struct cgroup_subsys_state *css = NULL;
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *pos = NULL;
@@ -1173,30 +976,6 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 	     iter != NULL;				\
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
-void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
-{
-	struct mem_cgroup *memcg;
-
-	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!memcg))
-		goto out;
-
-	switch (idx) {
-	case PGFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
-		break;
-	case PGMAJFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
-		break;
-	default:
-		BUG();
-	}
-out:
-	rcu_read_unlock();
-}
-EXPORT_SYMBOL(__mem_cgroup_count_vm_event);
-
 /**
  * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
  * @zone: zone of the wanted lruvec
@@ -1295,15 +1074,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 	VM_BUG_ON((long)(*lru_size) < 0);
 }
 
-bool mem_cgroup_is_descendant(struct mem_cgroup *memcg, struct mem_cgroup *root)
-{
-	if (root == memcg)
-		return true;
-	if (!root->use_hierarchy)
-		return false;
-	return cgroup_is_descendant(memcg->css.cgroup, root->css.cgroup);
-}
-
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *task_memcg;
@@ -1330,39 +1100,6 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
 	return ret;
 }
 
-int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
-{
-	unsigned long inactive_ratio;
-	unsigned long inactive;
-	unsigned long active;
-	unsigned long gb;
-
-	inactive = mem_cgroup_get_lru_size(lruvec, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_lru_size(lruvec, LRU_ACTIVE_ANON);
-
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
-	else
-		inactive_ratio = 1;
-
-	return inactive * inactive_ratio < active;
-}
-
-bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-
-	if (mem_cgroup_disabled())
-		return true;
-
-	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
-	memcg = mz->memcg;
-
-	return !!(memcg->css.flags & CSS_ONLINE);
-}
-
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -1394,15 +1131,6 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 	return margin;
 }
 
-int mem_cgroup_swappiness(struct mem_cgroup *memcg)
-{
-	/* root ? */
-	if (mem_cgroup_disabled() || !memcg->css.parent)
-		return vm_swappiness;
-
-	return memcg->swappiness;
-}
-
 /*
  * A routine for checking "mem" is under move_account() or not.
  *
@@ -2062,23 +1790,6 @@ void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(mem_cgroup_end_page_stat);
 
-/**
- * mem_cgroup_update_page_stat - update page state statistics
- * @memcg: memcg to account against
- * @idx: page state item to account
- * @val: number of pages (positive or negative)
- *
- * See mem_cgroup_begin_page_stat() for locking requirements.
- */
-void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
-				 enum mem_cgroup_stat_index idx, int val)
-{
-	VM_BUG_ON(!rcu_read_lock_held());
-
-	if (memcg)
-		this_cpu_add(memcg->stat->count[idx], val);
-}
-
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
  * TODO: maybe necessary to use big numbers in big irons.
@@ -2504,16 +2215,6 @@ void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages)
 	css_put_many(&memcg->css, nr_pages);
 }
 
-/*
- * helper for acessing a memcg's index. It will be used as an index in the
- * child cache array in kmem_cache, and also to derive its name. This function
- * will return -1 when this is not a kmem-limited memcg.
- */
-int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	return memcg ? memcg->kmemcg_id : -1;
-}
-
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -5521,19 +5222,6 @@ struct cgroup_subsys memory_cgrp_subsys = {
 };
 
 /**
- * mem_cgroup_events - count memory events against a cgroup
- * @memcg: the memory cgroup
- * @idx: the event index
- * @nr: the number of events to account for
- */
-void mem_cgroup_events(struct mem_cgroup *memcg,
-		       enum mem_cgroup_events_index idx,
-		       unsigned int nr)
-{
-	this_cpu_add(memcg->stat->events[idx], nr);
-}
-
-/**
  * mem_cgroup_low - check if memory consumption is below the normal range
  * @root: the highest ancestor to consider
  * @memcg: the memory cgroup to check
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1cf7f2988422..ef33ccf37224 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -146,7 +146,7 @@ static int hwpoison_filter_task(struct page *p)
 	if (!mem)
 		return -EINVAL;
 
-	css = mem_cgroup_css(mem);
+	css = &mem->css;
 	ino = cgroup_ino(css->cgroup);
 	css_put(css);
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8873985f905e..ec3f68b14b87 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -501,7 +501,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 			     struct kmem_cache *root_cache)
 {
 	static char memcg_name_buf[NAME_MAX + 1]; /* protected by slab_mutex */
-	struct cgroup_subsys_state *css = mem_cgroup_css(memcg);
+	struct cgroup_subsys_state *css = &memcg->css;
 	struct memcg_cache_array *arr;
 	struct kmem_cache *s = NULL;
 	char *cache_name;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c8d82827279a..903ca5f53339 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -175,7 +175,7 @@ static bool sane_reclaim(struct scan_control *sc)
 	if (!memcg)
 		return true;
 #ifdef CONFIG_CGROUP_WRITEBACK
-	if (cgroup_on_dfl(mem_cgroup_css(memcg)->cgroup))
+	if (memcg->css.cgroup)
 		return true;
 #endif
 	return false;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
