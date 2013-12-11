Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 52C096B003D
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:44 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so10815845pbb.23
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:44 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kn3si14721396pbc.184.2013.12.11.14.40.41
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:40:41 -0800 (PST)
Subject: [RFC][PATCH 3/3] mm: slabs: reset page at free
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Dec 2013 14:40:28 -0800
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
In-Reply-To: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
Message-Id: <20131211224028.9D7AD2B7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


We now have slub's ->freelist usage impinging on page->mapping's
storage space.  The buddy allocator wants ->mapping to be NULL
when a page is handed back, so we have to make sure that it is
cleared.

Note that slab already doeds this, so just create a common helper
and have all the slabs do it this way.  ->mapping is right next
to ->flags, so it's virtually guaranteed to be in the L1 at this
point, so this shouldn't cost very much to do in practice.

---

 linux.git-davehans/mm/slab.c |    3 +--
 linux.git-davehans/mm/slab.h |   11 +++++++++++
 linux.git-davehans/mm/slob.c |    2 +-
 linux.git-davehans/mm/slub.c |    2 +-
 4 files changed, 14 insertions(+), 4 deletions(-)

diff -puN mm/slab.c~slub-reset-page-at-free mm/slab.c
--- linux.git/mm/slab.c~slub-reset-page-at-free	2013-12-11 13:19:55.026994096 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-11 13:19:55.036994538 -0800
@@ -1725,8 +1725,7 @@ static void kmem_freepages(struct kmem_c
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
-	page_mapcount_reset(page);
-	page->mapping = NULL;
+	slab_reset_page(page);
 
 	memcg_release_pages(cachep, cachep->gfporder);
 	if (current->reclaim_state)
diff -puN mm/slab.h~slub-reset-page-at-free mm/slab.h
--- linux.git/mm/slab.h~slub-reset-page-at-free	2013-12-11 13:19:55.028994185 -0800
+++ linux.git-davehans/mm/slab.h	2013-12-11 13:19:55.036994538 -0800
@@ -279,3 +279,14 @@ struct kmem_cache_node {
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
 
+/*
+ * The slab allocators use 'struct page' fields for all kinds of
+ * things.  This resets the page so that the buddy allocator will
+ * be happy with it.
+ */
+static inline void slab_reset_page(struct page *page)
+{
+	page->mapping = NULL;
+	page_mapcount_reset(page);
+}
+
diff -puN mm/slob.c~slub-reset-page-at-free mm/slob.c
--- linux.git/mm/slob.c~slub-reset-page-at-free	2013-12-11 13:19:55.029994229 -0800
+++ linux.git-davehans/mm/slob.c	2013-12-11 13:19:55.036994538 -0800
@@ -371,7 +371,7 @@ static void slob_free(void *block, int s
 			clear_slob_page_free(sp);
 		spin_unlock_irqrestore(&slob_lock, flags);
 		__ClearPageSlab((struct page *)sp);
-		page_mapcount_reset((struct page *)sp);
+		slab_reset_page((struct page *)sp);
 		slob_free_pages(b, 0);
 		return;
 	}
diff -puN mm/slub.c~slub-reset-page-at-free mm/slub.c
--- linux.git/mm/slub.c~slub-reset-page-at-free	2013-12-11 13:19:55.031994317 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-11 13:19:55.039994671 -0800
@@ -1530,7 +1530,7 @@ static void __free_slab(struct kmem_cach
 	__ClearPageSlab(page);
 
 	memcg_release_pages(s, order);
-	page_mapcount_reset(page);
+	slab_reset_page(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	__free_memcg_kmem_pages(page, order);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
