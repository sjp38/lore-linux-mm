Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C6E7E6B0037
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 08:52:34 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so670179pab.11
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 05:52:34 -0700 (PDT)
Subject: [PATCH] writeback: fix delayed sync(2)
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Fri, 20 Sep 2013 16:52:26 +0400
Message-ID: <20130920125029.17356.66782.stgit@dhcp-10-30-17-2.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tj@kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, jack@suse.cz, linux-kernel@vger.kernel.org

Problem statement: if sync(2) races with bdi_wakeup_thread_delayed
(which is called when the first inode for a bdi is marked dirty), it's
possible that sync will be delayed for long (5 secs if dirty_writeback_interval
is set to default value).

How it works: sync schedules bdi work for immediate processing by calling
mod_delayed_work with 'delay' equal to 0. Bdi work is queued to pool->worklist
and wake_up_worker(pool) is called, but before worker gets the work from
the list, __mark_inode_dirty intervenes calling bdi_wakeup_thread_delayed
who calls mod_delayed_work with 'timeout' equal to dirty_writeback_interval
multiplied by 10. mod_delayed_work dives into try_to_grab_pending who
successfully steals the work from the worklist. Then it's re-queued with that
new delay. Until the timeout is lapsed, sync(2) sits on wait_for_completion in
sync_inodes_sb.

The patch uses queue_delayed_work for __mark_inode_dirty. This should be safe
because even if queue_delayed_work returns false (if the work is already on
a queue), bdi_writeback_workfn will re-schedule itself by looking at
wb->b_dirty.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 mm/backing-dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ce682f7..3fde024 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -294,7 +294,7 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
 	unsigned long timeout;
 
 	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
-	mod_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
+	queue_delayed_work(bdi_wq, &bdi->wb.dwork, timeout);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
