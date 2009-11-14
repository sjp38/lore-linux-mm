Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9886F6B009C
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:27 -0500 (EST)
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAPYk010606
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:26 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 24 of 25] transparent hugepage core
Message-Id: <b3f569d345255caf6b11.1258220322@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:42 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

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

4) avoidance of reservation and maximization of use of hugepages whenever
   possible. Reservation (needed to avoid runtime fatal faliures) may be ok for
   1 machine with 1 database with 1 database cache with 1 database cache size
   known at boot time. It's definitely not feasible with a virtualization
   hypervisor usage like RHEV-H that runs an unknown number of virtual machines
   with an unknown size of each virtual machine with an unknown amount of
   pagecache that could be potentially useful in the host for guest not using
   O_DIRECT (aka cache=off).

hugepages in the virtualization hypervisor (and also in the guest!) are
much more important than in a regular host not using virtualization, becasue
with NPT/EPT they decrease the tlb-miss cacheline accesses from 16 to 12 in
case only the hypervisor uses transparent hugepages, and they decrease the
tlb-miss cacheline accesses from 16 to 9 in case both the linux hypervisor and
the linux guest both uses this patch (though the guest will limit the addition
speedup to anonymous regions only for now...).  Even more important is that the
tlb miss handler is much slower on a NPT/EPT guest than for a regular shadow
paging or no-virtualization scenario. So maximizing the amount of virtual
memory cached by the TLB pays off significantly more with NPT/EPT than without
(even if there would be no significant speedup in the tlb-miss runtime).

The first (and more tedious) part of this work requires allowing the VM to
handle anonymous hugepages mixed with regular pages transparently on regular
anonymous vmas. This is what this patch tries to achieve in the least intrusive
possible way. We want hugepages and hugetlb to be used in a way so that all
applications can benefit without changes (as usual we leverage the KVM
virtualization design: by improving the Linux VM at large, KVM gets the
performance boost too).

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

Swap and oom works fine (well just like with regular pages ;). MMU
notifier is handled transparently too, with the exception of the young
bit on the pmd, that didn't have a range check but I think KVM will be
fine because the whole point of hugepages is that EPT/NPT will also
use a huge pmd when they notice gup returns pages with PageCompound set,
so they won't care of a range and there's just the pmd young bit to
check in that case.

NOTE: in some cases if the L2 cache is small, this may slowdown and
waste memory during COWs because 4M of memory are accessed in a single
fault instead of 8k (the payoff is that after COW the program can run
faster). So we might want to switch the copy_huge_page (and
clear_huge_page too) to not temporal stores. I also extensively
researched ways to avoid this cache trashing with a full prefault
logic that would cow in 8k/16k/32k/64k up to 1M (I can send those
patches that fully implemented prefault) but I concluded they're not
worth it and they add an huge additional complexity and they remove all tlb
benefits until the full hugepage has been faulted in, to save a little bit of
memory and some cache during app startup, but they still don't improve
substantially the cache-trashing during startup if the prefault happens in >4k
chunks.  One reason is that those 4k pte entries copied are still mapped on a
perfectly cache-colored hugepage, so the trashing is the worst one can generate
in those copies (cow of 4k page copies aren't so well colored so they trashes
less, but again this results in software running faster after the page fault).
Those prefault patches allowed things like a pte where post-cow pages were
local 4k regular anon pages and the not-yet-cowed pte entries were pointing in
the middle of some hugepage mapped read-only. If it doesn't payoff
substantially with todays hardware it will payoff even less in the future with
larger l2 caches, and the prefault logic would blot the VM a lot. If one is
emebdded and can't handle the sysctl to be 1 by default because of cache
trashing effects during page faults, it is simple enough to just disable
transparent hugepage globally and let transparent hugepages be allocated
selectively by applications in the MADV_HUGEPAGE region (both at page fault
time, and if enabled with the collapse_huge_page too through the kernel
daemon).

