Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 953C76B0070
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:08 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so9978727pab.12
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t6si34277540pdi.126.2014.12.24.04.23.03
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/38] mm: remove rest usage of VM_NONLINEAR and pte_file()
Date: Wed, 24 Dec 2014 14:22:15 +0200
Message-Id: <1419423766-114457-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

One bit in ->vm_flags is unused now!

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/gpu/drm/drm_vma_manager.c |  3 +-
 include/linux/mm.h                |  1 -
 include/linux/swapops.h           |  4 +-
 mm/debug.c                        |  1 -
 mm/gup.c                          |  2 +-
 mm/ksm.c                          |  2 +-
 mm/madvise.c                      |  4 +-
 mm/memcontrol.c                   |  4 +-
 mm/memory.c                       | 78 +++++++++++++++++++--------------------
 mm/mincore.c                      |  5 +--
 mm/mprotect.c                     |  2 +-
 mm/mremap.c                       |  2 -
 mm/msync.c                        |  5 +--
 13 files changed, 47 insertions(+), 66 deletions(-)

diff --git a/drivers/gpu/drm/drm_vma_manager.c b/drivers/gpu/drm/drm_vma_manager.c
index 63b471205072..68c1f32fb086 100644
--- a/drivers/gpu/drm/drm_vma_manager.c
+++ b/drivers/gpu/drm/drm_vma_manager.c
@@ -50,8 +50,7 @@
  *
  * You must not use multiple offset managers on a single address_space.
  * Otherwise, mm-core will be unable to tear down memory mappings as the VM will
- * no longer be linear. Please use VM_NONLINEAR in that case and implement your
- * own offset managers.
+ * no longer be linear.
  *
  * This offset manager works on page-based addresses. That is, every argument
  * and return code (with the exception of drm_vma_node_offset_addr()) is given
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6840c0dc8a06..43338946cb83 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -138,7 +138,6 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
-#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_ARCH_2	0x02000000
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 6adfb7bfbf44..50cbc876be56 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -54,7 +54,7 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
-	return !pte_none(pte) && !pte_present_nonuma(pte) && !pte_file(pte);
+	return !pte_none(pte) && !pte_present_nonuma(pte);
 }
 #endif
 
@@ -66,7 +66,6 @@ static inline swp_entry_t pte_to_swp_entry(pte_t pte)
 {
 	swp_entry_t arch_entry;
 
-	BUG_ON(pte_file(pte));
 	if (pte_swp_soft_dirty(pte))
 		pte = pte_swp_clear_soft_dirty(pte);
 	arch_entry = __pte_to_swp_entry(pte);
@@ -82,7 +81,6 @@ static inline pte_t swp_entry_to_pte(swp_entry_t entry)
 	swp_entry_t arch_entry;
 
 	arch_entry = __swp_entry(swp_type(entry), swp_offset(entry));
-	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
 
diff --git a/mm/debug.c b/mm/debug.c
index 0e58f3211f89..d69cb5a7ba9a 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -130,7 +130,6 @@ static const struct trace_print_flags vmaflags_names[] = {
 	{VM_ACCOUNT,			"account"	},
 	{VM_NORESERVE,			"noreserve"	},
 	{VM_HUGETLB,			"hugetlb"	},
-	{VM_NONLINEAR,			"nonlinear"	},
 #if defined(CONFIG_X86)
 	{VM_PAT,			"pat"		},
 #elif defined(CONFIG_PPC)
diff --git a/mm/gup.c b/mm/gup.c
index a900759cc807..f8b2838c88fa 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -55,7 +55,7 @@ retry:
 		 */
 		if (likely(!(flags & FOLL_MIGRATION)))
 			goto no_page;
-		if (pte_none(pte) || pte_file(pte))
+		if (pte_none(pte))
 			goto no_page;
 		entry = pte_to_swp_entry(pte);
 		if (!is_migration_entry(entry))
diff --git a/mm/ksm.c b/mm/ksm.c
index d247efab5073..2d12da1fda05 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1748,7 +1748,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_NONLINEAR | VM_MIXEDMAP))
+				 VM_HUGETLB | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
 #ifdef VM_SAO
diff --git a/mm/madvise.c b/mm/madvise.c
index 8d74d7617598..d03e1bbd3af3 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -164,7 +164,7 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
 		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
 		pte_unmap_unlock(orig_pte, ptl);
 
-		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
+		if (pte_present(pte) || pte_none(pte))
 			continue;
 		entry = pte_to_swp_entry(pte);
 		if (unlikely(non_swap_entry(entry)))
@@ -437,7 +437,7 @@ static long madvise_remove(struct vm_area_struct *vma,
 
 	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
 
-	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB))
+	if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
 		return -EINVAL;
 
 	f = vma->vm_file;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef91e856c7e4..408f189d24eb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4937,8 +4937,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	mapping = vma->vm_file->f_mapping;
 	if (pte_none(ptent))
 		pgoff = linear_page_index(vma, addr);
-	else /* pte_file(ptent) is true */
-		pgoff = pte_to_pgoff(ptent);
 
 	/* page is moved even if it's not RSS of this task(page-faulted). */
 #ifdef CONFIG_SWAP
