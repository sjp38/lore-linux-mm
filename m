Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A57236B03A3
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 13:42:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q25so2123376pfg.6
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:42:59 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id j8si17480955pgn.241.2017.04.11.10.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 10:42:58 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 81so668948pgh.3
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:42:58 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH 2/9] mm/huge_memory: Deposit a pgtable for DAX PMD faults when required
Date: Wed, 12 Apr 2017 03:42:26 +1000
Message-Id: <20170411174233.21902-3-oohall@gmail.com>
In-Reply-To: <20170411174233.21902-1-oohall@gmail.com>
References: <20170411174233.21902-1-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: arbab@linux.vnet.ibm.com, bsingharora@gmail.com, linux-nvdimm@lists.01.org, Oliver O'Halloran <oohall@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org

Although all architectures use a deposited page table for THP on anonymous VMAs
some architectures (s390 and powerpc) require the deposited storage even for
file backed VMAs due to quirks of their MMUs. This patch adds support for
depositing a table in DAX PMD fault handling path for archs that require it.
Other architectures should see no functional changes.

Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
---
 mm/huge_memory.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index aa01dd47cc65..a84909cf20d3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -715,7 +715,8 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 }
 
 static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write)
+		pmd_t *pmd, pfn_t pfn, pgprot_t prot, bool write,
+		pgtable_t pgtable)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t entry;
@@ -729,6 +730,12 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		entry = pmd_mkyoung(pmd_mkdirty(entry));
 		entry = maybe_pmd_mkwrite(entry, vma);
 	}
+
+	if (pgtable) {
+		pgtable_trans_huge_deposit(mm, pmd, pgtable);
+		atomic_long_inc(&mm->nr_ptes);
+	}
+
 	set_pmd_at(mm, addr, pmd, entry);
 	update_mmu_cache_pmd(vma, addr, pmd);
 	spin_unlock(ptl);
@@ -738,6 +745,7 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
+	pgtable_t pgtable = NULL;
 	/*
 	 * If we had pmd_special, we could avoid all these restrictions,
 	 * but we need to be consistent with PTEs and architectures that
@@ -752,9 +760,15 @@ int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return VM_FAULT_SIGBUS;
 
+	if (arch_needs_pgtable_deposit()) {
+		pgtable = pte_alloc_one(vma->vm_mm, addr);
+		if (!pgtable)
+			return VM_FAULT_OOM;
+	}
+
 	track_pfn_insert(vma, &pgprot, pfn);
 
-	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write);
+	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write, pgtable);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(vmf_insert_pfn_pmd);
@@ -1611,6 +1625,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb->fullmm);
 	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	if (vma_is_dax(vma)) {
+		if (arch_needs_pgtable_deposit())
+			zap_deposited_table(tlb->mm, pmd);
 		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
 			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
