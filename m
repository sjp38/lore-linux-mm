Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE788D003F
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:02 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 11/24] sys_swapon: do only cleanup in the cleanup blocks
Date: Tue,  1 Mar 2011 20:28:35 -0300
Message-Id: <1299022128-6239-12-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

The only way error is 0 in the cleanup blocks is when the function is
returning successfully. In this case, the cleanup blocks were setting
S_SWAPFILE in the S_ISREG case. But this is not a cleanup.

Move the setting of S_SWAPFILE to just before the "goto out;" to make
this more clear. At this point, we do not need to test for inode because
it will never be NULL.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index bc00c1a..ebc0307 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2136,6 +2136,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
 
+	if (S_ISREG(inode->i_mode))
+		inode->i_flags |= S_SWAPFILE;
 	error = 0;
 	goto out;
 bad_swap:
@@ -2160,11 +2162,8 @@ out:
 	}
 	if (name)
 		putname(name);
-	if (inode && S_ISREG(inode->i_mode)) {
-		if (!error)
-			inode->i_flags |= S_SWAPFILE;
+	if (inode && S_ISREG(inode->i_mode))
 		mutex_unlock(&inode->i_mutex);
-	}
 	return error;
 }
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
