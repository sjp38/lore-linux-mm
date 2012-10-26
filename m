Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2FC966B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 08:53:46 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] numa, mm: drop redundant check in do_huge_pmd_numa_page()
Date: Fri, 26 Oct 2012 15:54:34 +0300
Message-Id: <1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Will Deacon <will.deacon@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We check if the pmd entry is the same as on pmd_trans_huge() in
handle_mm_fault(). That's enough.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3c14a96..9bb2c23 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -758,12 +758,6 @@ void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(!pmd_same(*pmd, entry)))
 		goto unlock;
 
-	if (unlikely(pmd_trans_splitting(entry))) {
-		spin_unlock(&mm->page_table_lock);
-		wait_split_huge_page(vma->anon_vma, pmd);
-		return;
-	}
-
 	page = pmd_page(entry);
 	if (page) {
 		VM_BUG_ON(!PageCompound(page) || !PageHead(page));
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
