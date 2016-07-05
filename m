Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 910E26B025E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 08:00:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so86504965wme.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 05:00:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id kb8si3025312wjc.290.2016.07.05.05.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 05:00:49 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65Bs9Ew069654
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 08:00:48 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x7rvyvna-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Jul 2016 08:00:48 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Jul 2016 13:00:46 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7561C1B08069
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 13:02:00 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u65C0gVS16515528
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 12:00:42 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u65C0gta020322
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 06:00:42 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/2] mm: add callback to prepare the update of multiple page table entries
Date: Tue,  5 Jul 2016 14:00:39 +0200
In-Reply-To: <1467720040-4280-1-git-send-email-schwidefsky@de.ibm.com>
References: <1467720040-4280-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1467720040-4280-2-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Add a new callback 'ptep_prepare_range' to allow the architecture
code to optimize the modification of multiple page table entries.

The background for the callback is an instruction found on s390.
The IPTE-range instruction can be used to invalidate up to 256 ptes
with a single IPI, including the flush of the TLB entries associated
to the address range.

This has similarities to the arch_[enter|leave]_lazy_mmu_mode, but for
a more specific situation. ptep_prepare_range is called for the update
of a block of ptes.

ptep_prepare_range is called optimistically, the callback may choose
to do nothing. In this case the individual single pte operation and
the arch_[enter|leave]_lazy_mmu_mode mechanics need to deal with the
invalidation and the associated TLB flush.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/asm-generic/pgtable.h | 4 ++++
 mm/memory.c                   | 2 ++
 mm/mprotect.c                 | 1 +
 mm/mremap.c                   | 1 +
 4 files changed, 8 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 9401f48..b29f360 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -192,6 +192,10 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addres
 }
 #endif
 
+#ifndef ptep_prepare_range
+#define ptep_prepare_range(mm, start, end, ptep, full) do {} while (0)
+#endif
+
 #ifndef __HAVE_ARCH_PMDP_SET_WRPROTECT
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
diff --git a/mm/memory.c b/mm/memory.c
index 07493e3..eeecb92 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -934,6 +934,7 @@ again:
 	orig_src_pte = src_pte;
 	orig_dst_pte = dst_pte;
 	arch_enter_lazy_mmu_mode();
+	ptep_prepare_range(src_mm, addr, end, src_pte, 0);
 
 	do {
 		/*
@@ -1114,6 +1115,7 @@ again:
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	pte = start_pte;
 	arch_enter_lazy_mmu_mode();
+	ptep_prepare_range(mm, addr, end, pte, tlb->fullmm);
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent)) {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b650c54..3fa15b5 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -74,6 +74,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		return 0;
 
 	arch_enter_lazy_mmu_mode();
+	ptep_prepare_range(mm, addr, end, pte, 0);
 	do {
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 3fa0a467..5f4d0af 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -135,6 +135,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 	arch_enter_lazy_mmu_mode();
+	ptep_prepare_range(mm, old_addr, old_end, old_pte, 0);
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
