Message-Id: <4t16i2$m83mm@orsmga001.jf.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] tightening hugetlb strict accounting
Date: Fri, 14 Apr 2006 11:11:38 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, 'Adam Litke' <agl@us.ibm.com>
Cc: akpm@osdl.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Current hugetlb strict accounting for shared mapping always assume
mapping starts at zero file offset and reserves pages between zero
and size of the file.  This assumption often reserves (or lock down)
a lot more pages then necessary if application maps at none zero file
offset.  libhugetlbfs is one example that requires proper reservation
on shared mapping starts at none zero offset.

This patch extends the reservation and hugetlb strict accounting to
support any arbitrary pair of (offset, len), resulting a much more robust
and accurate scheme.  More importantly, it won't lock down any hugetlb
pages outside file mapping.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
Acked-by: Adam Litke <agl@us.ibm.com>


---
David, wli - are you ok with this patch?
Andrew - can we please give this a whirl in -mm?


 fs/hugetlbfs/inode.c    |   21 +--
 include/linux/hugetlb.h |    8 -
 mm/hugetlb.c            |  282 +++++++++++++++++++++++++++---------------------
 3 files changed, 173 insertions(+), 138 deletions(-)

diff -Nurp linux-2.6.16/fs/hugetlbfs/inode.c linux-2.6.16.ken/fs/hugetlbfs/inode.c
--- linux-2.6.16/fs/hugetlbfs/inode.c	2006-04-13 17:56:13.000000000 -0700
+++ linux-2.6.16.ken/fs/hugetlbfs/inode.c	2006-04-13 19:33:14.000000000 -0700
@@ -59,7 +59,6 @@ static void huge_pagevec_release(struct 
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
 	loff_t len, vma_len;
 	int ret;
 
@@ -87,9 +86,10 @@ static int hugetlbfs_file_mmap(struct fi
 	if (!(vma->vm_flags & VM_WRITE) && len > inode->i_size)
 		goto out;
 
-	if (vma->vm_flags & VM_MAYSHARE)
-		if (hugetlb_extend_reservation(info, len >> HPAGE_SHIFT) != 0)
-			goto out;
+	if (vma->vm_flags & VM_MAYSHARE &&
+	    hugetlb_reserve_pages(inode, vma->vm_pgoff >> (HPAGE_SHIFT-PAGE_SHIFT),
+				  len >> HPAGE_SHIFT))
+		goto out;
 
 	ret = 0;
 	hugetlb_prefault_arch_hook(vma->vm_mm);
@@ -195,12 +195,8 @@ static void truncate_hugepages(struct in
 	const pgoff_t start = lstart >> HPAGE_SHIFT;
 	struct pagevec pvec;
 	pgoff_t next;
-	int i;
+	int i, freed = 0;
 
-	hugetlb_truncate_reservation(HUGETLBFS_I(inode),
-				     lstart >> HPAGE_SHIFT);
-	if (!mapping->nrpages)
-		return;
 	pagevec_init(&pvec, 0);
 	next = start;
 	while (1) {
@@ -221,10 +217,12 @@ static void truncate_hugepages(struct in
 			truncate_huge_page(page);
 			unlock_page(page);
 			hugetlb_put_quota(mapping);
+			freed++;
 		}
 		huge_pagevec_release(&pvec);
 	}
 	BUG_ON(!lstart && mapping->nrpages);
+	hugetlb_unreserve_pages(inode, start, freed);
 }
 
 static void hugetlbfs_delete_inode(struct inode *inode)
@@ -366,6 +364,7 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
 		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
@@ -538,7 +537,6 @@ static struct inode *hugetlbfs_alloc_ino
 		hugetlbfs_inc_free_inodes(sbinfo);
 		return NULL;
 	}
-	p->prereserved_hpages = 0;
 	return &p->vfs_inode;
 }
 
