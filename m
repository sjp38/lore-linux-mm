Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7B66B01B0
	for <linux-mm@kvack.org>; Wed, 26 May 2010 08:21:31 -0400 (EDT)
Date: Wed, 26 May 2010 14:21:26 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526122126.GL23411@kernel.dk>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk> <20100526120855.GA30912@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526120855.GA30912@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26 2010, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 01:49:50PM +0200, Jens Axboe wrote:
> > Oops yes, you need to revert the parent too. But nevermind, I think I
> > see the issue. Can you try the below (go back to -git again)?
> 
> This one crashes during mount of the first XFS fs in a really strange
> way:

Clearly only half baked, weird. So from the looks of it:

> [   44.897741] XFS mounting filesystem vdb6
> [   45.188094] BUG: unable to handle kernel paging request at 6b6b6b6b
> [   45.190150] IP: [<6b6b6b6b>] 0x6b6b6b6b

it still ends up calling call_rcu() which I did not intend for it to do,
I must have made a mistake. My test equipment is packed down these days,
but I'll try on my workstation and send you a better patch.

Ugh ok I see it, I had the caller_frees reverted. Try this :-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index ea8592b..e173d02 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -121,6 +121,7 @@ static void bdi_work_free(struct rcu_head *head)
 static void wb_work_complete(struct bdi_work *work)
 {
 	const enum writeback_sync_modes sync_mode = work->args.sync_mode;
+	const int caller_frees = work->args.sb_pinned;
 	int onstack = bdi_work_on_stack(work);
 
 	/*
@@ -131,7 +132,7 @@ static void wb_work_complete(struct bdi_work *work)
 	 */
 	if (!onstack)
 		bdi_work_clear(work);
-	if (sync_mode == WB_SYNC_NONE || onstack)
+	if ((sync_mode == WB_SYNC_NONE && !caller_frees) || onstack)
 		call_rcu(&work->rcu_head, bdi_work_free);
 }
 
@@ -206,8 +207,10 @@ static void bdi_alloc_queue_work(struct backing_dev_info *bdi,
 	if (work) {
 		bdi_work_init(work, args);
 		bdi_queue_work(bdi, work);
-		if (wait)
+		if (wait) {
 			bdi_wait_on_work_clear(work);
+			kfree(work);
+		}
 	} else {
 		struct bdi_writeback *wb = &bdi->wb;
 

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
