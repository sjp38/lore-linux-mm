Message-ID: <3D3BA131.34D2BD86@zip.com.au>
Date: Sun, 21 Jul 2002 23:07:45 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: pte_chain_mempool-2.5.27-1
References: <20020721035513.GD6899@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, anton@samba.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> This patch, in order to achieve more reliable and efficient allocation,
> converts the pte_chain freelist to use mempool, which in turn uses the
> slab allocator as a front-end.

Using slab seems like a good idea to me.  It gives us the per-cpu
freelists and GC for free.

mempool?  Guess so.

mempool is really designed for things like IO request structures.
BIOs, etc.  Things which are guaranteed to have short lifecycles.
Things which make the "wait for some objects to be freed" loop
in mempool_alloc() reliable.

However when mempool went in, a bunch of developers (including
myself) went "oh goody" and reused mempool to add some buffering
to things like radix tree nodes, buffer_heads, pte_chains, etc.

This is inappropriate, because those objects have a very different
lifecycle.

For example, back when swap was using buffer_heads, I was getting
tasks locked up in mempool_alloc(GFP_NOIO), waiting for buffer_heads
to come free.  But no buffer_heads were being freed because there was
no memory pressure any more - somebody had just done a truncate() or
an exit(), there was plenty of free memory, nobody was calling 
try_to_free_buffers() and the mempool_alloc caller was in indefinite
sleep.  Waiting for someone to free up a buffer_head.

We could fix this problem by changing the schedule() in mempool_alloc()
into a schedule_timeout(not much), but Ingo didn't seem to like that.
Perhaps because we're using mempool in ways for which it was not
designed.


> +       pte_chain_pool = mempool_create(16*1024,
> +                                       pte_chain_pool_alloc,
> +                                       pte_chain_pool_free,
> +                                       NULL);
> +

Be aware that mempool kmallocs a contiguous chunk of element
pointers.  This statement is asking for a
kmalloc(16384 * sizeof(void *)), which is 128k. It will work,
but only just.

How did you engineer the size of this pool, btw?  In the
radix_tree code, we made the pool enormous.  It was effectively
halved in size when the ratnodes went to 64 slots, but I still
have the fun task of working out what the pool size should really
be.  In retrospect it would have been smarter to make it really
small and then increase it later in response to tester feedback.
Suggest you do that here.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
