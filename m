Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A6FB86B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 16:22:14 -0400 (EDT)
Date: Wed, 11 Mar 2009 13:19:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311195935.GO27823@random.random>
Message-ID: <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random>
 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain> <20090311195935.GO27823@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Andrea Arcangeli wrote:
> 
> Did you notice the check after 'mark it gup' that will run in CPU0?

Ahh, no. I just read the patch through fairly quickly, and the whole 
"(gup_get_pte & mask) != mask" didn't trigger as obvious. But yeah, I see 
that it ends up re-checking the RW bit.

> gup-fast will _not_ succeed because of the set_wr_protect that just 
> happened on CPU1. That's why I added the above check after 
> setpagegup/get_page.

Ok, with the recheck I think it's fine.

> > Also, having to set the PG_GUP bit means that the "fast" gup is likely not 
> > much faster than the slow one. It now has two atomics per page it looks 
> > up, afaik, which sounds like it would delete any advantage it had over the 
> > slow version that needed locking.
> 
> gup-fast has already to get_page, so I don't see it.

That's my point. It used to have one atomic. Now it has two (and a memory 
barrier). Those tend to be pretty expensive - even when there's no 
cacheline bouncing.

> Furthermore starting from the second access GUP is already
> set

That's a totally bogus argument. It will be true for _benchmarks_, but if 
somebody is trying to avoid buffered IO, one very possible common case is 
that it's all going to be new pages all the time.

That said, I don't know who the crazy O_DIRECT users are. It may be true 
that some O_DIRECT users end up using the same pages over and over again, 
and that this is a good optimization for them.

> > What we _could_ try to do is to always make the COW breaking be a 
> > _directed_ event - we'd make sure that we always break COW in the 
> > direction of the first owner (going to the rmap chains). That might solve 
> > everything, and be purely local to the logic in mm/memory.c (do_wp_page).
> 
> That's a really interesting idea and frankly I didn't think about it.

The advantage of it is that it fixes the problem not just in one place, 
but "forever". No hacks about exactly how you access the mappings etc.

Of course, nothing _really_ solves things. If you do some delayed IO after 
having looked up the mapping and turned it into a physical page, and the 
original allocator actually unmaps it (or exits), then the same issue can 
still happen (well, not the _same_ one - but the very similar issue of the 
child seeing changes even though the IO was started in the parent). 

This is why I think any "look up by physical" is fundamentally flawed. It 
very basically becomes a "I have a secret local TLB that cannot be changed 
or flushed". And any single-bit solution (GUP) is always going to be 
fairly broken. 

> The cost of my fix to fork is not measurable with fork microbenchmark,
> while the cost of finding who owns the original shared page in
> do_wp_page would be potentially be much bigger. The only slowdown to
> fork is in the O_DIRECT slow path which we don't care about and in the
> worst case is limited to the total amount of in-flight I/O.

Agreed. However, I really think this is a O_DIRECT problem. Just document 
it. Tell people that O_DIRECT simply doesn't work with COW, and 
fundamentally can never work well.

If you use O_DIRECT with threading, you had better know what the hell 
you're doing anyway. I do not think that the kernel should do stupid 
things just because stupid users don't understand the semantics of the 
_non-stupid_ thing (which is to just let people think about COW for five 
seconds).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
