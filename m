Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6BC6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:24:29 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so72212988qge.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:24:29 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id d19si39743258qhc.106.2015.08.26.11.24.28
        for <linux-mm@kvack.org>;
        Wed, 26 Aug 2015 11:24:28 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
Date: Wed, 26 Aug 2015 14:24:22 -0400
Message-Id: <1440613465-30393-4-git-send-email-emunson@akamai.com>
In-Reply-To: <1440613465-30393-1-git-send-email-emunson@akamai.com>
References: <1440613465-30393-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

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
faulted in.  The VM_LOCKONFAULT flag will be used together with
VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
be added to the unevictable LRU when they are faulted or if they are
already present, but will not cause any missing pages to be faulted in.

Exposing this new lock state means that we cannot overload the meaning
of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
to mean that the VMA for a fault was locked.  This means we need the
new FOLL_MLOCK flag to communicate the locked state of a VMA.
FOLL_POPULATE will now only control if the VMA should be populated and
in the case of VM_LOCKONFAULT, it will not be set.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org
---
Changes from v7:
*Drop entries in smaps and dri code to avoid exposing VM_LOCKONFAULT to
 userspace.  VM_LOCKONFAULT is still exposed via mm/debug.c
*Create VM_LOCKED_CLEAR_MASK to be used anywhere we want to clear all
 flags relating to locked VMAs

 include/linux/mm.h |  5 +++++
 kernel/fork.c      |  2 +-
 mm/debug.c         |  1 +
 mm/gup.c           | 10 ++++++++--
 mm/huge_memory.c   |  2 +-
 mm/hugetlb.c       |  4 ++--
 mm/mlock.c         |  2 +-
 mm/mmap.c          |  2 +-
 mm/rmap.c          |  6 ++++--
 9 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf6f117..47ff851 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -136,6 +136,7 @@ extern unsigned int kobjsize(const void *objp);
 
 #define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
+#define VM_LOCKONFAULT	0x00080000	/* Lock the pages covered when they are faulted in */
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
@@ -199,6 +200,9 @@ extern unsigned int kobjsize(const void *objp);
 /* This mask defines which mm->def_flags a process can inherit its parent */
 #define VM_INIT_DEF_MASK	VM_NOHUGEPAGE
 
+/* This mask is used to clear all the VMA flags used by mlock */
+#define VM_LOCKED_CLEAR_MASK	(~(VM_LOCKED | VM_LOCKONFAULT))
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
@@ -2071,6 +2075,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
 #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
+#define FOLL_MLOCK	0x1000	/* lock present pages */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/kernel/fork.c b/kernel/fork.c
index dbd9b8d..eee1cc5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -454,7 +454,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~VM_LOCKED;
+		tmp->vm_flags &= VM_LOCKED_CLEAR_MASK;
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
index 6297f6b..dce6ccd 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -92,7 +92,7 @@ retry:
 		 */
 		mark_page_accessed(page);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		/*
 		 * The preliminary mapping check is mainly to avoid the
 		 * pointless overhead of lock_page on the ZERO_PAGE
@@ -265,6 +265,9 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	unsigned int fault_flags = 0;
 	int ret;
 
+	/* mlock all present pages, but do not fault in new pages */
+	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
+		return -ENOENT;
 	/* For mm_populate(), just skip the stack guard page. */
 	if ((*flags & FOLL_POPULATE) &&
 			(stack_guard_page_start(vma, address) ||
@@ -850,7 +853,10 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
 	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
 
-	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
+	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
+	if (vma->vm_flags & VM_LOCKONFAULT)
+		gup_flags &= ~FOLL_POPULATE;
+
 	/*
 	 * We want to touch writable mappings with a write fault in order
 	 * to break COW, except for shared mappings because these don't COW
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 097c7a4..cba783e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1238,7 +1238,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  pmd, _pmd,  1))
 			update_mmu_cache_pmd(vma, addr, pmd);
 	}
-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		if (page->mapping && trylock_page(page)) {
 			lru_add_drain();
 			if (page->mapping)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a8c3087..a01ccc3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3764,8 +3764,8 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
 	unsigned long s_end = sbase + PUD_SIZE;
 
 	/* Allow segments to share if only one is marked locked */
-	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
-	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
+	unsigned long vm_flags = vma->vm_flags & VM_LOCKED_CLEAR_MASK;
+	unsigned long svm_flags = svma->vm_flags & VM_LOCKED_CLEAR_MASK;
 
 	/*
 	 * match the virtual addresses, permission and the alignment of the
diff --git a/mm/mlock.c b/mm/mlock.c
index 3094f27..7efe27d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -422,7 +422,7 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
-	vma->vm_flags &= ~VM_LOCKED;
+	vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
 
 	while (start < end) {
 		struct page *page = NULL;
diff --git a/mm/mmap.c b/mm/mmap.c
index aa632ad..019dcd6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1651,7 +1651,7 @@ out:
 					vma == get_gate_vma(current->mm)))
 			mm->locked_vm += (len >> PAGE_SHIFT);
 		else
-			vma->vm_flags &= ~VM_LOCKED;
+			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
 	}
 
 	if (file)
diff --git a/mm/rmap.c b/mm/rmap.c
index 171b687..14ce002 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -744,7 +744,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 
 		if (vma->vm_flags & VM_LOCKED) {
 			spin_unlock(ptl);
-			pra->vm_flags |= VM_LOCKED;
+			pra->vm_flags |=
+				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
 			return SWAP_FAIL; /* To break the loop */
 		}
 
@@ -765,7 +766,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
-			pra->vm_flags |= VM_LOCKED;
+			pra->vm_flags |=
+				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
 			return SWAP_FAIL; /* To break the loop */
 		}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
