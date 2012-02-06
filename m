Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 640566B140B
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:56 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/11] Avoid dereferencing bd_disk during swap_entry_free for network storage
Date: Mon,  6 Feb 2012 22:56:41 +0000
Message-Id: <1328569001-17599-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1328569001-17599-1-git-send-email-mgorman@suse.de>
References: <1328569001-17599-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

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
---
 mm/swapfile.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index e1bac6c..c549945 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -547,7 +547,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
-		struct gendisk *disk = p->bdev->bd_disk;
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -557,9 +556,11 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 			swap_list.next = p->type;
 		nr_swap_pages++;
 		p->inuse_pages--;
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
