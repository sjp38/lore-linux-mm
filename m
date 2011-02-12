Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0AB8D0046
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:48 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:44 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 15/24] sys_swapon: move setting of swapfilepages near use
Date: Sat, 12 Feb 2011 16:49:16 -0200
Message-Id: <1297536565-8059-15-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

There is no reason I can see to read inode->i_size long before it is
needed. Move its read to just before it is needed, to reduce the
variable lifetime.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index f5fe484..60c7784 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1975,8 +1975,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (unlikely(error))
 		goto bad_swap;
 
-	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
-
 	/*
 	 * Read the swap header.
 	 */
@@ -2045,6 +2043,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	error = -EINVAL;
 	if (!maxpages)
 		goto bad_swap;
+	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
 	if (swapfilepages && maxpages > swapfilepages) {
 		printk(KERN_WARNING
 		       "Swap area shorter than signature indicates\n");
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
