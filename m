Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 010C98D0042
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 13:49:48 -0500 (EST)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-01.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 12 Feb 2011 18:49:45 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 18/24] sys_swapon: call swap_cgroup_swapon earlier
Date: Sat, 12 Feb 2011 16:49:19 -0200
Message-Id: <1297536565-8059-18-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4D56D5F9.8000609@cesarb.net>
References: <4D56D5F9.8000609@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>

The call to swap_cgroup_swapon is in the middle of loading the swap map
and extents. As it only does memory allocation and does not depend on
the swapfile layout (map/extents), it can be called earlier (or later).

Move it to just after the allocation of swap_map, since it is
conceptually similar (allocates a map).

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 33c939d..6e9575b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2074,6 +2074,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 
+	error = swap_cgroup_swapon(p->type, maxpages);
+	if (error)
+		goto bad_swap;
+
 	nr_good_pages = maxpages - 1;	/* omit header page */
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
@@ -2088,10 +2092,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
-	error = swap_cgroup_swapon(p->type, maxpages);
-	if (error)
-		goto bad_swap;
-
 	if (nr_good_pages) {
 		swap_map[0] = SWAP_MAP_BAD;
 		p->max = maxpages;
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
