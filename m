Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5033B6B7223
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 22:10:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so10296645pgv.19
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 19:10:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m15si17085575pgc.381.2018.12.04.19.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 19:10:10 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB533lK1052127
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 22:10:09 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p63sunt9s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 22:10:09 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Dec 2018 03:10:08 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V3 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW upgrade
Date: Wed,  5 Dec 2018 08:39:31 +0530
In-Reply-To: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181205030931.12037-6-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

NestMMU requires us to mark the pte invalid and flush the tlb when we do a
RW upgrade of pte. We fixed a variant of this in the fault path in commit
Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++
 arch/powerpc/mm/hugetlbpage-radix.c          | 17 ++++++++++++
 arch/powerpc/mm/hugetlbpage.c                | 29 ++++++++++++++++++++
 3 files changed, 58 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 5b0177733994..66c1e4f88d65 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -13,6 +13,10 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 				unsigned long len, unsigned long pgoff,
 				unsigned long flags);
 
+extern void radix__huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
+						unsigned long addr, pte_t *ptep,
+						pte_t old_pte, pte_t pte);
+
 static inline int hstate_get_psize(struct hstate *hstate)
 {
 	unsigned long shift;
@@ -42,4 +46,12 @@ static inline bool gigantic_page_supported(void)
 /* hugepd entry valid bit */
 #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
 
+#define huge_ptep_modify_prot_start huge_ptep_modify_prot_start
+extern pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
+					 unsigned long addr, pte_t *ptep);
+
+#define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
+extern void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
+					 unsigned long addr, pte_t *ptep,
+					 pte_t old_pte, pte_t new_pte);
 #endif
diff --git a/arch/powerpc/mm/hugetlbpage-radix.c b/arch/powerpc/mm/hugetlbpage-radix.c
index 2486bee0f93e..11d9ea28a816 100644
--- a/arch/powerpc/mm/hugetlbpage-radix.c
+++ b/arch/powerpc/mm/hugetlbpage-radix.c
@@ -90,3 +90,20 @@ radix__hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 
 	return vm_unmapped_area(&info);
 }
+
+void radix__huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
+					 unsigned long addr, pte_t *ptep,
+					 pte_t old_pte, pte_t pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	/*
+	 * To avoid NMMU hang while relaxing access we need to flush the tlb before
+	 * we set the new value.
+	 */
+	if (is_pte_rw_upgrade(pte_val(old_pte), pte_val(pte)) &&
+	    (atomic_read(&mm->context.copros) > 0))
+		radix__flush_hugetlb_page(vma, addr);
+
+	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
+}
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 8cf035e68378..39d33a3d0dc6 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -912,3 +912,32 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 
 	return 1;
 }
+
+#ifdef CONFIG_PPC_BOOK3S_64
+pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
+				  unsigned long addr, pte_t *ptep)
+{
+	unsigned long pte_val;
+	/*
+	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
+	 * possible. Also keep the pte_present true so that we don't take
+	 * wrong fault.
+	 */
+	pte_val = pte_update(vma->vm_mm, addr, ptep,
+			     _PAGE_PRESENT, _PAGE_INVALID, 1);
+
+	return __pte(pte_val);
+}
+EXPORT_SYMBOL(huge_ptep_modify_prot_start);
+
+void huge_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
+				  pte_t *ptep, pte_t old_pte, pte_t pte)
+{
+
+	if (radix_enabled())
+		return radix__huge_ptep_modify_prot_commit(vma, addr, ptep,
+							   old_pte, pte);
+	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
+}
+EXPORT_SYMBOL(huge_ptep_modify_prot_commit);
+#endif
-- 
2.19.2
