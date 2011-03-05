Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 741DB8D0047
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 11:42:41 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Mar 2011 16:42:37 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 13/24] sys_swapon: separate bdev claim and inode lock
Date: Sat,  5 Mar 2011 13:42:14 -0300
Message-Id: <1299343345-3984-14-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>, Cesar Eduardo Barros <cesarb@cesarb.net>

Move the code which claims the bdev (S_ISBLK) or locks the inode
(S_ISREG) to a separate function. Only code movement, no functional
changes.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
Tested-by: Eric B Munson <emunson@mgebm.net>
Acked-by: Eric B Munson <emunson@mgebm.net>
---
 mm/swapfile.c |   64 ++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 96be104..27faeec 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1889,6 +1889,43 @@ static struct swap_info_struct *alloc_swap_info(void)
 	return p;
 }
 
+static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
+{
+	int error;
+
+	if (S_ISBLK(inode->i_mode)) {
+		p->bdev = bdgrab(I_BDEV(inode));
+		error = blkdev_get(p->bdev,
+				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
+				   sys_swapon);
+		if (error < 0) {
+			p->bdev = NULL;
+			error = -EINVAL;
+			goto bad_swap;
+		}
+		p->old_block_size = block_size(p->bdev);
+		error = set_blocksize(p->bdev, PAGE_SIZE);
+		if (error < 0)
+			goto bad_swap;
+		p->flags |= SWP_BLKDEV;
+	} else if (S_ISREG(inode->i_mode)) {
+		p->bdev = inode->i_sb->s_bdev;
+		mutex_lock(&inode->i_mutex);
+		if (IS_SWAPFILE(inode)) {
+			error = -EBUSY;
+			goto bad_swap;
+		}
+	} else {
+		error = -EINVAL;
+		goto bad_swap;
+	}
+
+	return 0;
+
+bad_swap:
+	return error;
+}
+
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 {
 	struct swap_info_struct *p;
@@ -1942,32 +1979,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
-	if (S_ISBLK(inode->i_mode)) {
-		p->bdev = bdgrab(I_BDEV(inode));
-		error = blkdev_get(p->bdev,
-				   FMODE_READ | FMODE_WRITE | FMODE_EXCL,
-				   sys_swapon);
-		if (error < 0) {
-			p->bdev = NULL;
-			error = -EINVAL;
-			goto bad_swap;
-		}
-		p->old_block_size = block_size(p->bdev);
-		error = set_blocksize(p->bdev, PAGE_SIZE);
-		if (error < 0)
-			goto bad_swap;
-		p->flags |= SWP_BLKDEV;
-	} else if (S_ISREG(inode->i_mode)) {
-		p->bdev = inode->i_sb->s_bdev;
-		mutex_lock(&inode->i_mutex);
-		if (IS_SWAPFILE(inode)) {
-			error = -EBUSY;
-			goto bad_swap;
-		}
-	} else {
-		error = -EINVAL;
+	error = claim_swapfile(p, inode);
+	if (unlikely(error))
 		goto bad_swap;
-	}
 
 	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
