Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1AE6B0075
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 10:17:56 -0500 (EST)
Received: by yhl29 with SMTP id 29so10767420yhl.0
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 07:17:55 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id c129si3448064ykd.78.2015.02.28.07.17.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 07:17:54 -0800 (PST)
Date: Sat, 28 Feb 2015 10:17:48 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150228151748.GD5404@thunk.org>
References: <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F0B662.8020508@suse.cz>
 <20150228000359.GL4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150228000359.GL4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sat, Feb 28, 2015 at 11:03:59AM +1100, Dave Chinner wrote:
> > I think the best way is if slab could also learn to provide reserves for
> > individual objects. Either just mark internally how many of them are reserved,
> > if sufficient number is free, or translate this to the page allocator reserves,
> > as slab knows which order it uses for the given objects.
> 
> Which is effectively what a slab based mempool is. Mempools don't
> guarantee a reserve is available once it's been resized, however,
> and we'd have to have mempools configured for every type of
> allocation we are going to do. So from that perspective it's not
> really a solution.

The bigger problem is it means that the upper layer which is making
the reservation before it starts taking lock won't necessarily know
exactly which slab objects it and all of the lower layers might need.

So it's much more flexible, and requires less accuracy, if we can just
request that (a) the mm subsystems reserves at least N pages, and (b)
tell it that at this point in time, it's safe for the requesting
subsystem to block until N pages is available.

Can this be guaranteed to be accurate?  No, of course not.  And in
some cases, it may be possible since it might depend on whether the
iSCSI device needs to reconnect to the target, or some sort of
exception handling, before it can complete its I/O request.

But it's better than what we have now, which is that once we've taken
certain locks, and/or started a complex transaction, we can't really
back out, so we end up looping either using GFP_NOFAIL, or around the
memory allocation request if there are still mm developers who are
delusional enough to believe, ala like King Canute, to say, "You must
always be able to handle memory allocation at any point in the kernel
and GFP_NOFAIL is an indicatoin of a subsystem bug!"

I can imagine using some adjustment factors, where a particular
voratious device might require hint to the file system to boost its
memory allocation estimate by 30%, or 50%.  So yes, it's a very,
*very* rough estimate.  And if we guess wrong, we might end up having
to loop ala GFP_NOFAIL anyway.  But it's better than not having such
an estimate.

I also grant that this doesn't work very well for emergency writeback,
or background writeback, where we can't and shouldn't block waiting
for enough memory to become free, since page cleaning is one of the
ways that we might be able to make memory available.  But if that's
the only problem we have, we're in good shape, since that can be
solved by either (a) doing a better job throttling memory allocations
or memory reservation requests in the first place, and/or (b) starting
the background writeback much more aggressively and earlier.

    	       		      	   		- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
