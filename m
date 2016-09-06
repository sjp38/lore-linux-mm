Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 621916B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 10:53:09 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w78so266099671oie.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 07:53:09 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id f3si5090940oig.181.2016.09.06.07.52.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 07:53:00 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix oom work when memory is under pressure
Date: Tue, 6 Sep 2016 22:47:06 +0800
Message-ID: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, mhocko@kernel.org, rientjes@google.com, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Some hungtask come up when I run the trinity, and OOM occurs
frequently.
A task hold lock to allocate memory, due to the low memory,
it will lead to oom. at the some time , it will retry because
it find that oom is in progress. but it always allocate fails,
the freed memory was taken away quickly.
The patch fix it by limit times to avoid hungtask and livelock
come up.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a178b1d..0dcf08b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3457,6 +3457,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	int oom_failed = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3645,8 +3646,13 @@ retry:
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
 		goto got_pg;
+	else
+		oom_failed++;
+
+	/* more than limited times will drop out */
+	if (oom_failed > MAX_RECLAIM_RETRIES)
+		goto nopage;
 
-	/* Retry as long as the OOM killer is making progress */
 	if (did_some_progress) {
 		no_progress_loops = 0;
 		goto retry;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
