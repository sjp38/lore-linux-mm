Message-Id: <200603100314.k2A3Evg28313@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] hugetlb strict commit accounting - v3
Date: Thu, 9 Mar 2006 19:14:58 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, wli@holomorphy.com, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlb strict commit accounting for shared mapping - v3

The a region reservation list is implementation as a linked list
hanging off address_space i_data->private_list.  It turns out that
clear_inode() was also looking at inode->i_data->private_list and
if not empty, it think inode has dirty buffers and start clearing.
Except it won't go very far before oops-ing.  That could happen if
a reservation is made but no actual faulting. hugetlbfs_delete_inode
and hugetlbfs_forget_inode doesn't call truncate_hugepages if there
are no actual page in the page cache, leading to clear_inode to do
bad thing.  Change that to always call truncate_hugepages even if
there are no pages in page cache and to let the unreserve code to
clear out the reservation linked list.


Changes since v2:
* fix none empty i_data->private_list before calling clear_inode
* delete VMACCTPG macro

Changes since v1:

* change resv_huge_pages to normal unsigned long
* add proper lock around update/access resv_huge_pages
* resv_huge_pages record future needs of hugetlb pages
* strict commit accounting for shared mapping
* don't allow free_huge_pages to dip below reserved page in sysctl path


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./fs/hugetlbfs/inode.c.orig	2006-03-09 15:02:25.558844840 -0800
+++ ./fs/hugetlbfs/inode.c	2006-03-09 19:39:44.786180072 -0800
@@ -56,48 +56,9 @@ static void huge_pagevec_release(struct 
 	pagevec_reinit(pvec);
 }
 
-/*
- * huge_pages_needed tries to determine the number of new huge pages that
- * will be required to fully populate this VMA.  This will be equal to
- * the size of the VMA in huge pages minus the number of huge pages
- * (covered by this VMA) that are found in the page cache.
- *
- * Result is in bytes to be compatible with is_hugepage_mem_enough()
- */
-static unsigned long
-huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma)
-{
-	int i;
-	struct pagevec pvec;
-	unsigned long start = vma->vm_start;
-	unsigned long end = vma->vm_end;
-	unsigned long hugepages = (end - start) >> HPAGE_SHIFT;
-	pgoff_t next = vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT);
-	pgoff_t endpg = next + hugepages;
-
-	pagevec_init(&pvec, 0);
-	while (next < endpg) {
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
-			break;
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-			if (page->index > next)
-				next = page->index;
-			if (page->index >= endpg)
-				break;
-			next++;
-			hugepages--;
-		}
-		huge_pagevec_release(&pvec);
-	}
-	return hugepages << HPAGE_SHIFT;
-}
-
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file->f_dentry->d_inode;
-	struct address_space *mapping = inode->i_mapping;
-	unsigned long bytes;
 	loff_t len, vma_len;
 	int ret;
 
