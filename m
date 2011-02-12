Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C21B58D0043
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:49 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:46 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 23/24] sys_swapoff: change order to match sys_swapon
Date: Sat, 12 Feb 2011 16:49:24 -0200
Message-Id: <1297536565-8059-23-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

The block in sys_swapon which does the final adjustments to the
swap_info_struct and to swap_list is the same as the block which
re-inserts it again at sys_swapoff on failure of try_to_unuse(), except
for the order of the operations within the lock. Since the order should
not matter, arbitrarily change sys_swapoff to match sys_swapon, in
preparation to making both share the same code.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8f1b17b..deeb0b1 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1625,6 +1625,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_lock(&swap_lock);
 		if (p->prio < 0)
 			p->prio = --least_priority;
+		p->flags |= SWP_WRITEOK;
+		nr_swap_pages += p->pages;
+		total_swap_pages += p->pages;
+
 		prev = -1;
 		for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
 			if (p->prio >= swap_info[i]->prio)
@@ -1636,9 +1640,6 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 			swap_list.head = swap_list.next = type;
 		else
 			swap_info[prev]->next = type;
-		nr_swap_pages += p->pages;
-		total_swap_pages += p->pages;
-		p->flags |= SWP_WRITEOK;
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
