Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3C72E900015
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 07:58:48 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so8937391wid.5
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 04:58:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si40706691wiz.75.2015.02.19.04.58.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 04:58:46 -0800 (PST)
Date: Thu, 19 Feb 2015 13:58:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150219125844.GI28427@dhcp22.suse.cz>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150219110124.GC15569@phnom.home.cmpxchg.org>
 <20150219122914.GH28427@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150219122914.GH28427@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Thu 19-02-15 13:29:14, Michal Hocko wrote:
[...]
> Something like the following.
__GFP_HIGH doesn't seem to be sufficient so we would need something
slightly else but the idea is still the same:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d52ab18fe0d..2d224bbdf8e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2599,6 +2599,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	int oom = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2635,6 +2636,15 @@ retry:
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
 	/*
+	 * __GFP_NOFAIL allocations cannot fail but yet the current context
+	 * might be blocking resources needed by the OOM victim to terminate.
+	 * Allow the caller to dive into memory reserves to succeed the
+	 * allocation and break out from a potential deadlock.
+	 */
+	if (oom > 10 && (gfp_mask & __GFP_NOFAIL))
+		alloc_flags |= ALLOC_NO_WATERMARKS;
+
+	/*
 	 * Find the true preferred zone if the allocation is unconstrained by
 	 * cpusets.
 	 */
@@ -2759,6 +2769,8 @@ retry:
 				goto got_pg;
 			if (!did_some_progress)
 				goto nopage;
+
+			oom++;
 		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
