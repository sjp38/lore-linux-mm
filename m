Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id D7E686B0272
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:37:31 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so17571139pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:37:31 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id w29si3589009pfa.53.2016.04.05.13.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:37:30 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id 184so17846644pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:37:30 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:37:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 00/10] mm: easy preliminaries to THPagecache
Message-ID: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I've rebased my huge tmpfs series against v4.6-rc2, and split it into
two sets.  This is a set of miscellaneous premliminaries that I think
we can agree to put into mmotm right away, to be included in v4.7: or
if not, then I later rework the subsequent huge tmpfs series to avoid
or include them; but for now it expects these go in ahead.

These don't assume or commit us to any particular implementation of
huge tmpfs, though most of them are tidyups that came from that work.
01-04 are similar to what I posted in February 2015, I think 05 is the
only interesting patch here, if 06 is rejected then we can just keep
it for our own testing, 07-10 clear away some small obstructions.

But this is a weird 00/10 because it includes a patch at the bottom
itself: v4.6-rc2 missed out Kirill's page_cache_* removal, but that
is assumed in the following patches; so 00/10 should be applied if
you're basing on top of v4.6-rc2, but not applied to a later tree.

00 mm: get rid of a few rc2 page_cache_*
01 mm: update_lru_size warn and reset bad lru_size
02 mm: update_lru_size do the __mod_zone_page_state
03 mm: use __SetPageSwapBacked and dont ClearPageSwapBacked
04 tmpfs: preliminary minor tidyups
05 tmpfs: mem_cgroup charge fault to vm_mm not current mm
06 mm: /proc/sys/vm/stat_refresh to force vmstat update
07 huge mm: move_huge_pmd does not need new_vma
08 huge pagecache: extend mremap pmd rmap lockout to files
09 huge pagecache: mmap_sem is unlocked when truncation splits pmd
10 arch: fix has_transparent_hugepage()

 Documentation/sysctl/vm.txt                  |   14 +
 arch/arc/include/asm/hugepage.h              |    2 
 arch/arm/include/asm/pgtable-3level.h        |    5 
 arch/arm64/include/asm/pgtable.h             |    5 
 arch/mips/include/asm/pgtable.h              |    1 
 arch/mips/mm/tlb-r4k.c                       |   21 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h |    1 
 arch/powerpc/include/asm/pgtable.h           |    1 
 arch/s390/include/asm/pgtable.h              |    1 
 arch/sparc/include/asm/pgtable_64.h          |    2 
 arch/tile/include/asm/pgtable.h              |    1 
 arch/x86/include/asm/pgtable.h               |    1 
 include/asm-generic/pgtable.h                |    8 
 include/linux/huge_mm.h                      |    4 
 include/linux/memcontrol.h                   |    6 
 include/linux/mempolicy.h                    |    6 
 include/linux/mm_inline.h                    |   24 ++
 include/linux/vmstat.h                       |    4 
 kernel/sysctl.c                              |    7 
 mm/filemap.c                                 |    4 
 mm/huge_memory.c                             |    7 
 mm/memcontrol.c                              |   26 ++
 mm/memory.c                                  |   17 -
 mm/migrate.c                                 |    6 
 mm/mremap.c                                  |   47 ++---
 mm/rmap.c                                    |    4 
 mm/shmem.c                                   |  148 +++++++----------
 mm/swap_state.c                              |    3 
 mm/vmscan.c                                  |   23 +-
 mm/vmstat.c                                  |   58 ++++++
 30 files changed, 271 insertions(+), 186 deletions(-)

[PATCH 00/10] mm: get rid of a few rc2 page_cache_*

Not-harebrained Linus forgot to apply Kirill's PAGE_CACHE_* page_cache_*
riddance in rc2, but did so the next day: this and the huge tmpfs series
assume that those changes have been made, so if applying these series to
vanilla v4.6-rc2 as intended, this patch resolves the few clashes first.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/filemap.c |    4 ++--
 mm/memory.c  |    6 +++---
 mm/rmap.c    |    2 +-
 mm/shmem.c   |   18 +++++++++---------
 4 files changed, 15 insertions(+), 15 deletions(-)

--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2178,8 +2178,8 @@ repeat:
 		if (page->mapping != mapping || !PageUptodate(page))
 			goto unlock;
 
-		size = round_up(i_size_read(mapping->host), PAGE_CACHE_SIZE);
-		if (page->index >= size >> PAGE_CACHE_SHIFT)
+		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
+		if (page->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
 		pte = vmf->pte + page->index - vmf->pgoff;
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2807,7 +2807,7 @@ static int __do_fault(struct vm_area_str
 	if (unlikely(PageHWPoison(vmf.page))) {
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
-		page_cache_release(vmf.page);
+		put_page(vmf.page);
 		return VM_FAULT_HWPOISON;
 	}
 
@@ -2996,7 +2996,7 @@ static int do_read_fault(struct mm_struc
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, false, false);
@@ -3105,7 +3105,7 @@ static int do_shared_fault(struct mm_str
 	if (unlikely(!pte_same(*pte, orig_pte))) {
 		pte_unmap_unlock(pte, ptl);
 		unlock_page(fault_page);
-		page_cache_release(fault_page);
+		put_page(fault_page);
 		return ret;
 	}
 	do_set_pte(vma, address, fault_page, pte, true, false);
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1541,7 +1541,7 @@ static int try_to_unmap_one(struct page
 
 discard:
 	page_remove_rmap(page, PageHuge(page));
-	page_cache_release(page);
+	put_page(page);
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -300,7 +300,7 @@ static int shmem_add_to_page_cache(struc
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	page_cache_get(page);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = index;
 
@@ -318,7 +318,7 @@ static int shmem_add_to_page_cache(struc
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		page_cache_release(page);
+		put_page(page);
 	}
 	return error;
 }
@@ -530,7 +530,7 @@ static void shmem_undo_range(struct inod
 		struct page *page = NULL;
 		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
 		if (page) {
-			unsigned int top = PAGE_CACHE_SIZE;
+			unsigned int top = PAGE_SIZE;
 			if (start > end) {
 				top = partial_end;
 				partial_end = 0;
@@ -1145,7 +1145,7 @@ static int shmem_getpage_gfp(struct inod
 	int once = 0;
 	int alloced = 0;
 
-	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
+	if (index > (MAX_LFS_FILESIZE >> PAGE_SHIFT))
 		return -EFBIG;
 repeat:
 	swap.val = 0;
@@ -1156,7 +1156,7 @@ repeat:
 	}
 
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto unlock;
 	}
@@ -1327,7 +1327,7 @@ clear:
 
 	/* Perhaps the file has been truncated since we checked */
 	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
-	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
 		if (alloced) {
 			ClearPageDirty(page);
 			delete_from_page_cache(page);
@@ -1355,7 +1355,7 @@ failed:
 unlock:
 	if (page) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (error == -ENOSPC && !once++) {
 		info = SHMEM_I(inode);
@@ -1635,8 +1635,8 @@ static ssize_t shmem_file_read_iter(stru
 	if (!iter_is_iovec(to))
 		sgp = SGP_DIRTY;
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	index = *ppos >> PAGE_SHIFT;
+	offset = *ppos & ~PAGE_MASK;
 
 	for (;;) {
 		struct page *page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
