Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E13836B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 03:32:56 -0400 (EDT)
Date: Thu, 9 Jul 2009 09:47:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090709074745.GT2714@wotan.suse.de>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain> <20090708062125.GJ2714@wotan.suse.de> <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 09:07:08AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 8 Jul 2009, Nick Piggin wrote:
> > 
> > I'm talking about the cases where you would want to use ZERO_PAGE for
> > computing with anonymous memory (not for zeroing IO). In that case,
> > the TLB would probably be the primary one.
> 
> Umm. Are you even listening to yourself?
> 
> OF COURSE the TLB would be the primary issue, since the zero page has made 
> cache effects go away.

Yes, that's what I said.

 
> BUT THAT IS A GOOD THING.
> 
> Instead of making it sound like "that's a bad thing, because now TLB 
> dominates", just say what's really going on: "that's a good thing, because 
> you made the cache access patterns wonderful".
> 
> See? You claim TLB is a problem, but it's really that you made all _other_ 
> problems go away. 

No I don't. Re-read what I wrote. I said that an app that scans huge
sparse matricies *might* be better off with a different data format
rather than relying on ZERO_PAGE with a naive format. Of course if it
does rely on ZERO_PAGE for this, then having ZERO_PAGE is going to be
better than allocating lots of anonymous memory for it, I didn't caim
otherwise.

 
> Now, it's true that you can avoid the TLB costs by moving the costs into a 
> "software TLB" (aka "indirection table"), and make the TLB footprint go 
> away by turning it into something else (indirection through a pointer). 
> 
> Sometimes that speeds things up - because you may be able to actually 
> avoid doing other things by noticing huge gaps etc - but sometimes it 
> slows you down too - because indirection isn't free, and maybe there are 
> common cases where there isn't so many sparse accesses.

Sometimes there are much for efficient data formats for sparse
matricies too, which can also avoid the quantization effects
(and cache usage) of page size.

 
> > I don't fight it. I had proposals to get rid of cache pingpong too,
> > but you rejected that ;)
> 
> Yeah, and they were ugly as hell. I had a suggestion to just continue to 
> use PG_reserved (which was _way_ simpler than your version) before the 
> counting, but you and Hugh were on a religious agenda against the whole 
> PG_reserved bit.

No I had no problem with it. I didn't see the big difference between
explicitly testing for ZERO_PAGE or using a new page flag bit (which
aren't free -- PG_reserved can basicaly be reclaimed now if somebody
cares to go through arch init code).

Now if there was more than one type of page to test for, then yes
a page flag would be better because it would reduce branches. I
just didn't see why you were religiously against testing ZERO_PAGE
but thought PG_zero (or PG_reserved or whatever) was so much better.


> So I don't understand why you claim that you fight it, when you CLEARLY 
> do. The patches that KAMEZAWA-san posted were already simpler than your 
> complicated models were - I just think they can be simpler still.

Having a ZERO_PAGE I'm not against, so I don't know why you claim
I am. Al I'm saying is that now we don't have one, we should have
some good reasons to introduce it again. Unreasonable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
