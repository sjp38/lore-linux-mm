Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C01646B4D71
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:35:11 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id w15so12593941edl.21
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:35:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f10si904532edb.244.2018.11.28.06.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 06:35:09 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wASEYGJ2001383
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:35:08 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p1v29jpqe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:35:07 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 28 Nov 2018 14:35:06 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2 2/5] mm: update ptep_modify_prot_commit to take old pte value as arg
Date: Wed, 28 Nov 2018 20:04:35 +0530
In-Reply-To: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
References: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181128143438.29458-3-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

Architectures like ppc64 requires to do a conditional tlb flush based on the old
and new value of pte. Enable that by passing old pte value as the arg.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/s390/include/asm/pgtable.h | 3 ++-
 arch/s390/mm/pgtable.c          | 2 +-
 arch/x86/include/asm/paravirt.h | 2 +-
 fs/proc/task_mmu.c              | 8 +++++---
 include/asm-generic/pgtable.h   | 2 +-
 mm/memory.c                     | 8 ++++----
 mm/mprotect.c                   | 6 +++---
 7 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 5d730199e37b..76dc344edb8c 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1070,7 +1070,8 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 
 #define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
 pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
-void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long, pte_t *, pte_t);
+void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
+			     pte_t *, pte_t, pte_t);
 
 #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
 static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 29c0a21cd34a..b283b92722cc 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -322,7 +322,7 @@ pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(ptep_modify_prot_start);
 
 void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
-			     pte_t *ptep, pte_t pte)
+			     pte_t *ptep, pte_t old_pte, pte_t pte)
 {
 	pgste_t pgste;
 	struct mm_struct *mm = vma->vm_mm;
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 1154f154025d..0d75a4f60500 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -429,7 +429,7 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned
 }
 
 static inline void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
-					   pte_t *ptep, pte_t pte)
+					   pte_t *ptep, pte_t old_pte, pte_t pte)
 {
 	struct mm_struct *mm = vma->vm_mm;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9952d7185170..8d62891d38a8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -940,10 +940,12 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 	pte_t ptent = *pte;
 
 	if (pte_present(ptent)) {
-		ptent = ptep_modify_prot_start(vma, addr, pte);
-		ptent = pte_wrprotect(ptent);
+		pte_t old_pte;
+
+		old_pte = ptep_modify_prot_start(vma, addr, pte);
+		ptent = pte_wrprotect(old_pte);
 		ptent = pte_clear_soft_dirty(ptent);
-		ptep_modify_prot_commit(vma, addr, pte, ptent);
+		ptep_modify_prot_commit(vma, addr, pte, old_pte, ptent);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
 		set_pte_at(vma->vm_mm, addr, pte, ptent);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index c9897dcc46c4..37039e918f17 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -619,7 +619,7 @@ static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma,
  */
 static inline void ptep_modify_prot_commit(struct vm_area_struct *vma,
 					   unsigned long addr,
-					   pte_t *ptep, pte_t pte)
+					   pte_t *ptep, pte_t old_pte, pte_t pte)
 {
 	__ptep_modify_prot_commit(vma->vm_mm, addr, ptep, pte);
 }
diff --git a/mm/memory.c b/mm/memory.c
index d36b0eaa7862..4f3ddaedc764 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3568,7 +3568,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
-	pte_t pte;
+	pte_t pte, old_pte;
 	bool was_writable = pte_savedwrite(vmf->orig_pte);
 	int flags = 0;
 
@@ -3588,12 +3588,12 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	 * Make it present again, Depending on how arch implementes non
 	 * accessible ptes, some can allow access by kernel mode.
 	 */
-	pte = ptep_modify_prot_start(vma, vmf->address, vmf->pte);
-	pte = pte_modify(pte, vma->vm_page_prot);
+	old_pte = ptep_modify_prot_start(vma, vmf->address, vmf->pte);
+	pte = pte_modify(old_pte, vma->vm_page_prot);
 	pte = pte_mkyoung(pte);
 	if (was_writable)
 		pte = pte_mkwrite(pte);
-	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, pte);
+	ptep_modify_prot_commit(vma, vmf->address, vmf->pte, old_pte, pte);
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 
 	page = vm_normal_page(vma, vmf->address, pte);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a301d4c83d3c..1b46b1b1248d 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -110,8 +110,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					continue;
 			}
 
-			ptent = ptep_modify_prot_start(vma, addr, pte);
-			ptent = pte_modify(ptent, newprot);
+			oldpte = ptep_modify_prot_start(vma, addr, pte);
+			ptent = pte_modify(oldpte, newprot);
 			if (preserve_write)
 				ptent = pte_mk_savedwrite(ptent);
 
@@ -121,7 +121,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					 !(vma->vm_flags & VM_SOFTDIRTY))) {
 				ptent = pte_mkwrite(ptent);
 			}
-			ptep_modify_prot_commit(vma, addr, pte, ptent);
+			ptep_modify_prot_commit(vma, addr, pte, oldpte, ptent);
 			pages++;
 		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
-- 
2.19.1
