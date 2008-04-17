Subject: Re: [patch 2/2]: introduce fast_gup
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
References: <20080328025455.GA8083@wotan.suse.de>
	 <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins>
	 <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 17 Apr 2008 18:12:48 +0200
Message-Id: <1208448768.7115.30.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-04-17 at 08:25 -0700, Linus Torvalds wrote:
> 
> On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> > 
> > Would this be sufficient to address that comment's conern?
> 
> It would be nicer to just add a "native_get_pte()" to x86, to match the 
> already-existing "native_set_pte()".

See, I _knew_ I was missing something obvious :-/

> And that "barrier()" should b "smp_rmb()". They may be the same code 
> sequence, but from a conceptual angle, "smp_rmb()" makes a whole lot more 
> sense.
> 
> Finally, I don't think that comment is correct in the first place. It's 
> not that simple. The thing is, even *with* the memory barrier in place, we 
> may have:
> 
> 	CPU#1			CPU#2
> 	=====			=====
> 
> 	fast_gup:
> 	 - read low word
> 
> 				native_set_pte_present:
> 				 - set low word to 0
> 				 - set high word to new value
> 
> 	 - read high word
> 
> 				- set low word to new value
> 
> and so you read a low word that is associated with a *different* high 
> word! Notice?
> 
> So trivial memory ordering is _not_ enough.
> 
> So I think the code literally needs to be something like this
> 
> 	#ifdef CONFIG_X86_PAE
> 
> 	static inline pte_t native_get_pte(pte_t *ptep)
> 	{
> 		pte_t pte;
> 
> 	retry:
> 		pte.pte_low = ptep->pte_low;
> 		smp_rmb();
> 		pte.pte_high = ptep->pte_high;
> 		smp_rmb();
> 		if (unlikely(pte.pte_low != ptep->pte_low)
> 			goto retry;
> 		return pte;
> 	}
> 
> 	#else
> 
> 	#define native_get_pte(ptep) (*(ptep))
> 
> 	#endif
> 
> but I have admittedly not really thought it fully through.

Looks sane here; Clark can you give this a spin?

Jeremy, did I get the paravirt stuff right?

---
Index: linux-2.6/arch/x86/mm/gup.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/gup.c
+++ linux-2.6/arch/x86/mm/gup.c
@@ -36,7 +36,7 @@ static noinline int gup_pte_range(pmd_t 
 		 * function that will do this properly, so it is broken on
 		 * 32-bit 3-level for the moment.
 		 */
-		pte_t pte = *ptep;
+		pte_t pte = get_pte(ptep);
 		struct page *page;
 
 		if ((pte_val(pte) & mask) != result)
Index: linux-2.6/arch/x86/kernel/paravirt_32.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/paravirt_32.c
+++ linux-2.6/arch/x86/kernel/paravirt_32.c
@@ -450,6 +450,7 @@ struct pv_mmu_ops pv_mmu_ops = {
 #ifdef CONFIG_X86_PAE
 	.set_pte_atomic = native_set_pte_atomic,
 	.set_pte_present = native_set_pte_present,
+	.get_pte = native_get_pte,
 	.set_pud = native_set_pud,
 	.pte_clear = native_pte_clear,
 	.pmd_clear = native_pmd_clear,
Index: linux-2.6/include/asm-x86/paravirt.h
===================================================================
--- linux-2.6.orig/include/asm-x86/paravirt.h
+++ linux-2.6/include/asm-x86/paravirt.h
@@ -216,6 +216,7 @@ struct pv_mmu_ops {
 	void (*set_pte_atomic)(pte_t *ptep, pte_t pteval);
 	void (*set_pte_present)(struct mm_struct *mm, unsigned long addr,
 				pte_t *ptep, pte_t pte);
+	void (*get_pte)(struct pte_t *ptep);
 	void (*set_pud)(pud_t *pudp, pud_t pudval);
 	void (*pte_clear)(struct mm_struct *mm, unsigned long addr, pte_t *ptep);
 	void (*pmd_clear)(pmd_t *pmdp);
@@ -886,6 +887,13 @@ static inline void set_pte_present(struc
 	pv_mmu_ops.set_pte_present(mm, addr, ptep, pte);
 }
 
+static inline pte_t get_pte(struct pte_t *ptep)
+{
+	unsigned long long ret = PVOP_CALL1(unsigned long long, pv_mmu_ops.get_pte, ptep);
+
+	return (pte_t) { ret, ret >> 32 };
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmdval)
 {
 	PVOP_VCALL3(pv_mmu_ops.set_pmd, pmdp,
@@ -941,6 +949,11 @@ static inline void set_pte_at(struct mm_
 	PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pteval.pte_low);
 }
 
+static inline pte_t get_pte(struct pte_t *ptep)
+{
+	return PVOP_CALL1(unsigned long, pv_mmu_ops.get_pte, ptep);
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmdval)
 {
 	PVOP_VCALL2(pv_mmu_ops.set_pmd, pmdp, pmdval.pud.pgd.pgd);
Index: linux-2.6/include/asm-x86/pgtable-2level.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable-2level.h
+++ linux-2.6/include/asm-x86/pgtable-2level.h
@@ -20,6 +20,10 @@ static inline void native_set_pte_at(str
 {
 	native_set_pte(ptep, pte);
 }
+static inline pte_t native_get_pte(pte_t *ptep)
+{
+	return *ptep;
+}
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	*pmdp = pmd;
@@ -33,6 +37,8 @@ static inline void native_set_pmd(pmd_t 
 #define set_pte_atomic(pteptr, pteval) set_pte(pteptr,pteval)
 #define set_pte_present(mm,addr,ptep,pteval) set_pte_at(mm,addr,ptep,pteval)
 
+#define get_pte(ptep)			native_get_pte(ptep)
+
 #define pte_clear(mm,addr,xp)	do { set_pte_at(mm, addr, xp, __pte(0)); } while (0)
 #define pmd_clear(xp)	do { set_pmd(xp, __pmd(0)); } while (0)
 
Index: linux-2.6/include/asm-x86/pgtable-3level.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable-3level.h
+++ linux-2.6/include/asm-x86/pgtable-3level.h
@@ -61,6 +61,20 @@ static inline void native_set_pte_presen
 	ptep->pte_low = pte.pte_low;
 }
 
+static inline pte_t native_get_pte(pte_t *ptep)
+{
+	pte_t pte;
+
+retry:
+	pte.pte_low = ptep->pte_low;
+	smp_rmb();
+	pte.pte_high = ptep->pte_high;
+	smp_rmb();
+	if (unlikely(pte.pte_low != ptep->pte_low))
+		goto retry;
+	return pte;
+}
+
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
 	set_64bit((unsigned long long *)(ptep),native_pte_val(pte));
@@ -99,6 +113,7 @@ static inline void native_pmd_clear(pmd_
 #define set_pte_at(mm, addr, ptep, pte)		native_set_pte_at(mm, addr, ptep, pte)
 #define set_pte_present(mm, addr, ptep, pte)	native_set_pte_present(mm, addr, ptep, pte)
 #define set_pte_atomic(ptep, pte)		native_set_pte_atomic(ptep, pte)
+#define get_pte(ptep)				native_get_pte(ptep)
 #define set_pmd(pmdp, pmd)			native_set_pmd(pmdp, pmd)
 #define set_pud(pudp, pud)			native_set_pud(pudp, pud)
 #define pte_clear(mm, addr, ptep)		native_pte_clear(mm, addr, ptep)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
