Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5B28390013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 09:36:45 -0400 (EDT)
Received: by iyl8 with SMTP id 8so6289595iyl.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 06:36:41 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH 2/2 V2] ksm: take dirty bit as reference to avoid volatile pages scanning
Date: Tue, 21 Jun 2011 21:36:17 +0800
References: <201106212055.25400.nai.xia@gmail.com>
In-Reply-To: <201106212055.25400.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106212136.17445.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

Introduced ksm_page_changed() to reference the dirty bit of a pte. We clear 
the dirty bit for each pte scanned but don't flush the tlb. For a huge page, 
if one of the subpage has changed, we try to skip the whole huge page 
assuming(this is true by now) that ksmd linearly scans the address space.

A NEW_FLAG is also introduced as a status of rmap_item to make ksmd scan
more aggressively for new VMAs - only skip the pages considered to be volatile
by the dirty bits. This can be enabled/disabled through KSM's sysfs interface.

Signed-off-by: Nai Xia <nai.xia@gmail.com>
Acked-by: Izik Eidus <izik.eidus@ravellosystems.com>
---
 mm/ksm.c |  189 ++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 155 insertions(+), 34 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9a68b0c..021ae6f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -108,6 +108,7 @@ struct ksm_scan {
 	unsigned long address;
 	struct rmap_item **rmap_list;
 	unsigned long seqnr;
+	unsigned long huge_skip; /* if a huge pte is dirty, skip subpages */
 };
 
 /**
@@ -151,6 +152,7 @@ struct rmap_item {
 #define SEQNR_MASK	0x0ff	/* low bits of unstable tree seqnr */
 #define UNSTABLE_FLAG	0x100	/* is a node of the unstable tree */
 #define STABLE_FLAG	0x200	/* is listed from the stable tree */
+#define NEW_FLAG	0x400	/* this rmap_item is new */
 
 /* The stable and unstable tree heads */
 static struct rb_root root_stable_tree = RB_ROOT;
@@ -189,6 +191,13 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+/*
+ * Skip page changed test and merge pages the first time we scan a page, this
+ * is useful for speeding up the merging of very large VMAs, since the
+ * scanning also allocs memory.
+ */
+static unsigned int ksm_merge_at_once = 0;
+
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
 #define KSM_RUN_UNMERGE	2
@@ -374,10 +383,15 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
 }
 
+static inline unsigned long get_address(struct rmap_item *rmap_item)
+{
+	return rmap_item->address & PAGE_MASK;
+}
+
 static void break_cow(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
-	unsigned long addr = rmap_item->address;
+	unsigned long addr = get_address(rmap_item);
 	struct vm_area_struct *vma;
 
 	/*
@@ -416,7 +430,7 @@ static struct page *page_trans_compound_anon(struct page *page)
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
-	unsigned long addr = rmap_item->address;
+	unsigned long addr = get_address(rmap_item);
 	struct vm_area_struct *vma;
 	struct page *page;
 
@@ -454,7 +468,7 @@ static void remove_node_from_stable_tree(struct stable_node *stable_node)
 		else
 			ksm_pages_shared--;
 		put_anon_vma(rmap_item->anon_vma);
-		rmap_item->address &= PAGE_MASK;
+		rmap_item->address &= ~STABLE_FLAG;
 		cond_resched();
 	}
 
@@ -542,7 +556,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 			ksm_pages_shared--;
 
 		put_anon_vma(rmap_item->anon_vma);
-		rmap_item->address &= PAGE_MASK;
+		rmap_item->address &= ~STABLE_FLAG;
 
 	} else if (rmap_item->address & UNSTABLE_FLAG) {
 		unsigned char age;
@@ -554,12 +568,14 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		 * than left over from before.
 		 */
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
-		BUG_ON(age > 1);
+		BUG_ON (age > 1);
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
@@ -705,13 +721,14 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
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
 
@@ -747,7 +764,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	err = 0;
 
 out_unlock:
-	pte_unmap_unlock(ptep, ptl);
+	page_check_address_unmap_unlock(ptl, ptep, need_pte_unmap);
 out:
 	return err;
 }
@@ -923,12 +940,13 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
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
@@ -1159,6 +1177,94 @@ static void stable_tree_append(struct rmap_item *rmap_item,
 		ksm_pages_shared++;
 }
 
