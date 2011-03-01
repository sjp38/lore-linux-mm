Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 926E28D0048
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:02 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 14/24] sys_swapon: simplify error flow in claim_swapfile
Date: Tue,  1 Mar 2011 20:28:38 -0300
Message-Id: <1299022128-6239-15-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

Since there is no cleanup to do, there is no reason to jump to a label.
Return directly instead.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 27faeec..058cf1b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1900,30 +1900,22 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 				   sys_swapon);
 		if (error < 0) {
 			p->bdev = NULL;
-			error = -EINVAL;
-			goto bad_swap;
+			return -EINVAL;
 		}
 		p->old_block_size = block_size(p->bdev);
 		error = set_blocksize(p->bdev, PAGE_SIZE);
 		if (error < 0)
-			goto bad_swap;
+			return error;
 		p->flags |= SWP_BLKDEV;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
 		mutex_lock(&inode->i_mutex);
-		if (IS_SWAPFILE(inode)) {
-			error = -EBUSY;
-			goto bad_swap;
-		}
-	} else {
-		error = -EINVAL;
-		goto bad_swap;
-	}
+		if (IS_SWAPFILE(inode))
+			return -EBUSY;
+	} else
+		return -EINVAL;
 
 	return 0;
-
-bad_swap:
-	return error;
 }
 
 SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
