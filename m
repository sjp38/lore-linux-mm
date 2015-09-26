Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C76E36B0254
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:10 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so129001804pac.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:10 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tc9si11804293pbc.232.2015.09.26.03.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:09 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/5] mm: uncharge kmem pages from generic free_page path
Date: Sat, 26 Sep 2015 13:45:53 +0300
Message-ID: <bd8dc6295b2984a55233904fe6e85ff3b32052d7.1443262808.git.vdavydov@parallels.com>
In-Reply-To: <cover.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, to charge a page to kmemcg one should use alloc_kmem_pages
helper. When the page is not needed anymore it must be freed with
free_kmem_pages helper, which will uncharge the page before freeing it.
Such a design is acceptable for thread info pages and kmalloc large
allocations, which are currently the only users of alloc_kmem_pages, but
it gets extremely inconvenient if one wants to make use of batched free
(e.g. to charge page tables - see release_pages) or page reference
counter (pipe buffers - see anon_pipe_buf_release).

To overcome this limitation, this patch moves kmemcg uncharge code to
the generic free path and zaps free_kmem_pages helper. To distinguish
kmem pages from other page types, it makes alloc_kmem_pages initialize
page->_mapcount to a special value and introduces a new PageKmem helper,
which returns true if it sees this value.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/gfp.h        |  3 ---
 include/linux/page-flags.h | 22 ++++++++++++++++++++++
 kernel/fork.c              |  2 +-
 mm/page_alloc.c            | 26 ++++++++------------------
 mm/slub.c                  |  2 +-
 mm/swap.c                  |  3 ++-
 6 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f92cbd2f4450..b46147c45966 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -384,9 +384,6 @@ extern void *__alloc_page_frag(struct page_frag_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask);
 extern void __free_page_frag(void *addr);
 
-extern void __free_kmem_pages(struct page *page, unsigned int order);
-extern void free_kmem_pages(unsigned long addr, unsigned int order);
-
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 416509e26d6d..a190719c2f46 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -594,6 +594,28 @@ static inline void __ClearPageBalloon(struct page *page)
 }
 
 /*
+ * PageKmem() returns true if the page was allocated with alloc_kmem_pages().
+ */
+#define PAGE_KMEM_MAPCOUNT_VALUE (-512)
+
+static inline int PageKmem(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_KMEM_MAPCOUNT_VALUE;
+}
+
+static inline void __SetPageKmem(struct page *page)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+	atomic_set(&page->_mapcount, PAGE_KMEM_MAPCOUNT_VALUE);
+}
+
+static inline void __ClearPageKmem(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageKmem(page), page);
+	atomic_set(&page->_mapcount, -1);
+}
+
+/*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
  */
diff --git a/kernel/fork.c b/kernel/fork.c
index 2845623fb582..c23f8a17e99e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -169,7 +169,7 @@ static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 
 static inline void free_thread_info(struct thread_info *ti)
 {
-	free_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
+	free_pages((unsigned long)ti, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b9f253..88d85367c81e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -942,6 +942,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 
 	if (PageAnon(page))
 		page->mapping = NULL;
+	if (PageKmem(page)) {
+		memcg_kmem_uncharge_pages(page, order);
+		__ClearPageKmem(page);
+	}
 	bad += free_pages_check(page);
 	for (i = 1; i < (1 << order); i++) {
 		if (compound)
@@ -3434,6 +3438,8 @@ struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
 		return NULL;
 	page = alloc_pages(gfp_mask, order);
 	memcg_kmem_commit_charge(page, memcg, order);
+	if (page)
+		__SetPageKmem(page);
 	return page;
 }
 
@@ -3446,27 +3452,11 @@ struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 		return NULL;
 	page = alloc_pages_node(nid, gfp_mask, order);
 	memcg_kmem_commit_charge(page, memcg, order);
+	if (page)
+		__SetPageKmem(page);
 	return page;
 }
 
-/*
- * __free_kmem_pages and free_kmem_pages will free pages allocated with
- * alloc_kmem_pages.
- */
-void __free_kmem_pages(struct page *page, unsigned int order)
-{
-	memcg_kmem_uncharge_pages(page, order);
-	__free_pages(page, order);
-}
-
-void free_kmem_pages(unsigned long addr, unsigned int order)
-{
-	if (addr != 0) {
-		VM_BUG_ON(!virt_addr_valid((void *)addr));
-		__free_kmem_pages(virt_to_page((void *)addr), order);
-	}
-}
-
 static void *make_alloc_exact(unsigned long addr, unsigned order, size_t size)
 {
 	if (addr) {
diff --git a/mm/slub.c b/mm/slub.c
index f614b5dc396b..f5248a7d9438 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3516,7 +3516,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kfree_hook(x);
-		__free_kmem_pages(page, compound_order(page));
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab_cache, page, object, _RET_IP_);
diff --git a/mm/swap.c b/mm/swap.c
index 983f692a47fd..8d8d03118a18 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -64,7 +64,8 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	mem_cgroup_uncharge(page);
+	if (!PageKmem(page))
+		mem_cgroup_uncharge(page);
 }
 
 static void __put_single_page(struct page *page)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
