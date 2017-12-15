Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52D986B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:05:21 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 14so14661860itm.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:05:21 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w199si4899004itb.32.2017.12.15.06.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:05:19 -0800 (PST)
Date: Fri, 15 Dec 2017 15:04:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171215140453.txrpiunvlncx7zqj@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 03:37:30PM +0100, Peter Zijlstra wrote:

> Kirill did point out that my patch(es) break FOLL_DUMP in that it would
> now exclude pkey protected pages from core-dumps.
> 
> My counter argument is that it will now properly exclude !_PAGE_USER
> pages.
> 
> If we change p??_access_permitted() to pass the full follow flags
> instead of just the write part we could fix that.

Something like the completely untested below would do that.

Then we'd need this on top:

--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1232,7 +1232,10 @@ __pte_access_permitted(unsigned long pte
 		need_pte_bits |= _PAGE_RW;
 
 	if ((pteval & need_pte_bits) != need_pte_bits)
-		return 0;
+		return false;
+
+	if (foll_flags & FOLL_DUMP)
+		return true;
 
 	return __pkru_allows_pkey(pte_flags_pkey(pteval), write);
 }

But it is rather ugly... :/


---

--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -11,6 +11,7 @@
 #define _ASMARM_PGTABLE_H
 
 #include <linux/const.h>
+#include <linux/foll_flags.h>
 #include <asm/proc-fns.h>
 
 #ifndef CONFIG_MMU
