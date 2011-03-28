Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DE8EC8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:17:59 -0400 (EDT)
Received: by pzk32 with SMTP id 32so788757pzk.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 07:17:57 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH 2/2] ksm: take dirty bit as reference to avoid volatile pages
Date: Mon, 28 Mar 2011 22:17:44 +0800
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201103282217.44713.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Chris Wright <chrisw@sous-sol.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

Introduced ksm_page_changed() to reference the dirty bit of a pte. We clear 
the dirty bit for each pte scanned but don't flush the tlb. For a huge page, 
if one of the subpage has changed, we try to skip the whole huge page 
assuming(this is true by now) that ksmd linearly scans the address space.

A NEW_FLAG is also introduced as a status of rmap_item to make ksmd scan
more aggressively for new VMAs - only skip the pages considered to be volatile
by the dirty bits.

Suggested-by: Izik Eidus <izik.eidus@ravellosystems.com>
Signed-off-by: Nai Xia <nai.xia@gmail.com>

---
diff --git a/mm/ksm.c b/mm/ksm.c
index c2b2a94..2350cc6 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -107,6 +107,7 @@ struct ksm_scan {
 	unsigned long address;
 	struct rmap_item **rmap_list;
 	unsigned long seqnr;
+	unsigned long huge_skip; /* if a huge pte is dirty skip page */
 };
 
 /**
@@ -150,6 +151,7 @@ struct rmap_item {
 #define SEQNR_MASK	0x0ff	/* low bits of unstable tree seqnr */
 #define UNSTABLE_FLAG	0x100	/* is a node of the unstable tree */
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
+#define NEW_FLAG	0x400	/* this rmap_item is new */
 
 /* The stable and unstable tree heads */
 static struct rb_root root_stable_tree = RB_ROOT;
@@ -301,6 +303,11 @@ static inline int in_stable_tree(struct rmap_item *rmap_item)
 	return rmap_item->address & STABLE_FLAG;
 }
 
+static inline unsigned long get_address(struct rmap_item *rmap_item)
+{
+	return rmap_item->address & PAGE_MASK;
+}
+
 static void hold_anon_vma(struct rmap_item *rmap_item,
 			  struct anon_vma *anon_vma)
 {
@@ -390,7 +397,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 static void break_cow(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
-	unsigned long addr = rmap_item->address;
+	unsigned long addr = get_address(rmap_item);
 	struct vm_area_struct *vma;
 
 	/*
@@ -429,7 +436,7 @@ static struct page *page_trans_compound_anon(struct page *page)
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
-	unsigned long addr = rmap_item->address;
+	unsigned long addr = get_address(rmap_item);
 	struct vm_area_struct *vma;
 	struct page *page;
 
@@ -467,7 +474,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		else
 			ksm_pages_shared--;
 		ksm_drop_anon_vma(rmap_item);
-		rmap_item->address &= PAGE_MASK;
+		rmap_item->address &= ~STABLE_FLAG;
 		cond_resched();
 	}
 
@@ -555,8 +562,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 			ksm_pages_shared--;
 
 		ksm_drop_anon_vma(rmap_item);
-		rmap_item->address &= PAGE_MASK;
-
+		rmap_item->address &= ~STABLE_FLAG;
 	} else if (rmap_item->address & UNSTABLE_FLAG) {
 		unsigned char age;
 		/*
@@ -568,11 +574,13 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		 */
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
+
 		if (!age)
 			rb_erase(&rmap_item->node, &root_unstable_tree);
 
 		ksm_pages_unshared--;
-		rmap_item->address &= PAGE_MASK;
+		rmap_item->address &= ~UNSTABLE_FLAG;
+		rmap_item->address &= ~SEQNR_MASK;
 	}
 out:
 	cond_resched();		/* we're called from many long loops */
@@ -682,15 +690,6 @@ error:
 }
 #endif /* CONFIG_SYSFS */
 
-static u32 calc_checksum(struct page *page)
-{
-	u32 checksum;
-	void *addr = kmap_atomic(page, KM_USER0);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
-	kunmap_atomic(addr, KM_USER0);
-	return checksum;
-}
-
 static int memcmp_pages(struct page *page1, struct page *page2)
 {
 	char *addr1, *addr2;
@@ -718,13 +717,14 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	spinlock_t *ptl;
 	int swapped;
 	int err = -EFAULT;
+	int need_pte_unmap;
 
 	addr = page_address_in_vma(page, vma);
 	if (addr == -EFAULT)
 		goto out;
 
 	BUG_ON(PageTransCompound(page));
-	ptep = page_check_address(page, mm, addr, &ptl, 0);
+	ptep = page_check_address(page, mm, addr, &ptl, 0, &need_pte_unmap);
 	if (!ptep)
 		goto out;
 
@@ -760,7 +760,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	err = 0;
 
 out_unlock:
-	pte_unmap_unlock(ptep, ptl);
+	page_check_address_unmap_unlock(ptl, ptep, need_pte_unmap);
 out:
 	return err;
 }
@@ -936,12 +936,13 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
+	unsigned long address = get_address(rmap_item);
 
 	down_read(&mm->mmap_sem);
 	if (ksm_test_exit(mm))
 		goto out;
-	vma = find_vma(mm, rmap_item->address);
-	if (!vma || vma->vm_start > rmap_item->address)
+	vma = find_vma(mm, address);
+	if (!vma || vma->vm_start > address)
 		goto out;
 
 	err = try_to_merge_one_page(vma, page, kpage);
