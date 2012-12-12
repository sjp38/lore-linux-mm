Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4F56B6B0071
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 03:17:26 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 12 Dec 2012 18:12:25 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 365AF2BB004F
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 19:17:18 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBC8HHv241746658
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 19:17:17 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBC8HGSB000690
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 19:17:17 +1100
Date: Wed, 12 Dec 2012 16:17:14 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RFC v3] Support volatile range for anon vma
Message-ID: <20121212081714.GA26311@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1355193255-7217-1-git-send-email-minchan@kernel.org>
 <20121211024104.GA10523@blaptop>
 <20121212064349.GA18308@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121212064349.GA18308@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Dec 12, 2012 at 02:43:49PM +0800, Wanpeng Li wrote:
>On Tue, Dec 11, 2012 at 11:41:04AM +0900, Minchan Kim wrote:
>>Sorry, resending with fixing compile error. :(
>>
>>>From 0cfd3b65e4e90ab59abe8a337334414f92423cad Mon Sep 17 00:00:00 2001
>>From: Minchan Kim <minchan@kernel.org>
>>Date: Tue, 11 Dec 2012 11:38:30 +0900
>>Subject: [RFC v3] Support volatile range for anon vma
>>
>>This still is [RFC v3] because just passed my simple test
>>with TCMalloc tweaking.
>>
>>I hope more inputs from user-space allocator people and test patch
>>with their allocator because it might need design change of arena
>>management design for getting real vaule.
>>
>>Changelog from v2
>>
>> * Removing madvise(addr, length, MADV_NOVOLATILE).
>> * add vmstat about the number of discarded volatile pages
>> * discard volatile pages without promotion in reclaim path
>>
>>This is based on v3.6.
>>
>>- What's the madvise(addr, length, MADV_VOLATILE)?
>>
>>  It's a hint that user deliver to kernel so kernel can *discard*
>>  pages in a range anytime.
>>
>>- What happens if user access page(ie, virtual address) discarded
>>  by kernel?
>>
>>  The user can see zero-fill-on-demand pages as if madvise(DONTNEED).
>>
>>- What happens if user access page(ie, virtual address) doesn't
>>  discarded by kernel?
>>
>>  The user can see old data without page fault.
>>
>>- What's different with madvise(DONTNEED)?
>>
>>  System call semantic
>>
>>  DONTNEED makes sure user always can see zero-fill pages after
>>  he calls madvise while VOLATILE can see zero-fill pages or
>>  old data.
>>
>>  Internal implementation
>>
>>  The madvise(DONTNEED) should zap all mapped pages in range so
>>  overhead is increased linearly with the number of mapped pages.
>>  Even, if user access zapped pages by write, page fault + page
>>  allocation + memset should be happened.
>>
>>  The madvise(VOLATILE) should mark the flag in a range(ie, VMA).
>>  It doesn't touch pages any more so overhead of the system call
>>  should be very small. If memory pressure happens, VM can discard
>>  pages in VMAs marked by VOLATILE. If user access address with
>>  write mode by discarding by VM, he can see zero-fill pages so the
>>  cost is same with DONTNEED but if memory pressure isn't severe,
>>  user can see old data without (page fault + page allocation + memset)
>>
>>  The VOLATILE mark should be removed in page fault handler when first
>>  page fault occur in marked vma so next page faults will follow normal
>>  page fault path. That's why user don't need madvise(MADV_NOVOLATILE)
>>  interface.
>>
>>- What's the benefit compared to DONTNEED?
>>
>>  1. The system call overhead is smaller because VOLATILE just marks
>>     the flag to VMA instead of zapping all the page in a range.
>>
>>  2. It has a chance to eliminate overheads (ex, page fault +
>>     page allocation + memset(PAGE_SIZE)).
>>
>>- Isn't there any drawback?
>>
>>  DONTNEED doesn't need exclusive mmap_sem locking so concurrent page
>>  fault of other threads could be allowed. But VOLATILE needs exclusive
>>  mmap_sem so other thread would be blocked if they try to access
>>  not-mapped pages. That's why I designed madvise(VOLATILE)'s overhead
>>  should be small as far as possible.
>>
>>  Other concern of exclusive mmap_sem is when page fault occur in
>>  VOLATILE marked vma. We should remove the flag of vma and merge
>>  adjacent vmas so needs exclusive mmap_sem. It can slow down page fault
>>  handling and prevent concurrent page fault. But we need such handling
>>  just once when page fault occur after we mark VOLATILE into VMA
>>  only if memory pressure happpens so the page is discarded. So it wouldn't
>>  not common so that benefit we get by this feature would be bigger than
>>  lose.
>>
>>- What's for targetting?
>>
>>  Firstly, user-space allocator like ptmalloc, tcmalloc or heap management
>>  of virtual machine like Dalvik. Also, it comes in handy for embedded
>>  which doesn't have swap device so they can't reclaim anonymous pages.
>>  By discarding instead of swap, it could be used in the non-swap system.
>>  For it,  we have to age anon lru list although we don't have swap because
>>  I don't want to discard volatile pages by top priority when memory pressure
>>  happens as volatile in this patch means "We don't need to swap out because
>>  user can handle the situation which data are disappear suddenly", NOT
>>  "They are useless so hurry up to reclaim them". So I want to apply same
>>  aging rule of nomal pages to them.
>>
>>  Anonymous page background aging of non-swap system would be a trade-off
>>  for getting good feature. Even, we had done it two years ago until merge
>>  [1] and I believe gain of this patch will beat loss of anon lru aging's
>>  overead once all of allocator start to use madvise.
>>  (This patch doesn't include background aging in case of non-swap system
>>  but it's trivial if we decide)
>>
>>[1] 74e3f3c3, vmscan: prevent background aging of anon page in no swap system
>>
>>Cc: Michael Kerrisk <mtk.manpages@gmail.com>
>>Cc: Arun Sharma <asharma@fb.com>
>>Cc: sanjay@google.com
>>Cc: Paul Turner <pjt@google.com>
>>CC: David Rientjes <rientjes@google.com>
>>Cc: John Stultz <john.stultz@linaro.org>
>>Cc: Andrew Morton <akpm@linux-foundation.org>
>>Cc: Christoph Lameter <cl@linux.com>
>>Cc: Android Kernel Team <kernel-team@android.com>
>>Cc: Robert Love <rlove@google.com>
>>Cc: Mel Gorman <mel@csn.ul.ie>
>>Cc: Hugh Dickins <hughd@google.com>
>>Cc: Dave Hansen <dave@linux.vnet.ibm.com>
>>Cc: Rik van Riel <riel@redhat.com>
>>Cc: Dave Chinner <david@fromorbit.com>
>>Cc: Neil Brown <neilb@suse.de>
>>Cc: Mike Hommey <mh@glandium.org>
>>Cc: Taras Glek <tglek@mozilla.com>
>>Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>>Cc: Christoph Lameter <cl@linux.com>
>>Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>Signed-off-by: Minchan Kim <minchan@kernel.org>
>>---
>> arch/x86/mm/fault.c               |    2 +
>> include/asm-generic/mman-common.h |    6 ++
>> include/linux/mm.h                |    7 ++-
>> include/linux/rmap.h              |   20 ++++++
>> include/linux/vm_event_item.h     |    2 +-
>> mm/madvise.c                      |   19 +++++-
>> mm/memory.c                       |   32 ++++++++++
>> mm/migrate.c                      |    6 +-
>> mm/rmap.c                         |  125 ++++++++++++++++++++++++++++++++++++-
>> mm/vmscan.c                       |    7 +++
>> mm/vmstat.c                       |    1 +
>> 11 files changed, 218 insertions(+), 9 deletions(-)
>>
>>diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>>index 76dcd9d..17c1c20 100644
>>--- a/arch/x86/mm/fault.c
>>+++ b/arch/x86/mm/fault.c
>>@@ -879,6 +879,8 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
>> 		}
>>
>> 		out_of_memory(regs, error_code, address);
>>+	} else if (fault & VM_FAULT_SIGSEG) {
>>+			bad_area(regs, error_code, address);
>> 	} else {
>> 		if (fault & (VM_FAULT_SIGBUS|VM_FAULT_HWPOISON|
>> 			     VM_FAULT_HWPOISON_LARGE))
>>diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
>>index d030d2c..f07781e 100644
>>--- a/include/asm-generic/mman-common.h
>>+++ b/include/asm-generic/mman-common.h
>>@@ -34,6 +34,12 @@
>> #define MADV_SEQUENTIAL	2		/* expect sequential page references */
>> #define MADV_WILLNEED	3		/* will need these pages */
>> #define MADV_DONTNEED	4		/* don't need these pages */
>>+/*
>>+ * Unlike other flags, we need two locks to protect MADV_VOLATILE.
>>+ * For changing the flag, we need mmap_sem's write lock and volatile_lock
>>+ * while we just need volatile_lock in case of reading the flag.
>>+ */
>>+#define MADV_VOLATILE	5		/* pages will disappear suddenly */
>>
>> /* common parameters: try to keep these consistent across architectures */
>> #define MADV_REMOVE	9		/* remove these pages & resources */
>>diff --git a/include/linux/mm.h b/include/linux/mm.h
>>index 311be90..89027b5 100644
>>--- a/include/linux/mm.h
>>+++ b/include/linux/mm.h
>>@@ -119,6 +119,7 @@ extern unsigned int kobjsize(const void *objp);
>> #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
>> #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
>> #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
>>+#define VM_VOLATILE	0x100000000	/* Pages in the vma could be discarable without swap */
>>
>> /* Bits set in the VMA until the stack is in its final location */
>> #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
>>@@ -143,7 +144,7 @@ extern unsigned int kobjsize(const void *objp);
>>  * Special vmas that are non-mergable, non-mlock()able.
>>  * Note: mm/huge_memory.c VM_NO_THP depends on this definition.
>>  */
>>-#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP)
>>+#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_RESERVED | VM_PFNMAP | VM_VOLATILE)
>>
>> /*
>>  * mapping from the currently active vm_flags protection bits (the
>>@@ -872,11 +873,11 @@ static inline int page_mapped(struct page *page)
>> #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
>> #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
>> #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
>>-
>>+#define VM_FAULT_SIGSEG	0x0800	/* -> There is no vma */
>> #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
>>
>> #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON | \
>>-			 VM_FAULT_HWPOISON_LARGE)
>>+			 VM_FAULT_HWPOISON_LARGE | VM_FAULT_SIGSEG)
>>
>> /* Encode hstate index for a hwpoisoned large page */
>> #define VM_FAULT_SET_HINDEX(x) ((x) << 12)
>>diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>>index 3fce545..735d7a3 100644
>>--- a/include/linux/rmap.h
>>+++ b/include/linux/rmap.h
>>@@ -67,6 +67,9 @@ struct anon_vma_chain {
>> 	struct list_head same_anon_vma;	/* locked by anon_vma->mutex */
>> };
>>
>>+void volatile_lock(struct vm_area_struct *vma);
>>+void volatile_unlock(struct vm_area_struct *vma);
>>+
>> #ifdef CONFIG_MMU
>> static inline void get_anon_vma(struct anon_vma *anon_vma)
>> {
>>@@ -170,6 +173,7 @@ enum ttu_flags {
>> 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
>> 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
>> 	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
>>+	TTU_IGNORE_VOLATILE = (1 << 11),/* ignore volatile */
>> };
>> #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
>>
>>@@ -194,6 +198,21 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
>> 	return ptep;
>> }
>>
>>+pte_t *__page_check_volatile_address(struct page *, struct mm_struct *,
>>+                                unsigned long, spinlock_t **);
>>+
>>+static inline pte_t *page_check_volatile_address(struct page *page,
>>+                                        struct mm_struct *mm,
>>+                                        unsigned long address,
>>+                                        spinlock_t **ptlp)
>>+{
>>+        pte_t *ptep;
>>+
>>+        __cond_lock(*ptlp, ptep = __page_check_volatile_address(page,
>>+                                        mm, address, ptlp));
>>+        return ptep;
>>+}
>>+
>> /*
>>  * Used by swapoff to help locate where page is expected in vma.
>>  */
>>@@ -257,5 +276,6 @@ static inline int page_mkclean(struct page *page)
>> #define SWAP_AGAIN	1
>> #define SWAP_FAIL	2
>> #define SWAP_MLOCK	3
>>+#define SWAP_DISCARD	4
>>
>> #endif	/* _LINUX_RMAP_H */
>>diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
>>index 57f7b10..3f9a40b 100644
>>--- a/include/linux/vm_event_item.h
>>+++ b/include/linux/vm_event_item.h
>>@@ -23,7 +23,7 @@
>>
>> enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>> 		FOR_ALL_ZONES(PGALLOC),
>>-		PGFREE, PGACTIVATE, PGDEACTIVATE,
>>+		PGFREE, PGVOLATILE, PGACTIVATE, PGDEACTIVATE,
>> 		PGFAULT, PGMAJFAULT,
>> 		FOR_ALL_ZONES(PGREFILL),
>> 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
>>diff --git a/mm/madvise.c b/mm/madvise.c
>>index 14d260f..53a19d8 100644
>>--- a/mm/madvise.c
>>+++ b/mm/madvise.c
>>@@ -86,6 +86,13 @@ static long madvise_behavior(struct vm_area_struct * vma,
>> 		if (error)
>> 			goto out;
>> 		break;
>>+	case MADV_VOLATILE:
>>+		if (vma->vm_flags & VM_LOCKED) {
>>+			error = -EINVAL;
>>+			goto out;
>>+		}
>>+		new_flags |= VM_VOLATILE;
>>+		break;
>> 	}
>>
>> 	if (new_flags == vma->vm_flags) {
>>@@ -118,9 +125,13 @@ static long madvise_behavior(struct vm_area_struct * vma,
>> success:
>> 	/*
>> 	 * vm_flags is protected by the mmap_sem held in write mode.
>>+	 * In caes of MADV_VOLATILE, we need anon_vma_lock additionally.
>> 	 */
>>+	if (behavior == MADV_VOLATILE)
>>+		volatile_lock(vma);
>> 	vma->vm_flags = new_flags;
>>-
>>+	if (behavior == MADV_VOLATILE)
>>+		volatile_unlock(vma);
>> out:
>> 	if (error == -ENOMEM)
>> 		error = -EAGAIN;
>>@@ -310,6 +321,7 @@ madvise_behavior_valid(int behavior)
>> #endif
>> 	case MADV_DONTDUMP:
>> 	case MADV_DODUMP:
>>+	case MADV_VOLATILE:
>> 		return 1;
>>
>> 	default:
>>@@ -385,6 +397,11 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>> 		goto out;
>> 	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
>>
>>+	if (behavior != MADV_VOLATILE)
>>+		len = (len_in + ~PAGE_MASK) & PAGE_MASK;
>>+	else
>>+		len = len_in & PAGE_MASK;
>>+
>> 	/* Check to see whether len was rounded up from small -ve to zero */
>> 	if (len_in && !len)
>> 		goto out;
>>diff --git a/mm/memory.c b/mm/memory.c
>>index 5736170..b5e4996 100644
>>--- a/mm/memory.c
>>+++ b/mm/memory.c
>>@@ -57,6 +57,7 @@
>> #include <linux/swapops.h>
>> #include <linux/elf.h>
>> #include <linux/gfp.h>
>>+#include <linux/mempolicy.h>
>>
>> #include <asm/io.h>
>> #include <asm/pgalloc.h>
>>@@ -3446,6 +3447,37 @@ int handle_pte_fault(struct mm_struct *mm,
>> 					return do_linear_fault(mm, vma, address,
>> 						pte, pmd, flags, entry);
>> 			}
>>+			if (vma->vm_flags & VM_VOLATILE) {
>>+				struct vm_area_struct *prev;
>>+
>>+				up_read(&mm->mmap_sem);
>>+				down_write(&mm->mmap_sem);
>>+				vma = find_vma_prev(mm, address, &prev);
>>+
>>+				/* Someone unmap the vma */
>>+				if (unlikely(!vma) || vma->vm_start > address) {
>>+					downgrade_write(&mm->mmap_sem);
>>+					return VM_FAULT_SIGSEG;
>>+				}
>>+				/* Someone else already hanlded */
>>+				if (vma->vm_flags & VM_VOLATILE) {
>>+					/*
>>+					 * From now on, we hold mmap_sem as
>>+					 * exclusive.
>>+					 */
>>+					volatile_lock(vma);
>>+					vma->vm_flags &= ~VM_VOLATILE;
>>+					volatile_unlock(vma);
>>+
>>+					vma_merge(mm, prev, vma->vm_start,
>>+						vma->vm_end, vma->vm_flags,
>>+						vma->anon_vma, vma->vm_file,
>>+						vma->vm_pgoff, vma_policy(vma));
>>+
>>+				}
>>+
>>+				downgrade_write(&mm->mmap_sem);
>>+			}
>> 			return do_anonymous_page(mm, vma, address,
>> 						 pte, pmd, flags);
>> 		}
>>diff --git a/mm/migrate.c b/mm/migrate.c
>>index 77ed2d7..08b009c 100644
>>--- a/mm/migrate.c
>>+++ b/mm/migrate.c
>>@@ -800,7 +800,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>> 	}
>>
>> 	/* Establish migration ptes or remove ptes */
>>-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>>+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|
>>+				TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
>>
>> skip_unmap:
>> 	if (!page_mapped(page))
>>@@ -915,7 +916,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>> 	if (PageAnon(hpage))
>> 		anon_vma = page_get_anon_vma(hpage);
>>
>>-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>>+	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|
>>+				TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
>>
>> 	if (!page_mapped(hpage))
>> 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
>>diff --git a/mm/rmap.c b/mm/rmap.c
>>index 0f3b7cd..1a0ab2b 100644
>>--- a/mm/rmap.c
>>+++ b/mm/rmap.c
>>@@ -603,6 +603,57 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
>> 	return vma_address(page, vma);
>> }
>>
>>+pte_t *__page_check_volatile_address(struct page *page, struct mm_struct *mm,
>>+		unsigned long address, spinlock_t **ptlp)
>>+{
>>+	pgd_t *pgd;
>>+	pud_t *pud;
>>+	pmd_t *pmd;
>>+	pte_t *pte;
>>+	spinlock_t *ptl;
>>+
>>+	swp_entry_t entry = { .val = page_private(page) };
>>+
>>+	if (unlikely(PageHuge(page))) {
>>+		pte = huge_pte_offset(mm, address);
>>+		ptl = &mm->page_table_lock;
>>+		goto check;
>>+	}
>>+
>>+	pgd = pgd_offset(mm, address);
>>+	if (!pgd_present(*pgd))
>>+		return NULL;
>>+
>>+	pud = pud_offset(pgd, address);
>>+	if (!pud_present(*pud))
>>+		return NULL;
>>+
>>+	pmd = pmd_offset(pud, address);
>>+	if (!pmd_present(*pmd))
>>+		return NULL;
>>+	if (pmd_trans_huge(*pmd))
>>+		return NULL;
>>+
>>+	pte = pte_offset_map(pmd, address);
>>+	ptl = pte_lockptr(mm, pmd);
>>+check:
>>+	spin_lock(ptl);
>>+	if (PageAnon(page)) {
>>+		if (!pte_present(*pte) && entry.val ==
>>+				pte_to_swp_entry(*pte).val) {
>>+			*ptlp = ptl;
>>+			return pte;
>>+		}
>>+	} else {
>>+		if (pte_none(*pte)) {
>>+			*ptlp = ptl;
>>+			return pte;
>>+		}
>>+	}
>>+	pte_unmap_unlock(pte, ptl);
>>+	return NULL;
>>+}
>>+
>> /*
>>  * Check that @page is mapped at @address into @mm.
>>  *
>>@@ -1218,6 +1269,35 @@ out:
>> 		mem_cgroup_end_update_page_stat(page, &locked, &flags);
>> }
>>
>>+int try_to_zap_one(struct page *page, struct vm_area_struct *vma,
>>+                unsigned long address)
>>+{
>>+        struct mm_struct *mm = vma->vm_mm;
>>+        pte_t *pte;
>>+        pte_t pteval;
>>+        spinlock_t *ptl;
>>+
>>+        pte = page_check_volatile_address(page, mm, address, &ptl);
>>+        if (!pte)
>>+                return 0;
>>+
>>+        /* Nuke the page table entry. */
>>+        flush_cache_page(vma, address, page_to_pfn(page));
>>+        pteval = ptep_clear_flush(vma, address, pte);
>>+
>>+        if (PageAnon(page)) {
>>+                swp_entry_t entry = { .val = page_private(page) };
>>+                if (PageSwapCache(page)) {
>>+                        dec_mm_counter(mm, MM_SWAPENTS);
>>+                        swap_free(entry);
>>+                }
>>+        }
>>+
>>+        pte_unmap_unlock(pte, ptl);
>>+        mmu_notifier_invalidate_page(mm, address);
>>+        return 1;
>>+}
>>+
>> /*
>>  * Subfunctions of try_to_unmap: try_to_unmap_one called
>>  * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
>>@@ -1494,6 +1574,10 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
>> 	struct anon_vma *anon_vma;
>> 	struct anon_vma_chain *avc;
>> 	int ret = SWAP_AGAIN;
>>+	bool is_volatile = true;
>>+
>>+	if (flags & TTU_IGNORE_VOLATILE)
>>+		is_volatile = false;
>>
>> 	anon_vma = page_lock_anon_vma(page);
>> 	if (!anon_vma)
>>@@ -1512,17 +1596,40 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
>> 		 * temporary VMAs until after exec() completes.
>> 		 */
>> 		if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
>>-				is_vma_temporary_stack(vma))
>>+				is_vma_temporary_stack(vma)) {
>>+			is_volatile = false;
>> 			continue;
>>+		}
>>
>> 		address = vma_address(page, vma);
>> 		if (address == -EFAULT)
>> 			continue;
>>+                /*
>>+                 * A volatile page will only be purged if ALL vmas
>>+		 * pointing to it are VM_VOLATILE.
>>+                 */
>>+                if (!(vma->vm_flags & VM_VOLATILE))
>>+                        is_volatile = false;
>>+
>> 		ret = try_to_unmap_one(page, vma, address, flags);
>> 		if (ret != SWAP_AGAIN || !page_mapped(page))
>> 			break;
>> 	}
>>
>>+        if (page_mapped(page) || is_volatile == false)
>>+                goto out;
>>+
>>+        list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
>>+                struct vm_area_struct *vma = avc->vma;
>>+                unsigned long address;
>>+
>>+                address = vma_address(page, vma);
>>+                try_to_zap_one(page, vma, address);
>>+        }
>>+        /* We're throwing this page out, so mark it clean */
>>+        ClearPageDirty(page);
>>+        ret = SWAP_DISCARD;
>>+out:
>> 	page_unlock_anon_vma(anon_vma);
>> 	return ret;
>> }
>>@@ -1651,6 +1758,7 @@ out:
>>  * SWAP_AGAIN	- we missed a mapping, try again later
>>  * SWAP_FAIL	- the page is unswappable
>>  * SWAP_MLOCK	- page is mlocked.
>>+ * SWAP_DISCARD - page is volatile.
>>  */
>> int try_to_unmap(struct page *page, enum ttu_flags flags)
>> {
>>@@ -1665,7 +1773,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>> 		ret = try_to_unmap_anon(page, flags);
>> 	else
>> 		ret = try_to_unmap_file(page, flags);
>>-	if (ret != SWAP_MLOCK && !page_mapped(page))
>>+	if (ret != SWAP_MLOCK && !page_mapped(page) &&
>>+					ret != SWAP_DISCARD)
>> 		ret = SWAP_SUCCESS;
>> 	return ret;
>> }
>>@@ -1707,6 +1816,18 @@ void __put_anon_vma(struct anon_vma *anon_vma)
>> 	anon_vma_free(anon_vma);
>> }
>>
>>+void volatile_lock(struct vm_area_struct *vma)
>>+{
>>+        if (vma->anon_vma)
>>+                anon_vma_lock(vma->anon_vma);
>>+}
>>+
>>+void volatile_unlock(struct vm_area_struct *vma)
>>+{
>>+        if (vma->anon_vma)
>>+                anon_vma_unlock(vma->anon_vma);
>>+}
>>+
>> #ifdef CONFIG_MIGRATION
>> /*
>>  * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
>>diff --git a/mm/vmscan.c b/mm/vmscan.c
>>index 99b434b..4e463a4 100644
>>--- a/mm/vmscan.c
>>+++ b/mm/vmscan.c
>>@@ -630,6 +630,9 @@ static enum page_references page_check_references(struct page *page,
>> 	if (vm_flags & VM_LOCKED)
>> 		return PAGEREF_RECLAIM;
>>
>>+	if (vm_flags & VM_VOLATILE)
>>+		return PAGEREF_RECLAIM;
>>+
>> 	if (referenced_ptes) {
>> 		if (PageSwapBacked(page))
>> 			return PAGEREF_ACTIVATE;
>>@@ -789,6 +792,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>> 		 */
>
>Hi Minchan,
>
>IIUC, anonymous page has already add to swapcache through add_to_swap called
>by shrink_page_list, but I can't figure out where you remove it from swapache.
>

