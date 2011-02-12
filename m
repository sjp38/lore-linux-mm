Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 85CA98D0045
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:47 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:44 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 11/24] sys_swapon: do only cleanup in the cleanup blocks
Date: Sat, 12 Feb 2011 16:49:12 -0200
Message-Id: <1297536565-8059-11-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

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
index 58fa178..f122f4a 100644
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
