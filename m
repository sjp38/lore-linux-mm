Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66D686B0388
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 18:58:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so79535836pgi.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:58:10 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id k20si11623161pfa.244.2017.02.17.15.58.08
        for <linux-mm@kvack.org>;
        Fri, 17 Feb 2017 15:58:09 -0800 (PST)
Date: Sat, 18 Feb 2017 10:58:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170217235806.GF15349@dastard>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
 <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
 <20170215160538.GA62565@bfoster.bfoster>
 <a055abbf-a471-d111-9491-dc5b00208228@beget.ru>
 <20170215180859.GB62565@bfoster.bfoster>
 <07ee50bc-8220-dda8-07f9-369758603df9@beget.ru>
 <20170216172034.GC11750@bfoster.bfoster>
 <20170216222129.GB15349@dastard>
 <077aa22b-7d84-c1cc-3ae6-1d67f762d291@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <077aa22b-7d84-c1cc-3ae6-1d67f762d291@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Brian Foster <bfoster@redhat.com>, Alexander Polakov <apolyakov@beget.ru>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Feb 17, 2017 at 08:11:09PM +0900, Tetsuo Handa wrote:
> On 2017/02/17 7:21, Dave Chinner wrote:
> > FWIW, the major problem with removing the blocking in inode reclaim
> > is the ease with which you can then trigger the OOM killer from
> > userspace.  The high level memory reclaim algorithms break down when
> > there are hundreds of direct reclaim processes hammering on reclaim
> > and reclaim stops making progress because it's skipping dirty
> > objects.  Direct reclaim ends up insufficiently throttled, so rather
> > than blocking it winds up reclaim priority and then declares OOM
> > because reclaim runs out of retries before sufficient memory has
> > been freed.
> > 
> > That, right now, looks to be an unsolvable problem without a major
> > rework of direct reclaim.  I've pretty much given up on ever getting
> > the unbound direct reclaim concurrency problem that is causing us
> > these problems fixed, so we are left to handle it in the subsystem
> > shrinkers as best we can. That leaves us with an unfortunate choice: 
> > 
> > 	a) throttle excessive concurrency in the shrinker to prevent
> > 	   IO breakdown, thereby causing reclaim latency bubbles
> > 	   under load but having a stable, reliable system; or
> > 	b) optimise for minimal reclaim latency and risk userspace
> > 	   memory demand triggering the OOM killer whenever there
> > 	   are lots of dirty inodes in the system.
> > 
> > Quite frankly, there's only one choice we can make in this
> > situation: reliability is always more important than performance.
> 
> Is it possible to get rid of direct reclaim and let allocating thread
> wait on queue? I wished such change in context of __GFP_KILLABLE at
> http://lkml.kernel.org/r/201702012049.BAG95379.VJFFOHMStLQFOO@I-love.SAKURA.ne.jp .

Yup, that's similar to what I've been suggesting - offloading the
direct reclaim slowpath to a limited set of kswapd-like workers
and blocking the allocating processes until there is either memory
for them or OOM is declared...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
