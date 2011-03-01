Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E56F8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:02 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 12/24] sys_swapon: use a single error label
Date: Tue,  1 Mar 2011 20:28:36 -0300
Message-Id: <1299022128-6239-13-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

sys_swapon currently has two error labels, bad_swap and bad_swap_2.
bad_swap does the same as bad_swap_2 plus destroy_swap_extents() and
swap_cgroup_swapoff(); both are noops in the places where bad_swap_2 is
jumped to. With a single extra test for inode (matching the one in the
S_ISREG case below), all the error paths in the function can go to
bad_swap.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index ebc0307..96be104 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1918,13 +1918,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (IS_ERR(name)) {
 		error = PTR_ERR(name);
 		name = NULL;
-		goto bad_swap_2;
+		goto bad_swap;
 	}
 	swap_file = filp_open(name, O_RDWR|O_LARGEFILE, 0);
 	if (IS_ERR(swap_file)) {
 		error = PTR_ERR(swap_file);
 		swap_file = NULL;
-		goto bad_swap_2;
+		goto bad_swap;
 	}
 
 	p->swap_file = swap_file;
@@ -2141,13 +2141,12 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	error = 0;
 	goto out;
 bad_swap:
-	if (S_ISBLK(inode->i_mode) && p->bdev) {
+	if (inode && S_ISBLK(inode->i_mode) && p->bdev) {
 		set_blocksize(p->bdev, p->old_block_size);
 		blkdev_put(p->bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	}
 	destroy_swap_extents(p);
 	swap_cgroup_swapoff(p->type);
-bad_swap_2:
 	spin_lock(&swap_lock);
 	p->swap_file = NULL;
 	p->flags = 0;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
