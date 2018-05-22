Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C942D6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:07:44 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c4-v6so18492165qtp.9
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:07:44 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50117.outbound.protection.outlook.com. [40.107.5.117])
        by mx.google.com with ESMTPS id j7-v6si2855015qtn.272.2018.05.22.03.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 03:07:42 -0700 (PDT)
Subject: [PATCH v7 02/17] mm: Introduce CONFIG_MEMCG_KMEM as combination of
 CONFIG_MEMCG && !CONFIG_SLOB
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 May 2018 13:07:33 +0300
Message-ID: <152698365328.3393.18066403280990272261.stgit@localhost.localdomain>
In-Reply-To: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

This patch introduces new config option, which is used
to replace repeating CONFIG_MEMCG && !CONFIG_SLOB pattern.
Next patches add a little more memcg+kmem related code,
so let's keep the defines more clearly.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
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
index 96def9d15b1b..2d23b5b745be 100644
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
@@ -51,7 +51,7 @@ struct list_lru_node {
 
 struct list_lru {
 	struct list_lru_node	*node;
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 	struct list_head	list;
 #endif
 };
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c6d2ca859802..996469bc2b82 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -264,7 +264,7 @@ struct mem_cgroup {
 	bool			tcpmem_active;
 	int			tcpmem_pressure;
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
@@ -1230,7 +1230,7 @@ int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void memcg_kmem_uncharge(struct page *page, int order);
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
 
@@ -1283,6 +1283,6 @@ static inline void memcg_put_cache_ids(void)
 {
 }
 
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c4e70e8481c3..0ccdbdec1e5b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -722,7 +722,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_MEMCG
 	unsigned			memcg_may_oom:1;
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	unsigned			memcg_kmem_skip_account:1;
 #endif
 #endif
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9ebe659bd4a5..5b63d08a0e43 100644
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
index 44e62e0dc51f..bcea6671a3ff 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -680,6 +680,11 @@ config MEMCG_SWAP_ENABLED
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
index 37d712924e56..232bb637cf02 100644
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
 
 int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 		    struct lock_class_key *key)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdb8028c806c..fc67e43849eb 100644
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
@@ -2123,7 +2123,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -2388,7 +2388,7 @@ void memcg_kmem_uncharge(struct page *page, int order)
 
 	css_put_many(&memcg->css, nr_pages);
 }
-#endif /* !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
@@ -3001,7 +3001,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int memcg_id;
@@ -3101,7 +3101,7 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
 static void memcg_free_kmem(struct mem_cgroup *memcg)
 {
 }
-#endif /* !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 static int memcg_update_kmem_max(struct mem_cgroup *memcg,
 				 unsigned long max)
@@ -4405,7 +4405,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
 	memcg->socket_pressure = jiffies;
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -6322,7 +6322,7 @@ static int __init mem_cgroup_init(void)
 {
 	int cpu, node;
 
-#ifndef CONFIG_SLOB
+#ifdef CONFIG_MEMCG_KMEM
 	/*
 	 * Kmem cache creation is mostly done with the slab_mutex held,
 	 * so use a workqueue with limited concurrency to avoid stalling
diff --git a/mm/slab.h b/mm/slab.h
index 68bdf498da3b..58c6c1c2a78e 100644
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
index b0dd9db1eb2f..400e26697bb6 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -127,7 +127,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 	return i;
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 
 LIST_HEAD(slab_root_caches);
 
@@ -255,7 +255,7 @@ static inline void destroy_memcg_params(struct kmem_cache *s)
 static inline void memcg_unlink_cache(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 /*
  * Figure out what the alignment of the objects will be given a set of
@@ -579,7 +579,7 @@ static int shutdown_cache(struct kmem_cache *s)
 	return 0;
 }
 
-#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
+#ifdef CONFIG_MEMCG_KMEM
 /*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
@@ -828,7 +828,7 @@ static inline int shutdown_memcg_caches(struct kmem_cache *s)
 {
 	return 0;
 }
-#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+#endif /* CONFIG_MEMCG_KMEM */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
