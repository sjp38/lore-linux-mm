Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC198D003E
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:01 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 10/24] sys_swapon: remove bdev variable
Date: Tue,  1 Mar 2011 20:28:34 -0300
Message-Id: <1299022128-6239-11-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

The bdev variable is always equivalent to (S_ISBLK(inode->i_mode) ?
p->bdev : NULL), as long as it being set is moved to a bit earlier. Use
this fact to remove the bdev variable.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index c655389..bc00c1a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1893,7 +1893,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
 	char *name;
-	struct block_device *bdev = NULL;
 	struct file *swap_file = NULL;
 	struct address_space *mapping;
 	int i, prev;
@@ -1944,19 +1943,19 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 
 	if (S_ISBLK(inode->i_mode)) {
-		bdev = bdgrab(I_BDEV(inode));
-		error = blkdev_get(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL,
+		p->bdev = bdgrab(I_BDEV(inode));
+		error = blkdev_get(p->bdev,
+				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
 				   sys_swapon);
 		if (error < 0) {
-			bdev = NULL;
+			p->bdev = NULL;
 			error = -EINVAL;
 			goto bad_swap;
 		}
-		p->old_block_size = block_size(bdev);
-		error = set_blocksize(bdev, PAGE_SIZE);
+		p->old_block_size = block_size(p->bdev);
+		error = set_blocksize(p->bdev, PAGE_SIZE);
 		if (error < 0)
 			goto bad_swap;
-		p->bdev = bdev;
 		p->flags |= SWP_BLKDEV;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
@@ -2140,9 +2139,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	error = 0;
 	goto out;
 bad_swap:
-	if (bdev) {
-		set_blocksize(bdev, p->old_block_size);
-		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
+	if (S_ISBLK(inode->i_mode) && p->bdev) {
+		set_blocksize(p->bdev, p->old_block_size);
+		blkdev_put(p->bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	}
 	destroy_swap_extents(p);
 	swap_cgroup_swapoff(p->type);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
