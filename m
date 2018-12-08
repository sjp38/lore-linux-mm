Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE4358E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 10:32:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so3363410edb.5
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 07:32:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e19-v6si2277892ejj.140.2018.12.08.07.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 07:32:32 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB8FTEIU037139
	for <linux-mm@kvack.org>; Sat, 8 Dec 2018 10:32:31 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p8b01hxna-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 08 Dec 2018 10:32:31 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 8 Dec 2018 15:32:29 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V3 1/5] mm: Update ptep_modify_prot_start/commit to take vm_area_struct as arg
In-Reply-To: <201812070559.TUZULzKt%fengguang.wu@intel.com>
References: <20181205030931.12037-2-aneesh.kumar@linux.ibm.com> <201812070559.TUZULzKt%fengguang.wu@intel.com>
Date: Sat, 08 Dec 2018 21:02:17 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <875zw4t4ou.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org

kbuild test robot <lkp@intel.com> writes:

> Hi Aneesh,
>
> I love your patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.20-rc5 next-20181206]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Aneesh-Kumar-K-V/NestMMU-pte-upgrade-workaround-for-mprotect/20181207-040417
> config: x86_64-allmodconfig (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
>
> All errors (new ones prefixed by >>):
>
>    In file included from arch/x86/include/asm/msr.h:246:0,
>                     from arch/x86/include/asm/processor.h:21,
>                     from arch/x86/include/asm/cpufeature.h:8,
>                     from arch/x86/include/asm/thread_info.h:53,
>                     from include/linux/thread_info.h:38,
>                     from arch/x86/include/asm/preempt.h:7,
>                     from include/linux/preempt.h:81,
>                     from include/linux/spinlock.h:51,
>                     from include/linux/mmzone.h:8,
>                     from include/linux/gfp.h:6,
>                     from include/linux/slab.h:15,
>                     from include/linux/crypto.h:24,
>                     from arch/x86/kernel/asm-offsets.c:9:
>    arch/x86/include/asm/paravirt.h: In function 'ptep_modify_prot_start':
>>> arch/x86/include/asm/paravirt.h:424:28: error: dereferencing pointer to incomplete type 'struct vm_area_struct'
>      struct mm_struct *mm = vma->vm_mm;
>                                ^~
>    make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
>

The fix turned out to be more code changes than what I expected. Instead
of adding mm_types.h to paravirt.h, I changed most of the related
functions to take vm_area_struct. That brings all ptep_modify_prot_start
variants to take vm_area_struct as arg and IMHO that is better. What do
you think?

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 0d75a4f60500..28152236a65b 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -421,9 +421,8 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned
 					   pte_t *ptep)
 {
 	pteval_t ret;
-	struct mm_struct *mm = vma->vm_mm;
 
-	ret = PVOP_CALL3(pteval_t, mmu.ptep_modify_prot_start, mm, addr, ptep);
+	ret = PVOP_CALL3(pteval_t, mmu.ptep_modify_prot_start, vma, addr, ptep);
 
 	return (pte_t) { .pte = ret };
 }
@@ -431,14 +430,13 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned
 static inline void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
 					   pte_t *ptep, pte_t old_pte, pte_t pte)
 {
-	struct mm_struct *mm = vma->vm_mm;
 
 	if (sizeof(pteval_t) > sizeof(long))
 		/* 5 arg words */
-		pv_ops.mmu.ptep_modify_prot_commit(mm, addr, ptep, pte);
+		pv_ops.mmu.ptep_modify_prot_commit(vma, addr, ptep, pte);
 	else
 		PVOP_VCALL4(mmu.ptep_modify_prot_commit,
-			    mm, addr, ptep, pte.pte);
+			    vma, addr, ptep, pte.pte);
 }
 
 static inline void set_pte(pte_t *ptep, pte_t pte)
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 26942ad63830..609a728ec809 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -55,6 +55,7 @@ struct task_struct;
 struct cpumask;
 struct flush_tlb_info;
 struct mmu_gather;
