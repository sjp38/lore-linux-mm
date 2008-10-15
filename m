Date: Wed, 15 Oct 2008 12:47:24 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <200810160619.53510.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810151231550.3288@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <200810160535.51586.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810151139320.3288@nehalem.linux-foundation.org> <200810160619.53510.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Oct 2008, Nick Piggin wrote:
> 
> I guess I wouldn't bother with your kernel. I was being hypothetical.
> Can you _prove_ no code has a bug due specifically to this issue?

Nick, nobody can prove anything but the most trivial programs.

> Did you read the anon_vma example? It's broken if it assumes the objects
> coming out of its slab are always "stable".

So why do you blame SLOB/SLAB?

This is my whole and only point - you're pointing at all the wrong things, 
and then I get upset when I point out to you - over and over again - that 
you point to the wrong thing, and you just keep on (once more) pointing to 
it.

Can you see my frustration? You keep on claiming this is somehow an 
issue of the slab allocator, and seem to refuse to just read what I write.

But let me try it again:

 - The object you get from kmalloc (or *any* allocator) is a per-CPU 
   object. It's your _local_ memory area. And it has to be that way, 
   because no allocator can ever know the difference between objects that 
   are going to have global visibility and objects that don't. So the 
   allocator has to basically assume the cheap case.

 - Yes, we could add a "smp_wmb()" at the end of all allocators, but that 
   would be a pointless no-op on architectures where it doesn't matter, 
   and it would be potentially expensive on architectures where it _does_ 
   matter. In other words, in neither case is it the right thing to do.

 - Most allocations by _far_ (at least in the static sense of "there's a 
   lot of kmalloc/kmem_cache_alloc's in the kernel") are going to be used 
   for things that are either thread-local (think temporary data 
   structures like "__getname()" for path allocators) or are going to be 
   used with proper locking.

   NONE OF THOSE CASES WANT THE OVERHEAD! And they are the *common* ones.

 - constructiors really have absolutely nothing to do with anything. What 
   about kzalloc()? That's an implicit "constructor" too. Do you want the 
   smp_wmb() there for that too? Do you realize that 99.9% of all such 
   users will fill in a few bytes/fields in _addition_ to clearing the 
   structure they just allocated? You do realize that almost nobody wants 
   a really empty data structure? You _do_ realize that the "smp_wmb()" in 
   the allocator IS TOTALLY USELESS if the code that did the allocation 
   then updates a few other fields too?

   ADDING the smp_wmb() at an allocation point WOULD BE ACTIVELY 
   MISLEADING. Anybody who thinks that it helps is just fooling himself. 

   We're *much* better off just telling everybody that if they think they 
   can do lockless data structures, they have to do the memory ordering at 
   the _insertion_ point, and stop believing in fairies and wizards and in 
   allocators doing it for them!

 - For _all_ of these reasons, any time you say that this is an allocator 
   issue, or a constructor issue, I don't need to even bother reading any 
   more. Because you've just shown yourself to not read what I wrote, nor 
   understand the issue.

So if you want to have a constructive discussion, you need to

 - *read* what I wrote. UNDERSTAND that memory ordering is a non-issue 
   when there is locking involved, and that locking is still the default 
   approach for any normal data structure.

 - *stop* talking about "constructors" and "SLOB allocators". Because as 
   long as you do, you're not making sense.

and if you can do that, I can treat you like you're worth talking to. But 
as long as you cannot accept that, what's the point?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
