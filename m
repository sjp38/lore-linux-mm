Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFC66B006C
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 08:37:07 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so60285077pad.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 05:37:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pr9si25901746pbc.12.2015.06.02.05.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 05:37:06 -0700 (PDT)
Received: from fsav305.sakura.ne.jp (fsav305.sakura.ne.jp [153.120.85.136])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t52Cb34e046323
	for <linux-mm@kvack.org>; Tue, 2 Jun 2015 21:37:03 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126227184186.bbtec.net [126.227.184.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t52Cb3Nd046320
	for <linux-mm@kvack.org>; Tue, 2 Jun 2015 21:37:03 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH] mm: Fix theoretical sleeping in atomic.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201506022137.FEE05202.FSHtJOVFQFOLOM@I-love.SAKURA.ne.jp>
Date: Tue, 2 Jun 2015 21:37:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 7e4775600798d24680ff449412f2d0479711948c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 2 Jun 2015 21:14:28 +0900
Subject: [PATCH] mm: Fix theoretical sleeping in atomic.

We could theoretically be too late to warn on

  (gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) == __GFP_NOFAIL

if get_page_from_freelist(ALLOC_NO_WATERMARKS) failed at
__alloc_pages_high_priority(), for wait_iff_congested() in
__alloc_pages_high_priority() might have already slept for
kmalloc(GFP_ATOMIC | __GFP_NOFAIL) allocation request because
ALLOC_NO_WATERMARKS can be automatically supplied due to
e.g. TIF_MEMDIE.

Make sure that __alloc_pages_high_priority() will not loop
unless both __GFP_NOFAIL and __GFP_WAIT are given.

Maybe

  if (!wait)
      WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);

part should be moved to immediately after

  if (order >= MAX_ORDER) {
      WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
      return NULL;
  }

?

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 73aa335..187a0b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2880,16 +2880,15 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	do {
+	for (;;) {
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 
-		if (!page && gfp_mask & __GFP_NOFAIL)
-			wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC,
-									HZ/50);
-	} while (!page && (gfp_mask & __GFP_NOFAIL));
-
-	return page;
+		if (page || (gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) !=
+		    (__GFP_NOFAIL | __GFP_WAIT))
+			return page;
+		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+	}
 }
 
 static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
