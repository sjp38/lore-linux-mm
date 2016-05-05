Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B56A76B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 04:14:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so8640637wme.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 01:14:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ib3si10017361wjb.118.2016.05.05.01.14.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 May 2016 01:14:56 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] writeback: Avoid exhausting allocation reserves under memory pressure
Date: Thu,  5 May 2016 10:14:52 +0200
Message-Id: <1462436092-32665-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mhocko@suse.cz, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org, Jan Kara <jack@suse.cz>

When system is under memory pressure memory management frequently calls
wakeup_flusher_threads() to writeback pages to that they can be freed.
This was observed to exhaust reserves for atomic allocations since
wakeup_flusher_threads() allocates one writeback work for each device
with dirty data with GFP_ATOMIC.

However it is pointless to allocate new work items when requested work
is identical. Instead, we can merge the new work with the pending work
items and thus save memory allocation.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                | 37 +++++++++++++++++++++++++++++++++++++
 include/trace/events/writeback.h |  1 +
 2 files changed, 38 insertions(+)

This is a patch which should (and in my basic testing does) address the issues
with many atomic allocations Tetsuo reported. What do people think?

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index fee81e8768c9..bb6725f5b1ba 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -189,6 +189,35 @@ out_unlock:
 	spin_unlock_bh(&wb->work_lock);
 }
 
+/*
+ * Check whether the request to writeback some pages can be merged with some
+ * other request which is already pending. If yes, merge it and return true.
+ * If no, return false.
+ */
+static bool wb_merge_request(struct bdi_writeback *wb, long nr_pages,
+			     struct super_block *sb, bool range_cyclic,
+			     enum wb_reason reason)
+{
+	struct wb_writeback_work *work;
+	bool merged = false;
+
+	spin_lock_bh(&wb->work_lock);
+	list_for_each_entry(work, &wb->work_list, list) {
+		if (work->reason == reason &&
+		    work->range_cyclic == range_cyclic &&
+		    work->auto_free == 1 && work->sb == sb &&
+		    work->for_sync == 0) {
+			work->nr_pages += nr_pages;
+			merged = true;
+			trace_writeback_merged(wb, work);
+			break;
+		}
+	}
+	spin_unlock_bh(&wb->work_lock);
+
+	return merged;
+}
+
 /**
  * wb_wait_for_completion - wait for completion of bdi_writeback_works
  * @bdi: bdi work items were issued to
@@ -928,6 +957,14 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 		return;
 
 	/*
+	 * Can we merge current request with another pending one - saves us
+	 * atomic allocation which can be significant e.g. when MM is under
+	 * pressure and calls wake_up_flusher_threads() a lot.
+	 */
+	if (wb_merge_request(wb, nr_pages, NULL, range_cyclic, reason))
+		return;
+
+	/*
 	 * This is WB_SYNC_NONE writeback, so if allocation fails just
 	 * wakeup the thread for old dirty data writeback
 	 */
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 73614ce1d204..84ad9fac475b 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -252,6 +252,7 @@ DEFINE_WRITEBACK_WORK_EVENT(writeback_exec);
 DEFINE_WRITEBACK_WORK_EVENT(writeback_start);
 DEFINE_WRITEBACK_WORK_EVENT(writeback_written);
 DEFINE_WRITEBACK_WORK_EVENT(writeback_wait);
+DEFINE_WRITEBACK_WORK_EVENT(writeback_merged);
 
 TRACE_EVENT(writeback_pages_written,
 	TP_PROTO(long pages_written),
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
