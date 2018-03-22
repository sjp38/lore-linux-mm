Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 124156B0028
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 13:31:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31so4697603wrr.2
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 10:31:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f188sor2276280wme.82.2018.03.22.10.31.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Mar 2018 10:31:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180322164157.GE28468@bombadil.infradead.org>
References: <20180322153157.10447-1-willy@infradead.org> <20180322153157.10447-7-willy@infradead.org>
 <CAKgT0UfcYLm3UZcq536cNOczVhR60qoFDHh_gcXqqyqdViuLzw@mail.gmail.com> <20180322164157.GE28468@bombadil.infradead.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 22 Mar 2018 10:31:09 -0700
Message-ID: <CAKgT0Uc1xhaiTT7QvVn_MZsasBVv2g--W1pm2ONHct_e5CZ13g@mail.gmail.com>
Subject: Re: [PATCH v2 6/8] page_frag_cache: Use a mask instead of offset
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Mar 22, 2018 at 9:41 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Thu, Mar 22, 2018 at 09:22:31AM -0700, Alexander Duyck wrote:
>> On Thu, Mar 22, 2018 at 8:31 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> > By combining 'va' and 'offset' into 'addr' and using a mask instead,
>> > we can save a compare-and-branch in the fast-path of the allocator.
>> > This removes 4 instructions on x86 (both 32 and 64 bit).
>>
>> What is the point of renaming "va"? I'm seeing a lot of unneeded
>> renaming in these patches that doesn't really seem needed and is just
>> making things harder to review.
>
> By renaming 'va', I made sure that I saw everywhere that 'va' was touched,
> and reviewed it to be sure it was still correct with the new meaning.
> The advantage of keeping that in the patch submission, rather than
> renaming it back again, is that you can see everywhere that it's been
> touched and verify that for yourself.

Okay, I guess that makes some sense. I was just mentally lumping it in
with the fragsz -> size and nc -> pfc changes.

>> > We can avoid storing the mask at all if we know that we're only allocating
>> > a single page.  This shrinks page_frag_cache from 12 to 8 bytes on 32-bit
>> > CONFIG_BASE_SMALL build.
>> >
>> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> So I am not really a fan of CONFIG_BASE_SMALL in general, so
>> advertising gains in size is just going back down the reducing size at
>> the expense of performance train of thought.
>
> There's no tradeoff for performance *in this patch* with
> CONFIG_BASE_SMALL.  Indeed, being able to assume that the cache contains a
> single PAGE_SIZE page reduces the number of instructions by two on x86-64
> (and is neutral on x86-32).  IIRC it saves a register, so there's one fewer
> 'push' at the beginning of the function and one fewer 'pop' at the end.

The issue is that you are now going to have to perform 8x as many
allocations and take the slow path that many more times.

> I think the more compelling argument for conditioning the number of pages
> allocated on CONFIG_BASE_SMALL is that a machine which needs to shrink
> its data structures so badly isn't going to have 32k of memory available,
> nor want to spend it on a networking allocation.  Eric's commit which
> introduced NETDEV_FRAG_PAGE_MAX_ORDER back in 2012 (69b08f62e174) didn't
> mention small machines as a consideration.

The problem is that is assuming that something is doing small enough
allocations that there is an advantage to using 4K. In the case of
this API I'm not certain that is the case. More often then not this is
used when allocating an skb in the Rx path. The typical Rx skb size is
headroom + 1514 + skb_shared_info. If you take a look that is
dangerously close to 2K. With your change you now get 2 allocations
per page instead of the 16 that was seen with a 32K page. If you have
a device that cannot control the Rx along that boundary things get
worse since you are looking at something like headroom + 2K +
skb_shared_info. In such a case there wouldn't be any point using the
API anymore since you might as well just use the page allocator.

>> Do we know for certain that a higher order page is always aligned to
>> the size of the higher order page itself? That is one thing I have
>> never been certain about. I know for example there are head and tail
>> pages so I was never certain if it was possible to create a higher
>> order page that is not aligned to to the size of the page itself.
>
> It's intrinsic to the buddy allocator that pages are naturally aligned
> to their order.  There's a lot of code in the kernel which relies on
> it, including much of the mm (particularly THP).  I suppose one could
> construct a non-aligned compound page, but it'd be really weird, and you'd
> have to split it up manually before handing it back to the page allocator.
> I don't see this ever changing.
>
>> >  struct page_frag_cache {
>> > -       void * va;
>> > +       void *addr;
>> >  #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>> > -       __u16 offset;
>> > -       __u16 size;
>> > -#else
>> > -       __u32 offset;
>> > +       unsigned int mask;
>>
>> So this is just an akward layout. You now have essentially:
>> #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>> #else
>>     unsigned int mask;
>> #endif
>
> Huh?  There's a '-' in front of the '#else'.  It looks like this:

Yeah, I might need to increase the font size on my email client. The
"-" had blended into the "#".

>
> struct page_frag_cache {
>         void *addr;
> #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>         unsigned int mask;

We might need to check here and see if this needs to be an "unsigned
int" or if we can get away with an "unsigned short". If the maximum
page size supported for most architectures is 64K or less. For those
cases we could just use an unsigned short. There are a rare few that
are larger where this would be forced into an "unsigned int".

> #endif
>         /* we maintain a pagecount bias, so that we dont dirty cache line
>          * containing page->_refcount every time we allocate a fragment.
>          */
>         unsigned int            pagecnt_bias;

We could probably look at doing something similar for pagecnt_bias.
For real use cases we currently force this to be aligned to something
like the L1 cache bytes. That usually reduces the number of actual
uses for this. If we put a limitation where the fragsz has to be
aligned to some value we could use that to limit this so the upper
limit for pagecnt_bias would be PAGE_FRAG_CACHE_MAX_SIZE / (required
alignment size).

> };
>
>> > @@ -4364,27 +4361,24 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *pfc,
>> >                                 PAGE_FRAG_CACHE_MAX_ORDER);PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>> >         if (page)
>> >                 size = PAGE_FRAG_CACHE_MAX_SIZE;
>> > -       pfc->size = size;
>> > +       pfc->mask = size - 1;
>> >  #endif
>> >         if (unlikely(!page))
>> >                 page = alloc_pages_node(NUMA_NO_NODE, gfp, 0);
>> >         if (!page) {
>> > -               pfc->va = NULL;
>> > +               pfc->addr = NULL;
>> >                 return NULL;
>> >         }
>> >
>> > -       pfc->va = page_address(page);
>> > -
>> >         /* Using atomic_set() would break get_page_unless_zero() users. */
>> >         page_ref_add(page, size - 1);
>>
>> You could just use the pfc->mask here instead of size - 1 just to
>> avoid having to do the subtraction more than once assuming the
>> compiler doesn't optimize it.
>
> Either way I'm assuming a compiler optimisation -- that it won't reload
> from memory, or that it'll remember the subtraction.  I don't much care
> which, and I'll happily use the page_frag_cache_mask() if that reads better
> for you.

If the compiler is doing it then you are probably fine.

Thanks.

- Alex
