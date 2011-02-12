Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8B58D003C
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:46 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:42 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 03/24] sys_swapon: do not depend on "type" after allocation
Date: Sat, 12 Feb 2011 16:49:04 -0200
Message-Id: <1297536565-8059-3-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

Within sys_swapon, after the swap_info entry has been allocated, we
always have type == p->type and swap_info[type] == p. Use this fact to
reduce the dependency on the "type" local variable within the function,
as a preparation to move the allocation of the swap_info entry to a
separate function.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 0fcbdca..f0fc4c0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1927,7 +1927,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	for (i = 0; i < nr_swapfiles; i++) {
 		struct swap_info_struct *q = swap_info[i];
 
-		if (i == type || !q->swap_file)
+		if (q == p || !q->swap_file)
 			continue;
 		if (mapping == q->swap_file->f_mapping)
 			goto bad_swap;
@@ -2062,7 +2062,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
-	error = swap_cgroup_swapon(type, maxpages);
+	error = swap_cgroup_swapon(p->type, maxpages);
 	if (error)
 		goto bad_swap;
 
@@ -2120,9 +2120,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	p->next = i;
 	if (prev < 0)
-		swap_list.head = swap_list.next = type;
+		swap_list.head = swap_list.next = p->type;
 	else
-		swap_info[prev]->next = type;
+		swap_info[prev]->next = p->type;
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	atomic_inc(&proc_poll_event);
@@ -2136,7 +2136,7 @@ bad_swap:
 		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	}
 	destroy_swap_extents(p);
-	swap_cgroup_swapoff(type);
+	swap_cgroup_swapoff(p->type);
 bad_swap_2:
 	spin_lock(&swap_lock);
 	p->swap_file = NULL;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
