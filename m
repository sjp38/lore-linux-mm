Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E3BEF6B0073
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 01:58:27 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 11:24:09 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 47C501258023
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 11:29:43 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r345wJLJ7602502
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 11:28:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r345wLk5027004
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 05:58:22 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 25/25] powerpc: Handle hugepages in kvm
Date: Thu,  4 Apr 2013 11:28:03 +0530
Message-Id: <1365055083-31956-26-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We could possibly avoid some of these changes because most of the HUGE PMD bits
map to PTE bits.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/kvm_book3s_64.h |   31 ++++++++++++
 arch/powerpc/kvm/book3s_64_mmu_hv.c      |   12 ++++-
 arch/powerpc/kvm/book3s_hv_rm_mmu.c      |   75 ++++++++++++++++++++++--------
 3 files changed, 97 insertions(+), 21 deletions(-)

diff --git a/arch/powerpc/include/asm/kvm_book3s_64.h b/arch/powerpc/include/asm/kvm_book3s_64.h
index 38bec1d..1c5c799 100644
--- a/arch/powerpc/include/asm/kvm_book3s_64.h
+++ b/arch/powerpc/include/asm/kvm_book3s_64.h
@@ -110,6 +110,7 @@ static inline unsigned long compute_tlbie_rb(unsigned long v, unsigned long r,
 	return rb;
 }
 
+/* FIXME !! should we use hpte_actual_psize or hpte decode ? */
 static inline unsigned long hpte_page_size(unsigned long h, unsigned long l)
 {
 	/* only handle 4k, 64k and 16M pages for now */
@@ -189,6 +190,36 @@ static inline pte_t kvmppc_read_update_linux_pte(pte_t *p, int writing)
 	return pte;
 }
 
+/*
+ * Lock and read a linux hugepage PMD.  If it's present and writable, atomically
+ * set dirty and referenced bits and return the PMD, otherwise return 0.
+ */
+static inline pmd_t kvmppc_read_update_linux_hugepmd(pmd_t *p, int writing)
+{
+	pmd_t pmd, tmp;
+
+	/* wait until _PAGE_BUSY is clear then set it atomically */
+	__asm__ __volatile__ (
+		"1:	ldarx	%0,0,%3\n"
+		"	andi.	%1,%0,%4\n"
+		"	bne-	1b\n"
+		"	ori	%1,%0,%4\n"
+		"	stdcx.	%1,0,%3\n"
+		"	bne-	1b"
+		: "=&r" (pmd), "=&r" (tmp), "=m" (*p)
+		: "r" (p), "i" (PMD_HUGE_BUSY)
+		: "cc");
+
+	if (pmd_large(pmd)) {
+		pmd = pmd_mkyoung(pmd);
+		if (writing && pmd_write(pmd))
+			pmd = pte_mkdirty(pmd);
+	}
+
+	*p = pmd;	/* clears PMD_HUGE_BUSY */
+	return pmd;
+}
+
 /* Return HPTE cache control bits corresponding to Linux pte bits */
 static inline unsigned long hpte_cache_bits(unsigned long pte_val)
 {
diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 4f2a7dc..da006da 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -675,6 +675,7 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 		}
 		/* if the guest wants write access, see if that is OK */
 		if (!writing && hpte_is_writable(r)) {
+			int hugepage;
 			pte_t *ptep, pte;
 
 			/*
@@ -683,11 +684,18 @@ int kvmppc_book3s_hv_page_fault(struct kvm_run *run, struct kvm_vcpu *vcpu,
 			 */
 			rcu_read_lock_sched();
 			ptep = find_linux_pte_or_hugepte(current->mm->pgd,
-							 hva, NULL, NULL);
-			if (ptep && pte_present(*ptep)) {
+							 hva, NULL, &hugepage);
+			if (!hugepage && ptep && pte_present(*ptep)) {
 				pte = kvmppc_read_update_linux_pte(ptep, 1);
 				if (pte_write(pte))
 					write_ok = 1;
+			} else if (hugepage && ptep) {
+				pmd_t pmd = *(pmd_t *)ptep;
+				if (pmd_large(pmd)) {
+					pmd = kvmppc_read_update_linux_hugepmd((pmd_t *)ptep, 1);
+					if (pmd_write(pmd))
+						write_ok = 1;
+				}
 			}
 			rcu_read_unlock_sched();
 		}
