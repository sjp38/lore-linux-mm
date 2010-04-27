Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E95F76B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 14:08:10 -0400 (EDT)
Date: Tue, 27 Apr 2010 11:08:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: April 27 (mm/page-writeback)
Message-Id: <20100427110807.d8641ace.akpm@linux-foundation.org>
In-Reply-To: <8ea19b02-d4d8-4000-9842-fec7f5bcf90d@default>
References: <8ea19b02-d4d8-4000-9842-fec7f5bcf90d@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux-Next <linux-next@vger.kernel.org>, Matthew Garrett <mjg@redhat.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Apr 2010 09:19:30 -0700 (PDT)
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> When CONFIG_BLOCK is not enabled:
> 
> mm/page-writeback.c:707: error: dereferencing pointer to incomplete type
> mm/page-writeback.c:708: error: dereferencing pointer to incomplete type
> 

Subject: "laptop-mode: Make flushes per-device" fix
From: Andrew Morton <akpm@linux-foundation.org>

When CONFIG_BLOCK is not enabled:

mm/page-writeback.c:707: error: dereferencing pointer to incomplete type
mm/page-writeback.c:708: error: dereferencing pointer to incomplete type

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Matthew Garrett <mjg@redhat.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 block/blk-core.c          |   15 +++++++++++++++
 include/linux/writeback.h |    1 -
 mm/page-writeback.c       |   15 ---------------
 3 files changed, 15 insertions(+), 16 deletions(-)

diff -puN block/blk-core.c~laptop-mode-make-flushes-per-device-fix block/blk-core.c
--- a/block/blk-core.c~laptop-mode-make-flushes-per-device-fix
+++ a/block/blk-core.c
@@ -488,6 +488,21 @@ struct request_queue *blk_alloc_queue(gf
 }
 EXPORT_SYMBOL(blk_alloc_queue);
 
+static void laptop_mode_timer_fn(unsigned long data)
+{
+	struct request_queue *q = (struct request_queue *)data;
+	int nr_pages = global_page_state(NR_FILE_DIRTY) +
+		global_page_state(NR_UNSTABLE_NFS);
+
+	/*
+	 * We want to write everything out, not just down to the dirty
+	 * threshold
+	 */
+
+	if (bdi_has_dirty_io(&q->backing_dev_info))
+		bdi_start_writeback(&q->backing_dev_info, NULL, nr_pages);
+}
+
 struct request_queue *blk_alloc_queue_node(gfp_t gfp_mask, int node_id)
 {
 	struct request_queue *q;
diff -puN mm/page-writeback.c~laptop-mode-make-flushes-per-device-fix mm/page-writeback.c
--- a/mm/page-writeback.c~laptop-mode-make-flushes-per-device-fix
+++ a/mm/page-writeback.c
@@ -693,21 +693,6 @@ int dirty_writeback_centisecs_handler(ct
 	return 0;
 }
 
-void laptop_mode_timer_fn(unsigned long data)
-{
-	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS);
-
-	/*
-	 * We want to write everything out, not just down to the dirty
-	 * threshold
-	 */
-
-	if (bdi_has_dirty_io(&q->backing_dev_info))
-		bdi_start_writeback(&q->backing_dev_info, NULL, nr_pages);
-}
-
 /*
  * We've spun up the disk and we're in laptop mode: schedule writeback
  * of all dirty data a few seconds from now.  If the flush is already scheduled
diff -puN include/linux/writeback.h~laptop-mode-make-flushes-per-device-fix include/linux/writeback.h
--- a/include/linux/writeback.h~laptop-mode-make-flushes-per-device-fix
+++ a/include/linux/writeback.h
@@ -99,7 +99,6 @@ static inline void inode_sync_wait(struc
 void laptop_io_completion(struct backing_dev_info *info);
 void laptop_sync_completion(void);
 void laptop_mode_sync(struct work_struct *work);
-void laptop_mode_timer_fn(unsigned long data);
 void throttle_vm_writeout(gfp_t gfp_mask);
 
 /* These are exported to sysctl. */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
