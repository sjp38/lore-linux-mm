Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B6AD76B005A
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:20 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1807285pab.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:20 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so1685930pde.10
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:18 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 08/14] vrange: Send SIGBUS when user try to access purged page
Date: Wed,  2 Oct 2013 17:51:37 -0700
Message-Id: <1380761503-14509-9-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

By vrange(2) semantic, a user should see SIGBUG if they try to
access purged page without marking the memory as non-voaltile
(ie, vrange(...VRANGE_NOVOLATILE)).

This allows for optimistic traversal of volatile pages, without
having to mark them non-volatile first and the SIGBUS allows
applications to trap and fixup the purged range before accessing
them again.

This patch implements it by adding SWP_VRANGE so it consumes one
from MAX_SWAPFILES. It means worst case of MAX_SWAPFILES in 32 bit
is 32 - 2 - 1 - 1 = 28. I think it's still enough for everybody.
If someone complains about that and thinks we shouldn't consume it,
I will change it with (swp_type 0, pgoffset 0) which is header of swap
which couldn't be allocated as swp_pte for swapout so we can use it.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/swap.h   |  6 +++++-
 include/linux/vrange.h | 20 ++++++++++++++++++++
 mm/memory.c            | 27 +++++++++++++++++++++++++++
 mm/mincore.c           |  5 ++++-
 mm/vrange.c            | 20 +++++++++++++++++++-
 5 files changed, 75 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d95cde5..7fd1006 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -49,6 +49,9 @@ static inline int current_is_kswapd(void)
  * actions on faults.
  */
 
+#define SWP_VRANGE_NUM 1
+#define SWP_VRANGE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
+
 /*
  * NUMA node memory migration support
  */
@@ -71,7 +74,8 @@ static inline int current_is_kswapd(void)
 #endif
 
 #define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM \
+			- SWP_VRANGE_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 778902d..50b9131 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -3,6 +3,8 @@
 
 #include <linux/vrange_types.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #define vrange_from_node(node_ptr) \
 	container_of(node_ptr, struct vrange, node)
@@ -12,6 +14,16 @@
 
 #ifdef CONFIG_MMU
 
+static inline swp_entry_t make_vrange_entry(void)
+{
+	return swp_entry(SWP_VRANGE, 0);
+}
+
+static inline int is_vrange_entry(swp_entry_t entry)
+{
+	return swp_type(entry) == SWP_VRANGE;
+}
+
 static inline void vrange_root_init(struct vrange_root *vroot, int type,
 								void *object)
 {
@@ -44,6 +56,9 @@ extern int vrange_fork(struct mm_struct *new,
 int discard_vpage(struct page *page);
 bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr);
 
+extern bool vrange_addr_purged(struct vm_area_struct *vma,
+					unsigned long address);
+
 #else
 
 static inline void vrange_root_init(struct vrange_root *vroot,
@@ -60,5 +75,10 @@ static inline bool vrange_addr_volatile(struct vm_area_struct *vma,
 	return false;
 }
 static inline int discard_vpage(struct page *page) { return 0 };
+static inline bool vrange_addr_purged(struct vm_area_struct *vma,
+					unsigned long address)
+{
+	return false;
+};
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/mm/memory.c b/mm/memory.c
index af84bc0..e33dbce 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/vrange.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -831,6 +832,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (unlikely(!pte_present(pte))) {
 		if (!pte_file(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
+			if (is_vrange_entry(entry))
+				goto out_set_pte;
 
 			if (swap_duplicate(entry) < 0)
 				return entry.val;
@@ -1174,6 +1177,8 @@ again:
 				print_bad_pte(vma, addr, ptent, NULL);
 		} else {
 			swp_entry_t entry = pte_to_swp_entry(ptent);
+			if (is_vrange_entry(entry))
+				goto out;
 
 			if (!non_swap_entry(entry))
 				rss[MM_SWAPENTS]--;
@@ -1190,6 +1195,7 @@ again:
 			if (unlikely(!free_swap_and_cache(entry)))
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
+out:
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
@@ -3715,15 +3721,36 @@ int handle_pte_fault(struct mm_struct *mm,
 
 	entry = *pte;
 	if (!pte_present(entry)) {
+		swp_entry_t vrange_entry;
+
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, flags, entry);
 			}
+anon:
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
+
+		vrange_entry = pte_to_swp_entry(entry);
+		if (unlikely(is_vrange_entry(vrange_entry))) {
+			if (!vrange_addr_purged(vma, address)) {
+				/* zap pte */
+				ptl = pte_lockptr(mm, pmd);
+				spin_lock(ptl);
+				if (unlikely(!pte_same(*pte, entry)))
+					goto unlock;
+				flush_cache_page(vma, address, pte_pfn(*pte));
+				ptep_clear_flush(vma, address, pte);
+				pte_unmap_unlock(pte, ptl);
+				goto anon;
+			}
+
+			return VM_FAULT_SIGBUS;
+		}
+
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
 					pte, pmd, flags, entry);
diff --git a/mm/mincore.c b/mm/mincore.c
index da2be56..2a95eef 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -15,6 +15,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
+#include <linux/vrange.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -129,7 +130,9 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		} else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			if (is_migration_entry(entry)) {
+			if (is_vrange_entry(entry))
+				*vec = 0;
+			else if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
 				*vec = 1;
 			} else {
diff --git a/mm/vrange.c b/mm/vrange.c
index c72e72d..c19a966 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -10,7 +10,6 @@
 #include <linux/rmap.h>
 #include <linux/hugetlb.h>
 #include "internal.h"
-#include <linux/swap.h>
 #include <linux/mmu_notifier.h>
 
 static struct kmem_cache *vrange_cachep;
@@ -430,6 +429,24 @@ bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr)
 	return ret;
 }
 
+bool vrange_addr_purged(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct vrange_root *vroot;
+	struct vrange *range;
+	unsigned long vstart_idx;
+	bool ret = false;
+
+	vroot = __vma_to_vroot(vma);
+	vstart_idx = __vma_addr_to_index(vma, addr);
+
+	vrange_lock(vroot);
+	range = __vrange_find(vroot, vstart_idx, vstart_idx + PAGE_SIZE - 1);
+	if (range && range->purged)
+		ret = true;
+	vrange_unlock(vroot);
+	return ret;
+}
+
 /* Caller should hold vrange_lock */
 static void do_purge(struct vrange_root *vroot,
 		unsigned long start_idx, unsigned long end_idx)
@@ -473,6 +490,7 @@ static void try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	page_remove_rmap(page);
 	page_cache_release(page);
 
+	set_pte_at(mm, addr, pte, swp_entry_to_pte(make_vrange_entry()));
 	pte_unmap_unlock(pte, ptl);
 	mmu_notifier_invalidate_page(mm, addr);
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
