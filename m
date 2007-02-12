From: Dave McCracken <dave.mccracken@oracle.com>
Date: Mon, 12 Feb 2007 08:28:02 -0600
Message-Id: <20070212142802.15738.80487.sendpatchset@wildcat.int.mccr.org>
Subject: [PATCH 1/1] Enable fully functional truncate for hugetlbfs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

This patch enables the full functionality of truncate for hugetlbfs
files.  Truncate was originally limited to reducing the file size
because page faults were not supported for hugetlbfs.  Now that page
faults have been implemented it is now possible to fully support
truncate.

Signed-off-by: Dave McCracken <dave.mccracken@oracle.com>

---
 inode.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

--- 2.6.20/./fs/hugetlbfs/inode.c	2007-02-04 12:44:54.000000000 -0600
+++ 2.6.20-htrunc/./fs/hugetlbfs/inode.c	2007-02-05 13:02:00.000000000 -0600
@@ -298,9 +298,10 @@ static int hugetlb_vmtruncate(struct ino
 {
 	pgoff_t pgoff;
 	struct address_space *mapping = inode->i_mapping;
+	unsigned long limit;
 
 	if (offset > inode->i_size)
-		return -EINVAL;
+		goto do_expand;
 
 	BUG_ON(offset & ~HPAGE_MASK);
 	pgoff = offset >> PAGE_SHIFT;
@@ -312,6 +313,24 @@ static int hugetlb_vmtruncate(struct ino
 	spin_unlock(&mapping->i_mmap_lock);
 	truncate_hugepages(inode, offset);
 	return 0;
+
+do_expand:
+	limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
+	if (limit != RLIM_INFINITY && offset > limit)
+		goto out_sig;
+	if (offset > inode->i_sb->s_maxbytes)
+		goto out_big;
+	if (hugetlb_reserve_pages(inode, inode->i_size >> HPAGE_SHIFT,
+				  offset >> HPAGE_SHIFT))
+		goto out_mem;
+	i_size_write(inode, offset);
+	return 0;
+out_sig:
+	send_sig(SIGXFSZ, current, 0);
+out_big:
+	return -EFBIG;
+out_mem:
+	return -ENOMEM;
 }
 
 static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
