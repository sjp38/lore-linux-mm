Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ACEBC6B0275
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:09:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t11-v6so1071142edq.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:09:03 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30136.outbound.protection.outlook.com. [40.107.3.136])
        by mx.google.com with ESMTPS id u24-v6si1156996edi.415.2018.07.03.08.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 08:09:01 -0700 (PDT)
Subject: [PATCH v8 02/17] mm: Introduce CONFIG_MEMCG_KMEM as combination of
 CONFIG_MEMCG && !CONFIG_SLOB
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 03 Jul 2018 18:08:56 +0300
Message-ID: <153063053670.1818.15013136946600481138.stgit@localhost.localdomain>
In-Reply-To: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

This patch introduces new config option, which is used
to replace repeating CONFIG_MEMCG && !CONFIG_SLOB pattern.
Next patches add a little more memcg+kmem related code,
so let's keep the defines more clearly.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/list_lru.h   |    4 ++--
 include/linux/memcontrol.h |    6 +++---
 include/linux/sched.h      |    2 +-
 include/linux/slab.h       |    2 +-
 init/Kconfig               |    5 +++++
 mm/list_lru.c              |    8 ++++----
 mm/memcontrol.c            |   16 ++++++++--------
 mm/slab.h                  |    6 +++---
 mm/slab_common.c           |    8 ++++----
 9 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index c2161c3a1809..5d7f951f4f32 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -42,7 +42,7 @@ struct list_lru_node {
 	spinlock_t		lock;
 	/* global list, used for the root cgroup in cgroup aware lrus */
 	struct list_lru_one	lru;
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
 	struct list_lru_memcg	__rcu *memcg_lrus;
 #endif
@@ -52,7 +52,7 @@ struct list_lru_node {
 struct list_lru {
 	struct list_lru_node	*node;
 	bool			lock_irq;
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
 #endif
 };
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 04b18ce4f1fd..62309f180ee6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -280,7 +280,7 @@ struct mem_cgroup {
 	bool			tcpmem_active;
 	int			tcpmem_pressure;
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
@@ -1253,7 +1253,7 @@ int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void memcg_kmem_uncharge(struct page *page, int order);
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
 
@@ -1306,6 +1306,6 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 251245601719..bd5212523af0 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -723,7 +723,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_MEMCG
 	unsigned			memcg_may_oom:1;
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	unsigned			memcg_kmem_skip_account:1;
 #endif
 #endif
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 14e3fe4bd6a1..ed9cbddeb4a6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -97,7 +97,7 @@
 # define SLAB_FAILSLAB		0
 #endif
 /* Account to memcg */
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 # define SLAB_ACCOUNT		((slab_flags_t __force)0x04000000U)
 #else
 # define SLAB_ACCOUNT		0
diff --git a/init/Kconfig b/init/Kconfig
index 4fac26b0efba..ce683fcbc701 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -691,6 +691,11 @@ config MEMCG_SWAP_ENABLED
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
 
+config MEMCG_KMEM
+	bool
+	depends on MEMCG && !SLOB
+	default y
+
 config BLK_CGROUP
 	bool "IO controller"
 	depends on BLOCK
diff --git a/mm/list_lru.c b/mm/list_lru.c
index b93f64f25414..6743cdb76ea6 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -13,7 +13,7 @@
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 static LIST_HEAD(list_lrus);
 static DEFINE_MUTEX(list_lrus_mutex);
 
@@ -104,7 +104,7 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 {
 	return &nlru->lru;
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -297,7 +297,7 @@ static void init_one_lru(struct list_lru_one *l)
 	l->nr_items = 0;
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 static void __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
 					  int begin, int end)
 {
@@ -556,7 +556,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 static void memcg_destroy_list_lru(struct list_lru *lru)
 {
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 int __list_lru_init(struct list_lru *lru, bool memcg_aware, bool lock_irq,
 		    struct lock_class_key *key)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 20220b164616..31d203099af8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -251,7 +251,7 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
@@ -305,7 +305,7 @@ EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
 struct workqueue_struct *memcg_kmem_cache_wq;
 
-#endif /* !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
@@ -2182,7 +2182,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -2447,7 +2447,7 @@ void memcg_kmem_uncharge(struct page *page, int order)
 
 	css_put_many(&memcg->css, nr_pages);
 }
-#endif /* !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
@@ -3060,7 +3060,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int memcg_id;
@@ -3160,7 +3160,7 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 static void memcg_free_kmem(struct mem_cgroup *memcg)
 {
 }
-#endif /* !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 static int memcg_update_kmem_max(struct mem_cgroup *memcg,
 				 unsigned long max)
@@ -4464,7 +4464,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
 	memcg->socket_pressure = jiffies;
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -6330,7 +6330,7 @@ static int __init mem_cgroup_init(void)
 {
 	int cpu, node;
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	/*
 	 * Kmem cache creation is mostly done with the slab_mutex held,
 	 * so use a workqueue with limited concurrency to avoid stalling
diff --git a/mm/slab.h b/mm/slab.h
index a6545332cc86..2215eec16c0a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -203,7 +203,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 
 /* List of all root caches. */
 extern struct list_head		slab_root_caches;
@@ -296,7 +296,7 @@ extern void memcg_link_cache(struct kmem_cache *s);
 extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 				void (*deact_fn)(struct kmem_cache *));
 
-#else /* CONFIG_MEMCG && !CONFIG_SLOB */
+#else /* CONFIG_MEMCG_KMEM */
 
 /* If !memcg, all caches are root. */
 #define slab_root_caches	slab_caches
@@ -351,7 +351,7 @@ static inline void memcg_link_cache(struct kmem_cache *s)
 {
 }
 
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2296caf87bfb..fea3376f9816 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -127,7 +127,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 	return i;
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 
 LIST_HEAD(slab_root_caches);
 
@@ -256,7 +256,7 @@ static inline void destroy_memcg_params(struct kmem_cache *s)
 static inline void memcg_unlink_cache(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 /*
  * Figure out what the alignment of the objects will be given a set of
@@ -584,7 +584,7 @@ static int shutdown_cache(struct kmem_cache *s)
 	return 0;
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 /*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
@@ -861,7 +861,7 @@ static inline int shutdown_memcg_caches(struct kmem_cache *s)
 static inline void flush_memcg_workqueue(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
