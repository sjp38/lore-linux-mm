Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A68506B0263
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:49:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so16530199oiw.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:49:45 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0101.outbound.protection.outlook.com. [157.55.234.101])
        by mx.google.com with ESMTPS id r65si1257767oia.96.2016.05.24.01.49.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 01:49:43 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RESEND 4/8] mm: charge/uncharge kmemcg from generic page allocator paths
Date: Tue, 24 May 2016 11:49:26 +0300
Message-ID: <a9736d856f895bcb465d9f257b54efe32eda6f99.1464079538.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1464079537.git.vdavydov@virtuozzo.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Currently, to charge a non-slab allocation to kmemcg one has to use
alloc_kmem_pages helper with __GFP_ACCOUNT flag. A page allocated with
this helper should finally be freed using free_kmem_pages, otherwise it
won't be uncharged.

This API suits its current users fine, but it turns out to be impossible
to use along with page reference counting, i.e. when an allocation is
supposed to be freed with put_page, as it is the case with pipe or unix
socket buffers.

To overcome this limitation, this patch moves charging/uncharging to
generic page allocator paths, i.e. to __alloc_pages_nodemask and
free_pages_prepare, and zaps alloc/free_kmem_pages helpers. This way,
one can use any of the available page allocation functions to get the
allocated page charged to kmemcg - it's enough to pass __GFP_ACCOUNT,
just like in case of kmalloc and friends. A charged page will be
automatically uncharged on free.

To make it possible, we need to mark pages charged to kmemcg somehow. To
avoid introducing a new page flag, we make use of page->_mapcount for
marking such pages. Since pages charged to kmemcg are not supposed to be
mapped to userspace, it should work just fine. There are other (ab)users
of page->_mapcount - buddy and balloon pages - but we don't conflict
with them.

In case kmemcg is compiled out or not used at runtime, this patch
introduces no overhead to generic page allocator paths. If kmemcg is
used, it will be plus one gfp flags check on alloc and plus one
page->_mapcount check on free, which shouldn't hurt performance, because
the data accessed are hot.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/gfp.h        | 10 +------
 include/linux/page-flags.h |  7 +++++
 kernel/fork.c              |  6 ++---
 mm/page_alloc.c            | 66 +++++++++-------------------------------------
 mm/slab_common.c           |  2 +-
 mm/slub.c                  |  6 ++---
 mm/vmalloc.c               |  6 ++---
 7 files changed, 31 insertions(+), 72 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..c29e9d347bc6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -78,8 +78,7 @@ struct vm_area_struct;
  * __GFP_THISNODE forces the allocation to be satisified from the requested
  *   node with no fallbacks or placement policy enforcements.
  *
- * __GFP_ACCOUNT causes the allocation to be accounted to kmemcg (only relevant
- *   to kmem allocations).
+ * __GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
  */
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE)
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)
@@ -486,10 +485,6 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
 
-extern struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order);
-extern struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask,
-					  unsigned int order);
-
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
@@ -513,9 +508,6 @@ extern void *__alloc_page_frag(struct page_frag_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask);
 extern void __free_page_frag(void *addr);
 
-extern void __free_kmem_pages(struct page *page, unsigned int order);
-extern void free_kmem_pages(unsigned long addr, unsigned int order);
-
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr), 0)
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9940ade6a25e..b51e75a47e82 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -630,6 +630,13 @@ PAGE_MAPCOUNT_OPS(Buddy, BUDDY)
 #define PAGE_BALLOON_MAPCOUNT_VALUE		(-256)
 PAGE_MAPCOUNT_OPS(Balloon, BALLOON)
 
+/*
+ * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
+ * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
+ */
+#define PAGE_KMEMCG_MAPCOUNT_VALUE		(-512)
+PAGE_MAPCOUNT_OPS(Kmemcg, KMEMCG)
+
 extern bool is_free_buddy_page(struct page *page);
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index 66cc2e0e137e..3f3c30f80786 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -162,8 +162,8 @@ void __weak arch_release_thread_info(struct thread_info *ti)
 static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
 						  int node)
 {
-	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
-						  THREAD_SIZE_ORDER);
+	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
+					     THREAD_SIZE_ORDER);
 
 	if (page)
 		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
@@ -178,7 +178,7 @@ static inline void free_thread_info(struct thread_info *ti)
 
 	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
 				    -(1 << THREAD_SIZE_ORDER));
