Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBA3C6B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 02:15:05 -0400 (EDT)
Date: Wed, 8 Jul 2009 08:21:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090708062125.GJ2714@wotan.suse.de>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 09:59:39AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 7 Jul 2009, Nick Piggin wrote:
> > 
> > I just wouldn't like to re-add significant complexity back to
> > the vm without good and concrete examples. OK I agree that
> > just saying "rewrite your code" is not so good, but are there
> > real significant problems? Is it inside just a particuar linear
> > algebra library or something  that might be able to be updated?
> 
> The thing is, ZERO_PAGE really used to work very well.
> 
> It was not only useful for simple "I want lots of memory, and I'm going to 
> use it pretty sparsely" (which _is_ a very valid thing to do), but it was 
> useful for TLB benchmarking, and for cache-efficient "I'm going to write 
> lots of zeroes to files", and for a number of other uses.
> 
> You can talk about TLB pressure all you want, but the fact is, quite often 
> normal cache effects dominate - and ZERO_PAGE is _wonderful_ for sharing 
> cachelines (which is why it was so useful for TLB performance testing: map 
> a huge area, and you know that there will be no cache effects, only TLB 
> effects).
> 
> There are actually very few cases where TLB effects are the primary ones - 
> they tend to happen when you have truly random accesses that have no 
> locality even on a small case. That's pretty rare. Even things that depend 
> on sparse arrays etc tend to mainly _access_ the parts it works on (ie you 
> may have allocated hundreds of megs of memory to simplify your memory 
> management, but you work on only a small part of it).

I'm talking about the cases where you would want to use ZERO_PAGE for
computing with anonymous memory (not for zeroing IO). In that case,
the TLB would probably be the primary one. For IO, having zero page
for /dev/zero mapping would be a good idea (I think I actually
implemented that in a sles kernel for someone doing benchmarking).

 
> So it's not just "people actually use it". It really was a useful feature, 
> with valid uses. We got rid of it, but if we can re-introduce it cleanly, 
> we definitely should.
> 
> I don't understand why you fight it. If we can do it well (read: without 
> having fork/exit cause endless amounts of cache ping-pongs due to touching 
> 'struct page *'), there are no downsides that I can see. It's not like 
> it's a complicated feature.

I don't fight it. I had proposals to get rid of cache pingpong too,
but you rejected that ;)

I just think that right now seeing as we have gotten rid of it for
a year or so, then it would be good to know of some real cases where
it helps before reintroducing it. I'm not saying none exist, I just
want to know about them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
