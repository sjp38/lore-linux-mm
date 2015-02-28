Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8496B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:04:05 -0500 (EST)
Received: by pdbft15 with SMTP id ft15so2275697pdb.11
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:04:04 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id fn1si5638243pbb.194.2015.02.27.16.04.02
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 16:04:03 -0800 (PST)
Date: Sat, 28 Feb 2015 11:03:59 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150228000359.GL4251@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F0B662.8020508@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F0B662.8020508@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Fri, Feb 27, 2015 at 07:24:34PM +0100, Vlastimil Babka wrote:
> On 02/23/2015 08:32 AM, Dave Chinner wrote:
> >> > And then there will be an unknown number of
> >> > slab allocations of unknown size with unknown slabs-per-page rules
> >> > - how many pages needed for them?
> > However many pages needed to allocate the number of objects we'll
> > consume from the slab.
> 
> I think the best way is if slab could also learn to provide reserves for
> individual objects. Either just mark internally how many of them are reserved,
> if sufficient number is free, or translate this to the page allocator reserves,
> as slab knows which order it uses for the given objects.

Which is effectively what a slab based mempool is. Mempools don't
guarantee a reserve is available once it's been resized, however,
and we'd have to have mempools configured for every type of
allocation we are going to do. So from that perspective it's not
really a solution.

Further, the kmalloc heap is backed by slab caches. We do *lots* of
variable sized kmalloc allocations in transactions the size of which
aren't known until allocation time.  In that case, we have to assume
it's going to be a page per object, because the allocations could
actually be that size.

AFAICT, the worst case is a slab-backing page allocation for
every slab object that is allocated, so we may as well cater for
that case from the start...

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
