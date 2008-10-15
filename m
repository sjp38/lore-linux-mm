Date: Wed, 15 Oct 2008 10:33:01 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <200810160410.49894.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <1224089658.3316.218.camel@calx> <200810160410.49894.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Oct 2008, Nick Piggin wrote:
> 
> Now they allocate these guys, take a lock, then insert them into the
> page tables. The lock is only an acquire barrier, so it can leak past
> stores.

I think that Matt's point was that the code is buggy regardless of any 
ctor or not.

If you make an allocation visible to other CPU's, you would need to make 
sure that allocation is stable with a smp_wmb() before you update the 
pointer to that allocation.

So the code that makes a page visible should just always do that 
synchronization.

And it has nothing to do with ctors or not. It's true whether you do the 
initialization by hand, or whether you use a ctor.

And more importantly, putting the write barrier in the ctor or in the 
memory allocator is simply broken. It's not a ctor/allocator issue. Why? 
Because even if you have a ctor, there is absolutely *nothing* that says 
that the ctor will be sufficient to initialize everything. Most ctors, in 
fact, are just initializing the basic fields - the person that does the 
allocation should finish things up.

The fact that _some_ people using an allocator with a ctor may not do 
anything but the ctor to the page is immaterial.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
