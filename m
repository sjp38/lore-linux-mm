Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA18077
	for <linux-mm@kvack.org>; Sat, 25 Jul 1998 09:06:04 -0400
Subject: Re: More info: 2.1.108 page cache performance on low memory
References: <Pine.LNX.3.96.980724234821.31219A-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 25 Jul 1998 15:05:41 +0200
In-Reply-To: Rik van Riel's message of "Fri, 24 Jul 1998 23:55:10 +0200 (CEST)"
Message-ID: <87d8au13oa.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> On 24 Jul 1998, Zlatko Calusic wrote:
> 
> > > There's also a 'soft limit', or borrow percentage. Ultimately
> > > the minimum and maximum percentages should be 0 and 100 %
> > > respectively.
> > 
> > Could you elaborate on "borrow" percentage? I have some trouble
> > understanding what that could be.
> 
> It's an idea I stole from Digital Unix :)
> 
> Basically, the cache is allowed to grow boundless, but is
> reclaimed until it reaches the borrow percentage when
> memory is short.

OK, I get it now. Looks good.

> 
> The philosophy behind is that caching the disk doesn't make
> much sense beyond a certain point.
> 

I mostly agree.

> It's a primitive idea, but it seems to have saved Andrea's
> machine quite well (with the additional patch).
> 
> I admit your patch (multiple aging) should work even better,
> but in order to do that, we probably want to make it auto-tuning
> on the borrow percentage:
> 
> - if page_cache_size > borrow + 5%     --> add aging loop
> - if loads_of_disk_io and almost thrashing [*] --> remove aging loop

Yes, something like this could be worthwhile. I observed some strange
patterns of behaviour with aging loop, sometimes system is still too
aggresive, and sometimes you can't say if it's working at all.

Probably, some debbugging and profiling code should be added to see
what's goin' on there.

> 
> [*] this thrashing can be measured by testing the cache hit/mis
> rate; if it falls below (say) 50% we could consider thrashing.

That probably wouldn't work as well as you expect. Problem is again
with that arbitrary 50%. I had code in kernel that reported
buffer/page cache hit ratio and was surprised that for both caches it
was > 90%. And that was on 5MB machine. Can you imagine? :)

> 
> (50% should be a good rate for an aging cache, and the amount
> of loops is trimmed quickly enough when we grow anyway. This
> mechanism could make a nice somewhat adjusting trimming
> mechanism. Expect a patch soon...)
> 

I'll be glad to test a patch, but I'm not that convinced that this is
really a good idea. But, then again I have nothing against it.

Keep up the good work!
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	Crime doesn't pay... does that mean my job is a crime?
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
