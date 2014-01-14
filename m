Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 831756B003B
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:01:32 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id x10so4354278pdj.16
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:01:32 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fv4si1197153pbd.122.2014.01.14.10.01.30
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 10:01:31 -0800 (PST)
Subject: [RFC][PATCH 4/9] mm: slabs: reset page at free
From: Dave Hansen <dave@sr71.net>
Date: Tue, 14 Jan 2014 10:00:54 -0800
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
In-Reply-To: <20140114180042.C1C33F78@viggo.jf.intel.com>
Message-Id: <20140114180054.20A1B660@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

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

 b/include/linux/mm.h |   11 +++++++++++
 b/mm/slab.c          |    3 +--
 b/mm/slob.c          |    2 +-
 b/mm/slub.c          |    2 +-
 4 files changed, 14 insertions(+), 4 deletions(-)

diff -puN include/linux/mm.h~slub-reset-page-at-free include/linux/mm.h
--- a/include/linux/mm.h~slub-reset-page-at-free	2014-01-14 09:57:57.099666808 -0800
+++ b/include/linux/mm.h	2014-01-14 09:57:57.110667301 -0800
@@ -2076,5 +2076,16 @@ static inline void set_page_pfmemalloc(s
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
--- a/mm/slab.c~slub-reset-page-at-free	2014-01-14 09:57:57.101666898 -0800
+++ b/mm/slab.c	2014-01-14 09:57:57.111667346 -0800
@@ -1718,8 +1718,7 @@ static void kmem_freepages(struct kmem_c
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
-	page_mapcount_reset(page);
-	page->mapping = NULL;
+	allocator_reset_page(page);
 
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
diff -puN mm/slob.c~slub-reset-page-at-free mm/slob.c
--- a/mm/slob.c~slub-reset-page-at-free	2014-01-14 09:57:57.103666988 -0800
+++ b/mm/slob.c	2014-01-14 09:57:57.112667391 -0800
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
--- a/mm/slub.c~slub-reset-page-at-free	2014-01-14 09:57:57.105667077 -0800
+++ b/mm/slub.c	2014-01-14 09:57:57.114667481 -0800
@@ -1450,7 +1450,7 @@ static void __free_slab(struct kmem_cach
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