@@ -113,10 +74,6 @@ static int hugetlbfs_file_mmap(struct fi
 	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
 		return -EINVAL;
 
-	bytes = huge_pages_needed(mapping, vma);
-	if (!is_hugepage_mem_enough(bytes))
-		return -ENOMEM;
-
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
 	mutex_lock(&inode->i_mutex);
@@ -129,6 +86,10 @@ static int hugetlbfs_file_mmap(struct fi
 	if (!(vma->vm_flags & VM_WRITE) && len > inode->i_size)
 		goto out;
 
+	if (vma->vm_flags & VM_MAYSHARE)
+		if (hugetlb_reserve_pages(inode, vma))
+			goto out;
+
 	ret = 0;
 	hugetlb_prefault_arch_hook(vma->vm_mm);
 	if (inode->i_size < len)
@@ -232,7 +193,7 @@ static void truncate_hugepages(struct ad
 	const pgoff_t start = lstart >> HPAGE_SHIFT;
 	struct pagevec pvec;
 	pgoff_t next;
-	int i;
+	int i, freed = 0;
 
 	pagevec_init(&pvec, 0);
 	next = start;
@@ -254,16 +215,17 @@ static void truncate_hugepages(struct ad
 			truncate_huge_page(page);
 			unlock_page(page);
 			hugetlb_put_quota(mapping);
+			freed++;
 		}
 		huge_pagevec_release(&pvec);
 	}
 	BUG_ON(!lstart && mapping->nrpages);
+	hugetlb_unreserve_pages(mapping->host, start, freed);
 }
 
 static void hugetlbfs_delete_inode(struct inode *inode)
 {
-	if (inode->i_data.nrpages)
-		truncate_hugepages(&inode->i_data, 0);
+	truncate_hugepages(&inode->i_data, 0);
 	clear_inode(inode);
 }
 
@@ -296,8 +258,7 @@ static void hugetlbfs_forget_inode(struc
 	inode->i_state |= I_FREEING;
 	inodes_stat.nr_inodes--;
 	spin_unlock(&inode_lock);
-	if (inode->i_data.nrpages)
-		truncate_hugepages(&inode->i_data, 0);
+	truncate_hugepages(&inode->i_data, 0);
 	clear_inode(inode);
 	destroy_inode(inode);
 }
@@ -401,6 +362,7 @@ static struct inode *hugetlbfs_get_inode
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
 		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		INIT_LIST_HEAD(&inode->i_mapping->private_list);
 		info = HUGETLBFS_I(inode);
 		mpol_shared_policy_init(&info->policy, MPOL_DEFAULT, NULL);
 		switch (mode & S_IFMT) {
--- ./include/linux/hugetlb.h.orig	2006-03-09 15:02:25.559821402 -0800
+++ ./include/linux/hugetlb.h	2006-03-09 16:54:55.444504341 -0800
@@ -26,6 +26,8 @@ struct page *alloc_huge_page(struct vm_a
 void free_huge_page(struct page *);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access);
+int hugetlb_reserve_pages(struct inode *inode, struct vm_area_struct *vma);
+void hugetlb_unreserve_pages(struct inode *inode, pgoff_t offset, int freed);
 
 extern unsigned long max_huge_pages;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
--- ./mm/hugetlb.c.orig	2006-03-09 15:02:25.559821402 -0800
+++ ./mm/hugetlb.c	2006-03-09 19:46:21.034222092 -0800
@@ -20,7 +20,7 @@
 #include <linux/hugetlb.h>
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-static unsigned long nr_huge_pages, free_huge_pages;
+static unsigned long nr_huge_pages, free_huge_pages, resv_huge_pages;
 unsigned long max_huge_pages;
 static struct list_head hugepage_freelists[MAX_NUMNODES];
 static unsigned int nr_huge_pages_node[MAX_NUMNODES];
@@ -98,6 +98,12 @@ struct page *alloc_huge_page(struct vm_a
 	int i;
 
 	spin_lock(&hugetlb_lock);
+	if (vma->vm_flags & VM_MAYSHARE)
+		resv_huge_pages--;
+	else if (free_huge_pages <= resv_huge_pages) {
+		spin_unlock(&hugetlb_lock);
+		return NULL;
+	}
 	page = dequeue_huge_page(vma, addr);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
@@ -199,6 +205,7 @@ static unsigned long set_max_huge_pages(
 		return nr_huge_pages;
 
 	spin_lock(&hugetlb_lock);
+	count = max(count, resv_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);
@@ -225,9 +232,11 @@ int hugetlb_report_meminfo(char *buf)
 	return sprintf(buf,
 			"HugePages_Total: %5lu\n"
 			"HugePages_Free:  %5lu\n"
+			"HugePages_Resv:  %5lu\n"
 			"Hugepagesize:    %5lu kB\n",
 			nr_huge_pages,
 			free_huge_pages,
+			resv_huge_pages,
 			HPAGE_SIZE/1024);
 }
 
@@ -572,3 +581,165 @@ int follow_hugetlb_page(struct mm_struct
 
 	return i;
 }
+
+struct file_region {
+	struct list_head link;
+	int from;
+	int to;
+};
+
+static int region_add(struct list_head *head, int f, int t)
+{
+	struct file_region *rg;
+	struct file_region *nrg;
+	struct file_region *trg;
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
+static int region_chg(struct list_head *head, int f, int t)
+{
+	struct file_region *rg;
+	struct file_region *nrg;
+	loff_t chg = 0;
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
+static int region_truncate(struct list_head *head, int end)
+{
+	struct file_region *rg;
+	struct file_region *trg;
+	int chg = 0;
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
+int hugetlb_reserve_pages(struct inode *inode, struct vm_area_struct *vma)
+{
+	int ret, chg;
+	int from = vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT);
+	int to = (vma->vm_pgoff + ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT)) >>
+		 (HPAGE_SHIFT - PAGE_SHIFT);
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
+void hugetlb_unreserve_pages(struct inode *inode, pgoff_t offset, int freed)
+{
+	int chg;
+	chg  = region_truncate(&inode->i_mapping->private_list, offset);
+	hugetlb_acct_memory(freed - chg);
+}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