diff --git a/arch/powerpc/kvm/book3s_hv_rm_mmu.c b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
index 7c8e1ed..e9d4e3a 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_mmu.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_mmu.c
@@ -146,24 +146,37 @@ static void remove_revmap_chain(struct kvm *kvm, long pte_index,
 }
 
 static pte_t lookup_linux_pte(pgd_t *pgdir, unsigned long hva,
-			      int writing, unsigned long *pte_sizep)
+			      int writing, unsigned long *pte_sizep,
+			      int *hugepage)
 {
 	pte_t *ptep;
 	unsigned long ps = *pte_sizep;
 	unsigned int shift;
 
-	ptep = find_linux_pte_or_hugepte(pgdir, hva, &shift, NULL);
+	ptep = find_linux_pte_or_hugepte(pgdir, hva, &shift, hugepage);
 	if (!ptep)
 		return __pte(0);
-	if (shift)
-		*pte_sizep = 1ul << shift;
-	else
-		*pte_sizep = PAGE_SIZE;
+	if (*hugepage) {
+		*pte_sizep = 1ul << 24;
+	} else {
+		if (shift)
+			*pte_sizep = 1ul << shift;
+		else
+			*pte_sizep = PAGE_SIZE;
+	}
 	if (ps > *pte_sizep)
 		return __pte(0);
-	if (!pte_present(*ptep))
-		return __pte(0);
-	return kvmppc_read_update_linux_pte(ptep, writing);
+
+	if (*hugepage) {
+		pmd_t *pmdp = (pmd_t *)ptep;
+		if (!pmd_large(*pmdp))
+			return __pmd(0);
+		return kvmppc_read_update_linux_hugepmd(pmdp, writing);
+	} else {
+		if (!pte_present(*ptep))
+			return __pte(0);
+		return kvmppc_read_update_linux_pte(ptep, writing);
+	}
 }
 
 static inline void unlock_hpte(unsigned long *hpte, unsigned long hpte_v)
@@ -239,18 +252,34 @@ long kvmppc_do_h_enter(struct kvm *kvm, unsigned long flags,
 		pte_size = PAGE_SIZE << (pa & KVMPPC_PAGE_ORDER_MASK);
 		pa &= PAGE_MASK;
 	} else {
+		int hugepage;
+
 		/* Translate to host virtual address */
 		hva = __gfn_to_hva_memslot(memslot, gfn);
 
 		/* Look up the Linux PTE for the backing page */
 		pte_size = psize;
-		pte = lookup_linux_pte(pgdir, hva, writing, &pte_size);
-		if (pte_present(pte)) {
-			if (writing && !pte_write(pte))
-				/* make the actual HPTE be read-only */
-				ptel = hpte_make_readonly(ptel);
-			is_io = hpte_cache_bits(pte_val(pte));
-			pa = pte_pfn(pte) << PAGE_SHIFT;
+		pte = lookup_linux_pte(pgdir, hva, writing, &pte_size, &hugepage);
+		if (hugepage) {
+			pmd_t pmd = (pmd_t)pte;
+			if (!pmd_large(pmd)) {
+				if (writing && !pmd_write(pmd))
+					/* make the actual HPTE be read-only */
+					ptel = hpte_make_readonly(ptel);
+				/*
+				 * we support hugepage only for RAM
+				 */
+				is_io = 0;
+				pa = pmd_pfn(pmd) << PAGE_SHIFT;
+			}
+		} else {
+			if (pte_present(pte)) {
+				if (writing && !pte_write(pte))
+					/* make the actual HPTE be read-only */
+					ptel = hpte_make_readonly(ptel);
+				is_io = hpte_cache_bits(pte_val(pte));
+				pa = pte_pfn(pte) << PAGE_SHIFT;
+			}
 		}
 	}
 
@@ -645,10 +674,18 @@ long kvmppc_h_protect(struct kvm_vcpu *vcpu, unsigned long flags,
 			gfn = ((r & HPTE_R_RPN) & ~(psize - 1)) >> PAGE_SHIFT;
 			memslot = __gfn_to_memslot(kvm_memslots(kvm), gfn);
 			if (memslot) {
+				int hugepage;
 				hva = __gfn_to_hva_memslot(memslot, gfn);
-				pte = lookup_linux_pte(pgdir, hva, 1, &psize);
-				if (pte_present(pte) && !pte_write(pte))
-					r = hpte_make_readonly(r);
+				pte = lookup_linux_pte(pgdir, hva, 1,
+						       &psize, &hugepage);
+				if (hugepage) {
+					pmd_t pmd = (pmd_t)pte;
+					if (pmd_large(pmd) && !pmd_write(pmd))
+						r = hpte_make_readonly(r);
+				} else {
+					if (pte_present(pte) && !pte_write(pte))
+						r = hpte_make_readonly(r);
+				}
 			}
 		}
 	}
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
