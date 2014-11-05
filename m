Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA8E6B0074
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 08:44:57 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so785892pab.41
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 05:44:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sl3si3063408pac.138.2014.11.05.05.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Nov 2014 05:44:55 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/3] memcg: turn memcg_kmem_skip_account into a bit field
Date: Wed, 5 Nov 2014 16:44:43 +0300
Message-ID: <bb4c78a617a67231e539400d7deb2e192c39feb8.1415194280.git.vdavydov@parallels.com>
In-Reply-To: <9ac4c9e767d437f744bb61feb7e042c93c67f727.1415194280.git.vdavydov@parallels.com>
References: <9ac4c9e767d437f744bb61feb7e042c93c67f727.1415194280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It isn't supposed to stack, so turn it into a bit-field to save 4 bytes
on the task_struct.

Also, remove the memcg_stop/resume_kmem_account helpers - it is clearer
to set/clear the flag inline. Regarding the overwhelming comment to the
helpers, which is removed by this patch too, we already have a compact
yet accurate explanation in memcg_schedule_cache_create, no need in yet
another one.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/sched.h |    7 +++++--
 mm/memcontrol.c       |   35 ++---------------------------------
 2 files changed, 7 insertions(+), 35 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 40497a2ed2d4..7b08b0240736 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1364,6 +1364,10 @@ struct task_struct {
 	unsigned sched_reset_on_fork:1;
 	unsigned sched_contributes_to_load:1;
 
+#ifdef CONFIG_MEMCG_KMEM
+	unsigned memcg_kmem_skip_account:1;
+#endif
+
 	unsigned long atomic_flags; /* Flags needing atomic access. */
 
 	pid_t pid;
@@ -1684,8 +1688,7 @@ struct task_struct {
 	/* bitmask and counter of trace recursion */
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
-#ifdef CONFIG_MEMCG /* memcg uses this to do batch job */
-	unsigned int memcg_kmem_skip_account;
+#ifdef CONFIG_MEMCG
 	struct memcg_oom_info {
 		struct mem_cgroup *memcg;
 		gfp_t gfp_mask;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b3fe830fdb29..52d1e933bb9f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2575,37 +2575,6 @@ void memcg_update_array_size(int num)
 	memcg_limited_groups_array_size = num;
 }
 
-/*
- * During the creation a new cache, we need to disable our accounting mechanism
- * altogether. This is true even if we are not creating, but rather just
- * enqueing new caches to be created.
- *
- * This is because that process will trigger allocations; some visible, like
- * explicit kmallocs to auxiliary data structures, name strings and internal
- * cache structures; some well concealed, like INIT_WORK() that can allocate
- * objects during debug.
- *
- * If any allocation happens during memcg_kmem_get_cache, we will recurse back
- * to it. This may not be a bounded recursion: since the first cache creation
- * failed to complete (waiting on the allocation), we'll just try to create the
- * cache again, failing at the same point.
- *
- * memcg_kmem_get_cache is prepared to abort after seeing a positive count of
- * memcg_kmem_skip_account. So we enclose anything that might allocate memory
- * inside the following two functions.
- */
-static inline void memcg_stop_kmem_account(void)
-{
-	VM_BUG_ON(!current->mm);
-	current->memcg_kmem_skip_account++;
-}
-
-static inline void memcg_resume_kmem_account(void)
-{
-	VM_BUG_ON(!current->mm);
-	current->memcg_kmem_skip_account--;
-}
-
 struct memcg_cache_create_work {
 	struct mem_cgroup *memcg;
 	struct kmem_cache *cachep;
@@ -2660,9 +2629,9 @@ static void memcg_schedule_cache_create(struct mem_cgroup *memcg,
 	 * this point we can't allow ourselves back into memcg_kmem_get_cache,
 	 * the safest choice is to do it like this, wrapping the whole function.
 	 */
-	memcg_stop_kmem_account();
+	current->memcg_kmem_skip_account = 1;
 	__memcg_schedule_cache_create(memcg, cachep);
-	memcg_resume_kmem_account();
+	current->memcg_kmem_skip_account = 0;
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
