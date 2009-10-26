Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C36F56B005A
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 14:51:35 -0400 (EDT)
Date: Mon, 26 Oct 2009 19:51:30 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: RFC: Transparent Hugepage support
Message-ID: <20091026185130.GC4868@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

Lately I've been working to make KVM use hugepages transparently
without the usual restrictions of hugetlbfs. Some of the restrictions
I'd like to see removed:

1) hugepages have to be swappable or the guest physical memory remains
   locked in RAM and can't be paged out to swap

2) if a hugepage allocation fails, regular pages should be allocated
   instead and mixed in the same vma without any failure and without
   userland noticing

3) if some task quits and more hugepages become available in the
   buddy, guest physical memory backed by regular pages should be
   relocated on hugepages automatically in regions under
   madvise(MADV_HUGEPAGE) (ideally event driven by waking up the
   kernel deamon if the order=HPAGE_SHIFT-PAGE_SHIFT list becomes not
   null)

The first (and more tedious) part of this work requires allowing the
VM to handle anonymous hugepages mixed with regular pages
transparently on regular anonymous vmas. This is what this patch tries
to achieve in the least intrusive possible way. We want hugepages and
hugetlb to be used in a way so that all applications can benefit
without changes (as usual we leverage the KVM virtualization design:
by improving the Linux VM at large, KVM gets the performance boost too).

The most important design choice is: always fallback to 4k allocation
if the hugepage allocation fails! This is the _very_ opposite of some
large pagecache patches that failed with -EIO back then if a 64k (or
similar) allocation failed...

Second important decision (to reduce the impact of the feature on the
existing pagetable handling code) is that at any time we can split an
hugepage into 512 regular pages and it has to be done with an
operation that can't fail. This way the reliability of the swapping
isn't decreased (no need to allocate memory when we are short on
memory to swap) and it's trivial to plug a split_huge_page* one-liner
where needed without polluting the VM. Over time we can teach
mprotect, mremap and friends to handle pmd_trans_huge natively without
calling split_huge_page*. The fact it can't fail isn't just for swap:
if split_huge_page would return -ENOMEM (instead of the current void)
we'd need to rollback the mprotect from the middle of it (ideally
including undoing the split_vma) which would be a big change and in
the very wrong direction (it'd likely be simpler not to call
split_huge_page at all and to teach mprotect and friends to handle
hugepages instead of rolling them back from the middle). In short the
very value of split_huge_page is that it can't fail.

The collapsing and madvise(MADV_HUGEPAGE) part will remain separated
and incremental and it'll just be an "harmless" addition later if this
initial part is agreed upon. It also should be noted that locking-wise
replacing regular pages with hugepages is going to be very easy if
compared to what I'm doing below in split_huge_page, as it will only
happen when page_count(page) matches page_mapcount(page) if we can
take the PG_lock and mmap_sem in write mode. collapse_huge_page will
be a "best effort" that (unlike split_huge_page) can fail at the
minimal sign of trouble and we can try again later. collapse_huge_page
will be similar to how KSM works and the madvise(MADV_HUGEPAGE) will
work similar to madvise(MADV_MERGEABLE).

For now the transparent_hugepage sysctl is for debug only (it'll be
moved to sysfs so that the kernel daemon that collapse huge pages will
be tuned from the same directory too), and we need more stats (notably
the split_huge_page* from smaps has to be removed and the amount of
hugepages in each vma should become visible in smaps too). Adam
expressed the interest to add hugepage visibility in pagemap too.

The default I like is that transparent hugepages are used at page
fault time if they're available in O(1) in the buddy. This can be
disabled via sysctl/sysfs setting the value to 0, and if it is
disabled they will only be used inside MADV_HUGEPAGE
regions. MADV_HUGEPAGE regions will do a lot more effort to shrink
caches to create hugepages during the page fault too and not only
through the collapse_huge_page kernel daemon. Then a future
sysctl/sysfs value of 2 tune can force all page faults to do a lot of
efforts to defrag cache and create hugepages whenever possible while
still leaving the collapse_huge_page daemon working strictly in
MADV_HUGEPAGE regions. Obviously KVM will call madvise(MADV_HUGEPAGE)
right after the other madvise it's already running on the guest
physical memory host virtual ranges. Ideally the daemon could run
system-wide too but I think that would tend to waste some CPU but it
remains a possibility and an heuristic would be to timestamp the vma
creation and start to call collapse_huge_page from the oldest vmas.

The pmd_trans_frozen/pmd_trans_huge locking is very solid. The
put_page (from get_user_page users that can't use mmu notifier like
O_DIRECT) that runs against a __split_huge_page_refcount instead was a
pain to serialize in a way that would result always in a coherent page
count for both tail and head. I think my locking solution with a
compound_lock taken only after the page_first is valid and is still a
PageHead should be safe but it surely needs review from SMP race point
of view. In short there is no current existing way to serialize the
O_DIRECT final put_page against split_huge_page_refcount so I had to
invent a new one (O_DIRECT loses knowledge on the mapping status by
the time gup_fast returns so...). And I didn't want to impact all
gup/gup_fast users for now, maybe if we change the gup interface
substantially we can avoid this locking, I admit I didn't think too
much about it because changing the gup unpinning interface would be
invasive.

If we ignored O_DIRECT we could stick to the existing compound
refcounting code, by simply adding a
get_user_pages_fast_flags(foll_flags) where KVM (and any other mmu
notifier user) would call it without FOLL_GET (and if FOLL_GET isn't
set we'd just BUG_ON if nobody registered itself in the current task
mmu notifier list yet). But O_DIRECT is fundamental for decent
performance of virtualized I/O on fast storage so we can't avoid it to
solve the race of put_page against split_huge_page_refcount to achieve
a complete hugepage feature for KVM.

The KVM patch that enables KVM to run on transparent hugepages will
follow later (Marcelo apparently already run KVM with hugepages on top
of this ;).

Swap and oom works fine (well just like with regular pages ;). MMU
notifier is handled transparently too, with the exception of the young
bit on the pmd, that didn't have a range check but I think KVM will be
fine because the whole point of hugepages is that EPT/NPT will also
use a huge pmd when they notice gup returns pages with PageCompound set,
so they won't care of a range and there's just the pmd young bit to
check in that case.

There are likely still many missing things, especially in the basic
accounting area (overcommit/anon-rss) I didn't pay much attention to
and lots of cleanups possible (including perhaps splitting the patch
as usual to make merging simpler). This is still a RFC after all...

NOTE: in some cases if the L2 cache is small, this may slowdown and
waste memory during COWs because 4M of memory are accessed in a single
fault instead of 8k (the payoff is that after COW the program can run
faster). So we might want to switch the copy_huge_page (and
clear_huge_page too) to not temporal stores. I also extensively
researched ways to avoid this cache trashing with a full prefault
logic that would cow in 8k/16k/32k/64k up to 1M (I can send those
patches that fully implemented prefault) but I concluded they're not
worth it and they add an huge additional complexity to save a little
bit of memory and some cache during app startup, but they still don't
improve substantially the cache-trashing during startup (not as good
as only 4k). One reason is that those 4k pte entries copied are still
mapped on a perfectly cache-colored hugepage, so the trashing is the
worst one can generate in those copies (cow of 4k page copies aren't
so well colored so they trashes less, but again this results in
software running faster after the page fault). Those prefault patches
allowed things like a pte where post-cow pages were local 4k regular
anon pages and the not-yet-cowed pte entries were pointing in the
middle of some hugepage mapped read-only. If it doesn't payoff
substantially with todays hardware it will payoff even less in the
future with larger l2 caches, and the prefault logic would blot the VM
a lot. If one is emebdded and can't handle the sysctl to be 1 by
default because of cache trashing effects during page faults, it is
simple enough to just disable transparent hugepage globally and let
hugepages be allocated only in the MADV_HUGEPAGE region (both at page
fault time, and if enabled with the collapse_huge_page too through the
kernel daemon).

This patch supports only hugepages mapped in the pmd, archs that have
smaller hugepages will not fit in this patch alone... maybe we can
achieve mixed page size of them with a small change, maybe not. I
didn't think much about it so far...

Some performance result:

vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largep
ages3 
memset page fault 1566023
memset tlb miss 453854
memset second tlb miss 453321
random access tlb miss 41635
random access second tlb miss 41658
vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largepages3 
memset page fault 1566471
memset tlb miss 453375
memset second tlb miss 453320
random access tlb miss 41636
random access second tlb miss 41637
vmx andrea # ./largepages3 
memset page fault 1566642
memset tlb miss 453417
memset second tlb miss 453313
random access tlb miss 41630
random access second tlb miss 41647
vmx andrea # ./largepages3 
memset page fault 1566872
memset tlb miss 453418
memset second tlb miss 453315
random access tlb miss 41618
random access second tlb miss 41659
vmx andrea # echo 0 > /proc/sys/vm/transparent_hugepage 
vmx andrea # ./largepages3 
memset page fault 2182476
memset tlb miss 460305
memset second tlb miss 460179
random access tlb miss 44483
random access second tlb miss 44186
vmx andrea # ./largepages3
memset page fault 2182791
memset tlb miss 460742
memset second tlb miss 459962
random access tlb miss 43981
random access second tlb miss 43988

============
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#define SIZE (3UL*1024*1024*1024)

int main()
{
	char *p = malloc(SIZE), *p2;
	struct timeval before, after;

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset page fault %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	memset(p, 0, SIZE);
	gettimeofday(&after, NULL);
	printf("memset second tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	for (p2 = p; p2 < p+SIZE; p2 += 4096)
		*p2 = 0;
	gettimeofday(&after, NULL);
	printf("random access tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	gettimeofday(&before, NULL);
	for (p2 = p; p2 < p+SIZE; p2 += 4096)
		*p2 = 0;
	gettimeofday(&after, NULL);
	printf("random access second tlb miss %Lu\n",
	       (after.tv_sec-before.tv_sec)*1000000UL +
	       after.tv_usec-before.tv_usec);

	return 0;
}
============

Comments welcome, thanks!

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -449,6 +449,11 @@ static inline void pte_update(struct mm_
 {
 	PVOP_VCALL3(pv_mmu_ops.pte_update, mm, addr, ptep);
 }
+static inline void pmd_update(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp)
+{
+	PVOP_VCALL3(pv_mmu_ops.pmd_update, mm, addr, pmdp);
+}
 
 static inline void pte_update_defer(struct mm_struct *mm, unsigned long addr,
 				    pte_t *ptep)
@@ -456,6 +461,12 @@ static inline void pte_update_defer(stru
 	PVOP_VCALL3(pv_mmu_ops.pte_update_defer, mm, addr, ptep);
 }
 
+static inline void pmd_update_defer(struct mm_struct *mm, unsigned long addr,
+				    pmd_t *pmdp)
+{
+	PVOP_VCALL3(pv_mmu_ops.pmd_update_defer, mm, addr, pmdp);
+}
+
 static inline pte_t __pte(pteval_t val)
 {
 	pteval_t ret;
@@ -557,6 +568,16 @@ static inline void set_pte_at(struct mm_
 		PVOP_VCALL4(pv_mmu_ops.set_pte_at, mm, addr, ptep, pte.pte);
 }
 
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	if (sizeof(pmdval_t) > sizeof(long))
+		/* 5 arg words */
+		pv_mmu_ops.set_pmd_at(mm, addr, pmdp, pmd);
+	else
+		PVOP_VCALL4(pv_mmu_ops.set_pmd_at, mm, addr, pmdp, pmd.pmd);
+}
+
 static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
 	pmdval_t val = native_pmd_val(pmd);
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -266,10 +266,16 @@ struct pv_mmu_ops {
 	void (*set_pte_at)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep, pte_t pteval);
 	void (*set_pmd)(pmd_t *pmdp, pmd_t pmdval);
+	void (*set_pmd_at)(struct mm_struct *mm, unsigned long addr,
+			   pmd_t *pmdp, pmd_t pmdval);
 	void (*pte_update)(struct mm_struct *mm, unsigned long addr,
 			   pte_t *ptep);
 	void (*pte_update_defer)(struct mm_struct *mm,
 				 unsigned long addr, pte_t *ptep);
+	void (*pmd_update)(struct mm_struct *mm, unsigned long addr,
+			   pmd_t *pmdp);
+	void (*pmd_update_defer)(struct mm_struct *mm,
+				 unsigned long addr, pmd_t *pmdp);
 
 	pte_t (*ptep_modify_prot_start)(struct mm_struct *mm, unsigned long addr,
 					pte_t *ptep);
diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
--- a/arch/x86/include/asm/pgtable-3level.h
+++ b/arch/x86/include/asm/pgtable-3level.h
@@ -31,6 +31,11 @@ static inline void native_set_pte(pte_t 
 	ptep->pte_low = pte.pte_low;
 }
 
+static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
+{
+	pmdp->pmd = pmd.pmd;
+}
+
 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)
 {
 	set_64bit((unsigned long long *)(ptep), native_pte_val(pte));
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -31,6 +31,7 @@ extern struct list_head pgd_list;
 #else  /* !CONFIG_PARAVIRT */
 #define set_pte(ptep, pte)		native_set_pte(ptep, pte)
 #define set_pte_at(mm, addr, ptep, pte)	native_set_pte_at(mm, addr, ptep, pte)
+#define set_pmd_at(mm, addr, pmdp, pmd)	native_set_pmd_at(mm, addr, pmdp, pmd)
 
 #define set_pte_atomic(ptep, pte)					\
 	native_set_pte_atomic(ptep, pte)
@@ -55,6 +56,8 @@ extern struct list_head pgd_list;
 
 #define pte_update(mm, addr, ptep)              do { } while (0)
 #define pte_update_defer(mm, addr, ptep)        do { } while (0)
+#define pmd_update(mm, addr, ptep)              do { } while (0)
+#define pmd_update_defer(mm, addr, ptep)        do { } while (0)
 
 #define pgd_val(x)	native_pgd_val(x)
 #define __pgd(x)	native_make_pgd(x)
@@ -90,11 +93,21 @@ static inline int pte_young(pte_t pte)
 	return pte_flags(pte) & _PAGE_ACCESSED;
 }
 
+static inline int pmd_young(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_ACCESSED;
+}
+
 static inline int pte_write(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_RW;
 }
 
+static inline int pmd_write(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_RW;
+}
+
 static inline int pte_file(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_FILE;
@@ -145,6 +158,13 @@ static inline pte_t pte_set_flags(pte_t 
 	return native_make_pte(v | set);
 }
 
+static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v | set);
+}
+
 static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 {
 	pteval_t v = native_pte_val(pte);
@@ -152,6 +172,13 @@ static inline pte_t pte_clear_flags(pte_
 	return native_make_pte(v & ~clear);
 }
 
+static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
+{
+	pmdval_t v = native_pmd_val(pmd);
+
+	return native_make_pmd(v & ~clear);
+}
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_DIRTY);
@@ -162,11 +189,21 @@ static inline pte_t pte_mkold(pte_t pte)
 	return pte_clear_flags(pte, _PAGE_ACCESSED);
 }
 
+static inline pmd_t pmd_mkold(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
+}
+
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_RW);
 }
 
+static inline pmd_t pmd_wrprotect(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_RW);
+}
+
 static inline pte_t pte_mkexec(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_NX);
@@ -177,16 +214,41 @@ static inline pte_t pte_mkdirty(pte_t pt
 	return pte_set_flags(pte, _PAGE_DIRTY);
 }
 
+static inline pmd_t pmd_mkdirty(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_DIRTY);
+}
+
+static inline pmd_t pmd_mkhuge(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_PSE);
+}
+
 static inline pte_t pte_mkyoung(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_ACCESSED);
 }
 
+static inline pmd_t pmd_mkyoung(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_ACCESSED);
+}
+
+static inline pmd_t pmd_mkfreeze(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+}
+
 static inline pte_t pte_mkwrite(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_RW);
 }
 
+static inline pmd_t pmd_mkwrite(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_RW);
+}
+
 static inline pte_t pte_mkhuge(pte_t pte)
 {
 	return pte_set_flags(pte, _PAGE_PSE);
@@ -315,6 +377,11 @@ static inline int pte_same(pte_t a, pte_
 	return a.pte == b.pte;
 }
 
+static inline int pmd_same(pmd_t a, pmd_t b)
+{
+	return a.pmd == b.pmd;
+}
+
 static inline int pte_present(pte_t a)
 {
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
@@ -330,6 +397,24 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_PRESENT;
 }
 
+static inline int pmd_trans_frozen(pmd_t pmd)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return !pmd_present(pmd);
+#else
+	return 0;
+#endif
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	return pmd_val(pmd) & _PAGE_PSE;
+#else
+	return 0;
+#endif
+}
+
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
@@ -346,7 +431,7 @@ static inline unsigned long pmd_page_vad
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -367,6 +452,7 @@ static inline unsigned long pmd_index(un
  * to linux/mm.h:page_to_nid())
  */
 #define mk_pte(page, pgprot)   pfn_pte(page_to_pfn(page), (pgprot))
