Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8639C6B0036
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:49 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so4619573pbc.14
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ub1si3789334pac.41.2014.06.02.14.36.48
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:48 -0700 (PDT)
Subject: [PATCH 02/10] mm: pagewalk: always skip hugetlbfs except when explicitly handled
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:47 -0700
References: <20140602213644.925A26D0@viggo.jf.intel.com>
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
Message-Id: <20140602213647.E5C5D134@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The short story:

The walk_page_range() code is fragile for hugetlbfs VMAs.  Each
walker instance must either exclude hugetlbfs from being walked,
or add a ->hugetlb_entry handler.  If this is not done, the code
will go off the rails and start clearing huge page table entries.

This patch removes that requirement on the walkers.  They can
merrily call walk_page_range() on hugetlbfs areas, and those
areas will simply be skipped inside the page walker code if they
have not set up a handler.

This makes the code more robust, shorter, and makes it more
intuitive to write a page table walker.  Yay.

Long story:

I was looking at the page walker code and thought I found a bug.
If the walker hits a hugetlbfs VMA where walk->hugetlb_entry was
not set, it would hit the if(), and the clear out the pgd
thinking it was bad.

This essentially means that *EVERY* page walker has to *KNOW* to
either exclude hugetlbfs VMAs, or set a ->hugetlb_entry handler.
The good news is that all 9 users of walk_page_range() do this
implicitly or explicitly.  The bad news is that it took me an
hour to convince myself of this, and future walk_page_range()
instances are vulnerable to making this mistake.  I think the
madvise() use was probably just lucky (details below).

Here's the code trimmed down.  Note what happens if we have a
is_vm_hugetlb_page(), !walk->hugetlb_entry, and a huge page pgd
entry in 'pgd' (or any of the lower levels).

int walk_page_range(unsigned long addr, unsigned long end, ...
{
...
	vma = find_vma(walk->mm, addr);
        if (vma) {
		if (walk->hugetlb_entry && is_vm_hugetlb_page(vma)) {
			walk_hugetlb_range(vma, addr, next, walk);
			...
			continue;
		}
	}
	if (pgd_none_or_clear_bad(pgd)) {


There are currently 9 users of walk_page_range().  They handle
hugetlbfs pages in 5 ways:

/proc/$pid/smaps:
/proc/$pid/clear_refs:
cgroup precharge:
cgroup move charge:
	checks VMA explicitly for hugetblfs and skips, does not set
	->hugetlb_entry (this patch removes the now unnecessary
	hugetlbfs checks for these)

openrisc dma alloc:
	works on kernel memory, so no hugetlbfs, also arch does not
	even support hugetlbfs

powerpc subpage protection:
	uses arch-specific is_hugepage_only_range() check

/proc/$pid/pagemap:
/proc/$pid/numa_map:
	sets ->hugetlb_entry
	(these are unaffected by this patch)

MADV_WILLNEED:
	does not set ->hugetlb_entry
	only called via:
	madvise_willneed() {
		if (!vma->file)
			force_swapin_readahead(...) {
				walk_page_range(...)
			}
	}
	That !vma->file check just _happens_ to cover hugetlbfs
  	vmas since they are always file-backed (or at least have
	vma->file set as far as I can tell)

	(this case is unaffected by this patch)

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/fs/proc/task_mmu.c |    4 +---
 b/mm/memcontrol.c    |    4 ----
 b/mm/pagewalk.c      |    5 ++++-
 3 files changed, 5 insertions(+), 8 deletions(-)

diff -puN fs/proc/task_mmu.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1 fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1	2014-06-02 14:20:19.210803615 -0700
+++ b/fs/proc/task_mmu.c	2014-06-02 14:20:19.218803974 -0700
@@ -590,7 +590,7 @@ static int show_smap(struct seq_file *m,
 	memset(&mss, 0, sizeof mss);
 	mss.vma = vma;
 	/* mmap_sem is held in m_start */
-	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
+	if (vma->vm_mm)
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
 
 	show_map_vma(m, vma, is_pid);
@@ -829,8 +829,6 @@ static ssize_t clear_refs_write(struct f
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			cp.vma = vma;
-			if (is_vm_hugetlb_page(vma))
-				continue;
 			/*
 			 * Writing 1 to /proc/pid/clear_refs affects all pages.
 			 *
diff -puN mm/memcontrol.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1 mm/memcontrol.c
--- a/mm/memcontrol.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1	2014-06-02 14:20:19.212803706 -0700
+++ b/mm/memcontrol.c	2014-06-02 14:20:19.220804064 -0700
@@ -6821,8 +6821,6 @@ static unsigned long mem_cgroup_count_pr
 			.mm = mm,
 			.private = vma,
 		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
 		walk_page_range(vma->vm_start, vma->vm_end,
 					&mem_cgroup_count_precharge_walk);
 	}
@@ -7087,8 +7085,6 @@ retry:
 			.mm = mm,
 			.private = vma,
 		};
-		if (is_vm_hugetlb_page(vma))
-			continue;
 		ret = walk_page_range(vma->vm_start, vma->vm_end,
 						&mem_cgroup_move_charge_walk);
 		if (ret)
diff -puN mm/pagewalk.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1 mm/pagewalk.c
--- a/mm/pagewalk.c~pagewalk-always-skip-hugetlbfs-except-when-explicitly-handled-1	2014-06-02 14:20:19.214803794 -0700
+++ b/mm/pagewalk.c	2014-06-02 14:20:19.220804064 -0700
@@ -115,6 +115,9 @@ static int walk_hugetlb_range(struct vm_
 	pte_t *pte;
 	int err = 0;
 
+	if (!walk->hugetlb_entry)
+		return 0;
+
 	do {
 		next = hugetlb_entry_end(h, addr, end);
 		pte = huge_pte_offset(walk->mm, addr & hmask);
@@ -208,7 +211,7 @@ int walk_page_range(unsigned long addr,
 			 * architecture and we can't handled it in the same
 			 * manner as non-huge pages.
 			 */
-			if (walk->hugetlb_entry && is_vm_hugetlb_page(vma)) {
+			if (is_vm_hugetlb_page(vma)) {
 				if (vma->vm_end < next)
 					next = vma->vm_end;
 				/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
