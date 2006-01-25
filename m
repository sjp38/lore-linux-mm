Date: Wed, 25 Jan 2006 11:22:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: page_alloc less atomics (resend)
Message-ID: <20060125102209.GC32578@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Oops, forgot to cc linux-mm

--
More atomic operation removal from page allocator

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -331,8 +331,8 @@ extern void __mod_page_state_offset(unsi
 #define TestClearPageReclaim(page) test_and_clear_bit(PG_reclaim, &(page)->flags)
 
 #define PageCompound(page)	test_bit(PG_compound, &(page)->flags)
-#define SetPageCompound(page)	set_bit(PG_compound, &(page)->flags)
-#define ClearPageCompound(page)	clear_bit(PG_compound, &(page)->flags)
+#define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
+#define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
 
 #ifdef CONFIG_SWAP
 #define PageSwapCache(page)	test_bit(PG_swapcache, &(page)->flags)
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -189,7 +189,7 @@ static void prep_compound_page(struct pa
 	for (i = 0; i < nr_pages; i++) {
 		struct page *p = page + i;
 
-		SetPageCompound(p);
+		__SetPageCompound(p);
 		set_page_private(p, (unsigned long)page);
 	}
 }
@@ -208,7 +208,7 @@ static void destroy_compound_page(struct
 		if (unlikely(!PageCompound(p) |
 				(page_private(p) != (unsigned long)page)))
 			bad_page(page);
-		ClearPageCompound(p);
+		__ClearPageCompound(p);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
