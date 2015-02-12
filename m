Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 02D5F900016
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:19:41 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kx10so12435133pab.0
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:19:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id km8si5087460pbc.254.2015.02.12.08.19.39
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:19:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 03/24] mm: avoid PG_locked on tail pages
Date: Thu, 12 Feb 2015 18:18:17 +0200
Message-Id: <1423757918-197669-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 5ed7bdaf22d5..d471370f27e8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -207,7 +207,8 @@ static inline int __TestClearPage##uname(struct page *page) { return 0; }
 
 struct page;	/* forward declaration */
 
-TESTPAGEFLAG(Locked, locked)
+#define PageLocked(page) test_bit(PG_locked, &compound_head(page)->flags)
+
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 	__SETPAGEFLAG(Referenced, referenced)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 4b3736f7065c..ad6da4e49555 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -428,16 +428,19 @@ extern void unlock_page(struct page *page);
 
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
 
@@ -490,6 +493,7 @@ extern int wait_on_page_bit_killable_timeout(struct page *page,
 
 static inline int wait_on_page_locked_killable(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLocked(page))
 		return wait_on_page_bit_killable(page, PG_locked);
 	return 0;
@@ -510,6 +514,7 @@ static inline void wake_up_page(struct page *page, int bit)
  */
 static inline void wait_on_page_locked(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLocked(page))
 		wait_on_page_bit(page, PG_locked);
 }
diff --git a/mm/filemap.c b/mm/filemap.c
index ad7242043bdb..b02c3f7cbe64 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -744,6 +744,7 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  */
 void unlock_page(struct page *page)
 {
+	page = compound_head(page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_atomic();
diff --git a/mm/slub.c b/mm/slub.c
index 0909e13cf708..16ba8c9665e2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -338,11 +338,13 @@ static inline int oo_objects(struct kmem_cache_order_objects x)
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
