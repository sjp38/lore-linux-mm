Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 04BB76B0055
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:19 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so13858511pde.20
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:19 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yl2si2381029pab.240.2014.01.01.23.13.16
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:18 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 08/16] vrange: Send SIGBUS when user try to access purged page
Date: Thu,  2 Jan 2014 16:12:16 +0900
Message-Id: <1388646744-15608-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

By vrange(2) semantic, a user should see SIGBUS if they try to
access purged page without marking the memory as non-voaltile
(ie, vrange(...VRANGE_NOVOLATILE)).

This allows for optimistic traversal of volatile pages, without
having to mark them non-volatile first and the SIGBUS allows
applications to trap and fixup the purged range before accessing
them again.

This patch implements it by adding SWP_VRANGE so it consumes one
from MAX_SWAPFILES. It means worst case of MAX_SWAPFILES in 32 bit
is 32 - 2 - 1 - 1 = 28. I think it's still enough for everybody.

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
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h   |    6 +++++-
 include/linux/vrange.h |   17 ++++++++++++++++-
 mm/memory.c            |   35 +++++++++++++++++++++++++++++++++--
 mm/mincore.c           |    5 ++++-
 mm/vrange.c            |   19 +++++++++++++++++++
 5 files changed, 77 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6c219f..39b3d4c6aec9 100644
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
index 778902d9cc30..d9ce2ec53a34 100644
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
@@ -43,7 +55,8 @@ extern int vrange_fork(struct mm_struct *new,
 					struct mm_struct *old);
 int discard_vpage(struct page *page);
 bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr);
-
+extern bool vrange_addr_purged(struct vm_area_struct *vma,
+				unsigned long address);
 #else
 
 static inline void vrange_root_init(struct vrange_root *vroot,
@@ -60,5 +73,7 @@ static inline bool vrange_addr_volatile(struct vm_area_struct *vma,
 	return false;
 }
 static inline int discard_vpage(struct page *page) { return 0 };
+static inline bool vrange_addr_purged(struct vm_area_struct *vma,
+				unsigned long address);
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/mm/memory.c b/mm/memory.c
index d176154c243f..86231180f01f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/vrange.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -807,6 +808,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (unlikely(!pte_present(pte))) {
 		if (!pte_file(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
+			if (is_vrange_entry(entry))
+				goto out_set_pte;
 
 			if (swap_duplicate(entry) < 0)
 				return entry.val;
@@ -1152,6 +1155,8 @@ again:
 				print_bad_pte(vma, addr, ptent, NULL);
 		} else {
 			swp_entry_t entry = pte_to_swp_entry(ptent);
+			if (is_vrange_entry(entry))
+				goto out;
 
 			if (!non_swap_entry(entry))
 				rss[MM_SWAPENTS]--;
@@ -1168,6 +1173,7 @@ again:
 			if (unlikely(!free_swap_and_cache(entry)))
 				print_bad_pte(vma, addr, ptent, NULL);
 		}
+out:
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
@@ -3695,15 +3701,40 @@ static int handle_pte_fault(struct mm_struct *mm,
 
 	entry = *pte;
 	if (!pte_present(entry)) {
+		swp_entry_t vrange_entry;
+retry:
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
-						pte, pmd, flags, entry);
+							pte, pmd, flags, entry);
 			}
 			return do_anonymous_page(mm, vma, address,
-						 pte, pmd, flags);
+					pte, pmd, flags);
+		}
+
+		vrange_entry = pte_to_swp_entry(entry);
+		if (unlikely(is_vrange_entry(vrange_entry))) {
+			if (!vrange_addr_purged(vma, address)) {
+				/*
+				 * If the address is not in purged vrange,
+				 * It means user already called NOVOLATILE
+				 * vrange system call so we shouldn't send
+				 * a SIGBUS. Intead, zap it and retry.
+				 */
+				ptl = pte_lockptr(mm, pmd);
+				spin_lock(ptl);
+				if (unlikely(!pte_same(*pte, entry)))
+					goto unlock;
+				flush_cache_page(vma, address, pte_pfn(*pte));
+				ptep_clear_flush(vma, address, pte);
+				pte_unmap_unlock(pte, ptl);
+				goto retry;
+			}
+
+			return VM_FAULT_SIGBUS;
 		}
+
 		if (pte_file(entry))
 			return do_nonlinear_fault(mm, vma, address,
 					pte, pmd, flags, entry);
diff --git a/mm/mincore.c b/mm/mincore.c
index da2be56a7b8f..e6138048d735 100644
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
+			if (is_vrange_entry(entry)) {
+				*vec = 0;
+			} else if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
 				*vec = 1;
 			} else {
diff --git a/mm/vrange.c b/mm/vrange.c
index 18afe94d3f13..f86ed33434d8 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -431,6 +431,24 @@ bool vrange_addr_volatile(struct vm_area_struct *vma, unsigned long addr)
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
+	range = __vrange_find(vroot, vstart_idx, vstart_idx);
+	if (range && range->purged)
+		ret = true;
+	vrange_unlock(vroot);
+	return ret;
+}
+
 /* Caller should hold vrange_lock */
 static void do_purge(struct vrange_root *vroot,
 		unsigned long start_idx, unsigned long end_idx)
@@ -474,6 +492,7 @@ static void try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	page_remove_rmap(page);
 	page_cache_release(page);
 
+	set_pte_at(mm, addr, pte, swp_entry_to_pte(make_vrange_entry()));
 	pte_unmap_unlock(pte, ptl);
 	mmu_notifier_invalidate_page(mm, addr);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
