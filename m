Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C1E936B025F
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 13:26:59 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id td3so78268356pab.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 10:26:59 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id oq6si1892680pab.84.2016.04.08.10.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 10:26:58 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id 184so79733802pff.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 10:26:58 -0700 (PDT)
Date: Fri, 8 Apr 2016 10:26:53 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Message-ID: <20160408172651.GA38264@ast-mbp.thefacebook.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com>
 <20160408143340.10e5b1d0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160408143340.10e5b1d0@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com, ogerlitz@mellanox.com, daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net, eranlinuxmellanox@gmail.com, lorenzo@google.com, linux-mm <linux-mm@kvack.org>

On Fri, Apr 08, 2016 at 02:33:40PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Fri, 8 Apr 2016 12:36:14 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > > +/* user return codes for PHYS_DEV prog type */
> > > +enum bpf_phys_dev_action {
> > > +	BPF_PHYS_DEV_DROP,
> > > +	BPF_PHYS_DEV_OK,
> > > +};  
> > 
> > I can imagine these extra return codes:
> > 
> >  BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
> >  BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
> >  BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
> > 
> > The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
> > which we can look at when we get that far...
> 
> I want to point out something which is quite FUNDAMENTAL, for
> understanding these return codes (and network stack).
> 
> 
> At driver RX time, the network stack basically have two ways of
> building an SKB, which is send up the stack.
> 
> Option-A (fastest): The packet page is writable. The SKB can be
> allocated and skb->data/head can point directly to the page.  And
> we place/write skb_shared_info in the end/tail-room. (This is done by
> calling build_skb()).
> 
> Option-B (slower): The packet page is read-only.  The SKB cannot point
> skb->data/head directly to the page, because skb_shared_info need to be
> written into skb->end (slightly hidden via skb_shinfo() casting).  To
> get around this, a separate piece of memory is allocated (speedup by
> __alloc_page_frag) for pointing skb->data/head, so skb_shared_info can
> be written. (This is done when calling netdev/napi_alloc_skb()).
>   Drivers then need to copy over packet headers, and assign + adjust
> skb_shinfo(skb)->frags[0] offset to skip copied headers.
> 
> 
> Unfortunately most drivers use option-B.  Due to cost of calling the
> page allocator.  It is only slightly most expensive to get a larger
> compound page from the page allocator, which then can be partitioned into
> page-fragments, thus amortizing the page alloc cost.  Unfortunately the
> cost is added later, when constructing the SKB.
>  Another reason for option-B, is that archs with expensive IOMMU
> requirements (like PowerPC), don't need to dma_unmap on every packet,
> but only on the compound page level.
> 
> Side-note: Most drivers have a "copy-break" optimization.  Especially
> for option-B, when copying header data anyhow. For small packet, one
> might as well free (or recycle) the RX page, if header size fits into
> the newly allocated memory (for skb_shared_info).

I think you guys are going into overdesign territory, so
. nack on read-only pages
. nack on copy-break approach
. nack on per-ring programs
. nack on modified/stolen/shared return codes

The whole thing must be dead simple to use. Above is not simple by any means.
The programs must see writeable pages only and return codes:
drop, pass to stack, redirect to xmit.
If program wishes to modify packets before passing it to stack, it
shouldn't need to deal with different return values.
No special things to deal with small or large packets. No header splits.
Program must not be aware of any such things.
Drivers can use DMA_BIDIRECTIONAL to allow received page to be
modified by the program and immediately sent to xmit. 
No dma map/unmap/sync per packet. If some odd architectures/dma setups
cannot do it, then XDP will not be applicable there.
We are not going to sacrifice performance for generality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
