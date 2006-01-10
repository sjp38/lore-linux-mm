Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0AJMXZW016060
	for <linux-mm@kvack.org>; Tue, 10 Jan 2006 14:22:33 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0AJMXK5122302
	for <linux-mm@kvack.org>; Tue, 10 Jan 2006 14:22:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0AJMWrW012264
	for <linux-mm@kvack.org>; Tue, 10 Jan 2006 14:22:32 -0500
Subject: Hugetlb: Shared memory race
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Tue, 10 Jan 2006 13:22:31 -0600
Message-Id: <1136920951.23288.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have discovered a race caused by the interaction of demand faulting
with the hugetlb overcommit accounting patch.  Attached is a workaround
for the problem.  Can anyone suggest a better approach to solving the
race I'll describe below?  If not, would the attached workaround be
acceptable?

The race occurs when multiple threads shmat a hugetlb area and begin
faulting in it's pages.  During a hugetlb fault, hugetlb_no_page checks
for the page in the page cache.  If not found, it allocates (and zeroes)
a new page and tries to add it to the page cache.  If this fails, the
huge page is freed and we retry the page cache lookup (assuming someone
else beat us to the add_to_page_cache call).

The above works fine, but due to the large window (while zeroing the
huge page) it is possible that many threads could be "borrowing" pages
only to return them later.  This causes free_hugetlb_pages to be lower
than the logical number of free pages and some threads trying to shmat
can falsely fail the accounting check.

The workaround disables the accounting check that happens at shmat time.
It was already done at shmget time (which is the normal semantics
anyway).

Signed-off-by: Adam Litke <agl@us.ibm.com>

 inode.c |   10 ++++++++++
 1 files changed, 10 insertions(+)
diff -upN reference/fs/hugetlbfs/inode.c current/fs/hugetlbfs/inode.c
--- reference/fs/hugetlbfs/inode.c
+++ current/fs/hugetlbfs/inode.c
@@ -74,6 +74,14 @@ huge_pages_needed(struct address_space *
 	pgoff_t next = vma->vm_pgoff;
 	pgoff_t endpg = next + ((end - start) >> PAGE_SHIFT);
 
+	/* 
+	 * Accounting for shared memory segments is done at shmget time
+	 * so we can skip the check now to avoid a race where hugetlb_no_page
+	 * is zeroing hugetlb pages not yet in the page cache.
+	 */
+	if (vma->vm_file->f_dentry->d_inode->i_blocks != 0)
+		return 0;
+
 	pagevec_init(&pvec, 0);
 	while (next < endpg) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))
@@ -832,6 +840,8 @@ struct file *hugetlb_zero_setup(size_t s
 
 	d_instantiate(dentry, inode);
 	inode->i_size = size;
+	/* Mark this file is used for shared memory */
+	inode->i_blocks = 1;
 	inode->i_nlink = 0;
 	file->f_vfsmnt = mntget(hugetlbfs_vfsmount);
 	file->f_dentry = dentry;

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
