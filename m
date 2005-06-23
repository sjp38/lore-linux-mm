Message-ID: <42BA5FA8.7080905@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:07:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch][rfc] 3/5: remove atomic bitop when freeing page
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au>
In-Reply-To: <42BA5F7B.30904@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030309030609000306020200"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030309030609000306020200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

3/5

--------------030309030609000306020200
Content-Type: text/plain;
 name="mm-remove-atomic-bitop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-remove-atomic-bitop.patch"

This bitop does not need to be atomic because it is performed when
there will be no references to the page (ie. the page is being freed).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -329,7 +329,7 @@ static inline void free_pages_check(cons
 			1 << PG_writeback )))
 		bad_page(function, page);
 	if (PageDirty(page))
-		ClearPageDirty(page);
+		__ClearPageDirty(page);
 }
 
 /*
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -194,6 +194,7 @@ extern void __mod_page_state(unsigned lo
 #define SetPageDirty(page)	set_bit(PG_dirty, &(page)->flags)
 #define TestSetPageDirty(page)	test_and_set_bit(PG_dirty, &(page)->flags)
 #define ClearPageDirty(page)	clear_bit(PG_dirty, &(page)->flags)
+#define __ClearPageDirty(page)	__clear_bit(PG_dirty, &(page)->flags)
 #define TestClearPageDirty(page) test_and_clear_bit(PG_dirty, &(page)->flags)
 
 #define SetPageLRU(page)	set_bit(PG_lru, &(page)->flags)

--------------030309030609000306020200--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
