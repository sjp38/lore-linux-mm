Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C70208D003D
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:00 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 06/24] sys_swapon: simplify error flow in alloc_swap_info
Date: Tue,  1 Mar 2011 20:28:30 -0300
Message-Id: <1299022128-6239-7-git-send-email-cesarb@cesarb.net>
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
 mm/swapfile.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8969b37..c97dc4b 100644
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
