Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C4B636B0256
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:09:48 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e127so55238245pfe.3
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:09:48 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id hz1si4108262pac.132.2016.02.26.09.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:09:48 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id q63so54920704pfb.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:09:47 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [RFC PATCH] writeback: move list_lock down into the for loop
Date: Fri, 26 Feb 2016 08:46:25 -0800
Message-Id: <1456505185-21566-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

The list_lock was moved outside the for loop by commit
e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
into wb_writeback())", however, the commit log says "No behavior change", so
it sounds safe to have the list_lock acquired inside the for loop as it did
before.
Leave tracepoints outside the critical area since tracepoints already have
preempt disabled.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
Tested with ltp on 8 cores Cortex-A57 machine.

 fs/fs-writeback.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1f76d89..9b7b5f6 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1623,7 +1623,6 @@ static long wb_writeback(struct bdi_writeback *wb,
 	work->older_than_this = &oldest_jif;
 
 	blk_start_plug(&plug);
-	spin_lock(&wb->list_lock);
 	for (;;) {
 		/*
 		 * Stop writeback when nr_pages has been consumed
@@ -1661,15 +1660,19 @@ static long wb_writeback(struct bdi_writeback *wb,
 			oldest_jif = jiffies;
 
 		trace_writeback_start(wb, work);
+
+		spin_lock(&wb->list_lock);
 		if (list_empty(&wb->b_io))
 			queue_io(wb, work);
 		if (work->sb)
 			progress = writeback_sb_inodes(work->sb, wb, work);
 		else
 			progress = __writeback_inodes_wb(wb, work);
-		trace_writeback_written(wb, work);
 
 		wb_update_bandwidth(wb, wb_start);
+		spin_unlock(&wb->list_lock);
+
+		trace_writeback_written(wb, work);
 
 		/*
 		 * Did we write something? Try for more
@@ -1693,15 +1696,14 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 */
 		if (!list_empty(&wb->b_more_io))  {
 			trace_writeback_wait(wb, work);
+			spin_lock(&wb->list_lock);
 			inode = wb_inode(wb->b_more_io.prev);
-			spin_lock(&inode->i_lock);
 			spin_unlock(&wb->list_lock);
+			spin_lock(&inode->i_lock);
 			/* This function drops i_lock... */
 			inode_sleep_on_writeback(inode);
-			spin_lock(&wb->list_lock);
 		}
 	}
-	spin_unlock(&wb->list_lock);
 	blk_finish_plug(&plug);
 
 	return nr_pages - work->nr_pages;
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
