Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EFF5A6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:56:00 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:15:15 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 6/12] ksm: five little cleanups
In-Reply-To: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
Message-ID: <Pine.LNX.4.64.0908031314070.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1. We don't use __break_cow entry point now: merge it into break_cow.
2. remove_all_slot_rmap_items is just a special case of
   remove_trailing_rmap_items: use the latter instead.
3. Extend comment on unmerge_ksm_pages and rmap_items.
4. try_to_merge_two_pages should use try_to_merge_with_ksm_page
   instead of duplicating its code; and so swap them around.
5. Comment on cmp_and_merge_page described last year's: update it.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/ksm.c |  112 ++++++++++++++++++++---------------------------------
 1 file changed, 44 insertions(+), 68 deletions(-)

--- ksm5/mm/ksm.c	2009-08-02 13:50:07.000000000 +0100
+++ ksm6/mm/ksm.c	2009-08-02 13:50:15.000000000 +0100
@@ -315,22 +315,18 @@ static void break_ksm(struct vm_area_str
 	/* Which leaves us looping there if VM_FAULT_OOM: hmmm... */
 }
 
-static void __break_cow(struct mm_struct *mm, unsigned long addr)
+static void break_cow(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma;
 
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, addr);
 	if (!vma || vma->vm_start > addr)
-		return;
+		goto out;
 	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
-		return;
+		goto out;
 	break_ksm(vma, addr);
-}
-
-static void break_cow(struct mm_struct *mm, unsigned long addr)
-{
-	down_read(&mm->mmap_sem);
-	__break_cow(mm, addr);
+out:
 	up_read(&mm->mmap_sem);
 }
 
@@ -439,17 +435,6 @@ static void remove_rmap_item_from_tree(s
 	cond_resched();		/* we're called from many long loops */
 }
 
-static void remove_all_slot_rmap_items(struct mm_slot *mm_slot)
-{
-	struct rmap_item *rmap_item, *node;
-
-	list_for_each_entry_safe(rmap_item, node, &mm_slot->rmap_list, link) {
-		remove_rmap_item_from_tree(rmap_item);
-		list_del(&rmap_item->link);
-		free_rmap_item(rmap_item);
-	}
-}
-
 static void remove_trailing_rmap_items(struct mm_slot *mm_slot,
 				       struct list_head *cur)
 {
@@ -471,6 +456,11 @@ static void remove_trailing_rmap_items(s
  * page and upping mmap_sem.  Nor does it fit with the way we skip dup'ing
  * rmap_items from parent to child at fork time (so as not to waste time
  * if exit comes before the next scan reaches it).
+ *
+ * Similarly, although we'd like to remove rmap_items (so updating counts
+ * and freeing memory) when unmerging an area, it's easier to leave that
+ * to the next pass of ksmd - consider, for example, how ksmd might be
+ * in cmp_and_merge_page on one of the rmap_items we would be removing.
  */
 static void unmerge_ksm_pages(struct vm_area_struct *vma,
 			      unsigned long start, unsigned long end)
@@ -495,7 +485,7 @@ static void unmerge_and_remove_all_rmap_
 				continue;
 			unmerge_ksm_pages(vma, vma->vm_start, vma->vm_end);
 		}
-		remove_all_slot_rmap_items(mm_slot);
+		remove_trailing_rmap_items(mm_slot, mm_slot->rmap_list.next);
 		up_read(&mm->mmap_sem);
 	}
 
@@ -533,7 +523,7 @@ static void remove_mm_from_lists(struct
 	list_del(&mm_slot->mm_list);
 	spin_unlock(&ksm_mmlist_lock);
 
-	remove_all_slot_rmap_items(mm_slot);
+	remove_trailing_rmap_items(mm_slot, mm_slot->rmap_list.next);
 	free_mm_slot(mm_slot);
 	clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 }
