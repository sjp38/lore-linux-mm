Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 255BA6B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 20:30:58 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id q83so37581548iod.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:30:58 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id o12si14781884ioe.169.2016.08.04.17.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 17:30:57 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id b62so286310808iod.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 17:30:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160804181913.26ee17b9@redhat.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com> <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com> <20160804181913.26ee17b9@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 4 Aug 2016 17:30:56 -0700
Message-ID: <CAKgT0UdbVK6Ti9drCQFfa0MyU40Kh=Hu=BtDTRCqqsSiBvJ7rg@mail.gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john fastabend <john.fastabend@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu, Aug 4, 2016 at 9:19 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Wed, 3 Aug 2016 10:45:13 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>
>> On Mon, Jul 25, 2016 at 09:35:20AM +0200, Eric Dumazet wrote:
>> > On Tue, 2016-07-19 at 12:16 -0700, Brenden Blanco wrote:
>> > > The mlx4 driver by default allocates order-3 pages for the ring to
>> > > consume in multiple fragments. When the device has an xdp program, this
>> > > behavior will prevent tx actions since the page must be re-mapped in
>> > > TODEVICE mode, which cannot be done if the page is still shared.
>> > >
>> > > Start by making the allocator configurable based on whether xdp is
>> > > running, such that order-0 pages are always used and never shared.
>> > >
>> > > Since this will stress the page allocator, add a simple page cache to
>> > > each rx ring. Pages in the cache are left dma-mapped, and in drop-only
>> > > stress tests the page allocator is eliminated from the perf report.
>> > >
>> > > Note that setting an xdp program will now require the rings to be
>> > > reconfigured.
>> >
>> > Again, this has nothing to do with XDP ?
>> >
>> > Please submit a separate patch, switching this driver to order-0
>> > allocations.
>> >
>> > I mentioned this order-3 vs order-0 issue earlier [1], and proposed to
>> > send a generic patch, but had been traveling lately, and currently in
>> > vacation.
>> >
>> > order-3 pages are problematic when dealing with hostile traffic anyway,
>> > so we should exclusively use order-0 pages, and page recycling like
>> > Intel drivers.
>> >
>> > http://lists.openwall.net/netdev/2016/04/11/88
>>
>> Completely agree. These multi-page tricks work only for benchmarks and
>> not for production.
>> Eric, if you can submit that patch for mlx4 that would be awesome.
>>
>> I think we should default to order-0 for both mlx4 and mlx5.
>> Alternatively we're thinking to do a netlink or ethtool switch to
>> preserve old behavior, but frankly I don't see who needs this order-N
>> allocation schemes.
>
> I actually agree, that we should switch to order-0 allocations.
>
> *BUT* this will cause performance regressions on platforms with
> expensive DMA operations (as they no longer amortize the cost of
> mapping a larger page).

The trick is to use page reuse like we do for the Intel NICs.  If you
can get away with just reusing the page you don't have to keep making
the expensive map/unmap calls.

> Plus, the base cost of order-0 page is 246 cycles (see [1] slide#9),
> and the 10G wirespeed target is approx 201 cycles.  Thus, for these
> speeds some page recycling tricks are needed.  I described how the Intel
> drives does a cool trick in [1] slide#14, but it does not address the
> DMA part and costs some extra atomic ops.

I'm not sure what you mean about it not addressing the DMA part.  Last
I knew we should be just as fast using the page reuse in the Intel
drivers as the Mellanox driver using the 32K page.  The only real
difference in cost is the spot where we are atomically incrementing
the page count since that is the atomic I assume you are referring to.

I had thought about it and amortizing the atomic operation would
probably be pretty straight forward.  All we would have to do is the
same trick we use in the page frag allocator.  We could add a separate
page_count type variable to the Rx buffer info structure and decrement
that instead.  If I am not mistaken that would allow us to drop it
down to only one atomic update of the page count every 64K or so uses
of the page.

> I've started coding on the page-pool last week, which address both the
> DMA mapping and recycling (with less atomic ops). (p.s. still on
> vacation this week).
>
> http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf

I really wonder if we couldn't get away with creating some sort of 2
tiered allocator for this.  So instead of allocating a page pool we
just reserved blocks of memory like we do with huge pages.  Then you
have essentially a huge page that is mapped to a given device for DMA
and reserved for it to use as a memory resource to allocate the order
0 pages out of.  Doing it that way would likely have multiple
advantages when working with things like IOMMU since the pages would
all belong to one linear block so it would likely consume less
resources on those devices, and it wouldn't be that far off from how
DPDK is making use of huge pages in order to improve it's memory
access times and such.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
