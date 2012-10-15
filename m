Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 9C7A26B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 02:00:15 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v4 03/10] thp: copy_huge_pmd(): copy huge zero page
Date: Mon, 15 Oct 2012 09:00:52 +0300
Message-Id: <1350280859-18801-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It's easy to copy huge zero page. Just set destination pmd to huge zero
page.

It's safe to copy huge zero page since we have none yet :-p

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 680c27f..9f5e5cb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -700,6 +700,18 @@ static inline struct page *alloc_hugepage(int defrag)
 }
 #endif
 
+static void set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd)
+{
+	pmd_t entry;
+	entry = pfn_pmd(huge_zero_pfn, vma->vm_page_prot);
+	entry = pmd_wrprotect(entry);
+	entry = pmd_mkhuge(entry);
+	set_pmd_at(mm, haddr, pmd, entry);
+	pgtable_trans_huge_deposit(mm, pgtable);
+	mm->nr_ptes++;
+}
+
 int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
@@ -777,6 +789,11 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_free(dst_mm, pgtable);
 		goto out_unlock;
 	}
+	if (is_huge_zero_pmd(pmd)) {
+		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd);
+		ret = 0;
+		goto out_unlock;
+	}
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
 		spin_unlock(&src_mm->page_table_lock);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