@@ -781,8 +779,7 @@ struct file *hugetlb_zero_setup(size_t s
 		goto out_file;
 
 	error = -ENOMEM;
-	if (hugetlb_extend_reservation(HUGETLBFS_I(inode),
-				       size >> HPAGE_SHIFT) != 0)
+	if (hugetlb_reserve_pages(inode, 0, size >> HPAGE_SHIFT))
 		goto out_inode;
 
 	d_instantiate(dentry, inode);
diff -Nurp linux-2.6.16/include/linux/hugetlb.h linux-2.6.16.ken/include/linux/hugetlb.h
--- linux-2.6.16/include/linux/hugetlb.h	2006-04-13 17:56:13.000000000 -0700
+++ linux-2.6.16.ken/include/linux/hugetlb.h	2006-04-13 19:27:48.000000000 -0700
@@ -23,6 +23,8 @@ int hugetlb_report_node_meminfo(int, cha
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
+int hugetlb_reserve_pages(struct inode *inode, long from, long to);
+void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long max_huge_pages;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
@@ -139,8 +141,6 @@ struct hugetlbfs_sb_info {
 
 struct hugetlbfs_inode_info {
 	struct shared_policy policy;
-	/* Protected by the (global) hugetlb_lock */
-	unsigned long prereserved_hpages;
 	struct inode vfs_inode;
 };
 
@@ -157,10 +157,6 @@ static inline struct hugetlbfs_sb_info *
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
 struct file *hugetlb_zero_setup(size_t);
-int hugetlb_extend_reservation(struct hugetlbfs_inode_info *info,
-			       unsigned long atleast_hpages);
-void hugetlb_truncate_reservation(struct hugetlbfs_inode_info *info,
-				  unsigned long atmost_hpages);
 int hugetlb_get_quota(struct address_space *mapping);
 void hugetlb_put_quota(struct address_space *mapping);
 
diff -Nurp linux-2.6.16/mm/hugetlb.c linux-2.6.16.ken/mm/hugetlb.c
--- linux-2.6.16/mm/hugetlb.c	2006-04-13 17:56:14.000000000 -0700
+++ linux-2.6.16.ken/mm/hugetlb.c	2006-04-13 19:27:04.000000000 -0700
@@ -22,7 +22,7 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-static unsigned long nr_huge_pages, free_huge_pages, reserved_huge_pages;
+static unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
 unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
@@ -123,39 +123,13 @@ static int alloc_fresh_huge_page(void)
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr)
 {
-	struct inode *inode = vma->vm_file->f_dentry->d_inode;
 	struct page *page;
-	int use_reserve = 0;
-	unsigned long idx;
 
 	spin_lock(&hugetlb_lock);
-
-	if (vma->vm_flags & VM_MAYSHARE) {
-
-		/* idx = radix tree index, i.e. offset into file in
-		 * HPAGE_SIZE units */
-		idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
-			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
-
-		/* The hugetlbfs specific inode info stores the number
-		 * of "guaranteed available" (huge) pages.  That is,
-		 * the first 'prereserved_hpages' pages of the inode
-		 * are either already instantiated, or have been
-		 * pre-reserved (by hugetlb_reserve_for_inode()). Here
-		 * we're in the process of instantiating the page, so
-		 * we use this to determine whether to draw from the
-		 * pre-reserved pool or the truly free pool. */
-		if (idx < HUGETLBFS_I(inode)->prereserved_hpages)
-			use_reserve = 1;
-	}
-
-	if (!use_reserve) {
-		if (free_huge_pages <= reserved_huge_pages)
-			goto fail;
-	} else {
-		BUG_ON(reserved_huge_pages == 0);
-		reserved_huge_pages--;
-	}
+	if (vma->vm_flags & VM_MAYSHARE)
+		resv_huge_pages--;
+	else if (free_huge_pages <= resv_huge_pages)
+		goto fail;
 
 	page = dequeue_huge_page(vma, addr);
 	if (!page)
@@ -165,96 +139,11 @@ static struct page *alloc_huge_page(stru
 	set_page_refcounted(page);
 	return page;
 
- fail:
-	WARN_ON(use_reserve); /* reserved allocations shouldn't fail */
+fail:
 	spin_unlock(&hugetlb_lock);
 	return NULL;
 }
 
-/* hugetlb_extend_reservation()
- *
- * Ensure that at least 'atleast' hugepages are, and will remain,
- * available to instantiate the first 'atleast' pages of the given
- * inode.  If the inode doesn't already have this many pages reserved
- * or instantiated, set aside some hugepages in the reserved pool to
- * satisfy later faults (or fail now if there aren't enough, rather
- * than getting the SIGBUS later).
- */
-int hugetlb_extend_reservation(struct hugetlbfs_inode_info *info,
-			       unsigned long atleast)
-{
-	struct inode *inode = &info->vfs_inode;
-	unsigned long change_in_reserve = 0;
-	int ret = 0;
-
-	spin_lock(&hugetlb_lock);
-	read_lock_irq(&inode->i_mapping->tree_lock);
-
-	if (info->prereserved_hpages >= atleast)
-		goto out;
-
-	/* Because we always call this on shared mappings, none of the
-	 * pages beyond info->prereserved_hpages can have been
-	 * instantiated, so we need to reserve all of them now. */
-	change_in_reserve = atleast - info->prereserved_hpages;
-
-	if ((reserved_huge_pages + change_in_reserve) > free_huge_pages) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	reserved_huge_pages += change_in_reserve;
-	info->prereserved_hpages = atleast;
-
- out:
-	read_unlock_irq(&inode->i_mapping->tree_lock);
-	spin_unlock(&hugetlb_lock);
-
-	return ret;
-}
-
-/* hugetlb_truncate_reservation()
- *
- * This returns pages reserved for the given inode to the general free
- * hugepage pool.  If the inode has any pages prereserved, but not
- * instantiated, beyond offset (atmost << HPAGE_SIZE), then release
- * them.
- */
-void hugetlb_truncate_reservation(struct hugetlbfs_inode_info *info,
-				  unsigned long atmost)
-{
-	struct inode *inode = &info->vfs_inode;
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long idx;
-	unsigned long change_in_reserve = 0;
-	struct page *page;
-
-	spin_lock(&hugetlb_lock);
-	read_lock_irq(&inode->i_mapping->tree_lock);
-
-	if (info->prereserved_hpages <= atmost)
-		goto out;
-
-	/* Count pages which were reserved, but not instantiated, and
-	 * which we can now release. */
-	for (idx = atmost; idx < info->prereserved_hpages; idx++) {
-		page = radix_tree_lookup(&mapping->page_tree, idx);
-		if (!page)
-			/* Pages which are already instantiated can't
-			 * be unreserved (and in fact have already
-			 * been removed from the reserved pool) */
-			change_in_reserve++;
-	}
-
-	BUG_ON(reserved_huge_pages < change_in_reserve);
-	reserved_huge_pages -= change_in_reserve;
-	info->prereserved_hpages = atmost;
-
- out:
-	read_unlock_irq(&inode->i_mapping->tree_lock);
-	spin_unlock(&hugetlb_lock);
-}
-
 static int __init hugetlb_init(void)
 {
 	unsigned long i;
@@ -334,7 +223,7 @@ static unsigned long set_max_huge_pages(
 		return nr_huge_pages;
 
 	spin_lock(&hugetlb_lock);
-	count = max(count, reserved_huge_pages);
+	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);
@@ -361,11 +250,11 @@ int hugetlb_report_meminfo(char *buf)
 	return sprintf(buf,
 			"HugePages_Total: %5lu\n"
 			"HugePages_Free:  %5lu\n"
-		        "HugePages_Rsvd:  %5lu\n"
+			"HugePages_Rsvd:  %5lu\n"
 			"Hugepagesize:    %5lu kB\n",
 			nr_huge_pages,
 			free_huge_pages,
-		        reserved_huge_pages,
+			resv_huge_pages,
 			HPAGE_SIZE/1024);
 }
 
@@ -754,3 +643,156 @@ void hugetlb_change_protection(struct vm
 	flush_tlb_range(vma, start, end);
 }
 
+struct file_region {
+	struct list_head link;
+	long from;
+	long to;
+};
+
+static long region_add(struct list_head *head, long f, long t)
+{
+	struct file_region *rg, *nrg, *trg;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (f > rg->from)
+		f = rg->from;
+
+	/* Check for and consume any regions we now overlap with. */
+	nrg = rg;
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > t)
+			break;
+
+		/* If this area reaches higher then extend our area to
+		 * include it completely.  If this is not the first area
+		 * which we intend to reuse, free it. */
+		if (rg->to > t)
+			t = rg->to;
+		if (rg != nrg) {
+			list_del(&rg->link);
+			kfree(rg);
+		}
+	}
+	nrg->from = f;
+	nrg->to = t;
+	return 0;
+}
+
+static long region_chg(struct list_head *head, long f, long t)
+{
+	struct file_region *rg, *nrg;
+	long chg = 0;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+
+	/* If we are below the current region then a new region is required.
+	 * Subtle, allocate a new region at the position but make it zero
+	 * size such that we can guarentee to record the reservation. */
+	if (&rg->link == head || t < rg->from) {
+		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
+		if (nrg == 0)
+			return -ENOMEM;
+		nrg->from = f;
+		nrg->to   = f;
+		INIT_LIST_HEAD(&nrg->link);
+		list_add(&nrg->link, rg->link.prev);
+
+		return t - f;
+	}
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (f > rg->from)
+		f = rg->from;
+	chg = t - f;
+
+	/* Check for and consume any regions we now overlap with. */
+	list_for_each_entry(rg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > t)
+			return chg;
+
+		/* We overlap with this area, if it extends futher than
+		 * us then we must extend ourselves.  Account for its
+		 * existing reservation. */
+		if (rg->to > t) {
+			chg += rg->to - t;
+			t = rg->to;
+		}
+		chg -= rg->to - rg->from;
+	}
+	return chg;
+}
+
+static long region_truncate(struct list_head *head, long end)
+{
+	struct file_region *rg, *trg;
+	long chg = 0;
+
+	/* Locate the region we are either in or before. */
+	list_for_each_entry(rg, head, link)
+		if (end <= rg->to)
+			break;
+	if (&rg->link == head)
+		return 0;
+
+	/* If we are in the middle of a region then adjust it. */
+	if (end > rg->from) {
+		chg = rg->to - end;
+		rg->to = end;
+		rg = list_entry(rg->link.next, typeof(*rg), link);
+	}
+
+	/* Drop any remaining regions. */
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		chg += rg->to - rg->from;
+		list_del(&rg->link);
+		kfree(rg);
+	}
+	return chg;
+}
+
+static int hugetlb_acct_memory(long delta)
+{
+	int ret = -ENOMEM;
+
+	spin_lock(&hugetlb_lock);
+	if ((delta + resv_huge_pages) <= free_huge_pages) {
+		resv_huge_pages += delta;
+		ret = 0;
+	}
+	spin_unlock(&hugetlb_lock);
+	return ret;
+}
+
+int hugetlb_reserve_pages(struct inode *inode, long from, long to)
+{
+	long ret, chg;
+
+	chg = region_chg(&inode->i_mapping->private_list, from, to);
+	if (chg < 0)
+		return chg;
+	ret = hugetlb_acct_memory(chg);
+	if (ret < 0)
+		return ret;
+	region_add(&inode->i_mapping->private_list, from, to);
+	return 0;
+}
+
+void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
+{
+	long chg = region_truncate(&inode->i_mapping->private_list, offset);
+	hugetlb_acct_memory(freed - chg);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
