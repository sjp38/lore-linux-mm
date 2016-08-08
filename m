Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D59586B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 14:34:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so607994074pad.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:34:37 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id r11si38120617pag.260.2016.08.08.11.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 11:34:37 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y134so25453786pfg.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:34:36 -0700 (PDT)
Date: Mon, 8 Aug 2016 11:34:30 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: order-0 vs order-N driver allocation. Was: [PATCH v10 07/12]
 net/mlx4_en: add page recycle to prepare rx ring for tx support
Message-ID: <20160808183428.GA87737@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
 <1469432120.8514.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160803174107.GA38399@ast-mbp.thefacebook.com>
 <20160804181913.26ee17b9@redhat.com>
 <1470381333.13693.48.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160808021525.GA81429@ast-mbp>
 <20160808100115.143d6ed3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160808100115.143d6ed3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net, netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>, Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com, hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>, Daniel Borkmann <daniel@iogearbox.net>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Mon, Aug 08, 2016 at 10:01:15AM +0200, Jesper Dangaard Brouer wrote:
> 
> On Sun, 7 Aug 2016 19:15:27 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Fri, Aug 05, 2016 at 09:15:33AM +0200, Eric Dumazet wrote:
> > > On Thu, 2016-08-04 at 18:19 +0200, Jesper Dangaard Brouer wrote:
> > >   
> > > > I actually agree, that we should switch to order-0 allocations.
> > > > 
> > > > *BUT* this will cause performance regressions on platforms with
> > > > expensive DMA operations (as they no longer amortize the cost of
> > > > mapping a larger page).  
> > > 
> > > 
> > > We much prefer reliable behavior, even it it is ~1 % slower than the
> > > super-optimized thing that opens highways for attackers.  
> > 
> > +1
> > It's more important to have deterministic performance at fresh boot
> > and after long uptime when high order-N are gone.
> 
> Yes, exactly. Doing high order-N pages allocations might look good on
> benchmarks on a freshly booted system, but once the page allocator gets
> fragmented (after long uptime) then performance characteristics change.
> (Discussed this with Christoph Lameter during MM-summit, and he have
> seen issues with this kind of fragmentation in production)
> 
> 
> > > Anyway, in most cases pages are re-used, so we only call
> > > dma_sync_single_range_for_cpu(), and there is no way to avoid this.
> > > 
> > > Using order-0 pages [1] is actually faster, since when we use high-order
> > > pages (multiple frames per 'page') we can not reuse the pages.
> > > 
> > > [1] I had a local patch to allocate these pages using a very simple
> > > allocator allocating max order (order-10) pages and splitting them into
> > > order-0 ages, in order to lower TLB footprint. But I could not measure a
> > > gain doing so on x86, at least on my lab machines.  
> > 
> > Which driver was that?
> > I suspect that should indeed be the case for any driver that
> > uses build_skb and <256 copybreak.
> > 
> > Saeed,
> > could you please share the performance numbers for mlx5 order-0 vs order-N ?
> > You mentioned that there was some performance improvement. We need to know
> > how much we'll lose when we turn off order-N.
> 
> I'm not sure the compare will be "fair" with the mlx5 driver, because
> (1) the N-order page mode (MPWQE) is a hardware feature, plus (2) the
> order-0 page mode is done "wrongly" (by preallocating SKBs together
> with RX ring entries).
> 
> AFAIK it is a hardware feature the MPQWE (Multi-Packet Work Queue
> Element) or Striding RQ, for ConnectX4-Lx.  Thus, the need to support
> two modes in the mlx5 driver.
> 
> Commit[1] 461017cb006a ("net/mlx5e: Support RX multi-packet WQE
> (Striding RQ)") states this gives a 10-15% performance improvement for
> netperf TCP stream (and ability to absorb bursty traffic).
> 
>  [1] https://git.kernel.org/torvalds/c/461017cb006

I suspect this 10% perf improvement is due to build_skb approach
instead of mpqwe which works fine with order-0 pages as well.
The request for perf numbers was for mlx5 order-0 vs order-N _with_
build_skb. In other words using MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ
with order-0.
Old mlx5e_handle_rx_cqe should also be converted to build_skb
even when striding_rq is not available in hw, it's a win.

> The MPWQE mode, uses order-5 pages.  The critical question is: what
> happens to the performance when order-5 allocations gets slower (or
> impossible) due to page fragmentation? (Notice the page allocator uses
> a central lock for order-N pages)

it suppose to fallback to order-0. See mlx5e_alloc_rx_fragmented_mpwqe.
which scares me a lot, since I don't see how such logic could have
been stress tested and we'll be hitting it in production.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
