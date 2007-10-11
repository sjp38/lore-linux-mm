From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] more granular page table lock for hugepages
Date: Thu, 11 Oct 2007 21:39:51 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <b040c32a0710092310t22693865ue0b53acec85fae44@mail.gmail.com> <b040c32a0710100050x51498022m247acf34da7bc3de@mail.gmail.com>
In-Reply-To: <b040c32a0710100050x51498022m247acf34da7bc3de@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_HugDHjmVNBe/HC5"
Message-Id: <200710112139.51354.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_HugDHjmVNBe/HC5
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 10 October 2007 17:50, Ken Chen wrote:
> On 10/9/07, Ken Chen <kenchen@google.com> wrote:
> > That's what I figures.  In that case, why don't we get rid of all spin
> > lock in the fast path of follow_hugetlb_pages.
> >
> > follow_hugetlb_page is called from get_user_pages, which should
> > already hold mm->mmap_sem in read mode.  That means page table tear
> > down can not happen.  We do a racy read on page table chain.  If a
> > race happened with another thread, no big deal, it will just fall into
> > hugetlb_fault() which will then serialize with
> > hugetlb_instantiation_mutex or mm->page_table_lock.  And that's slow
> > path anyway.
>
> never mind.  ftruncate can come through in another path removes
> mapping without holding mm->mmap_sem.  So much for the crazy idea.

Yeah, that's a killer...

Here is another crazy idea I've been mulling around. I was on
the brink of forgetting the whole thing until Suresh just now
showed how much performance there is to be had.

I don't suppose the mmap_sem avoidance from this patch matters
so much if your database isn't using threads. But at least it
should be faster (unless my crazy idea has some huge hole, and
provided hugepages are implemented).

Basic idea is that architectures can override get_user_pages.
Or at least, a fast if not complete version and subsequently
fall back to regular get_user_pages if it encounters something
difficult (eg. a swapped out page).

I *think* we can do this for x86-64 without taking mmap_sem, or
_any_ page table locks at all. Obviously the CPUs themselves do
a very similar lockless lookup for TLB fill.

[ We actually might even be able to go one better if we could have
  virt->phys instructions in the CPU that would lookup and even
  fill the TLB for us. I don't know what the chances of that
  happening are, Suresh ;) ]

Attached is the really basic sketch of how it will work. Any
party poopers care tell me why I'm an idiot? :)


--Boundary-00=_HugDHjmVNBe/HC5
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="mm-get_user_pages-fast.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mm-get_user_pages-fast.patch"

Index: linux-2.6/arch/x86/lib/Makefile_64
===================================================================
--- linux-2.6.orig/arch/x86/lib/Makefile_64
+++ linux-2.6/arch/x86/lib/Makefile_64
@@ -10,4 +10,4 @@ obj-$(CONFIG_SMP)	+= msr-on-cpu.o
 lib-y := csum-partial_64.o csum-copy_64.o csum-wrappers_64.o delay_64.o \
 	usercopy_64.o getuser_64.o putuser_64.o  \
 	thunk_64.o clear_page_64.o copy_page_64.o bitstr_64.o bitops_64.o
-lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o
+lib-y += memcpy_64.o memmove_64.o memset_64.o copy_user_64.o rwlock_64.o copy_user_nocache_64.o gup.o
Index: linux-2.6/arch/x86/lib/gup.c
===================================================================
--- /dev/null
+++ linux-2.6/arch/x86/lib/gup.c
@@ -0,0 +1,99 @@
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <asm/pgtable.h>
+
+static int gup_pte_range(struct mm_struct *mm, pmd_t pmd, unsigned long addr, unsigned long end, struct page **pages, int *nr, int write)
+{
+	pte_t *ptep;
+
+	ptep = (pte_t *)pmd_page_vaddr(pmd) + pte_index(addr);
+	do {
+		pte_t pte = *ptep;
+		struct page *page;
+
+		if (pte_none(pte) || !pte_present(pte))
+			return 0;
+
+		if (write && !pte_write(pte))
+			return 0;
+
+		page = pte_page(pte);
+		get_page(page);
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+	pte_unmap(ptep);
+
+	return 1;
+}
+
+static int gup_pmd_range(struct mm_struct *mm, pud_t pud, unsigned long addr, unsigned long end, struct page **pages, int *nr, int write)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = (pmd_t *)pud_page_vaddr(pud) + pmd_index(addr);
+	do {
+		pmd_t pmd = *pmdp;
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd))
+			return 0;
+		/* if (pte_huge(pmd)) {...} */
+		if (!gup_pte_range(mm, pmd, addr, next, pages, nr, write))
+			return 0;
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static unsigned long gup_pud_range(struct mm_struct *mm, pgd_t pgd, unsigned long addr, unsigned long end, struct page **pages, int *nr, int write)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = (pud_t *)pgd_page_vaddr(pgd) + pud_index(addr);
+	do {
+		pud_t pud = *pudp;
+
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (!gup_pmd_range(mm, pud, addr, next, pages, nr, write))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+int fast_gup(unsigned long addr, unsigned long end, int flags, struct page **pages, int nr, int write)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long next;
+	pgd_t *pgdp;
+
+	/* XXX: batch / limit 'nr', to avoid huge latency */
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables from being freed on x86-64. XXX: hugepages!
+	 *
+	 * So long as we atomically load page table pointers versus teardown
+	 * (which we do on x86-64), we can follow the address down to the
+	 * the page.
+	 */
+	local_irq_disable();
+	pgdp = pgd_offset(mm, addr);
+	do {
+		pgd_t pgd = *pgdp;
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(pgd))
+			break;
+		if (!gup_pud_range(mm, pgd, addr, next, pages, &nr, write))
+			break;
+	} while (pgdp++, addr = next, addr != end);
+	local_irq_enable();
+
+	return nr;
+}

--Boundary-00=_HugDHjmVNBe/HC5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
