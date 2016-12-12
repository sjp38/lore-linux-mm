Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id E446D6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 12:13:53 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id w194so39965740vkw.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 09:13:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s207si11381822vke.1.2016.12.12.09.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 09:13:52 -0800 (PST)
Date: Mon, 12 Dec 2016 18:13:44 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161212181344.3ddfa9c3@redhat.com>
In-Reply-To: <584EB8DF.8000308@gmail.com>
References: <20161205153132.283fcb0e@redhat.com>
	<20161212083812.GA19987@rapoport-lnx>
	<20161212104042.0a011212@redhat.com>
	<20161212141433.GB19987@rapoport-lnx>
	<584EB8DF.8000308@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Fastabend <john.fastabend@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, Vladislav Yasevich <vyasevich@gmail.com>, brouer@redhat.com

On Mon, 12 Dec 2016 06:49:03 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-12-12 06:14 AM, Mike Rapoport wrote:
> > On Mon, Dec 12, 2016 at 10:40:42AM +0100, Jesper Dangaard Brouer wrote:  
> >>
> >> On Mon, 12 Dec 2016 10:38:13 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >>  
> >>> Hello Jesper,
> >>>
> >>> On Mon, Dec 05, 2016 at 03:31:32PM +0100, Jesper Dangaard Brouer wrote:  
> >>>> Hi all,
> >>>>
> >>>> This is my design for how to safely handle RX zero-copy in the network
> >>>> stack, by using page_pool[1] and modifying NIC drivers.  Safely means
> >>>> not leaking kernel info in pages mapped to userspace and resilience
> >>>> so a malicious userspace app cannot crash the kernel.
> >>>>
> >>>> Design target
> >>>> =============
> >>>>
> >>>> Allow the NIC to function as a normal Linux NIC and be shared in a
> >>>> safe manor, between the kernel network stack and an accelerated
> >>>> userspace application using RX zero-copy delivery.
> >>>>
> >>>> Target is to provide the basis for building RX zero-copy solutions in
> >>>> a memory safe manor.  An efficient communication channel for userspace
> >>>> delivery is out of scope for this document, but OOM considerations are
> >>>> discussed below (`Userspace delivery and OOM`_).    
> >>>
> >>> Sorry, if this reply is a bit off-topic.  
> >>
> >> It is very much on topic IMHO :-)
> >>  
> >>> I'm working on implementation of RX zero-copy for virtio and I've dedicated
> >>> some thought about making guest memory available for physical NIC DMAs.
> >>> I believe this is quite related to your page_pool proposal, at least from
> >>> the NIC driver perspective, so I'd like to share some thoughts here.  
> >>
> >> Seems quite related. I'm very interested in cooperating with you! I'm
> >> not very familiar with virtio, and how packets/pages gets channeled
> >> into virtio.  
> > 
> > They are copied :-)
> > Presuming we are dealing only with vhost backend, the received skb
> > eventually gets converted to IOVs, which in turn are copied to the guest
> > memory. The IOVs point to the guest memory that is allocated by virtio-net
> > running in the guest.
> >   
> 
> Great I'm also doing something similar.
> 
> My plan was to embed the zero copy as an AF_PACKET mode and then push
> a AF_PACKET backend into vhost. I'll post a patch later this week.
> 
> >>> The idea is to dedicate one (or more) of the NIC's queues to a VM, e.g.
> >>> using macvtap, and then propagate guest RX memory allocations to the NIC
> >>> using something like new .ndo_set_rx_buffers method.  
> >>
> >> I believe the page_pool API/design aligns with this idea/use-case.
> >>  
> >>> What is your view about interface between the page_pool and the NIC
> >>> drivers?  
> >>
> >> In my Prove-of-Concept implementation, the NIC driver (mlx5) register
> >> a page_pool per RX queue.  This is done for two reasons (1) performance
> >> and (2) for supporting use-cases where only one single RX-ring queue is
> >> (re)configured to support RX-zero-copy.  There are some associated
> >> extra cost of enabling this mode, thus it makes sense to only enable it
> >> when needed.
> >>
> >> I've not decided how this gets enabled, maybe some new driver NDO.  It
> >> could also happen when a XDP program gets loaded, which request this
> >> feature.
> >>
> >> The macvtap solution is nice and we should support it, but it requires
> >> VM to have their MAC-addr registered on the physical switch.  This
> >> design is about adding flexibility. Registering an XDP eBPF filter
> >> provides the maximum flexibility for matching the destination VM.  
> > 
> > I'm not very familiar with XDP eBPF, and it's difficult for me to estimate
> > what needs to be done in BPF program to do proper conversion of skb to the
> > virtio descriptors.  
> 
> I don't think XDP has much to do with this code and they should be done
> separately. XDP runs eBPF code on received packets after the DMA engine
> has already placed the packet in memory so its too late in the process.

It does not have to be connected to XDP.  My idea should support RX
zero-copy into normal sockets, without XDP.

My idea was to pre-VMA map the RX ring, when zero-copy is requested,
thus it is not too late in the process.  When frame travel the normal
network stack, then require the SKB-read-only-page mode (skb-frags).
If the SKB reach a socket that support zero-copy, then we can do RX
zero-copy on normal sockets.

 
> The other piece here is enabling XDP in vhost but that is again separate
> IMO.
> 
> Notice that ixgbe supports pushing packets into a macvlan via 'tc'
> traffic steering commands so even though macvlan gets an L2 address it
> doesn't mean it can't use other criteria to steer traffic to it.

This sounds interesting. As this allow much more flexibility macvlan
matching, which I like, but still depending on HW support. 

 
> > We were not considered using XDP yet, so we've decided to limit the initial
> > implementation to macvtap because we can ensure correspondence between a
> > NIC queue and virtual NIC, which is not the case with more generic tap
> > device. It could be that use of XDP will allow for a generic solution for
> > virtio case as well.  
> 
> Interesting this was one of the original ideas behind the macvlan
> offload mode. iirc Vlad also was interested in this.
> 
> I'm guessing this was used because of the ability to push macvlan onto
> its own queue?
> 
> >    
> >>  
> >>> Have you considered using "push" model for setting the NIC's RX memory?  
> >>
> >> I don't understand what you mean by a "push" model?  
> > 
> > Currently, memory allocation in NIC drivers boils down to alloc_page with
> > some wrapping code. I see two possible ways to make NIC use of some
> > preallocated pages: either NIC driver will call an API (probably different
> > from alloc_page) to obtain that memory, or there will be NDO API that
> > allows to set the NIC's RX buffers. I named the later case "push".  
> 
> I prefer the ndo op. This matches up well with AF_PACKET model where we
> have "slots" and offload is just a transparent "push" of these "slots"
> to the driver. Below we have a snippet of our proposed API,

Hmmm. If you can rely on hardware setup to give you steering and
dedicated access to the RX rings.  In those cases, I guess, the "push"
model could be a more direct API approach.

I was shooting for a model that worked without hardware support.  And
then transparently benefit from HW support by configuring a HW filter
into a specific RX queue and attaching/using to that queue.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
