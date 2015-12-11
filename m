Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0A06B0254
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:54:31 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id c201so87659092wme.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:54:31 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hb7si27649029wjc.71.2015.12.11.11.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:54:30 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Date: Fri, 11 Dec 2015 14:54:11 -0500
Message-Id: <1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

What CONFIG_INET and CONFIG_LEGACY_KMEM guard inside the memory
controller code is insignificant, having these conditionals is not
worth the complication and fragility that comes with them.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 14 +++++--------
 init/Kconfig               | 26 +++--------------------
 mm/memcontrol.c            | 52 +++-------------------------------------------
 mm/vmpressure.c            |  2 --
 4 files changed, 11 insertions(+), 83 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2bb14d02..47995b4 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -233,9 +233,11 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_stat_cpu __percpu *stat;
 
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
+	unsigned long		socket_pressure;
+
+	/* Legacy tcp memory accounting */
 	struct cg_proto tcp_mem;
-#endif
+
 #ifndef CONFIG_SLOB
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
@@ -254,10 +256,6 @@ struct mem_cgroup {
 	struct wb_domain cgwb_domain;
 #endif
 
-#ifdef CONFIG_INET
-	unsigned long		socket_pressure;
-#endif
-
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
@@ -712,15 +710,13 @@ void sock_update_memcg(struct sock *sk);
 void sock_release_memcg(struct sock *sk);
 bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages);
-#if defined(CONFIG_MEMCG) && defined(CONFIG_INET)
+#ifdef CONFIG_MEMCG
 extern struct static_key_false memcg_sockets_enabled_key;
 #define mem_cgroup_sockets_enabled static_branch_unlikely(&memcg_sockets_enabled_key)
 static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 {
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (memcg->tcp_mem.memory_pressure)
 		return true;
-#endif
 	do {
 		if (time_before(jiffies, memcg->socket_pressure))
 			return true;
diff --git a/init/Kconfig b/init/Kconfig
index e8cdf02..b8fe7586 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1057,25 +1057,6 @@ config MEMCG_SWAP_ENABLED
 	  For those who want to have the feature enabled by default should
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
-config MEMCG_LEGACY_KMEM
-       bool
-config MEMCG_KMEM
-	bool "Legacy Memory Resource Controller Kernel Memory accounting"
-	depends on MEMCG
-	depends on SLUB || SLAB
-	select MEMCG_LEGACY_KMEM
-	help
-	  The Kernel Memory extension for Memory Resource Controller can limit
-	  the amount of memory used by kernel objects in the system. Those are
-	  fundamentally different from the entities handled by the standard
-	  Memory Controller, which are page-based, and can be swapped. Users of
-	  the kmem extension can use it to guarantee that no group of processes
-	  will ever exhaust kernel resources alone.
-
-	  This option affects the ORIGINAL cgroup interface. The cgroup2 memory
-	  controller includes important in-kernel memory consumers per default.
-
-	  If you're using cgroup2, say N.
 
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
@@ -1225,10 +1206,9 @@ config USER_NS
 	  to provide different user info for different servers.
 
 	  When user namespaces are enabled in the kernel it is
-	  recommended that the MEMCG and MEMCG_KMEM options also be
-	  enabled and that user-space use the memory control groups to
-	  limit the amount of memory a memory unprivileged users can
-	  use.
+	  recommended that the MEMCG option also be enabled and that
+	  user-space use the memory control groups to limit the amount
+	  of memory a memory unprivileged users can use.
 
 	  If unsure, say N.
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5cf7fd2..422ff3f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2821,11 +2821,9 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	case _KMEM:
 		counter = &memcg->kmem;
 		break;
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	case _TCP:
 		counter = &memcg->tcp_mem.memory_allocated;
 		break;
-#endif
 	default:
 		BUG();
 	}
@@ -2985,7 +2983,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 }
 #endif /* !CONFIG_SLOB */
 
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
@@ -3003,16 +3000,7 @@ out:
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
-#else
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
-{
-	return -EINVAL;
-}
-#endif /* CONFIG_MEMCG_LEGACY_KMEM */
 
