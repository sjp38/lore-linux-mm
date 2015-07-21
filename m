Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id B22099003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:59:47 -0400 (EDT)
Received: by qkfc129 with SMTP id c129so97601524qkf.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 12:59:47 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id k9si7535028qgk.87.2015.07.21.12.59.42
        for <linux-mm@kvack.org>;
        Tue, 21 Jul 2015 12:59:43 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH V4 4/6] mm: mlock: Introduce VM_LOCKONFAULT and add mlock flags to enable it
Date: Tue, 21 Jul 2015 15:59:39 -0400
Message-Id: <1437508781-28655-5-git-send-email-emunson@akamai.com>
In-Reply-To: <1437508781-28655-1-git-send-email-emunson@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

The cost of faulting in all memory to be locked can be very high when
working with large mappings.  If only portions of the mapping will be
used this can incur a high penalty for locking.

For the example of a large file, this is the usage pattern for a large
statical language model (probably applies to other statical or graphical
models as well).  For the security example, any application transacting
in data that cannot be swapped out (credit card data, medical records,
etc).

This patch introduces the ability to request that pages are not
pre-faulted, but are placed on the unevictable LRU when they are finally
faulted in.  This can be done area at a time via the
mlock2(MLOCK_ONFAULT) or the mlockall(MCL_ONFAULT) system calls.  These
calls can be undone via munlock2(MLOCK_ONFAULT) or
munlockall2(MCL_ONFAULT).

Applying the VM_LOCKONFAULT flag to a mapping with pages that are
already present required the addition of a function in gup.c to pin all
pages which are present in an address range.  It borrows heavily from
__mm_populate().

To keep accounting checks out of the page fault path, users are billed
for the entire mapping lock as if MLOCK_LOCKED was used.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org
Cc: linux-api@vger.kernel.org
---
Changes from V3:
Do extensive search for VM_LOCKED and ensure that VM_LOCKONFAULT is also handled
 where appropriate

 arch/alpha/include/uapi/asm/mman.h   |  2 +
 arch/mips/include/uapi/asm/mman.h    |  2 +
 arch/parisc/include/uapi/asm/mman.h  |  2 +
 arch/powerpc/include/uapi/asm/mman.h |  2 +
 arch/sparc/include/uapi/asm/mman.h   |  2 +
 arch/tile/include/uapi/asm/mman.h    |  3 ++
 arch/xtensa/include/uapi/asm/mman.h  |  2 +
 drivers/gpu/drm/drm_vm.c             |  8 ++-
 fs/proc/task_mmu.c                   |  3 +-
 include/linux/mm.h                   |  2 +
 include/uapi/asm-generic/mman.h      |  2 +
 kernel/events/uprobes.c              |  2 +-
 kernel/fork.c                        |  2 +-
 mm/debug.c                           |  1 +
 mm/gup.c                             |  3 +-
 mm/huge_memory.c                     |  3 +-
 mm/hugetlb.c                         |  4 +-
 mm/internal.h                        |  5 +-
 mm/ksm.c                             |  2 +-
 mm/madvise.c                         |  4 +-
 mm/memory.c                          |  5 +-
 mm/mlock.c                           | 98 +++++++++++++++++++++++++-----------
 mm/mmap.c                            | 28 +++++++----
 mm/mremap.c                          |  6 +--
 mm/msync.c                           |  2 +-
 mm/rmap.c                            | 12 ++---
 mm/shmem.c                           |  2 +-
 mm/swap.c                            |  3 +-
 mm/vmscan.c                          |  2 +-
 29 files changed, 145 insertions(+), 69 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/uapi/asm/mman.h
index ec72436..77ae8db 100644
--- a/arch/alpha/include/uapi/asm/mman.h
+++ b/arch/alpha/include/uapi/asm/mman.h
@@ -37,8 +37,10 @@
 
 #define MCL_CURRENT	 8192		/* lock all currently mapped pages */
 #define MCL_FUTURE	16384		/* lock all additions to address space */
