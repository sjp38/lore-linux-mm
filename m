Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id BAAFE6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 04:55:38 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so44333195igc.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:55:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s13si40395375pdi.27.2015.09.03.01.55.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Sep 2015 01:55:38 -0700 (PDT)
Subject: Re: [REPOST] [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC allocations.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201508231623.DED13020.tFOHFVFQOSOLMJ@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509011519170.11913@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1509011519170.11913@chino.kir.corp.google.com>
Message-Id: <201509031755.GGJ39045.JOFLOHOQtMVFSF@I-love.SAKURA.ne.jp>
Date: Thu, 3 Sep 2015 17:55:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

David Rientjes wrote:
> On Sun, 23 Aug 2015, Tetsuo Handa wrote:
> 
> > >From 08a638e04351386ab03cd1223988ac7940d4d3aa Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Sat, 1 Aug 2015 22:46:12 +0900
> > Subject: [PATCH 2/2] mm: Fix potentially scheduling in GFP_ATOMIC
> >  allocations.
> > 
> > Currently, if somebody does GFP_ATOMIC | __GFP_NOFAIL allocation,
> > wait_iff_congested() might be called via __alloc_pages_high_priority()
> > before reaching
> > 
> >   if (!wait) {
> >     WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
> >     goto nopage;
> >   }
> > 
> > because gfp_to_alloc_flags() includes ALLOC_NO_WATERMARKS if TIF_MEMDIE
> > was set.
> > 
> > We need to check for __GFP_WAIT flag at __alloc_pages_high_priority()
> > in order to make sure that we won't schedule.
> > 
> 
> I've brought the GFP_ATOMIC | __GFP_NOFAIL combination up before, which 
> resulted in the WARN_ON_ONCE() that you cited.  We don't support such a 
> combination.  Fixing up the documentation in any places you feel it is 
> deficient would be the best.
> 
The purpose of this check is to warn about unassured combination, isn't it?
Then, I think this check should be done like

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b5240b..7358225 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3046,15 +3046,8 @@ retry:
 	}
 
 	/* Atomic allocations - we can't balance anything */
-	if (!wait) {
-		/*
-		 * All existing users of the deprecated __GFP_NOFAIL are
-		 * blockable, so warn of any new users that actually allow this
-		 * type of allocation to fail.
-		 */
-		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+	if (!wait)
 		goto nopage;
-	}
 
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
@@ -3183,6 +3176,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	lockdep_trace_alloc(gfp_mask);
 
+	/*
+	 * All existing users of the __GFP_NOFAIL have __GFP_WAIT.
+	 * __GFP_NOFAIL allocations without __GFP_WAIT is unassured.
+	 */
+	WARN_ON_ONCE((gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) == __GFP_NOFAIL);
+
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
 	if (should_fail_alloc_page(gfp_mask, order))
----------

because such allocation requests can succeed at fast path or at

  /* This is the last chance, in general, before the goto nopage. */

. If unconditional WARN_ON_ONCE() is too wasteful, maybe we can do like

  #ifdef CONFIG_DEBUG_SOMETHING
    WARN_ON_ONCE((gfp_mask & (__GFP_NOFAIL | __GFP_WAIT)) == __GFP_NOFAIL);
  #endif

.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
