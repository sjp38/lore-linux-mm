Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8B93982F65
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:10 -0400 (EDT)
Received: by wikq8 with SMTP id q8so12982519wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:10 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id eq8si15963676wjc.105.2015.10.21.21.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:22:09 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/8] mm: memcontrol: account socket memory on unified hierarchy
Date: Thu, 22 Oct 2015 00:21:33 -0400
Message-Id: <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Socket memory can be a significant share of overall memory consumed by
common workloads. In order to provide reasonable resource isolation
out-of-the-box in the unified hierarchy, this type of memory needs to
be accounted and tracked per default in the memory controller.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 16 ++++++--
 mm/memcontrol.c            | 95 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 87 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5b72f83..6f1e0f8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -244,6 +244,10 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
+#ifdef CONFIG_INET
+	struct work_struct socket_work;
+#endif
+
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -676,11 +680,15 @@ static inline void mem_cgroup_wb_stats(struct bdi_writeback *wb,
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 struct sock;
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
-extern struct static_key_false mem_cgroup_sockets;
+#ifdef CONFIG_INET
+extern struct static_key_true mem_cgroup_sockets;
 static inline bool mem_cgroup_do_sockets(void)
 {
-	return static_branch_unlikely(&mem_cgroup_sockets);
+	if (mem_cgroup_disabled())
+		return false;
+	if (!static_branch_likely(&mem_cgroup_sockets))
+		return false;
+	return true;
 }
 void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
@@ -706,7 +714,7 @@ static inline void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg,
 					     unsigned int nr_pages)
 {
 }
-#endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_INET */
 
 #ifdef CONFIG_MEMCG_KMEM
 extern struct static_key memcg_kmem_enabled_key;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3789050..cb1d6aa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1916,6 +1916,18 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
@@ -1923,20 +1935,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
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
@@ -4129,6 +4134,8 @@ struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
 }
 EXPORT_SYMBOL(parent_mem_cgroup);
 
+static void socket_work_func(struct work_struct *work);
+
 static struct cgroup_subsys_state * __ref
 mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
@@ -4169,6 +4176,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+#ifdef CONFIG_INET
+	INIT_WORK(&memcg->socket_work, socket_work_func);
+#endif
 	return &memcg->css;
 
 free_out:
@@ -4266,6 +4276,8 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	cancel_work_sync(&memcg->socket_work);
+
 	memcg_destroy_kmem(memcg);
 	__mem_cgroup_free(memcg);
 }
@@ -4948,10 +4960,15 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
 	 * guarantees that @root doesn't have any children, so turning it
 	 * on for the root memcg is enough.
 	 */
-	if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
+	if (cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		root_mem_cgroup->use_hierarchy = true;
-	else
+#ifdef CONFIG_INET
+		/* unified hierarchy always counts skmem */
+		static_branch_enable(&mem_cgroup_sockets);
+#endif
+	} else {
 		root_mem_cgroup->use_hierarchy = false;
+	}
 }
 
 static u64 memory_current_read(struct cgroup_subsys_state *css,
@@ -5453,10 +5470,9 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-/* Writing them here to avoid exposing memcg's inner layout */
-#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
+#ifdef CONFIG_INET
 
-DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
+DEFINE_STATIC_KEY_TRUE(mem_cgroup_sockets);
 
 void sock_update_memcg(struct sock *sk)
 {
@@ -5490,6 +5506,14 @@ void sock_release_memcg(struct sock *sk)
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
@@ -5500,13 +5524,38 @@ void sock_release_memcg(struct sock *sk)
  */
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
+	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	struct page_counter *counter;
+	bool force = false;
 
-	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
+	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
+		if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
+			return true;
+		page_counter_charge(&memcg->skmem, nr_pages);
+		return false;
+	}
+
+	if (consume_stock(memcg, nr_pages))
 		return true;
+retry:
+	if (page_counter_try_charge(&memcg->memory, batch, &counter))
+		goto done;
 
-	page_counter_charge(&memcg->skmem, nr_pages);
-	return false;
+	if (batch > nr_pages) {
+		batch = nr_pages;
+		goto retry;
+	}
+
+	force = true;
+	page_counter_charge(&memcg->memory, batch);
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
@@ -5516,10 +5565,16 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
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
+#endif /* CONFIG_INET */
 
 /*
  * subsys_initcall() for memory controller.
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
