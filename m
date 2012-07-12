Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7281F6B009A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:28 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/12] Avoid dereferencing bd_disk during swap_entry_free for network storage
Date: Thu, 12 Jul 2012 07:41:06 +0100
Message-Id: <1342075266-29593-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Commit [b3a27d: swap: Add swap slot free callback to
block_device_operations] dereferences p->bdev->bd_disk but this is a
NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
on the swap_info_struct before dereferencing.

With reference to this callback, Christoph Hellwig stated "Please
just remove the callback entirely.  It has no user outside the staging
tree and was added clearly against the rules for that staging tree".
This would also be my preference but there was not an obvious way of
keeping zram in staging/ happy.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/swapfile.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1d77b13..f4c802d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -549,7 +549,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
-		struct gendisk *disk = p->bdev->bd_disk;
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -560,9 +559,11 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		nr_swap_pages++;
 		p->inuse_pages--;
 		frontswap_invalidate_page(p->type, offset);
-		if ((p->flags & SWP_BLKDEV) &&
-				disk->fops->swap_slot_free_notify)
-			disk->fops->swap_slot_free_notify(p->bdev, offset);
+		if (p->flags & SWP_BLKDEV) {
+			struct gendisk *disk = p->bdev->bd_disk;
+			if (disk->fops->swap_slot_free_notify)
+				disk->fops->swap_slot_free_notify(p->bdev, offset);
+		}
 	}
 
 	return usage;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
