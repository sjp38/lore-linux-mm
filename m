Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E23308D004A
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:48 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:45 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 17/24] sys_swapon: simplify error flow in read_swap_header
Date: Sat, 12 Feb 2011 16:49:18 -0200
Message-Id: <1297536565-8059-17-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Since there is no cleanup to do, there is no reason to jump to a label.
Return directly instead.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 314fb21..33c939d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1928,7 +1928,7 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
 
 	if (memcmp("SWAPSPACE2", swap_header->magic.magic, 10)) {
 		printk(KERN_ERR "Unable to find swap-space signature\n");
-		goto bad_swap;
+		return 0;
 	}
 
 	/* swap partition endianess hack... */
@@ -1944,7 +1944,7 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
 		printk(KERN_WARNING
 		       "Unable to handle swap header version %d\n",
 		       swap_header->info.version);
-		goto bad_swap;
+		return 0;
 	}
 
 	p->lowest_bit  = 1;
@@ -1976,22 +1976,19 @@ static unsigned long read_swap_header(struct swap_info_struct *p,
 	p->highest_bit = maxpages - 1;
 
 	if (!maxpages)
-		goto bad_swap;
+		return 0;
 	swapfilepages = i_size_read(inode) >> PAGE_SHIFT;
 	if (swapfilepages && maxpages > swapfilepages) {
 		printk(KERN_WARNING
 		       "Swap area shorter than signature indicates\n");
-		goto bad_swap;
+		return 0;
 	}
 	if (swap_header->info.nr_badpages && S_ISREG(inode->i_mode))
-		goto bad_swap;
+		return 0;
 	if (swap_header->info.nr_badpages > MAX_SWAP_BADPAGES)
-		goto bad_swap;
+		return 0;
 
 	return maxpages;
-
-bad_swap:
-	return 0;
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
