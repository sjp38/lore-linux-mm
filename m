Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0E46E6B006C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 23:59:53 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [RFC PATCH 2/4] mm: make consistent use of PG_slab flag
Date: Tue, 3 Jul 2012 11:57:15 +0800
Message-ID: <1341287837-7904-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Currently there is some inconsistency with the usages of PG_slab flag.
The SLAB/SLUB/SLOB allocator uses PG_slab flag to mark whether a (compound)
page contains managed objects, but other subsystems use PG_slab flag
to detect whether a (compound) page is allocated/managed by SLAB/SLUB/SLOB.

It's OK with SLAB allocator because all pages allocated by SLAB will be
used to host SLAB object, thus with PG_slab flag set. But it may run into
trouble with SLUB/SLOB allocators. If the requested object is bigger enough,
SLUB/SLOB allocator directly depends on the page allocator to fulfill object
allocate/release requests. To distinguish whether a (compound) page hosts
SLUB/SLOB objects, SLUB/SLOB allocator only sets PG_slab flag on small pages
hosting SLUB/SLOB objects. So the PG_slab flag won't be set for large pages
allocated/managed by SLUB/SLOB allocator.

This patch splits the traditional PG_slab flag into two flags:
PG_slab:	mark whether a (compound) page is allocated/managed by
                SLAB/SLUB/SLOB.
PG_slabobject:	mark whether a (compound) page hosts SLUB/SLOB objects.

