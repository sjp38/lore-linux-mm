Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 00B2D6B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 09:22:53 -0500 (EST)
Received: by pdjz10 with SMTP id z10so14263052pdj.12
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 06:22:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ki7si7634518pbc.210.2015.02.21.06.22.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Feb 2015 06:22:52 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150219225217.GY12722@dastard>
	<201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
	<20150220231511.GH12722@dastard>
	<20150221032000.GC7922@thunk.org>
	<20150221011907.2d26c979.akpm@linux-foundation.org>
In-Reply-To: <20150221011907.2d26c979.akpm@linux-foundation.org>
Message-Id: <201502212248.DCJ69753.MOJFOtQLFSOVFH@I-love.SAKURA.ne.jp>
Date: Sat, 21 Feb 2015 22:48:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org

Andrew Morton wrote:
> On Fri, 20 Feb 2015 22:20:00 -0500 "Theodore Ts'o" <tytso@mit.edu> wrote:
> 
> > +akpm
> 
> I was hoping not to have to read this thread ;)

Sorry for getting so complicated.

> What I'm not really understanding is why the pre-3.19 implementation
> actually worked.  We've exhausted the free pages, we're not succeeding
> at reclaiming anything, we aren't able to oom-kill anyone.  Yet it
> *does* work - we eventually find that memory and everything proceeds.
> 
> How come?  Where did that memory come from?
> 

Even without __GFP_NOFAIL, GFP_NOFS / GFP_NOIO allocations retried forever
(without invoking the OOM killer) if order <= PAGE_ALLOC_COSTLY_ORDER and
TIF_MEMDIE is not set. Somebody else volunteered that memory while retrying.
This implies silent hang-up forever if nobody volunteers memory.

> And yes, I agree that sites such as xfs's kmem_alloc() should be
> passing __GFP_NOFAIL to tell the page allocator what's going on.  I
> don't think it matters a lot whether kmem_alloc() retains its retry
> loop.  If __GFP_NOFAIL is working correctly then it will never loop
> anyway...

Commit 9879de7373fc ("mm: page_alloc: embed OOM killing naturally into
allocation slowpath") inadvertently changed GFP_NOFS / GFP_NOIO allocations
not to retry unless __GFP_NOFAIL is specified. Therefore, either applying
Johannes's akpm-doesnt-know-why-it-works patch or passing __GFP_NOFAIL
will restore the pre-3.19 behavior (with possibility of silent hang-up).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
