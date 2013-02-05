Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id B08D26B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:12:25 -0500 (EST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Feb 2013 18:11:37 -0000
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15IC84k34799660
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 18:12:08 GMT
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15ICGNP003307
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 11:12:17 -0700
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] s390/mm: implement software dirty bits
Date: Tue,  5 Feb 2013 10:12:05 -0800
Message-Id: <1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

The s390 architecture is unique in respect to dirty page detection,
it uses the change bit in the per-page storage key to track page
modifications. All other architectures track dirty bits by means
of page table entries. This property of s390 has caused numerous
problems in the past, e.g. see git commit ef5d437f71afdf4a
"mm: fix XFS oops due to dirty pages without buffers on s390".

To avoid future issues in regard to per-page dirty bits convert
s390 to a fault based software dirty bit detection mechanism. All
user page table entries which are marked as clean will be hardware
read-only, even if the pte is supposed to be writable. A write by
the user process will trigger a protection fault which will cause
the user pte to be marked as dirty and the hardware read-only bit
is removed.

With this change the dirty bit in the storage key is irrelevant
for Linux as a host, but the storage key is still required for
KVM guests. The effect is that page_test_and_clear_dirty and the
related code can be removed. The referenced bit in the storage
key is still used by the page_test_and_clear_young primitive to
provide page age information.

For page cache pages of mappings with mapping_cap_account_dirty
there will not be any change in behavior as the dirty bit tracking
already uses read-only ptes to control the amount of dirty pages.
Only for swap cache pages and pages of mappings without
mapping_cap_account_dirty there can be additional protection faults.
To avoid an excessive number of additional faults the mk_pte
primitive checks for PageDirty if the pgprot value allows for writes
and pre-dirties the pte. That avoids all additional faults for
tmpfs and shmem pages until these pages are added to the swap cache.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/page.h    |   22 -------
 arch/s390/include/asm/pgtable.h |  131 ++++++++++++++++++++++++++-------------
 arch/s390/include/asm/sclp.h    |    1 -
 arch/s390/include/asm/setup.h   |   16 ++---
 arch/s390/kvm/kvm-s390.c        |    2 +-
 arch/s390/lib/uaccess_pt.c      |    2 +-
 arch/s390/mm/pageattr.c         |    2 +-
 arch/s390/mm/vmem.c             |   24 +++----
 drivers/s390/char/sclp_cmd.c    |   10 +--
 include/asm-generic/pgtable.h   |   10 ---
 include/linux/page-flags.h      |    8 ---
 mm/rmap.c                       |   24 -------
 12 files changed, 112 insertions(+), 140 deletions(-)

diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index a86ad40840..75ce9b0 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -155,28 +155,6 @@ static inline int page_reset_referenced(unsigned long addr)
 #define _PAGE_ACC_BITS		0xf0	/* HW access control bits	*/
 
 /*
- * Test and clear dirty bit in storage key.
- * We can't clear the changed bit atomically. This is a potential
- * race against modification of the referenced bit. This function
- * should therefore only be called if it is not mapped in any
- * address space.
- *
- * Note that the bit gets set whenever page content is changed. That means
- * also when the page is modified by DMA or from inside the kernel.
- */
-#define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
-static inline int page_test_and_clear_dirty(unsigned long pfn, int mapped)
-{
-	unsigned char skey;
-
-	skey = page_get_storage_key(pfn << PAGE_SHIFT);
-	if (!(skey & _PAGE_CHANGED))
-		return 0;
-	page_set_storage_key(pfn << PAGE_SHIFT, skey & ~_PAGE_CHANGED, mapped);
-	return 1;
-}
-
-/*
  * Test and clear referenced bit in storage key.
  */
 #define __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 098adbb..2b3d3b6 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -29,6 +29,7 @@
 #ifndef __ASSEMBLY__
 #include <linux/sched.h>
 #include <linux/mm_types.h>