@@ -232,12 +233,12 @@ static inline pte_t *pmd_page_vaddr(pmd_
 #define pte_valid_user(pte)	\
 	(pte_valid(pte) && pte_isset((pte), L_PTE_USER) && pte_young(pte))
 
-static inline bool pte_access_permitted(pte_t pte, bool write)
+static inline bool pte_access_permitted(pte_t pte, unsigned int foll_flags)
 {
 	pteval_t mask = L_PTE_PRESENT | L_PTE_USER;
 	pteval_t needed = mask;
 
-	if (write)
+	if (foll_flags & FOLL_WRITE)
 		mask |= L_PTE_RDONLY;
 
 	return (pte_val(pte) & mask) == needed;
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -16,6 +16,8 @@
 #ifndef __ASM_PGTABLE_H
 #define __ASM_PGTABLE_H
 
+#include <linux/foll_flags.h>
+
 #include <asm/bug.h>
 #include <asm/proc-fns.h>
 
@@ -114,12 +116,23 @@ extern unsigned long empty_zero_page[PAG
  * write permission check) other than user execute-only which do not have the
  * PTE_USER bit set. PROT_NONE mappings do not have the PTE_VALID bit set.
  */
-#define pte_access_permitted(pte, write) \
-	(pte_valid_user(pte) && (!(write) || pte_write(pte)))
-#define pmd_access_permitted(pmd, write) \
-	(pte_access_permitted(pmd_pte(pmd), (write)))
-#define pud_access_permitted(pud, write) \
-	(pte_access_permitted(pud_pte(pud), (write)))
+static inline bool __pte_access_permitted(pte_t pte, unsigned int foll_flags)
+{
+	if (!pte_valid_user(pte))
+		return false;
+
+	if (foll_flags & FOLL_WRITE)
+		return !!pte_write(pte);
+
+	return true;
+}
+
+#define pte_access_permitted(pte, foll_flags) \
+	(__pte_access_permitted((pte), (foll_flags))
+#define pmd_access_permitted(pmd, foll_flags) \
+	(pte_access_permitted(pmd_pte(pmd), (foll_flags)))
+#define pud_access_permitted(pud, foll_flags) \
+	(pte_access_permitted(pud_pte(pud), (foll_flags)))
 
 static inline pte_t clear_pte_bit(pte_t pte, pgprot_t prot)
 {
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -75,7 +75,7 @@ static int gup_huge_pmd(pmd_t *pmdp, pmd
 	if (!(pmd_val(pmd) & _PAGE_VALID))
 		return 0;
 
-	if (!pmd_access_permitted(pmd, write))
+	if (!pmd_access_permitted(pmd, !!write * FOLL_WRITE))
 		return 0;
 
 	refs = 0;
@@ -114,7 +114,7 @@ static int gup_huge_pud(pud_t *pudp, pud
 	if (!(pud_val(pud) & _PAGE_VALID))
 		return 0;
 
-	if (!pud_access_permitted(pud, write))
+	if (!pud_access_permitted(pud, !!write * FOLL_WRITE))
 		return 0;
 
 	refs = 0;
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -2,6 +2,7 @@
 #ifndef _ASM_X86_PGTABLE_H
 #define _ASM_X86_PGTABLE_H
 
+#include <linux/foll_flags.h>
 #include <linux/mem_encrypt.h>
 #include <asm/page.h>
 #include <asm/pgtable_types.h>
@@ -1221,9 +1222,11 @@ static inline bool __pkru_allows_pkey(u1
  * _PAGE_PRESENT, _PAGE_USER, and _PAGE_RW in here which are the
  * same value on all 3 types.
  */
-static inline bool __pte_access_permitted(unsigned long pteval, bool write)
+static inline bool
+__pte_access_permitted(unsigned long pteval, unsigned int foll_flags)
 {
 	unsigned long need_pte_bits = _PAGE_PRESENT|_PAGE_USER;
+	bool write = foll_flags & FOLL_WRITE;
 
 	if (write)
 		need_pte_bits |= _PAGE_RW;
@@ -1235,21 +1238,21 @@ static inline bool __pte_access_permitte
 }
 
 #define pte_access_permitted pte_access_permitted
-static inline bool pte_access_permitted(pte_t pte, bool write)
+static inline bool pte_access_permitted(pte_t pte, bool foll_flags)
 {
-	return __pte_access_permitted(pte_val(pte), write);
+	return __pte_access_permitted(pte_val(pte), foll_flags);
 }
 
 #define pmd_access_permitted pmd_access_permitted
-static inline bool pmd_access_permitted(pmd_t pmd, bool write)
+static inline bool pmd_access_permitted(pmd_t pmd, bool foll_flags)
 {
-	return __pte_access_permitted(pmd_val(pmd), write);
+	return __pte_access_permitted(pmd_val(pmd), foll_flags);
 }
 
 #define pud_access_permitted pud_access_permitted
-static inline bool pud_access_permitted(pud_t pud, bool write)
+static inline bool pud_access_permitted(pud_t pud, bool foll_flags)
 {
-	return __pte_access_permitted(pud_val(pud), write);
+	return __pte_access_permitted(pud_val(pud), foll_flags);
 }
 
 #include <asm-generic/pgtable.h>
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -2,6 +2,7 @@
 #ifndef _ASM_GENERIC_PGTABLE_H
 #define _ASM_GENERIC_PGTABLE_H
 
+#include <linux/foll_flags.h>
 #include <linux/pfn.h>
 
 #ifndef __ASSEMBLY__
@@ -343,28 +344,28 @@ static inline int pte_unused(pte_t pte)
 #endif
 
 #ifndef pte_access_permitted
-#define pte_access_permitted(pte, write) \
-	(pte_present(pte) && (!(write) || pte_write(pte)))
+#define pte_access_permitted(pte, foll_flags) \
+	(pte_present(pte) && (!(foll_flags & FOLL_WRITE) || pte_foll_flags(pte)))
 #endif
 
 #ifndef pmd_access_permitted
-#define pmd_access_permitted(pmd, write) \
-	(pmd_present(pmd) && (!(write) || pmd_write(pmd)))
+#define pmd_access_permitted(pmd, foll_flags) \
+	(pmd_present(pmd) && (!(foll_flags & FOLL_WRITE) || pmd_foll_flags(pmd)))
 #endif
 
 #ifndef pud_access_permitted
-#define pud_access_permitted(pud, write) \
-	(pud_present(pud) && (!(write) || pud_write(pud)))
+#define pud_access_permitted(pud, foll_flags) \
+	(pud_present(pud) && (!(foll_flags & FOLL_WRITE) || pud_foll_flags(pud)))
 #endif
 
 #ifndef p4d_access_permitted
-#define p4d_access_permitted(p4d, write) \
-	(p4d_present(p4d) && (!(write) || p4d_write(p4d)))
+#define p4d_access_permitted(p4d, foll_flags) \
+	(p4d_present(p4d) && (!(foll_flags & FOLL_WRITE) || p4d_foll_flags(p4d)))
 #endif
 
 #ifndef pgd_access_permitted
-#define pgd_access_permitted(pgd, write) \
-	(pgd_present(pgd) && (!(write) || pgd_write(pgd)))
+#define pgd_access_permitted(pgd, foll_flags) \
+	(pgd_present(pgd) && (!(foll_flags & FOLL_WRITE) || pgd_foll_flags(pgd)))
 #endif
 
 #ifndef __HAVE_ARCH_PMD_SAME
--- /dev/null
+++ b/include/linux/foll_flags.h
@@ -0,0 +1,22 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_FOLL_FLAGS_H
+#define _LINUX_FOLL_FLAGS_H
+
+#define FOLL_WRITE	0x01	/* check pte is writable */
+#define FOLL_TOUCH	0x02	/* mark page accessed */
+#define FOLL_GET	0x04	/* do get_page on page */
+#define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
+#define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_NOWAIT	0x20	/* if a disk transfer is needed, start the IO
+				 * and return without waiting upon it */
+#define FOLL_POPULATE	0x40	/* fault in page */
+#define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
+#define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
+#define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
+#define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
+#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
+#define FOLL_MLOCK	0x1000	/* lock present pages */
+#define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
+#define FOLL_COW	0x4000	/* internal GUP flag */
+
+#endif /* _LINUX_FOLL_FLAGS_H */
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -6,6 +6,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/foll_flags.h>
 #include <linux/mmdebug.h>
 #include <linux/gfp.h>
 #include <linux/bug.h>
@@ -2419,23 +2420,6 @@ static inline struct page *follow_page(s
 	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
 }
 
-#define FOLL_WRITE	0x01	/* check pte is writable */
-#define FOLL_TOUCH	0x02	/* mark page accessed */
-#define FOLL_GET	0x04	/* do get_page on page */
-#define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
-#define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
-#define FOLL_NOWAIT	0x20	/* if a disk transfer is needed, start the IO
-				 * and return without waiting upon it */
-#define FOLL_POPULATE	0x40	/* fault in page */
-#define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
-#define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
-#define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
-#define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
-#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
-#define FOLL_MLOCK	0x1000	/* lock present pages */
-#define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
-#define FOLL_COW	0x4000	/* internal GUP flag */
-
 static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
 {
 	if (vm_fault & VM_FAULT_OOM)
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -153,7 +153,7 @@ static struct page *follow_page_pte(stru
 	}
 
 	if (flags & FOLL_GET) {
-		if (!pte_access_permitted(pte, !!(flags & FOLL_WRITE))) {
+		if (!pte_access_permitted(pte, flags)) {
 			page = ERR_PTR(-EFAULT);
 			goto out;
 		}
@@ -251,7 +251,7 @@ static struct page *follow_pmd_mask(stru
 	}
 
 	if (flags & FOLL_GET) {
-		if (!pmd_access_permitted(*pmd, !!(flags & FOLL_WRITE))) {
+		if (!pmd_access_permitted(*pmd, flags)) {
 			page = ERR_PTR(-EFAULT);
 			spin_unlock(ptr);
 			return page;
@@ -342,7 +342,7 @@ static struct page *follow_pud_mask(stru
 	}
 
 	if (flags & FOLL_GET) {
-		if (!pud_access_permitted(*pud, !!(flags & FOLL_WRITE))) {
+		if (!pud_access_permitted(*pud, flags)) {
 			page = ERR_PTR(-EFAULT);
 			spin_unlock(ptr);
 			return page;
@@ -1407,7 +1407,7 @@ static int gup_pte_range(pmd_t pmd, unsi
 		if (pte_protnone(pte))
 			goto pte_unmap;
 
-		if (!pte_access_permitted(pte, write))
+		if (!pte_access_permitted(pte, !!write * FOLL_WRITE))
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
@@ -1528,7 +1528,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_
 	struct page *head, *page;
 	int refs;
 
-	if (!pmd_access_permitted(orig, write))
+	if (!pmd_access_permitted(orig, !!write * FOLL_WRITE))
 		return 0;
 
 	if (pmd_devmap(orig))
@@ -1566,7 +1566,7 @@ static int gup_huge_pud(pud_t orig, pud_
 	struct page *head, *page;
 	int refs;
 
-	if (!pud_access_permitted(orig, write))
+	if (!pud_access_permitted(orig, !!write * FOLL_WRITE))
 		return 0;
 
 	if (pud_devmap(orig))
@@ -1605,7 +1605,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_
 	int refs;
 	struct page *head, *page;
 
-	if (!pgd_access_permitted(orig, write))
+	if (!pgd_access_permitted(orig, !!write * FOLL_WRITE))
 		return 0;
 
 	BUILD_BUG_ON(pgd_devmap(orig));
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -391,11 +391,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (pmd_protnone(pmd))
 			return hmm_vma_walk_clear(start, end, walk);
 
-		if (!pmd_access_permitted(pmd, write_fault))
+		if (!pmd_access_permitted(pmd, !!write_fault * FOLL_WRITE))
 			return hmm_vma_walk_clear(start, end, walk);
 
 		pfn = pmd_pfn(pmd) + pte_index(addr);
-		flag |= pmd_access_permitted(pmd, WRITE) ? HMM_PFN_WRITE : 0;
+		flag |= pmd_access_permitted(pmd, FOLL_WRITE) ? HMM_PFN_WRITE : 0;
 		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
 			pfns[i] = hmm_pfn_t_from_pfn(pfn) | flag;
 		return 0;
@@ -456,11 +456,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			continue;
 		}
 
-		if (!pte_access_permitted(pte, write_fault))
+		if (!pte_access_permitted(pte, !!write_fault * FOLL_WRITE))
 			goto fault;
 
 		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
-		pfns[i] |= pte_access_permitted(pte, WRITE) ? HMM_PFN_WRITE : 0;
+		pfns[i] |= pte_access_permitted(pte, FOLL_WRITE) ? HMM_PFN_WRITE : 0;
 		continue;
 
 fault:
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4336,7 +4336,7 @@ int follow_phys(struct vm_area_struct *v
 		goto out;
 	pte = *ptep;
 
-	if (!pte_access_permitted(pte, flags & FOLL_WRITE))
+	if (!pte_access_permitted(pte, flags))
 		goto unlock;
 
 	*prot = pgprot_val(pte_pgprot(pte));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
