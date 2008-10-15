Date: Wed, 15 Oct 2008 11:03:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <200810160445.28781.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810151058540.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <200810160410.49894.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org> <200810160445.28781.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Oct 2008, Nick Piggin wrote:
> 
> What do you mean by the allocation is stable?

"all writes done to it before it's exposed".

> 2. I think it could be easy to assume that the allocated object that was
> initialised with a ctor for us already will have its initializing stores
> ordered when we get it from slab.

You make tons of assumptions.

You assume that
 (a) unlocked accesses are the normal case and should be something the 
     allocator should prioritize/care about.
 (b) that if you have a ctor, it's the only thing the allocator will do.

I don't think either of those assumptions are at all relevant or 
interesting. Quite the reverse - I'd expect them to be in a very small 
minority.

Now, obviously, on pretty much all machines out there (ie x86[-64] and UP 
ARM), smp_wmb() is a no-op, so in that sense we could certainly say that 
"sure, this is a total special case, but we can add a smp_wmb() anyway 
since it won't cost us anything".

On the other hand, on the machines where it doesn't cost us anything, it 
obviously doesn't _do_ anything either, so that argument is pretty 
dubious. 

And on machines where the memory ordering _can_ matter, it's going to add 
cost to the wrong point.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
