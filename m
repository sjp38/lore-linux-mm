Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 328206B0093
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 07:07:53 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ec20so2878489lab.24
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 04:07:52 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si15887290lal.42.2013.11.25.04.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 04:07:51 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 05/15] memcg: move stop and resume accounting functions
Date: Mon, 25 Nov 2013 16:07:38 +0400
Message-ID: <dd12f72351d8ada63c576ee809713d5e47c8187a.1385377616.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385377616.git.vdavydov@parallels.com>
References: <cover.1385377616.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.cz
Cc: glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

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
index 9ba9975..e9bdcf3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3010,6 +3010,37 @@ static struct kmem_cache *memcg_params_to_cache(struct memcg_cache_params *p)
 	return cache_from_memcg_idx(cachep, memcg_cache_idx(p->memcg));
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
@@ -3278,37 +3309,6 @@ out:
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
