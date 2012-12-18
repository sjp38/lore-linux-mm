Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 924F66B0068
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 01:49:41 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb11so296158pad.24
        for <linux-mm@kvack.org>; Mon, 17 Dec 2012 22:49:40 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v4 2/3] Discard volatile page
Date: Tue, 18 Dec 2012 15:47:53 +0900
Message-Id: <1355813274-571-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1355813274-571-1-git-send-email-minchan@kernel.org>
References: <1355813274-571-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

VM don't need to swap out volatile pages. Instead, it just discards
pages and set true to the vma's purge state so if user try to access
purged vma without calling mnovolatile, it will encounter SIGBUS.

Reclaimer reclaims volatile page when it reaches tail of LRU regardless
of the recent reference. So when the memory pressure doesn't happen,
it wouldn't be evicted so it can reduce the number of minor fault.
Although memory pressure happens, it doesn't be evicted until it reaches
tail of LRU. It could mitigate fault/data-regenaration overhead if
memory pressure isn't severe. But it's not solid design and need more
discussion.

Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Arun Sharma <asharma@fb.com>
Cc: sanjay@google.com
Cc: Paul Turner <pjt@google.com>
CC: David Rientjes <rientjes@google.com>
Cc: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |    3 ++
 mm/memory.c          |    2 ++
 mm/migrate.c         |    6 ++--
 mm/rmap.c            |   95 ++++++++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c          |    3 ++
 5 files changed, 105 insertions(+), 4 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bfe1f47..ed263bb 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -80,6 +80,8 @@ enum ttu_flags {
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
 	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
+	/* ignore volatile. Should be revisit to handle migration entry */
+	TTU_IGNORE_VOLATILE = (1 << 11),
 };
 
 #ifdef CONFIG_MMU
@@ -261,5 +263,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_DISCARD	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..71e06fe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3459,6 +3459,8 @@ int handle_pte_fault(struct mm_struct *mm,
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, flags, entry);
 			}
+			if (unlikely(vma->vm_flags & VM_VOLATILE))
+				return VM_FAULT_SIGBUS;
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..bf9d76a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -800,7 +800,8 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	}
 
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|
+				TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
 
 skip_unmap:
 	if (!page_mapped(page))
@@ -915,7 +916,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
-	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|
+			TTU_IGNORE_ACCESS|TTU_IGNORE_VOLATILE);
 
 	if (!page_mapped(hpage))
 		rc = move_to_new_page(new_hpage, hpage, 1, mode);
diff --git a/mm/rmap.c b/mm/rmap.c
index 7f4493c..02ee1a3 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1189,6 +1189,64 @@ out:
 		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
+int try_to_zap_one(struct page *page, struct vm_area_struct *vma,
+		unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	swp_entry_t entry = { .val = page_private(page) };
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageAnon(page));
+	VM_BUG_ON(!PageSwapCache(page));
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		return 0;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		return 0;
+
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		return 0;
+
+	VM_BUG_ON(pmd_trans_huge(*pmd));
+
+	pte = pte_offset_map(pmd, address);
+	/* Make a quick check before getting the lock */
+	if(!pte_present(*pte)) {
+		pte_unmap(pte);
+		return 0;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+
+	if (entry.val != pte_to_swp_entry(*pte).val) {
+		pte_unmap_unlock(pte, ptl);
+		return 0;
+	}
+
+	/* Nuke the page table entry. */
+	flush_cache_page(vma, address, page_to_pfn(page));
+	ptep_clear_flush(vma, address, pte);
+
+	/* try_to_unmap_one increased MM_SWAPENTS */
+	dec_mm_counter(mm, MM_SWAPENTS);
+	swap_free(entry);
+
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, address);
+	return 1;
+}
+
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
@@ -1475,6 +1533,10 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
+	bool is_volatile = true;
+
+	if (flags & TTU_IGNORE_VOLATILE)
+		is_volatile = false;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
@@ -1494,8 +1556,17 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 		 * temporary VMAs until after exec() completes.
 		 */
 		if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
-				is_vma_temporary_stack(vma))
+				is_vma_temporary_stack(vma)) {
+			is_volatile = false;
 			continue;
+		}
+
+		/*
+		 * A volatile page will only be purged if ALL vmas
+		 * pointing to it are VM_VOLATILE.
+		 */
+		if (!(vma->vm_flags & VM_VOLATILE))
+			is_volatile = false;
 
 		address = vma_address(page, vma);
 		ret = try_to_unmap_one(page, vma, address, flags);
@@ -1503,6 +1574,25 @@ static int try_to_unmap_anon(struct page *page, enum ttu_flags flags)
 			break;
 	}
 
+	if (page_mapped(page) || is_volatile == false)
+		goto out;
+
+	/*
+	 * Here, all vmas point to the page are volatile and all ptes have
+	 * swap entry. PG_locked prevents race of do_swap_page.
+	 */
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		struct vm_area_struct *vma = avc->vma;
+		unsigned long address;
+
+		address = vma_address(page, vma);
+		if (try_to_zap_one(page, vma, address))
+			vma->purged = true;
+	}
+	/* We're throwing this page out, so mark it clean */
+	ClearPageDirty(page);
+	ret = SWAP_DISCARD;
+out:
 	page_unlock_anon_vma(anon_vma);
 	return ret;
 }
@@ -1628,6 +1718,7 @@ out:
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  * SWAP_MLOCK	- page is mlocked.
+ * SWAP_DISCARD - page is volatile.
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
@@ -1642,7 +1733,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 		ret = try_to_unmap_anon(page, flags);
 	else
 		ret = try_to_unmap_file(page, flags);
-	if (ret != SWAP_MLOCK && !page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page) && ret != SWAP_DISCARD)
 		ret = SWAP_SUCCESS;
 	return ret;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7ed376..cfe95d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -793,6 +793,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, ttu_flags)) {
+			case SWAP_DISCARD:
+				goto discard_page;
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -861,6 +863,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
+discard_page:
 		/*
 		 * If the page has buffers, try to free the buffer mappings
 		 * associated with this page. If we succeed we try to free
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
