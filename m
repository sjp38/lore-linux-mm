Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35D888D004C
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 18:29:03 -0500 (EST)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCHv2 18/24] sys_swapon: call swap_cgroup_swapon earlier
Date: Tue,  1 Mar 2011 20:28:42 -0300
Message-Id: <1299022128-6239-19-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>

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
index 13c13bd..7ac81fe 100644
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
