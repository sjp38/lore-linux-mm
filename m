Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 940558E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 20:45:13 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a12-v6so1755815ybe.21
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 17:45:13 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 133-v6sor2339360ywm.438.2018.09.18.17.45.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 17:45:12 -0700 (PDT)
Date: Tue, 18 Sep 2018 17:45:01 -0700
Message-Id: <20180919004501.178023-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] memcg: remove memcg_kmem_skip_account
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

The flag memcg_kmem_skip_account was added during the era of opt-out
kmem accounting. There is no need for such flag in the opt-in world as
there aren't any __GFP_ACCOUNT allocations within
memcg_create_cache_enqueue().

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/sched.h |  3 ---
 mm/memcontrol.c       | 24 +-----------------------
 2 files changed, 1 insertion(+), 26 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 977cb57d7bc9..c30e3cd4b81c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -723,9 +723,6 @@ struct task_struct {
 #endif
 #ifdef CONFIG_MEMCG
 	unsigned			in_user_fault:1;
-#ifdef CONFIG_MEMCG_KMEM
-	unsigned			memcg_kmem_skip_account:1;
-#endif
 #endif
 #ifdef CONFIG_COMPAT_BRK
 	unsigned			brk_randomized:1;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..bde698a0bb99 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2460,7 +2460,7 @@ static void memcg_kmem_cache_create_func(struct work_struct *w)
 /*
  * Enqueue the creation of a per-memcg kmem_cache.
  */
-static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
+static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 					       struct kmem_cache *cachep)
 {
 	struct memcg_kmem_cache_create_work *cw;
@@ -2478,25 +2478,6 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
 	queue_work(memcg_kmem_cache_wq, &cw->work);
 }
 
-static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
-					     struct kmem_cache *cachep)
-{
-	/*
-	 * We need to stop accounting when we kmalloc, because if the
-	 * corresponding kmalloc cache is not yet created, the first allocation
-	 * in __memcg_schedule_kmem_cache_create will recurse.
-	 *
-	 * However, it is better to enclose the whole function. Depending on
-	 * the debugging options enabled, INIT_WORK(), for instance, can
-	 * trigger an allocation. This too, will make us recurse. Because at
-	 * this point we can't allow ourselves back into memcg_kmem_get_cache,
-	 * the safest choice is to do it like this, wrapping the whole function.
-	 */
-	current->memcg_kmem_skip_account = 1;
-	__memcg_schedule_kmem_cache_create(memcg, cachep);
-	current->memcg_kmem_skip_account = 0;
-}
-
 static inline bool memcg_kmem_bypass(void)
 {
 	if (in_interrupt() || !current->mm || (current->flags & PF_KTHREAD))
@@ -2531,9 +2512,6 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
 	if (memcg_kmem_bypass())
 		return cachep;
 
-	if (current->memcg_kmem_skip_account)
-		return cachep;
-
 	memcg = get_mem_cgroup_from_current();
 	kmemcg_id = READ_ONCE(memcg->kmemcg_id);
 	if (kmemcg_id < 0)
-- 
2.19.0.397.gdd90340f6a-goog
