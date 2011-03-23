Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5318F8D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 22:03:28 -0400 (EDT)
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] sys_swapon: fix inode locking
Date: Tue, 22 Mar 2011 23:03:13 -0300
Message-Id: <1300845793-6068-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Cesar Eduardo Barros <cesarb@cesarb.net>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Eric B Munson <emunson@mgebm.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

A conflict between 52c50567d8ab0a0a87f12cceaa4194967854f0bd (mm: swap:
unlock swapfile inode mutex before closing file on bad swapfiles) and
83ef99befc324803a54cf2a5fab5a322df3a99d6 (sys_swapon: remove did_down
variable) caused a double unlock of the inode mutex (once in bad_swap:
before the filp_close, once at the end just before returning).

The patch which added the extra unlock cleared did_down to avoid
unlocking twice, but the other patch removed the did_down variable.

To fix, set inode to NULL after the first unlock, since it will be used
after that point only for the final unlock.

While checking this patch, I found a path which could unlock without
locking, in case the same inode was added as a swapfile twice. To fix,
move the setting of the inode variable further down, to just before
claim_swapfile, which will lock the inode before doing anything else.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Eric B Munson <emunson@mgebm.net>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 mm/swapfile.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index aafcf36..71b42ec 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2088,7 +2088,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 
 	p->swap_file = swap_file;
 	mapping = swap_file->f_mapping;
-	inode = mapping->host;
 
 	for (i = 0; i < nr_swapfiles; i++) {
 		struct swap_info_struct *q = swap_info[i];
@@ -2101,6 +2100,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		}
 	}
 
+	inode = mapping->host;
+	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
 	error = claim_swapfile(p, inode);
 	if (unlikely(error))
 		goto bad_swap;
@@ -2187,8 +2188,10 @@ bad_swap:
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
 	if (swap_file) {
-		if (inode && S_ISREG(inode->i_mode))
+		if (inode && S_ISREG(inode->i_mode)) {
 			mutex_unlock(&inode->i_mutex);
+			inode = NULL;
+		}
 		filp_close(swap_file, NULL);
 	}
 out:
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
