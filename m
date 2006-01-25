Date: Wed, 25 Jan 2006 10:19:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: slab less atomics
Message-ID: <20060125091927.GC32653@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Atomic operation removal from slab

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -1230,7 +1230,7 @@ static void *kmem_getpages(kmem_cache_t 
 		atomic_add(i, &slab_reclaim_pages);
 	add_page_state(nr_slab, i);
 	while (i--) {
-		SetPageSlab(page);
+		__SetPageSlab(page);
 		page++;
 	}
 	return addr;
@@ -1246,8 +1246,8 @@ static void kmem_freepages(kmem_cache_t 
 	const unsigned long nr_freed = i;
 
 	while (i--) {
-		if (!TestClearPageSlab(page))
-			BUG();
+		BUG_ON(!PageSlab(page));
+		__ClearPageSlab(page);
 		page++;
 	}
 	sub_page_state(nr_slab, nr_freed);
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -255,10 +255,8 @@ extern void __mod_page_state_offset(unsi
 #define __ClearPageActive(page)	__clear_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
-#define SetPageSlab(page)	set_bit(PG_slab, &(page)->flags)
-#define ClearPageSlab(page)	clear_bit(PG_slab, &(page)->flags)
-#define TestClearPageSlab(page)	test_and_clear_bit(PG_slab, &(page)->flags)
-#define TestSetPageSlab(page)	test_and_set_bit(PG_slab, &(page)->flags)
+#define __SetPageSlab(page)	__set_bit(PG_slab, &(page)->flags)
+#define __ClearPageSlab(page)	__clear_bit(PG_slab, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)	is_highmem(page_zone(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
