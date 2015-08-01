Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 277756B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 09:52:18 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so57226404pab.2
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 06:52:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ek3si3415743pbd.51.2015.08.01.06.52.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 01 Aug 2015 06:52:16 -0700 (PDT)
Received: from fsav309.sakura.ne.jp (fsav309.sakura.ne.jp [153.120.85.140])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t71DqE0G065396
	for <linux-mm@kvack.org>; Sat, 1 Aug 2015 22:52:14 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126074231104.bbtec.net [126.74.231.104])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t71DqD7N065393
	for <linux-mm@kvack.org>; Sat, 1 Aug 2015 22:52:13 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and __alloc_pages_high_priority().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508012252.DHI57365.HOFOVSQMFOFtJL@I-love.SAKURA.ne.jp>
Date: Sat, 1 Aug 2015 22:52:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

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
