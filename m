Date: Wed, 15 Oct 2008 10:36:15 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0810151033170.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <1224089658.3316.218.camel@calx> <200810160410.49894.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151028110.3288@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 15 Oct 2008, Linus Torvalds wrote:
> 
> If you make an allocation visible to other CPU's, you would need to make 
> sure that allocation is stable with a smp_wmb() before you update the 
> pointer to that allocation.

Just to clarify a hopefully obvious issue..

The assumption here is that you don't protect things with locking. Of 
course, if all people accessing the new pointer always have the 
appropriate lock, then memory ordering never matters, since the locks take 
care of it.

So _most_ allocators obviously don't need to do any smp_wmb() at all. But 
the ones that expose things locklessly (where page tables are just one 
example) need to worry.

Again, this is yet another reason to not put things in the allocator. The 
allocator cannot know, and shouldn't care. For all the exact same reasons 
that the allocator cannot know and shouldn't care whether the ctor results 
in a 'final' version or whether the allocator will do some final fixups.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
