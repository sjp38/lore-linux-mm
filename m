Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 045096B0035
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 18:59:11 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so3227231pbc.33
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:59:11 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ya10si2618561pab.298.2013.12.13.15.59.08
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 15:59:09 -0800 (PST)
Subject: [RFC][PATCH 3/7] mm: slabs: reset page at free
From: Dave Hansen <dave@sr71.net>
Date: Fri, 13 Dec 2013 15:59:07 -0800
References: <20131213235903.8236C539@viggo.jf.intel.com>
In-Reply-To: <20131213235903.8236C539@viggo.jf.intel.com>
Message-Id: <20131213235907.CEB6E034@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


In order to simplify 'struct page', we will shortly be moving
some fields around.  This causes slub's ->freelist usage to
impinge on page->mapping's storage space.  The buddy allocator
wants ->mapping to be NULL when a page is handed back, so we have
to make sure that it is cleared.

Note that slab already doeds this, so just create a common helper
and have all the slabs do it this way.  ->mapping is right next
to ->flags, so it's virtually guaranteed to be in the L1 at this
point, so this shouldn't cost very much to do in practice.

Other allocators and users of 'struct page' may also want to call
this if they use parts of 'struct page' for nonstandard purposes.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm.h |   11 +++++++++++
 linux.git-davehans/mm/slab.c          |    3 +--
 linux.git-davehans/mm/slab.h          |    1 +
 linux.git-davehans/mm/slob.c          |    2 +-
 linux.git-davehans/mm/slub.c          |    2 +-
 5 files changed, 15 insertions(+), 4 deletions(-)

diff -puN include/linux/mm.h~slub-reset-page-at-free include/linux/mm.h
--- linux.git/include/linux/mm.h~slub-reset-page-at-free	2013-12-13 15:51:47.771232294 -0800
+++ linux.git-davehans/include/linux/mm.h	2013-12-13 15:51:47.777232559 -0800
@@ -2030,5 +2030,16 @@ static inline void set_page_pfmemalloc(s
 	page->index = pfmemalloc;
 }
 
+/*
+ * Custom allocators (like the slabs) use 'struct page' fields
+ * for all kinds of things.  This resets the page's state so that
+ * the buddy allocator will be happy with it.
+ */
+static inline void allocator_reset_page(struct page *page)
+{
+	page->mapping = NULL;
+	page_mapcount_reset(page);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN mm/slab.c~slub-reset-page-at-free mm/slab.c
--- linux.git/mm/slab.c~slub-reset-page-at-free	2013-12-13 15:51:47.772232339 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-13 15:51:47.778232603 -0800
@@ -1718,8 +1718,7 @@ static void kmem_freepages(struct kmem_c
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
-	page_mapcount_reset(page);
-	page->mapping = NULL;
+	allocator_reset_page(page);
 
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
diff -puN mm/slab.h~slub-reset-page-at-free mm/slab.h
--- linux.git/mm/slab.h~slub-reset-page-at-free	2013-12-13 15:51:47.773232383 -0800
+++ linux.git-davehans/mm/slab.h	2013-12-13 15:51:47.778232603 -0800
@@ -278,3 +278,4 @@ struct kmem_cache_node {
 
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
+
diff -puN mm/slob.c~slub-reset-page-at-free mm/slob.c
--- linux.git/mm/slob.c~slub-reset-page-at-free	2013-12-13 15:51:47.774232427 -0800
+++ linux.git-davehans/mm/slob.c	2013-12-13 15:51:47.778232603 -0800
@@ -360,7 +360,7 @@ static void slob_free(void *block, int s
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
 		__ClearPageSlab(sp);
-		page_mapcount_reset(sp);
+		allocator_reset_page(sp);
 		slob_free_pages(b, 0);
 		return;
 	}
diff -puN mm/slub.c~slub-reset-page-at-free mm/slub.c
--- linux.git/mm/slub.c~slub-reset-page-at-free	2013-12-13 15:51:47.775232471 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-13 15:51:47.779232647 -0800
@@ -1452,7 +1452,7 @@ static void __free_slab(struct kmem_cach
 	__ClearPageSlab(page);
 
 	memcg_release_pages(s, order);
-	page_mapcount_reset(page);
+	allocator_reset_page(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	__free_memcg_kmem_pages(page, order);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
