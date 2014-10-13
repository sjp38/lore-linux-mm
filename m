Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8E86B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 13:04:49 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id a13so11250739igq.1
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 10:04:49 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id 23si9743612iop.94.2014.10.13.10.04.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Oct 2014 10:04:48 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 13 Oct 2014 22:34:45 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B975F125805A
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 22:35:34 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9DH51Cu46399524
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 22:35:02 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9DH4d8R000752
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 22:34:40 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
In-Reply-To: <20141013114428.GA28113@linaro.org>
References: <1411740233-28038-2-git-send-email-steve.capper@linaro.org> <20141002121902.GA2342@redhat.com> <87d29w1rf7.fsf@linux.vnet.ibm.com> <20141013.012146.992477977260812742.davem@davemloft.net> <20141013114428.GA28113@linaro.org>
Date: Mon, 13 Oct 2014 22:34:38 +0530
Message-ID: <877g03295l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>, David Miller <davem@davemloft.net>
Cc: aarcange@redhat.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

Steve Capper <steve.capper@linaro.org> writes:

> On Mon, Oct 13, 2014 at 01:21:46AM -0400, David Miller wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> Date: Mon, 13 Oct 2014 10:45:24 +0530
>> 
>> > Andrea Arcangeli <aarcange@redhat.com> writes:
>> > 
>> >> Hi Steve,
>> >>
>> >> On Fri, Sep 26, 2014 at 03:03:48PM +0100, Steve Capper wrote:
>> >>> This patch provides a general RCU implementation of get_user_pages_fast
>> >>> that can be used by architectures that perform hardware broadcast of
>> >>> TLB invalidations.
>> >>> 
>> >>> It is based heavily on the PowerPC implementation by Nick Piggin.
>> >>
>> >> It'd be nice if you could also at the same time apply it to sparc and
>> >> powerpc in this same patchset to show the effectiveness of having a
>> >> generic version. Because if it's not a trivial drop-in replacement,
>> >> then this should go in arch/arm* instead of mm/gup.c...
>> > 
>> > on ppc64 we have one challenge, we do need to support hugepd. At the pmd
>> > level we can have hugepte, normal pmd pointer or a pointer to hugepage
>> > directory which is used in case of some sub-architectures/platforms. ie,
>> > the below part of gup implementation in ppc64
>> > 
>> > else if (is_hugepd(pmdp)) {
>> > 	if (!gup_hugepd((hugepd_t *)pmdp, PMD_SHIFT,
>> > 			addr, next, write, pages, nr))
>> > 		return 0;
>> 
>> Sparc has to deal with the same issue.
>
> Hi Aneesh, David,
>
> Could we add some helpers to mm/gup.c to deal with the hugepage
> directory cases? If my understanding is correct, this arises for
> HugeTLB pages rather than THP? (I should have listed under the
> assumptions made that HugeTLB and THP have the same page table
> entries).

This is a straight lift of what we have in ppc64 on top of your patch. I
did respective hack on ppc64 side and did a simple boot test. Let me
know whether this works for arm too. It needs further cleanup to get
some typecasting fixed up.


diff --git a/mm/Kconfig b/mm/Kconfig
index 886db2158538..0ceb8a567dab 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	boolean
 
+config HAVE_GENERIC_RCU_GUP
+	boolean
+
 config ARCH_DISCARD_MEMBLOCK
 	boolean
 
diff --git a/mm/gup.c b/mm/gup.c
index 91d044b1600d..f9d2803f0c62 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -10,6 +10,10 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 
+#include <linux/sched.h>
+#include <linux/rwsem.h>
+#include <asm/pgtable.h>
+
 #include "internal.h"
 
 static struct page *no_page_table(struct vm_area_struct *vma,
@@ -672,3 +676,379 @@ struct page *get_dump_page(unsigned long addr)
 	return page;
 }
 #endif /* CONFIG_ELF_CORE */
+
+/**
+ * Generic RCU Fast GUP
+ *
+ * get_user_pages_fast attempts to pin user pages by walking the page
+ * tables directly and avoids taking locks. Thus the walker needs to be
+ * protected from page table pages being freed from under it, and should
+ * block any THP splits.
+ *
+ * One way to achieve this is to have the walker disable interrupts, and
+ * rely on IPIs from the TLB flushing code blocking before the page table
+ * pages are freed. This is unsuitable for architectures that do not need
+ * to broadcast an IPI when invalidating TLBs.
+ *
+ * Another way to achieve this is to batch up page table containing pages
+ * belonging to more than one mm_user, then rcu_sched a callback to free those
+ * pages. Disabling interrupts will allow the fast_gup walker to both block
+ * the rcu_sched callback, and an IPI that we broadcast for splitting THPs
+ * (which is a relatively rare event). The code below adopts this strategy.
+ *
+ * Before activating this code, please be aware that the following assumptions
+ * are currently made:
+ *
+ *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
+ *      pages containing page tables.
+ *
+ *  *) THP splits will broadcast an IPI, this can be achieved by overriding
+ *      pmdp_splitting_flush.
+ *
+ *  *) ptes can be read atomically by the architecture.
+ *
+ *  *) access_ok is sufficient to validate userspace address ranges.
+ *
+ * The last two assumptions can be relaxed by the addition of helper functions.
+ *
+ * This code is based heavily on the PowerPC implementation by Nick Piggin.
+ */
+#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
+
+#ifdef __HAVE_ARCH_PTE_SPECIAL
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	pte_t *ptep, *ptem;
+	int ret = 0;
+
+	ptem = ptep = pte_offset_map(&pmd, addr);
+	do {
+		/*
+		 * In the line below we are assuming that the pte can be read
+		 * atomically. If this is not the case for your architecture,
+		 * please wrap this in a helper function!
+		 *
+		 * for an example see gup_get_pte in arch/x86/mm/gup.c
+		 */
+		pte_t pte = ACCESS_ONCE(*ptep);
+		struct page *page;
+
+		/*
+		 * Similar to the PMD case below, NUMA hinting must take slow
+		 * path
+		 */
+		if (!pte_present(pte) || pte_special(pte) ||
+			pte_numa(pte) || (write && !pte_write(pte)))
+			goto pte_unmap;
+
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+
+		if (!page_cache_get_speculative(page))
+			goto pte_unmap;
+
+		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+			put_page(page);
+			goto pte_unmap;
+		}
+
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+
+	ret = 1;
+
+pte_unmap:
+	pte_unmap(ptem);
+	return ret;
+}
+#else
+
+/*
+ * If we can't determine whether or not a pte is special, then fail immediately
+ * for ptes. Note, we can still pin HugeTLB and THP as these are guaranteed not
+ * to be special.
+ *
+ * For a futex to be placed on a THP tail page, get_futex_key requires a
+ * __get_user_pages_fast implementation that can pin pages. Thus it's still
+ * useful to have gup_huge_pmd even if we can't operate on ptes.
+ */
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif /* __HAVE_ARCH_PTE_SPECIAL */
+
+int gup_huge_pte(pte_t orig, pte_t *ptep, unsigned long addr,
+		 unsigned long sz, unsigned long end, int write,
+		 struct page **pages, int *nr)
+{
+	int refs;
+	unsigned long pte_end;
+	struct page *head, *page, *tail;
+
+
+	if (write && !pte_write(orig))
+		return 0;
+
+	if (!pte_present(orig))
+		return 0;
+
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
+
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(orig)));
+
+	refs = 0;
+	head = pte_page(orig);
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pte_val(orig) != pte_val(*ptep))) {
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	/*
+	 * Any tail pages need their mapcount reference taken before we
+	 * return. (This allows the THP code to bump their ref count when
+	 * they are split into base pages).
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
+	}
+
+	return 1;
+}
+
+#ifndef is_hugepd
+typedef struct { signed long pd; } hugepd_t;
+
+/*
+ * Some architectures support hugepage directory format that is
+ * required to support different hugetlbfs sizes.
+ */
+#define is_hugepd(hugepd) (0)
+
+static inline hugepd_t pmd_hugepd(pmd_t pmd)
+{
+	return  (hugepd_t){ pmd_val(pmd) };
+}
+
+static inline hugepd_t pud_hugepd(pud_t pud)
+{
+	return  (hugepd_t){ pud_val(pud) };
+}
+
+static inline hugepd_t pgd_hugepd(pgd_t pgd)
+{
+	return  (hugepd_t){ pgd_val(pgd) };
+}
+
+static inline int gup_hugepd(hugepd_t hugepd, unsigned long addr,
+			     unsigned pdshift, unsigned long end,
+			     int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = pmd_offset(&pud, addr);
+	do {
+		pmd_t pmd = ACCESS_ONCE(*pmdp);
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			return 0;
+
+		if (pmd_trans_huge(pmd) || pmd_huge(pmd)) {
+			/*
+			 * NUMA hinting faults need to be handled in the GUP
+			 * slowpath for accounting purposes and so that they
+			 * can be serialised against THP migration.
+			 */
+			if (pmd_numa(pmd))
+				return 0;
+
+			if (!gup_huge_pte(pmd_pte(pmd), pmdp_ptep(pmdp), addr,
+					  PMD_SIZE, next, write, pages, nr))
+				return 0;
+
+		} else if (is_hugepd(pmd_hugepd(pmd))) {
+			/*
+			 * architecture have different format for hugetlbfs
+			 * pmd format and THP pmd format
+			 */
+			if (!gup_hugepd(pmd_hugepd(pmd), addr, PMD_SHIFT, next,
+					write, pages, nr))
+				return 0;
+		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = pud_offset(&pgd, addr);
+	do {
+		pud_t pud = ACCESS_ONCE(*pudp);
+
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (pud_huge(pud)) {
+			if (!gup_huge_pte(__pte(pud_val(pud)), (pte_t *)pudp,
+					  addr, PUD_SIZE, next, write,
+					  pages, nr))
+				return 0;
+		} else if (is_hugepd(pud_hugepd(pud))) {
+			if (!gup_hugepd((pud_hugepd(pud)), addr, PUD_SHIFT,
+					 next, write, pages, nr))
+				return 0;
+		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+/*
+ * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
+ * back to the regular GUP. It will only return non-negative values.
+ */
+int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			  struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long addr, len, end;
+	unsigned long next, flags;
+	pgd_t *pgdp;
+	int nr = 0;
+
+	start &= PAGE_MASK;
+	addr = start;
+	len = (unsigned long) nr_pages << PAGE_SHIFT;
+	end = start + len;
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					start, len)))
+		return 0;
+
+	/*
+	 * Disable interrupts, we use the nested form as we can already
+	 * have interrupts disabled by get_futex_key.
+	 *
+	 * With interrupts disabled, we block page table pages from being
+	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
+	 * for more details.
+	 *
+	 * We do not adopt an rcu_read_lock(.) here as we also want to
+	 * block IPIs that come from THPs splitting.
+	 */
+
+	local_irq_save(flags);
+	pgdp = pgd_offset(mm, addr);
+	do {
+		pgd_t pgd = ACCESS_ONCE(*pgdp);
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(pgd))
+			break;
+		if (pgd_huge(pgd)) {
+			if (!gup_huge_pte(pgd, (pte_t *)pgdp, addr, PGDIR_SIZE,
+					 next, write, pages, &nr))
+				break;
+		} else if (is_hugepd(pgd_hugepd(pgd))) {
+			if (!gup_hugepd((pgd_hugepd(pgd)), addr, PGDIR_SHIFT,
+					 next, write, pages, &nr))
+				break;
+		} else if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+			break;
+	} while (pgdp++, addr = next, addr != end);
+	local_irq_restore(flags);
+
+	return nr;
+}
+
+/**
+ * get_user_pages_fast() - pin user pages in memory
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @write:	whether pages will be written to
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long.
+ *
+ * Attempt to pin user pages in memory without taking mm->mmap_sem.
+ * If not successful, it will fall back to taking the lock and
+ * calling get_user_pages().
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno.
+ */
+int get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	int nr, ret;
+
+	start &= PAGE_MASK;
+	nr = __get_user_pages_fast(start, nr_pages, write, pages);
+	ret = nr;
+
+	if (nr < nr_pages) {
+		/* Try to get the remaining pages with get_user_pages */
+		start += nr << PAGE_SHIFT;
+		pages += nr;
+
+		down_read(&mm->mmap_sem);
+		ret = get_user_pages(current, mm, start,
+				     nr_pages - nr, write, 0, pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		/* Have to be a bit careful with return values */
+		if (nr > 0) {
+			if (ret < 0)
+				ret = nr;
+			else
+				ret += nr;
+		}
+	}
+
+	return ret;
+}
+
+#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
