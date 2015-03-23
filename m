Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0A69B6B00AD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:09 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so137699244qgf.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:08 -0700 (PDT)
Received: from mail-qc0-x236.google.com (mail-qc0-x236.google.com. [2607:f8b0:400d:c01::236])
        by mx.google.com with ESMTPS id x7si11275019qce.15.2015.03.22.21.55.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:54 -0700 (PDT)
Received: by qcto4 with SMTP id o4so136680470qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:54 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 27/48] writeback, blkcg: propagate non-root blkcg congestion state
Date: Mon, 23 Mar 2015 00:54:38 -0400
Message-Id: <1427086499-15657-28-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Now that bdi layer can handle per-blkcg bdi_writeback_congested state,
blk_{set|clear}_congested() can propagate non-root blkcg congestion
state to them.

This can be easily achieved by disabling the root_rl tests in
blk_{set|clear}_congested().  Note that we still need those tests when
!CONFIG_CGROUP_WRITEBACK as otherwise we'll end up flipping root blkcg
wb's congestion state for events happening on other blkcgs.

v2: Updated for bdi_writeback_congested.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 block/blk-core.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index cad26e3..95488fb 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -65,23 +65,26 @@ static struct workqueue_struct *kblockd_workqueue;
 
 static void blk_clear_congested(struct request_list *rl, int sync)
 {
-	if (rl != &rl->q->root_rl)
-		return;
 #ifdef CONFIG_CGROUP_WRITEBACK
 	clear_wb_congested(rl->blkg->wb_congested, sync);
 #else
-	clear_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
+	/*
+	 * If !CGROUP_WRITEBACK, all blkg's map to bdi->wb and we shouldn't
+	 * flip its congestion state for events on other blkcgs.
+	 */
+	if (rl == &rl->q->root_rl)
+		clear_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
 #endif
 }
 
 static void blk_set_congested(struct request_list *rl, int sync)
 {
-	if (rl != &rl->q->root_rl)
-		return;
 #ifdef CONFIG_CGROUP_WRITEBACK
 	set_wb_congested(rl->blkg->wb_congested, sync);
 #else
-	set_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
+	/* see blk_clear_congested() */
+	if (rl == &rl->q->root_rl)
+		set_wb_congested(rl->q->backing_dev_info.wb.congested, sync);
 #endif
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
