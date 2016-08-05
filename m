Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 533BD6B0262
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:22:12 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so68354095ith.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:15:28 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id w73si9176894itw.123.2016.08.05.08.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 08:15:27 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id j124so1881167ith.3
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:15:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160805035534.GA56390@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com> <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com> <20160804181913.26ee17b9@redhat.com>
 <CAKgT0UdbVK6Ti9drCQFfa0MyU40Kh=Hu=BtDTRCqqsSiBvJ7rg@mail.gmail.com> <20160805035534.GA56390@ast-mbp.thefacebook.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 5 Aug 2016 08:15:25 -0700
Message-ID: <CAKgT0Uc0=10xhcJJ+55rBv=YNPgPLmHb8x82CKbj+N895JQY5Q@mail.gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john fastabend <john.fastabend@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu, Aug 4, 2016 at 8:55 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Aug 04, 2016 at 05:30:56PM -0700, Alexander Duyck wrote:
>> On Thu, Aug 4, 2016 at 9:19 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> >
>> > On Wed, 3 Aug 2016 10:45:13 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>> >
>> >> On Mon, Jul 25, 2016 at 09:35:20AM +0200, Eric Dumazet wrote:
>> >> > On Tue, 2016-07-19 at 12:16 -0700, Brenden Blanco wrote:
>> >> > > The mlx4 driver by default allocates order-3 pages for the ring to
>> >> > > consume in multiple fragments. When the device has an xdp program, this
>> >> > > behavior will prevent tx actions since the page must be re-mapped in
>> >> > > TODEVICE mode, which cannot be done if the page is still shared.
>> >> > >
>> >> > > Start by making the allocator configurable based on whether xdp is
>> >> > > running, such that order-0 pages are always used and never shared.
>> >> > >
>> >> > > Since this will stress the page allocator, add a simple page cache to
>> >> > > each rx ring. Pages in the cache are left dma-mapped, and in drop-only
>> >> > > stress tests the page allocator is eliminated from the perf report.
>> >> > >
>> >> > > Note that setting an xdp program will now require the rings to be
>> >> > > reconfigured.
>> >> >
>> >> > Again, this has nothing to do with XDP ?
>> >> >
>> >> > Please submit a separate patch, switching this driver to order-0
>> >> > allocations.
>> >> >
>> >> > I mentioned this order-3 vs order-0 issue earlier [1], and proposed to
>> >> > send a generic patch, but had been traveling lately, and currently in
>> >> > vacation.
>> >> >
>> >> > order-3 pages are problematic when dealing with hostile traffic anyway,
>> >> > so we should exclusively use order-0 pages, and page recycling like
>> >> > Intel drivers.
>> >> >
>> >> > http://lists.openwall.net/netdev/2016/04/11/88
>> >>
>> >> Completely agree. These multi-page tricks work only for benchmarks and
>> >> not for production.
>> >> Eric, if you can submit that patch for mlx4 that would be awesome.
>> >>
>> >> I think we should default to order-0 for both mlx4 and mlx5.
>> >> Alternatively we're thinking to do a netlink or ethtool switch to
>> >> preserve old behavior, but frankly I don't see who needs this order-N
>> >> allocation schemes.
>> >
>> > I actually agree, that we should switch to order-0 allocations.
>> >
>> > *BUT* this will cause performance regressions on platforms with
>> > expensive DMA operations (as they no longer amortize the cost of
>> > mapping a larger page).
>
> order-0 is mainly about correctness under memory pressure.
> As Eric pointed out order-N is a serious issue for hostile traffic,
> but even for normal traffic it's a problem. Sooner or later
> only order-0 pages will be available.
> Performance considerations come second.
>
>> The trick is to use page reuse like we do for the Intel NICs.  If you
>> can get away with just reusing the page you don't have to keep making
>> the expensive map/unmap calls.
>
> you mean two packet per page trick?
> I think it's trading off performance vs memory.
> It's useful. I wish there was a knob to turn it on/off instead
> of relying on mtu size threshold.

The MTU size doesn't really play a role in the Intel drivers in
regards to page reuse anymore.  We pretty much are just treating the
page as a pair of 2K buffers.  It does have some disadvantages in that
we cannot pack the frames as tight in the case of jumbo frames with
GRO, but at the same time jumbo frames are just not that common.

>> > I've started coding on the page-pool last week, which address both the
>> > DMA mapping and recycling (with less atomic ops). (p.s. still on
>> > vacation this week).
>> >
>> > http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf
>>
>> I really wonder if we couldn't get away with creating some sort of 2
>> tiered allocator for this.  So instead of allocating a page pool we
>> just reserved blocks of memory like we do with huge pages.  Then you
>> have essentially a huge page that is mapped to a given device for DMA
>> and reserved for it to use as a memory resource to allocate the order
>> 0 pages out of.  Doing it that way would likely have multiple
>> advantages when working with things like IOMMU since the pages would
>> all belong to one linear block so it would likely consume less
>> resources on those devices, and it wouldn't be that far off from how
>> DPDK is making use of huge pages in order to improve it's memory
>> access times and such.
>
> interesting idea. Like dma_map 1GB region and then allocate
> pages from it only? but the rest of the kernel won't be able
> to use them? so only some smaller region then? or it will be
> a boot time flag to reserve this pseudo-huge page?

Yeah, something like that.  If we were already talking about
allocating a pool of pages it might make sense to just setup something
like this where you could reserve a 1GB region for a single 10G device
for instance.  Then it would make the whole thing much easier to deal
with since you would have a block of memory that should perform very
well in terms of DMA accesses.

> I don't think any of that is needed for XDP. As demonstrated by current
> mlx4 it's very fast already. No bottlenecks in page allocators.
> Tiny page recycle array does the magic because most of the traffic
> is not going to the stack.

Agreed.  If you aren't handing the frames up we don't really don't
even have to bother.  In the Intel drivers for instance if the frame
size is less than 256 bytes we just copy the whole thing out since it
is cheaper to just extend the header copy rather than taking the extra
hit for get_page/put_page.

> This order-0 vs order-N discussion is for the main stack.
> Not related to XDP.

Agreed.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
