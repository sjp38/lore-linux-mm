Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 668F56B00EE
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 11:57:29 -0400 (EDT)
Received: by pzk6 with SMTP id 6so4243066pzk.36
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 08:57:21 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
Date: Thu,  1 Sep 2011 21:27:02 +0530
Message-Id: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

This is important for SMP scenario, to check whether the timer
callback is executing on another CPU when we are deleting the
timer.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/backing-dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d6edf8d..754b35a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
 		 * dirty data on the default backing_dev_info
 		 */
 		if (wb_has_dirty_io(me) || !list_empty(&me->bdi->work_list)) {
-			del_timer(&me->wakeup_timer);
+			del_timer_sync(&me->wakeup_timer);
 			wb_do_writeback(me, 0);
 		}
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
