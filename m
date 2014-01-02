Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F31706B003A
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so14235701pab.14
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:15 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.12
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:14 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 05/16] vrange: Add basic functions to purge volatile pages
Date: Thu,  2 Jan 2014 16:12:13 +0900
Message-Id: <1388646744-15608-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds discard_vpage and related functions to purge
anonymous and file volatile pages.

It is in preparation for purging volatile pages when memory is tight.
The logic to trigger purge volatile pages will be introduced in the
next patch.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[jstultz: Reworked to add purging of file pages, commit log tweaks]
Signed-off-by: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vrange.h |    9 +++
 mm/internal.h          |    2 -
 mm/vrange.c            |  192 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 201 insertions(+), 2 deletions(-)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index ef153c8a88d1..778902d9cc30 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -41,6 +41,9 @@ extern int vrange_clear(struct vrange_root *vroot,
 extern void vrange_root_cleanup(struct vrange_root *vroot);
 extern int vrange_fork(struct mm_struct *new,
 					struct mm_struct *old);
+int discard_vpage(struct page *page);
+bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr);
+
 #else
 
 static inline void vrange_root_init(struct vrange_root *vroot,
@@ -51,5 +54,11 @@ static inline int vrange_fork(struct mm_struct *new, struct mm_struct *old)
 	return 0;
 }
 
+static inline bool vrange_addr_volatile(struct vm_area_struct *vma,
+					unsigned long addr)
+{
+	return false;
+}
+static inline int discard_vpage(struct page *page) { return 0 };
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/mm/internal.h b/mm/internal.h
index 684f7aa9692a..a4f6495cc930 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -225,10 +225,8 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 
 extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
-#endif
 #else /* !CONFIG_MMU */
 static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
 {
diff --git a/mm/vrange.c b/mm/vrange.c
index 9ed5610b2e54..18afe94d3f13 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -6,6 +6,12 @@
 #include <linux/slab.h>
 #include <linux/syscalls.h>
 #include <linux/mman.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/hugetlb.h>
+#include "internal.h"
+#include <linux/swap.h>
+#include <linux/mmu_notifier.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -64,6 +70,19 @@ static inline void __vrange_resize(struct vrange *range,
 	__vrange_add(range, vroot);
 }
 
+static struct vrange *__vrange_find(struct vrange_root *vroot,
+					unsigned long start_idx,
+					unsigned long end_idx)
+{
+	struct vrange *range = NULL;
+	struct interval_tree_node *node;
+
+	node = interval_tree_iter_first(&vroot->v_rb, start_idx, end_idx);
+	if (node)
+		range = vrange_from_node(node);
+	return range;
+}
+
 static int vrange_add(struct vrange_root *vroot,
 			unsigned long start_idx, unsigned long end_idx)
 {
@@ -394,3 +413,176 @@ SYSCALL_DEFINE4(vrange, unsigned long, start,
 out:
 	return ret;
 }
+
+bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct vrange_root *vroot;
+	unsigned long vstart_idx, vend_idx;
+	bool ret = false;
+
+	vroot = __vma_to_vroot(vma);
+	vstart_idx = __vma_addr_to_index(vma, addr);
+	vend_idx = vstart_idx + PAGE_SIZE - 1;
+
+	vrange_lock(vroot);
+	if (__vrange_find(vroot, vstart_idx, vend_idx))
+		ret = true;
+	vrange_unlock(vroot);
+	return ret;
+}
+
+/* Caller should hold vrange_lock */
+static void do_purge(struct vrange_root *vroot,
+		unsigned long start_idx, unsigned long end_idx)
+{
+	struct vrange *range;
+	struct interval_tree_node *node;
+
+	node = interval_tree_iter_first(&vroot->v_rb, start_idx, end_idx);
+	while (node) {
+		range = container_of(node, struct vrange, node);
+		range->purged = true;
+		node = interval_tree_iter_next(node, start_idx, end_idx);
+	}
+}
+
+static void try_to_discard_one(struct vrange_root *vroot, struct page *page,
+				struct vm_area_struct *vma, unsigned long addr)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *pte;
+	pte_t pteval;
+	spinlock_t *ptl;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	pte = page_check_address(page, mm, addr, &ptl, 0);
+	if (!pte)
+		return;
+
+	BUG_ON(vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|VM_HUGETLB));
+
+	flush_cache_page(vma, addr, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, addr, pte);
+
+	update_hiwater_rss(mm);
+	if (PageAnon(page))
+		dec_mm_counter(mm, MM_ANONPAGES);
+	else
+		dec_mm_counter(mm, MM_FILEPAGES);
+
+	page_remove_rmap(page);
+	page_cache_release(page);
+
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, addr);
+
+	addr = __vma_addr_to_index(vma, addr);
+
+	do_purge(vroot, addr, addr + PAGE_SIZE - 1);
+}
+
+static int try_to_discard_anon_vpage(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	struct anon_vma_chain *avc;
+	pgoff_t pgoff;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct vrange_root *vroot;
+
+	unsigned long address;
+
+	anon_vma = page_lock_anon_vma_read(page);
+	if (!anon_vma)
+		return -1;
+
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	/*
+	 * During interating the loop, some processes could see a page as
+	 * purged while others could see a page as not-purged because we have
+	 * no global lock between parent and child for protecting vrange system
+	 * call during this loop. But it's not a problem because the page is
+	 * not *SHARED* page but *COW* page so parent and child can see other
+	 * data anytime. The worst case by this race is a page was purged
+	 * but couldn't be discarded so it makes unnecessary page fault but
+	 * it wouldn't be severe.
+	 */
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		vma = avc->vma;
+		mm = vma->vm_mm;
+		vroot = &mm->vroot;
+		address = vma_address(page, vma);
+
+		vrange_lock(vroot);
+		if (!__vrange_find(vroot, address, address + PAGE_SIZE - 1)) {
+			vrange_unlock(vroot);
+			continue;
+		}
+
+		try_to_discard_one(vroot, page, vma, address);
+		vrange_unlock(vroot);
+	}
+
+	page_unlock_anon_vma_read(anon_vma);
+	return 0;
+}
+
+static int try_to_discard_file_vpage(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct vrange_root *vroot;
+	unsigned long vstart_idx;
+	int ret = 1;
+
+	if (!page->mapping)
+		return ret;
+
+	vroot = &mapping->vroot;
+	vstart_idx = page->index << PAGE_SHIFT;
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	vrange_lock(vroot);
+
+	if (!__vrange_find(vroot, vstart_idx, vstart_idx + PAGE_SIZE - 1))
+		goto out;
+
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long address = vma_address(page, vma);
+		try_to_discard_one(vroot, page, vma, address);
+	}
+
+	VM_BUG_ON(page_mapped(page));
+	ret = 0;
+out:
+	vrange_unlock(vroot);
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return ret;
+}
+
+static int try_to_discard_vpage(struct page *page)
+{
+	if (PageAnon(page))
+		return try_to_discard_anon_vpage(page);
+	return try_to_discard_file_vpage(page);
+}
+
+int discard_vpage(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageLRU(page));
+
+	if (!try_to_discard_vpage(page)) {
+		if (PageSwapCache(page))
+			try_to_free_swap(page);
+
+		if (page_freeze_refs(page, 1)) {
+			unlock_page(page);
+			return 0;
+		}
+	}
+
+	return 1;
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