+#include <linux/page-flags.h>
 #include <asm/bug.h>
 #include <asm/page.h>
 
@@ -221,13 +222,15 @@ extern unsigned long MODULES_END;
 /* Software bits in the page table entry */
 #define _PAGE_SWT	0x001		/* SW pte type bit t */
 #define _PAGE_SWX	0x002		/* SW pte type bit x */
-#define _PAGE_SWC	0x004		/* SW pte changed bit (for KVM) */
-#define _PAGE_SWR	0x008		/* SW pte referenced bit (for KVM) */
-#define _PAGE_SPECIAL	0x010		/* SW associated with special page */
+#define _PAGE_SWC	0x004		/* SW pte changed bit */
+#define _PAGE_SWR	0x008		/* SW pte referenced bit */
+#define _PAGE_SWW	0x010		/* SW pte write bit */
+#define _PAGE_SPECIAL	0x020		/* SW associated with special page */
 #define __HAVE_ARCH_PTE_SPECIAL
 
 /* Set of bits not changed in pte_modify */
-#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_SPECIAL | _PAGE_SWC | _PAGE_SWR)
+#define _PAGE_CHG_MASK		(PAGE_MASK | _PAGE_SPECIAL | _PAGE_CO | \
+				 _PAGE_SWC | _PAGE_SWR)
 
 /* Six different types of pages. */
 #define _PAGE_TYPE_EMPTY	0x400
@@ -321,6 +324,7 @@ extern unsigned long MODULES_END;
 
 /* Bits in the region table entry */
 #define _REGION_ENTRY_ORIGIN	~0xfffUL/* region/segment table origin	    */
+#define _REGION_ENTRY_RO	0x200	/* region protection bit	    */
 #define _REGION_ENTRY_INV	0x20	/* invalid region table entry	    */
 #define _REGION_ENTRY_TYPE_MASK	0x0c	/* region/segment table type mask   */
 #define _REGION_ENTRY_TYPE_R1	0x0c	/* region first table type	    */
@@ -382,9 +386,10 @@ extern unsigned long MODULES_END;
  */
 #define PAGE_NONE	__pgprot(_PAGE_TYPE_NONE)
 #define PAGE_RO		__pgprot(_PAGE_TYPE_RO)
-#define PAGE_RW		__pgprot(_PAGE_TYPE_RW)
+#define PAGE_RW		__pgprot(_PAGE_TYPE_RO | _PAGE_SWW)
+#define PAGE_RWC	__pgprot(_PAGE_TYPE_RW | _PAGE_SWW | _PAGE_SWC)
 
-#define PAGE_KERNEL	PAGE_RW
+#define PAGE_KERNEL	PAGE_RWC
 #define PAGE_COPY	PAGE_RO
 
 /*
@@ -631,23 +636,23 @@ static inline pgste_t pgste_update_all(pte_t *ptep, pgste_t pgste)
 	bits = skey & (_PAGE_CHANGED | _PAGE_REFERENCED);
 	/* Clear page changed & referenced bit in the storage key */
 	if (bits & _PAGE_CHANGED)
-		page_set_storage_key(address, skey ^ bits, 1);
+		page_set_storage_key(address, skey ^ bits, 0);
 	else if (bits)
 		page_reset_referenced(address);
 	/* Transfer page changed & referenced bit to guest bits in pgste */
 	pgste_val(pgste) |= bits << 48;		/* RCP_GR_BIT & RCP_GC_BIT */
 	/* Get host changed & referenced bits from pgste */
 	bits |= (pgste_val(pgste) & (RCP_HR_BIT | RCP_HC_BIT)) >> 52;
