Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l92MUGpn015374
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 23:30:16 +0100
Received: from nz-out-0506.google.com (nzes1.prod.google.com [10.36.170.1])
	by zps36.corp.google.com with ESMTP id l92MTwkT010022
	for <linux-mm@kvack.org>; Tue, 2 Oct 2007 15:30:15 -0700
Received: by nz-out-0506.google.com with SMTP id s1so2923268nze
        for <linux-mm@kvack.org>; Tue, 02 Oct 2007 15:30:15 -0700 (PDT)
Message-ID: <b040c32a0710021530o7a8ae28aybd65f8f4d677029@mail.gmail.com>
Date: Tue, 2 Oct 2007 15:30:15 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] fix file position for hugetlbfs-read-support
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While working on a related area, I ran into a bug in hugetlbfs file
read support that is currently in -mm tree
(hugetlbfs-read-support.patch).

The problem is that hugetlb file position wasn't updated in
hugetlbfs_read(), so sys_read() will always read from same file
location.  A simple "cp" command that reads file until EOF will never
terminate.  Fix it by updating the ppos at the end of
hugetlbfs_read().

Signed-off-by: Ken Chen <kenchen@google.com>


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 6dde2c3..8d9a631 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -228,9 +228,9 @@ hugetlbfs_read(struct file *filp
 	struct address_space *mapping = filp->f_mapping;
 	struct inode *inode = mapping->host;
 	unsigned long index = *ppos >> HPAGE_SHIFT;
+	unsigned long offset = *ppos & ~HPAGE_MASK;
 	unsigned long end_index;
 	loff_t isize;
-	unsigned long offset;
 	ssize_t retval = 0;

 	/* validate length */
@@ -241,7 +241,6 @@ hugetlbfs_read(struct file *filp
 	if (!isize)
 		goto out;

-	offset = *ppos & ~HPAGE_MASK;
 	end_index = (isize - 1) >> HPAGE_SHIFT;
 	for (;;) {
 		struct page *page;
@@ -290,6 +289,7 @@ hugetlbfs_read(struct file *filp
 		goto out;
 	}
 out:
+	*ppos = ((loff_t) index << HPAGE_SHIFT) + offset;
 	return retval;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
