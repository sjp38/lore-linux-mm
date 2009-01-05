Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDF2C6B00A3
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 14:39:45 -0500 (EST)
Date: Mon, 5 Jan 2009 11:39:29 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re: BUG:
 soft lockup - is this XFS problem?)
In-Reply-To: <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0901051131090.3057@localhost.localdomain>
References: <gifgp1$8ic$1@ger.gmane.org> <20081223171259.GA11945@infradead.org> <20081230042333.GC27679@wotan.suse.de> <20090103214443.GA6612@infradead.org> <20090105014821.GA367@wotan.suse.de> <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de>
 <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain> <20090105180008.GE32675@wotan.suse.de> <alpine.LFD.2.00.0901051027011.3057@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



On Mon, 5 Jan 2009, Linus Torvalds wrote:
> 
> Either the value can change, or it can not. It's that simple.
> 
> If it cannot change, then we can load it just once, or we can load it 
> multiple times, and it won't matter. Barriers won't do anything but screw 
> up the code.
> 
> If it can change from under us, you need to use rcu_dereference(), or 
> open-code it with an ACCESS_ONCE() or put in barriers. But your placement 
> of a barrier was NONSENSICAL. Your barrier didn't protect anything else - 
> like the test for the RADIX_TREE_INDIRECT_PTR bit.
> 
> And that was the fundamental problem.

Btw, this is the real issue with anything that does "locking vs 
optimistic" accesses.

If you use locking, then by definition (if you did things right), the 
values you are working with do not change. As a result, it doesn't matter 
if the compiler re-orders accesses, splits them up, or coalesces them. 
It's why normal code should never need barriers, because it doesn't matter 
whether some access gets optimized away or gets done multiple times.

But whenever you use an optimistic algorithm, and the data may change 
under you, you need to use barriers or other things to limit the things 
the CPU and/or compiler does.

And yes, "rcu_dereference()" is one such thing - it's not a barrier in the 
sense that it doesn't necessarily affect ordering of accesses to other 
variables around it (although the read_barrier_depends() obviously _is_ a 
very special kind of ordering wrt the pointer itself on alpha). But it 
does make sure that the compiler at least does not coalesce - or split - 
that _one_ particular access.

It's true that it has "rcu" in its name, and it's also true that that may 
be a bit misleading in that it's very much useful not just for rcu, but 
for _any_ algorithm that depends on rcu-like behavior - ie optimistic 
accesses to data that may change underneath it. RCU is just the most 
commonly used (and perhaps best codified) variant of that kind of code.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