-	/* Clear host bits in pgste. */
+	/* Transfer page changed & referenced bit to kvm user bits */
+	pgste_val(pgste) |= bits << 45;		/* KVM_UR_BIT & KVM_UC_BIT */
+	/* Clear relevant host bits in pgste. */
 	pgste_val(pgste) &= ~(RCP_HR_BIT | RCP_HC_BIT);
 	pgste_val(pgste) &= ~(RCP_ACC_BITS | RCP_FP_BIT);
 	/* Copy page access key and fetch protection bit to pgste */
 	pgste_val(pgste) |=
 		(unsigned long) (skey & (_PAGE_ACC_BITS | _PAGE_FP_BIT)) << 56;
-	/* Transfer changed and referenced to kvm user bits */
-	pgste_val(pgste) |= bits << 45;		/* KVM_UR_BIT & KVM_UC_BIT */
-	/* Transfer changed & referenced to pte sofware bits */
-	pte_val(*ptep) |= bits << 1;		/* _PAGE_SWR & _PAGE_SWC */
+	/* Transfer referenced bit to pte */
+	pte_val(*ptep) |= (bits & _PAGE_REFERENCED) << 1;
 #endif
 	return pgste;
 
@@ -660,20 +665,25 @@ static inline pgste_t pgste_update_young(pte_t *ptep, pgste_t pgste)
 
 	if (!pte_present(*ptep))
 		return pgste;
+	/* Get referenced bit from storage key */
 	young = page_reset_referenced(pte_val(*ptep) & PAGE_MASK);
-	/* Transfer page referenced bit to pte software bit (host view) */
-	if (young || (pgste_val(pgste) & RCP_HR_BIT))
+	if (young)
+		pgste_val(pgste) |= RCP_GR_BIT;
+	/* Get host referenced bit from pgste */
+	if (pgste_val(pgste) & RCP_HR_BIT) {
+		pgste_val(pgste) &= ~RCP_HR_BIT;
+		young = 1;
+	}
+	/* Transfer referenced bit to kvm user bits and pte */
+	if (young) {
+		pgste_val(pgste) |= KVM_UR_BIT;
 		pte_val(*ptep) |= _PAGE_SWR;
-	/* Clear host referenced bit in pgste. */
-	pgste_val(pgste) &= ~RCP_HR_BIT;
-	/* Transfer page referenced bit to guest bit in pgste */
-	pgste_val(pgste) |= (unsigned long) young << 50; /* set RCP_GR_BIT */
+	}
 #endif
 	return pgste;
-
 }
 
-static inline void pgste_set_pte(pte_t *ptep, pgste_t pgste, pte_t entry)
+static inline void pgste_set_key(pte_t *ptep, pgste_t pgste, pte_t entry)
 {
 #ifdef CONFIG_PGSTE
 	unsigned long address;
@@ -687,10 +697,23 @@ static inline void pgste_set_pte(pte_t *ptep, pgste_t pgste, pte_t entry)
 	/* Set page access key and fetch protection bit from pgste */
 	nkey |= (pgste_val(pgste) & (RCP_ACC_BITS | RCP_FP_BIT)) >> 56;
 	if (okey != nkey)
-		page_set_storage_key(address, nkey, 1);
+		page_set_storage_key(address, nkey, 0);
 #endif
 }
 
