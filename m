Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3C26B0259
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:58:57 -0500 (EST)
Received: by wmec201 with SMTP id c201so230014946wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:58:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p9si21686829wjw.8.2015.11.24.13.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:58:56 -0800 (PST)
Date: Tue, 24 Nov 2015 16:58:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 12/13] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151124215844.GA1373@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Socket memory can be a significant share of overall memory consumed by
common workloads. In order to provide reasonable resource isolation in
the unified hierarchy, this type of memory needs to be included in the
tracking/accounting of a cgroup under active memory resource control.

Overhead is only incurred when a non-root control group is created AND
the memory controller is instructed to track and account the memory
footprint of that group. cgroup.memory=nosocket can be specified on
the boot commandline to override any runtime configuration and
forcibly exclude socket memory from active memory resource control.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/kernel-parameters.txt |   4 ++
 include/linux/memcontrol.h          |  11 +++-
 mm/memcontrol.c                     | 122 +++++++++++++++++++++++++++++-------
 3 files changed, 111 insertions(+), 26 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 742f69d..7868f1b 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -599,6 +599,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			cut the overhead, others just disable the usage. So
 			only cgroup_disable=memory is actually worthy}
 
+	cgroup.memory=	[KNL] Pass options to the cgroup memory controller.
+			Format: <string>
+			nosocket -- Disable socket memory accounting.
+
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
 			See security/selinux/Kconfig help text.
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index dad56ef..fae0aaf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -170,6 +170,9 @@ struct mem_cgroup {
 	unsigned long low;
 	unsigned long high;
 
+	/* Range enforcement for interrupt charges */
+	struct work_struct high_work;
+
 	unsigned long soft_limit;
 
 	/* vmpressure notifications */
@@ -679,7 +682,7 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 struct sock;
 extern struct static_key memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
@@ -689,11 +692,15 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
+#ifdef CONFIG_MEMCG_KMEM
 	return memcg->tcp_mem.memory_pressure;
+#else
+	return false;
+#endif
 }
 #else
 #define mem_cgroup_sockets_enabled 0
-#endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_INET */
 
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ed030b5..59555b0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -80,6 +80,9 @@ struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+/* Socket memory accounting disabled? */
+static bool cgroup_memory_nosocket;
+
 /* Whether the swap controller is active */
 #ifdef CONFIG_MEMCG_SWAP
 int do_swap_account __read_mostly;
@@ -1923,6 +1926,26 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	return NOTIFY_OK;
 }
 
+static void reclaim_high(struct mem_cgroup *memcg,
+			 unsigned int nr_pages,
+			 gfp_t gfp_mask)
+{
+	do {
+		if (page_counter_read(&memcg->memory) <= memcg->high)
+			continue;
+		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
+		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+	} while ((memcg = parent_mem_cgroup(memcg)));
+}
+
+static void high_work_func(struct work_struct *work)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(work, struct mem_cgroup, high_work);
+	reclaim_high(memcg, CHARGE_BATCH, GFP_KERNEL);
+}
+
 /*
  * Scheduled by try_charge() to be executed from the userland return path
  * and reclaims memory over the high limit.
@@ -1930,20 +1953,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 void mem_cgroup_handle_over_high(void)
 {
 	unsigned int nr_pages = current->memcg_nr_pages_over_high;
-	struct mem_cgroup *memcg, *pos;
+	struct mem_cgroup *memcg;
 
 	if (likely(!nr_pages))
 		return;
 
-	pos = memcg = get_mem_cgroup_from_mm(current->mm);
-
-	do {
-		if (page_counter_read(&pos->memory) <= pos->high)
-			continue;
-		mem_cgroup_events(pos, MEMCG_HIGH, 1);
-		try_to_free_mem_cgroup_pages(pos, nr_pages, GFP_KERNEL, true);
-	} while ((pos = parent_mem_cgroup(pos)));
-
+	memcg = get_mem_cgroup_from_mm(current->mm);
+	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
 	current->memcg_nr_pages_over_high = 0;
 }
@@ -2078,6 +2094,11 @@ done_restock:
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
+			/* Don't bother a random interrupted task */
+			if (in_interrupt()) {
+				schedule_work(&memcg->high_work);
+				break;
+			}
 			current->memcg_nr_pages_over_high += batch;
 			set_notify_resume(current);
 			break;
