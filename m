Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 73A936B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:26:11 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v6 09/12] thp: lazy huge zero page allocation
Date: Thu, 15 Nov 2012 21:26:59 +0200
Message-Id: <1353007622-18393-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Instead of allocating huge zero page on hugepage_init() we can postpone it
until first huge zero page map. It saves memory if THP is not in use.

cmpxchg() is used to avoid race on huge_zero_pfn initialization.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ca3f6f2..bad9c8f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -160,22 +160,24 @@ static int start_khugepaged(void)
 	return err;
 }
 
-static int __init init_huge_zero_page(void)
+static int init_huge_zero_pfn(void)
 {
 	struct page *hpage;
+	unsigned long pfn;
 
 	hpage = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
 			HPAGE_PMD_ORDER);
 	if (!hpage)
 		return -ENOMEM;
-
-	huge_zero_pfn = page_to_pfn(hpage);
+	pfn = page_to_pfn(hpage);
+	if (cmpxchg(&huge_zero_pfn, 0, pfn))
+		__free_page(hpage);
 	return 0;
 }
 
 static inline bool is_huge_zero_pfn(unsigned long pfn)
 {
-	return pfn == huge_zero_pfn;
+	return huge_zero_pfn && pfn == huge_zero_pfn;
 }
 
 static inline bool is_huge_zero_pmd(pmd_t pmd)
@@ -564,10 +566,6 @@ static int __init hugepage_init(void)
 	if (err)
 		return err;
 
-	err = init_huge_zero_page();
-	if (err)
-		goto out;
-
 	err = khugepaged_slab_init();
 	if (err)
 		goto out;
@@ -590,8 +588,6 @@ static int __init hugepage_init(void)
 
 	return 0;
 out:
-	if (huge_zero_pfn)
-		__free_page(pfn_to_page(huge_zero_pfn));
 	hugepage_exit_sysfs(hugepage_kobj);
 	return err;
 }
@@ -728,6 +724,10 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		if (!(flags & FAULT_FLAG_WRITE)) {
 			pgtable_t pgtable;
+			if (unlikely(!huge_zero_pfn && init_huge_zero_pfn())) {
+				count_vm_event(THP_FAULT_FALLBACK);
+				goto out;
+			}
 			pgtable = pte_alloc_one(mm, haddr);
 			if (unlikely(!pgtable))
 				goto out;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