+static inline void pgste_set_pte(pte_t *ptep, pte_t entry)
+{
+	if (!MACHINE_HAS_ESOP && (pte_val(entry) & _PAGE_SWW)) {
+		/*
+		 * Without enhanced suppression-on-protection force
+		 * the dirty bit on for all writable ptes.
+		 */
+		pte_val(entry) |= _PAGE_SWC;
+		pte_val(entry) &= ~_PAGE_RO;
+	}
+	*ptep = entry;
+}
+
 /**
  * struct gmap_struct - guest address space
  * @mm: pointer to the parent mm_struct
@@ -749,11 +772,14 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 
 	if (mm_has_pgste(mm)) {
 		pgste = pgste_get_lock(ptep);
-		pgste_set_pte(ptep, pgste, entry);
-		*ptep = entry;
+		pgste_set_key(ptep, pgste, entry);
+		pgste_set_pte(ptep, entry);
 		pgste_set_unlock(ptep, pgste);
-	} else
+	} else {
+		if (!(pte_val(entry) & _PAGE_INVALID) && MACHINE_HAS_EDAT1)
+			pte_val(entry) |= _PAGE_CO;
 		*ptep = entry;
+	}
 }
 
 /*
@@ -762,16 +788,12 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
  */
 static inline int pte_write(pte_t pte)
 {
-	return (pte_val(pte) & _PAGE_RO) == 0;
+	return (pte_val(pte) & _PAGE_SWW) != 0;
 }
 
 static inline int pte_dirty(pte_t pte)
 {
-#ifdef CONFIG_PGSTE
-	if (pte_val(pte) & _PAGE_SWC)
-		return 1;
-#endif
-	return 0;
+	return (pte_val(pte) & _PAGE_SWC) != 0;
 }
 
 static inline int pte_young(pte_t pte)
@@ -821,11 +843,14 @@ static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	pte_val(pte) &= _PAGE_CHG_MASK;
 	pte_val(pte) |= pgprot_val(newprot);
+	if ((pte_val(pte) & _PAGE_SWC) && (pte_val(pte) & _PAGE_SWW))
+		pte_val(pte) &= ~_PAGE_RO;
 	return pte;
 }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
+	pte_val(pte) &= ~_PAGE_SWW;
 	/* Do not clobber _PAGE_TYPE_NONE pages!  */
 	if (!(pte_val(pte) & _PAGE_INVALID))
 		pte_val(pte) |= _PAGE_RO;
@@ -834,20 +859,26 @@ static inline pte_t pte_wrprotect(pte_t pte)
 
 static inline pte_t pte_mkwrite(pte_t pte)
 {
-	pte_val(pte) &= ~_PAGE_RO;
+	pte_val(pte) |= _PAGE_SWW;
+	if (pte_val(pte) & _PAGE_SWC)
+		pte_val(pte) &= ~_PAGE_RO;
 	return pte;
 }
 
 static inline pte_t pte_mkclean(pte_t pte)
 {
-#ifdef CONFIG_PGSTE
 	pte_val(pte) &= ~_PAGE_SWC;
-#endif
+	/* Do not clobber _PAGE_TYPE_NONE pages!  */
+	if (!(pte_val(pte) & _PAGE_INVALID))
+		pte_val(pte) |= _PAGE_RO;
 	return pte;
 }
 
 static inline pte_t pte_mkdirty(pte_t pte)
 {
+	pte_val(pte) |= _PAGE_SWC;
+	if (pte_val(pte) & _PAGE_SWW)
+		pte_val(pte) &= ~_PAGE_RO;
 	return pte;
 }
 
@@ -885,10 +916,10 @@ static inline pte_t pte_mkhuge(pte_t pte)
 		pte_val(pte) |= _SEGMENT_ENTRY_INV;
 	}
 	/*
-	 * Clear SW pte bits SWT and SWX, there are no SW bits in a segment
-	 * table entry.
+	 * Clear SW pte bits, there are no SW bits in a segment table entry.
 	 */
