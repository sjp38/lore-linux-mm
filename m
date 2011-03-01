Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4381A8D0042
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:01 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 08/24] sys_swapon: move setting of error nearer use
Date: Tue,  1 Mar 2011 20:28:32 -0300
Message-Id: <1299022128-6239-9-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

Move the setting of the error variable nearer the goto in a few places.

Avoids calling PTR_ERR() if not IS_ERR() in two places, and makes the
error condition more explicit in two other places.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8893c10..55a50ef 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1917,14 +1917,14 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		return PTR_ERR(p);
 
 	name = getname(specialfile);
-	error = PTR_ERR(name);
 	if (IS_ERR(name)) {
+		error = PTR_ERR(name);
 		name = NULL;
 		goto bad_swap_2;
 	}
 	swap_file = filp_open(name, O_RDWR|O_LARGEFILE, 0);
-	error = PTR_ERR(swap_file);
 	if (IS_ERR(swap_file)) {
+		error = PTR_ERR(swap_file);
 		swap_file = NULL;
 		goto bad_swap_2;
 	}
@@ -1933,17 +1933,17 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	mapping = swap_file->f_mapping;
 	inode = mapping->host;
 
-	error = -EBUSY;
 	for (i = 0; i < nr_swapfiles; i++) {
 		struct swap_info_struct *q = swap_info[i];
 
 		if (q == p || !q->swap_file)
 			continue;
-		if (mapping == q->swap_file->f_mapping)
+		if (mapping == q->swap_file->f_mapping) {
+			error = -EBUSY;
 			goto bad_swap;
+		}
 	}
 
-	error = -EINVAL;
 	if (S_ISBLK(inode->i_mode)) {
 		bdev = bdgrab(I_BDEV(inode));
 		error = blkdev_get(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL,
@@ -1968,6 +1968,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 			goto bad_swap;
 		}
 	} else {
+		error = -EINVAL;
 		goto bad_swap;
 	}
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
