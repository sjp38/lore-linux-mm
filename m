Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A7FBA6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 03:21:54 -0400 (EDT)
Received: by pawq9 with SMTP id q9so81798857paw.3
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 00:21:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b6si21499565pdp.20.2015.08.23.00.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Aug 2015 00:21:53 -0700 (PDT)
Subject: [REPOST] [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and __alloc_pages_high_priority().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Aug 2015 16:21:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org

>From 4a3cf5be07a66cf3906a380e77ba5e2ac1b2b3d5 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 1 Aug 2015 22:39:30 +0900
Subject: [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and
 __alloc_pages_high_priority().

Currently, TIF_MEMDIE is checked at gfp_to_alloc_flags() which is before
calling __alloc_pages_high_priority() and at

  /* Avoid allocations with no watermarks from looping endlessly */
  if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))

which is after returning from __alloc_pages_high_priority(). This means
that if TIF_MEMDIE is set between returning from gfp_to_alloc_flags() and
checking test_thread_flag(TIF_MEMDIE), the allocation can fail without
calling __alloc_pages_high_priority(). We need to replace
"test_thread_flag(TIF_MEMDIE)" with "whether TIF_MEMDIE was already set
as of calling gfp_to_alloc_flags()" in order to close this race window.

Since gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS for several cases,
it will be more correct to replace "test_thread_flag(TIF_MEMDIE)" with
"whether gfp_to_alloc_flags() included ALLOC_NO_WATERMARKS" because the
purpose of test_thread_flag(TIF_MEMDIE) is to give up immediately if
__alloc_pages_high_priority() failed.

Note that we could simply do

  if (alloc_flags & ALLOC_NO_WATERMARKS) {
    ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
    page = __alloc_pages_high_priority(gfp_mask, order, ac);
    if (page)
      goto got_pg;
    WARN_ON_ONCE(!wait && (gfp_mask & __GFP_NOFAIL));
    goto nopage;
  }

instead of changing to

  if ((alloc_flags & ALLOC_NO_WATERMARKS) && !(gfp_mask & __GFP_NOFAIL))
    goto nopage;

if we can duplicate

  if (!wait) {
    WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
    goto nopage;
  }

.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4b220cb..37a0390 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3085,7 +3085,7 @@ retry:
 		goto nopage;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	if ((alloc_flags & ALLOC_NO_WATERMARKS) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
