Date: Wed, 25 Jan 2006 10:15:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: nommu use compound pages?
Message-ID: <20060125091509.GB32653@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

This topic came up about a year ago but I couldn't work out why it never
happened. Possibly because compound pages wheren't always enabled.

Now that they are, can we have another shot? It would be great to
unify all this stuff finally. I must admit I'm not too familiar with
the nommu code, but I couldn't find a fundamental problem from the
archives.

Nick
--

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -338,11 +338,7 @@ static inline void get_page(struct page 
 
 void put_page(struct page *page);
 
-#ifdef CONFIG_MMU
 void split_page(struct page *page, unsigned int order);
-#else
-static inline void split_page(struct page *page, unsigned int order) {}
-#endif
 
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -11,19 +11,7 @@
 
 static inline void set_page_refs(struct page *page, int order)
 {
-#ifdef CONFIG_MMU
 	set_page_count(page, 1);
-#else
-	int i;
-
-	/*
-	 * We need to reference all the pages for this order, otherwise if
-	 * anyone accesses one of the pages with (get/put) it will be freed.
-	 * - eg: access_process_vm()
-	 */
-	for (i = 0; i < (1 << order); i++)
-		set_page_count(page + i, 1);
-#endif /* CONFIG_MMU */
 }
 
 extern void fastcall __init __free_pages_bootmem(struct page *page,
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -422,11 +422,6 @@ static void __free_pages_ok(struct page 
 		mutex_debug_check_no_locks_freed(page_address(page),
 						 PAGE_SIZE<<order);
 
-#ifndef CONFIG_MMU
-	for (i = 1 ; i < (1 << order) ; ++i)
-		__put_page(page + i);
-#endif
-
 	for (i = 0 ; i < (1 << order) ; ++i)
 		reserved += free_pages_check(page + i);
 	if (reserved)
@@ -747,7 +742,6 @@ static inline void prep_zero_page(struct
 		clear_highpage(page + i);
 }
 
-#ifdef CONFIG_MMU
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
@@ -767,7 +761,6 @@ void split_page(struct page *page, unsig
 		set_page_count(page + i, 1);
 	}
 }
-#endif
 
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
Index: linux-2.6/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.orig/fs/ramfs/file-nommu.c
+++ linux-2.6/fs/ramfs/file-nommu.c
@@ -87,8 +87,7 @@ static int ramfs_nommu_expand_for_mappin
 	xpages = 1UL << order;
 	npages = (newsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
-	for (loop = 0; loop < npages; loop++)
-		set_page_count(pages + loop, 1);
+	split_page(pages, order);
 
 	/* trim off any pages we don't actually require */
 	for (loop = npages; loop < xpages; loop++)
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -158,7 +158,7 @@ void *__vmalloc(unsigned long size, gfp_
 	/*
 	 * kmalloc doesn't like __GFP_HIGHMEM for some reason
 	 */
-	return kmalloc(size, gfp_mask & ~__GFP_HIGHMEM);
+	return kmalloc(size, (gfp_mask | __GFP_COMP) & ~__GFP_HIGHMEM);
 }
 
 struct page * vmalloc_to_page(void *addr)
@@ -615,7 +615,7 @@ static int do_mmap_private(struct vm_are
 	 * - note that this may not return a page-aligned address if the object
 	 *   we're allocating is smaller than a page
 	 */
-	base = kmalloc(len, GFP_KERNEL);
+	base = kmalloc(len, GFP_KERNEL|__GFP_COMP);
 	if (!base)
 		goto enomem;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
