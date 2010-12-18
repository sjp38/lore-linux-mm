Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DABCC6B009A
	for <linux-mm@kvack.org>; Sat, 18 Dec 2010 03:17:10 -0500 (EST)
Date: Sat, 18 Dec 2010 09:17:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mmotm 2010-12-16-14-56 uploaded (hugetlb)
Message-ID: <20101218081707.GX1671@random.random>
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
 <20101217143316.fa36be7d.randy.dunlap@oracle.com>
 <20101217145334.3d67d80b.akpm@linux-foundation.org>
 <20101217233740.GR1671@random.random>
 <4D0C0043.7090408@oracle.com>
 <20101217165834.447cc096.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101217165834.447cc096.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi everyone,

On Fri, Dec 17, 2010 at 04:58:34PM -0800, Andrew Morton wrote:
> The first one millionth:
> 
> include/asm-generic/pgtable.h: In function 'ptep_get_and_clear':
> include/asm-generic/pgtable.h:77: error: expected statement before ')' token
> include/asm-generic/pgtable.h:94: error: invalid storage class for function 'pmdp_get_and_clear'
> 
> Due to thp-add-pmd-mangling-generic-functions.patch

Here two fixes for the um build.

This is thp-add-pmd-mangling-generic-functions-fix.patch. I hope I'm
not asking for more build troubles down the road insisting on inline
and returning (pmd_t) { 0 } instead of converting it back to a
preprocessor macro.

========
Subject: thp: fix pgtable.h build for um

From: Andrea Arcangeli <aarcange@redhat.com>

make ARCH=um failed because of some typo error in newly written code to cleanup
asm-generic/pgtable.h but that was never compiled in on x86/x64 without um.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -74,7 +74,7 @@ static inline pte_t ptep_get_and_clear(s
 	pte_t pte = *ptep;
 	pte_clear(mm, address, ptep);
 	return pte;
-)
+}
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_GET_AND_CLEAR
@@ -93,7 +93,7 @@ static inline pmd_t pmdp_get_and_clear(s
 				       pmd_t *pmdp)
 {
 	BUG();
-	return 0;
+	return (pmd_t){ 0 };
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -29,7 +29,7 @@ int ptep_set_access_flags(struct vm_area
 		flush_tlb_page(vma, address);
 	}
 	return changed;
-})
+}
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS



This one is thp-pte-alloc-trans-splitting-fix.patch

======
Subject: thp: fix pte_alloc_map

From: Andrea Arcangeli <aarcange@redhat.com>

vma can be NULL safely for archs not implementing THP.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
--- a/arch/arm/mm/pgd.c
+++ b/arch/arm/mm/pgd.c
@@ -52,7 +52,7 @@ pgd_t *get_pgd_slow(struct mm_struct *mm
 		if (!new_pmd)
 			goto no_pmd;
 
-		new_pte = pte_alloc_map(mm, new_pmd, 0);
+		new_pte = pte_alloc_map(mm, NULL, new_pmd, 0);
 		if (!new_pte)
 			goto no_pte;
 
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -38,7 +38,7 @@ huge_pte_alloc(struct mm_struct *mm, uns
 	if (pud) {
 		pmd = pmd_alloc(mm, pud, taddr);
 		if (pmd)
-			pte = pte_alloc_map(mm, pmd, taddr);
+			pte = pte_alloc_map(mm, NULL, pmd, taddr);
 	}
 	return pte;
 }
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -35,7 +35,7 @@ pte_t *huge_pte_alloc(struct mm_struct *
 		if (pud) {
 			pmd = pmd_alloc(mm, pud, addr);
 			if (pmd)
-				pte = pte_alloc_map(mm, pmd, addr);
+				pte = pte_alloc_map(mm, NULL, pmd, addr);
 		}
 	}
 
diff --git a/arch/sparc/mm/generic_32.c b/arch/sparc/mm/generic_32.c
--- a/arch/sparc/mm/generic_32.c
+++ b/arch/sparc/mm/generic_32.c
@@ -50,7 +50,7 @@ static inline int io_remap_pmd_range(str
 		end = PGDIR_SIZE;
 	offset -= address;
 	do {
-		pte_t * pte = pte_alloc_map(mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, NULL, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		io_remap_pte_range(mm, pte, address, end - address, address + offset, prot, space);
diff --git a/arch/sparc/mm/generic_64.c b/arch/sparc/mm/generic_64.c
--- a/arch/sparc/mm/generic_64.c
+++ b/arch/sparc/mm/generic_64.c
@@ -92,7 +92,7 @@ static inline int io_remap_pmd_range(str
 		end = PGDIR_SIZE;
 	offset -= address;
 	do {
-		pte_t * pte = pte_alloc_map(mm, pmd, address);
+		pte_t * pte = pte_alloc_map(mm, NULL, pmd, address);
 		if (!pte)
 			return -ENOMEM;
 		io_remap_pte_range(mm, pte, address, end - address, address + offset, prot, space);
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -214,7 +214,7 @@ pte_t *huge_pte_alloc(struct mm_struct *
 	if (pud) {
 		pmd = pmd_alloc(mm, pud, addr);
 		if (pmd)
-			pte = pte_alloc_map(mm, pmd, addr);
+			pte = pte_alloc_map(mm, NULL, pmd, addr);
 	}
 	return pte;
 }
diff --git a/arch/um/kernel/skas/mmu.c b/arch/um/kernel/skas/mmu.c
--- a/arch/um/kernel/skas/mmu.c
+++ b/arch/um/kernel/skas/mmu.c
@@ -31,7 +31,7 @@ static int init_stub_pte(struct mm_struc
 	if (!pmd)
 		goto out_pmd;
 
-	pte = pte_alloc_map(mm, pmd, proc);
+	pte = pte_alloc_map(mm, NULL, pmd, proc);
 	if (!pte)
 		goto out_pte;
 


Let me know if there are further build troubles, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