+#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
 
 /*
  * the pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
@@ -526,6 +612,12 @@ static inline void native_set_pte_at(str
 	native_set_pte(ptep, pte);
 }
 
+static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
+				     pmd_t *pmdp , pmd_t pmd)
+{
+	native_set_pmd(pmdp, pmd);
+}
+
 #ifndef CONFIG_PARAVIRT
 /*
  * Rules for using pte_update - it must be called after any PTE update which
@@ -557,14 +649,21 @@ struct vm_area_struct;
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
 				 pte_t entry, int dirty);
+extern int pmdp_set_access_flags(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp,
+				 pmd_t entry, int dirty);
 
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
 				     unsigned long addr, pte_t *ptep);
+extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+				     unsigned long addr, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 extern int ptep_clear_flush_young(struct vm_area_struct *vma,
 				  unsigned long address, pte_t *ptep);
+extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmdp);
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
@@ -575,6 +674,14 @@ static inline pte_t ptep_get_and_clear(s
 	return pte;
 }
 
+static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
+				       pmd_t *pmdp)
+{
+	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
+	pmd_update(mm, addr, pmdp);
+	return pmd;
+}
+
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep,
@@ -601,6 +708,16 @@ static inline void ptep_set_wrprotect(st
 	pte_update(mm, addr, ptep);
 }
 
+static inline void pmdp_set_wrprotect(struct mm_struct *mm,
+				      unsigned long addr, pmd_t *pmdp)
+{
+	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
+	pmd_update(mm, addr, pmd);
+}
+
+extern void pmdp_freeze_flush(struct vm_area_struct *vma,
+			      unsigned long addr, pmd_t *pmdp);
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -71,6 +71,18 @@ static inline pte_t native_ptep_get_and_
 	return ret;
 #endif
 }
+static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
+{
+#ifdef CONFIG_SMP
+	return native_make_pmd(xchg(&xp->pmd, 0));
+#else
+	/* native_local_pmdp_get_and_clear,
+	   but duplicated because of cyclic dependency */
+	pmd_t ret = *xp;
+	native_pmd_clear(NULL, 0, xp);
+	return ret;
+#endif
+}
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -422,8 +422,11 @@ struct pv_mmu_ops pv_mmu_ops = {
 	.set_pte = native_set_pte,
 	.set_pte_at = native_set_pte_at,
 	.set_pmd = native_set_pmd,
+	.set_pmd_at = native_set_pmd_at,
 	.pte_update = paravirt_nop,
 	.pte_update_defer = paravirt_nop,
+	.pmd_update = paravirt_nop,
+	.pmd_update_defer = paravirt_nop,
 
 	.ptep_modify_prot_start = __ptep_modify_prot_start,
 	.ptep_modify_prot_commit = __ptep_modify_prot_commit,
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -179,6 +179,7 @@ static void mark_screen_rdonly(struct mm
 	if (pud_none_or_clear_bad(pud))
 		goto out;
 	pmd = pmd_offset(pud, 0xA0000);
+	split_huge_page_mm(mm, 0xA0000, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto out;
 	pte = pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -128,6 +128,10 @@ static noinline int gup_huge_pmd(pmd_t p
 	do {
 		VM_BUG_ON(compound_head(page) != head);
 		pages[*nr] = page;
+		if (PageTail(page)) {
+			VM_BUG_ON(atomic_read(&page->_count) < 0);
+			atomic_inc(&page->_count);
+		}
 		(*nr)++;
 		page++;
 		refs++;
@@ -148,7 +152,7 @@ static int gup_pmd_range(pud_t pud, unsi
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
+		if (!pmd_present(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
 			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -288,6 +288,23 @@ int ptep_set_access_flags(struct vm_area
 	return changed;
 }
 
+int pmdp_set_access_flags(struct vm_area_struct *vma,
+			  unsigned long address, pmd_t *pmdp,
+			  pmd_t entry, int dirty)
+{
+	int changed = !pmd_same(*pmdp, entry);
+
+	VM_BUG_ON(address & ~HPAGE_MASK);
+
+	if (changed && dirty) {
+		*pmdp = entry;
+		pmd_update_defer(vma->vm_mm, address, pmdp);
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+	}
+
+	return changed;
+}
+
 int ptep_test_and_clear_young(struct vm_area_struct *vma,
 			      unsigned long addr, pte_t *ptep)
 {
@@ -303,6 +320,21 @@ int ptep_test_and_clear_young(struct vm_
 	return ret;
 }
 
+int pmdp_test_and_clear_young(struct vm_area_struct *vma,
+			      unsigned long addr, pmd_t *pmdp)
+{
+	int ret = 0;
+
+	if (pmd_young(*pmdp))
+		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
+					 (unsigned long *) &pmdp->pmd);
+
+	if (ret)
+		pmd_update(vma->vm_mm, addr, pmdp);
+
+	return ret;
+}
+
 int ptep_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pte_t *ptep)
 {
@@ -315,6 +347,33 @@ int ptep_clear_flush_young(struct vm_are
 	return young;
 }
 
+int pmdp_clear_flush_young(struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmdp)
+{
+	int young;
+
+	VM_BUG_ON(address & ~HPAGE_MASK);
+
+	young = pmdp_test_and_clear_young(vma, address, pmdp);
+	if (young)
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+
+	return young;
+}
+
+void pmdp_freeze_flush(struct vm_area_struct *vma,
+		       unsigned long address, pmd_t *pmdp)
+{
+	int cleared;
+	VM_BUG_ON(address & ~HPAGE_MASK);
+	cleared = test_and_clear_bit(_PAGE_BIT_PRESENT,
+				     (unsigned long *)&pmdp->pmd);
+	if (cleared) {
+		pmd_update(vma->vm_mm, address, pmdp);
+		flush_tlb_range(vma, address, address + HPAGE_SIZE);
+	}
+}
+
 /**
  * reserve_top_address - reserves a hole in the top of kernel address space
  * @reserve - size of hole to reserve
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -23,6 +23,19 @@
 	}								  \
 	__changed;							  \
 })
+
+#define pmdp_set_access_flags(__vma, __address, __pmdp, __entry, __dirty) \
+	({								\
+		int __changed = !pmd_same(*(__pmdp), __entry);		\
+		VM_BUG_ON((__address) & ~HPAGE_MASK);			\
+		if (__changed) {					\
+			set_pmd_at((__vma)->vm_mm, __address, __pmdp,	\
+				   __entry);				\
+			flush_tlb_range(__vma, __address,		\
+					(__address) + HPAGE_SIZE);	\
+		}							\
+		__changed;						\
+	})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
@@ -37,6 +50,17 @@
 			   (__ptep), pte_mkold(__pte));			\
 	r;								\
 })
+#define pmdp_test_and_clear_young(__vma, __address, __pmdp)		\
+({									\
+	pmd_t __pmd = *(__pmdp);					\
+	int r = 1;							\
+	if (!pmd_young(__pmd))						\
+		r = 0;							\
+	else								\
+		set_pmd_at((__vma)->vm_mm, (__address),			\
+			   (__pmdp), pmd_mkold(__pmd));			\
+	r;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
@@ -48,6 +72,16 @@
 		flush_tlb_page(__vma, __address);			\
 	__young;							\
 })
+#define pmdp_clear_flush_young(__vma, __address, __pmdp)		\
+({									\
+	int __young;							\
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	__young = pmdp_test_and_clear_young(__vma, __address, __pmdp);	\
+	if (__young)							\
+		flush_tlb_range(__vma, __address,			\
+				(__address) + HPAGE_SIZE);		\
+	__young;							\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
@@ -57,6 +91,13 @@
 	pte_clear((__mm), (__address), (__ptep));			\
 	__pte;								\
 })
+
+#define pmdp_get_and_clear(__mm, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = *(__pmdp);					\
+	pmd_clear((__mm), (__address), (__pmdp));			\
+	__pmd;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
@@ -88,6 +129,15 @@ do {									\
 	flush_tlb_page(__vma, __address);				\
 	__pte;								\
 })
+
+#define pmdp_clear_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd;							\
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	__pmd = pmdp_get_and_clear((__vma)->vm_mm, __address, __pmdp);	\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_SIZE);	\
+	__pmd;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
@@ -97,10 +147,25 @@ static inline void ptep_set_wrprotect(st
 	pte_t old_pte = *ptep;
 	set_pte_at(mm, address, ptep, pte_wrprotect(old_pte));
 }
+
+static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long address, pmd_t *pmdp)
+{
+	pmd_t old_pmd = *pmdp;
+	set_pmd_at(mm, address, pmdp, pmd_wrprotect(old_pmd));
+}
+
+#define pmdp_freeze_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = pmd_mkfreeze(*(__pmdp));				\
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	set_pmd_at((__vma)->vm_mm, __address, __pmdp, __pmd);		\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_SIZE);	\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
+#define pmd_same(A,B)	(pmd_val(A) == pmd_val(B))
 #endif
 
 #ifndef __HAVE_ARCH_PAGE_TEST_DIRTY
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -294,6 +294,20 @@ static inline int is_vmalloc_or_module_a
 }
 #endif
 
+static inline void compound_lock(struct page *page)
+{
+	while (TestSetPageCompoundLock(page))
+		while (PageCompoundLock(page))
+			cpu_relax();
+	smp_mb();
+}
+
+static inline void compound_unlock(struct page *page)
+{
+	smp_mb();
+	ClearPageCompoundLock(page);
+}
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
@@ -308,9 +322,14 @@ static inline int page_count(struct page
 
 static inline void get_page(struct page *page)
 {
-	page = compound_head(page);
-	VM_BUG_ON(atomic_read(&page->_count) == 0);
+	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
 	atomic_inc(&page->_count);
+	if (unlikely(PageTail(page))) {
+		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
+		atomic_inc(&page->first_page->_count);
+		/* __split_huge_page_refcount can't run under get_page */
+		VM_BUG_ON(!PageTail(page));
+	}
 }
 
 static inline struct page *virt_to_head_page(const void *x)
@@ -364,6 +383,19 @@ static inline void set_compound_order(st
 }
 
 /*
+ * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
+ * servicing faults for write access.  In the normal case, do always want
+ * pte_mkwrite.  But get_user_pages can cause write faults for mappings
+ * that do not have writing enabled, when used by access_process_vm.
+ */
+static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pte = pte_mkwrite(pte);
+	return pte;
+}
+
+/*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
  * zeroes, and text pages of executables and shared libraries have
@@ -804,6 +836,64 @@ int invalidate_inode_page(struct page *p
 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
+
+extern int do_huge_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  unsigned int flags);
+extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
+			 struct vm_area_struct *vma);
+extern int do_huge_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd, pmd_t orig_pmd);
+extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
+extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
+					  unsigned long addr,
+					  pmd_t *pmd,
+					  unsigned int flags);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+			  pmd_t *dst_pmd, pmd_t *src_pmd,
+			  struct vm_area_struct *vma,
+			  unsigned long addr, unsigned long end);
+extern int handle_pte_fault(struct mm_struct *mm,
+			    struct vm_area_struct *vma, unsigned long address,
+			    pte_t *pte, pmd_t *pmd, unsigned int flags);
+extern int sysctl_transparent_hugepage;
+extern void __split_huge_page_mm(struct mm_struct *mm, unsigned long address,
+				 pmd_t *pmd);
+extern void __split_huge_page_vma(struct vm_area_struct *vma, pmd_t *pmd);
+extern int split_huge_page(struct page *page);
+#define split_huge_page_mm(__mm, __addr, __pmd)				\
+	do {								\
+		if (unlikely(pmd_trans_huge(*(__pmd))))			\
+			__split_huge_page_mm(__mm, __addr, __pmd);	\
+	}  while (0)
+#define split_huge_page_vma(__vma, __pmd)				\
+	do {								\
+		if (unlikely(pmd_trans_huge(*(__pmd))))			\
+			__split_huge_page_vma(__vma, __pmd);		\
+	}  while (0)
+#define wait_split_huge_page(__anon_vma, __pmd)				\
+	do {								\
+		smp_mb();						\
+		spin_unlock_wait(&(__anon_vma)->lock);			\
+		smp_mb();						\
+		VM_BUG_ON(pmd_trans_frozen(*(__pmd)) ||			\
+			  pmd_trans_huge(*(__pmd)));			\
+	} while (0)
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define sysctl_transparent_hugepage 0
+static inline int split_huge_page(struct page *page)
+{
+	return 0;
+}
+#define split_huge_page_mm(__mm, __addr, __pmd)	\
+	do { }  while (0)
+#define split_huge_page_vma(__vma, __pmd)	\
+	do { }  while (0)
+#define wait_split_huge_page(__anon_vma, __pmd)	\
+	do { } while (0)
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
@@ -904,7 +994,8 @@ static inline int __pmd_alloc(struct mm_
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
 #endif
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
+int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address);
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 
 /*
@@ -973,12 +1064,14 @@ static inline void pgtable_page_dtor(str
 	pte_unmap(pte);					\
 } while (0)
 
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map(pmd, address))
+#define pte_alloc_map(mm, vma, pmd, address)				\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, vma,	\
+							pmd, address))?	\
+	 NULL: pte_offset_map(pmd, address))
 
 #define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, NULL,	\
+							pmd, address))?	\
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
 
 #define pte_alloc_kernel(pmd, address)			\
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -287,6 +287,9 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -243,6 +243,32 @@ static inline void mmu_notifier_mm_destr
 	__pte;								\
 })
 
+#define pmdp_clear_flush_notify(__vma, __address, __pmdp)		\
+({									\
+	pmd_t __pmd;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	VM_BUG_ON(__address & ~HPAGE_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_SIZE);	\
+	__pmd = pmdp_clear_flush(___vma, ___address, __pmdp);		\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_SIZE);	\
+	__pmd;								\
+})
+
+#define pmdp_freeze_flush_notify(__vma, __address, __pmdp)		\
+({									\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	VM_BUG_ON(__address & ~HPAGE_MASK);				\
+	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
+					    (__address)+HPAGE_SIZE);	\
+	pmdp_freeze_flush(___vma, ___address, __pmdp);			\
+	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
+					  (__address)+HPAGE_SIZE);	\
+})
+
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
@@ -254,6 +280,17 @@ static inline void mmu_notifier_mm_destr
 	__young;							\
 })
 
+#define pmdp_clear_flush_young_notify(__vma, __address, __pmdp)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = pmdp_clear_flush_young(___vma, ___address, __pmdp);	\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address);		\
+	__young;							\
+})
+
 #define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
 ({									\
 	struct mm_struct *___mm = __mm;					\
@@ -305,7 +342,10 @@ static inline void mmu_notifier_mm_destr
 }
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
+#define pmdp_clear_flush_young_notify pmdp_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
+#define pmdp_clear_flush_notify pmdp_clear_flush
+#define pmdp_freeze_flush_notify pmdp_freeze_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,6 +108,7 @@ enum pageflags {
 #ifdef CONFIG_MEMORY_FAILURE
 	PG_hwpoison,		/* hardware poisoned page. Don't touch */
 #endif
+	PG_compound_lock,
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -239,6 +240,8 @@ PAGEFLAG(MappedToDisk, mappedtodisk)
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
 PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
 
+PAGEFLAG(CompoundLock, compound_lock) TESTSETFLAG(CompoundLock, compound_lock)
+
 #ifdef CONFIG_HIGHMEM
 /*
  * Must use a macro here due to header dependency issues. page_zone() is not
@@ -346,7 +349,7 @@ static inline void set_page_writeback(st
  * tests can be used in performance sensitive paths. PageCompound is
  * generally not used in hot code paths.
  */
-__PAGEFLAG(Head, head)
+__PAGEFLAG(Head, head) CLEARPAGEFLAG(Head, head)
 __PAGEFLAG(Tail, tail)
 
 static inline int PageCompound(struct page *page)
@@ -354,6 +357,13 @@ static inline int PageCompound(struct pa
 	return page->flags & ((1L << PG_head) | (1L << PG_tail));
 
 }
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void ClearPageCompound(struct page *page)
+{
+	BUG_ON(!PageHead(page));
+	ClearPageHead(page);
+}
+#endif
 #else
 /*
  * Reduce page flag use as much as possible by overlapping
@@ -391,6 +401,14 @@ static inline void __ClearPageTail(struc
 	page->flags &= ~PG_head_tail_mask;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void ClearPageCompound(struct page *page)
+{
+	BUG_ON(page->flags & PG_head_tail_mask != (1L << PG_compound));
+	ClearPageCompound(page);
+}
+#endif
+
 #endif /* !PAGEFLAGS_EXTENDED */
 
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -73,6 +73,7 @@ void page_remove_rmap(struct page *);
 
 static inline void page_dup_rmap(struct page *page)
 {
+	VM_BUG_ON(PageTail(page));
 	atomic_inc(&page->_mapcount);
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -496,6 +496,9 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(mm->pmd_huge_pte);
+#endif
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -636,6 +639,10 @@ struct mm_struct *dup_mm(struct task_str
 	mm->token_priority = 0;
 	mm->last_interval = 0;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	mm->pmd_huge_pte = NULL;
+#endif
+
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1422,6 +1422,16 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "transparent_hugepage",
+		.data		= &sysctl_transparent_hugepage,
+		.maxlen		= sizeof(sysctl_transparent_hugepage),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 
 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -290,3 +290,16 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config TRANSPARENT_HUGEPAGE
+	bool "Transparent Hugepage support"
+	depends on X86_64
+	help
+	  Transparent Hugepages allows the kernel to use huge pages and
+	  huge tlb transparently to the applications whenever possible.
+	  This feature can improve computing performance to certain
+	  applications by speeding up page faults during memory
+	  allocation, by reducing the number of tlb misses and by speeding
+	  up the pagetable walking.
+
+	  If unsure, say N.
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -45,3 +45,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
new file mode 100644
--- /dev/null
+++ b/mm/huge_memory.c
@@ -0,0 +1,376 @@
+/*
+ *  Copyright (C) 2009  Red Hat, Inc.
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/highmem.h>
+#include <linux/hugetlb.h>
+#include <linux/mmu_notifier.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <asm/pgalloc.h>
+#include "internal.h"
+
+int sysctl_transparent_hugepage __read_mostly = 1;
+
+static void clear_huge_page(struct page *page, unsigned long addr)
+{
+	int i;
+
+	might_sleep();
+	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
+		cond_resched();
+		clear_user_highpage(page + i, addr + PAGE_SIZE * i);
+	}
+}
+
+static void prepare_pmd_huge_pte(pgtable_t pgtable,
+				 struct mm_struct *mm)
+{
+	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
+
+	/* FIFO */
+	if (!mm->pmd_huge_pte)
+		INIT_LIST_HEAD(&pgtable->lru);
+	else
+		list_add(&pgtable->lru, &mm->pmd_huge_pte->lru);
+	mm->pmd_huge_pte = pgtable;
+}
+
+static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
+{
+	if (likely(vma->vm_flags & VM_WRITE))
+		pmd = pmd_mkwrite(pmd);
+	return pmd;
+}
+
+static int __do_huge_anonymous_page(struct mm_struct *mm,
+				    struct vm_area_struct *vma,
+				    unsigned long address, pmd_t *pmd,
+				    struct page *page,
+				    unsigned long haddr)
+{
+	int ret = 0;
+	pgtable_t pgtable;
+
+	VM_BUG_ON(!PageCompound(page));
+	pgtable = pte_alloc_one(mm, address);
+	if (unlikely(!pgtable)) {
+		put_page(page);
+		return VM_FAULT_OOM;
+	}
+
+	clear_huge_page(page, haddr);
+
+	__SetPageUptodate(page);
+	smp_wmb();
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_none(*pmd))) {
+		put_page(page);
+		pte_free(mm, pgtable);
+	} else {
+		pmd_t entry;
+		entry = mk_pmd(page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_mkhuge(entry);
+		page_add_new_anon_rmap(page, vma, haddr);
+		set_pmd_at(mm, haddr, pmd, entry);
+		prepare_pmd_huge_pte(pgtable, mm);
+	}
+	spin_unlock(&mm->page_table_lock);
+	
+	return ret;
+}
+
+int do_huge_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd,
+			   unsigned int flags)
+{
+	struct page *page;
+	unsigned long haddr = address & HPAGE_MASK;
+	pte_t *pte;
+
+	if (haddr >= vma->vm_start && haddr + HPAGE_SIZE <= vma->vm_end) {
+		if (unlikely(anon_vma_prepare(vma)))
+			return VM_FAULT_OOM;
+		page = alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_COMP|
+				   __GFP_REPEAT|__GFP_NOWARN,
+				   HPAGE_SHIFT-PAGE_SHIFT);
+		if (unlikely(!page))
+			goto out;
+
+		return __do_huge_anonymous_page(mm, vma,
+						address, pmd,
+						page, haddr);
+	}
+out:
+	pte = pte_alloc_map(mm, vma, pmd, address);
+	if (!pte)
+		return VM_FAULT_OOM;
+	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
+}
+
+static void copy_huge_page(struct page *dst_page, struct page *src_page,
+			   unsigned long addr, struct vm_area_struct *vma)
+{
+	int i;
+
+	might_sleep();
+	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
+		copy_user_highpage(dst_page + i, src_page + i,
+				   addr + PAGE_SIZE * i, vma);
+		cond_resched();
+	}
+}
+
+int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
+		  struct vm_area_struct *vma)
+{
+	struct page *src_page;
+	pmd_t pmd;
+	pgtable_t pgtable;
+	int ret;
+
+	ret = -ENOMEM;
+	pgtable = pte_alloc_one(dst_mm, addr);
+	if (unlikely(!pgtable))
+		goto out;
+
+	spin_lock(&dst_mm->page_table_lock);
+	spin_lock_nested(&src_mm->page_table_lock, SINGLE_DEPTH_NESTING);
+
+	ret = -EAGAIN;
+	pmd = *src_pmd;
+	if (unlikely(!pmd_trans_huge(pmd)))
+		goto out_unlock;
+	if (unlikely(pmd_trans_frozen(pmd))) {
+		/* split huge page running from under us */
+		spin_unlock(&src_mm->page_table_lock);
+		spin_unlock(&dst_mm->page_table_lock);
+
+		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
+		goto out;
+	}
+	src_page = pmd_pgtable(pmd);
+	VM_BUG_ON(!PageHead(src_page));
+	get_page(src_page);
+	page_dup_rmap(src_page);
+	add_mm_counter(dst_mm, anon_rss, 1<<(HPAGE_SHIFT-PAGE_SHIFT));
+
+	pmdp_set_wrprotect(src_mm, addr, src_pmd);
+	pmd = pmd_mkold(pmd_wrprotect(pmd));
+	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+	prepare_pmd_huge_pte(pgtable, dst_mm);
+
+	ret = 0;
+out_unlock:
+	spin_unlock(&src_mm->page_table_lock);
+	spin_unlock(&dst_mm->page_table_lock);
+out:
+	return ret;
+}
+
+/* no "address" argument so destroys page coloring of some arch */
+pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
+{
+	pgtable_t pgtable;
+
+	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
+
+	/* FIFO */
+	pgtable = mm->pmd_huge_pte;
+	if (list_empty(&pgtable->lru))
+		mm->pmd_huge_pte = NULL; /* debug */
+	else {
+		mm->pmd_huge_pte = list_entry(pgtable->lru.next,
+					      struct page, lru);
+		list_del(&pgtable->lru);
+	}
+	return pgtable;
+}
+
+int do_huge_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
+{
+	int ret = 0, i;
+	struct page *page, *new_page;
+	unsigned long haddr;
+	struct page **pages;
+
+	VM_BUG_ON(!vma->anon_vma);
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+		goto out_unlock;
+
+	page = pmd_pgtable(orig_pmd);
+	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
+	haddr = address & HPAGE_MASK;
+	if (page_mapcount(page) == 1) {
+		pmd_t entry;
+		entry = pmd_mkyoung(orig_pmd);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
+			update_mmu_cache(vma, address, entry);
+		ret |= VM_FAULT_WRITE;
+		goto out_unlock;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	new_page = alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_COMP|
+			      __GFP_REPEAT|__GFP_NOWARN,
+			      HPAGE_SHIFT-PAGE_SHIFT);
+#ifdef CONFIG_DEBUG_VM
+	if (sysctl_transparent_hugepage == -1  && new_page) {
+		put_page(new_page);
+		new_page = NULL;
+	}
+#endif
+	if (unlikely(!new_page)) {
+		pgtable_t pgtable;
+		pmd_t _pmd;
+
+		pages = kzalloc(sizeof(struct page *) *
+				(1<<(HPAGE_SHIFT-PAGE_SHIFT)),
+				GFP_KERNEL);
+		if (unlikely(!pages)) {
+			ret |= VM_FAULT_OOM;
+			goto out;
+		}
+		
+		for (i = 0; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT); i++) {
+			pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
+						  vma, address);
+			if (unlikely(!pages[i])) {
+				while (--i >= 0)
+					put_page(pages[i]);
+				kfree(pages);
+				ret |= VM_FAULT_OOM;
+				goto out;
+			}
+		}
+
+		spin_lock(&mm->page_table_lock);
+		if (unlikely(!pmd_same(*pmd, orig_pmd)))
+			goto out_free_pages;
+		else
+			get_page(page);
+		spin_unlock(&mm->page_table_lock);
+
+		might_sleep();
+		for (i = 0; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT); i++) {
+			copy_user_highpage(pages[i], page + i,
+					   haddr + PAGE_SHIFT*i, vma);
+			__SetPageUptodate(pages[i]);
+			cond_resched();
+		}
+
+		spin_lock(&mm->page_table_lock);
+		if (unlikely(!pmd_same(*pmd, orig_pmd)))
+			goto out_free_pages;
+		else
+			put_page(page);
+
+		pmdp_clear_flush_notify(vma, haddr, pmd);
+		/* leave pmd empty until pte is filled */
+
+		pgtable = get_pmd_huge_pte(mm);
+		pmd_populate(mm, &_pmd, pgtable);
+
+		for (i = 0; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT);
+		     i++, haddr += PAGE_SIZE) {
+			pte_t *pte, entry;
+			entry = mk_pte(pages[i], vma->vm_page_prot);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			page_add_new_anon_rmap(pages[i], vma, haddr);
+			pte = pte_offset_map(&_pmd, haddr);
+			VM_BUG_ON(!pte_none(*pte));
+			set_pte_at(mm, haddr, pte, entry);
+			pte_unmap(pte);
+		}
+		kfree(pages);
+
+		mm->nr_ptes++;
+		smp_wmb(); /* make pte visible before pmd */
+		pmd_populate(mm, pmd, pgtable);
+		spin_unlock(&mm->page_table_lock);
+
+		ret |= VM_FAULT_WRITE;
+		page_remove_rmap(page);
+		put_page(page);
+		goto out;
+	}
+
+	copy_huge_page(new_page, page, haddr, vma);
+	__SetPageUptodate(new_page);
+
+	smp_wmb();
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, orig_pmd)))
+		put_page(new_page);
+	else {
+		pmd_t entry;
+		entry = mk_pmd(new_page, vma->vm_page_prot);
+		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_mkhuge(entry);
+		pmdp_clear_flush_notify(vma, haddr, pmd);
+		page_add_new_anon_rmap(new_page, vma, haddr);
+		set_pmd_at(mm, haddr, pmd, entry);
+		update_mmu_cache(vma, address, entry);
+		page_remove_rmap(page);
+		put_page(page);
+		ret |= VM_FAULT_WRITE;
+	}
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+out:
+	return ret;
+
+out_free_pages:
+	for (i = 0; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT); i++)
+		put_page(pages[i]);
+	kfree(pages);
+	goto out_unlock;
+}
+
+struct page *follow_trans_huge_pmd(struct mm_struct *mm,
+				   unsigned long addr,
+				   pmd_t *pmd,
+				   unsigned int flags)
+{
+	struct page *page = NULL;
+
+	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
+
+	if (flags & FOLL_WRITE && !pmd_write(*pmd))
+		goto out;
+
+	page = pmd_pgtable(*pmd);
+	VM_BUG_ON(!PageHead(page));
+	if (flags & FOLL_TOUCH) {
+		pmd_t _pmd;
+		/*
+		 * We should set the dirty bit only for FOLL_WRITE but
+		 * for now the dirty bit in the pmd is meaningless.
+		 * And if the dirty bit will become meaningful and
+		 * we'll only set it with FOLL_WRITE, an atomic
+		 * set_bit will be required on the pmd to set the
+		 * young bit, instead of the current set_pmd_at.
+		 */
+		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
+		set_pmd_at(mm, addr & HPAGE_MASK, pmd, _pmd);
+	}
+	page += (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
+	VM_BUG_ON(!PageCompound(page));
+	if (flags & FOLL_GET)
+		get_page(page);
+
+out:
+	return page;
+}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -324,9 +324,11 @@ void free_pgtables(struct mmu_gather *tl
 	}
 }
 
