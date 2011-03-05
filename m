Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CA20F8D0042
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 11:42:39 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Mar 2011 16:42:36 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 08/24] sys_swapon: move setting of error nearer use
Date: Sat,  5 Mar 2011 13:42:09 -0300
Message-Id: <1299343345-3984-9-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>, Cesar Eduardo Barros <cesarb@cesarb.net>

Move the setting of the error variable nearer the goto in a few places.

Avoids calling PTR_ERR() if not IS_ERR() in two places, and makes the
error condition more explicit in two other places.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
Tested-by: Eric B Munson <emunson@mgebm.net>
Acked-by: Eric B Munson <emunson@mgebm.net>
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
