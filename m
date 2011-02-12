Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E6A308D003D
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:47 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:44 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 12/24] sys_swapon: use a single error label
Date: Sat, 12 Feb 2011 16:49:13 -0200
Message-Id: <1297536565-8059-12-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

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
index f122f4a..57eff7e 100644
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
