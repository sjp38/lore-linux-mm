Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 38B5C6B025E
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 07:29:16 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id gy3so30496197igb.0
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 04:29:16 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id ug2si7502020igb.56.2016.04.09.04.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 04:29:15 -0700 (PDT)
Received: by mail-ig0-x230.google.com with SMTP id ui10so36597064igc.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 04:29:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160408213414.GA43408@ast-mbp.thefacebook.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<20160408123614.2a15a346@redhat.com>
	<20160408143340.10e5b1d0@redhat.com>
	<20160408172651.GA38264@ast-mbp.thefacebook.com>
	<20160408220808.682630d7@redhat.com>
	<20160408213414.GA43408@ast-mbp.thefacebook.com>
Date: Sat, 9 Apr 2016 08:29:14 -0300
Message-ID: <CALx6S36d74D-8Rx762nmNwb1TF0M0sBfojBhUF96prJiYmDYiQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver filter
From: Tom Herbert <tom@herbertland.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Brenden Blanco <bblanco@plumgrid.com>, "David S. Miller" <davem@davemloft.net>, Linux Kernel Network Developers <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Daniel Borkmann <daniel@iogearbox.net>, Eric Dumazet <eric.dumazet@gmail.com>, Edward Cree <ecree@solarflare.com>, john fastabend <john.fastabend@gmail.com>, Thomas Graf <tgraf@suug.ch>, Johannes Berg <johannes@sipsolutions.net>, eranlinuxmellanox@gmail.com, Lorenzo Colitti <lorenzo@google.com>, linux-mm <linux-mm@kvack.org>

On Fri, Apr 8, 2016 at 6:34 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Apr 08, 2016 at 10:08:08PM +0200, Jesper Dangaard Brouer wrote:
>> On Fri, 8 Apr 2016 10:26:53 -0700
>> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>
>> > On Fri, Apr 08, 2016 at 02:33:40PM +0200, Jesper Dangaard Brouer wrote:
>> > >
>> > > On Fri, 8 Apr 2016 12:36:14 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>> > >
>> > > > > +/* user return codes for PHYS_DEV prog type */
>> > > > > +enum bpf_phys_dev_action {
>> > > > > +     BPF_PHYS_DEV_DROP,
>> > > > > +     BPF_PHYS_DEV_OK,
>> > > > > +};
>> > > >
>> > > > I can imagine these extra return codes:
>> > > >
>> > > >  BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
>> > > >  BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
>> > > >  BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
>> > > >
>> > > > The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
>> > > > which we can look at when we get that far...
>> > >
>> > > I want to point out something which is quite FUNDAMENTAL, for
>> > > understanding these return codes (and network stack).
>> > >
>> > >
>> > > At driver RX time, the network stack basically have two ways of
>> > > building an SKB, which is send up the stack.
>> > >
>> > > Option-A (fastest): The packet page is writable. The SKB can be
>> > > allocated and skb->data/head can point directly to the page.  And
>> > > we place/write skb_shared_info in the end/tail-room. (This is done by
>> > > calling build_skb()).
>> > >
>> > > Option-B (slower): The packet page is read-only.  The SKB cannot point
>> > > skb->data/head directly to the page, because skb_shared_info need to be
>> > > written into skb->end (slightly hidden via skb_shinfo() casting).  To
>> > > get around this, a separate piece of memory is allocated (speedup by
>> > > __alloc_page_frag) for pointing skb->data/head, so skb_shared_info can
>> > > be written. (This is done when calling netdev/napi_alloc_skb()).
>> > >   Drivers then need to copy over packet headers, and assign + adjust
>> > > skb_shinfo(skb)->frags[0] offset to skip copied headers.
>> > >
>> > >
>> > > Unfortunately most drivers use option-B.  Due to cost of calling the
>> > > page allocator.  It is only slightly most expensive to get a larger
>> > > compound page from the page allocator, which then can be partitioned into
>> > > page-fragments, thus amortizing the page alloc cost.  Unfortunately the
>> > > cost is added later, when constructing the SKB.
>> > >  Another reason for option-B, is that archs with expensive IOMMU
>> > > requirements (like PowerPC), don't need to dma_unmap on every packet,
>> > > but only on the compound page level.
>> > >
>> > > Side-note: Most drivers have a "copy-break" optimization.  Especially
>> > > for option-B, when copying header data anyhow. For small packet, one
>> > > might as well free (or recycle) the RX page, if header size fits into
>> > > the newly allocated memory (for skb_shared_info).
>> >
>> > I think you guys are going into overdesign territory, so
>> > . nack on read-only pages
>>
>> Unfortunately you cannot just ignore or nack read-only pages. They are
>> a fact in the current drivers.
>>
>> Most drivers today (at-least the ones we care about) only deliver
>> read-only pages.  If you don't accept read-only pages day-1, then you
>> first have to rewrite a lot of drivers... and that will stall the
>> project!  How will you deal with this fact?
>>
>> The early drop filter use-case in this patchset, can ignore read-only
>> pages.  But ABI wise we need to deal with the future case where we do
>> need/require writeable pages.  A simple need-writable pages in the API
>> could help us move forward.
>
> the program should never need to worry about whether dma buffer is
> writeable or not. Complicating drivers, api, abi, usability
> for the single use case of fast packet drop is not acceptable.
> XDP is not going to be a fit for all drivers and all architectures.
> That is cruicial 'performance vs generality' aspect of the design.
> All kernel-bypasses are taking advantage of specific architecture.
> We have to take advantage of it as well. If it doesn't fit
> powerpc with iommu, so be it. XDP will return -enotsupp.
> That is fundamental point. We have to cut such corners and avoid
> all cases where unnecessary generality hurts performance.
> Read-only pages is clearly such thing.
>
+1. Forwarding which will be a common application almost always
requires modification (decrement TTL), and header data split has
always been a weak feature since the device has to have some arbitrary
rules about what headers needs to be split out (either implements
protocol specific parsing or some fixed length).

