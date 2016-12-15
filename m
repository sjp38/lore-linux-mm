Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 49FD46B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:15:22 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so21085365wjo.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:15:22 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 196si11845832wmg.139.2016.12.15.02.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 02:15:20 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so5420248wmu.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:15:20 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: throttle show_mem from warn_alloc
Date: Thu, 15 Dec 2016 11:15:10 +0100
Message-Id: <20161215101510.9030-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has been stressing OOM killer path with many parallel allocation
requests when he has noticed that it is not all that hard to swamp
kernel logs with warn_alloc messages caused by allocation stalls. Even
though the allocation stall message is triggered only once in 10s there
might be many different tasks hitting it roughly around the same time.

A big part of the output is show_mem() which can generate a lot of
output even on a small machines. There is no reason to show the state of
memory counter for each allocation stall, especially when multiple of
them are reported in a short time period. Chances are that not much has
changed since the last report. This patch simply rate limits show_mem
called from warn_alloc to only dump something once per second. This
should be enough to give us a clue why an allocation might be stalling
while burst of warnings will not swamp log with too much data.

While we are at it, extract all the show_mem related handling (filters)
into a separate function warn_alloc_show_mem. This will make the code
cleaner and as a bonus point we can distinguish which part of warn_alloc
got throttled due to rate limiting as ___ratelimit dumps the caller.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f2c9e535f7f..7a46fc300f18 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3019,14 +3019,13 @@ static DEFINE_RATELIMIT_STATE(nopage_rs,
 		DEFAULT_RATELIMIT_INTERVAL,
 		DEFAULT_RATELIMIT_BURST);
 
-void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
+static DEFINE_RATELIMIT_STATE(show_mem_rs, HZ, 1);
+
+static void warn_alloc_show_mem(gfp_t gfp_mask)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
-	struct va_format vaf;
-	va_list args;
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
-	    debug_guardpage_minorder() > 0)
+	if (should_suppress_show_mem() || !__ratelimit(&show_mem_rs))
 		return;
 
 	/*
@@ -3041,6 +3040,18 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	if (in_interrupt() || !(gfp_mask & __GFP_DIRECT_RECLAIM))
 		filter &= ~SHOW_MEM_FILTER_NODES;
 
+	show_mem(filter);
+}
+
+void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
+	    debug_guardpage_minorder() > 0)
+		return;
+
 	pr_warn("%s: ", current->comm);
 
 	va_start(args, fmt);
@@ -3052,8 +3063,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	pr_cont(", mode:%#x(%pGg)\n", gfp_mask, &gfp_mask);
 
 	dump_stack();
-	if (!should_suppress_show_mem())
-		show_mem(filter);
+	warn_alloc_show_mem(gfp_mask);
 }
 
 static inline struct page *
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
