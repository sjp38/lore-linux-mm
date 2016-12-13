Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C11E16B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 03:43:51 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id g193so101776156qke.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 00:43:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c36si27713111qtd.119.2016.12.13.00.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 00:43:50 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBD8ctDX057421
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 03:43:50 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27a8126c9d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 03:43:50 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 13 Dec 2016 08:43:47 -0000
Date: Tue, 13 Dec 2016 10:43:38 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx>
 <20161212104042.0a011212@redhat.com>
 <20161212141433.GB19987@rapoport-lnx>
 <20161212161026.0dfd2e13@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212161026.0dfd2e13@redhat.com>
Message-Id: <20161213084337.GE19987@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Fastabend <john.fastabend@gmail.com>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>

On Mon, Dec 12, 2016 at 04:10:26PM +0100, Jesper Dangaard Brouer wrote:
> On Mon, 12 Dec 2016 16:14:33 +0200
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > 
> > They are copied :-)
> > Presuming we are dealing only with vhost backend, the received skb
> > eventually gets converted to IOVs, which in turn are copied to the guest
> > memory. The IOVs point to the guest memory that is allocated by virtio-net
> > running in the guest.
> 
> Thanks for explaining that. It seems like a lot of overhead. I have to
> wrap my head around this... so, the hardware NIC is receiving the
> packet/page, in the RX ring, and after converting it to IOVs, it is
> conceptually transmitted into the guest, and then the guest-side have a
> RX-function to handle this packet. Correctly understood?

Almost :)
For the hardware NIC driver, the receive just follows the "normal" path.
It creates an skb for the packet and passes it to the net core RX. Then the
skb is delivered to tap/macvtap. The later converts the skb to IOVs and
IOVs are pushed to the guest address space.

On the guest side, virtio-net sees these IOVs as a part of its RX ring, it
creates an skb for the packet and passes the skb to the net core of the
guest.

> > I'm not very familiar with XDP eBPF, and it's difficult for me to estimate
> > what needs to be done in BPF program to do proper conversion of skb to the
> > virtio descriptors.
> 
> XDP is a step _before_ the SKB is allocated.  The XDP eBPF program can
> modify the packet-page data, but I don't think it is needed for your
> use-case.  View XDP (primarily) as an early (demux) filter.
> 
> XDP is missing a feature your need, which is TX packet into another
> net_device (I actually imagine a port mapping table, that point to a
> net_device).  This require a new "TX-raw" NDO that takes a page (+
> offset and length). 
> 
> I imagine, the virtio driver (virtio_net or a new driver?) getting
> extended with this new "TX-raw" NDO, that takes "raw" packet-pages.
>  Whether zero-copy is possible is determined by checking if page
> originates from a page_pool that have enabled zero-copy (and likely
> matching against a "protection domain" id number).
 
That could be quite a few drivers that will need to implement "TX-raw" then
:)
In general case, the virtual NIC may be connected to the physical network
via long chain of virtual devices such as bridge, veth and ovs.
Actually, because of that we wanted to concentrate on macvtap...
 
> > We were not considered using XDP yet, so we've decided to limit the initial
> > implementation to macvtap because we can ensure correspondence between a
> > NIC queue and virtual NIC, which is not the case with more generic tap
> > device. It could be that use of XDP will allow for a generic solution for
> > virtio case as well.
> 
> You don't need an XDP filter, if you can make the HW do the early demux
> binding into a queue.  The check for if memory is zero-copy enabled
> would be the same.
> 
> > >   
> > > > Have you considered using "push" model for setting the NIC's RX memory?  
> > > 
> > > I don't understand what you mean by a "push" model?  
> > 
> > Currently, memory allocation in NIC drivers boils down to alloc_page with
> > some wrapping code. I see two possible ways to make NIC use of some
> > preallocated pages: either NIC driver will call an API (probably different
> > from alloc_page) to obtain that memory, or there will be NDO API that
> > allows to set the NIC's RX buffers. I named the later case "push".
> 
> As you might have guessed, I'm not into the "push" model, because this
> means I cannot share the queue with the normal network stack.  Which I
> believe is possible as outlined (in email and [2]) and can be done with
> out HW filter features (like macvlan).

I think I should sleep on it a bit more :)
Probably we can add page_pool "backend" implementation to vhost...

--
Sincerely yours,
Mike. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
