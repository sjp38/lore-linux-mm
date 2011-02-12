Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9983F8D0050
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:49 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:46 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 22/24] sys_swapon: move printk outside lock
Date: Sat, 12 Feb 2011 16:49:23 -0200
Message-Id: <1297536565-8059-22-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

The block in sys_swapon which does the final adjustments to the
swap_info_struct and to swap_list is the same as the block which
re-inserts it again at sys_swapoff on failure of try_to_unuse(). To be
able to make both share the same code, move the printk() call in the
middle of it to just after it.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5ec7183..8f1b17b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2144,13 +2144,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
 
-	printk(KERN_INFO "Adding %uk swap on %s.  "
-			"Priority:%d extents:%d across:%lluk %s%s\n",
-		p->pages<<(PAGE_SHIFT-10), name, p->prio,
-		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
-		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
-		(p->flags & SWP_DISCARDABLE) ? "D" : "");
-
 	/* insert swap space into swap_list: */
 	prev = -1;
 	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
@@ -2164,6 +2157,14 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	else
 		swap_info[prev]->next = p->type;
 	spin_unlock(&swap_lock);
+
+	printk(KERN_INFO "Adding %uk swap on %s.  "
+			"Priority:%d extents:%d across:%lluk %s%s\n",
+		p->pages<<(PAGE_SHIFT-10), name, p->prio,
+		nr_extents, (unsigned long long)span<<(PAGE_SHIFT-10),
+		(p->flags & SWP_SOLIDSTATE) ? "SS" : "",
+		(p->flags & SWP_DISCARDABLE) ? "D" : "");
+
 	mutex_unlock(&swapon_mutex);
 	atomic_inc(&proc_poll_event);
 	wake_up_interruptible(&proc_poll_wait);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
