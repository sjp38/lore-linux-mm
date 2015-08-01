Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5157C6B0254
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 09:53:14 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so57026549pac.3
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 06:53:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t3si16886553pdf.232.2015.08.01.06.53.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 01 Aug 2015 06:53:13 -0700 (PDT)
Received: from fsav206.sakura.ne.jp (fsav206.sakura.ne.jp [210.224.168.168])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t71DrAZC065658
	for <linux-mm@kvack.org>; Sat, 1 Aug 2015 22:53:10 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126074231104.bbtec.net [126.74.231.104])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t71DrAAf065655
	for <linux-mm@kvack.org>; Sat, 1 Aug 2015 22:53:10 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 2/2] mm: Fix potentically scheduling in GFP_ATOMIC allocations.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201508012253.JFI12317.SVtFHFFJOMQLOO@I-love.SAKURA.ne.jp>
Date: Sat, 1 Aug 2015 22:53:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 08a638e04351386ab03cd1223988ac7940d4d3aa Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 1 Aug 2015 22:46:12 +0900
Subject: [PATCH 2/2] mm: Fix potentically scheduling in GFP_ATOMIC
 allocations.

Currently, if somebody does GFP_ATOMIC | __GFP_NOFAIL allocation,
wait_iff_congested() might be called via __alloc_pages_high_priority()
before reaching

  if (!wait) {
    WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
    goto nopage;
  }

because gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS if TIF_MEMDIE
was set.

We need to check for __GFP_WAIT flag at __alloc_pages_high_priority()
in order to make sure that we won't schedule.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 37a0390..f9f09fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2917,16 +2917,15 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
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
