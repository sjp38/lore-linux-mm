From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/13] writeback: fix queue_io() ordering
Date: Fri, 06 Aug 2010 00:10:56 +0800
Message-ID: <20100805162433.390104073@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3KF-0003He-TE
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:48 +0200
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E92B26B02BA
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:55 -0400 (EDT)
Content-Disposition: inline; filename=queue_io-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

This was not a bug, since b_io is empty for kupdate writeback.
The next patch will do requeue_io() for non-kupdate writeback,
so let's fix it.

CC: Dave Chinner <david@fromorbit.com>
Cc: Martin Bligh <mbligh@google.com>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

--- linux-next.orig/fs/fs-writeback.c	2010-08-05 23:03:37.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-08-05 23:21:43.000000000 +0800
@@ -253,10 +253,18 @@ static void move_expired_inodes(struct l
 
 /*
  * Queue all expired dirty inodes for io, eldest first.
+ * Before
+ *         newly dirtied     b_dirty    b_io    b_more_io
+ *         =============>    gf         edc     BA
+ * After
+ *         newly dirtied     b_dirty    b_io    b_more_io
+ *         =============>    g          fBAedc
+ *                                           |
+ *                                           +--> dequeue for IO
  */
 static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
 {
-	list_splice_init(&wb->b_more_io, wb->b_io.prev);
+	list_splice_init(&wb->b_more_io, &wb->b_io);
 	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
