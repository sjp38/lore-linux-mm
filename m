Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B51946B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 10:25:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so190198474pgf.3
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 07:25:43 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id 91si89074068ply.117.2017.01.09.07.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 07:25:42 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH] mm,compaction: serialize waitqueue_active() checks
Date: Mon,  9 Jan 2017 07:25:28 -0800
Message-Id: <1483975528-24342-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

Without a memory barrier, the following race can occur with a high-order
allocation:

wakeup_kcompactd(order == 1)  		     kcompactd()
  [L] waitqueue_active(kcompactd_wait)
						[S] prepare_to_wait_event(kcompactd_wait)
						[L] (kcompactd_max_order == 0)
  [S] kcompactd_max_order = order;		      schedule()

Where the waitqueue_active() check is speculatively re-ordered to before
setting the actual condition (max_order), not seeing the threads that's
going to block; making us miss a wakeup. There are a couple of options to
fix this, including calling wq_has_sleepers() which adds a full barrier,
or unconditionally doing the wake_up_interruptible() and serialize on the
q->lock. However, to make use of the control dependency, we just need to
add L->L guarantees.

While this bug is theoretical, there have been other offenders of the lockless
waitqueue_active() in the past -- this is also documented in the call itself.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/compaction.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 949198d01260..fb0f87554eb9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1950,6 +1950,13 @@ void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx)
 	if (pgdat->kcompactd_max_order < order)
 		pgdat->kcompactd_max_order = order;
 
+	/*
+	 * Pairs with implicit barrier in wait_event_freezable()
+	 * such that wakeups are not missed in the lockless
+	 * waitqueue_active() call.
+	 */
+	smp_acquire__after_ctrl_dep();
+
 	if (pgdat->kcompactd_classzone_idx > classzone_idx)
 		pgdat->kcompactd_classzone_idx = classzone_idx;
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
