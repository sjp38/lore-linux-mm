Message-Id: <200603302318.k2UNIJg25911@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] fix extra page ref count in follow_hugetlb_page
Date: Thu, 30 Mar 2006 15:19:04 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, 'Adam Litke' <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

"[PATCH] optimize follow_hugetlb_page" breaks mlock on hugepage areas.

I mis-interpret pages argument and made get_page() unconditional.  It
should only get a ref count when "pages" argument is non-null.

Credit goes to Adam Litke who spotted the bug.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Acked-by: Adam Litke <agl@us.ibm.com>


--- ./mm/hugetlb.c.orig	2006-03-30 15:54:20.000000000 -0800
+++ ./mm/hugetlb.c	2006-03-30 15:54:56.000000000 -0800
@@ -555,9 +555,10 @@ int follow_hugetlb_page(struct mm_struct
 		pfn_offset = (vaddr & ~HPAGE_MASK) >> PAGE_SHIFT;
 		page = pte_page(*pte);
 same_page:
-		get_page(page);
-		if (pages)
+		if (pages) {
+			get_page(page);
 			pages[i] = page + pfn_offset;
+		}
 
 		if (vmas)
 			vmas[i] = vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
