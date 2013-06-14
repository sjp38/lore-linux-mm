Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id E5B2A6B0036
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 03:31:04 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 14 Jun 2013 12:55:07 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 65B3AE0054
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 13:00:20 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5E7UtPv8257554
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 13:00:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5E7Uvlt013030
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 17:30:59 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 3/8] mm/writeback: Don't check force_wait to handle bdi->work_list
Date: Fri, 14 Jun 2013 15:30:36 +0800
Message-Id: <1371195041-26654-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371195041-26654-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

After commit 839a8e86("writeback: replace custom worker pool implementation
with unbound workqueue"), bdi_writeback_workfn runs off bdi_writeback->dwork,
on each execution, it processes bdi->work_list and reschedules if there are
more things to do instead of flush any work that race with us existing. It is
unecessary to check force_wait in wb_do_writeback since it is always 0 after
the mentioned commit. This patch remove the force_wait in wb_do_writeback.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 fs/fs-writeback.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index f892dec..e15aa97 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -959,7 +959,7 @@ static long wb_check_old_data_flush(struct bdi_writeback *wb)
 /*
  * Retrieve work items and do the writeback they describe
  */
-static long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
+static long wb_do_writeback(struct bdi_writeback *wb)
 {
 	struct backing_dev_info *bdi = wb->bdi;
 	struct wb_writeback_work *work;
@@ -967,12 +967,6 @@ static long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
 
 	set_bit(BDI_writeback_running, &wb->bdi->state);
 	while ((work = get_next_work_item(bdi)) != NULL) {
-		/*
-		 * Override sync mode, in case we must wait for completion
-		 * because this thread is exiting now.
-		 */
-		if (force_wait)
-			work->sync_mode = WB_SYNC_ALL;
 
 		trace_writeback_exec(bdi, work);
 
@@ -1021,7 +1015,7 @@ void bdi_writeback_workfn(struct work_struct *work)
 		 * rescuer as work_list needs to be drained.
 		 */
 		do {
-			pages_written = wb_do_writeback(wb, 0);
+			pages_written = wb_do_writeback(wb);
 			trace_writeback_pages_written(pages_written);
 		} while (!list_empty(&bdi->work_list));
 	} else {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
