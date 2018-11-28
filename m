Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3436B4F9B
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:55:34 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j202so3967414itj.1
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 15:55:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t187sor39446iod.103.2018.11.28.15.55.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 15:55:33 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] mm: remove pte_lock_deinit()
Date: Wed, 28 Nov 2018 16:55:25 -0700
Message-Id: <20181128235525.58780-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Souptick Joarder <jrdr.linux@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

Pagetable page doesn't touch page->mapping or have any used field
that overlaps with it. No need to clear mapping in dtor. In fact,
doing so might mask problems that otherwise would be detected by
bad_page().

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 include/linux/mm.h | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..7c8f4fc9244e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1900,13 +1900,6 @@ static inline bool ptlock_init(struct page *page)
 	return true;
 }
 
-/* Reset page->mapping so free_pages_check won't complain. */
-static inline void pte_lock_deinit(struct page *page)
-{
-	page->mapping = NULL;
-	ptlock_free(page);
-}
-
 #else	/* !USE_SPLIT_PTE_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
@@ -1917,7 +1910,7 @@ static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
 }
 static inline void ptlock_cache_init(void) {}
 static inline bool ptlock_init(struct page *page) { return true; }
-static inline void pte_lock_deinit(struct page *page) {}
+static inline void ptlock_free(struct page *page) {}
 #endif /* USE_SPLIT_PTE_PTLOCKS */
 
 static inline void pgtable_init(void)
@@ -1937,7 +1930,7 @@ static inline bool pgtable_page_ctor(struct page *page)
 
 static inline void pgtable_page_dtor(struct page *page)
 {
-	pte_lock_deinit(page);
+	ptlock_free(page);
 	__ClearPageTable(page);
 	dec_zone_page_state(page, NR_PAGETABLE);
 }
-- 
2.20.0.rc1.387.gf8505762e3-goog
