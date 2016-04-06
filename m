Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9463E6B028E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:58:08 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id td3so41715731pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:58:08 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id by4si2256824pad.130.2016.04.06.15.51.35
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 15/30] thp: file pages support for split_huge_page()
Date: Thu,  7 Apr 2016 01:51:05 +0300
Message-Id: <1459983080-106718-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Basic scheme is the same as for anon THP.

Main differences:

  - File pages are on radix-tree, so we have head->_count offset by
    HPAGE_PMD_NR. The count got distributed to small pages during split.

  - mapping->tree_lock prevents non-lockless access to pages under split
    over radix-tree;

  - Lockless access is prevented by setting the head->_count to 0 during
    split;

  - After split, some pages can be beyond i_size. We drop them from
    radix-tree.

  - We don't setup migration entries. Just unmap pages. It helps
    handling cases when i_size is in the middle of the page: no need
    handle unmap pages beyond i_size manually.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c         |   2 +
 mm/huge_memory.c | 160 +++++++++++++++++++++++++++++++++++++++----------------
 mm/mempolicy.c   |   2 +
 3 files changed, 119 insertions(+), 45 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 39f751e1cb33..52f091e28f76 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -287,6 +287,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			ret = split_huge_page(page);
 			unlock_page(page);
 			put_page(page);
+			if (pmd_none(*pmd))
+				return no_page_table(vma, flags);
 		}
 
 		return ret ? ERR_PTR(ret) :
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4c3f94a443bc..8b1d2c474e87 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -31,6 +31,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -3146,12 +3147,15 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
 
 static void freeze_page(struct page *page)
 {
-	enum ttu_flags ttu_flags = TTU_MIGRATION | TTU_IGNORE_MLOCK |
-		TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED;
+	enum ttu_flags ttu_flags = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS |
+		TTU_RMAP_LOCKED;
 	int i, ret;
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 
+	if (PageAnon(page))
+		ttu_flags |= TTU_MIGRATION;
+
 	/* We only need TTU_SPLIT_HUGE_PMD once */
 	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
 	for (i = 1; !ret && i < HPAGE_PMD_NR; i++) {
@@ -3161,7 +3165,7 @@ static void freeze_page(struct page *page)
 
 		ret = try_to_unmap(page + i, ttu_flags);
 	}
-	VM_BUG_ON(ret);
+	VM_BUG_ON_PAGE(ret, page + i - 1);
 }
 
 static void unfreeze_page(struct page *page)
@@ -3183,15 +3187,20 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	/*
 	 * tail_page->_count is zero and not changing from under us. But
 	 * get_page_unless_zero() may be running from under us on the
-	 * tail_page. If we used atomic_set() below instead of atomic_inc(), we
-	 * would then run atomic_set() concurrently with
+	 * tail_page. If we used atomic_set() below instead of atomic_inc() or
+	 * atomic_add(), we would then run atomic_set() concurrently with
 	 * get_page_unless_zero(), and atomic_set() is implemented in C not
 	 * using locked ops. spin_unlock on x86 sometime uses locked ops
 	 * because of PPro errata 66, 92, so unless somebody can guarantee
 	 * atomic_set() here would be safe on all archs (and not only on x86),
-	 * it's safer to use atomic_inc().
+	 * it's safer to use atomic_inc()/atomic_add().
 	 */
-	page_ref_inc(page_tail);
+	if (PageAnon(head)) {
+		page_ref_inc(page_tail);
+	} else {
+		/* Additional pin to radix tree */
+		page_ref_add(page_tail, 2);
+	}
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
@@ -3227,25 +3236,44 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	lru_add_page_tail(head, page_tail, lruvec, list);
 }
 
-static void __split_huge_page(struct page *page, struct list_head *list)
+static void __split_huge_page(struct page *page, struct list_head *list,
+		unsigned long flags)
 {
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
+	pgoff_t end = -1;
 	int i;
 
-	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
-	for (i = HPAGE_PMD_NR - 1; i >= 1; i--)
+	if (!PageAnon(page))
+		end = DIV_ROUND_UP(i_size_read(head->mapping->host), PAGE_SIZE);
+
+	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
+		/* Some pages can be beyond i_size: drop them from page cache */
+		if (head[i].index >= end) {
+			__ClearPageDirty(head + i);
+			__delete_from_page_cache(head + i, NULL);
+			put_page(head + i);
+		}
+	}
 
 	ClearPageCompound(head);
-	spin_unlock_irq(&zone->lru_lock);
+	/* See comment in __split_huge_page_tail() */
+	if (PageAnon(head)) {
+		page_ref_inc(head);
+	} else {
+		/* Additional pin to radix tree */
+		page_ref_add(head, 2);
+		spin_unlock(&head->mapping->tree_lock);
+	}
+
+	spin_unlock_irqrestore(&page_zone(head)->lru_lock, flags);
 
 	unfreeze_page(head);
 
