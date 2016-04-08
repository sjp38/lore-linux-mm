Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id A48FE6B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 08:33:50 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id f105so64967580qge.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 05:33:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si9659627qgp.51.2016.04.08.05.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 05:33:49 -0700 (PDT)
Date: Fri, 8 Apr 2016 14:33:40 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Message-ID: <20160408143340.10e5b1d0@redhat.com>
In-Reply-To: <20160408123614.2a15a346@redhat.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
	<20160408123614.2a15a346@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brenden Blanco <bblanco@plumgrid.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com, alexei.starovoitov@gmail.com, ogerlitz@mellanox.com, daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net, eranlinuxmellanox@gmail.com, lorenzo@google.com, brouer@redhat.com, linux-mm <linux-mm@kvack.org>


On Fri, 8 Apr 2016 12:36:14 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > +/* user return codes for PHYS_DEV prog type */
> > +enum bpf_phys_dev_action {
> > +	BPF_PHYS_DEV_DROP,
> > +	BPF_PHYS_DEV_OK,
> > +};  
> 
> I can imagine these extra return codes:
> 
>  BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
>  BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
>  BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
> 
> The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
> which we can look at when we get that far...

I want to point out something which is quite FUNDAMENTAL, for
understanding these return codes (and network stack).


At driver RX time, the network stack basically have two ways of
building an SKB, which is send up the stack.

Option-A (fastest): The packet page is writable. The SKB can be
allocated and skb->data/head can point directly to the page.  And
we place/write skb_shared_info in the end/tail-room. (This is done by
calling build_skb()).

Option-B (slower): The packet page is read-only.  The SKB cannot point
skb->data/head directly to the page, because skb_shared_info need to be
written into skb->end (slightly hidden via skb_shinfo() casting).  To
get around this, a separate piece of memory is allocated (speedup by
__alloc_page_frag) for pointing skb->data/head, so skb_shared_info can
be written. (This is done when calling netdev/napi_alloc_skb()).
  Drivers then need to copy over packet headers, and assign + adjust
skb_shinfo(skb)->frags[0] offset to skip copied headers.


Unfortunately most drivers use option-B.  Due to cost of calling the
page allocator.  It is only slightly most expensive to get a larger
compound page from the page allocator, which then can be partitioned into
page-fragments, thus amortizing the page alloc cost.  Unfortunately the
cost is added later, when constructing the SKB.
 Another reason for option-B, is that archs with expensive IOMMU
requirements (like PowerPC), don't need to dma_unmap on every packet,
but only on the compound page level.

Side-note: Most drivers have a "copy-break" optimization.  Especially
for option-B, when copying header data anyhow. For small packet, one
might as well free (or recycle) the RX page, if header size fits into
the newly allocated memory (for skb_shared_info).


For the early filter drop (DDoS use-case), it does not matter that the
packet-page is read-only.

BUT for the future XDP (eXpress Data Path) use-case it does matter.  If
we ever want to see speeds comparable to DPDK, then drivers to
need to implement option-A, as this allow forwarding at the packet-page
level.

I hope, my future page-pool facility can remove/hide the cost calling
the page allocator.


Back to the return codes, thus:
-------------------------------
BPF_PHYS_DEV_SHARED requires driver use option-B, when constructing
the SKB, and treat packet data as read-only.

BPF_PHYS_DEV_MODIFIED requires driver to provide a writable packet-page.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