@@ -740,6 +730,29 @@ out:
 }
 
 /*
+ * try_to_merge_with_ksm_page - like try_to_merge_two_pages,
+ * but no new kernel page is allocated: kpage must already be a ksm page.
+ */
+static int try_to_merge_with_ksm_page(struct mm_struct *mm1,
+				      unsigned long addr1,
+				      struct page *page1,
+				      struct page *kpage)
+{
+	struct vm_area_struct *vma;
+	int err = -EFAULT;
+
+	down_read(&mm1->mmap_sem);
+	vma = find_vma(mm1, addr1);
+	if (!vma || vma->vm_start > addr1)
+		goto out;
+
+	err = try_to_merge_one_page(vma, page1, kpage);
+out:
+	up_read(&mm1->mmap_sem);
+	return err;
+}
+
+/*
  * try_to_merge_two_pages - take two identical pages and prepare them
  * to be merged into one page.
  *
@@ -772,9 +785,8 @@ static int try_to_merge_two_pages(struct
 	down_read(&mm1->mmap_sem);
 	vma = find_vma(mm1, addr1);
 	if (!vma || vma->vm_start > addr1) {
-		put_page(kpage);
 		up_read(&mm1->mmap_sem);
-		return err;
+		goto out;
 	}
 
 	copy_user_highpage(kpage, page1, addr1, vma);
@@ -782,56 +794,20 @@ static int try_to_merge_two_pages(struct
 	up_read(&mm1->mmap_sem);
 
 	if (!err) {
-		down_read(&mm2->mmap_sem);
-		vma = find_vma(mm2, addr2);
-		if (!vma || vma->vm_start > addr2) {
-			put_page(kpage);
-			up_read(&mm2->mmap_sem);
-			break_cow(mm1, addr1);
-			return -EFAULT;
-		}
-
-		err = try_to_merge_one_page(vma, page2, kpage);
-		up_read(&mm2->mmap_sem);
-
+		err = try_to_merge_with_ksm_page(mm2, addr2, page2, kpage);
 		/*
-		 * If the second try_to_merge_one_page failed, we have a
-		 * ksm page with just one pte pointing to it, so break it.
+		 * If that fails, we have a ksm page with only one pte
+		 * pointing to it: so break it.
 		 */
 		if (err)
 			break_cow(mm1, addr1);
 	}
-
+out:
 	put_page(kpage);
 	return err;
 }
 
 /*
- * try_to_merge_with_ksm_page - like try_to_merge_two_pages,
- * but no new kernel page is allocated: kpage must already be a ksm page.
- */
-static int try_to_merge_with_ksm_page(struct mm_struct *mm1,
-				      unsigned long addr1,
-				      struct page *page1,
-				      struct page *kpage)
-{
-	struct vm_area_struct *vma;
-	int err = -EFAULT;
-
-	down_read(&mm1->mmap_sem);
-	vma = find_vma(mm1, addr1);
-	if (!vma || vma->vm_start > addr1) {
-		up_read(&mm1->mmap_sem);
-		return err;
-	}
-
-	err = try_to_merge_one_page(vma, page1, kpage);
-	up_read(&mm1->mmap_sem);
-
-	return err;
-}
-
-/*
  * stable_tree_search - search page inside the stable tree
  * @page: the page that we are searching identical pages to.
  * @page2: pointer into identical page that we are holding inside the stable
@@ -1040,10 +1016,10 @@ static void stable_tree_append(struct rm
 }
 
 /*
- * cmp_and_merge_page - take a page computes its hash value and check if there
- * is similar hash value to different page,
- * in case we find that there is similar hash to different page we call to
- * try_to_merge_two_pages().
+ * cmp_and_merge_page - first see if page can be merged into the stable tree;
+ * if not, compare checksum to previous and if it's the same, see if page can
+ * be inserted into the unstable tree, or merged with a page already there and
+ * both transferred to the stable tree.
  *
  * @page: the page that we are searching identical page to.
  * @rmap_item: the reverse mapping into the virtual address of this page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
