Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2090F6B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:11:51 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so5433985pac.0
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 08:11:50 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gm1si8223442pbd.6.2014.10.20.08.11.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 08:11:39 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: remove activate_kmem_mutex
Date: Mon, 20 Oct 2014 19:11:29 +0400
Message-ID: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The activate_kmem_mutex is used to serialize memcg.kmem.limit updates,
but we already serialize them with memcg_limit_mutex so let's remove the
former.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3a203c7ec6c7..e957f0c80c6e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2618,8 +2618,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
  */
 static DEFINE_MUTEX(memcg_slab_mutex);
 
-static DEFINE_MUTEX(activate_kmem_mutex);
-
 /*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
@@ -3756,9 +3754,8 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-/* should be called with activate_kmem_mutex held */
-static int __memcg_activate_kmem(struct mem_cgroup *memcg,
-				 unsigned long nr_pages)
+static int memcg_activate_kmem(struct mem_cgroup *memcg,
+			       unsigned long nr_pages)
 {
 	int err = 0;
 	int memcg_id;
@@ -3820,17 +3817,6 @@ out:
 	return err;
 }
 
-static int memcg_activate_kmem(struct mem_cgroup *memcg,
-			       unsigned long nr_pages)
-{
-	int ret;
-
-	mutex_lock(&activate_kmem_mutex);
-	ret = __memcg_activate_kmem(memcg, nr_pages);
-	mutex_unlock(&activate_kmem_mutex);
-	return ret;
-}
-
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
@@ -3853,14 +3839,14 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	if (!parent)
 		return 0;
 
-	mutex_lock(&activate_kmem_mutex);
+	mutex_lock(&memcg_limit_mutex);
 	/*
 	 * If the parent cgroup is not kmem-active now, it cannot be activated
 	 * after this point, because it has at least one child already.
 	 */
 	if (memcg_kmem_is_active(parent))
-		ret = __memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
-	mutex_unlock(&activate_kmem_mutex);
+		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
+	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
 #else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
