Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E11CE6B0186
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 20:39:06 -0400 (EDT)
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Subject: [RFC] [PATCH 1/4] memcg: Kernel memory accounting infrastructure.
Date: Fri, 14 Oct 2011 17:38:27 -0700
Message-Id: <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org, Suleiman Souhlal <ssouhlal@FreeBSD.org>

Enabled with CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY.

Signed-off-by: Suleiman Souhlal <suleiman@google.com>
---
 init/Kconfig    |    8 ++++
 mm/memcontrol.c |  110 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 117 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index d627783..d9ce229 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -690,6 +690,14 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
 
+config CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	bool "Memory Resource Controller kernel memory tracking"
+	depends on CGROUP_MEM_RES_CTLR
+	help
+	  This option enables the tracking of kernel memory by the
+	  Memory Resource Controller.
+	  Enabling it might have performance impacts.
+
 config CGROUP_PERF
 	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
 	depends on PERF_EVENTS && CGROUPS
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3508777..52b18ed 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -58,6 +58,10 @@ struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+atomic64_t pre_memcg_kmem_bytes;	/* kmem usage before memcg is enabled */
+#endif
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
 int do_swap_account __read_mostly;
@@ -285,6 +289,11 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu nocpu_base;
 	spinlock_t pcp_counter_lock;
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	atomic64_t kmem_bypassed;
+	atomic64_t kmem_bytes;
+#endif
 };
 
 /* Stuffs for move charges at task migration. */
@@ -366,6 +375,8 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
 static void drain_all_stock_async(struct mem_cgroup *mem);
+static void memcg_kmem_move(struct mem_cgroup *memcg);
+static void memcg_kmem_init(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
@@ -3714,6 +3725,7 @@ move_account:
 		/* This is for making all *used* pages to be on LRU. */
 		lru_add_drain_all();
 		drain_all_stock_sync(mem);
+		memcg_kmem_move(mem);
 		ret = 0;
 		mem_cgroup_start_move(mem);
 		for_each_node_state(node, N_HIGH_MEMORY) {
@@ -3749,6 +3761,7 @@ try_to_free:
 	}
 	/* we call try-to-free pages for make this cgroup empty */
 	lru_add_drain_all();
+	memcg_kmem_move(mem);
 	/* try to free all pages in this cgroup */
 	shrink = 1;
 	while (nr_retries && mem->res.usage > 0) {
@@ -4032,6 +4045,7 @@ enum {
 	MCS_INACTIVE_FILE,
 	MCS_ACTIVE_FILE,
 	MCS_UNEVICTABLE,
+	MCS_KMEM,
 	NR_MCS_STAT,
 };
 
@@ -4055,7 +4069,8 @@ struct {
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
 	{"active_file", "total_active_file"},
-	{"unevictable", "total_unevictable"}
+	{"unevictable", "total_unevictable"},
+	{"kernel_memory", "total_kernel_memory"}
 };
 
 
@@ -4095,6 +4110,10 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
 	val = mem_cgroup_nr_lru_pages(mem, BIT(LRU_UNEVICTABLE));
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	s->stat[MCS_KMEM] += atomic64_read(&mem->kmem_bytes);
+#endif
 }
 
 static void
@@ -4930,6 +4949,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mem->last_scanned_child = 0;
 	mem->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&mem->oom_notify);
+	memcg_kmem_init(mem);
 
 	if (parent)
 		mem->swappiness = mem_cgroup_swappiness(parent);
@@ -4956,6 +4976,10 @@ static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+	BUG_ON(atomic64_read(&mem->kmem_bytes) != 0);
+#endif
+
 	mem_cgroup_put(mem);
 }
 
@@ -5505,3 +5529,87 @@ static int __init enable_swap_account(char *s)
 __setup("swapaccount=", enable_swap_account);
 
 #endif
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY
+static void
+memcg_account_kmem(struct mem_cgroup *memcg, long long delta, bool bypassed)
+{
+	if (bypassed && memcg && memcg != root_mem_cgroup) {
+		atomic64_add(delta, &memcg->kmem_bypassed);
+		memcg = NULL;
+	}
+
+	if (memcg)
+		atomic64_add(delta, &memcg->kmem_bytes);
+	else if (root_mem_cgroup != NULL)
+		atomic64_add(delta, &root_mem_cgroup->kmem_bytes);
+	else
+		atomic64_add(delta, &pre_memcg_kmem_bytes);
+}
+
+static void
+memcg_unaccount_kmem(struct mem_cgroup *memcg, long long delta)
+{
+	if (memcg) {
+		long long bypassed = atomic64_read(&memcg->kmem_bypassed);
+		if (bypassed > 0) {
+			if (bypassed > delta)
+				bypassed = delta;
+			do {
+				memcg_unaccount_kmem(NULL, bypassed);
+				delta -= bypassed;
+				bypassed = atomic64_sub_return(bypassed,
+						&memcg->kmem_bypassed);
+			} while (bypassed < 0);	/* might have raced */
+		}
+	}
+
+	if (memcg)
+		atomic64_sub(delta, &memcg->kmem_bytes);
+	else if (root_mem_cgroup != NULL)
+		atomic64_sub(delta, &root_mem_cgroup->kmem_bytes);
+	else
+		atomic64_sub(delta, &pre_memcg_kmem_bytes);
+
+	if (memcg && memcg != root_mem_cgroup)
+		res_counter_uncharge(&memcg->res, delta);
+}
+
+static void
+memcg_kmem_init(struct mem_cgroup *memcg)
+{
+	if (memcg == root_mem_cgroup) {
+		long kmem_bytes;
+
+		kmem_bytes = atomic64_xchg(&pre_memcg_kmem_bytes, 0);
+		atomic64_set(&memcg->kmem_bytes, kmem_bytes);
+	} else
+		atomic64_set(&memcg->kmem_bytes, 0);
+	atomic64_set(&memcg->kmem_bypassed, 0);
+}
+
+static void
+memcg_kmem_move(struct mem_cgroup *memcg)
+{
+	long kmem_bytes;
+
+	atomic64_set(&memcg->kmem_bypassed, 0);
+	kmem_bytes = atomic64_xchg(&memcg->kmem_bytes, 0);
+	res_counter_uncharge(&memcg->res, kmem_bytes);
+	/*
+	 * Currently we don't need to do a charge after this, since we are
+	 * only moving to the root.
+	 */
+	atomic64_add(kmem_bytes, &root_mem_cgroup->kmem_bytes);
+}
+#else /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
+static void
+memcg_kmem_init(struct mem_cgroup *memcg)
+{
+}
+
+static void
+memcg_kmem_move(struct mem_cgroup *memcg)
+{
+}
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KERNEL_MEMORY */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
