Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 99C6F6B007B
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:52:52 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so7805884pdb.32
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:52:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ez4si15833554pbb.37.2014.11.22.20.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:52:51 -0800 (PST)
Received: from fsav304.sakura.ne.jp (fsav304.sakura.ne.jp [153.120.85.135])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4qm63081301
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:52:48 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4qlfb081298
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:52:47 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 4/5] mm: Drop __GFP_WAIT flag when allocating from shrinker functions.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Message-Id: <201411231352.IFC13048.LOOJQMFtFVSHFO@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:52:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From b248c31988ea582d2d4f4093fb8b649be91174bb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:40:47 +0900
Subject: [PATCH 4/5] mm: Drop __GFP_WAIT flag when allocating from shrinker functions.

Memory allocations from shrinker functions are complicated.
If unexpected flags are stored in "struct shrink_control"->gfp_mask and
used inside shrinker functions, it can cause difficult-to-trigger bugs
like https://bugzilla.kernel.org/show_bug.cgi?id=87891 .

Also, stack usage by __alloc_pages_nodemask() is large. If we unlimitedly
allow recursive __alloc_pages_nodemask() calls, kernel stack could overflow
under extreme memory pressure.

Some shrinker functions are using sleepable locks which could make kswapd
sleep for unpredictable duration. If kswapd is unexpectedly blocked inside
shrinker functions and somebody is expecting that kswapd is running for
reclaiming memory (e.g.

  while (unlikely(too_many_isolated(zone, file, sc))) {
          congestion_wait(BLK_RW_ASYNC, HZ/10);

          /* We are about to die and free our memory. Return now. */
          if (fatal_signal_pending(current))
                  return SWAP_CLUSTER_MAX;
  }

in shrink_inactive_list()), it is a memory allocation deadlock.

This patch drops __GFP_WAIT flag when allocating from shrinker functions
so that recursive __alloc_pages_nodemask() calls will not cause troubles
like recursive locks and/or unpredictable sleep. The comments in this patch
suggest shrinker functions users to try to avoid use of sleepable locks
and memory allocations from shrinker functions, as with TTM driver's
shrinker functions.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11cc37d..c77418e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2801,6 +2801,41 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		 */
 		current->gfp_start = jiffies;
 		current->gfp_flags = gfp_mask;
+	} else {
+		/*
+		 * When this function is called from interrupt context,
+		 * the caller must not include __GFP_WAIT flag.
+		 *
+		 * When this function is called by recursive
+		 * __alloc_pages_nodemask() calls from shrinker functions,
+		 * the context might allow __GFP_WAIT flag. But since this
+		 * function consumes a lot of kernel stack, kernel stack
+		 * could overflow under extreme memory pressure if we
+		 * unlimitedly allow recursive __alloc_pages_nodemask() calls.
+		 * Also, if kswapd is unexpectedly blocked for unpredictable
+		 * duration inside shrinker functions, and somebody is
+		 * expecting that kswapd is running for reclaiming memory,
+		 * it is a memory allocation deadlock.
+		 *
+		 * If current->gfp_flags != 0 here, it means that this function
+		 * is called from either interrupt context or shrinker
+		 * functions. Thus, it should be safe to drop __GFP_WAIT flag.
+		 *
+		 * Moreover, we don't need to check for current->gfp_flags != 0
+		 * here because omit_timestamp == true is equivalent to
+		 * (gfp_mask & __GFP_WAIT) == 0 and/or current->gfp_flags != 0.
+		 * Dropping __GFP_WAIT flag when (gfp_mask & __GFP_WAIT) == 0
+		 * is a no-op.
+		 *
+		 * By dropping __GFP_WAIT flag, kswapd will no longer blocked
+		 * by recursive __alloc_pages_nodemask() calls from shrinker
+		 * functions. Note that kswapd could still be blocked for
+		 * unpredictable duration if sleepable locks are used inside
+		 * shrinker functions. Therefore, please try to avoid use of
+		 * sleepable locks and memory allocations from shrinker
+		 * functions.
+		 */
+		gfp_mask &= ~__GFP_WAIT;
 	}
 
 	gfp_mask &= gfp_allowed_mask;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
