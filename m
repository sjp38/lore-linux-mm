Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3A8BD6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 19:52:58 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 09:45:49 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 614213578045
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:52:52 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5INqhZ63342634
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:52:43 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5INqpDd016762
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:52:52 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 2/6] mm/writeback: Don't check force_wait to handle bdi->work_list
Date: Wed, 19 Jun 2013 07:52:39 +0800
Message-Id: <1371599563-6424-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v3 - > v4:
    * add Tejun's Reviewed-by

After commit 839a8e86("writeback: replace custom worker pool implementation
with unbound workqueue"), bdi_writeback_workfn runs off bdi_writeback->dwork,
on each execution, it processes bdi->work_list and reschedules if there are
more things to do instead of flush any work that race with us existing. It is
unecessary to check force_wait in wb_do_writeback since it is always 0 after
the mentioned commit. This patch remove the force_wait in wb_do_writeback.

Reviewed-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 fs/fs-writeback.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

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
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
