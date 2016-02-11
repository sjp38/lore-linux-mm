Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 166026B0260
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:48 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id c10so30670876pfc.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:48 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q74si12880319pfq.207.2016.02.11.06.22.13
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 20/28] thp: file pages support for split_huge_page()
Date: Thu, 11 Feb 2016 17:21:48 +0300
Message-Id: <1455200516-132137-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Basic scheme is the same as for anon THP.

Main differences:

  - File pages are on radix-tree, so we have head->_count offset by
    HPAGE_PMD_NR. The count got distributed to small pages during split.

  - mapping->tree_lock prevents non-lockless access to pages under split
    over radix-tree;

  - lockless access is prevented by setting the head->_count to 0 during
    split;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c         |   2 +
 mm/huge_memory.c | 137 ++++++++++++++++++++++++++++++++++++++-----------------
 mm/mempolicy.c   |   2 +
 3 files changed, 100 insertions(+), 41 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 60f422a0af8b..76148816c0cd 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -285,6 +285,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			ret = split_huge_page(page);
 			unlock_page(page);
 			put_page(page);
+			if (pmd_none(*pmd))
+				return no_page_table(vma, flags);
 		}
 
 		return ret ? ERR_PTR(ret) :
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8e2d84698c15..ca7f21516c3a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -29,6 +29,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 #include <linux/debugfs.h>
 
 #include <asm/tlb.h>
@@ -3096,7 +3097,7 @@ static void freeze_page(struct page *page)
 	ret = try_to_unmap(page, ttu_flags | TTU_SPLIT_HUGE_PMD);
 	for (i = 1; !ret && i < HPAGE_PMD_NR; i++)
 		ret = try_to_unmap(page + i, ttu_flags);
-	VM_BUG_ON(ret);
+	VM_BUG_ON_PAGE(ret, page + i - 1);
 }
 
 static void unfreeze_page(struct page *page)
@@ -3118,15 +3119,20 @@ static void __split_huge_page_tail(struct page *head, int tail,
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
-	atomic_inc(&page_tail->_count);
+	if (PageAnon(head)) {
+		atomic_inc(&page_tail->_count);
+	} else {
+		/* Additional pin to radix tree */
+		atomic_add(2, &page_tail->_count);
+	}
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
@@ -3162,15 +3168,14 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	lru_add_page_tail(head, page_tail, lruvec, list);
 }
 
-static void __split_huge_page(struct page *page, struct list_head *list)
+static void __split_huge_page(struct page *page, struct list_head *list,
+		unsigned long flags)
 {
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
 	int i;
 
-	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
 	lruvec = mem_cgroup_page_lruvec(head, zone);
 
 	/* complete memcg works before add pages to LRU */
@@ -3180,7 +3185,16 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 		__split_huge_page_tail(head, i, lruvec, list);
 
 	ClearPageCompound(head);
-	spin_unlock_irq(&zone->lru_lock);
+	/* See comment in __split_huge_page_tail() */
+	if (PageAnon(head)) {
+		atomic_inc(&head->_count);
+	} else {
+		/* Additional pin to radix tree */
+		atomic_add(2, &head->_count);
+		spin_unlock(&head->mapping->tree_lock);
+	}
+
+	spin_unlock_irqrestore(&page_zone(head)->lru_lock, flags);
 
 	unfreeze_page(head);
 
@@ -3248,35 +3262,43 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	struct page *head = compound_head(page);
 	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
 	struct anon_vma *anon_vma;
-	int count, mapcount, ret;
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
+		extra_pins = 0;
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
+		anon_vma_lock_write(anon_vma);
+	} else {
+		/* Addidional pins from radix tree */
+		extra_pins = HPAGE_PMD_NR;
+		i_mmap_lock_read(head->mapping);
+		anon_vma = NULL;
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
@@ -3289,35 +3311,69 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (mlocked)
 		lru_add_drain();
 
+	/* prevent PageLRU to go away from under us, and freeze lru stats */
+	spin_lock_irqsave(&page_zone(head)->lru_lock, flags);
+
+	if (!anon_vma) {
+		void **pslot;
+
+		spin_lock(&head->mapping->tree_lock);
+		pslot = radix_tree_lookup_slot(&head->mapping->page_tree,
+				page_index(head));
+		/*
+		 * Check if the head page is present in radix tree.
+		 * We assume all tail are present too, if head is there.
+		 */
+		if (radix_tree_deref_slot_protected(pslot,
+					&head->mapping->tree_lock) != head)
+			goto fail;
+	}
+
 	/* Prevent deferred_split_scan() touching ->_count */
-	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
+	spin_lock(&pgdata->split_queue_lock);
 	count = page_count(head);
 	mapcount = total_mapcount(head);
-	if (!mapcount && count == 1) {
+	if (!mapcount && page_freeze_refs(head, 1 + extra_pins)) {
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
+fail:		if (!anon_vma)
+			spin_unlock(&head->mapping->tree_lock);
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
+	} else {
+		struct inode *inode = head->mapping->host;
+		i_mmap_unlock_read(head->mapping);
+
+		/* After split, some pages can be beyond i_size.
+		 * We need to drop them.
+		 *
+		 * TODO: Find generic solution.
+		 */
+		unmap_mapping_range(inode->i_mapping, inode->i_size, 0, 1);
+		shmem_truncate_range(inode, inode->i_size, (loff_t)-1);
+	}
 out:
 	count_vm_event(!ret ? THP_SPLIT_PAGE : THP_SPLIT_PAGE_FAILED);
 	return ret;
@@ -3440,8 +3496,7 @@ static int split_huge_pages_set(void *data, u64 val)
 			if (zone != page_zone(page))
 				goto next;
 
-			if (!PageHead(page) || !PageAnon(page) ||
-					PageHuge(page))
+			if (!PageHead(page) || PageHuge(page) || !PageLRU(page))
 				goto next;
 
 			total++;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8c5fd08c253c..5742271a026d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -515,6 +515,8 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
 		}
 	}
 
+	if (pmd_none(*pmd))
+		return 0;
 retry:
 	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
