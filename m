Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBFB6B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 12:10:53 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so932349pab.7
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 09:10:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ye3si2702696pab.141.2014.12.09.09.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Dec 2014 09:10:51 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap __memcg_{charge,uncharge}_slab
Date: Tue, 9 Dec 2014 20:10:39 +0300
Message-ID: <1418145039-31053-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

They are simple wrappers around memcg_{charge,uncharge}_kmem, so let's
zap them and call these functions directly.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    5 +++--
 mm/memcontrol.c            |   21 +++------------------
 mm/slab.h                  |    4 ++--
 3 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7c95af8d552c..18ccb2988979 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -403,8 +403,9 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep);
 void __memcg_kmem_put_cache(struct kmem_cache *cachep);
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
+		      unsigned long nr_pages);
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
 
 int __memcg_cleanup_cache_params(struct kmem_cache *s);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09c4838b24f0..e9086513a42f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2494,8 +2494,8 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 	return cache_from_memcg_idx(cachep, memcg_cache_id(p->memcg));
 }
 
-static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
-			     unsigned long nr_pages)
+int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
+		      unsigned long nr_pages)
 {
 	struct page_counter *counter;
 	int ret = 0;
@@ -2532,8 +2532,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 	return ret;
 }
 
-static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
-				unsigned long nr_pages)
+void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages)
 {
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
@@ -2766,20 +2765,6 @@ static void memcg_schedule_register_cache(struct mem_cgroup *memcg,
 	current->memcg_kmem_skip_account = 0;
 }
 
-int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order)
-{
-	unsigned int nr_pages = 1 << order;
-
-	return memcg_charge_kmem(cachep->memcg_params->memcg, gfp, nr_pages);
-}
-
-void __memcg_uncharge_slab(struct kmem_cache *cachep, int order)
-{
-	unsigned int nr_pages = 1 << order;
-
-	memcg_uncharge_kmem(cachep->memcg_params->memcg, nr_pages);
-}
-
 /*
  * Return the kmem_cache we're supposed to use for a slab allocation.
  * We try to use the current memcg's version of the cache.
diff --git a/mm/slab.h b/mm/slab.h
index 1cf4005482dd..90430d6f665e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -235,7 +235,7 @@ static __always_inline int memcg_charge_slab(struct kmem_cache *s,
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return __memcg_charge_slab(s, gfp, order);
+	return memcg_charge_kmem(s->memcg_params->memcg, gfp, 1 << order);
 }
 
 static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
@@ -244,7 +244,7 @@ static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 		return;
 	if (is_root_cache(s))
 		return;
-	__memcg_uncharge_slab(s, order);
+	memcg_uncharge_kmem(s->memcg_params->memcg, 1 << order);
 }
 #else
 static inline bool is_root_cache(struct kmem_cache *s)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
