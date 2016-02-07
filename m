Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 965488309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:27:56 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id c10so30334499pfc.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:27:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c4si11525435pfj.47.2016.02.07.09.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 09:27:55 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 3/5] mm: memcontrol: zap memcg_kmem_online helper
Date: Sun, 7 Feb 2016 20:27:33 +0300
Message-ID: <6ae345a21265e07951aa632314dfc610e40ea713.1454864628.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1454864628.git.vdavydov@virtuozzo.com>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As kmem accounting is now either enabled for all cgroups or disabled
system-wide, there's no point in having memcg_kmem_online() helper -
instead one can use memcg_kmem_enabled() and mem_cgroup_online(), as
shrink_slab() now does.

There are only two places left where this helper is used -
__memcg_kmem_charge() and memcg_create_kmem_cache(). The former can only
be called if memcg_kmem_enabled() returned true. Since the cgroup it
operates on is online, mem_cgroup_is_root() check will be enough.

memcg_create_kmem_cache() can't use mem_cgroup_online() helper instead
of memcg_kmem_online(), because it relies on the fact that in
memcg_offline_kmem() memcg->kmem_state is changed before
memcg_deactivate_kmem_caches() is called, but there we can just
open-code the check.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 10 ----------
 mm/memcontrol.c            |  2 +-
 mm/slab_common.c           |  2 +-
 3 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d6300313b298..bc8e4e22f58f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -795,11 +795,6 @@ static inline bool memcg_kmem_enabled(void)
 	return static_branch_unlikely(&memcg_kmem_enabled_key);
 }
 
-static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
-{
-	return memcg->kmem_state == KMEM_ONLINE;
-}
-
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -909,11 +904,6 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
-static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
-{
-	return false;
-}
-
 static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
 	return 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 28d1b1e9d4fb..341bf86d26c2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2346,7 +2346,7 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	int ret = 0;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-	if (memcg_kmem_online(memcg))
+	if (!mem_cgroup_is_root(memcg))
 		ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	css_put(&memcg->css);
 	return ret;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 6afb2263a5c5..8addc3c4df37 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -510,7 +510,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (!memcg_kmem_online(memcg))
+	if (memcg->kmem_state != KMEM_ONLINE)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