@@ -4126,6 +4147,8 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
 
+	cancel_work_sync(&memcg->high_work);
+
 	mem_cgroup_remove_from_trees(memcg);
 
 	for_each_node(node)
@@ -4172,6 +4195,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 		page_counter_init(&memcg->kmem, NULL);
 	}
 
+	INIT_WORK(&memcg->high_work, high_work_func);
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 	memcg->move_charge_at_immigrate = 0;
@@ -4243,6 +4267,11 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
+#ifdef CONFIG_INET
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
+		static_key_slow_inc(&memcg_sockets_enabled_key);
+#endif
+
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
 	 * orders reading memcg->initialized against its callers
@@ -4282,6 +4311,10 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
+#ifdef CONFIG_INET
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
+		static_key_slow_dec(&memcg_sockets_enabled_key);
+#endif
 	__mem_cgroup_free(memcg);
 }
 
@@ -5470,8 +5503,7 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 
 struct static_key memcg_sockets_enabled_key;
 EXPORT_SYMBOL(memcg_sockets_enabled_key);
@@ -5496,10 +5528,15 @@ void sock_update_memcg(struct sock *sk)
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
-	if (memcg != root_mem_cgroup &&
-	    memcg->tcp_mem.active &&
-	    css_tryget_online(&memcg->css))
+	if (memcg == root_mem_cgroup)
+		goto out;
+#ifdef CONFIG_MEMCG_KMEM
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcp_mem.active)
+		goto out;
+#endif
+	if (css_tryget_online(&memcg->css))
 		sk->sk_memcg = memcg;
+out:
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(sock_update_memcg);
@@ -5520,15 +5557,30 @@ void sock_release_memcg(struct sock *sk)
  */
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	struct page_counter *counter;
+	gfp_t gfp_mask = GFP_KERNEL;
 
-	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
-				    nr_pages, &counter)) {
-		memcg->tcp_mem.memory_pressure = 0;
-		return true;
+#ifdef CONFIG_MEMCG_KMEM
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		struct page_counter *counter;
+
+		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
+					    nr_pages, &counter)) {
+			memcg->tcp_mem.memory_pressure = 0;
+			return true;
+		}
+		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
+		memcg->tcp_mem.memory_pressure = 1;
+		return false;
 	}
-	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
-	memcg->tcp_mem.memory_pressure = 1;
+#endif
+	/* Don't block in the packet receive path */
+	if (in_softirq())
+		gfp_mask = GFP_NOWAIT;
+
+	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
+		return true;
+
+	try_charge(memcg, gfp_mask|__GFP_NOFAIL, nr_pages);
 	return false;
 }
 
@@ -5539,10 +5591,32 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	page_counter_uncharge(&memcg->tcp_mem.memory_allocated, nr_pages);
+#ifdef CONFIG_MEMCG_KMEM
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
+				      nr_pages);
+		return;
+	}
+#endif
+	page_counter_uncharge(&memcg->memory, nr_pages);
+	css_put_many(&memcg->css, nr_pages);
 }
 
-#endif
+#endif /* CONFIG_INET */
+
+static int __init cgroup_memory(char *s)
+{
+	char *token;
+
+	while ((token = strsep(&s, ",")) != NULL) {
+		if (!*token)
+			continue;
+		if (!strcmp(token, "nosocket"))
+			cgroup_memory_nosocket = true;
+	}
+	return 0;
+}
+__setup("cgroup.memory=", cgroup_memory);
 
 /*
  * subsys_initcall() for memory controller.
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