@@ -1171,6 +1172,62 @@ static void stable_tree_append(struct rmap_item *rmap_item,
 		ksm_pages_shared++;
 }
 
+static inline unsigned long get_huge_end_addr(unsigned long address)
+{
+	return (address & HPAGE_PMD_MASK) + HPAGE_SIZE;
+}
+
+/*
+ * ksm_page_changed - take the dirty bit of the pte as a hint for volatile
+ * pages. We clear the dirty bit for each pte scanned but don't flush the
+ * tlb. For huge pages, if one of the subpage has changed, we try to skip
+ * the whole huge page.
+ */
+static int ksm_page_changed(struct page *page, struct rmap_item *rmap_item)
+{
+	int ret = 1;
+	unsigned long address = get_address(rmap_item);
+	struct mm_struct *mm = rmap_item->mm;
+	pte_t *ptep, entry;
+	spinlock_t *ptl;
+	int need_pte_unmap;
+
+	if (ksm_scan.huge_skip) {
+		/* in process of skipping a huge page */
+		if (ksm_scan.mm_slot->mm == rmap_item->mm &&
+		    PageTail(page) && address < ksm_scan.huge_skip) {
+			ret = 1;
+			goto out;
+		} else {
+			ksm_scan.huge_skip = 0;
+		}
+	}
+
+	ptep = page_check_address(page, mm, address, &ptl, 0, &need_pte_unmap);
+	if (!ptep)
+		goto out;
+
+	entry = *ptep;
+	if (!pte_dirty(entry)) {
+		ret = 0;
+	} else {
+		set_page_dirty(page);
+		entry = pte_mkclean(entry);
+		set_pte_at(mm, address, ptep, entry);
+		if (PageTransCompound(page))
+			ksm_scan.huge_skip = get_huge_end_addr(address);
+	}
+
+	if (rmap_item->address & NEW_FLAG) {
+		rmap_item->address &= ~NEW_FLAG;
+		ret = 0;
+	}
+
+	page_check_address_unmap_unlock(ptl, ptep, need_pte_unmap);
+out:
+	return ret;
+}
+
 /*
  * cmp_and_merge_page - first see if page can be merged into the stable tree;
  * if not, compare checksum to previous and if it's the same, see if page can
@@ -1186,7 +1243,6 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
 	int err;
 
 	remove_rmap_item_from_tree(rmap_item);
@@ -1208,17 +1264,8 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 		return;
 	}
 
-	/*
-	 * If the hash value of the page has changed from the last time
-	 * we calculated it, this page is changing frequently: therefore we
-	 * don't want to insert it in the unstable tree, and we don't want
-	 * to waste our time searching for something identical to it there.
-	 */
-	checksum = calc_checksum(page);
-	if (rmap_item->oldchecksum != checksum) {
-		rmap_item->oldchecksum = checksum;
+	if (ksm_page_changed(page, rmap_item))
 		return;
-	}
 
 	tree_rmap_item =
 		unstable_tree_search_insert(rmap_item, page, &tree_page);
@@ -1264,9 +1311,9 @@ static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 
 	while (*rmap_list) {
 		rmap_item = *rmap_list;
-		if ((rmap_item->address & PAGE_MASK) == addr)
+		if (get_address(rmap_item) == addr)
 			return rmap_item;
-		if (rmap_item->address > addr)
+		if (get_address(rmap_item) > addr)
 			break;
 		*rmap_list = rmap_item->rmap_list;
 		remove_rmap_item_from_tree(rmap_item);
@@ -1278,6 +1325,7 @@ static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 		/* It has already been zeroed */
 		rmap_item->mm = mm_slot->mm;
 		rmap_item->address = addr;
+		rmap_item->address |= NEW_FLAG;
 		rmap_item->rmap_list = *rmap_list;
 		*rmap_list = rmap_item;
 	}
@@ -1614,12 +1662,12 @@ again:
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		unsigned long address = get_address(rmap_item);
 
 		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
+			if (address < vma->vm_start || address >= vma->vm_end)
 				continue;
 			/*
 			 * Initially we examine only the vma which covers this
@@ -1633,8 +1681,8 @@ again:
 			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 				continue;
 
-			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+			referenced += page_referenced_one(page, vma, address,
+						&mapcount, vm_flags);
 			if (!search_new_forks || !mapcount)
 				break;
 		}
@@ -1667,12 +1715,12 @@ again:
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		unsigned long address = get_address(rmap_item);
 
 		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
+			if (address < vma->vm_start || address >= vma->vm_end)
 				continue;
 			/*
 			 * Initially we examine only the vma which covers this
@@ -1683,8 +1731,7 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
-			ret = try_to_unmap_one(page, vma,
-					rmap_item->address, flags);
+			ret = try_to_unmap_one(page, vma, address, flags);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
 				anon_vma_unlock(anon_vma);
 				goto out;
@@ -1719,12 +1766,12 @@ again:
 		struct anon_vma *anon_vma = rmap_item->anon_vma;
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
+		unsigned long address = get_address(rmap_item);
 
 		anon_vma_lock(anon_vma);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
 			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
+			if (address < vma->vm_start || address >= vma->vm_end)
 				continue;
 			/*
 			 * Initially we examine only the vma which covers this
@@ -1735,7 +1782,7 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
-			ret = rmap_one(page, vma, rmap_item->address, arg);
+			ret = rmap_one(page, vma, address, arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock(anon_vma);
 				goto out;

---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
