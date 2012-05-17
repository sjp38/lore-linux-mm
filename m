Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2849D6B00EC
	for <linux-mm@kvack.org>; Thu, 17 May 2012 18:17:55 -0400 (EDT)
Received: by dajt11 with SMTP id t11so3731643daj.38
        for <linux-mm@kvack.org>; Thu, 17 May 2012 15:17:54 -0700 (PDT)
From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3] mm: Fix slab->page flags corruption.
Date: Thu, 17 May 2012 15:17:49 -0700
Message-Id: <1337293069-22443-1-git-send-email-pshelar@nicira.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, cl@linux.com, penberg@kernel.org, mpm@selenic.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com, Pravin B Shelar <pshelar@nicira.com>

v2-v3:
	- Check if page is still compound page after inc refcnt.
v1-v2:
	- Avoid taking compound lock for slab pages.

--8<--------------------------cut here-------------------------->8--

Transparent huge pages can change page->flags (PG_compound_lock)
without taking Slab lock. Since THP can not break slab pages we can
safely access compound page without taking compound lock.

Specifically this patch fixes race between compound_unlock and slab
functions which does page-flags update. This can occur when
get_page/put_page is called on page from slab object.

Reported-by: Amey Bhide <abhide@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
---
 include/linux/mm.h |    2 ++
 mm/swap.c          |   27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

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
index 8ff73d8..44a0f81 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -82,6 +82,19 @@ static void put_compound_page(struct page *page)
 		if (likely(page != page_head &&
 			   get_page_unless_zero(page_head))) {
 			unsigned long flags;
+
+			if (PageSlab(page_head)) {
+				if (PageTail(page)) {
+					/* THP can not break up slab pages, avoid
+					 * taking compound_lock(). */
+					if (put_page_testzero(page_head))
+						VM_BUG_ON(1);
+
+					atomic_dec(&page->_mapcount);
+					goto skip_lock_tail;
+				} else
+					goto skip_lock;
+			}
 			/*
 			 * page_head wasn't a dangling pointer but it
 			 * may not be a head page anymore by the time
@@ -93,6 +106,7 @@ static void put_compound_page(struct page *page)
 				/* __split_huge_page_refcount run before us */
 				compound_unlock_irqrestore(page_head, flags);
 				VM_BUG_ON(PageHead(page_head));
+			skip_lock:
 				if (put_page_testzero(page_head))
 					__put_single_page(page_head);
 			out_put_single:
@@ -115,6 +129,8 @@ static void put_compound_page(struct page *page)
 			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
 			VM_BUG_ON(atomic_read(&page->_count) != 0);
 			compound_unlock_irqrestore(page_head, flags);
+
+			skip_lock_tail:
 			if (put_page_testzero(page_head)) {
 				if (PageHead(page_head))
 					__put_compound_page(page_head);
@@ -162,6 +178,15 @@ bool __get_page_tail(struct page *page)
 	struct page *page_head = compound_trans_head(page);
 
 	if (likely(page != page_head && get_page_unless_zero(page_head))) {
+
+		if (PageSlab(page_head)) {
+			if (likely(PageTail(page))) {
+				__get_page_tail_foll(page, false);
+				return true;
+			} else
+				goto out;
+		}
+
 		/*
 		 * page_head wasn't a dangling pointer but it
 		 * may not be a head page anymore by the time
@@ -175,6 +200,8 @@ bool __get_page_tail(struct page *page)
 			got = true;
 		}
 		compound_unlock_irqrestore(page_head, flags);
+
+		out:
 		if (unlikely(!got))
 			put_page(page_head);
 	}
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
