Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0215D6B0037
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:28:11 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id gl10so1629277lab.14
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:28:11 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id oc6si14699824lbb.31.2014.03.26.08.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 08:28:10 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
Date: Wed, 26 Mar 2014 19:28:04 +0400
Message-ID: <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com>
In-Reply-To: <cover.1395846845.git.vdavydov@parallels.com>
References: <cover.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

We don't track any random page allocation, so we shouldn't track kmalloc
that falls back to the page allocator.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>
---
 include/linux/slab.h |    2 +-
 mm/memcontrol.c      |   27 +--------------------------
 mm/slub.c            |    4 ++--
 3 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3dd389aa91c7..8a928ff71d93 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -363,7 +363,7 @@ kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret;
 
-	flags |= (__GFP_COMP | __GFP_KMEMCG);
+	flags |= __GFP_COMP;
 	ret = (void *) __get_free_pages(flags, order);
 	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b4b6aef562fa..81a162d01d4d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3528,35 +3528,10 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 
 	*_memcg = NULL;
 
-	/*
-	 * Disabling accounting is only relevant for some specific memcg
-	 * internal allocations. Therefore we would initially not have such
-	 * check here, since direct calls to the page allocator that are marked
-	 * with GFP_KMEMCG only happen outside memcg core. We are mostly
-	 * concerned with cache allocations, and by having this test at
-	 * memcg_kmem_get_cache, we are already able to relay the allocation to
-	 * the root cache and bypass the memcg cache altogether.
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
-	if (!current->mm || current->memcg_kmem_skip_account)
+	if (!current->mm)
 		return true;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-
 	if (!memcg_can_account_kmem(memcg)) {
 		css_put(&memcg->css);
 		return true;
diff --git a/mm/slub.c b/mm/slub.c
index 5e234f1f8853..c2e58a787443 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3325,7 +3325,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	struct page *page;
 	void *ptr = NULL;
 
-	flags |= __GFP_COMP | __GFP_NOTRACK | __GFP_KMEMCG;
+	flags |= __GFP_COMP | __GFP_NOTRACK;
 	page = alloc_pages_node(node, flags, get_order(size));
 	if (page)
 		ptr = page_address(page);
@@ -3395,7 +3395,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kfree_hook(x);
-		__free_memcg_kmem_pages(page, compound_order(page));
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab_cache, page, object, _RET_IP_);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
