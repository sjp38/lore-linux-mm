Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 944F56B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 16:04:48 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id h184so55264922ybb.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:04:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d3si2552391vkh.92.2016.12.14.13.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 13:04:47 -0800 (PST)
Date: Wed, 14 Dec 2016 22:04:38 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161214220438.4608f2bb@redhat.com>
In-Reply-To: <5851740A.2080806@gmail.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
	<20161213171028.24dbf519@redhat.com>
	<5850335F.6090000@gmail.com>
	<20161213.145333.514056260418695987.davem@davemloft.net>
	<58505535.1080908@gmail.com>
	<20161214103914.3a9ebbbf@redhat.com>
	<5851740A.2080806@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Fastabend <john.fastabend@gmail.com>
Cc: David Miller <davem@davemloft.net>, cl@linux.com, rppt@linux.vnet.ibm.com, netdev@vger.kernel.org, linux-mm@kvack.org, willemdebruijn.kernel@gmail.com, bjorn.topel@intel.com, magnus.karlsson@intel.com, alexander.duyck@gmail.com, mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com, tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com, METH@il.ibm.com, vyasevich@gmail.com, brouer@redhat.com

On Wed, 14 Dec 2016 08:32:10 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-12-14 01:39 AM, Jesper Dangaard Brouer wrote:
> > On Tue, 13 Dec 2016 12:08:21 -0800
> > John Fastabend <john.fastabend@gmail.com> wrote:
> >   
> >> On 16-12-13 11:53 AM, David Miller wrote:  
> >>> From: John Fastabend <john.fastabend@gmail.com>
> >>> Date: Tue, 13 Dec 2016 09:43:59 -0800
> >>>     
> >>>> What does "zero-copy send packet-pages to the application/socket that
> >>>> requested this" mean? At the moment on x86 page-flipping appears to be
> >>>> more expensive than memcpy (I can post some data shortly) and shared
> >>>> memory was proposed and rejected for security reasons when we were
> >>>> working on bifurcated driver.    
> >>>
> >>> The whole idea is that we map all the active RX ring pages into
> >>> userspace from the start.
> >>>
> >>> And just how Jesper's page pool work will avoid DMA map/unmap,
> >>> it will also avoid changing the userspace mapping of the pages
> >>> as well.
> >>>
> >>> Thus avoiding the TLB/VM overhead altogether.
> >>>     
> > 
> > Exactly.  It is worth mentioning that pages entering the page pool need
> > to be cleared (measured cost 143 cycles), in order to not leak any
> > kernel info.  The primary focus of this design is to make sure not to
> > leak kernel info to userspace, but with an "exclusive" mode also
> > support isolation between applications.
> > 
> >   
> >> I get this but it requires applications to be isolated. The pages from
> >> a queue can not be shared between multiple applications in different
> >> trust domains. And the application has to be cooperative meaning it
> >> can't "look" at data that has not been marked by the stack as OK. In
> >> these schemes we tend to end up with something like virtio/vhost or
> >> af_packet.  
> > 
> > I expect 3 modes, when enabling RX-zero-copy on a page_pool. The first
> > two would require CAP_NET_ADMIN privileges.  All modes have a trust
> > domain id, that need to match e.g. when page reach the socket.  
> 
> Even mode 3 should required cap_net_admin we don't want userspace to
> grab queues off the nic without it IMO.

Good point.

> > 
> > Mode-1 "Shared": Application choose lowest isolation level, allowing
> >  multiple application to mmap VMA area.  
> 
> My only point here is applications can read each others data and all
> applications need to cooperate for example one app could try to write
> continuously to read only pages causing faults and what not. This is
> all non standard and doesn't play well with cgroups and "normal"
> applications. It requires a new orchestration model.
> 
> I'm a bit skeptical of the use case but I know of a handful of reasons
> to use this model. Maybe take a look at the ivshmem implementation in
> DPDK.
> 
> Also this still requires a hardware filter to push "application" traffic
> onto reserved queues/pages as far as I can tell.
> 
> > 
> > Mode-2 "Single-user": Application request it want to be the only user
> >  of the RX queue.  This blocks other application to mmap VMA area.
> >   
> 
> Assuming data is read-only sharing with the stack is possibly OK :/. I
> guess you would need to pools of memory for data and skb so you don't
> leak skb into user space.

Yes, as describe in orig email and here[1]: "once an application
request zero-copy RX, then the driver must use a specific SKB
allocation mode and might have to reconfigure the RX-ring."

The SKB allocation mode is "read-only packet page", which is the
current default mode (also desc in document[1]) of using skb-frags.

[1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
 
> The devils in the details here. There are lots of hooks in the kernel
> that can for example push the packet with a 'redirect' tc action for
> example. And letting an app "read" data or impact performance of an
> unrelated application is wrong IMO. Stacked devices also provide another
> set of details that are a bit difficult to track down see all the
> hardware offload efforts.
> 
> I assume all these concerns are shared between mode-1 and mode-2
> 
> > Mode-3 "Exclusive": Application request to own RX queue.  Packets are
> >  no longer allowed for normal netstack delivery.
> >   
> 
> I have patches for this mode already but haven't pushed them due to
> an alternative solution using VFIO.

Interesting.

> > Notice mode-2 still requires CAP_NET_ADMIN, because packets/pages are
> > still allowed to travel netstack and thus can contain packet data from
> > other normal applications.  This is part of the design, to share the
> > NIC between netstack and an accelerated userspace application using RX
> > zero-copy delivery.
> >   
> 
> I don't think this is acceptable to be honest. Letting an application
> potentially read/impact other arbitrary applications on the system
> seems like a non-starter even with CAP_NET_ADMIN. At least this was
> the conclusion from bifurcated driver work some time ago.

I though the bifurcated driver work was rejected because it could leak
kernel info in the pages. This approach cannot.

   
> >> Any ACLs/filtering/switching/headers need to be done in hardware or
> >> the application trust boundaries are broken.  
> > 
> > The software solution outlined allow the application to make the
> > choice of what trust boundary it wants.
> > 
> > The "exclusive" mode-3 make most sense together with HW filters.
> > Already today, we support creating a new RX queue based on ethtool
> > ntuple HW filter and then you simply attach your application that
> > queue in mode-3, and have full isolation.
> >   
> 
> Still pretty fuzzy on why mode-1 and mode-2 do not need hw filters?
> Without hardware filters we have no way of knowing who/what data is
> put in the page.

For sockets, an SKB carrying a RX zero-copy-able page can be steered
(as normal) into a given socket. Then we check if socket requested
zero-copy, and verify if the domain-id match between the page_pool and
socket.

You can also use XDP to filter and steer the packet (which will be
faster and using normal steering code). 

> >    
> >> If the above can not be met then a copy is needed. What I am trying
> >> to tease out is the above comment along with other statements like
> >> this "can be done with out HW filter features".  
> > 
> > Does this address your concerns?
> >   
> 
> I think we need to enforce strong isolation. An application should not
> be able to read data or impact other applications. I gather this is
> the case per comment about normal applications in mode-2. A slightly
> weaker statement would be to say applications can only impace/read
> data of other applications in their domain. This might be OK as well.

I think this approach covers the "weaker statement".  Because only page
within the pool are "exposed".  Thus, the domain is the NIC (possibly
restricted to a single RX queue).

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
