Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A62EA6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 14:41:37 -0400 (EDT)
Received: by ggnf1 with SMTP id f1so3045016ggn.25
        for <linux-mm@kvack.org>; Mon, 14 May 2012 11:41:36 -0700 (PDT)
From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 1/2] mm: Fix slab->page flags corruption.
Date: Mon, 14 May 2012 11:41:17 -0700
Message-Id: <1337020877-20087-1-git-send-email-pshelar@nicira.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, mpm@selenic.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com, Pravin B Shelar <pshelar@nicira.com>

Transparent huge pages can change page->flags (PG_compound_lock)
without taking Slab lock. Since THP can not break slab pages we can
safely access compound page without taking compound lock.

Specificly this patch fixes race between compound_unlock and slab
functions which does page-flags update. This can occur when
get_page/put_page is called on page from slab object.

Reported-by: Amey Bhide <abhide@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/mm.h |    2 ++
 mm/swap.c          |   17 +++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74aa71b..82f86e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -321,6 +321,7 @@ static inline int is_vmalloc_or_module_addr(const void *x)
 static inline void compound_lock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(PageSlab(page));
 	bit_spin_lock(PG_compound_lock, &page->flags);
 #endif
 }
@@ -328,6 +329,7 @@ static inline void compound_lock(struct page *page)
 static inline void compound_unlock(struct page *page)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(PageSlab(page));
 	bit_spin_unlock(PG_compound_lock, &page->flags);
 #endif
 }
diff --git a/mm/swap.c b/mm/swap.c
index 8ff73d8..d4eb9f6 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -82,6 +82,16 @@ static void put_compound_page(struct page *page)
 		if (likely(page != page_head &&
 			   get_page_unless_zero(page_head))) {
 			unsigned long flags;
+
+			if (PageSlab(page_head)) {
+				/* THP can not break up slab pages, avoid
+				 * taking compound_lock(). */
+				if (put_page_testzero(page_head))
+					VM_BUG_ON(1);
+
+				atomic_dec(&page->_mapcount);
+				goto skip_lock;
+			}
 			/*
 			 * page_head wasn't a dangling pointer but it
 			 * may not be a head page anymore by the time
@@ -115,6 +125,8 @@ static void put_compound_page(struct page *page)
 			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
 			VM_BUG_ON(atomic_read(&page->_count) != 0);
 			compound_unlock_irqrestore(page_head, flags);
+
+			skip_lock:
 			if (put_page_testzero(page_head)) {
 				if (PageHead(page_head))
 					__put_compound_page(page_head);
@@ -168,6 +180,11 @@ bool __get_page_tail(struct page *page)
 		 * we obtain the lock. That is ok as long as it
 		 * can't be freed from under us.
 		 */
+		if (PageSlab(page_head)) {
+			__get_page_tail_foll(page, false);
+			return true;
+		}
+
 		flags = compound_lock_irqsave(page_head);
 		/* here __split_huge_page_refcount won't run anymore */
 		if (likely(PageTail(page))) {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
