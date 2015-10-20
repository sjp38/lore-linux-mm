Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E20F66B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 19:55:49 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so36760965pac.3
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:55:49 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a13si8741023pbu.165.2015.10.20.16.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 16:55:46 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 2/4] mm/hugetlb: Setup hugetlb_falloc during fallocate hole punch
Date: Tue, 20 Oct 2015 16:52:20 -0700
Message-Id: <1445385142-29936-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

When performing a fallocate hole punch, set up a hugetlb_falloc struct
and make i_private point to it.  i_private will point to this struct for
the duration of the operation.  At the end of the operation, wake up
anyone who faulted on the hole and is on the waitq.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb9..719bbe0 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -507,6 +507,7 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 {
 	struct hstate *h = hstate_inode(inode);
 	loff_t hpage_size = huge_page_size(h);
+	unsigned long hpage_shift = huge_page_shift(h);
 	loff_t hole_start, hole_end;
 
 	/*
@@ -518,8 +519,30 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 
 	if (hole_end > hole_start) {
 		struct address_space *mapping = inode->i_mapping;
+		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(hugetlb_falloc_waitq);
+		/*
+		 * Page faults on the area to be hole punched must be stopped
+		 * during the operation.  Initialize struct and have
+		 * inode->i_private point to it.
+		 */
+		struct hugetlb_falloc hugetlb_falloc = {
+			.waitq = &hugetlb_falloc_waitq,
+			.start = hole_start >> hpage_shift,
+			.end = hole_end >> hpage_shift
+		};
 
 		mutex_lock(&inode->i_mutex);
+
+		/*
+		 * inode->i_private will be checked in the page fault path.
+		 * The locking assures that all writes to the structure are
+		 * complete before assigning to i_private.  A fault on another
+		 * CPU will see the fully initialized structure.
+		 */
+		spin_lock(&inode->i_lock);
+		inode->i_private = &hugetlb_falloc;
+		spin_unlock(&inode->i_lock);
+
 		i_mmap_lock_write(mapping);
 		if (!RB_EMPTY_ROOT(&mapping->i_mmap))
 			hugetlb_vmdelete_list(&mapping->i_mmap,
@@ -527,6 +550,12 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
 						hole_end  >> PAGE_SHIFT);
 		i_mmap_unlock_write(mapping);
 		remove_inode_hugepages(inode, hole_start, hole_end);
+
+		spin_lock(&inode->i_lock);
+		inode->i_private = NULL;
+		wake_up_all(&hugetlb_falloc_waitq);
+		spin_unlock(&inode->i_lock);
+
 		mutex_unlock(&inode->i_mutex);
 	}
 
@@ -647,9 +676,6 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
 	if (!(mode & FALLOC_FL_KEEP_SIZE) && offset + len > inode->i_size)
 		i_size_write(inode, offset + len);
 	inode->i_ctime = CURRENT_TIME;
-	spin_lock(&inode->i_lock);
-	inode->i_private = NULL;
-	spin_unlock(&inode->i_lock);
 out:
 	mutex_unlock(&inode->i_mutex);
 	return error;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
