Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA77F600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:30:47 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 31/31] swapfile: avoid NULL pointer dereference in swapon when s_bdev is NULL
Date: Thu,  1 Oct 2009 19:41:09 +0530
Message-Id: <1254406269-16771-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

While testing Swap over NFS patchset, I noticed an oops that was triggered
during swapon. Investigating further, the NULL pointer deference is due to the
SSD device check/optimization in the swapon code that assumes s_bdev is not
NULL.

inode->i_sb->s_bdev could be NULL in a few cases. For e.g. one such case is
loopback NFS mount, there could be others as well. Fix this by ensuring s_bdev
is not NULL before we try to deference s_bdev.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 mm/swapfile.c |   26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

Index: mmotm/mm/swapfile.c
===================================================================
--- mmotm.orig/mm/swapfile.c
+++ mmotm/mm/swapfile.c
@@ -160,10 +160,12 @@ static int discard_swap(struct swap_info
 				continue;
 		}
 
-		err = blkdev_issue_discard(si->bdev, start_block,
+		if (si->bdev) {
+			err = blkdev_issue_discard(si->bdev, start_block,
 						nr_blocks, GFP_KERNEL);
-		if (err)
-			break;
+			if (err)
+				break;
+		}
 
 		cond_resched();
 	}
@@ -199,9 +201,11 @@ static void discard_swap_cluster(struct
 
 			start_block <<= PAGE_SHIFT - 9;
 			nr_blocks <<= PAGE_SHIFT - 9;
-			if (blkdev_issue_discard(si->bdev, start_block,
+			if (si->bdev) {
+				if (blkdev_issue_discard(si->bdev, start_block,
 							nr_blocks, GFP_NOIO))
-				break;
+					break;
+			}
 		}
 
 		lh = se->list.next;
@@ -1991,12 +1995,14 @@ SYSCALL_DEFINE2(swapon, const char __use
 		goto bad_swap;
 	}
 
-	if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
-		p->flags |= SWP_SOLIDSTATE;
-		p->cluster_next = 1 + (random32() % p->highest_bit);
+	if (p->bdev) {
+		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
+			p->flags |= SWP_SOLIDSTATE;
+			p->cluster_next = 1 + (random32() % p->highest_bit);
+		}
+		if (discard_swap(p) == 0)
+			p->flags |= SWP_DISCARDABLE;
 	}
-	if (discard_swap(p) == 0)
-		p->flags |= SWP_DISCARDABLE;
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