+#define MCL_ONFAULT	32768		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi/asm/mman.h
index 67c1cdf..71ed81d 100644
--- a/arch/mips/include/uapi/asm/mman.h
+++ b/arch/mips/include/uapi/asm/mman.h
@@ -61,11 +61,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/uapi/asm/mman.h
index daab994..c0871ce 100644
--- a/arch/parisc/include/uapi/asm/mman.h
+++ b/arch/parisc/include/uapi/asm/mman.h
@@ -31,8 +31,10 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL     0               /* no further special treatment */
 #define MADV_RANDOM     1               /* expect random page references */
diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 189e85f..f93f7eb 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -22,8 +22,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/uapi/asm/mman.h
index 13d51be..8cd2ebc 100644
--- a/arch/sparc/include/uapi/asm/mman.h
+++ b/arch/sparc/include/uapi/asm/mman.h
@@ -17,8 +17,10 @@
 
 #define MCL_CURRENT     0x2000          /* lock all currently mapped pages */
 #define MCL_FUTURE      0x4000          /* lock all additions to address space */
+#define MCL_ONFAULT	0x8000		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi/asm/mman.h
index f69ce48..acdd013 100644
--- a/arch/tile/include/uapi/asm/mman.h
+++ b/arch/tile/include/uapi/asm/mman.h
@@ -36,11 +36,14 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
+
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 
 #endif /* _ASM_TILE_MMAN_H */
diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index 11f354f..5725a15 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -74,11 +74,13 @@
  */
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 /*
  * Flags for mlock
  */
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #define MADV_NORMAL	0		/* no further special treatment */
 #define MADV_RANDOM	1		/* expect random page references */
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index aab49ee..dfbcfc2 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -699,9 +699,15 @@ int drm_vma_info(struct seq_file *m, void *data)
 		   (void *)(unsigned long)virt_to_phys(high_memory));
 
 	list_for_each_entry(pt, &dev->vmalist, head) {
+		char lock_flag = '-';
+
 		vma = pt->vma;
 		if (!vma)
 			continue;
+		if (vma->vm_flags & VM_LOCKED)
+			lock_flag = 'l';
+		else if (vma->vm_flags & VM_LOCKONFAULT)
+			lock_flag = 'f';
 		seq_printf(m,
 			   "\n%5d 0x%pK-0x%pK %c%c%c%c%c%c 0x%08lx000",
 			   pt->pid,
@@ -710,7 +716,7 @@ int drm_vma_info(struct seq_file *m, void *data)
 			   vma->vm_flags & VM_WRITE ? 'w' : '-',
 			   vma->vm_flags & VM_EXEC ? 'x' : '-',
 			   vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
-			   vma->vm_flags & VM_LOCKED ? 'l' : '-',
+			   lock_flag,
 			   vma->vm_flags & VM_IO ? 'i' : '-',
 			   vma->vm_pgoff);
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ca1e091..2c435a7 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -579,6 +579,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 #ifdef CONFIG_X86_INTEL_MPX
 		[ilog2(VM_MPX)]		= "mp",
 #endif
+		[ilog2(VM_LOCKONFAULT)]	= "lf",
 		[ilog2(VM_LOCKED)]	= "lo",
 		[ilog2(VM_IO)]		= "io",
 		[ilog2(VM_SEQ_READ)]	= "sr",
@@ -654,7 +655,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.swap >> 10,
 		   vma_kernel_pagesize(vma) >> 10,
 		   vma_mmu_pagesize(vma) >> 10,
-		   (vma->vm_flags & VM_LOCKED) ?
+		   (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
 	show_smap_vma_flags(m, vma);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f9..e78544f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -127,6 +127,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
+#define VM_LOCKONFAULT	0x00001000	/* Lock the pages covered when they are faulted in */
 #define VM_LOCKED	0x00002000
 #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
 
@@ -1865,6 +1866,7 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
 	/* Ignore errors */
 	(void) __mm_populate(addr, len, 1);
 }
+extern int mm_lock_present(unsigned long addr, unsigned long start);
 #else
 static inline void mm_populate(unsigned long addr, unsigned long len) {}
 #endif
diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
index 242436b..555aab0 100644
--- a/include/uapi/asm-generic/mman.h
+++ b/include/uapi/asm-generic/mman.h
@@ -17,7 +17,9 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_ONFAULT	4		/* lock all pages that are faulted in */
 
 #define MLOCK_LOCKED	0x01		/* Lock and populate the specified range */
+#define MLOCK_ONFAULT	0x02		/* Lock pages in range after they are faulted in, do not prefault */
 
 #endif /* __ASM_GENERIC_MMAN_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index cb346f2..882c9f6 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -201,7 +201,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		try_to_free_swap(page);
 	pte_unmap_unlock(ptep, ptl);
 
-	if (vma->vm_flags & VM_LOCKED)
+	if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))
 		munlock_vma_page(page);
 	put_page(page);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index dbd9b8d..a949228 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -454,7 +454,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~VM_LOCKED;
