Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 859F16B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:22:47 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so37612129pdb.3
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:22:47 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id k16si6899980pbq.81.2015.03.04.15.22.44
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 15:22:46 -0800 (PST)
Date: Thu, 5 Mar 2015 10:17:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304231740.GA18360@dastard>
References: <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <20150302202228.GA15089@phnom.home.cmpxchg.org>
 <20150302231206.GK18360@dastard>
 <20150303025023.GA22453@phnom.home.cmpxchg.org>
 <20150304065242.GR18360@dastard>
 <20150304150436.GA16442@phnom.home.cmpxchg.org>
 <20150304173841.GB15669@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304173841.GB15669@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Mar 04, 2015 at 12:38:41PM -0500, Theodore Ts'o wrote:
> On Wed, Mar 04, 2015 at 10:04:36AM -0500, Johannes Weiner wrote:
> > Yes, we can make this work if you can tell us which allocations have
> > limited/controllable lifetime.
> 
> It may be helpful to be a bit precise about definitions here.  There
> are a number of different object lifetimes:
> 
> a) will be released before the kernel thread returns control to
> userspace
> 
> b) will be released once the current I/O operation finishes.  (In the
> case of nbd where the remote server has unexpectedy gone away might be
> quite a while, but I'm not sure how much we care about that scenario)
> 
> c) can be trivially released if the mm subsystem asks via calling a
> shrinker
> 
> d) can be released only after doing some amount of bounded work (i.e.,
> cleaning a dirty page)
> 
> e) impossible to predict when it can be released (e.g., dcache, inodes
> attached to an open file descriptors, buffer heads that won't be freed
> until the file system is umounted, etc.)
> 
> 
> I'm guessing that what you mean is (b), but what about cases such as
> (c)?

The thing is, in the XFS transaction case we are hitting e) for
every allocation, and only after IO and/or some processing do we
know whether it will fall into c), d) or whether it will be
permanently consumed.

> Would the mm subsystem find it helpful if it had more information
> about object lifetime?  For example, the CMA folks seem to really care
> about know whether memory allocations falls in category (e) or not.

The problem is that most filesystem allocations fall into category
(e). Worse is that the state of an object can change without
allocations having taken place e.g. an object on a reclaimable LRU
can be found via a cache lookup, then joined to and modified in a
transaction. Hence objects can change state from "reclaimable" to
"permanently consumed" without actually going through memory reclaim
and allocation.

IOWs, what is really required is the ability to say "this amount of
allocation reserve is now consumed" /some time after/ we've done the
allocation. i.e. when we join the object to the transaction and
modify it, that's when we need to be able to reduce the reservation
limit as that memory is now permanently consumed by the transaction
context. Objects that fall into c) and d) don't need to have anyting
special done, because reclaim will eventually free the memory they
hold once the allocating context releases them.

Indeed, this model works even when we find those c) and d) objects
in cache rather than allocating them. They would get correctly
accounted as "consumed reserve" because we no longer need to
allocate that memory in transaction context and so that reserve can
be released back to the free pool....

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
