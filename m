Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l71NaVv7006342
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 00:36:32 +0100
Received: from an-out-0708.google.com (anac8.prod.google.com [10.100.54.8])
	by zps36.corp.google.com with ESMTP id l71NaGhK018639
	for <linux-mm@kvack.org>; Wed, 1 Aug 2007 16:36:20 -0700
Received: by an-out-0708.google.com with SMTP id c8so66942ana
        for <linux-mm@kvack.org>; Wed, 01 Aug 2007 16:36:16 -0700 (PDT)
Message-ID: <b040c32a0708011636x74f61aefvf2ecaa280cc990fc@mail.gmail.com>
Date: Wed, 1 Aug 2007 16:36:15 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] hugetlb: allow extending ftruncate on hugetlbfs
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For historical reason, expanding ftruncate that increases file size on
hugetlbfs is not allowed due to pages were pre-faulted and lack of
fault handler.  Now that we have demand faulting on hugetlb since
2.6.15, there is no reason to hold back that limitation.

This will make hugetlbfs behave more like a normal fs. I'm writing a
user level code that uses hugetlbfs but will fall back to tmpfs if
there are no hugetlb page available in the system.  Having hugetlbfs
specific ftruncate behavior is a bit quirky and I would like to remove
that artificial limitation.

Signed-off-by: <kenchen@google.com>


diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c848a19..a255aac 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -313,21 +313,15 @@ hugetlb_vmtruncate_list(struct prio_tree
 	}
 }

-/*
- * Expanding truncates are not allowed.
- */
 static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
 {
 	pgoff_t pgoff;
 	struct address_space *mapping = inode->i_mapping;

-	if (offset > inode->i_size)
-		return -EINVAL;
-
 	BUG_ON(offset & ~HPAGE_MASK);
 	pgoff = offset >> PAGE_SHIFT;

-	inode->i_size = offset;
+	i_size_write(inode, offset);
 	spin_lock(&mapping->i_mmap_lock);
 	if (!prio_tree_empty(&mapping->i_mmap))
 		hugetlb_vmtruncate_list(&mapping->i_mmap, pgoff);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