+		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {
diff --git a/mm/debug.c b/mm/debug.c
index 76089dd..25176bb 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -121,6 +121,7 @@ static const struct trace_print_flags vmaflags_names[] = {
 	{VM_GROWSDOWN,			"growsdown"	},
 	{VM_PFNMAP,			"pfnmap"	},
 	{VM_DENYWRITE,			"denywrite"	},
+	{VM_LOCKONFAULT,		"lockonfault"	},
 	{VM_LOCKED,			"locked"	},
 	{VM_IO,				"io"		},
 	{VM_SEQ_READ,			"seqread"	},
diff --git a/mm/gup.c b/mm/gup.c
index 233ef17..097a22a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -92,7 +92,8 @@ retry:
 		 */
 		mark_page_accessed(page);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_POPULATE) &&
+	    (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))) {
 		/*
 		 * The preliminary mapping check is mainly to avoid the
 		 * pointless overhead of lock_page on the ZERO_PAGE
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c107094..7985e35 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1238,7 +1238,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  pmd, _pmd,  1))
 			update_mmu_cache_pmd(vma, addr, pmd);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_POPULATE) &&
+	    (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))) {
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087..82caa48 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3764,8 +3764,8 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
 	unsigned long s_end = sbase + PUD_SIZE;
 
 	/* Allow segments to share if only one is marked locked */
-	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
-	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
+	unsigned long vm_flags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
+	unsigned long svm_flags = svma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
 
 	/*
 	 * match the virtual addresses, permission and the alignment of the
diff --git a/mm/internal.h b/mm/internal.h
index 36b23f1..53e140e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -246,10 +246,11 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 extern long populate_vma_page_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end, int *nonblocking);
 extern void munlock_vma_pages_range(struct vm_area_struct *vma,
-			unsigned long start, unsigned long end);
+			unsigned long start, unsigned long end, vm_flags_t to_drop);
 static inline void munlock_vma_pages_all(struct vm_area_struct *vma)
 {
-	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end);
+	munlock_vma_pages_range(vma, vma->vm_start, vma->vm_end,
+				VM_LOCKED | VM_LOCKONFAULT);
 }
 
 /*
diff --git a/mm/ksm.c b/mm/ksm.c
index 7ee101e..5d91b7d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1058,7 +1058,7 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 			err = replace_page(vma, page, kpage, orig_pte);
 	}
 
-	if ((vma->vm_flags & VM_LOCKED) && kpage && !err) {
+	if ((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) && kpage && !err) {
 		munlock_vma_page(page);
 		if (!PageMlocked(kpage)) {
 			unlock_page(page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 64bb8a2..c9d9296 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -279,7 +279,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	*prev = vma;
-	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+	if (vma->vm_flags & (VM_LOCKED|VM_LOCKONFAULT|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
 	zap_page_range(vma, start, end - start, NULL);
@@ -300,7 +300,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
-	if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
+	if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT | VM_HUGETLB))
 		return -EINVAL;
 
 	f = vma->vm_file;
diff --git a/mm/memory.c b/mm/memory.c
index 388dcf9..2b19e0b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2165,7 +2165,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if (page_copied && (vma->vm_flags & VM_LOCKED)) {
+		if (page_copied && (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))) {
 			lock_page(old_page);	/* LRU manipulation */
 			munlock_vma_page(old_page);
 			unlock_page(old_page);
@@ -2577,7 +2577,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	swap_free(entry);
-	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	if (vm_swap_full() || (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) ||
+	    PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache) {
diff --git a/mm/mlock.c b/mm/mlock.c
index d6e61d6..8b45be1 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -406,23 +406,22 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
  * @vma - vma containing range to be munlock()ed.
  * @start - start address in @vma of the range
  * @end - end of range in @vma.
+ * @to_drop - the VMA flags we want to drop from the specified range
  *
- *  For mremap(), munmap() and exit().
+ *  For mremap(), munmap(), munlock(), and exit().
  *
- * Called with @vma VM_LOCKED.
- *
- * Returns with VM_LOCKED cleared.  Callers must be prepared to
+ * Returns with specified flags cleared.  Callers must be prepared to
  * deal with this.
  *
- * We don't save and restore VM_LOCKED here because pages are
+ * We don't save and restore specified flags here because pages are
  * still on lru.  In unmap path, pages might be scanned by reclaim
  * and re-mlocked by try_to_{munlock|unmap} before we unmap and
  * free them.  This will result in freeing mlocked pages.
  */
-void munlock_vma_pages_range(struct vm_area_struct *vma,
-			     unsigned long start, unsigned long end)
+void munlock_vma_pages_range(struct vm_area_struct *vma, unsigned long start,
+			     unsigned long end, vm_flags_t to_drop)
 {
-	vma->vm_flags &= ~VM_LOCKED;
+	vma->vm_flags &= ~to_drop;
 
 	while (start < end) {
 		struct page *page = NULL;
@@ -502,11 +501,12 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	pgoff_t pgoff;
 	int nr_pages;
 	int ret = 0;
-	int lock = !!(newflags & VM_LOCKED);
+	int lock = !!(newflags & (VM_LOCKED | VM_LOCKONFAULT));
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
-		goto out;	/* don't set VM_LOCKED,  don't count */
+		/* don't set VM_LOCKED or VM_LOCKONFAULT and don't count */
+		goto out;
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
@@ -546,7 +546,11 @@ success:
 	if (lock)
 		vma->vm_flags = newflags;
 	else
-		munlock_vma_pages_range(vma, start, end);
+		/*
+		 * We need to tell which VM_LOCK* flag(s) we are clearing here
+		 */
+		munlock_vma_pages_range(vma, start, end,
+					(vma->vm_flags & ~(newflags)));
 
 out:
 	*prev = vma;
@@ -581,10 +585,12 @@ static int apply_vma_flags(unsigned long start, size_t len,
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
 		newflags = vma->vm_flags;
-		if (add_flags)
+		if (add_flags) {
+			newflags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 			newflags |= flags;
-		else
+		} else {
 			newflags &= ~flags;
+		}
 
 		tmp = vma->vm_end;
 		if (tmp > end)
@@ -637,9 +643,15 @@ static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
 	if (error)
 		return error;
 
-	error = __mm_populate(start, len, 0);
-	if (error)
-		return __mlock_posix_error_return(error);
+	if (flags & (VM_LOCKED | VM_LOCKONFAULT)) {
+		if (flags & VM_LOCKED)
+			error = __mm_populate(start, len, 0);
+		else
+			error = mm_lock_present(start, len);
+		if (error)
+			return __mlock_posix_error_return(error);
+	}
+
 	return 0;
 }
 
@@ -650,10 +662,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 
 SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 {
-	if (!flags || flags & ~MLOCK_LOCKED)
+	if (!flags || (flags & ~(MLOCK_LOCKED | MLOCK_ONFAULT)) ||
+	    flags == (MLOCK_LOCKED | MLOCK_ONFAULT))
 		return -EINVAL;
 
-	return do_mlock(start, len, VM_LOCKED);
+	if (flags & MLOCK_LOCKED)
+		return do_mlock(start, len, VM_LOCKED);
+
+	return do_mlock(start, len, VM_LOCKONFAULT);
 }
 
 static int do_munlock(unsigned long start, size_t len, vm_flags_t flags)
@@ -672,31 +688,46 @@ static int do_munlock(unsigned long start, size_t len, vm_flags_t flags)
 
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
-	return do_munlock(start, len, VM_LOCKED);
+	return do_munlock(start, len, VM_LOCKED | VM_LOCKONFAULT);
 }
 
 SYSCALL_DEFINE3(munlock2, unsigned long, start, size_t, len, int, flags)
 {
-	if (!flags || flags & ~MLOCK_LOCKED)
+	vm_flags_t to_clear = 0;
+
+	if (!flags || flags & ~(MLOCK_LOCKED | MLOCK_ONFAULT))
 		return -EINVAL;
-	return do_munlock(start, len, VM_LOCKED);
+
+	if (flags & MLOCK_LOCKED)
+		to_clear |= VM_LOCKED;
+	if (flags & MLOCK_ONFAULT)
+		to_clear |= VM_LOCKONFAULT;
+
+	return do_munlock(start, len, to_clear);
 }
 
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	vm_flags_t to_add;
 
 	if (flags & MCL_FUTURE)
 		current->mm->def_flags |= VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
+	if (flags & MCL_ONFAULT) {
+		current->mm->def_flags |= VM_LOCKONFAULT;
+		to_add = VM_LOCKONFAULT;
+	} else {
+		to_add = VM_LOCKED;
+	}
+
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags & ~VM_LOCKED;
-		if (flags & MCL_CURRENT)
-			newflags |= VM_LOCKED;
+		newflags = vma->vm_flags & ~(VM_LOCKED | VM_LOCKONFAULT);
+		newflags |= to_add;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
@@ -711,7 +742,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)) ||
+	    (flags & (MCL_FUTURE | MCL_ONFAULT)) == (MCL_FUTURE | MCL_ONFAULT))
 		goto out;
 
 	ret = -EPERM;
