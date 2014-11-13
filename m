Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 746286B00DC
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 04:12:52 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so148314pad.1
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 01:12:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zt3si11231652pbc.97.2014.11.13.01.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Nov 2014 01:12:51 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/2] memcg: only check memcg_kmem_skip_account in __memcg_kmem_get_cache
Date: Thu, 13 Nov 2014 12:12:42 +0300
Message-ID: <c07e576c9b76c00fbcc1978f9659bf5b83513d14.1415868622.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

__memcg_kmem_get_cache can recurse if it calls kmalloc (which it does if
the cgroup's kmem cache doesn't exist), because kmalloc may call
__memcg_kmem_get_cache internally again. To avoid the recursion, we use
the task_struct->memcg_kmem_skip_account flag.

However, there's no need checking the flag in memcg_kmem_newpage_charge,
because there's no way how this function could result in recursion, if
called from memcg_kmem_get_cache. So let's remove the redundant code.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   28 ----------------------------
 1 file changed, 28 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bb8c237026cc..d9fab72da52e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2905,34 +2905,6 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 
 	*_memcg = NULL;
 
-	/*
-	 * Disabling accounting is only relevant for some specific memcg
-	 * internal allocations. Therefore we would initially not have such
-	 * check here, since direct calls to the page allocator that are
-	 * accounted to kmemcg (alloc_kmem_pages and friends) only happen
-	 * outside memcg core. We are mostly concerned with cache allocations,
-	 * and by having this test at memcg_kmem_get_cache, we are already able
-	 * to relay the allocation to the root cache and bypass the memcg cache
-	 * altogether.
-	 *
-	 * There is one exception, though: the SLUB allocator does not create
-	 * large order caches, but rather service large kmallocs directly from
-	 * the page allocator. Therefore, the following sequence when backed by
-	 * the SLUB allocator:
-	 *
-	 *	memcg_stop_kmem_account();
-	 *	kmalloc(<large_number>)
-	 *	memcg_resume_kmem_account();
-	 *
-	 * would effectively ignore the fact that we should skip accounting,
-	 * since it will drive us directly to this function without passing
-	 * through the cache selector memcg_kmem_get_cache. Such large
-	 * allocations are extremely rare but can happen, for instance, for the
-	 * cache arrays. We bring this test here.
-	 */
-	if (current->memcg_kmem_skip_account)
-		return true;
-
 	memcg = get_mem_cgroup_from_mm(current->mm);
 
 	if (!memcg_kmem_is_active(memcg)) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
