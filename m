Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53B986B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:20 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so927045pab.10
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:20 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q8si3286323pds.51.2014.11.05.06.50.06
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 04/19] mm: avoid PG_locked on tail pages
Date: Wed,  5 Nov 2014 16:49:39 +0200
Message-Id: <1415198994-15252-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting pte entries can point to tail pages. It's doesn't
make much sense to mark tail page locked -- we need to protect whole
compound page.

This patch adjust helpers related to PG_locked to operate on head page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 3 ++-
 include/linux/pagemap.h    | 5 +++++
 mm/filemap.c               | 1 +
 mm/slub.c                  | 2 ++
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd79792..676f72d29ac2 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -203,7 +203,8 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 
 struct page;	/* forward declaration */
 
-TESTPAGEFLAG(Locked, locked)
+#define PageLocked(page) test_bit(PG_locked, &compound_head(page)->flags)
+
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 	__SETPAGEFLAG(Referenced, referenced)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 3df8c7db7a4e..110e86e480bb 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -445,16 +445,19 @@ extern void unlock_page(struct page *page);
 
 static inline void __set_page_locked(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	__set_bit(PG_locked, &page->flags);
 }
 
 static inline void __clear_page_locked(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	__clear_bit(PG_locked, &page->flags);
 }
 
 static inline int trylock_page(struct page *page)
 {
+	page = compound_head(page);
 	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
 }
 
@@ -505,6 +508,7 @@ extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
 
 static inline int wait_on_page_locked_killable(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLocked(page))
 		return wait_on_page_bit_killable(page, PG_locked);
 	return 0;
@@ -519,6 +523,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
  */
 static inline void wait_on_page_locked(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLocked(page))
 		wait_on_page_bit(page, PG_locked);
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index f501b56ec2c6..020d4afd45df 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -735,6 +735,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  */
 void unlock_page(struct page *page)
 {
+	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_atomic();
diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc07a76..de37b20abaa9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -347,11 +347,13 @@ static inline int oo_objects(struct kmem_cache_order_objects x)
  */
 static __always_inline void slab_lock(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	bit_spin_lock(PG_locked, &page->flags);
 }
 
 static __always_inline void slab_unlock(struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