-	pte_val(pte) &= ~(_PAGE_SWT | _PAGE_SWX);
+	pte_val(pte) &= ~(_PAGE_SWT | _PAGE_SWX | _PAGE_SWC |
+			  _PAGE_SWR | _PAGE_SWW);
 	/*
 	 * Also set the change-override bit because we don't need dirty bit
 	 * tracking for hugetlbfs pages.
@@ -1040,9 +1071,11 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 					   unsigned long address,
 					   pte_t *ptep, pte_t pte)
 {
-	*ptep = pte;
-	if (mm_has_pgste(mm))
+	if (mm_has_pgste(mm)) {
+		pgste_set_pte(ptep, pte);
 		pgste_set_unlock(ptep, *(pgste_t *)(ptep + PTRS_PER_PTE));
+	} else
+		*ptep = pte;
 }
 
 #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
@@ -1110,10 +1143,13 @@ static inline pte_t ptep_set_wrprotect(struct mm_struct *mm,
 
 		if (!mm_exclusive(mm))
 			__ptep_ipte(address, ptep);
-		*ptep = pte_wrprotect(pte);
+		pte = pte_wrprotect(pte);
 
-		if (mm_has_pgste(mm))
+		if (mm_has_pgste(mm)) {
+			pgste_set_pte(ptep, pte);
 			pgste_set_unlock(ptep, pgste);
+		} else
+			*ptep = pte;
 	}
 	return pte;
 }
@@ -1131,10 +1167,12 @@ static inline int ptep_set_access_flags(struct vm_area_struct *vma,
 		pgste = pgste_get_lock(ptep);
 
 	__ptep_ipte(address, ptep);
-	*ptep = entry;
 
-	if (mm_has_pgste(vma->vm_mm))
+	if (mm_has_pgste(vma->vm_mm)) {
+		pgste_set_pte(ptep, entry);
 		pgste_set_unlock(ptep, pgste);
+	} else
+		*ptep = entry;
 	return 1;
 }
 
@@ -1152,8 +1190,13 @@ static inline pte_t mk_pte_phys(unsigned long physpage, pgprot_t pgprot)
 static inline pte_t mk_pte(struct page *page, pgprot_t pgprot)
 {
 	unsigned long physpage = page_to_phys(page);
+	pte_t __pte = mk_pte_phys(physpage, pgprot);
 
-	return mk_pte_phys(physpage, pgprot);
+	if ((pte_val(__pte) & _PAGE_SWW) && PageDirty(page)) {
+		pte_val(__pte) |= _PAGE_SWC;
+		pte_val(__pte) &= ~_PAGE_RO;
+	}
+	return __pte;
 }
 
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
@@ -1245,6 +1288,8 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 			      pmd_t *pmdp, pmd_t entry)
 {
+	if (!(pmd_val(entry) & _SEGMENT_ENTRY_INV) && MACHINE_HAS_EDAT1)
+		pmd_val(entry) |= _SEGMENT_ENTRY_CO;
 	*pmdp = entry;
 }
 
diff --git a/arch/s390/include/asm/sclp.h b/arch/s390/include/asm/sclp.h
index 8337886..06a1361 100644
--- a/arch/s390/include/asm/sclp.h
+++ b/arch/s390/include/asm/sclp.h
@@ -46,7 +46,6 @@ int sclp_cpu_deconfigure(u8 cpu);
 void sclp_facilities_detect(void);
 unsigned long long sclp_get_rnmax(void);
 unsigned long long sclp_get_rzm(void);
-u8 sclp_get_fac85(void);
 int sclp_sdias_blk_count(void);
 int sclp_sdias_copy(void *dest, int blk_num, int nr_blks);
 int sclp_chp_configure(struct chp_id chpid);
diff --git a/arch/s390/include/asm/setup.h b/arch/s390/include/asm/setup.h
index f69f76b..f685751 100644
--- a/arch/s390/include/asm/setup.h
+++ b/arch/s390/include/asm/setup.h
@@ -64,13 +64,14 @@ extern unsigned int s390_user_mode;
 
 #define MACHINE_FLAG_VM		(1UL << 0)
 #define MACHINE_FLAG_IEEE	(1UL << 1)
-#define MACHINE_FLAG_CSP	(1UL << 3)
-#define MACHINE_FLAG_MVPG	(1UL << 4)
-#define MACHINE_FLAG_DIAG44	(1UL << 5)
-#define MACHINE_FLAG_IDTE	(1UL << 6)
-#define MACHINE_FLAG_DIAG9C	(1UL << 7)
-#define MACHINE_FLAG_MVCOS	(1UL << 8)
-#define MACHINE_FLAG_KVM	(1UL << 9)
+#define MACHINE_FLAG_CSP	(1UL << 2)
+#define MACHINE_FLAG_MVPG	(1UL << 3)
+#define MACHINE_FLAG_DIAG44	(1UL << 4)
+#define MACHINE_FLAG_IDTE	(1UL << 5)
+#define MACHINE_FLAG_DIAG9C	(1UL << 6)
+#define MACHINE_FLAG_MVCOS	(1UL << 7)
+#define MACHINE_FLAG_KVM	(1UL << 8)
+#define MACHINE_FLAG_ESOP	(1UL << 9)
 #define MACHINE_FLAG_EDAT1	(1UL << 10)
 #define MACHINE_FLAG_EDAT2	(1UL << 11)
 #define MACHINE_FLAG_LPAR	(1UL << 12)
@@ -84,6 +85,7 @@ extern unsigned int s390_user_mode;
 #define MACHINE_IS_LPAR		(S390_lowcore.machine_flags & MACHINE_FLAG_LPAR)
 
 #define MACHINE_HAS_DIAG9C	(S390_lowcore.machine_flags & MACHINE_FLAG_DIAG9C)
+#define MACHINE_HAS_ESOP	(S390_lowcore.machine_flags & MACHINE_FLAG_ESOP)
 #define MACHINE_HAS_PFMF	MACHINE_HAS_EDAT1
 #define MACHINE_HAS_HPAGE	MACHINE_HAS_EDAT1
 
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index f090e81..2923781 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -147,7 +147,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 		r = KVM_MAX_VCPUS;
 		break;
 	case KVM_CAP_S390_COW:
-		r = sclp_get_fac85() & 0x2;
+		r = MACHINE_HAS_ESOP;
 		break;
 	default:
 		r = 0;
diff --git a/arch/s390/lib/uaccess_pt.c b/arch/s390/lib/uaccess_pt.c
index 9017a63..a70ee84 100644
--- a/arch/s390/lib/uaccess_pt.c
+++ b/arch/s390/lib/uaccess_pt.c
@@ -50,7 +50,7 @@ static __always_inline unsigned long follow_table(struct mm_struct *mm,
 	ptep = pte_offset_map(pmd, addr);
 	if (!pte_present(*ptep))
 		return -0x11UL;
-	if (write && !pte_write(*ptep))
+	if (write && (!pte_write(*ptep) || !pte_dirty(*ptep)))
 		return -0x04UL;
 
 	return (pte_val(*ptep) & PAGE_MASK) + (addr & ~PAGE_MASK);
diff --git a/arch/s390/mm/pageattr.c b/arch/s390/mm/pageattr.c
index 29ccee3..d21040e 100644
--- a/arch/s390/mm/pageattr.c
+++ b/arch/s390/mm/pageattr.c
@@ -127,7 +127,7 @@ void kernel_map_pages(struct page *page, int numpages, int enable)
 			pte_val(*pte) = _PAGE_TYPE_EMPTY;
 			continue;
 		}
-		*pte = mk_pte_phys(address, __pgprot(_PAGE_TYPE_RW));
+		pte_val(*pte) = __pa(address);
 	}
 }
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 6ed1426..79699f46 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -85,11 +85,9 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 	pud_t *pu_dir;
 	pmd_t *pm_dir;
 	pte_t *pt_dir;
-	pte_t  pte;
 	int ret = -ENOMEM;
 
 	while (address < end) {
-		pte = mk_pte_phys(address, __pgprot(ro ? _PAGE_RO : 0));
 		pg_dir = pgd_offset_k(address);
 		if (pgd_none(*pg_dir)) {
 			pu_dir = vmem_pud_alloc();
@@ -101,9 +99,9 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 #if defined(CONFIG_64BIT) && !defined(CONFIG_DEBUG_PAGEALLOC)
 		if (MACHINE_HAS_EDAT2 && pud_none(*pu_dir) && address &&
 		    !(address & ~PUD_MASK) && (address + PUD_SIZE <= end)) {
-			pte_val(pte) |= _REGION3_ENTRY_LARGE;
-			pte_val(pte) |= _REGION_ENTRY_TYPE_R3;
-			pud_val(*pu_dir) = pte_val(pte);
+			pud_val(*pu_dir) = __pa(address) |
+				_REGION_ENTRY_TYPE_R3 | _REGION3_ENTRY_LARGE |
+				(ro ? _REGION_ENTRY_RO : 0);
 			address += PUD_SIZE;
 			continue;
 		}
@@ -118,8 +116,9 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 #if defined(CONFIG_64BIT) && !defined(CONFIG_DEBUG_PAGEALLOC)
 		if (MACHINE_HAS_EDAT1 && pmd_none(*pm_dir) && address &&
 		    !(address & ~PMD_MASK) && (address + PMD_SIZE <= end)) {
-			pte_val(pte) |= _SEGMENT_ENTRY_LARGE;
-			pmd_val(*pm_dir) = pte_val(pte);
+			pmd_val(*pm_dir) = __pa(address) |
+				_SEGMENT_ENTRY | _SEGMENT_ENTRY_LARGE |
+				(ro ? _SEGMENT_ENTRY_RO : 0);
 			address += PMD_SIZE;
 			continue;
 		}
@@ -132,7 +131,7 @@ static int vmem_add_mem(unsigned long start, unsigned long size, int ro)
 		}
 
 		pt_dir = pte_offset_kernel(pm_dir, address);
-		*pt_dir = pte;
+		pte_val(*pt_dir) = __pa(address) | (ro ? _PAGE_RO : 0);
 		address += PAGE_SIZE;
 	}
 	ret = 0;
@@ -199,7 +198,6 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 	pud_t *pu_dir;
 	pmd_t *pm_dir;
 	pte_t *pt_dir;
-	pte_t  pte;
 	int ret = -ENOMEM;
 
 	start_addr = (unsigned long) start;
@@ -237,9 +235,8 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 				new_page = vmemmap_alloc_block(PMD_SIZE, node);
 				if (!new_page)
 					goto out;
-				pte = mk_pte_phys(__pa(new_page), PAGE_RW);
-				pte_val(pte) |= _SEGMENT_ENTRY_LARGE;
-				pmd_val(*pm_dir) = pte_val(pte);
+				pmd_val(*pm_dir) = __pa(new_page) |
+					_SEGMENT_ENTRY | _SEGMENT_ENTRY_LARGE;
 				address = (address + PMD_SIZE) & PMD_MASK;
 				continue;
 			}
@@ -260,8 +257,7 @@ int __meminit vmemmap_populate(struct page *start, unsigned long nr, int node)
 			new_page =__pa(vmem_alloc_pages(0));
 			if (!new_page)
 				goto out;
-			pte = pfn_pte(new_page >> PAGE_SHIFT, PAGE_KERNEL);
-			*pt_dir = pte;
+			pte_val(*pt_dir) = __pa(new_page);
 		}
 		address += PAGE_SIZE;
 	}
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index c44d13f..30a2255 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -56,7 +56,6 @@ static int __initdata early_read_info_sccb_valid;
 
 u64 sclp_facilities;
 static u8 sclp_fac84;
-static u8 sclp_fac85;
 static unsigned long long rzm;
 static unsigned long long rnmax;
 
@@ -131,7 +130,8 @@ void __init sclp_facilities_detect(void)
 	sccb = &early_read_info_sccb;
 	sclp_facilities = sccb->facilities;
 	sclp_fac84 = sccb->fac84;
-	sclp_fac85 = sccb->fac85;
+	if (sccb->fac85 & 0x02)
+		S390_lowcore.machine_flags |= MACHINE_FLAG_ESOP;
 	rnmax = sccb->rnmax ? sccb->rnmax : sccb->rnmax2;
 	rzm = sccb->rnsize ? sccb->rnsize : sccb->rnsize2;
 	rzm <<= 20;
@@ -171,12 +171,6 @@ unsigned long long sclp_get_rzm(void)
 	return rzm;
 }
 
-u8 sclp_get_fac85(void)
-{
-	return sclp_fac85;
-}
-EXPORT_SYMBOL_GPL(sclp_get_fac85);
-
 /*
  * This function will be called after sclp_facilities_detect(), which gets
  * called from early.c code. Therefore the sccb should have valid contents.
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 5cf680a..bfd8768 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -197,16 +197,6 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
-#ifndef __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
-#define page_test_and_clear_dirty(pfn, mapped)	(0)
-#endif
-
-#ifndef __HAVE_ARCH_PAGE_TEST_AND_CLEAR_DIRTY
-#define pte_maybe_dirty(pte)		pte_dirty(pte)
-#else
-#define pte_maybe_dirty(pte)		(1)
-#endif
-
 #ifndef __HAVE_ARCH_PAGE_TEST_AND_CLEAR_YOUNG
 #define page_test_and_clear_young(pfn) (0)
 #endif
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 70473da..6d53675 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -303,21 +303,13 @@ static inline void __SetPageUptodate(struct page *page)
 
 static inline void SetPageUptodate(struct page *page)
 {
-#ifdef CONFIG_S390
-	if (!test_and_set_bit(PG_uptodate, &page->flags))
-		page_set_storage_key(page_to_phys(page), PAGE_DEFAULT_KEY, 0);
-#else
 	/*
 	 * Memory barrier must be issued before setting the PG_uptodate bit,
 	 * so that all previous stores issued in order to bring the page
 	 * uptodate are actually visible before PageUptodate becomes true.
-	 *
-	 * s390 doesn't need an explicit smp_wmb here because the test and
-	 * set bit already provides full barriers.
 	 */
 	smp_wmb();
 	set_bit(PG_uptodate, &(page)->flags);
