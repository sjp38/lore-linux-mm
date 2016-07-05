Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 447AC6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 08:00:49 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id da8so204818529obb.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 05:00:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w14si4017751pfa.187.2016.07.05.05.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 05:00:48 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65BsKiw054080
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 08:00:47 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23x8ww7d6h-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Jul 2016 08:00:47 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Jul 2016 13:00:45 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 46154219005F
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 13:00:12 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u65C0hSs1901024
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 12:00:43 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u65C0gOk009367
	for <linux-mm@kvack.org>; Tue, 5 Jul 2016 06:00:42 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page table entries
Date: Tue,  5 Jul 2016 14:00:40 +0200
In-Reply-To: <1467720040-4280-1-git-send-email-schwidefsky@de.ibm.com>
References: <1467720040-4280-1-git-send-email-schwidefsky@de.ibm.com>
Message-Id: <1467720040-4280-3-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

The IPTE instruction with the range option can invalidate up to 256 page
table entries at once. This speeds up the mprotect, munmap, mremap and
fork operations for multi-threaded programs.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h | 25 +++++++++++++++++++++++++
 arch/s390/include/asm/setup.h   |  2 ++
 arch/s390/kernel/early.c        |  2 ++
 arch/s390/mm/pageattr.c         |  2 +-
 arch/s390/mm/pgtable.c          | 17 +++++++++++++++++
 5 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 20e5f7d..2caf726 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -997,6 +997,31 @@ static inline int ptep_set_access_flags(struct vm_area_struct *vma,
 	return 1;
 }
 
+void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
+			   unsigned long end, pte_t *ptep);
+
+static inline void ptep_prepare_range(struct mm_struct *mm,
+				      unsigned long start,
+				      unsigned long end,
+				      pte_t *ptep, int full)
+{
+	if (!full)
+		ptep_invalidate_range(mm, start, end, ptep);
+}
+#define ptep_prepare_range ptep_prepare_range
+
+#define __HAVE_ARCH_MOVE_PTE
+static inline pte_t move_pte(pte_t pte, pgprot_t prot,
+			     unsigned long old_addr,
+			     unsigned long new_addr)
+{
+	if ((pte_val(pte) & _PAGE_PRESENT) &&
+	    (pte_val(pte) & _PAGE_READ) &&
+	    (pte_val(pte) & _PAGE_YOUNG))
+		pte_val(pte) &= ~_PAGE_INVALID;
+	return pte;
+}
+
 /*
  * Additional functions to handle KVM guest page tables
  */
diff --git a/arch/s390/include/asm/setup.h b/arch/s390/include/asm/setup.h
index c0f0efb..58b13e0 100644
--- a/arch/s390/include/asm/setup.h
+++ b/arch/s390/include/asm/setup.h
@@ -30,6 +30,7 @@
 #define MACHINE_FLAG_TLB_LC	_BITUL(12)
 #define MACHINE_FLAG_VX		_BITUL(13)
 #define MACHINE_FLAG_CAD	_BITUL(14)
+#define MACHINE_FLAG_IPTE_RANGE	_BITUL(15)
 
 #define LPP_MAGIC		_BITUL(31)
 #define LPP_PFAULT_PID_MASK	_AC(0xffffffff, UL)
@@ -71,6 +72,7 @@ extern void detect_memory_memblock(void);
 #define MACHINE_HAS_TLB_LC	(S390_lowcore.machine_flags & MACHINE_FLAG_TLB_LC)
 #define MACHINE_HAS_VX		(S390_lowcore.machine_flags & MACHINE_FLAG_VX)
 #define MACHINE_HAS_CAD		(S390_lowcore.machine_flags & MACHINE_FLAG_CAD)
+#define MACHINE_HAS_IPTE_RANGE	(S390_lowcore.machine_flags & MACHINE_FLAG_IPTE_RANGE)
 
 /*
  * Console mode. Override with conmode=
diff --git a/arch/s390/kernel/early.c b/arch/s390/kernel/early.c
index 717b03a..ebf69c4 100644
--- a/arch/s390/kernel/early.c
+++ b/arch/s390/kernel/early.c
@@ -339,6 +339,8 @@ static __init void detect_machine_facilities(void)
 		S390_lowcore.machine_flags |= MACHINE_FLAG_EDAT1;
 		__ctl_set_bit(0, 23);
 	}
+	if (test_facility(13))
+		S390_lowcore.machine_flags |= MACHINE_FLAG_IPTE_RANGE;
 	if (test_facility(78))
 		S390_lowcore.machine_flags |= MACHINE_FLAG_EDAT2;
 	if (test_facility(3))
diff --git a/arch/s390/mm/pageattr.c b/arch/s390/mm/pageattr.c
index 7104ffb..91809d9 100644
--- a/arch/s390/mm/pageattr.c
+++ b/arch/s390/mm/pageattr.c
@@ -306,7 +306,7 @@ static void ipte_range(pte_t *pte, unsigned long address, int nr)
 {
 	int i;
 
-	if (test_facility(13)) {
+	if (MACHINE_HAS_IPTE_RANGE) {
 		__ptep_ipte_range(address, nr - 1, pte);
 		return;
 	}
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 74f8f2a..3dd85ec 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -283,6 +283,23 @@ void ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL(ptep_modify_prot_commit);
 
+void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
+			   unsigned long end, pte_t *ptep)
+{
+	unsigned long nr;
+
+	if (!MACHINE_HAS_IPTE_RANGE || mm_has_pgste(mm))
+		return;
+	preempt_disable();
+	nr = (end - start) >> PAGE_SHIFT;
+	/* If the flush is likely to be local skip the ipte range */
+	if (nr && !cpumask_equal(mm_cpumask(mm),
+				 cpumask_of(smp_processor_id())))
+		__ptep_ipte_range(start, nr - 1, ptep);
+	preempt_enable();
+}
+EXPORT_SYMBOL(ptep_invalidate_range);
+
 static inline pmd_t pmdp_flush_direct(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
 {
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