@@ -3312,36 +3340,54 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct page *head = compound_head(page);
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
-	struct anon_vma *anon_vma;
-	int count, mapcount, ret;
+	struct anon_vma *anon_vma = NULL;
+	struct address_space *mapping = NULL;
+	int count, mapcount, extra_pins, ret;
 	bool mlocked;
 	unsigned long flags;
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
-	VM_BUG_ON_PAGE(!PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
-	/*
-	 * The caller does not necessarily hold an mmap_sem that would prevent
-	 * the anon_vma disappearing so we first we take a reference to it
-	 * and then lock the anon_vma for write. This is similar to
-	 * page_lock_anon_vma_read except the write lock is taken to serialise
-	 * against parallel split or collapse operations.
-	 */
-	anon_vma = page_get_anon_vma(head);
-	if (!anon_vma) {
-		ret = -EBUSY;
-		goto out;
+	if (PageAnon(head)) {
+		/*
+		 * The caller does not necessarily hold an mmap_sem that would
+		 * prevent the anon_vma disappearing so we first we take a
+		 * reference to it and then lock the anon_vma for write. This
+		 * is similar to page_lock_anon_vma_read except the write lock
+		 * is taken to serialise against parallel split or collapse
+		 * operations.
+		 */
+		anon_vma = page_get_anon_vma(head);
+		if (!anon_vma) {
+			ret = -EBUSY;
+			goto out;
+		}
+		extra_pins = 0;
+		mapping = NULL;
+		anon_vma_lock_write(anon_vma);
+	} else {
+		mapping = head->mapping;
+
+		/* Truncated ? */
+		if (!mapping) {
+			ret = -EBUSY;
+			goto out;
+		}
+
+		/* Addidional pins from radix tree */
+		extra_pins = HPAGE_PMD_NR;
+		anon_vma = NULL;
+		i_mmap_lock_read(mapping);
 	}
-	anon_vma_lock_write(anon_vma);
 
 	/*
 	 * Racy check if we can split the page, before freeze_page() will
 	 * split PMDs
 	 */
-	if (total_mapcount(head) != page_count(head) - 1) {
+	if (total_mapcount(head) != page_count(head) - extra_pins - 1) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -3354,35 +3400,60 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (mlocked)
 		lru_add_drain();
 
+	/* prevent PageLRU to go away from under us, and freeze lru stats */
+	spin_lock_irqsave(&page_zone(head)->lru_lock, flags);
+
+	if (mapping) {
+		void **pslot;
+
+		spin_lock(&mapping->tree_lock);
+		pslot = radix_tree_lookup_slot(&mapping->page_tree,
+				page_index(head));
+		/*
+		 * Check if the head page is present in radix tree.
+		 * We assume all tail are present too, if head is there.
+		 */
+		if (radix_tree_deref_slot_protected(pslot,
+					&mapping->tree_lock) != head)
+			goto fail;
+	}
+
 	/* Prevent deferred_split_scan() touching ->_count */
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock(&pgdata->split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
-	if (!mapcount && count == 1) {
+	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
 		if (!list_empty(page_deferred_list(head))) {
 			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
-		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-		__split_huge_page(page, list);
+		spin_unlock(&pgdata->split_queue_lock);
+		__split_huge_page(page, list, flags);
 		ret = 0;
-	} else if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
-		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
-		pr_alert("total_mapcount: %u, page_count(): %u\n",
-				mapcount, count);
-		if (PageTail(page))
-			dump_page(head, NULL);
-		dump_page(page, "total_mapcount(head) > 0");
-		BUG();
 	} else {
-		spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
+		if (IS_ENABLED(CONFIG_DEBUG_VM) && mapcount) {
+			pr_alert("total_mapcount: %u, page_count(): %u\n",
+					mapcount, count);
+			if (PageTail(page))
+				dump_page(head, NULL);
+			dump_page(page, "total_mapcount(head) > 0");
+			BUG();
+		}
+		spin_unlock(&pgdata->split_queue_lock);
+fail:		if (mapping)
+			spin_unlock(&mapping->tree_lock);
+		spin_unlock_irqrestore(&page_zone(head)->lru_lock, flags);
 		unfreeze_page(head);
 		ret = -EBUSY;
 	}
 
 out_unlock:
-	anon_vma_unlock_write(anon_vma);
-	put_anon_vma(anon_vma);
+	if (anon_vma) {
+		anon_vma_unlock_write(anon_vma);
+		put_anon_vma(anon_vma);
+	}
+	if (mapping)
+		i_mmap_unlock_read(mapping);
 out:
 	count_vm_event(!ret ? THP_SPLIT_PAGE : THP_SPLIT_PAGE_FAILED);
 	return ret;
@@ -3505,8 +3576,7 @@ static int split_huge_pages_set(void *data, u64 val)
 			if (zone != page_zone(page))
 				goto next;
 
-			if (!PageHead(page) || !PageAnon(page) ||
-					PageHuge(page))
+			if (!PageHead(page) || PageHuge(page) || !PageLRU(page))
 				goto next;
 
 			total++;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 36cc01bc950a..148143974c5b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -515,6 +515,8 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		}
 	}
 
+	if (pmd_trans_unstable(pmd))
+		return 0;
 retry:
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