-
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 {
 	int ret;
@@ -3047,12 +3035,6 @@ out:
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
-#else
-static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
-{
-	return -EINVAL;
-}
-#endif /* CONFIG_MEMCG_LEGACY_KMEM && CONFIG_INET */
 
 /*
  * The user of this function is...
@@ -3115,11 +3097,9 @@ static ssize_t mem_cgroup_reset(struct kernfs_open_file *of, char *buf,
 	case _KMEM:
 		counter = &memcg->kmem;
 		break;
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	case _TCP:
 		counter = &memcg->tcp_mem.memory_allocated;
 		break;
-#endif
 	default:
 		BUG();
 	}
@@ -4072,7 +4052,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_numa_stat_show,
 	},
 #endif
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	{
 		.name = "kmem.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
@@ -4105,7 +4084,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_slab_show,
 	},
 #endif
-#ifdef CONFIG_INET
 	{
 		.name = "kmem.tcp.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_TCP, RES_LIMIT),
@@ -4129,8 +4107,6 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.write = mem_cgroup_reset,
 		.read_u64 = mem_cgroup_read_u64,
 	},
-#endif
-#endif
 	{ },	/* terminate */
 };
 
@@ -4258,15 +4234,13 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
+	memcg->socket_pressure = jiffies;
 #ifndef CONFIG_SLOB
 	memcg->kmemcg_id = -1;
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
-#ifdef CONFIG_INET
-	memcg->socket_pressure = jiffies;
-#endif
 	return &memcg->css;
 
 free_out:
@@ -4299,10 +4273,8 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, &parent->memsw);
 		page_counter_init(&memcg->kmem, &parent->kmem);
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 		page_counter_init(&memcg->tcp_mem.memory_allocated,
 				  &parent->tcp_mem.memory_allocated);
-#endif
 
 		/*
 		 * No need to take a reference to the parent because cgroup
@@ -4314,9 +4286,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		memcg->soft_limit = PAGE_COUNTER_MAX;
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 		page_counter_init(&memcg->tcp_mem.memory_allocated, NULL);
-#endif
 		/*
 		 * Deeper hierachy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
@@ -4331,10 +4301,8 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
-#ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
-#endif
 
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
@@ -4374,17 +4342,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
-#ifdef CONFIG_INET
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_dec(&memcg_sockets_enabled_key);
-#endif
-
-	memcg_free_kmem(memcg);
 
-#if defined(CONFIG_MEMCG_LEGACY_KMEM) && defined(CONFIG_INET)
 	if (memcg->tcp_mem.active)
 		static_branch_dec(&memcg_sockets_enabled_key);
-#endif
 
 	memcg_free_kmem(memcg);
 
@@ -5585,8 +5547,6 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
 	commit_charge(newpage, memcg, true);
 }
 
-#ifdef CONFIG_INET
-
 DEFINE_STATIC_KEY_FALSE(memcg_sockets_enabled_key);
 EXPORT_SYMBOL(memcg_sockets_enabled_key);
 
@@ -5612,10 +5572,8 @@ void sock_update_memcg(struct sock *sk)
 	memcg = mem_cgroup_from_task(current);
 	if (memcg == root_mem_cgroup)
 		goto out;
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && !memcg->tcp_mem.active)
 		goto out;
-#endif
 	if (css_tryget_online(&memcg->css))
 		sk->sk_memcg = memcg;
 out:
@@ -5641,7 +5599,6 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
 	gfp_t gfp_mask = GFP_KERNEL;
 
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		struct page_counter *counter;
 
@@ -5654,7 +5611,7 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 		memcg->tcp_mem.memory_pressure = 1;
 		return false;
 	}
-#endif
+
 	/* Don't block in the packet receive path */
 	if (in_softirq())
 		gfp_mask = GFP_NOWAIT;
@@ -5673,19 +5630,16 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
-#ifdef CONFIG_MEMCG_LEGACY_KMEM
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
 		page_counter_uncharge(&memcg->tcp_mem.memory_allocated,
 				      nr_pages);
 		return;
 	}
-#endif
+
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	css_put_many(&memcg->css, nr_pages);
 }
 
-#endif /* CONFIG_INET */
-
 static int __init cgroup_memory(char *s)
 {
 	char *token;
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 8cdeebe..506f03e 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -275,7 +275,6 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 
 		level = vmpressure_calc_level(scanned, reclaimed);
 
-#ifdef CONFIG_INET
 		if (level > VMPRESSURE_LOW) {
 			/*
 			 * Let the socket buffer allocator know that
@@ -287,7 +286,6 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
 			 */
 			memcg->socket_pressure = jiffies + HZ;
 		}
-#endif
 	}
 }
 
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
