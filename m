Subject: Re: [patch] arbitrary size memory allocator, memarea-2.4.15-D6
References: <Pine.LNX.4.33.0111121714100.14093-200000@localhost.localdomain>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 17 Nov 2001 11:00:38 -0700
In-Reply-To: <Pine.LNX.4.33.0111121714100.14093-200000@localhost.localdomain>
Message-ID: <m14rnt9t15.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> in the past couple of years the buddy allocator has started to show
> limitations that are hurting performance and flexibility.
> 
> eg. one of the main reasons why we keep MAX_ORDER at an almost obscenely
> high level is the fact that we occasionally have to allocate big,
> physically continuous memory areas. We do not realistically expect to be
> able to allocate such high-order pages after bootup, still every page
> allocation carries the cost of it. And even with MAX_ORDER at 10, large
> RAM boxes have hit this limit and are hurting visibly - as witnessed by
> Anton. Falling back to vmalloc() is not a high-quality option, due to the
> TLB-miss overhead.

And additionally vmalloc is nearly as subject to fragmentation as
contiguous memory is.  And on some machines the amount of memory
dedicated to vmalloc is comparatively small. 128M or so.
 
> If we had an allocator that could handle large, rare but
> performance-insensitive allocations, then we could decrease MAX_ORDER back
> to 5 or 6, which would result in less cache-footprint and faster operation
> of the page allocator.

It definitely sounds reasonable.  A special allocator for a hard and
different case. 

> Obviously, alloc_memarea() can be pretty slow if RAM is getting full, nor
> does it guarantee allocation, so for non-boot allocations other backup
> mechanizms have to be used, such as vmalloc(). It is not a replacement for
> the buddy allocator - it's not intended for frequent use.

If we can fix it so that this allocator works well enough that you
don't need a backup allocator but instead when this fails you can
pretty much figure that you couldn't allocate what you are after
then it has a much better chance of being useful.

> alloc_memarea() tries to optimize away as much as possible from linear
> scanning of zone mem-maps, but the worst-case scenario is that it has to
> iterate over all pages - which can be ~256K iterations if eg. we search on
> a 1 GB box.

Hmm.  Can't you assume that buddies are coalesced?
 
> possible future improvements:
> 
> - alloc_memarea() could zap clean pagecache pages as well.
> 
> - if/once reverse pte mappings are added, alloc_memarea() could also
>   initiate the swapout of anonymous & dirty pages. These modifications
>   would make it pretty likely to succeed if the allocation size is
>   realistic.

Except for anonymous pages we have perfectly serviceable reverse
mappings.  They are slow but this is a performance insensitive
allocator so it shouldn't be a big deal to use page->address_space->i_mmap.

But I suspect you could get farther by generating a zone on the fly
for the area you want to free up, and using the normal mechanisms,
or a slight variation on them to free up all the pages in that
area.

> - possibly add 'alignment' and 'offset' to the __alloc_memarea()
>   arguments, to possibly create a given alignment for the memarea, to
>   handle really broken hardware and possibly result in better page
>   coloring as well.
> 
> - if we extended the buddy allocator to have a page-granularity bitmap as
>   well, then alloc_memarea() could search for physically continuous page
>   areas *much* faster. But this creates a real runtime (and cache
>   footprint) overhead in the buddy allocator.

I don't see the need to make this allocator especially fast so I doubt
that would really help.

> i've tested the patch pretty thoroughly on big and small RAM boxes. The
> patch is against 2.4.15-pre3.
> 
> Reports, comments, suggestions welcome,

See above.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
