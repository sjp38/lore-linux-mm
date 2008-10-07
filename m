Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <48EB6D2C.30806@linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <48EB6D2C.30806@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 07 Oct 2008 16:13:08 +0200
Message-Id: <1223388788.26330.38.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-10-07 at 09:07 -0500, Christoph Lameter wrote:
> > Which basically shows us that the content of the pcpu_size[] array got
> > corrupted after the krealloc() call in split_block().
> > 
> > Which made me look at which slab allocator I had selected, which turned
> > out to be SLOB (from testing the network swap stuff).
> 
> krealloc() is in generic core code (mm/util.c) and is the same for all allocators.

Joy :/

> krealloc uses ksize() which is somewhat dicey for SLOB because it only works
> on kmalloc'ed memory. Is the krealloc used on memory allocated with kmalloc()?
> Slob's ksize could use a BUG_ON for the case in which ksize() is used on
> kmem_cache_alloc'd memory.

kernel/module.c: perpcu_modinit() reads:

	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
			    GFP_KERNEL);

kernel/module.c: split_block() reads:

		new = krealloc(pcpu_size, sizeof(new[0])*pcpu_num_allocated*2,
			       GFP_KERNEL);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
