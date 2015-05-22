Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2634C6B02A5
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:14 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so23423198qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:14 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id c7si3883627qcf.43.2015.05.22.15.24.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:08 -0700 (PDT)
Received: by qkx62 with SMTP id 62so23320946qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:08 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 15/19] writeback: update wb_over_bg_thresh() to use wb_domain aware operations
Date: Fri, 22 May 2015 18:23:32 -0400
Message-Id: <1432333416-6221-16-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

wb_over_bg_thresh() currently uses global_dirty_limits() and
wb_dirty_limit() both of which are wrappers around operations which
take dirty_throttle_control.  For cgroup writeback support, the
function will be updated to also consider memcg wb_domains which
requires the context information carried in dirty_throttle_control.

This patch updates wb_over_bg_thresh() so that it uses the underlying
wb_domain aware operations directly and builds the global
dirty_throttle_control in the process.

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9d9a896..a7ba5ce 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1749,15 +1749,22 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
  */
 bool wb_over_bg_thresh(struct bdi_writeback *wb)
 {
-	unsigned long background_thresh, dirty_thresh;
+	struct dirty_throttle_control gdtc_stor = { GDTC_INIT(wb) };
+	struct dirty_throttle_control * const gdtc = &gdtc_stor;
 
-	global_dirty_limits(&background_thresh, &dirty_thresh);
+	/*
+	 * Similar to balance_dirty_pages() but ignores pages being written
+	 * as we're trying to decide whether to put more under writeback.
+	 */
+	gdtc->avail = global_dirtyable_memory();
+	gdtc->dirty = global_page_state(NR_FILE_DIRTY) +
+		      global_page_state(NR_UNSTABLE_NFS);
+	domain_dirty_limits(gdtc);
 
-	if (global_page_state(NR_FILE_DIRTY) +
-	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+	if (gdtc->dirty > gdtc->bg_thresh)
 		return true;
 
-	if (wb_stat(wb, WB_RECLAIMABLE) > wb_calc_thresh(wb, background_thresh))
+	if (wb_stat(wb, WB_RECLAIMABLE) > __wb_calc_thresh(gdtc))
 		return true;
 
 	return false;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
