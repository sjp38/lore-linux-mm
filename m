Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2KKxhwY020569
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:59:43 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2KKxh7U200850
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:59:43 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2KKxgQH005083
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:59:43 -0500
Subject: [RFC] Use huge_pages_needed for private hugetlb mappings
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 14:59:39 -0600
Message-Id: <1142888380.14508.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[RFC] Use huge_pages_needed algorithm for MAP_PRIVATE mappings

Since Ken Chen and David Gibson's strict reservation patch can handle only
shared mappings, restore the huge_pages_needed function and use it for private
mappings.

* Evil Note *
This patch depends on the following two patches:
Ken Chen - [patch] hugetlb strict commit accounting - v3
David Gibson - hugepage: Serialize hugepage allocation and instantiation

Signed-off-by: Adam Litke <agl@us.ibm.com>
---
 inode.c |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 45 insertions(+), 1 deletion(-)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -56,9 +56,48 @@ static void huge_pagevec_release(struct 
 	pagevec_reinit(pvec);
 }
 
+/*
+ * huge_pages_needed tries to determine the number of new huge pages that
+ * will be required to fully populate this VMA.  This will be equal to
+ * the size of the VMA in huge pages minus the number of huge pages
+ * (covered by this VMA) that are found in the page cache.
+ *
+ * Result is in bytes to be compatible with is_hugepage_mem_enough()
+ */
+static unsigned long
+huge_pages_needed(struct address_space *mapping, struct vm_area_struct *vma)
+{
+	int i;
+	struct pagevec pvec;
+	unsigned long start = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	unsigned long hugepages = (end - start) >> HPAGE_SHIFT;
+	pgoff_t next = vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT);
+	pgoff_t endpg = next + hugepages;
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
 
@@ -86,9 +125,14 @@ static int hugetlbfs_file_mmap(struct fi
 	if (!(vma->vm_flags & VM_WRITE) && len > inode->i_size)
 		goto out;
 
-	if (vma->vm_flags & VM_MAYSHARE)
+	if (vma->vm_flags & VM_MAYSHARE) {
 		if (hugetlb_reserve_pages(inode, vma))
 			goto out;
+	} else {
+		bytes = huge_pages_needed(mapping, vma);
+		if (!is_hugepage_mem_enough(bytes))
+			goto out;
+	}
 
 	ret = 0;
 	hugetlb_prefault_arch_hook(vma->vm_mm);

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
