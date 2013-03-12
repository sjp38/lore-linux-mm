Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 5B4336B003A
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:57 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 06/11] send SIGBUS when user try to access purged page
Date: Tue, 12 Mar 2013 16:38:30 +0900
Message-Id: <1363073915-25000-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

By vrange(2) semantic, user should see SIGBUG if he try to access
purged page without vrange(...VRANGE_NOVOLATILE).

This patch implements it.

I reused PSE bit for quick prototype without enough considering
so need time to see what's empty bit and I am surely missing
many places to handle vrange pte bit. I should investigate all of
pte handling places, especially pte_none case. TODO

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/x86/include/asm/pgtable_types.h |  2 ++
 include/asm-generic/pgtable.h        | 11 +++++++++++
 include/linux/vrange.h               |  2 ++
 mm/memory.c                          | 23 +++++++++++++++++++++--
 mm/vrange.c                          | 26 ++++++++++++++++++++++++--
 5 files changed, 60 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 567b5d0..8c5163f 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -64,6 +64,8 @@
 #define _PAGE_FILE	(_AT(pteval_t, 1) << _PAGE_BIT_FILE)
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
+#define _PAGE_VRANGE	_PAGE_BIT_PSE
+
 /*
  * _PAGE_NUMA indicates that this page will trigger a numa hinting
  * minor page fault to gather numa placement statistics (see
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index bfd8768..1486d42 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -469,6 +469,17 @@ static inline unsigned long my_zero_pfn(unsigned long addr)
 
 #ifdef CONFIG_MMU
 
+static inline pte_t pte_mkvrange(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_VRANGE);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+
+static inline int pte_vrange(pte_t pte)
+{
+	return ((pte_flags(pte) | _PAGE_PRESENT) == _PAGE_VRANGE);
+}
+
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_trans_huge(pmd_t pmd)
 {
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index eb3f941..24ed4c1 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -41,6 +41,8 @@ int discard_vpage(struct page *page);
 bool vrange_address(struct mm_struct *mm, unsigned long start,
 			unsigned long end);
 
+extern bool is_purged_vrange(struct mm_struct *mm, unsigned long address);
+
 #else
 
 static inline void vrange_init(void) {};
diff --git a/mm/memory.c b/mm/memory.c
index 494526a..cc369ab 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/vrange.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -840,7 +841,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
-		if (!pte_file(pte)) {
+		if (!pte_file(pte) && !pte_vrange(pte)) {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (swap_duplicate(entry) < 0)
@@ -1180,7 +1181,7 @@ again:
 		if (pte_file(ptent)) {
 			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
 				print_bad_pte(vma, addr, ptent, NULL);
-		} else {
+		} else if (!pte_vrange(ptent)) {
 			swp_entry_t entry = pte_to_swp_entry(ptent);
 
 			if (!non_swap_entry(entry))
@@ -3663,9 +3664,27 @@ int handle_pte_fault(struct mm_struct *mm,
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, flags, entry);
 			}
+anon:
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
+
+		if (unlikely(pte_vrange(entry))) {
+			if (!is_purged_vrange(mm, address)) {
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
diff --git a/mm/vrange.c b/mm/vrange.c
index 78aa252..89fcae4 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -343,7 +343,9 @@ int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
 
 	present = pte_present(*pte);
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush(vma, address, pte);
+
+	ptep_clear_flush(vma, address, pte);
+	pteval = pte_mkvrange(*pte);
 
 	update_hiwater_rss(mm);
 	dec_mm_counter(mm, MM_ANONPAGES);
@@ -357,10 +359,12 @@ int try_to_discard_one(struct page *page, struct vm_area_struct *vma,
 			BUG_ON(1);
 	}
 
+	set_pte_at(mm, address, pte, pteval);
+	__vrange_purge(mm, address, address + PAGE_SIZE -1);
 	pte_unmap_unlock(pte, ptl);
 	mmu_notifier_invalidate_page(mm, address);
+	vrange_unlock(mm);
 	ret = 1;
-	__vrange_purge(mm, address, address + PAGE_SIZE -1);
 out:
 	return ret;
 }
@@ -448,3 +452,21 @@ int discard_vpage(struct page *page)
 
 	return 0;
 }
+
+bool is_purged_vrange(struct mm_struct *mm, unsigned long address)
+{
+	struct rb_root *root = &mm->v_rb;
+	struct interval_tree_node *node;
+	struct vrange *range;
+	bool ret = false;
+
+	vrange_lock(mm);
+	node = interval_tree_iter_first(root, address, address + PAGE_SIZE - 1);
+	if (node) {
+		range = container_of(node, struct vrange, node);
+		if (range->purged)
+			ret = true;
+	}
+	vrange_unlock(mm);
+	return ret;
+}
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
