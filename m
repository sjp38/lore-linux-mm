Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE256B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:49:25 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so26451974pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 06:49:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id os8si3775239pbc.251.2015.08.27.06.49.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 06:49:24 -0700 (PDT)
Subject: Re: [REPOST] [PATCH 1/2] mm: Fix race between setting TIF_MEMDIE and __alloc_pages_high_priority().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508231621.EGJ17658.FFQJtFSLVOOHMO@I-love.SAKURA.ne.jp>
	<20150824100319.GG17078@dhcp22.suse.cz>
	<201508242152.HHB69241.OFJLFVtFHQOMSO@I-love.SAKURA.ne.jp>
	<20150824132006.GN17078@dhcp22.suse.cz>
In-Reply-To: <20150824132006.GN17078@dhcp22.suse.cz>
Message-Id: <201508272249.HDH81838.FtQOLMFFOVSJOH@I-love.SAKURA.ne.jp>
Date: Thu, 27 Aug 2015 22:49:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Michal Hocko wrote:
> The TIF_MEMDIE check was explicit for a good reason IMO. The race is not
> really that important AFAICS because we would only fail the allocation
> sooner for the OOM victim and that one might fail already. I might be
> missing something of course but your change has a higher risk of
> undesired behavior than the original code.

In a different thread, you are trying to allow giving up !__GFP_FS
allocations without retrying because giving up __GFP_FS allocations
without retrying increases possibility of hitting obsucure bugs in the
error recovery paths. This TIF_MEMDIE v.s. __alloc_pages_high_priority()
race condition allows giving up not only !__GFP_FS allocations but also
__GFP_FS allocations; i.e. fixing this race reduces possibility of
hitting obsucure bugs.

Thus, here is an updated patch.
------------------------------------------------------------
>From 5300fa1b78130113189e72a0a09e9a49090b5f1e Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 27 Aug 2015 22:30:13 +0900
Subject: [PATCH] mm: Fix race between setting TIF_MEMDIE and __alloc_pages_high_priority().

Currently, TIF_MEMDIE is checked at gfp_to_alloc_flags() which is before
calling __alloc_pages_high_priority() and at

  /* Avoid allocations with no watermarks from looping endlessly */
  if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))

which is after returning from __alloc_pages_high_priority(). This means
that if TIF_MEMDIE is set between returning from gfp_to_alloc_flags() and
checking test_thread_flag(TIF_MEMDIE), the allocation will fail without
calling __alloc_pages_high_priority().

For now, we need to try to avoid failing small __GFP_FS allocations
because many of error recovery paths are untested, resulting in obscure
bugs. This patch replaces "test_thread_flag(TIF_MEMDIE)" with "whether
TIF_MEMDIE was already set as of calling gfp_to_alloc_flags()" in order
to try to avoid such failures.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ff998c..8880b17 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3012,6 +3012,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	bool memdie_pending;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3036,6 +3037,7 @@ retry:
 	if (!(gfp_mask & __GFP_NO_KSWAPD))
 		wake_all_kswapds(order, ac);
 
+	memdie_pending = test_thread_flag(TIF_MEMDIE);
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background
 	 * reclaim. Now things get more complex, so set up alloc_flags according
@@ -3091,8 +3093,13 @@ retry:
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
 
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+	/*
+	 * Give up if chosen as an OOM victim. But if the context allows,
+	 * make sure that __alloc_pages_high_priority() was called before
+	 * giving up, for failing small __GFP_FS allocations are prone to
+	 * trigger obscure bugs.
+	 */
+	if (memdie_pending && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
 	/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