@@ -4970,7 +4968,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		page = mc_handle_present_pte(vma, addr, ptent);
 	else if (is_swap_pte(ptent))
 		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
-	else if (pte_none(ptent) || pte_file(ptent))
+	else if (pte_none(ptent))
 		page = mc_handle_file_pte(vma, addr, ptent, &ent);
 
 	if (!page && !ent.val)
diff --git a/mm/memory.c b/mm/memory.c
index 587522630b10..f70c9568ea31 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -811,42 +811,40 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
-		if (!pte_file(pte)) {
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			if (likely(!non_swap_entry(entry))) {
-				if (swap_duplicate(entry) < 0)
-					return entry.val;
-
-				/* make sure dst_mm is on swapoff's mmlist. */
-				if (unlikely(list_empty(&dst_mm->mmlist))) {
-					spin_lock(&mmlist_lock);
-					if (list_empty(&dst_mm->mmlist))
-						list_add(&dst_mm->mmlist,
-							 &src_mm->mmlist);
-					spin_unlock(&mmlist_lock);
-				}
-				rss[MM_SWAPENTS]++;
-			} else if (is_migration_entry(entry)) {
-				page = migration_entry_to_page(entry);
-
-				if (PageAnon(page))
-					rss[MM_ANONPAGES]++;
-				else
-					rss[MM_FILEPAGES]++;
-
-				if (is_write_migration_entry(entry) &&
-				    is_cow_mapping(vm_flags)) {
-					/*
-					 * COW mappings require pages in both
-					 * parent and child to be set to read.
-					 */
-					make_migration_entry_read(&entry);
-					pte = swp_entry_to_pte(entry);
-					if (pte_swp_soft_dirty(*src_pte))
-						pte = pte_swp_mksoft_dirty(pte);
-					set_pte_at(src_mm, addr, src_pte, pte);
-				}
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (likely(!non_swap_entry(entry))) {
+			if (swap_duplicate(entry) < 0)
+				return entry.val;
+
+			/* make sure dst_mm is on swapoff's mmlist. */
+			if (unlikely(list_empty(&dst_mm->mmlist))) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&dst_mm->mmlist))
+					list_add(&dst_mm->mmlist,
+							&src_mm->mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+			rss[MM_SWAPENTS]++;
+		} else if (is_migration_entry(entry)) {
+			page = migration_entry_to_page(entry);
+
+			if (PageAnon(page))
+				rss[MM_ANONPAGES]++;
+			else
+				rss[MM_FILEPAGES]++;
+
+			if (is_write_migration_entry(entry) &&
+					is_cow_mapping(vm_flags)) {
+				/*
+				 * COW mappings require pages in both
+				 * parent and child to be set to read.
+				 */
+				make_migration_entry_read(&entry);
+				pte = swp_entry_to_pte(entry);
+				if (pte_swp_soft_dirty(*src_pte))
+					pte = pte_swp_mksoft_dirty(pte);
+				set_pte_at(src_mm, addr, src_pte, pte);
 			}
 		}
 		goto out_set_pte;
@@ -1020,11 +1018,9 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB | VM_NONLINEAR |
-			       VM_PFNMAP | VM_MIXEDMAP))) {
-		if (!vma->anon_vma)
-			return 0;
-	}
+	if (!(vma->vm_flags & (VM_HUGETLB | VM_PFNMAP | VM_MIXEDMAP)) &&
+			!vma->anon_vma)
+		return 0;
 
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
diff --git a/mm/mincore.c b/mm/mincore.c
index c8c528b36641..e5f8c032dc72 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -131,10 +131,7 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			mincore_unmapped_range(vma, addr, next, vec);
 		else if (pte_present(pte))
 			*vec = 1;
-		else if (pte_file(pte)) {
-			pgoff = pte_to_pgoff(pte);
-			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
-		} else { /* pte is a swap entry */
+		else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (non_swap_entry(entry)) {
diff --git a/mm/mprotect.c b/mm/mprotect.c
index ace93454ce8e..33121662f08b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -105,7 +105,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 			if (updated)
 				pages++;
-		} else if (IS_ENABLED(CONFIG_MIGRATION) && !pte_file(oldpte)) {
+		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
 			if (is_write_migration_entry(entry)) {
diff --git a/mm/mremap.c b/mm/mremap.c
index 17fa018f5f39..57dadc025c64 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -81,8 +81,6 @@ static pte_t move_soft_dirty_pte(pte_t pte)
 		pte = pte_mksoft_dirty(pte);
 	else if (is_swap_pte(pte))
 		pte = pte_swp_mksoft_dirty(pte);
-	else if (pte_file(pte))
-		pte = pte_file_mksoft_dirty(pte);
 #endif
 	return pte;
 }
diff --git a/mm/msync.c b/mm/msync.c
index 992a1673d488..bb04d53ae852 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -86,10 +86,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
 			up_read(&mm->mmap_sem);
-			if (vma->vm_flags & VM_NONLINEAR)
-				error = vfs_fsync(file, 1);
-			else
-				error = vfs_fsync_range(file, fstart, fend, 1);
+			error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
