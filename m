From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/14] mm: fix major/minor fault accounting on retried fault
Date: Tue, 07 Apr 2009 19:50:41 +0800
Message-ID: <20090407115233.975503899@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 386045F0002
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:50 -0400 (EDT)
Content-Disposition: inline; filename=filemap-major-fault-retry.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ying Han <yinghan@google.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

VM_FAULT_RETRY does make major/minor faults accounting a bit twisted..

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 arch/x86/mm/fault.c |    2 ++
 mm/memory.c         |   22 ++++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

--- mm.orig/arch/x86/mm/fault.c
+++ mm/arch/x86/mm/fault.c
@@ -1160,6 +1160,8 @@ good_area:
 	if (fault & VM_FAULT_RETRY) {
 		if (retry_flag) {
 			retry_flag = 0;
+			tsk->maj_flt++;
+			tsk->min_flt--;
 			goto retry;
 		}
 		BUG();
--- mm.orig/mm/memory.c
+++ mm/mm/memory.c
@@ -2882,26 +2882,32 @@ int handle_mm_fault(struct mm_struct *mm
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	int ret;
 
 	__set_current_state(TASK_RUNNING);
 
-	count_vm_event(PGFAULT);
-
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+	if (unlikely(is_vm_hugetlb_page(vma))) {
+		ret = hugetlb_fault(mm, vma, address, write_access);
+		goto out;
+	}
 
+	ret = VM_FAULT_OOM;
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
 	if (!pud)
-		return VM_FAULT_OOM;
+		goto out;
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
-		return VM_FAULT_OOM;
+		goto out;
 	pte = pte_alloc_map(mm, pmd, address);
 	if (!pte)
-		return VM_FAULT_OOM;
+		goto out;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	ret = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+out:
+	if (!(ret & VM_FAULT_RETRY))
+		count_vm_event(PGFAULT);
+	return ret;
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
