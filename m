Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 600FB6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 04:57:21 -0400 (EDT)
Date: Fri, 8 Oct 2010 16:35:14 +0800
From: Yong Wang <yong.y.wang@linux.intel.com>
Subject: [PATCH] bdi: use deferable timer for sync_supers task
Message-ID: <20101008083514.GA12402@ywang-moblin2.bj.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xia.wu@intel.com
List-ID: <linux-mm.kvack.org>

sync_supers task currently wakes up periodically for superblock
writeback. This hurts power on battery driven devices. This patch
turns this housekeeping timer into a deferable timer so that it
does not fire when system is really idle.

Signed-off-by: Yong Wang <yong.y.wang@intel.com>
Signed-off-by: Xia Wu <xia.wu@intel.com>
---
 mm/backing-dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 65d4204..9a8daa5 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -238,7 +238,9 @@ static int __init default_bdi_init(void)
 	sync_supers_tsk = kthread_run(bdi_sync_supers, NULL, "sync_supers");
 	BUG_ON(IS_ERR(sync_supers_tsk));
 
-	setup_timer(&sync_supers_timer, sync_supers_timer_fn, 0);
+	init_timer_deferrable(&sync_supers_timer);
+	sync_supers_timer.function = sync_supers_timer_fn;
+	sync_supers_timer.data = 0;
 	bdi_arm_supers_timer();
 
 	err = bdi_init(&default_backing_dev_info);
-- 
1.5.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
