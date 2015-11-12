Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6A882F64
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:38 -0500 (EST)
Received: by wmec201 with SMTP id c201so57704415wme.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n74si1493252wmg.4.2015.11.12.15.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:37 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 13/14] mm: memcontrol: account socket memory in unified hierarchy memory controller
Date: Thu, 12 Nov 2015 18:41:32 -0500
Message-Id: <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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
 include/linux/memcontrol.h |  12 ++++-
 mm/memcontrol.c            | 131 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 118 insertions(+), 25 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4cf5afa..809d6de 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -256,6 +256,10 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
+#ifdef CONFIG_INET
+	struct work_struct	socket_work;
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -691,7 +695,7 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 struct sock;
 extern struct static_key memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_key_false(&memcg_sockets_enabled_key)
@@ -701,11 +705,15 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
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
index 408fb04..cad9525 100644
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
@@ -1923,6 +1926,18 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
 /*
  * Scheduled by try_charge() to be executed from the userland return path
  * and reclaims memory over the high limit.
@@ -1930,20 +1945,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
@@ -4141,6 +4149,8 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
+static void socket_work_func(struct work_struct *work);
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -4180,6 +4190,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_INET
+	INIT_WORK(&memcg->socket_work, socket_work_func);
+#endif
 	return &memcg->css;
 
 free_out:
@@ -4237,6 +4250,11 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
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
@@ -4276,6 +4294,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
+#ifdef CONFIG_INET
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
+		static_key_slow_dec(&memcg_sockets_enabled_key);
+	cancel_work_sync(&memcg->socket_work);
+#endif
 	__mem_cgroup_free(memcg);
 }
 
@@ -5464,8 +5487,7 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 
 struct static_key memcg_sockets_enabled_key;
 EXPORT_SYMBOL(memcg_sockets_enabled_key);
@@ -5490,10 +5512,16 @@ void sock_update_memcg(struct sock *sk)
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
-	if (memcg != root_mem_cgroup &&
-	    test_bit(MEMCG_SOCK_ACTIVE, &memcg->tcp_mem.flags) &&
-	    css_tryget_online(&memcg->css))
+	if (memcg == root_mem_cgroup)
+		goto out;
+#ifdef CONFIG_MEMCG_KMEM
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
+	    !test_bit(MEMCG_SOCK_ACTIVE, &memcg->tcp_mem.flags))
+		goto out;
+#endif
+	if (css_tryget_online(&memcg->css))
 		sk->sk_memcg = memcg;
+out:
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(sock_update_memcg);
@@ -5504,6 +5532,14 @@ void sock_release_memcg(struct sock *sk)
 	css_put(&sk->sk_memcg->css);
 }
 
+static void socket_work_func(struct work_struct *work)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(work, struct mem_cgroup, socket_work);
+	reclaim_high(memcg, CHARGE_BATCH, GFP_KERNEL);
+}
+
 /**
  * mem_cgroup_charge_skmem - charge socket memory
  * @memcg: memcg to charge
@@ -5514,16 +5550,43 @@ void sock_release_memcg(struct sock *sk)
  */
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
+	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	struct page_counter *counter;
+	bool force = false;
 
-	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
-				    nr_pages, &counter)) {
-		memcg->tcp_mem.memory_pressure = 0;
+#ifdef CONFIG_MEMCG_KMEM
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
+					    nr_pages, &counter)) {
+			memcg->tcp_mem.memory_pressure = 0;
+			return true;
+		}
+		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
+		memcg->tcp_mem.memory_pressure = 1;
+		return false;
+	}
+#endif
+	if (consume_stock(memcg, nr_pages))
 		return true;
+retry:
+	if (page_counter_try_charge(&memcg->memory, batch, &counter))
+		goto done;
+
+	if (batch > nr_pages) {
+		batch = nr_pages;
+		goto retry;
 	}
-	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
-	memcg->tcp_mem.memory_pressure = 1;
-	return false;
+
+	page_counter_charge(&memcg->memory, batch);
+	force = true;
+done:
+	css_get_many(&memcg->css, batch);
+	if (batch > nr_pages)
+		refill_stock(memcg, batch - nr_pages);
+
+	schedule_work(&memcg->socket_work);
+
+	return !force;
 }
 
 /**
@@ -5533,10 +5596,32 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
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
