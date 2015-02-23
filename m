Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B3C9D6B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 08:57:33 -0500 (EST)
Received: by paceu11 with SMTP id eu11so27695506pac.7
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 05:57:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id bz5si13804817pab.102.2015.02.23.05.57.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 05:57:32 -0800 (PST)
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
	<20150221011907.2d26c979.akpm@linux-foundation.org>
	<201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
	<20150223102147.GB24272@dhcp22.suse.cz>
In-Reply-To: <20150223102147.GB24272@dhcp22.suse.cz>
Message-Id: <201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
Date: Mon, 23 Feb 2015 22:03:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

Michal Hocko wrote:
> What about something like the following?

I'm fine with whatever approaches as long as retry is guaranteed.

But maybe we can use memory reserves like below? I think there will be
little risk because userspace processes are already frozen...

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a47f0b2..cea0a1b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2760,8 +2760,17 @@ retry:
 							&did_some_progress);
 			if (page)
 				goto got_pg;
-			if (!did_some_progress)
+			if (!did_some_progress && !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
+			/*
+			 * What!? __GFP_NOFAIL allocation failed to invoke
+			 * the OOM killer due to oom_killer_disabled == true?
+			 * Then, pretend ALLOC_NO_WATERMARKS request and let
+			 * __alloc_pages_high_priority() retry forever...
+			 */
+			WARN(1, "Retrying GFP_NOFAIL allocation...\n");
+			gfp_mask &= ~__GFP_NOMEMALLOC;
+			gfp_mask |= __GFP_MEMALLOC;
 		}
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
