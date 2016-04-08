Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7D26B0253
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 12:12:28 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id gy3so16711869igb.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 09:12:28 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id l79si5641751ioe.190.2016.04.08.09.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 09:12:27 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id 2so137377227ioy.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 09:12:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160407223853.6f4c7dbd@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<1460058531.13579.12.camel@netapp.com>
	<20160407223853.6f4c7dbd@redhat.com>
Date: Fri, 8 Apr 2016 09:12:26 -0700
Message-ID: <CAKgT0UdaTbwvA+Q2t-yri1HqHzMdfMecL3Dqf1MMq39kF96ZKQ@mail.gmail.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Alexander Duyck <alexander.duyck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com>, "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bblanco@plumgrid.com" <bblanco@plumgrid.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@hansenpartnership.com>, "tom@herbertland.com" <tom@herbertland.com>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Thu, Apr 7, 2016 at 1:38 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Thu, 7 Apr 2016 19:48:50 +0000
> "Waskiewicz, PJ" <PJ.Waskiewicz@netapp.com> wrote:
>
>> On Thu, 2016-04-07 at 16:17 +0200, Jesper Dangaard Brouer wrote:
>> > (Topic proposal for MM-summit)
>> >
>> > Network Interface Cards (NIC) drivers, and increasing speeds stress
>> > the page-allocator (and DMA APIs).  A number of driver specific
>> > open-coded approaches exists that work-around these bottlenecks in
>> > the
>> > page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
>> > allocating larger pages and handing-out page "fragments".
>> >
>> > I'm proposing a generic page-pool recycle facility, that can cover
>> > the
>> > driver use-cases, increase performance and open up for zero-copy RX.
>>
>> Is this based on the page recycle stuff from ixgbe that used to be in
>> the driver?  If so I'd really like to be part of the discussion.
>
> Okay, so it is not part of the driver any-longer?  I've studied the
> current ixgbe driver (and other NIC drivers) closely.  Do you have some
> code pointers, to this older code?

No, it is still in the driver.  I think when PJ said "used to" he was
referring to the fact that the code was present in the driver back
when he was working on it at Intel.

You have to realize that the page reuse code has been in the Intel
drivers for a long time.  I think I introduced it originally on igb in
July of 2008 as page recycling, commit bf36c1a0040c ("igb: add page
recycling support"), and it was copied over to ixgbe in September,
commit 762f4c571058 ("ixgbe: recycle pages in packet split mode").

> The likely-fastest recycle code I've see is in the bnx2x driver.  If
> you are interested see: bnx2x_reuse_rx_data().  Again is it a bit
> open-coded produce/consumer ring queue (which would be nice to also
> cleanup).

Yeah, that is essentially the same kind of code we have in
ixgbe_reuse_rx_page().  From what I can tell though the bnx2x doesn't
actually reuse the buffers in the common case.  That function is only
called in the copy-break and error cases to recycle the buffer so that
it doesn't have to be freed.

> To amortize the cost of allocating a single page, most other drivers
> use the trick of allocating a larger (compound) page, and partition
> this page into smaller "fragments".  Which also amortize the cost of
> dma_map/unmap (important on non-x86).

Right.  The only reason why I went the reuse route instead of the
compound page route is that I had speculated that you could still
bottleneck yourself since the issue I was trying to avoid was the
dma_map call hitting a global lock in IOMMU enabled systems.  With the
larger page route I could at best reduce the number of map calls to
1/16 or 1/32 of what it was.  By doing the page reuse I actually bring
it down to something approaching 0 as long as the buffers are being
freed in a reasonable timeframe.  This way the code would scale so I
wouldn't have to worry about how many rings were active at the same
time.

As PJ can attest we even saw bugs where the page reuse actually was
too effective in some cases leading to us carrying memory from one
node to another when the interrupt was migrated.  That was why we had
to add the code to force us to free the page if it came from another
node.

> This is actually problematic performance wise, because packet-data
> (in these page fragments) only get DMA_sync'ed, and is thus considered
> "read-only".  As netstack need to write packet headers, yet-another
> (writable) memory area is allocated per packet (plus the SKB meta-data
> struct).

Have you done any actual testing with build_skb recently that shows
how much of a gain there is to be had?  I'm just curious as I know I
saw a gain back in the day, but back when I ran that test we didn't
have things like napi_alloc_skb running around which should be a
pretty big win.  It might be useful to hack a driver such as ixgbe to
use build_skb and see if it is even worth the trouble to do it
properly.

Here is a patch I had generated back in 2013 to convert ixgbe over to
using build_skb, https://patchwork.ozlabs.org/patch/236044/.  You
might be able to updated to make it work against current ixgbe and
then could come back to us with data on what the actual gain is.  My
thought is the gain should have significantly decreased since back in
the day as we optimized napi_alloc_skb to the point where I think the
only real difference is probably the memcpy to pull the headers from
the page.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
