Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id A39CA82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:50 -0500 (EST)
Received: by wmnn186 with SMTP id n186so3683319wmn.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:50 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h3si4135044wjw.15.2015.11.04.14.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:49 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 7/8] mm: memcontrol: account socket memory in unified hierarchy memory controller
Date: Wed,  4 Nov 2015 17:22:13 -0500
Message-Id: <1446675734-25671-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
References: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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
 include/linux/memcontrol.h |   8 +++-
 mm/memcontrol.c            | 110 +++++++++++++++++++++++++++++++++++++--------
 2 files changed, 97 insertions(+), 21 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f3caf84..7adabb7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -245,6 +245,10 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
+#ifdef CONFIG_INET
+	struct work_struct socket_work;
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -679,7 +683,7 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 extern struct static_key_false mem_cgroup_sockets;
 static inline bool mem_cgroup_do_sockets(void)
 {
@@ -698,7 +702,7 @@ static inline bool mem_cgroup_do_sockets(void)
 {
 	return false;
 }
-#endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_INET */
 
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 85f212e..2994c9d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -79,6 +79,9 @@ struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+/* Socket memory accounting disabled? */
+static int cgroup_memory_nosocket;
+
 /* Whether the swap controller is active */
 #ifdef CONFIG_MEMCG_SWAP
 int do_swap_account __read_mostly;
@@ -1916,6 +1919,18 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
@@ -1923,20 +1938,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
@@ -4129,6 +4137,8 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
+static void socket_work_func(struct work_struct *work);
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -4169,6 +4179,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_INET
+	INIT_WORK(&memcg->socket_work, socket_work_func);
+#endif
 	return &memcg->css;
 
 free_out:
@@ -4228,6 +4241,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
+		static_branch_enable(&mem_cgroup_sockets);
+
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
 	 * orders reading memcg->initialized against its callers
@@ -4266,6 +4282,8 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	cancel_work_sync(&memcg->socket_work);
+
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
 }
@@ -5453,8 +5471,7 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 
 DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
 
@@ -5490,6 +5507,14 @@ void sock_release_memcg(struct sock *sk)
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
@@ -5500,15 +5525,42 @@ void sock_release_memcg(struct sock *sk)
  */
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
+	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	struct page_counter *counter;
+	bool force = false;
+
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		if (page_counter_try_charge(&memcg->skmem, nr_pages,
+					    &counter)) {
+			memcg->skmem_breached = false;
+			return true;
+		}
+		page_counter_charge(&memcg->skmem, nr_pages);
+		memcg->skmem_breached = true;
+		return false;
+	}
 
-	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter)) {
-		memcg->skmem_breached = false;
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
-	page_counter_charge(&memcg->skmem, nr_pages);
-	memcg->skmem_breached = true;
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
@@ -5518,10 +5570,30 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-	page_counter_uncharge(&memcg->skmem, nr_pages);
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		page_counter_uncharge(&memcg->skmem, nr_pages);
+		return;
+	}
+
+	page_counter_uncharge(&memcg->memory, nr_pages);
+	css_put_many(&memcg->css, nr_pages);
 }
 
-#endif
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
+
+#endif /* CONFIG_INET */
 
 /*
  * subsys_initcall() for memory controller.
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
