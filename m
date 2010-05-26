Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7071B6B01D7
	for <linux-mm@kvack.org>; Wed, 26 May 2010 08:56:18 -0400 (EDT)
Date: Wed, 26 May 2010 14:56:15 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: writeback hang in current mainline
Message-ID: <20100526125614.GM23411@kernel.dk>
References: <20100526111326.GA28541@lst.de> <20100526112125.GJ23411@kernel.dk> <20100526114018.GA30107@lst.de> <20100526114950.GK23411@kernel.dk> <20100526120855.GA30912@lst.de> <20100526122126.GL23411@kernel.dk> <20100526124549.GA32550@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526124549.GA32550@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26 2010, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 02:21:26PM +0200, Jens Axboe wrote:
> > Ugh ok I see it, I had the caller_frees reverted. Try this :-)
> 
> This seems to fix it.  Running some more tests now.

Goodie, then the analysis at least is correct. A potentially cleaner fix
would be to just allocate the WB_SYNC_NONE && sb_pinned work struct on
the stack, since then we can get rid of that nastiness in
wb_work_complete() as well (and not pass 'sb_pinned' around so much).

If you have time, care to test this one as well?

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 5c4161f..e9d6182 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -193,8 +193,7 @@ static void bdi_wait_on_work_clear(struct bdi_work *work)
 }
 
 static void bdi_alloc_queue_work(struct backing_dev_info *bdi,
-				 struct wb_writeback_args *args,
-				 int wait)
+				 struct wb_writeback_args *args)
 {
 	struct bdi_work *work;
 
@@ -206,8 +205,6 @@ static void bdi_alloc_queue_work(struct backing_dev_info *bdi,
 	if (work) {
 		bdi_work_init(work, args);
 		bdi_queue_work(bdi, work);
-		if (wait)
-			bdi_wait_on_work_clear(work);
 	} else {
 		struct bdi_writeback *wb = &bdi->wb;
 
@@ -216,6 +213,18 @@ static void bdi_alloc_queue_work(struct backing_dev_info *bdi,
 	}
 }
 
+static void bdi_queue_wait_wb_args(struct backing_dev_info *bdi,
+				   struct wb_writeback_args *args)
+{
+	struct bdi_work work;
+
+	bdi_work_init(&work, args);
+	work.state |= WS_ONSTACK;
+
+	bdi_queue_work(bdi, &work);
+	bdi_wait_on_work_clear(&work);
+}
+
 /**
  * bdi_sync_writeback - start and wait for writeback
  * @bdi: the backing device to write from
@@ -240,13 +249,8 @@ static void bdi_sync_writeback(struct backing_dev_info *bdi,
 		 */
 		.sb_pinned	= 1,
 	};
-	struct bdi_work work;
-
-	bdi_work_init(&work, &args);
-	work.state |= WS_ONSTACK;
 
-	bdi_queue_work(bdi, &work);
-	bdi_wait_on_work_clear(&work);
+	bdi_queue_wait_wb_args(bdi, &args);
 }
 
 /**
@@ -282,7 +286,10 @@ void bdi_start_writeback(struct backing_dev_info *bdi, struct super_block *sb,
 		args.for_background = 1;
 	}
 
-	bdi_alloc_queue_work(bdi, &args, sb_locked);
+	if (!sb_locked)
+		bdi_alloc_queue_work(bdi, &args);
+	else
+		bdi_queue_wait_wb_args(bdi, &args);
 }
 
 /*
@@ -1011,7 +1018,7 @@ static void bdi_writeback_all(struct super_block *sb, long nr_pages)
 		if (!bdi_has_dirty_io(bdi))
 			continue;
 
-		bdi_alloc_queue_work(bdi, &args, 0);
+		bdi_alloc_queue_work(bdi, &args);
 	}
 
 	rcu_read_unlock();

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
