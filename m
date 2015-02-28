Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C0BC16B007B
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 11:30:06 -0500 (EST)
Received: by wggy19 with SMTP id y19so25705074wgg.13
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 08:30:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gb4si9404737wic.120.2015.02.28.08.30.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Feb 2015 08:30:04 -0800 (PST)
Date: Sat, 28 Feb 2015 11:29:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150228162943.GA17989@phnom.home.cmpxchg.org>
References: <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150223004521.GK12722@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Mon, Feb 23, 2015 at 11:45:21AM +1100, Dave Chinner wrote:
> On Sat, Feb 21, 2015 at 06:52:27PM -0500, Johannes Weiner wrote:
> > On Fri, Feb 20, 2015 at 09:52:17AM +1100, Dave Chinner wrote:
> > > I will actively work around aanything that causes filesystem memory
> > > pressure to increase the chance of oom killer invocations. The OOM
> > > killer is not a solution - it is, by definition, a loose cannon and
> > > so we should be reducing dependencies on it.
> > 
> > Once we have a better-working alternative, sure.
> 
> Great, but first a simple request: please stop writing code and
> instead start architecting a solution to the problem. i.e. we need a
> design and have that documented before code gets written. If you
> watched my recent LCA talk, then you'll understand what I mean
> when I say: stop programming and start engineering.

This code was for the sake of argument, see below.

> > > I really don't care about the OOM Killer corner cases - it's
> > > completely the wrong way line of development to be spending time on
> > > and you aren't going to convince me otherwise. The OOM killer a
> > > crutch used to justify having a memory allocation subsystem that
> > > can't provide forward progress guarantee mechanisms to callers that
> > > need it.
> > 
> > We can provide this.  Are all these callers able to preallocate?
> 
> Anything that allocates in transaction context (and therefor is
> GFP_NOFS by definition) can preallocate at transaction reservation
> time. However, preallocation is dumb, complex, CPU and memory
> intensive and will have a *massive* impact on performance.
> Allocating 10-100 pages to a reserve which we will almost *never
> use* and then free them again *on every single transaction* is a lot
> of unnecessary additional fast path overhead.  Hence a "preallocate
> for every context" reserve pool is not a viable solution.

You are missing the point of my question.  Whether we allocate right
away or make sure the memory is allocatable later on is a matter of
cost, but the logical outcome is the same.  That is not my concern
right now.

An OOM killer allows transactional allocation sites to get away
without planning ahead.  You are arguing that the OOM killer is a
cop-out on the MM site but I see it as the opposite: it puts a lot of
complexity in the allocator so that callsites can maneuver themselves
into situations where they absolutely need to get memory - or corrupt
user data - without actually making sure their needs will be covered.

If we replace __GFP_NOFAIL + OOM killer with a reserve system, we are
putting the full responsibility on the user.  Are you sure this is
going to reduce our kernel-wide error rate?

> And, really, "reservation" != "preallocation".

That's an implementation detail.  Yes, the example implementation was
dumb and heavy-handed, but a reservation system that works based on
watermarks, and considers clean cache readily allocatable, is not much
more complex than that.

I'm trying to figure out if the current nofail allocators can get
their memory needs figured out beforehand.  And reliably so - what
good are estimates that are right 90% of the time, when failing the
allocation means corrupting user data?  What is the contingency plan?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