-int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
+int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
+		pmd_t *pmd, unsigned long address)
 {
 	pgtable_t new = pte_alloc_one(mm, address);
+	int wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -346,14 +348,18 @@ int __pte_alloc(struct mm_struct *mm, pm
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
 	spin_lock(&mm->page_table_lock);
-	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
+	wait_split_huge_page = 0;
+	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		mm->nr_ptes++;
 		pmd_populate(mm, pmd, new);
 		new = NULL;
-	}
+	} else if (unlikely(pmd_trans_frozen(*pmd)))
+		wait_split_huge_page = 1;
 	spin_unlock(&mm->page_table_lock);
 	if (new)
 		pte_free(mm, new);
+	if (wait_split_huge_page)
+		wait_split_huge_page(vma->anon_vma, pmd);
 	return 0;
 }
 
@@ -366,10 +372,11 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&init_mm.page_table_lock);
-	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
+	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
-	}
+	} else
+		VM_BUG_ON(pmd_trans_frozen(*pmd));
 	spin_unlock(&init_mm.page_table_lock);
 	if (new)
 		pte_free_kernel(&init_mm, new);
@@ -637,9 +644,9 @@ out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
+int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		   pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		   unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
@@ -699,6 +706,16 @@ static inline int copy_pmd_range(struct 
 	src_pmd = pmd_offset(src_pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (pmd_trans_huge(*src_pmd)) {
+			int err;
+			err = copy_huge_pmd(dst_mm, src_mm,
+					    dst_pmd, src_pmd, addr, vma);
+			if (err == -ENOMEM)
+				return -ENOMEM;
+			if (!err)
+				continue;
+			/* fall through */
+		}
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
 		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
@@ -895,6 +912,35 @@ static inline unsigned long zap_pmd_rang
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (pmd_trans_huge(*pmd)) {
+			spin_lock(&tlb->mm->page_table_lock);
+			if (likely(pmd_trans_huge(*pmd))) {
+				if (unlikely(pmd_trans_frozen(*pmd))) {
+					spin_unlock(&tlb->mm->page_table_lock);
+					wait_split_huge_page(vma->anon_vma,
+							     pmd);
+				} else {
+					struct page *page;
+					pgtable_t pgtable;
+					pgtable = get_pmd_huge_pte(tlb->mm);
+					page = pfn_to_page(pmd_pfn(*pmd));
+					VM_BUG_ON(!PageCompound(page));
+					pmd_clear(pmd);
+					spin_unlock(&tlb->mm->page_table_lock);
+					page_remove_rmap(page);
+					VM_BUG_ON(page_mapcount(page) < 0);
+					add_mm_counter(tlb->mm, anon_rss,
+						       -1<<(HPAGE_SHIFT-
+							    PAGE_SHIFT));
+					put_page(page);
+					pte_free(tlb->mm, pgtable);
+					(*zap_work)--;
+					continue;
+				}
+			} else
+				spin_unlock(&tlb->mm->page_table_lock);
+			/* fall through */
+		}
 		if (pmd_none_or_clear_bad(pmd)) {
 			(*zap_work)--;
 			continue;
@@ -1160,11 +1206,27 @@ struct page *follow_page(struct vm_area_
 	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		goto no_page_table;
-	if (pmd_huge(*pmd)) {
+	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
 		BUG_ON(flags & FOLL_GET);
 		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
 		goto out;
 	}
+	if (pmd_trans_huge(*pmd)) {
+		spin_lock(&mm->page_table_lock);
+		if (likely(pmd_trans_huge(*pmd))) {
+			if (unlikely(pmd_trans_frozen(*pmd))) {
+				spin_unlock(&mm->page_table_lock);
+				wait_split_huge_page(vma->anon_vma, pmd);
+			} else {
+				page = follow_trans_huge_pmd(mm, address,
+							     pmd, flags);
+				spin_unlock(&mm->page_table_lock);
+				goto out;
+			}
+		} else
+			spin_unlock(&mm->page_table_lock);
+		/* fall through */
+	}
 	if (unlikely(pmd_bad(*pmd)))
 		goto no_page_table;
 
@@ -1273,6 +1335,7 @@ int __get_user_pages(struct task_struct 
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
@@ -1925,19 +1988,6 @@ static inline int pte_unmap_same(struct 
 	return same;
 }
 
-/*
- * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
- * servicing faults for write access.  In the normal case, do always want
- * pte_mkwrite.  But get_user_pages can cause write faults for mappings
- * that do not have writing enabled, when used by access_process_vm.
- */
-static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
-{
-	if (likely(vma->vm_flags & VM_WRITE))
-		pte = pte_mkwrite(pte);
-	return pte;
-}
-
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
 	/*
@@ -2926,9 +2976,9 @@ static int do_nonlinear_fault(struct mm_
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static inline int handle_pte_fault(struct mm_struct *mm,
-		struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pmd_t *pmd, unsigned int flags)
+int handle_pte_fault(struct mm_struct *mm,
+		     struct vm_area_struct *vma, unsigned long address,
+		     pte_t *pte, pmd_t *pmd, unsigned int flags)
 {
 	pte_t entry;
 	spinlock_t *ptl;
@@ -3004,7 +3054,23 @@ int handle_mm_fault(struct mm_struct *mm
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	pte = pte_alloc_map(mm, pmd, address);
+	if (pmd_none(*pmd) && sysctl_transparent_hugepage) {
+		if (!vma->vm_ops)
+			return do_huge_anonymous_page(mm, vma, address,
+						      pmd, flags);
+	} else {
+		pmd_t orig_pmd = *pmd;
+		barrier();
+		if (pmd_trans_huge(orig_pmd)) {
+			if (flags & FAULT_FLAG_WRITE &&
+			    !pmd_write(orig_pmd) &&
+			    !pmd_trans_frozen(orig_pmd))
+				return do_huge_wp_page(mm, vma, address,
+						       pmd, orig_pmd);
+			return 0;
+		}
+	}
+	pte = pte_alloc_map(mm, vma, pmd, address);
 	if (!pte)
 		return VM_FAULT_OOM;
 
@@ -3144,6 +3210,7 @@ static int follow_pte(struct mm_struct *
 		goto out;
 
 	pmd = pmd_offset(pud, address);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -450,6 +450,7 @@ static inline int check_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_vma(vma, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		if (check_pte_range(vma, pmd, addr, next, nodes,
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -102,6 +102,7 @@ static void remove_migration_pte(struct 
                 return;
 
 	pmd = pmd_offset(pud, addr);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (!pmd_present(*pmd))
 		return;
 
diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -95,6 +95,7 @@ static long do_mincore(unsigned long add
 	if (pud_none_or_clear_bad(pud))
 		goto none_mapped;
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_vma(vma, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		goto none_mapped;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -89,6 +89,7 @@ static inline void change_pmd_range(stru
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_mm(mm, addr, pmd);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		change_pte_range(mm, pmd, addr, next, newprot, dirty_accountable);
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -42,13 +42,15 @@ static pmd_t *get_old_pmd(struct mm_stru
 		return NULL;
 
 	pmd = pmd_offset(pud, addr);
+	split_huge_page_mm(mm, addr, pmd);
 	if (pmd_none_or_clear_bad(pmd))
 		return NULL;
 
 	return pmd;
 }
 
-static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
+static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
+			    unsigned long addr)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -63,7 +65,7 @@ static pmd_t *alloc_new_pmd(struct mm_st
 	if (!pmd)
 		return NULL;
 
-	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
+	if (!pmd_present(*pmd) && __pte_alloc(mm, vma, pmd, addr))
 		return NULL;
 
 	return pmd;
@@ -148,7 +150,7 @@ unsigned long move_page_tables(struct vm
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;
-		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
+		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
 		if (!new_pmd)
 			break;
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -310,6 +310,7 @@ void prep_compound_page(struct page *pag
 	}
 }
 
+/* update __split_huge_page_refcount if you change this function */
 static int destroy_compound_page(struct page *page, unsigned long order)
 {
 	int i;
@@ -587,6 +588,8 @@ static void __free_pages_ok(struct page 
 
 	kmemcheck_free_shadow(page, order);
 
+	if (PageAnon(page))
+		page->mapping = NULL;
 	for (i = 0 ; i < (1 << order) ; ++i)
 		bad += free_pages_check(page + i);
 	if (bad)
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -33,6 +33,7 @@ static int walk_pmd_range(pud_t *pud, un
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		split_huge_page_mm(walk->mm, addr, pmd);
 		if (pmd_none_or_clear_bad(pmd)) {
 			if (walk->pte_hole)
 				err = walk->pte_hole(addr, next, walk);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -55,8 +55,10 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/hugetlb.h>
 
 #include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 
 #include "internal.h"
 
@@ -260,6 +262,42 @@ unsigned long page_address_in_vma(struct
 	return vma_address(page, vma);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static pmd_t *__page_check_address_pmd(struct page *page, struct mm_struct *mm,
+				       unsigned long address, int notfrozen)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd, *ret = NULL;
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		goto out;
+	VM_BUG_ON(notfrozen == 1 && pmd_trans_frozen(*pmd));
+	if (pmd_trans_huge(*pmd) && pmd_pgtable(*pmd) == page) {
+		VM_BUG_ON(notfrozen == -1 && !pmd_trans_frozen(*pmd));
+		ret = pmd;
+	}
+out:
+	return ret;
+}
+
+#define page_check_address_pmd(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, 0)
+#define page_check_address_pmd_notfrozen(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, 1)
+#define page_check_address_pmd_frozen(__page, __mm, __address) \
+	__page_check_address_pmd(__page, __mm, __address, -1)
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 /*
  * Check that @page is mapped at @address into @mm.
  *
@@ -344,39 +382,21 @@ static int page_referenced_one(struct pa
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
-	pte_t *pte;
-	spinlock_t *ptl;
 	int referenced = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
-		goto out;
-
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
 	 * in order that it progresses to try_to_unmap and is moved to the
 	 * unevictable list.
 	 */
 	if (vma->vm_flags & VM_LOCKED) {
-		*mapcount = 1;	/* break early from loop */
+		*mapcount = 0;	/* break early from loop */
 		*vm_flags |= VM_LOCKED;
-		goto out_unmap;
-	}
-
-	if (ptep_clear_flush_young_notify(vma, address, pte)) {
-		/*
-		 * Don't treat a reference through a sequentially read
-		 * mapping as such.  If the page has been used in
-		 * another mapping, we will catch it; if this other
-		 * mapping is already gone, the unmap path will have
-		 * set PG_referenced or activated the page.
-		 */
-		if (likely(!VM_SequentialReadHint(vma)))
-			referenced++;
+		goto out;
 	}
 
 	/* Pretend the page is referenced if the task has the
@@ -385,9 +405,42 @@ static int page_referenced_one(struct pa
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
-out_unmap:
+	if (unlikely(PageCompound(page))) {
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		pmd_t *pmd;
+
+		spin_lock(&mm->page_table_lock);
+		pmd = page_check_address_pmd(page, mm, address);
+		if (pmd && !pmd_trans_frozen(*pmd) &&
+		    pmdp_clear_flush_young_notify(vma, address, pmd))
+			referenced++;
+		spin_unlock(&mm->page_table_lock);
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+		VM_BUG_ON(1);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+	} else {
+		pte_t *pte;
+		spinlock_t *ptl;
+
+		pte = page_check_address(page, mm, address, &ptl, 0);
+		if (!pte)
+			goto out;
+
+		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+			/*
+			 * Don't treat a reference through a sequentially read
+			 * mapping as such.  If the page has been used in
+			 * another mapping, we will catch it; if this other
+			 * mapping is already gone, the unmap path will have
+			 * set PG_referenced or activated the page.
+			 */
+			if (likely(!VM_SequentialReadHint(vma)))
+				referenced++;
+		}
+		pte_unmap_unlock(pte, ptl);
+	}
+
 	(*mapcount)--;
-	pte_unmap_unlock(pte, ptl);
 out:
 	if (referenced)
 		*vm_flags |= vma->vm_flags;
@@ -1210,6 +1263,10 @@ int try_to_unmap(struct page *page, enum
 
 	BUG_ON(!PageLocked(page));
 
+	if (unlikely(PageCompound(page)))
+		if (unlikely(split_huge_page(page)))
+			return SWAP_AGAIN;
+
 	if (PageAnon(page))
 		ret = try_to_unmap_anon(page, flags);
 	else
@@ -1243,3 +1300,221 @@ int try_to_munlock(struct page *page)
 		return try_to_unmap_file(page, TTU_MUNLOCK);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int __split_huge_page_freeze(struct page *page,
+				    struct vm_area_struct *vma,
+				    unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t *pmd;
+	int ret = 0;
+
+	if (unlikely(address == -EFAULT))
+		goto out;
+	spin_lock(&mm->page_table_lock);
+	pmd = page_check_address_pmd_notfrozen(page, mm, address);
+	if (pmd) {
+		/*
+		 * We can't temporarily set the pmd to null in order
+		 * to freeze it, pmd_huge must remain on at all
+		 * times.
+		 */
+		pmdp_freeze_flush_notify(vma, address, pmd);
+		ret = 1;
+	}
+	spin_unlock(&mm->page_table_lock);
+out:
+	return ret;
+}
+
+static void __split_huge_page_refcount(struct page *page)
+{
+	int i;
+	unsigned long head_index = page->index;
+
+	compound_lock(page);
+
+	for (i = 1; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT); i++) {
+		struct page *page_tail = page + i;
+
+		/* tail_page->_count cannot change */
+		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
+		BUG_ON(page_count(page) <= 0);
+		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
+		BUG_ON(atomic_read(&page_tail->_count) <= 0);
+
+		/* after clearing PageTail the gup refcount can be released */
+		smp_mb();
+
+		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+		page_tail->flags |= (page->flags &
+				     ((1L << PG_referenced) |
+				      (1L << PG_swapbacked) |
+				      (1L << PG_mlocked) |
+				      (1L << PG_uptodate)));
+		page_tail->flags |= (1L << PG_dirty);
+
+		/*
+		 * 1) clear PageTail before overwriting first_page
+		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
+		 */
+		smp_wmb();
+
+		BUG_ON(page_mapcount(page_tail));
+		page_tail->_mapcount = page->_mapcount;
+		BUG_ON(page_tail->mapping);
+		page_tail->mapping = page->mapping;
+		page_tail->index = ++head_index;
+		BUG_ON(!PageAnon(page_tail));
+		BUG_ON(!PageUptodate(page_tail));
+		BUG_ON(!PageDirty(page_tail));
+		BUG_ON(!PageSwapBacked(page_tail));
+
+		if (page_evictable(page_tail, NULL))
+			lru_cache_add_lru(page_tail, LRU_ACTIVE_ANON);
+		else
+			add_page_to_unevictable_list(page_tail);
+		put_page(page_tail);
+	}
+
+	ClearPageCompound(page);
+	compound_unlock(page);
+}
+
+static int __split_huge_page_map(struct page *page,
+				 struct vm_area_struct *vma,
+				 unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t *pmd, _pmd;
+	int ret = 0, i;
+	pgtable_t pgtable;
+	unsigned long haddr;
+
+	if (unlikely(address == -EFAULT))
+		goto out;
+	spin_lock(&mm->page_table_lock);
+	pmd = page_check_address_pmd_frozen(page, mm, address);
+	if (pmd) {
+		pgtable = get_pmd_huge_pte(mm);
+		pmd_populate(mm, &_pmd, pgtable);
+
+		for (i = 0, haddr = address; i < 1<<(HPAGE_SHIFT-PAGE_SHIFT);
+		     i++, haddr += PAGE_SIZE) {
+			pte_t *pte, entry;
+			entry = mk_pte(page + i, vma->vm_page_prot);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (!pmd_write(*pmd))
+				entry = pte_wrprotect(entry);
+			else
+				BUG_ON(page_mapcount(page) != 1);
+			if (!pmd_young(*pmd))
+				entry = pte_mkold(entry);
+			pte = pte_offset_map(&_pmd, haddr);
+			BUG_ON(!pte_none(*pte));
+			set_pte_at(mm, haddr, pte, entry);
+			pte_unmap(pte);
+		}
+
+		mm->nr_ptes++;
+		smp_wmb(); /* make pte visible before pmd */
+		pmd_populate(mm, pmd, pgtable);
+		ret = 1;
+	}
+	spin_unlock(&mm->page_table_lock);
+out:
+	return ret;
+}
+
+/* must be called with anon_vma->lock hold */
+static void __split_huge_page(struct page *page,
+			      struct anon_vma *anon_vma)
+{
+	int mapcount, mapcount2;
+	struct vm_area_struct *vma;
+
+	BUG_ON(!PageHead(page));
+
+	mapcount = 0;
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		mapcount += __split_huge_page_freeze(page, vma,
+						     vma_address(page, vma));
+	BUG_ON(mapcount != page_mapcount(page));
+
+	__split_huge_page_refcount(page);
+
+	mapcount2 = 0;
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		mapcount2 += __split_huge_page_map(page, vma,
+						   vma_address(page, vma));
+	BUG_ON(mapcount != mapcount2);
+}
+
+/* must run with mmap_sem to prevent vma to go away */
+void __split_huge_page_vma(struct vm_area_struct *vma, pmd_t *pmd)
+{
+	struct page *page;
+	struct anon_vma *anon_vma;
+	struct mm_struct *mm;
+
+	BUG_ON(vma->vm_flags & VM_HUGETLB);
+
+	mm = vma->vm_mm;
+	BUG_ON(down_write_trylock(&mm->mmap_sem));
+
+	anon_vma = vma->anon_vma;
+
+	spin_lock(&anon_vma->lock);
+	BUG_ON(pmd_trans_frozen(*pmd));
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_trans_huge(*pmd))) {
+		spin_unlock(&mm->page_table_lock);
+		spin_unlock(&anon_vma->lock);
+		return;
+	}
+	page = pmd_pgtable(*pmd);
+	spin_unlock(&mm->page_table_lock);
+
+	__split_huge_page(page, anon_vma);
+
+	spin_unlock(&anon_vma->lock);
+	BUG_ON(pmd_trans_huge(*pmd));
+}
+
+/* must run with mmap_sem to prevent vma to go away */
+void __split_huge_page_mm(struct mm_struct *mm,
+			  unsigned long address,
+			  pmd_t *pmd)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, address);
+	BUG_ON(vma->vm_start > address);
+	BUG_ON(vma->vm_mm != mm);
+
+	__split_huge_page_vma(vma, pmd);
+}
+
+int split_huge_page(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	int ret = 1;
+
+	BUG_ON(!PageAnon(page));
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		goto out;
+	ret = 0;
+	if (!PageCompound(page))
+		goto out_unlock;
+
+ 	BUG_ON(!PageSwapBacked(page));
+	__split_huge_page(page, anon_vma);
+
+	BUG_ON(PageCompound(page));
+out_unlock:
+	page_unlock_anon_vma(anon_vma);
+out:
+	return ret;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -55,17 +55,80 @@ static void __page_cache_release(struct 
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
+}
+
+static void __put_single_page(struct page *page)
+{
+	__page_cache_release(page);
 	free_hot_page(page);
 }
 
+static void __put_compound_page(struct page *page)
+{
+	compound_page_dtor *dtor;
+
+	__page_cache_release(page);
+	dtor = get_compound_page_dtor(page);
+	(*dtor)(page);
+}
+
 static void put_compound_page(struct page *page)
 {
-	page = compound_head(page);
-	if (put_page_testzero(page)) {
-		compound_page_dtor *dtor;
-
-		dtor = get_compound_page_dtor(page);
-		(*dtor)(page);
+	if (unlikely(PageTail(page))) {
+		/* __split_huge_page_refcount can run under us */
+		struct page *page_head = page->first_page;
+		smp_rmb();
+		if (likely(PageTail(page) && get_page_unless_zero(page_head))) {
+			if (unlikely(!PageHead(page_head))) {
+				/* PageHead is cleared after PageTail */
+				smp_rmb();
+				VM_BUG_ON(PageTail(page));
+				goto out_put_head;
+			}
+			/*
+			 * Only run compound_lock on a valid PageHead,
+			 * after having it pinned with
+			 * get_page_unless_zero() above.
+			 */
+			smp_mb();
+			/* page_head wasn't a dangling pointer */
+			compound_lock(page_head);
+			if (unlikely(!PageTail(page))) {
+				/* __split_huge_page_refcount run before us */
+				compound_unlock(page_head);
+			out_put_head:
+				put_page(page_head);
+			out_put_single:
+				if (put_page_testzero(page))
+					__put_single_page(page);
+				return;
+			}
+			VM_BUG_ON(page_head != page->first_page);
+			/*
+			 * We can release the refcount taken by
+			 * get_page_unless_zero now that
+			 * split_huge_page_refcount is blocked on the
+			 * compound_lock.
+			 */
+			if (put_page_testzero(page_head))
+				VM_BUG_ON(1);
+			/* __split_huge_page_refcount will wait now */
+			VM_BUG_ON(atomic_read(&page->_count) <= 0);
+			atomic_dec(&page->_count);
+			VM_BUG_ON(atomic_read(&page_head->_count) <= 0);
+			if (put_page_testzero(page_head))
+				__put_compound_page(page_head);
+			else
+				compound_unlock(page_head);
+			return;
+		} else
+			/* page_head is a dangling pointer */
+			goto out_put_single;
+	} else if (put_page_testzero(page)) {
+		if (PageHead(page))
+			__put_compound_page(page);
+		else
+			__put_single_page(page);
 	}
 }
 
@@ -74,7 +137,7 @@ void put_page(struct page *page)
 	if (unlikely(PageCompound(page)))
 		put_compound_page(page);
 	else if (put_page_testzero(page))
-		__page_cache_release(page);
+		__put_single_page(page);
 }
 EXPORT_SYMBOL(put_page);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -152,6 +152,10 @@ int add_to_swap(struct page *page)
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageUptodate(page));
 
+	if (unlikely(PageCompound(page)))
+		if (unlikely(split_huge_page(page)))
+			return 0;
+
 	entry = get_swap_page();
 	if (!entry.val)
 		return 0;
diff --git a/mm/swapfile.c b/mm/swapfile.c
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -896,6 +896,8 @@ static inline int unuse_pmd_range(struct
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (unlikely(pmd_trans_huge(*pmd)))
+			continue;
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
