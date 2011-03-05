Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E27818D0043
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 11:42:42 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 5 Mar 2011 16:42:39 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 17/24] sys_swapon: simplify error flow in read_swap_header
Date: Sat,  5 Mar 2011 13:42:18 -0300
Message-Id: <1299343345-3984-18-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
References: <1299343345-3984-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, Eric B Munson <emunson@mgebm.net>, Cesar Eduardo Barros <cesarb@cesarb.net>

Since there is no cleanup to do, there is no reason to jump to a label.
Return directly instead.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
Tested-by: Eric B Munson <emunson@mgebm.net>
Acked-by: Eric B Munson <emunson@mgebm.net>
---
 mm/swapfile.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index a56e6fe..13c13bd 100644
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