-#endif
 }
 
 CLEARPAGEFLAG(Uptodate, uptodate)
diff --git a/mm/rmap.c b/mm/rmap.c
index 2c78f8c..3d38edf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1126,7 +1126,6 @@ void page_add_file_rmap(struct page *page)
  */
 void page_remove_rmap(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
 	bool anon = PageAnon(page);
 	bool locked;
 	unsigned long flags;
@@ -1144,29 +1143,6 @@ void page_remove_rmap(struct page *page)
 		goto out;
 
 	/*
-	 * Now that the last pte has gone, s390 must transfer dirty
-	 * flag from storage key to struct page.  We can usually skip
-	 * this if the page is anon, so about to be freed; but perhaps
-	 * not if it's in swapcache - there might be another pte slot
-	 * containing the swap entry, but page not yet written to swap.
-	 *
-	 * And we can skip it on file pages, so long as the filesystem
-	 * participates in dirty tracking (note that this is not only an
-	 * optimization but also solves problems caused by dirty flag in
-	 * storage key getting set by a write from inside kernel); but need to
-	 * catch shm and tmpfs and ramfs pages which have been modified since
-	 * creation by read fault.
-	 *
-	 * Note that mapping must be decided above, before decrementing
-	 * mapcount (which luckily provides a barrier): once page is unmapped,
-	 * it could be truncated and page->mapping reset to NULL at any moment.
-	 * Note also that we are relying on page_mapping(page) to set mapping
-	 * to &swapper_space when PageSwapCache(page).
-	 */
-	if (mapping && !mapping_cap_account_dirty(mapping) &&
-	    page_test_and_clear_dirty(page_to_pfn(page), 1))
-		set_page_dirty(page);
-	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
 	 */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
