From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/6] writeback: fix queue_io() ordering
Date: Sun, 11 Jul 2010 10:07:01 +0800
Message-ID: <20100711021749.163345723@intel.com>
References: <20100711020656.340075560@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OXmR2-0002KP-Dh
	for glkm-linux-mm-2@m.gmane.org; Sun, 11 Jul 2010 04:38:28 +0200
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C8C4C6B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 22:38:12 -0400 (EDT)
Content-Disposition: inline; filename=queue_io-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This was not a bug, since b_io is empty for kupdate writeback.
The next patch will do requeue_io() for non-kupdate writeback,
so let's fix it.

CC: Dave Chinner <david@fromorbit.com>
Cc: Martin Bligh <mbligh@google.com>
Cc: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-11 09:13:31.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-11 09:13:32.000000000 +0800
@@ -252,11 +252,14 @@ static void move_expired_inodes(struct l
 }
 
 /*
- * Queue all expired dirty inodes for io, eldest first.
+ * Queue all expired dirty inodes for io, eldest first:
+ * (newly dirtied) => b_dirty inodes
+ *                 => b_more_io inodes
+ *                 => remaining inodes in b_io => (dequeue for sync)
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
