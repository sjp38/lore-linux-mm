Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2456C6B03C8
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:06:28 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v85so203752068oia.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:06:28 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id r125si1769638itg.4.2017.02.14.11.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:06:26 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id r141so6596393ita.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:06:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170214194615.3feddd07@redhat.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <20170214131206.44b644f6@redhat.com> <CANn89i+udp6Y42D9wqmz7U6LGn1mtDRXpQGHAOAeX25eD0dGnQ@mail.gmail.com>
 <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com> <CAKgT0UdRmpV_n1wstTHvqCgyRtze8z1rTJ5pKc_jdRttQCSySw@mail.gmail.com>
 <20170214194615.3feddd07@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 14 Feb 2017 11:06:25 -0800
Message-ID: <CAKgT0Uc2YrAzXC7LofaxC2NWi1kL=Fd5Nkgv60dMwrjn4d=ROQ@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <ttoukan.linux@gmail.com>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>, Martin KaFai Lau <kafai@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Willem de Bruijn <willemb@google.com>, Brenden Blanco <bblanco@plumgrid.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm <linux-mm@kvack.org>, John Fastabend <john.r.fastabend@intel.com>

On Tue, Feb 14, 2017 at 10:46 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Tue, 14 Feb 2017 09:29:54 -0800
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Tue, Feb 14, 2017 at 6:56 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>> >
>> >
>> > On 14/02/2017 3:45 PM, Eric Dumazet wrote:
>> >>
>> >> On Tue, Feb 14, 2017 at 4:12 AM, Jesper Dangaard Brouer
>> >> <brouer@redhat.com> wrote:
>> >>
>> >>> It is important to understand that there are two cases for the cost of
>> >>> an atomic op, which depend on the cache-coherency state of the
>> >>> cacheline.
>> >>>
>> >>> Measured on Skylake CPU i7-6700K CPU @ 4.00GHz
>> >>>
>> >>> (1) Local CPU atomic op :  27 cycles(tsc)  6.776 ns
>> >>> (2) Remote CPU atomic op: 260 cycles(tsc) 64.964 ns
>> >>>
>> >> Okay, it seems you guys really want a patch that I said was not giving
>> >> good results
>> >>
>> >> Let me publish the numbers I get , adding or not the last (and not
>> >> official) patch.
>> >>
>> >> If I _force_ the user space process to run on the other node,
>> >> then the results are not the ones Alex or you are expecting.
>> >>
>> >> I have with this patch about 2.7 Mpps of this silly single TCP flow,
>> >> and 3.5 Mpps without it.
>> >>
>> >> lpaa24:~# sar -n DEV 1 10 | grep eth0 | grep Ave
>> >> Average:         eth0 2699243.20  16663.70 1354783.36   1079.95
>> >> 0.00      0.00      4.50
>> >>
>> >> Profile of the cpu on NUMA node 1 ( netserver consuming data ) :
>> >>
>> >>      54.73%  [kernel]      [k] copy_user_enhanced_fast_string
>> >>      31.07%  [kernel]      [k] skb_release_data
>> >>       4.24%  [kernel]      [k] skb_copy_datagram_iter
>> >>       1.35%  [kernel]      [k] copy_page_to_iter
>> >>       0.98%  [kernel]      [k] _raw_spin_lock
>> >>       0.90%  [kernel]      [k] skb_release_head_state
>> >>       0.60%  [kernel]      [k] tcp_transmit_skb
>> >>       0.51%  [kernel]      [k] mlx4_en_xmit
>> >>       0.33%  [kernel]      [k] ___cache_free
>> >>       0.28%  [kernel]      [k] tcp_rcv_established
>> >>
>> >> Profile of cpu handling mlx4 softirqs (NUMA node 0)
>> >>
>> >>
>> >>      48.00%  [kernel]          [k] mlx4_en_process_rx_cq
>> >>      12.92%  [kernel]          [k] napi_gro_frags
>> >>       7.28%  [kernel]          [k] inet_gro_receive
>> >>       7.17%  [kernel]          [k] tcp_gro_receive
>> >>       5.10%  [kernel]          [k] dev_gro_receive
>> >>       4.87%  [kernel]          [k] skb_gro_receive
>> >>       2.45%  [kernel]          [k] mlx4_en_prepare_rx_desc
>> >>       2.04%  [kernel]          [k] __build_skb
>> >>       1.02%  [kernel]          [k] napi_reuse_skb.isra.95
>> >>       1.01%  [kernel]          [k] tcp4_gro_receive
>> >>       0.65%  [kernel]          [k] kmem_cache_alloc
>> >>       0.45%  [kernel]          [k] _raw_spin_lock
>> >>
>> >> Without the latest  patch (the exact patch series v3 I submitted),
>> >> thus with this atomic_inc() in mlx4_en_process_rx_cq  instead of only
>> >> reads.
>> >>
>> >> lpaa24:~# sar -n DEV 1 10|grep eth0|grep Ave
>> >> Average:         eth0 3566768.50  25638.60 1790345.69   1663.51
>> >> 0.00      0.00      4.50
>> >>
>> >> Profiles of the two cpus :
>> >>
>> >>      74.85%  [kernel]      [k] copy_user_enhanced_fast_string
>> >>       6.42%  [kernel]      [k] skb_release_data
>> >>       5.65%  [kernel]      [k] skb_copy_datagram_iter
>> >>       1.83%  [kernel]      [k] copy_page_to_iter
>> >>       1.59%  [kernel]      [k] _raw_spin_lock
>> >>       1.48%  [kernel]      [k] skb_release_head_state
>> >>       0.72%  [kernel]      [k] tcp_transmit_skb
>> >>       0.68%  [kernel]      [k] mlx4_en_xmit
>> >>       0.43%  [kernel]      [k] page_frag_free
>> >>       0.38%  [kernel]      [k] ___cache_free
>> >>       0.37%  [kernel]      [k] tcp_established_options
>> >>       0.37%  [kernel]      [k] __ip_local_out
>> >>
>> >>
>> >>     37.98%  [kernel]          [k] mlx4_en_process_rx_cq
>> >>      26.47%  [kernel]          [k] napi_gro_frags
>> >>       7.02%  [kernel]          [k] inet_gro_receive
>> >>       5.89%  [kernel]          [k] tcp_gro_receive
>> >>       5.17%  [kernel]          [k] dev_gro_receive
>> >>       4.80%  [kernel]          [k] skb_gro_receive
>> >>       2.61%  [kernel]          [k] __build_skb
>> >>       2.45%  [kernel]          [k] mlx4_en_prepare_rx_desc
>> >>       1.59%  [kernel]          [k] napi_reuse_skb.isra.95
>> >>       0.95%  [kernel]          [k] tcp4_gro_receive
>> >>       0.51%  [kernel]          [k] kmem_cache_alloc
>> >>       0.42%  [kernel]          [k] __inet_lookup_established
>> >>       0.34%  [kernel]          [k] swiotlb_sync_single_for_cpu
>> >>
>> >>
>> >> So probably this will need further analysis, outside of the scope of
>> >> this patch series.
>> >>
>> >> Could we now please Ack this v3 and merge it ?
>> >>
>> >> Thanks.
>> >
>> > Thanks Eric.
>> >
>> > As the previous series caused hangs, we must run functional regression tests
>> > over this series as well.
>> > Run has already started, and results will be available tomorrow morning.
>> >
>> > In general, I really like this series. The re-factorization looks more
>> > elegant and more correct, functionally.
>> >
>> > However, performance wise: we fear that the numbers will be drastically
>> > lower with this transition to order-0 pages,
>> > because of the (becoming critical) page allocator and dma operations
>> > bottlenecks, especially on systems with costly
>> > dma operations, such as ARM, iommu=on, etc...
>>
>> So to give you an idea I originally came up with the approach used in
>> the Intel drivers when I was dealing with a PowerPC system where the
>> IOMMU was a requirement.  With this setup correctly the map/unmap
>> calls should be almost non-existent.  Basically the only time we
>> should have to allocate or free a page is if something is sitting on
>> the pages for an excessively long time or if the interrupt is bouncing
>> between memory nodes which forces us to free the memory since it is
>> sitting on the wrong node.
>>
>> > We already have this exact issue in mlx5, where we moved to order-0
>> > allocations with a fixed size cache, but that was not enough.
>> > Customers of mlx5 have already complained about the performance degradation,
>> > and currently this is hurting our business.
>> > We get a clear nack from our performance regression team regarding doing the
>> > same in mlx4.
>>
>> What form of recycling were you doing?  If you were doing the offset
>> based setup then that obviously only gets you so much.  The advantage
>> to using the page count is that you get almost a mobius strip effect
>> for your buffers and descriptor rings where you just keep flipping the
>> page offset back and forth via an XOR and the only cost is
>> dma_sync_for_cpu, get_page, dma_sync_for_device instead of having to
>> do the full allocation, mapping, and unmapping.
>>
>> > So, the question is, can we live with this degradation until those
>> > bottleneck challenges are addressed?
>> > Following our perf experts feedback, I cannot just simply Ack. We need to
>> > have a clear plan to close the perf gap or reduce the impact.
>>
>> I think we need to define what is the degradation you are expecting to
>> see.  Using the page count based approach should actually be better in
>> some cases than the order 3 page and just walking frags approach since
>> the theoretical reuse is infinite instead of fixed.
>>
>> > Internally, I already implemented "dynamic page-cache" and "page-reuse"
>> > mechanisms in the driver,
>> > and together they totally bridge the performance gap.
>> > That's why I would like to hear from Jesper what is the status of his
>> > page_pool API, it is promising and could totally solve these issues.
>> >
>> > Regards,
>> > Tariq
>>
>> The page pool may provide gains but we have to actually see it before
>> we can guarantee it.  If worse comes to worse I might just resort to
>> standardizing the logic used for the Intel driver page count based
>> approach.  Then if nothing else we would have a standard path for all
>> the drivers to use if we start going down this route.
>
> With this Intel driver page count based recycle approach, the recycle
> size is tied to the size of the RX ring.  As Eric and Tariq discovered.
> And for other performance reasons (memory footprint of walking RX ring
> data-structures), don't want to increase the RX ring sizes.  Thus, it
> create two opposite performance needs.  That is why I think a more
> explicit approach with a pool is more attractive.
>
> How is this approach doing to work for XDP?
> (XDP doesn't "share" the page, and in-general we don't want the extra
> atomic.)

