Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 545D98D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 07:07:08 -0500 (EST)
Subject: Re: [PATCH 00/25] mm: Preemptibility -v7
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110125173111.720927511@chello.nl>
References: <20110125173111.720927511@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 17 Feb 2011 13:06:39 +0100
Message-ID: <1297944399.2413.1672.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Tue, 2011-01-25 at 18:31 +0100, Peter Zijlstra wrote:
>  - figure out what to do with sparc's tlb_batch lack of ->fullmm

David, how does this look?

---
Index: linux-2.6/arch/sparc/mm/tlb.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/mm/tlb.c
+++ linux-2.6/arch/sparc/mm/tlb.c
@@ -43,7 +43,8 @@ void flush_tlb_pending(void)
 	put_cpu_var(tlb_batch);
 }
=20
-void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t *ptep,=
 pte_t orig)
+void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,=20
+		   pte_t *ptep, pte_t orig, int fullmm)
 {
 	struct tlb_batch *tb =3D &get_cpu_var(tlb_batch);
 	unsigned long nr;
@@ -77,12 +78,10 @@ void tlb_batch_add(struct mm_struct *mm,
=20
 no_cache_flush:
=20
-	/*
-	if (tb->fullmm) {
+	if (fullmm) {
 		put_cpu_var(tlb_batch);
 		return;
 	}
-	*/
=20
 	nr =3D tb->tlb_nr;
=20
Index: linux-2.6/arch/sparc/include/asm/pgtable_64.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/include/asm/pgtable_64.h
+++ linux-2.6/arch/sparc/include/asm/pgtable_64.h
@@ -655,9 +655,11 @@ static inline int pte_special(pte_t pte)
 #define pte_unmap(pte)			do { } while (0)
=20
 /* Actual page table PTE updates.  */
-extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr, pte_t=
 *ptep, pte_t orig);
+extern void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,=20
+			  pte_t *ptep, pte_t orig, int fullmm);
=20
-static inline void set_pte_at(struct mm_struct *mm, unsigned long addr, pt=
e_t *ptep, pte_t pte)
+static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,=
=20
+			     pte_t *ptep, pte_t pte, int fullmm)
 {
 	pte_t orig =3D *ptep;
=20
@@ -670,12 +672,19 @@ static inline void set_pte_at(struct mm_
 	 *             and SUN4V pte layout, so this inline test is fine.
 	 */
 	if (likely(mm !=3D &init_mm) && (pte_val(orig) & _PAGE_VALID))
-		tlb_batch_add(mm, addr, ptep, orig);
+		tlb_batch_add(mm, addr, ptep, orig, fullmm);
 }
=20
+#define set_pte_at(mm,addr,ptep,pte)	\
+	__set_pte_at((mm), (addr), (ptep), (pte), 0)
+
 #define pte_clear(mm,addr,ptep)		\
 	set_pte_at((mm), (addr), (ptep), __pte(0UL))
=20
+#define __HAVE_ARCH_PTE_CLEAR_NOT_PRESENT_FULL
+#define pte_clear_not_present_full(mm,addr,ptep,fullmm)	\
+	__set_pte_at((mm), (addr), (ptep), __pte(0UL), (fullmm))
+
 #ifdef DCACHE_ALIASING_POSSIBLE
 #define __HAVE_ARCH_MOVE_PTE
 #define move_pte(pte, prot, old_addr, new_addr)				\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
