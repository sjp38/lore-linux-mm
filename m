Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9BADE6B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 04:19:49 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so13264111pdb.2
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 01:19:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sk2si2390966pac.156.2015.02.21.01.19.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Feb 2015 01:19:48 -0800 (PST)
Date: Sat, 21 Feb 2015 01:19:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-Id: <20150221011907.2d26c979.akpm@linux-foundation.org>
In-Reply-To: <20150221032000.GC7922@thunk.org>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
	<20150217125315.GA14287@phnom.home.cmpxchg.org>
	<20150217225430.GJ4251@dastard>
	<20150219102431.GA15569@phnom.home.cmpxchg.org>
	<20150219225217.GY12722@dastard>
	<201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
	<20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

On Fri, 20 Feb 2015 22:20:00 -0500 "Theodore Ts'o" <tytso@mit.edu> wrote:

> +akpm

I was hoping not to have to read this thread ;)

afaict there are two (main) issues:

a) whether to oom-kill when __GFP_FS is not set.  The kernel hasn't
   been doing this for ages and nothing has changed recently.

b) whether to keep looping when __GFP_NOFAIL is not set and __GFP_FS
   is not set and we can't oom-kill anything (which goes without
   saying, because __GFP_FS isn't set!).

   And 9879de7373fc ("mm: page_alloc: embed OOM killing naturally
   into allocation slowpath") somewhat inadvertently changed this policy
   - the allocation attempt will now promptly return ENOMEM if
   !__GFP_NOFAIL and !__GFP_FS.

Correct enough?

Question a) seems a bit of red herring and we can park it for now.


What I'm not really understanding is why the pre-3.19 implementation
actually worked.  We've exhausted the free pages, we're not succeeding
at reclaiming anything, we aren't able to oom-kill anyone.  Yet it
*does* work - we eventually find that memory and everything proceeds.

How come?  Where did that memory come from?


Short term, we need to fix 3.19.x and 3.20 and that appears to be by
applying Johannes's akpm-doesnt-know-why-it-works patch:

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (high_zoneidx < ZONE_NORMAL)
 			goto out;
 		/* The OOM killer does not compensate for light reclaim */
-		if (!(gfp_mask & __GFP_FS))
+		if (!(gfp_mask & __GFP_FS)) {
+			/*
+			 * XXX: Page reclaim didn't yield anything,
+			 * and the OOM killer can't be invoked, but
+			 * keep looping as per should_alloc_retry().
+			 */
+			*did_some_progress = 1;
 			goto out;
+		}
 		/*
 		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
 		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

Have people adequately confirmed that this gets us out of trouble?


And yes, I agree that sites such as xfs's kmem_alloc() should be
passing __GFP_NOFAIL to tell the page allocator what's going on.  I
don't think it matters a lot whether kmem_alloc() retains its retry
loop.  If __GFP_NOFAIL is working correctly then it will never loop
anyway...


Also, this:

On Wed, 18 Feb 2015 09:54:30 +1100 Dave Chinner <david@fromorbit.com> wrote:

> Right now, the oom killer is a liability. Over the past 6 months
> I've slowly had to exclude filesystem regression tests from running
> on small memory machines because the OOM killer is now so unreliable
> that it kills the test harness regularly rather than the process
> generating memory pressure.

David, I did not know this!  If you've been telling us about this then
perhaps it wasn't loud enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