The extra atomic is moot since it is we can get rid of that by doing
bulk page count updates.

Why can't XDP share a page?  You have brought up the user space aspect
of things repeatedly but the AF_PACKET patches John did more or less
demonstrated that wasn't the case.  What you end up with is you have
to either be providing pure user space pages or pure kernel pages.
You can't have pages being swapped between the two without introducing
security issues.  So even with your pool approach it doesn't matter
which way things are run.  Your pool is either device to user space,
or device to kernel space and it can't be both without creating
sharing concerns.

> We absolutely need recycling with XDP, when transmitting out another
> device, and the other devices DMA-TX completion need some way of
> returning this page.

I fully agree here.  However the easiest way of handling this is via
the page count in my opinion.

> What is basically needed is a standardized callback to allow the remote
> driver to return the page to the originating driver.  As we don't have
> a NDP for XDP-forward/transmit yet, we could pass this callback as a
> parameter along with the packet-page to send?

No.  This assumes way too much.  Most packets aren't going to be
device to device routing.  We have seen this type of thing and
rejected it multiple times.  Don't think driver to driver.  This is
driver to network stack, socket, device, virtual machine, storage,
etc.  The fact is there are many spots where a frame might get
terminated.  This is why the bulk alloc/free of skbs never went
anywhere.  We never really addressed the fact that there are many more
spots where a frame is terminated.

This is why I said before what we need to do is have a page destructor
to handle this sort of thing.  The idea is you want to have this work
everywhere.  Having just drivers do this would make it a nice toy but
completely useless since not too many people are doing
routing/bridging between interfaces.  Using the page destructor it is
easy to create a pool of "free" pages that you can then pull your DMA
pages out of or that you can release back into the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
