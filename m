Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 883D6829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:12 -0400 (EDT)
Received: by qgfa63 with SMTP id a63so16279343qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:12 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id y199si58671qky.13.2015.05.22.14.15.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:11 -0700 (PDT)
Received: by qgez61 with SMTP id z61so16256975qge.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:11 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 29/51] writeback, blkcg: propagate non-root blkcg congestion state
Date: Fri, 22 May 2015 17:13:43 -0400
Message-Id: <1432329245-5844-30-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
index b457c4f..cf6974e 100644
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
