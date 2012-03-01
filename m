Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 6F9F16B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:19:12 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:11:21 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219Da2C3309708
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:13:36 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219J6xv004323
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:19:07 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2] hugetlbfs: Drop taking inode i_mutex lock from hugetlbfs_read
Date: Thu,  1 Mar 2012 14:48:50 +0530
Message-Id: <1330593530-2022-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, hughd@google.com
Cc: linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Taking i_mutex lock in hugetlbfs_read can result in deadlock with mmap
as explained below
 Thread A:
  read() on hugetlbfs
   hugetlbfs_read() called
    i_mutex grabbed
     hugetlbfs_read_actor() called
      __copy_to_user() called
       page fault is triggered
 Thread B, sharing address space with A:
  mmap() the same file
   ->mmap_sem is grabbed on task_B->mm->mmap_sem
    hugetlbfs_file_mmap() is called
     attempt to grab ->i_mutex and block waiting for A to give it up
 Thread A:
  pagefault handled blocked on attempt to grab task_A->mm->mmap_sem,
 which happens to be the same thing as task_B->mm->mmap_sem.  Block waiting
 for B to give it up.

AFAIU i_mutex lock got added to  hugetlbfs_read as per
http://lkml.indiana.edu/hypermail/linux/kernel/0707.2/3066.html
to take care of the race between truncate and read. This patch fix
this by looking at page->mapping under page_lock (find_lock_page())
to ensure; the inode didn't get truncated in the range during a
parallel read.

Ideally we can extend the patch to make sure we don't increase i_size
in mmap. But that will break userspace, because application will now
have to use truncate(2) to increase i_size in hugetlbfs.

Based on the original patch from Hillf Danton <dhillf@gmail.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 1e85a7a..3645cd3 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -238,17 +238,10 @@ static ssize_t hugetlbfs_read(struct file *filp, char __user *buf,
 	loff_t isize;
 	ssize_t retval = 0;
 
-	mutex_lock(&inode->i_mutex);
-
 	/* validate length */
 	if (len == 0)
 		goto out;
 
-	isize = i_size_read(inode);
-	if (!isize)
-		goto out;
-
-	end_index = (isize - 1) >> huge_page_shift(h);
 	for (;;) {
 		struct page *page;
 		unsigned long nr, ret;
@@ -256,18 +249,21 @@ static ssize_t hugetlbfs_read(struct file *filp, char __user *buf,
 
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = huge_page_size(h);
+		isize = i_size_read(inode);
+		if (!isize)
+			goto out;
+		end_index = (isize - 1) >> huge_page_shift(h);
 		if (index >= end_index) {
 			if (index > end_index)
 				goto out;
 			nr = ((isize - 1) & ~huge_page_mask(h)) + 1;
-			if (nr <= offset) {
+			if (nr <= offset)
 				goto out;
-			}
 		}
 		nr = nr - offset;
 
 		/* Find the page */
-		page = find_get_page(mapping, index);
+		page = find_lock_page(mapping, index);
 		if (unlikely(page == NULL)) {
 			/*
 			 * We have a HOLE, zero out the user-buffer for the
@@ -279,17 +275,18 @@ static ssize_t hugetlbfs_read(struct file *filp, char __user *buf,
 			else
 				ra = 0;
 		} else {
+			unlock_page(page);
+
 			/*
 			 * We have the page, copy it to user space buffer.
 			 */
 			ra = hugetlbfs_read_actor(page, offset, buf, len, nr);
 			ret = ra;
+			page_cache_release(page);
 		}
 		if (ra < 0) {
 			if (retval == 0)
 				retval = ra;
-			if (page)
-				page_cache_release(page);
 			goto out;
 		}
 
@@ -299,16 +296,12 @@ static ssize_t hugetlbfs_read(struct file *filp, char __user *buf,
 		index += offset >> huge_page_shift(h);
 		offset &= ~huge_page_mask(h);
 
-		if (page)
-			page_cache_release(page);
-
 		/* short read or no more work */
 		if ((ret != nr) || (len == 0))
 			break;
 	}
 out:
 	*ppos = ((loff_t)index << huge_page_shift(h)) + offset;
-	mutex_unlock(&inode->i_mutex);
 	return retval;
 }
 
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
