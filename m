Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 41C026B0072
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 03:12:47 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so8581915dak.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 00:12:46 -0800 (PST)
Date: Mon, 7 Jan 2013 16:12:37 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch]mm: make madvise(MADV_WILLNEED) support swap file prefetch
Message-ID: <20130107081237.GB21779@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com


Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
this syscall can do swapin prefetch. It has no impact if the memory isn't
swapout.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/madvise.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)

Index: linux/mm/madvise.c
===================================================================
--- linux.orig/mm/madvise.c	2013-01-07 15:27:45.064893547 +0800
+++ linux/mm/madvise.c	2013-01-07 15:27:53.636787409 +0800
@@ -16,6 +16,9 @@
 #include <linux/ksm.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/blkdev.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -131,6 +134,82 @@ out:
 	return error;
 }
 
+static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
+	unsigned long end, struct mm_walk *walk)
+{
+	pte_t *orig_pte;
+	struct vm_area_struct *vma = walk->private;
+	unsigned long index;
+
+	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
+		return 0;
+
+	for (index = start; index != end; index += PAGE_SIZE) {
+		pte_t pte;
+		swp_entry_t entry;
+		struct page *page;
+		spinlock_t *ptl;
+
+		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
+		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
+		pte_unmap_unlock(orig_pte, ptl);
+
+		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
+			continue;
+		entry = pte_to_swp_entry(pte);
+		if (unlikely(non_swap_entry(entry)))
+			continue;
+
+		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
+								vma, index);
+		if (page)
+			page_cache_release(page);
+	}
+
+	return 0;
+}
+
+static void force_swapin_readahead(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+	struct mm_walk walk = {
+		.mm = vma->vm_mm,
+		.pmd_entry = swapin_walk_pmd_entry,
+		.private = vma,
+	};
+
+	walk_page_range(start, end, &walk);
+
+	lru_add_drain();	/* Push any new pages onto the LRU now */
+}
+
+static void force_shm_swapin_readahead(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end,
+		struct address_space *mapping)
+{
+	pgoff_t index;
+	struct page *page;
+	swp_entry_t swap;
+
+	for (; start < end; start += PAGE_SIZE) {
+		index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+		page = find_get_page(mapping, index);
+		if (!radix_tree_exceptional_entry(page)) {
+			if (page)
+				page_cache_release(page);
+			continue;
+		}
+		swap = radix_to_swp_entry(page);
+		page = read_swap_cache_async(swap, GFP_HIGHUSER_MOVABLE,
+								NULL, 0);
+		if (page)
+			page_cache_release(page);
+	}
+
+	lru_add_drain();	/* Push any new pages onto the LRU now */
+}
+
 /*
  * Schedule all required I/O operations.  Do not wait for completion.
  */
@@ -140,6 +219,18 @@ static long madvise_willneed(struct vm_a
 {
 	struct file *file = vma->vm_file;
 
+#ifdef CONFIG_SWAP
+	if (!file || mapping_cap_swap_backed(file->f_mapping)) {
+		*prev = vma;
+		if (!file)
+			force_swapin_readahead(vma, start, end);
+		else
+			force_shm_swapin_readahead(vma, start, end,
+						file->f_mapping);
+		return 0;
+	}
+#endif
+
 	if (!file)
 		return -EBADF;
 
@@ -371,6 +462,7 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 	int error = -EINVAL;
 	int write;
 	size_t len;
+	struct blk_plug plug;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
@@ -410,6 +502,7 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 	if (vma && start > vma->vm_start)
 		prev = vma;
 
+	blk_start_plug(&plug);
 	for (;;) {
 		/* Still start < end. */
 		error = -ENOMEM;
@@ -445,6 +538,7 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 			vma = find_vma(current->mm, start);
 	}
 out:
+	blk_finish_plug(&plug);
 	if (write)
 		up_write(&current->mm->mmap_sem);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
