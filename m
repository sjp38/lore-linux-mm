Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85E306B0318
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:49:14 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id bk3so53590828wjc.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:49:14 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id q19si22795539wju.89.2016.12.20.05.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:49:13 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so24524197wme.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:49:13 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] mm: help __GFP_NOFAIL allocations which do not trigger OOM killer
Date: Tue, 20 Dec 2016 14:49:04 +0100
Message-Id: <20161220134904.21023-4-mhocko@kernel.org>
In-Reply-To: <20161220134904.21023-1-mhocko@kernel.org>
References: <20161220134904.21023-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Now that __GFP_NOFAIL doesn't override decisions to skip the oom killer
we are left with requests which require to loop inside the allocator
without invoking the oom killer (e.g. GFP_NOFS|__GFP_NOFAIL used by fs
code) and so they might, in very unlikely situations, loop for ever -
e.g. other parallel request could starve them.

This patch tries to limit the likelihood of such a lockup by giving
these __GFP_NOFAIL requests a chance to move on by consuming a small
part of memory reserves. We are using ALLOC_HARDER which should be
enough to prevent from the starvation by regular allocation requests,
yet it shouldn't consume enough from the reserves to disrupt high
priority requests (ALLOC_HIGH).

While we are at it, let's introduce a helper __alloc_pages_cpuset_fallback
which enforces the cpusets but allows to fallback to ignore them if
the first attempt fails. __GFP_NOFAIL requests can be considered
important enough to allow cpuset runaway in order for the system to move
on. It is highly unlikely that any of these will be GFP_USER anyway.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 46 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 36 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2dda7c3eba52..e8e551015d48 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3064,6 +3064,26 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 }
 
 static inline struct page *
+__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
+			      unsigned int alloc_flags,
+			      const struct alloc_context *ac)
+{
+	struct page *page;
+
+	page = get_page_from_freelist(gfp_mask, order,
+			alloc_flags|ALLOC_CPUSET, ac);
+	/*
+	 * fallback to ignore cpuset restriction if our nodes
+	 * are depleted
+	 */
+	if (!page)
+		page = get_page_from_freelist(gfp_mask, order,
+				alloc_flags, ac);
+
+	return page;
+}
+
+static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
@@ -3127,17 +3147,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
 
-		if (gfp_mask & __GFP_NOFAIL) {
-			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-			/*
-			 * fallback to ignore cpuset restriction if our nodes
-			 * are depleted
-			 */
-			if (!page)
-				page = get_page_from_freelist(gfp_mask, order,
+		/*
+		 * Help non-failing allocations by giving them access to memory
+		 * reserves
+		 */
+		if (gfp_mask & __GFP_NOFAIL)
+			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
 					ALLOC_NO_WATERMARKS, ac);
-		}
 	}
 out:
 	mutex_unlock(&oom_lock);
@@ -3743,6 +3759,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
 
+		/*
+		 * Help non-failing allocations by giving them access to memory
+		 * reserves but do not use ALLOC_NO_WATERMARKS because this
+		 * could deplete whole memory reserves which would just make
+		 * the situation worse
+		 */
+		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
+		if (page)
+			goto got_pg;
+
 		cond_resched();
 		goto retry;
 	}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
