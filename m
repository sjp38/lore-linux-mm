Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 387908D0039
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:47 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:43 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 09/24] sys_swapon: remove did_down variable
Date: Sat, 12 Feb 2011 16:49:10 -0200
Message-Id: <1297536565-8059-9-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Since mutex_lock(&inode->i_mutex) is called just after setting inode,
did_down is always equivalent to (inode && S_ISREG(inode->i_mode)).

Use this fact to remove the did_down variable.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 340537d..1baaddc 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1907,7 +1907,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	unsigned char *swap_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
-	int did_down = 0;
 
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -1962,7 +1961,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
 		mutex_lock(&inode->i_mutex);
-		did_down = 1;
 		if (IS_SWAPFILE(inode)) {
 			error = -EBUSY;
 			goto bad_swap;
@@ -2163,7 +2161,7 @@ out:
 	}
 	if (name)
 		putname(name);
-	if (did_down) {
+	if (inode && S_ISREG(inode->i_mode)) {
 		if (!error)
 			inode->i_flags |= S_SWAPFILE;
 		mutex_unlock(&inode->i_mutex);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
