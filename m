Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9936F6B0327
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 07:51:24 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so113422485ito.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 04:51:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w140si3140371itc.124.2016.11.17.04.51.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 04:51:23 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL allocations.
Date: Thu, 17 Nov 2016 21:50:04 +0900
Message-Id: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org

Filesystem code might request costly __GFP_NOFAIL !__GFP_REPEAT GFP_NOFS
allocations. But commit 0a0337e0d1d13446 ("mm, oom: rework oom detection")
overlooked that __GFP_NOFAIL allocation requests need to invoke the OOM
killer and retry even if order > PAGE_ALLOC_COSTLY_ORDER && !__GFP_REPEAT.
The caller will crash if such allocation request failed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org> # 4.7+
---
 mm/page_alloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..b458f00 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3650,9 +3650,10 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/*
 	 * Do not retry costly high order allocations unless they are
-	 * __GFP_REPEAT
+	 * __GFP_REPEAT or __GFP_NOFAIL
 	 */
-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
+	if (order > PAGE_ALLOC_COSTLY_ORDER &&
+	    !(gfp_mask & (__GFP_REPEAT | __GFP_NOFAIL)))
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
