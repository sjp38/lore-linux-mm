From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060119192229.11913.59043.sendpatchset@linux.site>
In-Reply-To: <20060119192131.11913.27564.sendpatchset@linux.site>
References: <20060119192131.11913.27564.sendpatchset@linux.site>
Subject: [patch 6/6] mm: de-skew page refcounting
Date: Thu, 19 Jan 2006 20:23:40 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

atomic_add_unless (atomic_inc_not_zero) no longer requires an offset
refcount to function correctly.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -294,7 +294,7 @@ struct page {
  */
 static inline int put_page_testzero(struct page *page)
 {
-	BUG_ON(atomic_read(&page->_count) == -1);
+	BUG_ON(atomic_read(&page->_count) == 0);
 	return atomic_dec_and_test(&page->_count);
 }
 
@@ -304,10 +304,10 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	return atomic_add_unless(&page->_count, 1, -1);
+	return atomic_inc_not_zero(&page->_count);
 }
 
-#define set_page_count(p,v) 	atomic_set(&(p)->_count, (v) - 1)
+#define set_page_count(p,v) 	atomic_set(&(p)->_count, (v))
 #define __put_page(p)		atomic_dec(&(p)->_count)
 
 extern void FASTCALL(__page_cache_release(struct page *));
@@ -316,7 +316,7 @@ static inline int page_count(struct page
 {
 	if (PageCompound(page))
 		page = (struct page *)page_private(page);
-	return atomic_read(&page->_count) + 1;
+	return atomic_read(&page->_count);
 }
 
 static inline void get_page(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
