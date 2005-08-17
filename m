Date: Wed, 17 Aug 2005 15:36:04 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817151723.48c948c7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 17 Aug 2005, Andrew Morton wrote:
> 
> These are getting in the way now, and I need to make a go/no-go decision.
> 
> I have vague feelings of ickiness with the patches wrt:
> 
> a) general increase of complexity
> 
> b) the fact that they only partially address the problem: anonymous page
>    faults are addressed, but lots of other places aren't.
> 
> c) the fact that they address one particular part of one particular
>    workload on exceedingly rare machines.
> 
> I believe that Nick has plans to address b).
> 
> I'd like us to thrash this out (again), please.  Hugh, could you (for the
> nth and final time) describe your concerns with these patches?

Hmm.. I personally like the anonymous page thing, since I actualyl think
that's one of the most important ones. It's the one that does _not_ 
actually only matter for some esoteric case: if you can get rid of a lock 
in the page fault logic, that's a big win, in my opinion. Locks are 
expensive.

HOWEVER, the fact that it makes the mm counters be atomic just makes it
pointless. It may help scalability, but it loses the attribute that I
considered a big win above - it no longer helps the non-contended case (at
least on x86, a uncontended spinlock is about as expensive as a atomic
op).

I thought Christoph (Nick?) had a patch to make the counters be
per-thread, and then just folded back into the mm-struct every once in a
while?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
