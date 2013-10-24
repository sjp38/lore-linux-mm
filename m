Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D58E86B00E1
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:26 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so2409936pab.10
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:26 -0700 (PDT)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id dl5si809198pbd.146.2013.10.24.05.05.25
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:25 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 05/15] memcg: move stop and resume accounting functions
Date: Thu, 24 Oct 2013 16:04:56 +0400
Message-ID: <11b30773c2108333a34b2e869201953bad38a733.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

I need to move this up a bit, and I am doing it in a separate patch just to
reduce churn in the patch that needs it.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |   62 +++++++++++++++++++++++++++----------------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5104d1f..bb38596 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2987,6 +2987,37 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 	return cachep->memcg_params->memcg_caches[memcg_cache_idx(p->memcg)];
 }
 
+/*
+ * During the creation a new cache, we need to disable our accounting mechanism
+ * altogether. This is true even if we are not creating, but rather just
+ * enqueing new caches to be created.
+ *
+ * This is because that process will trigger allocations; some visible, like
+ * explicit kmallocs to auxiliary data structures, name strings and internal
+ * cache structures; some well concealed, like INIT_WORK() that can allocate
+ * objects during debug.
+ *
+ * If any allocation happens during memcg_kmem_get_cache, we will recurse back
+ * to it. This may not be a bounded recursion: since the first cache creation
+ * failed to complete (waiting on the allocation), we'll just try to create the
+ * cache again, failing at the same point.
+ *
+ * memcg_kmem_get_cache is prepared to abort after seeing a positive count of
+ * memcg_kmem_skip_account. So we enclose anything that might allocate memory
+ * inside the following two functions.
+ */
+static inline void memcg_stop_kmem_account(void)
+{
+	VM_BUG_ON(!current->mm);
+	current->memcg_kmem_skip_account++;
+}
+
+static inline void memcg_resume_kmem_account(void)
+{
+	VM_BUG_ON(!current->mm);
+	current->memcg_kmem_skip_account--;
+}
+
 #ifdef CONFIG_SLABINFO
 static int mem_cgroup_slabinfo_read(struct cgroup_subsys_state *css,
 				    struct cftype *cft, struct seq_file *m)
@@ -3262,37 +3293,6 @@ out:
 	kfree(s->memcg_params);
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
 static void kmem_cache_destroy_work_func(struct work_struct *w)
 {
 	struct kmem_cache *cachep;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