This patch supports only hugepages mapped in the pmd, archs that have
smaller hugepages will not fit in this patch alone. Also some archs like power
have certain tlb limits that prevents mixing different page size in the same
regions so they will not fit in this framework that requires "graceful
fallback" to basic PAGE_SIZE in case of physical memory fragmentation.
hugetlbfs remains a perfect fit for those because its software limits happen to
match the hardware limits. hugetlbfs also remains a perfect fit for hugepage
sizes like 1GByte that cannot be hoped to be found not fragmented after a
certain system uptime and that would be very expensive to defragment with
relocation, so requiring reservation. hugetlbfs is the "reservation way", the
point of transparent hugepages is not to have any reservation at all and
maximizing the use of cache and hugepages at all times automatically.

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

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -833,6 +833,69 @@ int invalidate_inode_page(struct page *p
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
+extern int zap_pmd_trans_huge(struct mmu_gather *tlb,
+			      struct vm_area_struct *vma,
+			      pmd_t *pmd);
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
+#define HPAGE_ORDER (HPAGE_SHIFT-PAGE_SHIFT)
+#define HPAGE_NR (1<<HPAGE_ORDER)
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
@@ -0,0 +1,408 @@
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
+#include <asm/tlb.h>
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
+				   HPAGE_ORDER);
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
+	add_mm_counter(dst_mm, anon_rss, HPAGE_NR);
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
+			      HPAGE_ORDER);
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
+		pages = kzalloc(sizeof(struct page *) * HPAGE_NR,
+				GFP_KERNEL);
+		if (unlikely(!pages)) {
+			ret |= VM_FAULT_OOM;
+			goto out;
+		}
+		
+		for (i = 0; i < HPAGE_NR; i++) {
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
+		for (i = 0; i < HPAGE_NR; i++) {
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
+		for (i = 0; i < HPAGE_NR;
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
+	for (i = 0; i < HPAGE_NR; i++)
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
+
+int zap_pmd_trans_huge(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		       pmd_t *pmd)
+{
+	int ret = 0;
+
+	spin_lock(&tlb->mm->page_table_lock);
+	if (likely(pmd_trans_huge(*pmd))) {
+		if (unlikely(pmd_trans_frozen(*pmd))) {
+			spin_unlock(&tlb->mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma,
+					     pmd);
+		} else {
+			struct page *page;
+			pgtable_t pgtable;
+			pgtable = get_pmd_huge_pte(tlb->mm);
+			page = pfn_to_page(pmd_pfn(*pmd));
+			VM_BUG_ON(!PageCompound(page));
+			pmd_clear(pmd);
+			spin_unlock(&tlb->mm->page_table_lock);
+			page_remove_rmap(page);
+			VM_BUG_ON(page_mapcount(page) < 0);
+			add_mm_counter(tlb->mm, anon_rss, -HPAGE_NR);
+			tlb_remove_page(tlb, page);
+			pte_free(tlb->mm, pgtable);
+			ret = 1;
+		}
+	} else
+		spin_unlock(&tlb->mm->page_table_lock);
+
+	return ret;
+}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -644,9 +644,9 @@ out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
+int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		   pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		   unsigned long addr, unsigned long end)
 {
 	pte_t *orig_src_pte, *orig_dst_pte;
 	pte_t *src_pte, *dst_pte;
@@ -709,6 +709,16 @@ static inline int copy_pmd_range(struct 
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
@@ -905,6 +915,15 @@ static inline unsigned long zap_pmd_rang
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (pmd_trans_huge(*pmd)) {
+			if (next-addr != HPAGE_SIZE)
+				split_huge_page_vma(vma, pmd);
+			else if (zap_pmd_trans_huge(tlb, vma, pmd)) {
+				(*zap_work)--;
+				continue;
+			}
+			/* fall through */
+		}
 		if (pmd_none_or_clear_bad(pmd)) {
 			(*zap_work)--;
 			continue;
@@ -1170,11 +1189,27 @@ struct page *follow_page(struct vm_area_
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
 
@@ -1283,6 +1318,7 @@ int __get_user_pages(struct task_struct 
 			pmd = pmd_offset(pud, pg);
 			if (pmd_none(*pmd))
 				return i ? : -EFAULT;
+			VM_BUG_ON(pmd_trans_huge(*pmd));
 			pte = pte_offset_map(pmd, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
@@ -2924,9 +2960,9 @@ static int do_nonlinear_fault(struct mm_
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
@@ -3002,6 +3038,22 @@ int handle_mm_fault(struct mm_struct *mm
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
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
 	pte = pte_alloc_map(mm, vma, pmd, address);
 	if (!pte)
 		return VM_FAULT_OOM;
@@ -3142,6 +3194,7 @@ static int follow_pte(struct mm_struct *
 		goto out;
 
 	pmd = pmd_offset(pud, address);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -382,39 +382,21 @@ static int page_referenced_one(struct pa
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
@@ -423,9 +405,42 @@ static int page_referenced_one(struct pa
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
@@ -1285,3 +1300,221 @@ int try_to_munlock(struct page *page)
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
+	for (i = 1; i < HPAGE_NR; i++) {
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
+		for (i = 0, haddr = address; i < HPAGE_NR;
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