@@ -740,18 +772,24 @@ out:
 static int do_munlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	vm_flags_t to_clear = 0;
 
 	if (flags & MCL_FUTURE)
 		current->mm->def_flags &= ~VM_LOCKED;
+	if (flags & MCL_ONFAULT)
+		current->mm->def_flags &= ~VM_LOCKONFAULT;
 	if (flags == MCL_FUTURE)
 		goto out;
 
+	if (flags & MCL_CURRENT)
+		to_clear |= VM_LOCKED;
+	if (flags & MCL_ONFAULT)
+		to_clear |= VM_LOCKONFAULT;
+
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
 		vm_flags_t newflags;
 
-		newflags = vma->vm_flags;
-		if (flags & MCL_CURRENT)
-			newflags &= ~VM_LOCKED;
+		newflags = vma->vm_flags & ~to_clear;
 
 		/* Ignore errors */
 		mlock_fixup(vma, &prev, vma->vm_start, vma->vm_end, newflags);
@@ -766,7 +804,7 @@ SYSCALL_DEFINE0(munlockall)
 	int ret;
 
 	down_write(&current->mm->mmap_sem);
-	ret = do_munlockall(MCL_CURRENT | MCL_FUTURE);
+	ret = do_munlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
 	up_write(&current->mm->mmap_sem);
 	return ret;
 }
