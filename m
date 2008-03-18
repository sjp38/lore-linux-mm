Date: Tue, 18 Mar 2008 11:25:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [git pull] slub fallback fix
In-Reply-To: <Pine.LNX.4.64.0803181037470.21992@schroedinger.engr.sgi.com>
Message-ID: <alpine.LFD.1.00.0803181115580.3020@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com> <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org> <Pine.LNX.4.64.0803181037470.21992@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>


On Tue, 18 Mar 2008, Christoph Lameter wrote:
> 
> Fallback is rare and I'd like to have the fallback logic in one place. It 
> would also mean that the interrupt state on return to slab_alloc() would 
> be indeterminate. Currently that works but it may be surprising in the 
> future when changes are made there.

But your version is not just larger and slower, I think it's less obvious 
too exactly because it has a lot *more* of those special cases.

That irq handling in the allocator doesn't "nest" correctly, and it has 
never ever been "good practice" to re-enable interrupts when they've been 
disabled by the caller anyway, so all this code already violates the 
standard rules.

For good reasons, don't get me wrong. But this code is not normal, and 
it's already violating all rules. Wouldn't it be better to at least try to 
keep it small and simple rather than try to have some made-up rules that 
still violate all the common rules?

Just look at the patch:

	-       if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK))
	-               return kmalloc_large(s->objsize, gfpflags);
	-
	+       if (!(gfpflags & __GFP_NORETRY) &&
	+                               (s->flags & __PAGE_ALLOC_FALLBACK)) {
	+               if (gfpflags & __GFP_WAIT)
	+                       local_irq_enable();
	+               object = kmalloc_large(s->objsize, gfpflags);
	+               if (gfpflags & __GFP_WAIT)
	+                       local_irq_disable();
	+               return object;
	+       }

and try to tell me that the new code is more readable? I *really* don't 
agree.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
