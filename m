Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id E47266B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:22:48 -0400 (EDT)
Received: by wixw10 with SMTP id w10so4232158wix.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:22:48 -0700 (PDT)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id 16si22220933wjs.171.2015.03.17.01.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 01:22:47 -0700 (PDT)
Received: by webcq43 with SMTP id cq43so1754268web.2
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:22:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317072952.GA23143@js1304-P5Q-DELUXE>
References: <1426248777-19768-1-git-send-email-r.peniaev@gmail.com>
	<1426248777-19768-2-git-send-email-r.peniaev@gmail.com>
	<20150317045608.GA22902@js1304-P5Q-DELUXE>
	<CACZ9PQWbZ7m1LQLs+bOjtHNsKDmSZmkjAH8vmnc2VBgCLDdhDg@mail.gmail.com>
	<20150317072952.GA23143@js1304-P5Q-DELUXE>
Date: Tue, 17 Mar 2015 17:22:46 +0900
Message-ID: <CACZ9PQUO4cBsTdO37n4UWeHk=26g_WqWo-cVsDCf8E1gkq2Zkg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/vmalloc: fix possible exhaustion of vmalloc space
 caused by vm_map_ram allocator
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, WANG Chao <chaowang@redhat.com>, Fabian Frederick <fabf@skynet.be>, Christoph Lameter <cl@linux.com>, Gioh Kim <gioh.kim@lge.com>, Rob Jones <rob.jones@codethink.co.uk>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Tue, Mar 17, 2015 at 4:29 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Tue, Mar 17, 2015 at 02:12:14PM +0900, Roman Peniaev wrote:
>> On Tue, Mar 17, 2015 at 1:56 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> > On Fri, Mar 13, 2015 at 09:12:55PM +0900, Roman Pen wrote:
>> >> If suitable block can't be found, new block is allocated and put into a head
>> >> of a free list, so on next iteration this new block will be found first.
>> >>
>> >> That's bad, because old blocks in a free list will not get a chance to be fully
>> >> used, thus fragmentation will grow.
>> >>
>> >> Let's consider this simple example:
>> >>
>> >>  #1 We have one block in a free list which is partially used, and where only
>> >>     one page is free:
>> >>
>> >>     HEAD |xxxxxxxxx-| TAIL
>> >>                    ^
>> >>                    free space for 1 page, order 0
>> >>
>> >>  #2 New allocation request of order 1 (2 pages) comes, new block is allocated
>> >>     since we do not have free space to complete this request. New block is put
>> >>     into a head of a free list:
>> >>
>> >>     HEAD |----------|xxxxxxxxx-| TAIL
>> >>
>> >>  #3 Two pages were occupied in a new found block:
>> >>
>> >>     HEAD |xx--------|xxxxxxxxx-| TAIL
>> >>           ^
>> >>           two pages mapped here
>> >>
>> >>  #4 New allocation request of order 0 (1 page) comes.  Block, which was created
>> >>     on #2 step, is located at the beginning of a free list, so it will be found
>> >>     first:
>> >>
>> >>   HEAD |xxX-------|xxxxxxxxx-| TAIL
>> >>           ^                 ^
>> >>           page mapped here, but better to use this hole
>> >>
>> >> It is obvious, that it is better to complete request of #4 step using the old
>> >> block, where free space is left, because in other case fragmentation will be
>> >> highly increased.
>> >>
>> >> But fragmentation is not only the case.  The most worst thing is that I can
>> >> easily create scenario, when the whole vmalloc space is exhausted by blocks,
>> >> which are not used, but already dirty and have several free pages.
>> >>
>> >> Let's consider this function which execution should be pinned to one CPU:
>> >>
>> >>  ------------------------------------------------------------------------------
>> >> /* Here we consider that our block is equal to 1MB, thus 256 pages */
>> >> static void exhaust_virtual_space(struct page *pages[256], int iters)
>> >> {
>> >>       /* Firstly we have to map a big chunk, e.g. 16 pages.
>> >>        * Then we have to occupy the remaining space with smaller
>> >>        * chunks, i.e. 8 pages. At the end small hole should remain.
>> >>        * So at the end of our allocation sequence block looks like
>> >>        * this:
>> >>        *                XX  big chunk
>> >>        * |XXxxxxxxx-|    x  small chunk
>> >>        *                 -  hole, which is enough for a small chunk,
>> >>        *                    but not for a big chunk
>> >>        */
>> >>       unsigned big_allocs   = 1;
>> >>       /* -1 for hole, which should be left at the end of each block
>> >>        * to keep it partially used, with some free space available */
>> >>       unsigned small_allocs = (256 - 16) / 8 - 1;
>> >>       void    *vaddrs[big_allocs + small_allocs];
>> >>
>> >>       while (iters--) {
>> >>               int i = 0, j;
>> >>
>> >>               /* Map big chunk */
>> >>               vaddrs[i++] = vm_map_ram(pages, 16, -1, PAGE_KERNEL);
>> >>
>> >>               /* Map small chunks */
>> >>               for (j = 0; j < small_allocs; j++)
>> >>                       vaddrs[i++] = vm_map_ram(pages + 16 + j * 8, 8, -1,
>> >>                                                PAGE_KERNEL);
>> >>
>> >>               /* Unmap everything */
>> >>               while (i--)
>> >>                       vm_unmap_ram(vaddrs[i], (i ? 8 : 16));
>> >>       }
>> >> }
>> >>  ------------------------------------------------------------------------------
>> >>
>> >> On every iteration new block (1MB of vm area in my case) will be allocated and
>> >> then will be occupied, without attempt to resolve small allocation request
>> >> using previously allocated blocks in a free list.
>> >>
>> >> In current patch I simply put newly allocated block to the tail of a free list,
>> >> thus reduce fragmentation, giving a chance to resolve allocation request using
>> >> older blocks with possible holes left.
>> >
>> > Hello,
>> >
>> > I think that if you put newly allocated block to the tail of a free
>> > list, below example would results in enormous performance degradation.
>> >
>> > new block: 1MB (256 pages)
>> >
>> > while (iters--) {
>> >   vm_map_ram(3 or something else not dividable for 256) * 85
>> >   vm_unmap_ram(3) * 85
>> > }
>> >
>> > On every iteration, it needs newly allocated block and it is put to the
>> > tail of a free list so finding it consumes large amount of time.
>> >
>> > Is there any other solution to prevent your problem?
>>
>> Hello.
>>
>> My second patch fixes this problem.
>> I occupy the block on allocation and avoid jumping to the search loop.
>
> I'm not sure that this fixes above case.
> 'vm_map_ram (3) * 85' means 85 times vm_map_ram() calls.
>
> First vm_map_ram(3) caller could get benefit from your second patch.
> But, second caller and the other callers in each iteration could not
> get benefit and should iterate whole list to find suitable free block,
> because this free block is put to the tail of the list. Am I missing
> something?

You are missing the fact that we occupy blocks in 2^n.
So in your example 4 page slots will be occupied (order is 2), not 3.

The maximum size of allocation is 32 pages for 32-bit system
(if you try to map more, original alloc_vmap_area will be called).

So the maximum order is 5.  That means that worst case, before we make
the decision
to allocate new block, is to iterate 6 blocks:

HEAD
1st block - has 1  page slot  free (order 0)
2nd block - has 2  page slots free (order 1)
3rd block - has 4  page slots free (order 2)
4th block - has 8  page slots free (order 3)
5th block - has 16 page slots free (order 4)
6th block - has 32 page slots free (order 5)
TAIL

So the worst scenario is that each CPU queue can have 6 blocks in a free list.

This can happen only and only if you allocate blocks increasing the order.
(as I did in the function written in the comment of the first patch)
This is weird and rare case, but still it is possible.
Afterwards you will get 6 blocks in a list.

All further requests should be placed in a newly allocated block or
some free slots
should be found in a free list.  Seems it does not look dramatically awful.


--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
