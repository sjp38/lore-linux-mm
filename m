Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57CA96B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 04:16:58 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o868GqNi028235
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:16:53 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz13.hot.corp.google.com with ESMTP id o868Goo8017517
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 01:16:51 -0700
Received: by pwj10 with SMTP id 10so984618pwj.39
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 01:16:50 -0700 (PDT)
Date: Mon, 6 Sep 2010 01:17:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/4] swap: do not send discards as barriers
In-Reply-To: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
Message-ID: <alpine.LSU.2.00.1009060112470.13600@sister.anvils>
References: <alpine.LSU.2.00.1009060104410.13600@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Tejun Heo <tj@kernel.org>, Jens Axboe <jaxboe@fusionio.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Nigel Cunningham <nigel@tuxonice.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@infradead.org>

The swap code already uses synchronous discards, no need to add I/O
barriers.

This fixes the worst of the terrible slowdown in swap allocation for
hibernation, reported on 2.6.35 by Nigel Cunningham; but does not
entirely eliminate that regression.

tj: superflous newlines removed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Nigel Cunningham <nigel@tuxonice.net>
Signed-off-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Jens Axboe <jaxboe@fusionio.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: stable@kernel.org
---

 mm/swapfile.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

--- swap2/mm/swapfile.c	2010-09-05 22:45:54.000000000 -0700
+++ swap3/mm/swapfile.c	2010-09-05 22:47:21.000000000 -0700
@@ -139,8 +139,7 @@ static int discard_swap(struct swap_info
 	nr_blocks = ((sector_t)se->nr_pages - 1) << (PAGE_SHIFT - 9);
 	if (nr_blocks) {
 		err = blkdev_issue_discard(si->bdev, start_block,
-				nr_blocks, GFP_KERNEL,
-				BLKDEV_IFL_WAIT | BLKDEV_IFL_BARRIER);
+				nr_blocks, GFP_KERNEL, BLKDEV_IFL_WAIT);
 		if (err)
 			return err;
 		cond_resched();
@@ -151,8 +150,7 @@ static int discard_swap(struct swap_info
 		nr_blocks = (sector_t)se->nr_pages << (PAGE_SHIFT - 9);
 
 		err = blkdev_issue_discard(si->bdev, start_block,
-				nr_blocks, GFP_KERNEL,
-				BLKDEV_IFL_WAIT | BLKDEV_IFL_BARRIER);
+				nr_blocks, GFP_KERNEL, BLKDEV_IFL_WAIT);
 		if (err)
 			break;
 
@@ -191,8 +189,7 @@ static void discard_swap_cluster(struct
 			start_block <<= PAGE_SHIFT - 9;
 			nr_blocks <<= PAGE_SHIFT - 9;
 			if (blkdev_issue_discard(si->bdev, start_block,
-				    nr_blocks, GFP_NOIO, BLKDEV_IFL_WAIT |
-							BLKDEV_IFL_BARRIER))
+				    nr_blocks, GFP_NOIO, BLKDEV_IFL_WAIT))
 				break;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
