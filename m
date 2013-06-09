Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AF47A6B0032
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 08:46:13 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id o10so3094318lbi.25
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 05:46:11 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v2 1/2] memcg: also test for skip accounting at the page allocation level
Date: Sun,  9 Jun 2013 16:45:53 +0400
Message-Id: <1370781954-9972-2-git-send-email-glommer@openvz.org>
In-Reply-To: <1370781954-9972-1-git-send-email-glommer@openvz.org>
References: <1370781954-9972-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suze.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@openvz.org>

Disabling accounting is only relevant for some specific memcg internal
allocations. Therefore we would initially not have such check at
memcg_kmem_newpage_charge, since direct calls to the page allocator that are
marked with GFP_KMEMCG only happen outside memcg core. We are mostly concerned
with cache allocations and by having this test at memcg_kmem_get_cache we are
already able to relay the allocation to the root cache and bypass the memcg
caches altogether.

There is one exception, though: the SLUB allocator does not create large order
caches, but rather service large kmallocs directly from the page allocator.
Therefore, the following sequence, when backed by the SLUB allocator:

	memcg_stop_kmem_account();
	kmalloc(<large_number>)
	memcg_resume_kmem_account();

would effectively ignore the fact that we should skip accounting,
since it will drive us directly to this function without passing
through the cache selector memcg_kmem_get_cache. Such large
allocations are extremely rare but can happen, for instance, for the
cache arrays.

This was never a problem in practice, because we weren't skipping
accounting for the cache arrays. All the allocations we were skipping
were fairly small. However, the fact that we were not skipping those
allocations are a problem and can prevent the memcgs from going away.
As we fix that, we need to make sure that the fix will also work with
the SLUB allocator.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reported-by: Michal Hocko <mhocko@suze.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5d8b93a..dbabe4d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3974,6 +3974,34 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	int ret;
 
 	*_memcg = NULL;
+
+	/*
+	 * Disabling accounting is only relevant for some specific memcg
+	 * internal allocations. Therefore we would initially not have such
+	 * check here, since direct calls to the page allocator that are marked
+	 * with GFP_KMEMCG only happen outside memcg core. We are mostly
+	 * concerned with cache allocations, and by having this test at
+	 * memcg_kmem_get_cache, we are already able to relay the allocation to
+	 * the root cache and bypass the memcg cache altogether.
+	 *
+	 * There is one exception, though: the SLUB allocator does not create
+	 * large order caches, but rather service large kmallocs directly from
+	 * the page allocator. Therefore, the following sequence when backed by
+	 * the SLUB allocator:
+	 *
+	 * 	memcg_stop_kmem_account();
+	 * 	kmalloc(<large_number>)
+	 * 	memcg_resume_kmem_account();
+	 *
+	 * would effectively ignore the fact that we should skip accounting,
+	 * since it will drive us directly to this function without passing
+	 * through the cache selector memcg_kmem_get_cache. Such large
+	 * allocations are extremely rare but can happen, for instance, for the
+	 * cache arrays. We bring this test here.
+	 */
+	if (!current->mm || current->memcg_kmem_skip_account)
+		return true;
+
 	memcg = try_get_mem_cgroup_from_mm(current->mm);
 
 	/*
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