The PG_slabobject flag won't be set on pages allocated by SLAB allocator
because it's redundant.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 include/linux/page-flags.h |    4 +++-
 include/linux/slub_def.h   |    3 +++
 mm/slob.c                  |   21 +++++++++++++++++----
 mm/slub.c                  |   22 ++++++++++++++--------
 4 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c88d2a9..5fcf0b8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -123,8 +123,9 @@ enum pageflags {
 	PG_pinned = PG_owner_priv_1,
 	PG_savepinned = PG_dirty,
 
-	/* SLOB */
+	/* SLOB & SLUB */
 	PG_slob_free = PG_private,
+	PG_slab_object = PG_private_2,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -208,6 +209,7 @@ PAGEFLAG(SavePinned, savepinned);			/* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
+__PAGEFLAG(SlabObject, slab_object)
 __PAGEFLAG(SlobFree, slob_free)
 
 /*
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index c2f8c8b..e357c8d 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -11,6 +11,7 @@
 #include <linux/bug.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
+#include <linux/page-flags.h>
 
 #include <linux/kmemleak.h>
 
@@ -224,6 +225,8 @@ static __always_inline void *
 kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
 	void *ret = (void *) __get_free_pages(flags | __GFP_COMP, order);
+	if (ret)
+		__SetPageSlab(virt_to_page(ret));
 	kmemleak_alloc(ret, size, 1, flags);
 	return ret;
 }
diff --git a/mm/slob.c b/mm/slob.c
index 8105be4..2c1fa9c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -135,17 +135,17 @@ static LIST_HEAD(free_slob_large);
  */
 static inline int is_slob_page(struct slob_page *sp)
 {
-	return PageSlab((struct page *)sp);
+	return PageSlabObject((struct page *)sp);
 }
 
 static inline void set_slob_page(struct slob_page *sp)
 {
-	__SetPageSlab((struct page *)sp);
+	__SetPageSlabObject((struct page *)sp);
 }
 
 static inline void clear_slob_page(struct slob_page *sp)
 {
-	__ClearPageSlab((struct page *)sp);
+	__ClearPageSlabObject((struct page *)sp);
 }
 
 static inline struct slob_page *slob_page(const void *addr)
@@ -242,7 +242,7 @@ static int slob_last(slob_t *s)
 
 static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page, *pos;
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
@@ -254,11 +254,24 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 	if (!page)
 		return NULL;
 
+	/* Only set PG_slab flag on head page in case of compound page */
+	if (gfp & __GFP_COMP)
+		order = 0;
+	for (pos = page + (1 << order) - 1; pos >= page; pos--)
+		__SetPageSlab(pos);
+
 	return page_address(page);
 }
 
 static void slob_free_pages(void *b, int order)
 {
+	struct page *pos, *end;
+
+	pos = virt_to_page(b);
+	end = pos + (PageCompound(pos) ? 1 : 1 << order);
+	for (; pos < end; pos++)
+		__ClearPageSlab(pos);
+
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += 1 << order;
 	free_pages((unsigned long)b, order);
diff --git a/mm/slub.c b/mm/slub.c
index 8c691fa..9dc6524 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -840,7 +840,7 @@ static int check_slab(struct kmem_cache *s, struct page *page)
 
 	VM_BUG_ON(!irqs_disabled());
 
-	if (!PageSlab(page)) {
+	if (!PageSlabObject(page)) {
 		slab_err(s, page, "Not a valid slab page");
 		return 0;
 	}
@@ -1069,7 +1069,7 @@ static noinline int alloc_debug_processing(struct kmem_cache *s, struct page *pa
 	return 1;
 
 bad:
-	if (PageSlab(page)) {
+	if (PageSlabObject(page)) {
 		/*
 		 * If this is a slab page then lets do the best we can
 		 * to avoid issues in the future. Marking all objects
@@ -1108,7 +1108,7 @@ static noinline int free_debug_processing(struct kmem_cache *s,
 		goto out;
 
 	if (unlikely(s != page->slab)) {
-		if (!PageSlab(page)) {
+		if (!PageSlabObject(page)) {
 			slab_err(s, page, "Attempt to free object(0x%p) "
 				"outside of slab", object);
 		} else if (!page->slab) {
@@ -1370,6 +1370,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	__SetPageSlab(page);
+	__SetPageSlabObject(page);
 
 	start = page_address(page);
 
@@ -1413,6 +1414,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
+	__ClearPageSlabObject(page);
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
@@ -3369,8 +3371,10 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 
 	flags |= __GFP_COMP | __GFP_NOTRACK;
 	page = alloc_pages_node(node, flags, get_order(size));
-	if (page)
+	if (page) {
+		__SetPageSlab(page);
 		ptr = page_address(page);
+	}
 
 	kmemleak_alloc(ptr, size, 1, flags);
 	return ptr;
@@ -3414,7 +3418,7 @@ size_t ksize(const void *object)
 
 	page = virt_to_head_page(object);
 
-	if (unlikely(!PageSlab(page))) {
+	if (unlikely(!PageSlabObject(page))) {
 		WARN_ON(!PageCompound(page));
 		return PAGE_SIZE << compound_order(page);
 	}
@@ -3437,7 +3441,7 @@ bool verify_mem_not_deleted(const void *x)
 	local_irq_save(flags);
 
 	page = virt_to_head_page(x);
-	if (unlikely(!PageSlab(page))) {
+	if (unlikely(!PageSlabObject(page))) {
 		/* maybe it was from stack? */
 		rv = true;
 		goto out_unlock;
@@ -3470,9 +3474,10 @@ void kfree(const void *x)
 		return;
 
 	page = virt_to_head_page(x);
-	if (unlikely(!PageSlab(page))) {
+	if (unlikely(!PageSlabObject(page))) {
 		BUG_ON(!PageCompound(page));
 		kmemleak_free(x);
+		__ClearPageSlab(page);
 		put_page(page);
 		return;
 	}
@@ -3715,7 +3720,8 @@ void __init kmem_cache_init(void)
 	/* Allocate two kmem_caches from the page allocator */
 	kmalloc_size = ALIGN(kmem_size, cache_line_size());
 	order = get_order(2 * kmalloc_size);
-	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT, order);
+	kmem_cache = (void *)__get_free_pages(GFP_NOWAIT | __GFP_COMP, order);
+	__SetPageSlab(virt_to_page(kmem_cache));
 
 	/*
 	 * Must first have the slab cache available for the allocations of the
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
