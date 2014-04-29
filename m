Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEB36B0036
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:42:24 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y13so515186pdi.12
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:42:23 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id da1si590679pbc.337.2014.04.29.02.42.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 02:42:23 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so6887064pab.13
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 02:42:22 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 1/3] mm/swap.c: introduce put_[un]refcounted_compound_page helpers for spliting put_compound_page
Date: Tue, 29 Apr 2014 17:42:07 +0800
Message-Id: <b1987d6fb09745a5274895efbde79e37ff9557a3.1398764420.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, aarcange@redhat.com, mgorman@suse.de, nasa4836@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, put_compound_page should carefully handle tricky case
to avoid racing with compound page releasing or spliting, which
makes it growing quite lenthy(about 200+ lines) and need deep
tab indention, which makes it quite hard to follow and maintain.

This patch(and the next patch) tries to refactor this function.
It is a prepared patch.

Based on the code skeleton of put_compound_page:

put_compound_pge:
        if !PageTail(page)
        	put head page fastpath;
		return;

        /* else PageTail */
        page_head = compound_head(page)
        if !__compound_tail_refcounted(page_head)
		put head page optimal path; <---(1)
		return;
        else
		put head page slowpath; <--- (2)
                return;

This patch introduces two helpers, put_[un]refcounted_compound_page,
handling the code path (1) and code path (2), respectively. They both
are tagged __always_inline, thus it elmiates function call overhead,
making them operating the same way as before.

They are almost copied verbatim(except one place, a "goto out_put_single"
is expanded), with some comments rephrasing.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/swap.c | 142 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 142 insertions(+)

diff --git a/mm/swap.c b/mm/swap.c
index c0cd7d0..a576449 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -79,6 +79,148 @@ static void __put_compound_page(struct page *page)
 	(*dtor)(page);
 }
 
+/**
+ * Two special cases here: we could avoid taking compound_lock_irqsave
+ * and could skip the tail refcounting(in _mapcount).
+ *
+ * 1. Hugetlbfs page:
+ *
+ *    PageHeadHuge will remain true until the compound page
+ *    is released and enters the buddy allocator, and it could
+ *    not be split by __split_huge_page_refcount().
+ *
+ *    So if we see PageHeadHuge set, and we have the tail page pin,
+ *    then we could safely put head page.
+ *
+ * 2. Slab THP page:
+ *
+ *    PG_slab is cleared before the slab frees the head page, and
+ *    tail pin cannot be the last reference left on the head page,
+ *    because the slab code is free to reuse the compound page
+ *    after a kfree/kmem_cache_free without having to check if
+ *    there's any tail pin left.  In turn all tail pinsmust be always
+ *    released while the head is still pinned by the slab code
+ *    and so we know PG_slab will be still set too.
+ *
+ *    So if we see PageSlab set, and we have the tail page pin,
+ *    then we could safely put head page.
+ */
+static __always_inline
+void put_unrefcounted_compound_page(struct page *page_head, struct page *page)
+{
+	/*
+	 * If @page is a THP tail, we must read the tail page
+	 * flags after the head page flags. The
+	 * __split_huge_page_refcount side enforces write memory barriers
+	 * between clearing PageTail and before the head page
+	 * can be freed and reallocated.
+	 */
+	smp_rmb();
+	if (likely(PageTail(page))) {
+		/*
+		 * __split_huge_page_refcount cannot race
+		 * here, see the comment above this function.
+		 */
+		VM_BUG_ON_PAGE(!PageHead(page_head), page_head);
+		VM_BUG_ON_PAGE(page_mapcount(page) != 0, page);
+		if (put_page_testzero(page_head)) {
+			/*
+			 * If this is the tail of a slab THP page,
+			 * the tail pin must not be the last reference
+			 * held on the page, because the PG_slab cannot
+			 * be cleared before all tail pins (which skips
+			 * the _mapcount tail refcounting) have been
+			 * released.
+			 *
+			 * If this is the tail of a hugetlbfs page,
+			 * the tail pin may be the last reference on
+			 * the page instead, because PageHeadHuge will
+			 * not go away until the compound page enters
+			 * the buddy allocator.
+			 */
+			VM_BUG_ON_PAGE(PageSlab(page_head), page_head);
+			__put_compound_page(page_head);
+		}
+	} else
+		/*
+		 * __split_huge_page_refcount run before us,
+		 * @page was a THP tail. The split @page_head
+		 * has been freed and reallocated as slab or
+		 * hugetlbfs page of smaller order (only
+		 * possible if reallocated as slab on x86).
+		 */
+		if (put_page_testzero(page))
+			__put_single_page(page);
+}
+
+static __always_inline
+void put_refcounted_compound_page(struct page *page_head, struct page *page)
+{
+	if (likely(page != page_head && get_page_unless_zero(page_head))) {
+		unsigned long flags;
+
+		/*
+		 * @page_head wasn't a dangling pointer but it may not
+		 * be a head page anymore by the time we obtain the
+		 * lock. That is ok as long as it can't be freed from
+		 * under us.
+		 */
+		flags = compound_lock_irqsave(page_head);
+		if (unlikely(!PageTail(page))) {
+			/* __split_huge_page_refcount run before us */
+			compound_unlock_irqrestore(page_head, flags);
+			if (put_page_testzero(page_head)) {
+				/*
+				 * The @page_head may have been freed
+				 * and reallocated as a compound page
+				 * of smaller order and then freed
+				 * again.  All we know is that it
+				 * cannot have become: a THP page, a
+				 * compound page of higher order, a
+				 * tail page.  That is because we
+				 * still hold the refcount of the
+				 * split THP tail and page_head was
+				 * the THP head before the split.
+				 */
+				if (PageHead(page_head))
+					__put_compound_page(page_head);
+				else
+					__put_single_page(page_head);
+			}
+out_put_single:
+			if (put_page_testzero(page))
+				__put_single_page(page);
+			return;
+		}
+		VM_BUG_ON_PAGE(page_head != page->first_page, page);
+		/*
+		 * We can release the refcount taken by
+		 * get_page_unless_zero() now that
+		 * __split_huge_page_refcount() is blocked on the
+		 * compound_lock.
+		 */
+		if (put_page_testzero(page_head))
+			VM_BUG_ON_PAGE(1, page_head);
+		/* __split_huge_page_refcount will wait now */
+		VM_BUG_ON_PAGE(page_mapcount(page) <= 0, page);
+		atomic_dec(&page->_mapcount);
+		VM_BUG_ON_PAGE(atomic_read(&page_head->_count) <= 0, page_head);
+		VM_BUG_ON_PAGE(atomic_read(&page->_count) != 0, page);
+		compound_unlock_irqrestore(page_head, flags);
+
+		if (put_page_testzero(page_head)) {
+			if (PageHead(page_head))
+				__put_compound_page(page_head);
+			else
+				__put_single_page(page_head);
+		}
+	} else {
+		/* @page_head is a dangling pointer */
+		VM_BUG_ON_PAGE(PageTail(page), page);
+		goto out_put_single;
+	}
+}
+
 static void put_compound_page(struct page *page)
 {
 	struct page *page_head;
-- 
2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
