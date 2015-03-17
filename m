Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3295E6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 00:56:08 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so86173617pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 21:56:07 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ju14si26760128pab.145.2015.03.16.21.56.06
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 21:56:07 -0700 (PDT)
Date: Tue, 17 Mar 2015 13:56:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space
 caused by vm_map_ram allocator
Message-ID: <20150317045608.GA22902@js1304-P5Q-DELUXE>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
 <1426248777-19768-2-git-send-email-r.peniaev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426248777-19768-2-git-send-email-r.peniaev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Pen <r.peniaev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, Mar 13, 2015 at 09:12:55PM +0900, Roman Pen wrote:
> If suitable block can't be found, new block is allocated and put into a head
> of a free list, so on next iteration this new block will be found first.
> 
> That's bad, because old blocks in a free list will not get a chance to be fully
> used, thus fragmentation will grow.
> 
> Let's consider this simple example:
> 
>  #1 We have one block in a free list which is partially used, and where only
>     one page is free:
> 
>     HEAD |xxxxxxxxx-| TAIL
>                    ^
>                    free space for 1 page, order 0
> 
>  #2 New allocation request of order 1 (2 pages) comes, new block is allocated
>     since we do not have free space to complete this request. New block is put
>     into a head of a free list:
> 
>     HEAD |----------|xxxxxxxxx-| TAIL
> 
>  #3 Two pages were occupied in a new found block:
> 
>     HEAD |xx--------|xxxxxxxxx-| TAIL
>           ^
>           two pages mapped here
> 
>  #4 New allocation request of order 0 (1 page) comes.  Block, which was created
>     on #2 step, is located at the beginning of a free list, so it will be found
>     first:
> 
>   HEAD |xxX-------|xxxxxxxxx-| TAIL
>           ^                 ^
>           page mapped here, but better to use this hole
> 
> It is obvious, that it is better to complete request of #4 step using the old
> block, where free space is left, because in other case fragmentation will be
> highly increased.
> 
> But fragmentation is not only the case.  The most worst thing is that I can
> easily create scenario, when the whole vmalloc space is exhausted by blocks,
> which are not used, but already dirty and have several free pages.
> 
> Let's consider this function which execution should be pinned to one CPU:
> 
>  ------------------------------------------------------------------------------
> /* Here we consider that our block is equal to 1MB, thus 256 pages */
> static void exhaust_virtual_space(struct page *pages[256], int iters)
> {
> 	/* Firstly we have to map a big chunk, e.g. 16 pages.
> 	 * Then we have to occupy the remaining space with smaller
> 	 * chunks, i.e. 8 pages. At the end small hole should remain.
> 	 * So at the end of our allocation sequence block looks like
> 	 * this:
> 	 *                XX  big chunk
> 	 * |XXxxxxxxx-|    x  small chunk
> 	 *                 -  hole, which is enough for a small chunk,
> 	 *                    but not for a big chunk
> 	 */
> 	unsigned big_allocs   = 1;
> 	/* -1 for hole, which should be left at the end of each block
> 	 * to keep it partially used, with some free space available */
> 	unsigned small_allocs = (256 - 16) / 8 - 1;
> 	void    *vaddrs[big_allocs + small_allocs];
> 
> 	while (iters--) {
> 		int i = 0, j;
> 
> 		/* Map big chunk */
> 		vaddrs[i++] = vm_map_ram(pages, 16, -1, PAGE_KERNEL);
> 
> 		/* Map small chunks */
> 		for (j = 0; j < small_allocs; j++)
> 			vaddrs[i++] = vm_map_ram(pages + 16 + j * 8, 8, -1,
> 						 PAGE_KERNEL);
> 
> 		/* Unmap everything */
> 		while (i--)
> 			vm_unmap_ram(vaddrs[i], (i ? 8 : 16));
> 	}
> }
>  ------------------------------------------------------------------------------
> 
> On every iteration new block (1MB of vm area in my case) will be allocated and
> then will be occupied, without attempt to resolve small allocation request
> using previously allocated blocks in a free list.
> 
> In current patch I simply put newly allocated block to the tail of a free list,
> thus reduce fragmentation, giving a chance to resolve allocation request using
> older blocks with possible holes left.

Hello,

I think that if you put newly allocated block to the tail of a free
list, below example would results in enormous performance degradation.

new block: 1MB (256 pages)

while (iters--) {
  vm_map_ram(3 or something else not dividable for 256) * 85
  vm_unmap_ram(3) * 85
}

On every iteration, it needs newly allocated block and it is put to the
tail of a free list so finding it consumes large amount of time.

Is there any other solution to prevent your problem?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
