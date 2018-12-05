Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 184EF6B7220
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 22:10:01 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c34so6739412edb.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 19:10:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o1-v6si51560ejb.330.2018.12.04.19.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 19:09:59 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB533kFl110673
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 22:09:57 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p63s1xde2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 22:09:57 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Dec 2018 03:09:56 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V3 3/5] arch/powerpc/mm: Nest MMU workaround for mprotect RW upgrade.
Date: Wed,  5 Dec 2018 08:39:29 +0530
In-Reply-To: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
References: <20181205030931.12037-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181205030931.12037-4-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

NestMMU requires us to mark the pte invalid and flush the tlb when we do a
RW upgrade of pte. We fixed a variant of this in the fault path in commit
Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")

Do the same for mprotect upgrades.

Hugetlb is handled in the next patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 18 +++++++++++++
 arch/powerpc/include/asm/book3s/64/radix.h   |  4 +++
 arch/powerpc/mm/pgtable-book3s64.c           | 27 ++++++++++++++++++++
 arch/powerpc/mm/pgtable-radix.c              | 18 +++++++++++++
 4 files changed, 67 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 2e6ada28da64..92eaea164700 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1314,6 +1314,24 @@ static inline int pud_pfn(pud_t pud)
 	BUILD_BUG();
 	return 0;
 }
+#define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
+pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
+void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
+			     pte_t *, pte_t, pte_t);
+
+/*
+ * Returns true for a R -> RW upgrade of pte
+ */
+static inline bool is_pte_rw_upgrade(unsigned long old_val, unsigned long new_val)
+{
+	if (!(old_val & _PAGE_READ))
+		return false;
+
+	if ((!(old_val & _PAGE_WRITE)) && (new_val & _PAGE_WRITE))
+		return true;
+
+	return false;
+}
 
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
index 7d1a3d1543fc..5ab134eeed20 100644
--- a/arch/powerpc/include/asm/book3s/64/radix.h
+++ b/arch/powerpc/include/asm/book3s/64/radix.h
@@ -127,6 +127,10 @@ extern void radix__ptep_set_access_flags(struct vm_area_struct *vma, pte_t *ptep
 					 pte_t entry, unsigned long address,
 					 int psize);
 
+extern void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
+					   unsigned long addr, pte_t *ptep,
+					   pte_t old_pte, pte_t pte);
+
 static inline unsigned long __radix_pte_update(pte_t *ptep, unsigned long clr,
 					       unsigned long set)
 {
diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
index 9f93c9f985c5..3d126353b11e 100644
--- a/arch/powerpc/mm/pgtable-book3s64.c
+++ b/arch/powerpc/mm/pgtable-book3s64.c
@@ -482,3 +482,30 @@ void arch_report_meminfo(struct seq_file *m)
 		   atomic_long_read(&direct_pages_count[MMU_PAGE_1G]) << 20);
 }
 #endif /* CONFIG_PROC_FS */
+
+pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
+			     pte_t *ptep)
+{
+	unsigned long pte_val;
+
+	/*
+	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
+	 * possible. Also keep the pte_present true so that we don't take
+	 * wrong fault.
+	 */
+	pte_val = pte_update(vma->vm_mm, addr, ptep, _PAGE_PRESENT, _PAGE_INVALID, 0);
+
+	return __pte(pte_val);
+
+}
+EXPORT_SYMBOL(ptep_modify_prot_start);
+
+void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
+			     pte_t *ptep, pte_t old_pte, pte_t pte)
+{
+	if (radix_enabled())
+		return radix__ptep_modify_prot_commit(vma, addr,
+						      ptep, old_pte, pte);
+	set_pte_at(vma->vm_mm, addr, ptep, pte);
+}
+EXPORT_SYMBOL(ptep_modify_prot_commit);
diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
index 931156069a81..dced3cd241c2 100644
--- a/arch/powerpc/mm/pgtable-radix.c
+++ b/arch/powerpc/mm/pgtable-radix.c
@@ -1063,3 +1063,21 @@ void radix__ptep_set_access_flags(struct vm_area_struct *vma, pte_t *ptep,
 	}
 	/* See ptesync comment in radix__set_pte_at */
 }
+
+void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
+				    unsigned long addr, pte_t *ptep,
+				    pte_t old_pte, pte_t pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	/*
+	 * To avoid NMMU hang while relaxing access we need to flush the tlb before
+	 * we set the new value. We need to do this only for radix, because hash
+	 * translation does flush when updating the linux pte.
+	 */
+	if (is_pte_rw_upgrade(pte_val(old_pte), pte_val(pte)) &&
+	    (atomic_read(&mm->context.copros) > 0))
+		radix__flush_tlb_page(vma, addr);
+
+	set_pte_at(mm, addr, ptep, pte);
+}
-- 
2.19.2
