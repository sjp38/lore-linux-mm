Message-ID: <48EB6D2C.30806@linux-foundation.org>
Date: Tue, 07 Oct 2008 09:07:40 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] SLOB's krealloc() seems bust
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
In-Reply-To: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Which basically shows us that the content of the pcpu_size[] array got
> corrupted after the krealloc() call in split_block().
> 
> Which made me look at which slab allocator I had selected, which turned
> out to be SLOB (from testing the network swap stuff).

krealloc() is in generic core code (mm/util.c) and is the same for all allocators.

krealloc uses ksize() which is somewhat dicey for SLOB because it only works
on kmalloc'ed memory. Is the krealloc used on memory allocated with kmalloc()?
Slob's ksize could use a BUG_ON for the case in which ksize() is used on
kmem_cache_alloc'd memory.

/* can't use ksize for kmem_cache_alloc memory, only kmalloc */
size_t ksize(const void *block)
{
        struct slob_page *sp;

        BUG_ON(!block);
        if (unlikely(block == ZERO_SIZE_PTR))
                return 0;

        sp = (struct slob_page *)virt_to_page(block);


Add a BUG_ON(!kmalloc_cache(sp))?


        if (slob_page(sp))
                return ((slob_t *)block - 1)->units + SLOB_UNIT;
			^^^^^^^ Is this correct?
			
        else
                return sp->page.private;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
