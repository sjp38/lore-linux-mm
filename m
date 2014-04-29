Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 728FE6B003B
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 17:21:43 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so826271pad.35
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:42 -0700 (PDT)
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
        by mx.google.com with ESMTPS id gr5si14310460pac.278.2014.04.29.14.21.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 14:21:42 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id fa1so855128pad.6
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:42 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 4/4] MADV_VOLATILE: Add page purging logic & SIGBUS trap
Date: Tue, 29 Apr 2014 14:21:23 -0700
Message-Id: <1398806483-19122-5-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This patch adds the hooks in the vmscan logic to purge volatile pages
and mark their pte as purged. With this, volatile pages will be purged
under pressure, and their ptes swap entry's marked. If the purged pages
are accessed before being marked non-volatile, we catch this and send a
SIGBUS.

This is a simplified implementation that uses logic from Minchan's earlier
efforts, so credit to Minchan for his work.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Keith Packard <keithp@keithp.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/mvolatile.h |   1 +
 mm/internal.h             |   2 -
 mm/memory.c               |   7 +++
 mm/mvolatile.c            | 119 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                 |   5 ++
 mm/vmscan.c               |  12 +++++
 6 files changed, 144 insertions(+), 2 deletions(-)

diff --git a/include/linux/mvolatile.h b/include/linux/mvolatile.h
index f53396b..8b797b7 100644
--- a/include/linux/mvolatile.h
+++ b/include/linux/mvolatile.h
@@ -2,5 +2,6 @@
 #define _LINUX_MVOLATILE_H
 
 int madvise_volatile(int bhv, unsigned long start, unsigned long end);
+extern int purge_volatile_page(struct page *page);
 
 #endif /* _LINUX_MVOLATILE_H */
diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..2213055 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -240,10 +240,8 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 
 extern pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma);
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern unsigned long vma_address(struct page *page,
 				 struct vm_area_struct *vma);
-#endif
 #else /* !CONFIG_MMU */
 static inline int mlocked_vma_newpage(struct vm_area_struct *v, struct page *p)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 037b812..cf024bd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,6 +61,7 @@
 #include <linux/string.h>
 #include <linux/dma-debug.h>
 #include <linux/debugfs.h>
+#include <linux/mvolatile.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3067,6 +3068,12 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			migration_entry_wait(mm, pmd, address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
+		} else if (is_purged_entry(entry)) {
+			page_table = pte_offset_map_lock(mm, pmd, address,
+									&ptl);
+			if (likely(pte_same(*page_table, orig_pte)))
+				ret = VM_FAULT_SIGBUS;
+			goto unlock;
 		} else {
 			print_bad_pte(vma, address, orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
diff --git a/mm/mvolatile.c b/mm/mvolatile.c
index 555d5c4..a7831d3 100644
--- a/mm/mvolatile.c
+++ b/mm/mvolatile.c
@@ -232,3 +232,122 @@ out:
 
 	return ret;
 }
+
+
+/**
+ * try_to_purge_one - Purge a volatile page from a vma
+ * @page: page to purge
+ * @vma: vma to purge page from
+ *
+ * Finds the pte for a page in a vma, marks the pte as purged
+ * and release the page.
+ */
+static void try_to_purge_one(struct page *page, struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *pte;
+	pte_t pteval;
+	spinlock_t *ptl;
+	unsigned long addr;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	addr = vma_address(page, vma);
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
+	set_pte_at(mm, addr, pte, swp_entry_to_pte(make_purged_entry()));
+
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, addr);
+}
+
+
+/**
+ * try_to_purge_vpage - check vma chain and purge from vmas marked volatile
+ * @page: page to purge
+ *
+ * Goes over all the vmas that hold a page, and where the vmas are volatile,
+ * purge the page from the vma.
+ *
+ * Returns 0 on success, -1 on error.
+ */
+static int try_to_purge_vpage(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	struct anon_vma_chain *avc;
+	pgoff_t pgoff;
+	int ret = 0;
+
+	anon_vma = page_lock_anon_vma_read(page);
+	if (!anon_vma)
+		return -1;
+
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	/*
+	 * During interating the loop, some processes could see a page as
+	 * purged while others could see a page as not-purged because we have
+	 * no global lock between parent and child for protecting mvolatile
+	 * system call during this loop. But it's not a problem because the
+	 * page is  not *SHARED* page but *COW* page so parent and child can
+	 * see other data anytime. The worst case by this race is a page was
+	 * purged but couldn't be discarded so it makes unnecessary pagefault
+	 * but it wouldn't be severe.
+	 */
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		struct vm_area_struct *vma = avc->vma;
+
+		if (!(vma->vm_flags & VM_VOLATILE)) {
+			ret = -1;
+			break;
+		}
+		try_to_purge_one(page, vma);
+	}
+	page_unlock_anon_vma_read(anon_vma);
+	return ret;
+}
+
+
+/**
+ * purge_volatile_page - If possible, purge the specified volatile page
+ * @page: page to purge
+ *
+ * Attempts to purge a volatile page, and if needed frees the swap page
+ *
+ * Returns 0 on success, -1 on error.
+ */
+int purge_volatile_page(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageLRU(page));
+
+	/* XXX - for now we only support anonymous volatile pages */
+	if (!PageAnon(page))
+		return -1;
+
+	if (!try_to_purge_vpage(page)) {
+		if (PageSwapCache(page))
+			try_to_free_swap(page);
+
+		if (page_freeze_refs(page, 1)) {
+			unlock_page(page);
+			return 0;
+		}
+	}
+	return -1;
+}
diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..efb5c61 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -728,6 +728,11 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 		pte_unmap_unlock(pte, ptl);
+		if (vma->vm_flags & VM_VOLATILE) {
+			pra->mapcount = 0;
+			pra->vm_flags |= VM_VOLATILE;
+			return SWAP_FAIL;
+		}
 	}
 
 	if (referenced) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f56c8d..a267926 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -43,6 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/mvolatile.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -697,6 +698,7 @@ enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
+	PAGEREF_PURGE,
 	PAGEREF_ACTIVATE,
 };
 
@@ -717,6 +719,13 @@ static enum page_references page_check_references(struct page *page,
 	if (vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
+	/*
+	 * If volatile page is reached on LRU's tail, we discard the
+	 * page without considering recycle the page.
+	 */
+	if (vm_flags & VM_VOLATILE)
+		return PAGEREF_PURGE;
+
 	if (referenced_ptes) {
 		if (PageSwapBacked(page))
 			return PAGEREF_ACTIVATE;
@@ -944,6 +953,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
+		case PAGEREF_PURGE:
+			if (!purge_volatile_page(page))
+				goto free_it;
 		case PAGEREF_KEEP:
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
