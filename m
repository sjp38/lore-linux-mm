Message-ID: <450D5310.50004@yahoo.com.au>
Date: Sun, 17 Sep 2006 23:52:16 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>	<20060914220011.2be9100a.akpm@osdl.org>	<20060914234926.9b58fd77.pj@sgi.com>	<20060915002325.bffe27d1.akpm@osdl.org>	<20060915012810.81d9b0e3.akpm@osdl.org>	<20060915203816.fd260a0b.pj@sgi.com>	<20060915214822.1c15c2cb.akpm@osdl.org>	<20060916043036.72d47c90.pj@sgi.com>	<20060916081846.e77c0f89.akpm@osdl.org>	<20060917022834.9d56468a.pj@sgi.com>	<450D1A94.7020100@yahoo.com.au>	<20060917041525.4ddbd6fa.pj@sgi.com>	<450D434B.4080702@yahoo.com.au> <20060917061922.45695dcb.pj@sgi.com>
In-Reply-To: <20060917061922.45695dcb.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Nick wrote:

>>The part of your suggestion that I think is too complex to worry about
>>initially, is worrying about full/low/high watermarks and skipping over
>>full zones in your cache.
> 
> 
> Now I'm confused again.  I wasn't aware of giving the slightest
> consideration to full/low/high watermarks in this design.
> 
> Could you quote the portion of my design in which you found this
> consideration of watermarks?

So that's the part where you wanted to see if a zone has any free
memory pages. What you are doing is not actually seeing if a zone
has _any_ free memory pages, but testing whether a given allocation
type is within its corresponding watermarks.

Among other things, these watermarks depends on whether the
allocation is GFP_WAIT or not, and GFP_HIGH or not... so either
you'll be invalidating your cache all the time or you won't obey
the watermarks very well.

Not only that, but you'll sometimes not allocate from more
pereferable zones that now have enough pages but previously didn't.

>>So: just cache the *first* zone that the cpuset allows. If that is
>>full and we have to search subsequent zones, so be it. I hope it would
>>work reasonably well in the common case, though.
> 
> 
> Well, hoping that I'm not misreading again, this seems like it won't
> help.  In the case that Andrew and David present, the cpuset was
> allowing pretty much every node (60 of 64, IIRC).  The performance
> problem came in skipping over the nodes that David's test filled up
> with a memory hog, to get to a node that still had memory it could
> provide to the task running the kernel build.
> 
> So I don't think that it's finding the first node allowed by the
> cpuset that is the painful part here.  I think it is finding the
> first node that still has any free memory pages.
> 
> So I'm pretty sure that I have to cache the first node that isn't
> full.  And I'm pretty sure that's what Andrew has been asking for
> consistently.

Yes I misunderstood the requirements. I thought it was when a small
number of nodes were allowed by the cpuset.

Hmm, if a large number of nodes are allowed by the cpuset, and
you're operating in low memory conditions, you're going to want to
do a reasonable amount of iterating over the zones anyway so you
can do things like kick each one's kswapd.

What we could do then, is allocate pages in batches (we already do),
but only check watermarks if we have to go to the buddly allocator
(we don't currently do this, but really should anyway, considering
that the watermark checks are based on pages in the buddy allocator
rather than pages in buddy + pcp).

At that point, having a cache of the last pcp to have free pages
might be an option: any pcp pages are fair game because they are
already allocated from the POV of the watermark checking / kswapd
kicking.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
