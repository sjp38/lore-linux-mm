Date: Tue, 18 Mar 2008 11:45:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] slub fallback fix
In-Reply-To: <alpine.LFD.1.00.0803181115580.3020@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0803181137250.23639@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com>
 <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org>
 <Pine.LNX.4.64.0803181037470.21992@schroedinger.engr.sgi.com>
 <alpine.LFD.1.00.0803181115580.3020@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Linus Torvalds wrote:

> That irq handling in the allocator doesn't "nest" correctly, and it has 
> never ever been "good practice" to re-enable interrupts when they've been 
> disabled by the caller anyway, so all this code already violates the 
> standard rules.

Yes this interupt stuff in the slab allocators is not the nicest thing. 
Surely wish we could get rid of it. The realtime folks may be able to get 
there by simply not using the slab allocator from interrupt contexts.
 
> Just look at the patch:
> 
> 	-       if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK))
> 	-               return kmalloc_large(s->objsize, gfpflags);
> 	-
> 	+       if (!(gfpflags & __GFP_NORETRY) &&
> 	+                               (s->flags & __PAGE_ALLOC_FALLBACK)) {
> 	+               if (gfpflags & __GFP_WAIT)
> 	+                       local_irq_enable();
> 	+               object = kmalloc_large(s->objsize, gfpflags);
> 	+               if (gfpflags & __GFP_WAIT)
> 	+                       local_irq_disable();
> 	+               return object;
> 	+       }
> 
> and try to tell me that the new code is more readable? I *really* don't 
> agree.

Well it may now have become not so readable anymore. However, this 
contains the kmalloc fallback logic in one spot. And that logic is likely 
going to be generalized for 2.6.26 removing __PAGE_ALLOC_FALLBACK etc. The 
chunk is going away. Either solution is fine with me. Just get it fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
