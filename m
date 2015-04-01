Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A20106B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 18:53:04 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so69217371pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 15:53:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pq10si4717640pbb.99.2015.04.01.15.53.03
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 15:53:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: get page_cache_get_speculative() work on tail pages
Date: Thu,  2 Apr 2015 01:52:52 +0300
Message-Id: <1427928772-100068-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Generic RCU fast GUP rely on page_cache_get_speculative() to obtain pin
on pte-mapped page.  As pointed by Aneesh during review of my compound
pages refcounting rework, page_cache_get_speculative() would fail on
pte-mapped tail page, since tail pages always have page->_count == 0.

That means we would never be able to successfully obtain pin on
pte-mapped tail page via generic RCU fast GUP.

But the problem is not exclusive to my patchset. In current kernel some
drivers (sound, for instance) already map compound pages with PTEs.

Let's teach page_cache_get_speculative() about tail. We can acquire pin
by speculatively taking pin on head page and recheck that compound page
didn't disappear under us. Retry if it did.

We don't care about THP tail page refcounting -- THP *tail* pages
shouldn't be found where page_cache_get_speculative() is used --
pagecache radix tree or page tables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Steve Capper <steve.capper@linaro.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 include/linux/pagemap.h | 31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7c3790764795..573a2510da36 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -142,8 +142,10 @@ void release_pages(struct page **pages, int nr, bool cold);
  */
 static inline int page_cache_get_speculative(struct page *page)
 {
+	struct page *head_page;
 	VM_BUG_ON(in_interrupt());
-
+retry:
+	head_page = compound_head_fast(page);
 #ifdef CONFIG_TINY_RCU
 # ifdef CONFIG_PREEMPT_COUNT
 	VM_BUG_ON(!in_atomic());
@@ -157,11 +159,11 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * disabling preempt, and hence no need for the "speculative get" that
 	 * SMP requires.
 	 */
-	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_inc(&page->_count);
+	VM_BUG_ON_PAGE(page_count(head_page) == 0, head_page);
+	atomic_inc(&head_page->_count);
 
 #else
-	if (unlikely(!get_page_unless_zero(page))) {
+	if (unlikely(!get_page_unless_zero(head_page))) {
 		/*
 		 * Either the page has been freed, or will be freed.
 		 * In either case, retry here and the caller should
@@ -170,7 +172,26 @@ static inline int page_cache_get_speculative(struct page *page)
 		return 0;
 	}
 #endif
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	/* compound_head_fast() seen PageTail(page) == true */
+	if (unlikely(head_page != page)) {
+		/*
+		 * compound_head_fast() could fetch dangling page->first_page
+		 * pointer to an old compound page, so recheck that it's still
+		 * a tail page before returning.
+		 */
+		smp_mb__after_atomic();
+		if (unlikely(!PageTail(page))) {
+			put_page(head_page);
+			goto retry;
+		}
+		/*
+		 * Tail page refcounting is only required for THP pages.
+		 * If page_cache_get_speculative() got called on tail-THP pages
+		 * something went horribly wrong. We don't have THP in pagecache
+		 * and we don't map tail-THP to page tables.
+		 */
+		VM_BUG_ON_PAGE(compound_tail_refcounted(head_page), head_page);
+	}
 
 	return 1;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
