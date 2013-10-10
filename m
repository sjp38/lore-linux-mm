Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 219AB6B003A
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:10 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so3018137pdi.27
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:09 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/34] mm: allow pgtable_page_ctor() to fail
Date: Thu, 10 Oct 2013 21:05:30 +0300
Message-Id: <1381428359-14843-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Change pgtable_page_ctor() return type from void to bool.
Returns true, if initialization is successful and false otherwise.

Current implementation never fails, but it will change later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 75735f6171..f6467032a9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1254,10 +1254,11 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
 #endif /* USE_SPLIT_PTE_PTLOCKS */
 
-static inline void pgtable_page_ctor(struct page *page)
+static inline bool pgtable_page_ctor(struct page *page)
 {
 	pte_lock_init(page);
 	inc_zone_page_state(page, NR_PAGETABLE);
+	return true;
 }
 
 static inline void pgtable_page_dtor(struct page *page)
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
