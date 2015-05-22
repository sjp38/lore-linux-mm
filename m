Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id BA1C36B029B
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:03 -0400 (EDT)
Received: by qgew3 with SMTP id w3so17065133qge.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:03 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id d68si528412qhc.84.2015.05.22.15.23.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:23:59 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so23418901qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:23:59 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 10/19] writeback: add dirty_throttle_control->wb_completions
Date: Fri, 22 May 2015 18:23:27 -0400
Message-Id: <1432333416-6221-11-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

wb->completions measures the wb's proportional write bandwidth in
global_wb_domain and thus naturally tied to the wb_domain.  This patch
adds dirty_throttle_control->wb_completions which is initialized to
wb->completions by GDTC_INIT() and updates __wb_dirty_limits() to use
it instead of dereferencing wb->completions directly.

This will allow dirty_throttle_control to represent different
wb_domains and the matching wb completions.

This patch doesn't introduce any behavioral changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/page-writeback.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index fcebae7..5b439fc 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -127,6 +127,7 @@ struct wb_domain global_wb_domain;
 /* consolidated parameters for balance_dirty_pages() and its subroutines */
 struct dirty_throttle_control {
 	struct bdi_writeback	*wb;
+	struct fprop_local_percpu *wb_completions;
 
 	unsigned long		dirty;		/* file_dirty + write + nfs */
 	unsigned long		thresh;		/* dirty threshold */
@@ -139,7 +140,8 @@ struct dirty_throttle_control {
 	unsigned long		pos_ratio;
 };
 
-#define GDTC_INIT(__wb)		.wb = (__wb)
+#define GDTC_INIT(__wb)		.wb = (__wb),				\
+				.wb_completions = &(__wb)->completions
 
 /*
  * Length of period for aging writeout fractions of bdis. This is an
@@ -590,7 +592,7 @@ static unsigned long __wb_calc_thresh(struct dirty_throttle_control *dtc)
 	/*
 	 * Calculate this BDI's share of the thresh ratio.
 	 */
-	fprop_fraction_percpu(&dom->completions, &dtc->wb->completions,
+	fprop_fraction_percpu(&dom->completions, dtc->wb_completions,
 			      &numerator, &denominator);
 
 	wb_thresh = (thresh * (100 - bdi_min_ratio)) / 100;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
