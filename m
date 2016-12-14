Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A89CC6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:39:24 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id m67so10212855qkf.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:39:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p25si29754468qte.81.2016.12.14.01.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 01:39:23 -0800 (PST)
Date: Wed, 14 Dec 2016 10:39:14 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161214103914.3a9ebbbf@redhat.com>
In-Reply-To: <58505535.1080908@gmail.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
	<20161213171028.24dbf519@redhat.com>
	<5850335F.6090000@gmail.com>
	<20161213.145333.514056260418695987.davem@davemloft.net>
	<58505535.1080908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Fastabend <john.fastabend@gmail.com>
Cc: David Miller <davem@davemloft.net>, cl@linux.com, rppt@linux.vnet.ibm.com, netdev@vger.kernel.org, linux-mm@kvack.org, willemdebruijn.kernel@gmail.com, bjorn.topel@intel.com, magnus.karlsson@intel.com, alexander.duyck@gmail.com, mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com, tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com, METH@il.ibm.com, vyasevich@gmail.com, brouer@redhat.com

On Tue, 13 Dec 2016 12:08:21 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-12-13 11:53 AM, David Miller wrote:
> > From: John Fastabend <john.fastabend@gmail.com>
> > Date: Tue, 13 Dec 2016 09:43:59 -0800
> >   
> >> What does "zero-copy send packet-pages to the application/socket that
> >> requested this" mean? At the moment on x86 page-flipping appears to be
> >> more expensive than memcpy (I can post some data shortly) and shared
> >> memory was proposed and rejected for security reasons when we were
> >> working on bifurcated driver.  
> > 
> > The whole idea is that we map all the active RX ring pages into
> > userspace from the start.
> > 
> > And just how Jesper's page pool work will avoid DMA map/unmap,
> > it will also avoid changing the userspace mapping of the pages
> > as well.
> > 
> > Thus avoiding the TLB/VM overhead altogether.
> >   

Exactly.  It is worth mentioning that pages entering the page pool need
to be cleared (measured cost 143 cycles), in order to not leak any
kernel info.  The primary focus of this design is to make sure not to
leak kernel info to userspace, but with an "exclusive" mode also
support isolation between applications.


> I get this but it requires applications to be isolated. The pages from
> a queue can not be shared between multiple applications in different
> trust domains. And the application has to be cooperative meaning it
> can't "look" at data that has not been marked by the stack as OK. In
> these schemes we tend to end up with something like virtio/vhost or
> af_packet.

I expect 3 modes, when enabling RX-zero-copy on a page_pool. The first
two would require CAP_NET_ADMIN privileges.  All modes have a trust
domain id, that need to match e.g. when page reach the socket.

Mode-1 "Shared": Application choose lowest isolation level, allowing
 multiple application to mmap VMA area.

Mode-2 "Single-user": Application request it want to be the only user
 of the RX queue.  This blocks other application to mmap VMA area.

Mode-3 "Exclusive": Application request to own RX queue.  Packets are
 no longer allowed for normal netstack delivery.

Notice mode-2 still requires CAP_NET_ADMIN, because packets/pages are
still allowed to travel netstack and thus can contain packet data from
other normal applications.  This is part of the design, to share the
NIC between netstack and an accelerated userspace application using RX
zero-copy delivery.


> Any ACLs/filtering/switching/headers need to be done in hardware or
> the application trust boundaries are broken.

The software solution outlined allow the application to make the choice
of what trust boundary it wants.

The "exclusive" mode-3 make most sense together with HW filters.
Already today, we support creating a new RX queue based on ethtool
ntuple HW filter and then you simply attach your application that queue
in mode-3, and have full isolation.

 
> If the above can not be met then a copy is needed. What I am trying
> to tease out is the above comment along with other statements like
> this "can be done with out HW filter features".

Does this address your concerns?

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
