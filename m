Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id B16AD6B00C1
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:05:15 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so31114699qkh.2
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:15 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id o6si5155641qge.70.2015.04.06.13.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:05:04 -0700 (PDT)
Received: by qkx62 with SMTP id 62so31176073qkx.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:05:04 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 15/19] writeback: update wb_over_bg_thresh() to use wb_domain aware operations
Date: Mon,  6 Apr 2015 16:04:30 -0400
Message-Id: <1428350674-8303-16-git-send-email-tj@kernel.org>
In-Reply-To: <1428350674-8303-1-git-send-email-tj@kernel.org>
References: <1428350674-8303-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

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
index 1bc3a65..c08b053 100644
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
