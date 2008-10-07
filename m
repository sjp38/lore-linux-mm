Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <48EB6D2C.30806@linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 10:00:55 -0500
Message-Id: <1223391655.13453.344.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-07 at 09:07 -0500, Christoph Lameter wrote:
> > Which basically shows us that the content of the pcpu_size[] array got
> > corrupted after the krealloc() call in split_block().
> > 
> > Which made me look at which slab allocator I had selected, which turned
> > out to be SLOB (from testing the network swap stuff).
> 
> krealloc() is in generic core code (mm/util.c) and is the same for all allocators.
> 
> krealloc uses ksize() which is somewhat dicey for SLOB because it only works
> on kmalloc'ed memory. Is the krealloc used on memory allocated with kmalloc()?
> Slob's ksize could use a BUG_ON for the case in which ksize() is used on
> kmem_cache_alloc'd memory.
> 
> /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
> size_t ksize(const void *block)
> {
>         struct slob_page *sp;
> 
>         BUG_ON(!block);
>         if (unlikely(block == ZERO_SIZE_PTR))
>                 return 0;
> 
>         sp = (struct slob_page *)virt_to_page(block);
> 
> 
> Add a BUG_ON(!kmalloc_cache(sp))?

We can't dynamically determine whether a pointer points to a kmalloced
object or not. kmem_cache_alloc objects have no header and live on the
same pages as kmalloced ones.

>         if (slob_page(sp))
>                 return ((slob_t *)block - 1)->units + SLOB_UNIT;
> 			^^^^^^^ Is this correct?

The cast? Yes. We want to look at the slob_t object header immediately
before the object pointer.

But the rest of the statement looks completely broken. If our SLOB
object is 3 units (6 bytes), with a usuable size of 4 bytes, the above
will report 3 + 2 = 5 bytes. Instead we want (3 - 1) * 2 = 4, something
more like:

	return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
			
It's a bit amazing no one's hit this before, but I guess that's because
for allocations > 6 bytes, it will under-report buffer sizes, avoiding
overruns. And for the < 6 byte cases, we've just been getting lucky.

Give this a try, please:

diff -r 5e32b09a1b2b mm/slob.c
--- a/mm/slob.c	Fri Oct 03 14:04:43 2008 -0500
+++ b/mm/slob.c	Tue Oct 07 10:00:16 2008 -0500
@@ -515,7 +515,7 @@
 
 	sp = (struct slob_page *)virt_to_page(block);
 	if (slob_page(sp))
-		return ((slob_t *)block - 1)->units + SLOB_UNIT;
+		return (((slob_t *)block - 1)->units - 1) * SLOB_UNIT;
 	else
 		return sp->page.private;
 }

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