-	__free_kmem_pages(page, THREAD_SIZE_ORDER);
+	__free_pages(page, THREAD_SIZE_ORDER);
 }
 # else
 static struct kmem_cache *thread_info_cache;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f948f4e02e89..c9ee98f1d3cc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -63,6 +63,7 @@
 #include <linux/sched/rt.h>
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
+#include <linux/memcontrol.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -1017,6 +1018,10 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	}
 	if (PageAnonHead(page))
 		page->mapping = NULL;
+	if (memcg_kmem_enabled() && PageKmemcg(page)) {
+		memcg_kmem_uncharge(page, order);
+		__ClearPageKmemcg(page);
+	}
 	if (check_free)
 		bad += free_pages_check(page);
 	if (bad)
@@ -3833,6 +3838,14 @@ no_zone:
 	}
 
 out:
+	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page) {
+		if (unlikely(memcg_kmem_charge(page, gfp_mask, order))) {
+			__free_pages(page, order);
+			page = NULL;
+		} else
+			__SetPageKmemcg(page);
+	}
+
 	if (kmemcheck_enabled && page)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
 
@@ -3988,59 +4001,6 @@ void __free_page_frag(void *addr)
 }
 EXPORT_SYMBOL(__free_page_frag);
 
-/*
- * alloc_kmem_pages charges newly allocated pages to the kmem resource counter
- * of the current memory cgroup if __GFP_ACCOUNT is set, other than that it is
- * equivalent to alloc_pages.
- *
- * It should be used when the caller would like to use kmalloc, but since the
- * allocation is large, it has to fall back to the page allocator.
- */
-struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order)
-{
-	struct page *page;
-
-	page = alloc_pages(gfp_mask, order);
-	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) &&
-	    page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
-		__free_pages(page, order);
-		page = NULL;
-	}
-	return page;
-}
-
-struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
-{
-	struct page *page;
-
-	page = alloc_pages_node(nid, gfp_mask, order);
-	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) &&
-	    page && memcg_kmem_charge(page, gfp_mask, order) != 0) {
-		__free_pages(page, order);
-		page = NULL;
-	}
-	return page;
-}
-
-/*
- * __free_kmem_pages and free_kmem_pages will free pages allocated with
- * alloc_kmem_pages.
- */
-void __free_kmem_pages(struct page *page, unsigned int order)
-{
-	if (memcg_kmem_enabled())
-		memcg_kmem_uncharge(page, order);
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
 static void *make_alloc_exact(unsigned long addr, unsigned int order,
 		size_t size)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a65dad7fdcd1..3bf8f63a6abe 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1012,7 +1012,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	struct page *page;
 
 	flags |= __GFP_COMP;
-	page = alloc_kmem_pages(flags, order);
+	page = alloc_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
 	kasan_kmalloc_large(ret, size, flags);
diff --git a/mm/slub.c b/mm/slub.c
index 538c8584ba8d..ac7b5a55e4c9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2867,7 +2867,7 @@ int build_detached_freelist(struct kmem_cache *s, size_t size,
 		if (unlikely(!PageSlab(page))) {
 			BUG_ON(!PageCompound(page));
 			kfree_hook(object);
-			__free_kmem_pages(page, compound_order(page));
+			__free_pages(page, compound_order(page));
 			p[size] = NULL; /* mark object processed */
 			return size;
 		}
@@ -3575,7 +3575,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	void *ptr = NULL;
 
 	flags |= __GFP_COMP | __GFP_NOTRACK;
-	page = alloc_kmem_pages_node(node, flags, get_order(size));
+	page = alloc_pages_node(node, flags, get_order(size));
 	if (page)
 		ptr = page_address(page);
 
@@ -3656,7 +3656,7 @@ void kfree(const void *x)
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
 		kfree_hook(x);
-		__free_kmem_pages(page, compound_order(page));
+		__free_pages(page, compound_order(page));
 		return;
 	}
 	slab_free(page->slab_cache, page, object, NULL, 1, _RET_IP_);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cf7ad1a53be0..a806236ecd62 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1501,7 +1501,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
-			__free_kmem_pages(page, 0);
+			__free_pages(page, 0);
 		}
 
 		kvfree(area->pages);
@@ -1628,9 +1628,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		struct page *page;
 
 		if (node == NUMA_NO_NODE)
-			page = alloc_kmem_pages(alloc_mask, order);
+			page = alloc_pages(alloc_mask, order);
 		else
-			page = alloc_kmem_pages_node(node, alloc_mask, order);
+			page = alloc_pages_node(node, alloc_mask, order);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
