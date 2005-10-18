Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9IMfBq6025416
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:41:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9IMfBa2093740
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:41:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9IMfAuI028745
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 18:41:11 -0400
Subject: [PATCH 2/2] hugetlb: overcommit accounting check
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1129674980.8702.19.camel@localhost.localdomain>
References: <1129674980.8702.19.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 18 Oct 2005 17:40:56 -0500
Message-Id: <1129675256.8702.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, "ADAM G. LITKE [imap]" <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Version 2 (Tue, 18 Oct 2005)
	Added comment to huge_pages_needed
	Removed erroneous shared memory exemption logic
Initial Post (Thu, 18 Aug 2005)

Basic overcommit checking for hugetlb_file_map() based on an implementation
used with demand faulting in SLES9.

Since demand faulting can't guarantee the availability of pages at mmap time,
this patch implements a basic sanity check to ensure that the number of huge
pages required to satisfy the mmap are currently available.  Despite the
obvious race, I think it is a good start on doing proper accounting.  I'd like
to work towards an accounting system that mimics the semantics of normal pages
(especially for the MAP_PRIVATE/COW case).  That work is underway and builds on
what this patch starts.

Huge page shared memory segments are simpler and still maintain their commit on
shmget semantics.

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 inode.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 54 insertions(+), 10 deletions(-)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -45,9 +45,59 @@ static struct backing_dev_info hugetlbfs
 
 int sysctl_hugetlb_shm_group;
 
+static void huge_pagevec_release(struct pagevec *pvec)
+{
+	int i;
+
+	for (i = 0; i < pagevec_count(pvec); ++i)
+		put_page(pvec->pages[i]);
+
+	pagevec_reinit(pvec);
+}
+
+/*
+ * huge_pages_needed tries to determine the number of new huge pages that
+ * will be required to fully populate this VMA.  This will be equal to
+ * the size of the VMA in huge pages minus the number of huge pages 
+ * (covered by this VMA) that are found in the page cache.
+ *
+ * Result is in bytes to be compatible with is_hugepage_mem_enough()
+ */
+unsigned long
+huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma)
+{
+	int i;
+	struct pagevec pvec;
+	unsigned long start = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	unsigned long hugepages = (end - start) >> HPAGE_SHIFT;
+	pgoff_t next = vma->vm_pgoff;
+	pgoff_t endpg = next + ((end - start) >> PAGE_SHIFT);
+	struct inode *inode = vma->vm_file->f_dentry->d_inode;
+
+	pagevec_init(&pvec, 0);
+	while (next < endpg) {
+		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
+			break;
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			if (page->index > next)
+				next = page->index;
+			if (page->index >= endpg)
+				break;
+			next++;
+			hugepages--;
+		}
+		huge_pagevec_release(&pvec);
+	}
+	return hugepages << HPAGE_SHIFT;
+}
+
 static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	struct address_space *mapping = inode->i_mapping;
+	unsigned long bytes;
 	loff_t len, vma_len;
 	int ret;
 
@@ -66,6 +116,10 @@ static int hugetlbfs_file_mmap(struct fi
 	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
 		return -EINVAL;
 
+	bytes = huge_pages_needed(mapping, vma);
+	if (!is_hugepage_mem_enough(bytes))
+		return -ENOMEM;
+
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
 	down(&inode->i_sem);
@@ -168,16 +222,6 @@ static int hugetlbfs_commit_write(struct
 	return -EINVAL;
 }
 
-static void huge_pagevec_release(struct pagevec *pvec)
-{
-	int i;
-
-	for (i = 0; i < pagevec_count(pvec); ++i)
-		put_page(pvec->pages[i]);
-
-	pagevec_reinit(pvec);
-}
-
 static void truncate_huge_page(struct page *page)
 {
 	clear_page_dirty(page);

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