@@ -775,7 +813,7 @@ SYSCALL_DEFINE1(munlockall2, int, flags)
 {
 	int ret = -EINVAL;
 
-	if (!flags || flags & ~(MCL_CURRENT | MCL_FUTURE))
+	if (!flags || flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT))
 		return ret;
 
 	down_write(&current->mm->mmap_sem);
diff --git a/mm/mmap.c b/mm/mmap.c
index aa632ad..de89be4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1232,8 +1232,8 @@ static inline int mlock_future_check(struct mm_struct *mm,
 {
 	unsigned long locked, lock_limit;
 
-	/*  mlock MCL_FUTURE? */
-	if (flags & VM_LOCKED) {
+	/*  mlock MCL_FUTURE or MCL_ONFAULT? */
+	if (flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
@@ -1646,12 +1646,12 @@ out:
 	perf_event_mmap(vma);
 
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
-	if (vm_flags & VM_LOCKED) {
+	if (vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		if (!((vm_flags & VM_SPECIAL) || is_vm_hugetlb_page(vma) ||
 					vma == get_gate_vma(current->mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 		else
-			vma->vm_flags &= ~VM_LOCKED;
+			vma->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
 	}
 
 	if (file)
@@ -2104,7 +2104,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	/* mlock limit tests */
-	if (vma->vm_flags & VM_LOCKED) {
+	if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		unsigned long locked;
 		unsigned long limit;
 		locked = mm->locked_vm + grow;
@@ -2128,7 +2128,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	/* Ok, everything looks good - let it rip */
-	if (vma->vm_flags & VM_LOCKED)
+	if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))
 		mm->locked_vm += grow;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
 	return 0;
@@ -2583,7 +2583,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	if (mm->locked_vm) {
 		struct vm_area_struct *tmp = vma;
 		while (tmp && tmp->vm_start < end) {
-			if (tmp->vm_flags & VM_LOCKED) {
+			if (tmp->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 				mm->locked_vm -= vma_pages(tmp);
 				munlock_vma_pages_all(tmp);
 			}
@@ -2636,6 +2636,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long populate = 0;
 	unsigned long ret = -EINVAL;
 	struct file *file;
+	vm_flags_t drop_lock_flag = 0;
 
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. "
 			"See Documentation/vm/remap_file_pages.txt.\n",
@@ -2675,10 +2676,15 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	flags |= MAP_SHARED | MAP_FIXED | MAP_POPULATE;
 	if (vma->vm_flags & VM_LOCKED) {
 		flags |= MAP_LOCKED;
-		/* drop PG_Mlocked flag for over-mapped range */
-		munlock_vma_pages_range(vma, start, start + size);
+		drop_lock_flag = VM_LOCKED;
+	} else if (vma->vm_flags & VM_LOCKONFAULT) {
+		drop_lock_flag = VM_LOCKONFAULT;
 	}
 
+	if (drop_lock_flag)
+		/* drop PG_Mlocked flag for over-mapped range */
+		munlock_vma_pages_range(vma, start, start + size, VM_LOCKED);
+
 	file = get_file(vma->vm_file);
 	ret = do_mmap_pgoff(vma->vm_file, start, size,
 			prot, flags, pgoff, &populate);
@@ -2781,7 +2787,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 out:
 	perf_event_mmap(vma);
 	mm->total_vm += len >> PAGE_SHIFT;
-	if (flags & VM_LOCKED)
+	if (flags & (VM_LOCKED | VM_LOCKONFAULT))
 		mm->locked_vm += (len >> PAGE_SHIFT);
 	vma->vm_flags |= VM_SOFTDIRTY;
 	return addr;
@@ -2816,7 +2822,7 @@ void exit_mmap(struct mm_struct *mm)
 	if (mm->locked_vm) {
 		vma = mm->mmap;
 		while (vma) {
-			if (vma->vm_flags & VM_LOCKED)
+			if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))
 				munlock_vma_pages_all(vma);
 			vma = vma->vm_next;
 		}
diff --git a/mm/mremap.c b/mm/mremap.c
index a7c93ec..44d4c44 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -335,7 +335,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 			vma->vm_next->vm_flags |= VM_ACCOUNT;
 	}
 
-	if (vm_flags & VM_LOCKED) {
+	if (vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		mm->locked_vm += new_len >> PAGE_SHIFT;
 		*locked = true;
 	}
@@ -371,7 +371,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 			return ERR_PTR(-EINVAL);
 	}
 
-	if (vma->vm_flags & VM_LOCKED) {
+	if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 		unsigned long locked, lock_limit;
 		locked = mm->locked_vm << PAGE_SHIFT;
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
@@ -548,7 +548,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 			}
 
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
-			if (vma->vm_flags & VM_LOCKED) {
+			if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 				mm->locked_vm += pages;
 				locked = true;
 				new_addr = addr;
diff --git a/mm/msync.c b/mm/msync.c
index bb04d53..1183183 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -73,7 +73,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		}
 		/* Here vma->vm_start <= start < vma->vm_end. */
 		if ((flags & MS_INVALIDATE) &&
-				(vma->vm_flags & VM_LOCKED)) {
+				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))) {
 			error = -EBUSY;
 			goto out_unlock;
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index 171b687..3e91372 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -742,9 +742,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (!pmd)
 			return SWAP_AGAIN;
 
-		if (vma->vm_flags & VM_LOCKED) {
+		if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 			spin_unlock(ptl);
-			pra->vm_flags |= VM_LOCKED;
+			pra->vm_flags |= (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
 			return SWAP_FAIL; /* To break the loop */
 		}
 
@@ -763,9 +763,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (!pte)
 			return SWAP_AGAIN;
 
-		if (vma->vm_flags & VM_LOCKED) {
+		if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 			pte_unmap_unlock(pte, ptl);
-			pra->vm_flags |= VM_LOCKED;
+			pra->vm_flags |= (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
 			return SWAP_FAIL; /* To break the loop */
 		}
 
@@ -1205,7 +1205,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!(flags & TTU_IGNORE_MLOCK)) {
-		if (vma->vm_flags & VM_LOCKED)
+		if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT))
 			goto out_mlock;
 
 		if (flags & TTU_MUNLOCK)
@@ -1315,7 +1315,7 @@ out_mlock:
 	 * page is actually mlocked.
 	 */
 	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
-		if (vma->vm_flags & VM_LOCKED) {
+		if (vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) {
 			mlock_vma_page(page);
 			ret = SWAP_MLOCK;
 		}
diff --git a/mm/shmem.c b/mm/shmem.c
index 4caf8ed..9ddf2ca 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -754,7 +754,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	index = page->index;
 	inode = mapping->host;
 	info = SHMEM_I(inode);
-	if (info->flags & VM_LOCKED)
+	if (info->flags & (VM_LOCKED | VM_LOCKONFAULT))
 		goto redirty;
 	if (!total_swap_pages)
 		goto redirty;
diff --git a/mm/swap.c b/mm/swap.c
index a3a0a2f..3580a21 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -710,7 +710,8 @@ void lru_cache_add_active_or_unevictable(struct page *page,
 {
 	VM_BUG_ON_PAGE(PageLRU(page), page);
 
-	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
+	if (likely((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) == 0) ||
+		   (vma->vm_flags & VM_SPECIAL)) {
 		SetPageActive(page);
 		lru_cache_add(page);
 		return;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e61445d..019d306 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -804,7 +804,7 @@ static enum page_references page_check_references(struct page *page,
 	 * Mlock lost the isolation race with us.  Let try_to_unmap()
 	 * move the page to the unevictable list.
 	 */
-	if (vm_flags & VM_LOCKED)
+	if (vm_flags & (VM_LOCKED | VM_LOCKONFAULT))
 		return PAGEREF_RECLAIM;
 
 	if (referenced_ptes) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
