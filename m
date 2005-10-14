Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9EEjdaJ010825
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 10:45:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9EEjZ4r064232
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 10:45:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9EEjPT4023460
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 10:45:25 -0400
Subject: [PATCH] hugetlb: Remove spurious i_blocks accounting check
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Fri, 14 Oct 2005 09:45:10 -0500
Message-Id: <1129301110.8797.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix up hugetlb-simple-overcommit-check.patch in -mm tree

Pft.  This bit of code that Bill Irwin pointed out snuck in here from another
accounting approach I was investigating.

Signed-off-by: Adam Litke <agl@us.ibm.com>

 inode.c |    9 ---------
 1 files changed, 9 deletions(-)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -75,14 +75,6 @@ huge_pages_needed(struct address_space *
 	pgoff_t endpg = next + ((end - start) >> PAGE_SHIFT);
 	struct inode *inode = vma->vm_file->f_dentry->d_inode;
 
-	/*
-	 * Shared memory segments are accounted for at shget time,
-	 * not at shmat (when the mapping is actually created) so 
-	 * check here if the memory has already been accounted for.
-	 */
-	if (inode->i_blocks != 0)
-		return 0;
-
 	pagevec_init(&pvec, 0);
 	while (next < endpg) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
@@ -844,7 +836,6 @@ struct file *hugetlb_zero_setup(size_t s
 	d_instantiate(dentry, inode);
 	inode->i_size = size;
 	inode->i_nlink = 0;
-	inode->i_blocks = 1;
 	file->f_vfsmnt = mntget(hugetlbfs_vfsmount);
 	file->f_dentry = dentry;
 	file->f_mapping = inode->i_mapping;

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