+struct vm_area_struct;
 
 /*
  * Wrapper type for pointers to code which uses the non-standard
@@ -254,9 +255,9 @@ struct pv_mmu_ops {
 			   pte_t *ptep, pte_t pteval);
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
 
-	pte_t (*ptep_modify_prot_start)(struct mm_struct *mm, unsigned long addr,
+	pte_t (*ptep_modify_prot_start)(struct vm_area_struct *vma, unsigned long addr,
 					pte_t *ptep);
-	void (*ptep_modify_prot_commit)(struct mm_struct *mm, unsigned long addr,
+	void (*ptep_modify_prot_commit)(struct vm_area_struct *vma, unsigned long addr,
 					pte_t *ptep, pte_t pte);
 
 	struct paravirt_callee_save pte_val;
diff --git a/arch/x86/xen/mmu.h b/arch/x86/xen/mmu.h
index a7e47cf7ec6c..6e4c6bd62203 100644
--- a/arch/x86/xen/mmu.h
+++ b/arch/x86/xen/mmu.h
@@ -17,8 +17,8 @@ bool __set_phys_to_machine(unsigned long pfn, unsigned long mfn);
 
 void set_pte_mfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
 
-pte_t xen_ptep_modify_prot_start(struct mm_struct *mm, unsigned long addr, pte_t *ptep);
-void  xen_ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
+pte_t xen_ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep);
+void  xen_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
 				  pte_t *ptep, pte_t pte);
 
 unsigned long xen_read_cr2_direct(void);
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index a5d7ed125337..b7c89619cfc9 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -306,20 +306,20 @@ static void xen_set_pte_at(struct mm_struct *mm, unsigned long addr,
 	__xen_set_pte(ptep, pteval);
 }
 
-pte_t xen_ptep_modify_prot_start(struct mm_struct *mm,
+pte_t xen_ptep_modify_prot_start(struct vm_area_struct *vma,
 				 unsigned long addr, pte_t *ptep)
 {
 	/* Just return the pte as-is.  We preserve the bits on commit */
-	trace_xen_mmu_ptep_modify_prot_start(mm, addr, ptep, *ptep);
+	trace_xen_mmu_ptep_modify_prot_start(vma->vm_mm, addr, ptep, *ptep);
 	return *ptep;
 }
 
-void xen_ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
+void xen_ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
 				 pte_t *ptep, pte_t pte)
 {
 	struct mmu_update u;
 
-	trace_xen_mmu_ptep_modify_prot_commit(mm, addr, ptep, pte);
+	trace_xen_mmu_ptep_modify_prot_commit(vma->vm_mm, addr, ptep, pte);
 	xen_mc_batch();
 
 	u.ptr = virt_to_machine(ptep).maddr | MMU_PT_UPDATE_PRESERVE_AD;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 37039e918f17..3ff8b1c3f003 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -568,7 +568,7 @@ static inline int pmd_none_or_clear_bad(pmd_t *pmd)
 	return 0;
 }
 
-static inline pte_t __ptep_modify_prot_start(struct mm_struct *mm,
+static inline pte_t __ptep_modify_prot_start(struct vm_area_struct *vma,
 					     unsigned long addr,
 					     pte_t *ptep)
 {
@@ -577,10 +577,10 @@ static inline pte_t __ptep_modify_prot_start(struct mm_struct *mm,
 	 * non-present, preventing the hardware from asynchronously
 	 * updating it.
 	 */
-	return ptep_get_and_clear(mm, addr, ptep);
+	return ptep_get_and_clear(vma->vm_mm, addr, ptep);
 }
 
-static inline void __ptep_modify_prot_commit(struct mm_struct *mm,
+static inline void __ptep_modify_prot_commit(struct vm_area_struct *vma,
 					     unsigned long addr,
 					     pte_t *ptep, pte_t pte)
 {
@@ -588,7 +588,7 @@ static inline void __ptep_modify_prot_commit(struct mm_struct *mm,
 	 * The pte is non-present, so there's no hardware state to
 	 * preserve.
 	 */
-	set_pte_at(mm, addr, ptep, pte);
+	set_pte_at(vma->vm_mm, addr, ptep, pte);
 }
 
 #ifndef __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
@@ -610,7 +610,7 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma,
 					   unsigned long addr,
 					   pte_t *ptep)
 {
-	return __ptep_modify_prot_start(vma->vm_mm, addr, ptep);
+	return __ptep_modify_prot_start(vma, addr, ptep);
 }
 
 /*
@@ -621,7 +621,7 @@ static inline void ptep_modify_prot_commit(struct vm_area_struct *vma,
 					   unsigned long addr,
 					   pte_t *ptep, pte_t old_pte, pte_t pte)
 {
-	__ptep_modify_prot_commit(vma->vm_mm, addr, ptep, pte);
+	__ptep_modify_prot_commit(vma, addr, ptep, pte);
 }
 #endif /* __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION */
 #endif /* CONFIG_MMU */