Yeah, they all done in shrink_page_list, I mean if you can avoid the process of 
add to swapcache and remove it from swapcache since your idea don't need swapout.

>Regards,
>Wanpeng Li 
>
>> 		if (page_mapped(page) && mapping) {
>> 			switch (try_to_unmap(page, TTU_UNMAP)) {
>>+			case SWAP_DISCARD:
>>+				count_vm_event(PGVOLATILE);
>>+				goto discard_page;
>> 			case SWAP_FAIL:
>> 				goto activate_locked;
>> 			case SWAP_AGAIN:
>>@@ -857,6 +863,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>> 			}
>> 		}
>>
>>+discard_page:
>> 		/*
>> 		 * If the page has buffers, try to free the buffer mappings
>> 		 * associated with this page. If we succeed we try to free
>>diff --git a/mm/vmstat.c b/mm/vmstat.c
>>index df7a674..410caf5 100644
>>--- a/mm/vmstat.c
>>+++ b/mm/vmstat.c
>>@@ -734,6 +734,7 @@ const char * const vmstat_text[] = {
>> 	TEXTS_FOR_ZONES("pgalloc")
>>
>> 	"pgfree",
>>+	"pgvolatile",
>> 	"pgactivate",
>> 	"pgdeactivate",
>>
>>-- 
>>1.7.9.5
>>
>>-- 
>>Kind regards,
>>Minchan Kim
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
