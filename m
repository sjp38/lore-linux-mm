Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 681F34403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:03:53 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id o185so44644051pfb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:03:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rb5si16649673pab.125.2016.02.04.05.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 05:03:52 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/3] mm: memcontrol: report slab usage in cgroup2 memory.stat
Date: Thu, 4 Feb 2016 16:03:38 +0300
Message-ID: <bbc5780485f59f276ad61bcbcf5b7ddb027a0669.1454589800.git.vdavydov@virtuozzo.com>
In-Reply-To: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Show how much memory is used for storing reclaimable and unreclaimable
in-kernel data structures allocated from slab caches.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 Documentation/cgroup-v2.txt | 15 +++++++++++++++
 include/linux/memcontrol.h  | 21 +++++++++++++++++++++
 mm/memcontrol.c             |  8 ++++++++
 mm/slab.c                   |  8 +++++---
 mm/slab.h                   | 30 ++++++++++++++++++++++++++++--
 mm/slub.c                   |  3 ++-
 6 files changed, 79 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index ff49cf901148..e4e0c1d78cee 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -843,6 +843,11 @@ PAGE_SIZE multiple when read back.
 		Amount of memory used to cache filesystem data,
 		including tmpfs and shared memory.
 
+	  slab
+
+		Amount of memory used for storing in-kernel data
+		structures.
+
 	  sock
 
 		Amount of memory used in network transmission buffers
@@ -871,6 +876,16 @@ PAGE_SIZE multiple when read back.
 		on the internal memory management lists used by the
 		page reclaim algorithm
 
+	  slab_reclaimable
+
+		Part of "slab" that might be reclaimed, such as
+		dentries and inodes.
+
+	  slab_unreclaimable
+
+		Part of "slab" that cannot be reclaimed on memory
+		pressure.
+
 	  pgfault
 
 		Total number of page faults incurred
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f0c4bec6565b..e7af4834ffea 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -53,6 +53,8 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 	/* default hierarchy stats */
 	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
+	MEMCG_SLAB_RECLAIMABLE,
+	MEMCG_SLAB_UNRECLAIMABLE,
 	MEMCG_NR_STAT,
 };
 
@@ -883,6 +885,20 @@ static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 	if (memcg_kmem_enabled())
 		__memcg_kmem_put_cache(cachep);
 }
+
+/**
+ * memcg_kmem_update_page_stat - update kmem page state statistics
+ * @page: the page
+ * @idx: page state item to account
+ * @val: number of pages (positive or negative)
+ */
+static inline void memcg_kmem_update_page_stat(struct page *page,
+				enum mem_cgroup_stat_index idx, int val)
+{
+	if (memcg_kmem_enabled() && page->mem_cgroup)
+		this_cpu_add(page->mem_cgroup->stat->count[idx], val);
+}
+
 #else
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
@@ -928,6 +944,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
+
+static inline void memcg_kmem_update_page_stat(struct page *page,
+				enum mem_cgroup_stat_index idx, int val)
+{
+}
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 606dda49e671..b198ed5a8928 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5100,6 +5100,9 @@ static int memory_stat_show(struct seq_file *m, void *v)
 		   (u64)stat[MEM_CGROUP_STAT_RSS] * PAGE_SIZE);
 	seq_printf(m, "file %llu\n",
 		   (u64)stat[MEM_CGROUP_STAT_CACHE] * PAGE_SIZE);
+	seq_printf(m, "slab %llu\n",
+		   (u64)(stat[MEMCG_SLAB_RECLAIMABLE] +
+			 stat[MEMCG_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
 	seq_printf(m, "sock %llu\n",
 		   (u64)stat[MEMCG_SOCK] * PAGE_SIZE);
 
@@ -5120,6 +5123,11 @@ static int memory_stat_show(struct seq_file *m, void *v)
 			   mem_cgroup_lru_names[i], (u64)val * PAGE_SIZE);
 	}
 
+	seq_printf(m, "slab_reclaimable %llu\n",
+		   (u64)stat[MEMCG_SLAB_RECLAIMABLE] * PAGE_SIZE);
+	seq_printf(m, "slab_unreclaimable %llu\n",
+		   (u64)stat[MEMCG_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
+
 	/* Accumulated memory events */
 
 	seq_printf(m, "pgfault %lu\n",
diff --git a/mm/slab.c b/mm/slab.c
index ff6526e56e6a..5b1c58206143 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1569,9 +1569,10 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
  */
 static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 {
-	const unsigned long nr_freed = (1 << cachep->gfporder);
+	int order = cachep->gfporder;
+	unsigned long nr_freed = (1 << order);
 
-	kmemcheck_free_shadow(page, cachep->gfporder);
+	kmemcheck_free_shadow(page, order);
 
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		sub_zone_page_state(page_zone(page),
@@ -1588,7 +1589,8 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
-	__free_kmem_pages(page, cachep->gfporder);
+	memcg_uncharge_slab(page, order, cachep);
+	__free_pages(page, order);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
diff --git a/mm/slab.h b/mm/slab.h
index 43f89f33f9ad..124379603634 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -245,12 +245,33 @@ static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
+	int ret;
+
 	if (!memcg_kmem_enabled())
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return __memcg_kmem_charge_memcg(page, gfp, order,
-					 s->memcg_params.memcg);
+
+	ret = __memcg_kmem_charge_memcg(page, gfp, order,
+					s->memcg_params.memcg);
+	if (ret)
+		return ret;
+
+	memcg_kmem_update_page_stat(page,
+			(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+			MEMCG_SLAB_RECLAIMABLE : MEMCG_SLAB_UNRECLAIMABLE,
+			1 << order);
+	return 0;
+}
+
+static __always_inline void memcg_uncharge_slab(struct page *page, int order,
+						struct kmem_cache *s)
+{
+	memcg_kmem_update_page_stat(page,
+			(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+			MEMCG_SLAB_RECLAIMABLE : MEMCG_SLAB_UNRECLAIMABLE,
+			-(1 << order));
+	memcg_kmem_uncharge(page, order);
 }
 
 extern void slab_init_memcg_params(struct kmem_cache *);
@@ -293,6 +314,11 @@ static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 	return 0;
 }
 
+static inline void memcg_uncharge_slab(struct page *page, int order,
+				       struct kmem_cache *s)
+{
+}
+
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
diff --git a/mm/slub.c b/mm/slub.c
index 7d4da68f1291..4270cc774380 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1474,7 +1474,8 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	page_mapcount_reset(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-	__free_kmem_pages(page, order);
+	memcg_uncharge_slab(page, order, s);
+	__free_pages(page, order);
 }
 
 #define need_reserve_slab_rcu						\
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