+static inline unsigned long get_huge_end_addr(unsigned long address)
+{
+	return (address & HPAGE_PMD_MASK) + HPAGE_SIZE;
+}
+
+static inline int ksm_ptep_test_and_clear_dirty(pte_t *ptep)
+{
+	int ret = 0;
+
+	if (pte_dirty(*ptep))
+		ret = test_and_clear_bit(_PAGE_BIT_DIRTY,
+					 (unsigned long *) &ptep->pte);
+
+	return ret;
+}
+
+#define ksm_ptep_test_and_clear_dirty_notify(__mm, __address, __ptep)	\
+({									\
+	int __dirty;							\
+	struct mm_struct *___mm = __mm;					\
+	unsigned long ___address = __address;				\
+	__dirty = ksm_ptep_test_and_clear_dirty(__ptep);		\
+	__dirty |= mmu_notifier_test_and_clear_dirty(___mm,		\
+						     ___address);	\
+	__dirty;							\
+})
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
+	pte_t *ptep;
+	spinlock_t *ptl;
+	int need_pte_unmap;
+	unsigned int checksum;
+
+	/* If the the ptes are not updated by guest OS, we rely on checksum. */
+	if (!mmu_notifier_dirty_update(mm)) {
+		checksum = calc_checksum(page);
+		if (rmap_item->oldchecksum != checksum)
+			rmap_item->oldchecksum = checksum;
+		else
+			ret = 0;
+		goto out;
+	}
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
+	if (ksm_ptep_test_and_clear_dirty_notify(mm, address, ptep)) {
+		set_page_dirty(page);
+		if (PageTransCompound(page))
+			ksm_scan.huge_skip = get_huge_end_addr(address);
+	} else {
+		ret = 0;
+	}
+
+	page_check_address_unmap_unlock(ptl, ptep, need_pte_unmap);
+
+out:
+	/* This is simply to speed up merging in the first scan. */
+	if (ksm_merge_at_once && rmap_item->address & NEW_FLAG) {
+		rmap_item->address &= ~NEW_FLAG;
+		ret = 0;
+	}
+
+	return ret;
+}
+
 /*
  * cmp_and_merge_page - first see if page can be merged into the stable tree;
  * if not, compare checksum to previous and if it's the same, see if page can
@@ -1174,7 +1280,6 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
 	int err;
 
 	remove_rmap_item_from_tree(rmap_item);
@@ -1196,17 +1301,8 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
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
@@ -1252,9 +1348,9 @@ static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 
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
@@ -1266,6 +1362,7 @@ static struct rmap_item *get_next_rmap_item(struct mm_slot *mm_slot,
 		/* It has already been zeroed */
 		rmap_item->mm = mm_slot->mm;
 		rmap_item->address = addr;
+		rmap_item->address |= NEW_FLAG;
 		rmap_item->rmap_list = *rmap_list;
 		*rmap_list = rmap_item;
 	}
@@ -1608,12 +1705,12 @@ again:
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
@@ -1627,8 +1724,8 @@ again:
 			if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 				continue;
 
-			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+			referenced += page_referenced_one(page, vma, address,
+						&mapcount, vm_flags);
 			if (!search_new_forks || !mapcount)
 				break;
 		}
@@ -1661,12 +1758,12 @@ again:
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
@@ -1677,8 +1774,7 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
-			ret = try_to_unmap_one(page, vma,
-					rmap_item->address, flags);
+			ret = try_to_unmap_one(page, vma, address, flags);
 			if (ret != SWAP_AGAIN || !page_mapped(page)) {
 				anon_vma_unlock(anon_vma);
 				goto out;
@@ -1713,12 +1809,12 @@ again:
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
@@ -1729,7 +1825,7 @@ again:
 			if ((rmap_item->mm == vma->vm_mm) == search_new_forks)
 				continue;
 
-			ret = rmap_one(page, vma, rmap_item->address, arg);
+			ret = rmap_one(page, vma, address, arg);
 			if (ret != SWAP_AGAIN) {
 				anon_vma_unlock(anon_vma);
 				goto out;
@@ -1872,6 +1968,30 @@ static ssize_t pages_to_scan_store(struct kobject *kobj,
 }
 KSM_ATTR(pages_to_scan);
 
+static ssize_t merge_at_once_show(struct kobject *kobj,
+				  struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u\n", ksm_merge_at_once);
+}
+
+static ssize_t merge_at_once_store(struct kobject *kobj,
+				   struct kobj_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int err;
+	unsigned long merge_at_once;
+
+	err = strict_strtoul(buf, 10, &merge_at_once);
+	if (err || merge_at_once > UINT_MAX)
+		return -EINVAL;
+
+	ksm_merge_at_once = merge_at_once;
+
+	return count;
+}
+KSM_ATTR(merge_at_once);
+
+
 static ssize_t run_show(struct kobject *kobj, struct kobj_attribute *attr,
 			char *buf)
 {
@@ -1975,6 +2095,7 @@ static struct attribute *ksm_attrs[] = {
 	&pages_unshared_attr.attr,
 	&pages_volatile_attr.attr,
 	&full_scans_attr.attr,
+	&merge_at_once_attr.attr,
 	NULL,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
