From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:41:25 +0200
Message-Id: <20060712144125.16998.94552.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 23/39] mm: pgrep: nonresident page tracking hooks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add hooks for nonresident page tracking.
The policy has to define MM_POLICY_HAS_NONRESIDENT when it makes
use of these.

API:

Remeber a page - insert it into the nonresident page tracking.

	void pgrep_remember(struct zone *, struct page *);

Forget about a page - remove it from the nonresident page tracking.

	void pgrep_forget(struct address_space *, unsigned long);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    2 ++
 include/linux/mm_use_once_policy.h |    3 +++
 mm/memory.c                        |   28 ++++++++++++++++++++++++++++
 mm/swapfile.c                      |   12 ++++++++++--
 mm/vmscan.c                        |    2 ++
 5 files changed, 45 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:35.000000000 +0200
@@ -165,6 +165,9 @@ static inline void __pgrep_remove(struct
 		zone->policy.nr_inactive--;
 }
 
+#define pgrep_remember(z, p) do { } while (0)
+#define pgrep_forget(m, i) do { } while (0)
+
 static inline unsigned long __pgrep_nr_pages(struct zone *zone)
 {
 	return zone->policy.nr_active + zone->policy.nr_inactive;
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:35.000000000 +0200
@@ -88,6 +88,8 @@ extern unsigned long pgrep_shrink_zone(i
 /* int pgrep_is_active(struct page *); */
 /* void __pgrep_remove(struct zone *zone, struct page *page); */
 extern void pgrep_reinsert(struct list_head *);
+/* void pgrep_remember(struct zone *, struct page*); */
+/* void pgrep_forget(struct address_space *, unsigned long); */
 extern void pgrep_show(struct zone *);
 extern void pgrep_zoneinfo(struct zone *, struct seq_file *);
 extern void __pgrep_counts(unsigned long *, unsigned long *,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-07-12 16:09:19.000000000 +0200
@@ -603,6 +603,31 @@ int copy_page_range(struct mm_struct *ds
 	return 0;
 }
 
+#if defined MM_POLICY_HAS_NONRESIDENT
+static void free_file(struct vm_area_struct *vma,
+				unsigned long offset)
+{
+	struct address_space *mapping;
+	struct page *page;
+
+	if (!vma ||
+	    !vma->vm_file ||
+	    !vma->vm_file->f_mapping)
+		return;
+
+	mapping = vma->vm_file->f_mapping;
+	page = find_get_page(mapping, offset);
+	if (page) {
+		page_cache_release(page);
+		return;
+	}
+
+	pgrep_forget(mapping, offset);
+}
+#else
+#define free_file(a,b) do { } while (0)
+#endif
+
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
@@ -618,6 +643,7 @@ static unsigned long zap_pte_range(struc
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent)) {
+			free_file(vma, pte_to_pgoff(ptent));
 			(*zap_work)--;
 			continue;
 		}
@@ -677,6 +703,8 @@ static unsigned long zap_pte_range(struc
 			continue;
 		if (!pte_file(ptent))
 			free_swap_and_cache(pte_to_swp_entry(ptent));
+		else
+			free_file(vma, pte_to_pgoff(ptent));
 		pte_clear_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/swapfile.c	2006-07-12 16:09:19.000000000 +0200
@@ -28,6 +28,7 @@
 #include <linux/mutex.h>
 #include <linux/capability.h>
 #include <linux/syscalls.h>
+#include <linux/mm_page_replace.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
@@ -300,7 +301,8 @@ void swap_free(swp_entry_t entry)
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, swp_offset(entry));
+		if (!swap_entry_free(p, swp_offset(entry)))
+			pgrep_forget(&swapper_space, entry.val);
 		spin_unlock(&swap_lock);
 	}
 }
@@ -397,12 +399,18 @@ void free_swap_and_cache(swp_entry_t ent
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, swp_offset(entry)) == 1) {
+		switch (swap_entry_free(p, swp_offset(entry))) {
+		case 1:
 			page = find_get_page(&swapper_space, entry.val);
 			if (page && unlikely(TestSetPageLocked(page))) {
 				page_cache_release(page);
 				page = NULL;
 			}
+			break;
+
+		case 0:
+			pgrep_forget(&swapper_space, entry.val);
+			break;
 		}
 		spin_unlock(&swap_lock);
 	}
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:35.000000000 +0200
@@ -308,6 +308,7 @@ int remove_mapping(struct address_space 
 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
+		pgrep_remember(page_zone(page), page);
 		__delete_from_swap_cache(page);
 		write_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
@@ -315,6 +316,7 @@ int remove_mapping(struct address_space 
 		return 1;
 	}
 
+	pgrep_remember(page_zone(page), page);
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
 	__put_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