>> > The whole thing must be dead simple to use. Above is not simple by any means.
>>
>> Maybe you missed that the above was a description of how the current
>> network stack handles this, which is not simple... which is root of the
>> hole performance issue.
>
> Disagree. The stack has copy-break, gro, gso and everything else because
> it's serving _host_ use case. XDP is packet forwarder use case.
> The requirements are completely different. Ex. the host needs gso
> in the core and drivers. It needs to deliver data all the way
> to user space and back. That is hard and that's where complexity
> comes from. For packet forwarder none of it is needed. So saying,
> look we have this complexity, so XDP needs it too, is flawed argument.
> The kernel is serving host and applications.
> XDP is pure packet-in/packet-out framework to achieve better
> performance than kernel-bypass, since kernel is the right
> place to do it. It has clean access to interrupts, per-cpu,
> scheduler, device registers and so on.
> Though there are only two broad use cases packet drop and forward,
> they cover a ton of real cases: firewalls, dos prevention,
> load balancer, nat, etc. In other words mostly stateless.
> As soon as packet needs to be queued somewhere we have to
> instantiate skb and pass it to the stack.
> So no queues in XDP and no 'stolen' and 'shared' return codes.
> The program always runs to completion with single packet.
> There is no header vs payload split. There is no header
> from program point of view. It's raw bytes in dma buffer.
>
Exactly. We are rethinking the low level data path for performance. An
all encompassing solution that covers ever existing driver model only
results in complexity which is what makes things "slow" in the first
place. Drivers need to change to implement XDP, but the model is as
simple as we can make it-- for instance we are putting very little
requirements on device features.

Tom


>> I do like the idea of rejecting XDP eBPF programs based on the DMA
>> setup is not compatible, or if the driver does not implement e.g.
>> writable DMA pages.
>
> exactly.
>
>> Customers wanting this feature will then go buy the NIC which support
>> this feature.  There is nothing more motivating for NIC vendors seeing
>> customers buying the competitors hardware. And it only require a driver
>> change to get this market...
>
> exactly.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
