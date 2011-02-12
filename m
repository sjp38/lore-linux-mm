Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC58E8D003D
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:46 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:43 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 06/24] sys_swapon: simplify error flow in alloc_swap_info
Date: Sat, 12 Feb 2011 16:49:07 -0200
Message-Id: <1297536565-8059-6-git-send-email-cesarb@cesarb.net>
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
 mm/swapfile.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index be728e3..5538c77 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1848,7 +1848,6 @@ static struct swap_info_struct *alloc_swap_info(void)
 {
 	struct swap_info_struct *p;
 	unsigned int type;
-	int error;
 
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
@@ -1859,11 +1858,10 @@ static struct swap_info_struct *alloc_swap_info(void)
 		if (!(swap_info[type]->flags & SWP_USED))
 			break;
 	}
-	error = -EPERM;
 	if (type >= MAX_SWAPFILES) {
 		spin_unlock(&swap_lock);
 		kfree(p);
-		goto out;
+		return ERR_PTR(-EPERM);
 	}
 	if (type >= nr_swapfiles) {
 		p->type = type;
@@ -1889,9 +1887,6 @@ static struct swap_info_struct *alloc_swap_info(void)
 	spin_unlock(&swap_lock);
 
 	return p;
-
-out:
-	return ERR_PTR(error);
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
