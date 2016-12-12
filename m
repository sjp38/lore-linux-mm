Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C15F46B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 04:40:51 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id y205so74929222qkb.4
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 01:40:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k10si25934850qtb.97.2016.12.12.01.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 01:40:50 -0800 (PST)
Date: Mon, 12 Dec 2016 10:40:42 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161212104042.0a011212@redhat.com>
In-Reply-To: <20161212083812.GA19987@rapoport-lnx>
References: <20161205153132.283fcb0e@redhat.com>
	<20161212083812.GA19987@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Fastabend <john.fastabend@gmail.com>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>, Kalman Meth <METH@il.ibm.com>, brouer@redhat.com


On Mon, 12 Dec 2016 10:38:13 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Hello Jesper,
> 
> On Mon, Dec 05, 2016 at 03:31:32PM +0100, Jesper Dangaard Brouer wrote:
> > Hi all,
> > 
> > This is my design for how to safely handle RX zero-copy in the network
> > stack, by using page_pool[1] and modifying NIC drivers.  Safely means
> > not leaking kernel info in pages mapped to userspace and resilience
> > so a malicious userspace app cannot crash the kernel.
> > 
> > Design target
> > =============
> > 
> > Allow the NIC to function as a normal Linux NIC and be shared in a
> > safe manor, between the kernel network stack and an accelerated
> > userspace application using RX zero-copy delivery.
> > 
> > Target is to provide the basis for building RX zero-copy solutions in
> > a memory safe manor.  An efficient communication channel for userspace
> > delivery is out of scope for this document, but OOM considerations are
> > discussed below (`Userspace delivery and OOM`_).  
> 
> Sorry, if this reply is a bit off-topic.

It is very much on topic IMHO :-)

> I'm working on implementation of RX zero-copy for virtio and I've dedicated
> some thought about making guest memory available for physical NIC DMAs.
> I believe this is quite related to your page_pool proposal, at least from
> the NIC driver perspective, so I'd like to share some thoughts here.

Seems quite related. I'm very interested in cooperating with you! I'm
not very familiar with virtio, and how packets/pages gets channeled
into virtio.

> The idea is to dedicate one (or more) of the NIC's queues to a VM, e.g.
> using macvtap, and then propagate guest RX memory allocations to the NIC
> using something like new .ndo_set_rx_buffers method.

I believe the page_pool API/design aligns with this idea/use-case.

> What is your view about interface between the page_pool and the NIC
> drivers?

In my Prove-of-Concept implementation, the NIC driver (mlx5) register
a page_pool per RX queue.  This is done for two reasons (1) performance
and (2) for supporting use-cases where only one single RX-ring queue is
(re)configured to support RX-zero-copy.  There are some associated
extra cost of enabling this mode, thus it makes sense to only enable it
when needed.

I've not decided how this gets enabled, maybe some new driver NDO.  It
could also happen when a XDP program gets loaded, which request this
feature.

The macvtap solution is nice and we should support it, but it requires
VM to have their MAC-addr registered on the physical switch.  This
design is about adding flexibility. Registering an XDP eBPF filter
provides the maximum flexibility for matching the destination VM.


> Have you considered using "push" model for setting the NIC's RX memory?

I don't understand what you mean by a "push" model?

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
