Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63A886B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 12:06:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m98so84373246iod.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 09:06:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k185si5033399itb.12.2017.02.06.09.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 09:06:56 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v16H4KXg023681
	for <linux-mm@kvack.org>; Mon, 6 Feb 2017 12:06:55 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28etc208ep-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Feb 2017 12:06:55 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 6 Feb 2017 10:06:54 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/autonuma: don't use set_pte_at when updating protnone ptes
Date: Mon,  6 Feb 2017 22:36:16 +0530
Message-Id: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Architectures like ppc64, use privilege access bit to mark pte non accessible.
This implies that kernel can do a copy_to_user to an address marked for numa fault.
This also implies that there can be a parallel hardware update for the pte.
set_pte_at cannot be used in such scenarios. Hence switch the pte
update to use ptep_get_and_clear and set_pte_at combination.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/pgtable.c |  7 +------
 mm/memory.c               | 18 +++++++++---------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index cb39c8bd2436..b8ac81a16389 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -186,12 +186,7 @@ static pte_t set_access_flags_filter(pte_t pte, struct vm_area_struct *vma,
 void set_pte_at(struct mm_struct *mm, unsigned long addr, pte_t *ptep,
 		pte_t pte)
 {
-	/*
-	 * When handling numa faults, we already have the pte marked
-	 * _PAGE_PRESENT, but we can be sure that it is not in hpte.
-	 * Hence we can use set_pte_at for them.
-	 */
-	VM_WARN_ON(pte_present(*ptep) && !pte_protnone(*ptep));
+	VM_WARN_ON(pte_present(*ptep));
 
 	/*
 	 * Add the pte bit when tryint set a pte
diff --git a/mm/memory.c b/mm/memory.c
index 6bf2b471e30c..e78bf72f30dd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3387,32 +3387,32 @@ static int do_numa_page(struct vm_fault *vmf)
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
-	pte_t pte = vmf->orig_pte;
-	bool was_writable = pte_write(pte);
+	pte_t pte;
+	bool was_writable = pte_write(vmf->orig_pte);
 	int flags = 0;
 
 	/*
 	* The "pte" at this point cannot be used safely without
 	* validation through pte_unmap_same(). It's of NUMA type but
 	* the pfn may be screwed if the read is non atomic.
-	*
-	* We can safely just do a "set_pte_at()", because the old
-	* page table entry is not accessible, so there would be no
-	* concurrent hardware modifications to the PTE.
 	*/
 	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
-	if (unlikely(!pte_same(*vmf->pte, pte))) {
+	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		goto out;
 	}
 
-	/* Make it present again */
+	/*
+	 * Make it present again, Depending on how arch implementes non
+	 * accessible ptes, some can allow access by kernel mode.
+	 */
+	pte = ptep_modify_prot_start(vma->vm_mm, vmf->address, vmf->pte);
 	pte = pte_modify(pte, vma->vm_page_prot);
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
-	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
+	ptep_modify_prot_commit(vma->vm_mm, vmf->address, vmf->pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
 	page = vm_normal_page(vma, vmf->address, pte);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
