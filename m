Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84BDB6B0538
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:41:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z2-v6so2052312pgo.17
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:41:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r14-v6si5893200pfa.296.2018.05.17.13.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 13:41:03 -0700 (PDT)
Date: Thu, 17 May 2018 13:41:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/dmapool: localize page allocations
Message-ID: <20180517204103.GJ26718@bombadil.infradead.org>
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
 <20180517181815.GC26718@bombadil.infradead.org>
 <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
 <20180517194612.GG26718@bombadil.infradead.org>
 <d49e594a-c18a-160f-ca4c-91520ff3b293@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d49e594a-c18a-160f-ca4c-91520ff3b293@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sinan Kaya <okaya@codeaurora.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On Thu, May 17, 2018 at 04:05:45PM -0400, Sinan Kaya wrote:
> On 5/17/2018 3:46 PM, Matthew Wilcox wrote:
> >> Remember that the CPU core that is running this driver is most probably on
> >> the same NUMA node as the device itself.
> > Umm ... says who?  If my process is running on NUMA node 5 and I submit
> > an I/O, it should be allocating from a pool on node 5, not from a pool
> > on whichever node the device is attached to.
> 
> OK, let's do an exercise. Maybe, I'm missing something in the big picture.

Sure.

> If a user process is running at node 5, it submits some work to the hardware
> via block layer that is eventually invoked by syscall. 
> 
> Whatever buffer process is using, it gets copied into the kernel space as
> it is crossing a userspace/kernel space boundary.
> 
> Block layer packages a block request with the kernel pointers and makes a
> request to the NVMe driver for consumption.
> 
> Last time I checked, dma_alloc_coherent() API uses the locality information
> from the device not from the CPU for allocation.

Yes, it does.  I wonder why that is; it doesn't actually make any sense.
It'd be far more sensible to allocate it on memory local to the user
than memory local to the device.

> While the metadata for dma_pool is pointing to the currently running CPU core,
> the DMA buffer itself is created using the device node itself today without
> my patch.

Umm ... dma_alloc_coherent memory is for metadata about the transfer, not
for the memory used for the transaction.

> I would think that you actually want to run the process at the same NUMA node
> as the CPU and device itself for performance reasons. Otherwise, performance
> expectations should be low. 

That's foolish.  Consider a database appliance with four sockets, each
with its own memory and I/O devices attached.  You can't tell the user
to shard the database into four pieces and have each socket only work on
the quarter of the database that's available to each socket.  They may
as well buy four smaller machines.  The point of buying a large NUMA
machine is to use all of it.

Let's try a different example.  I have a four-socket system with one
NVMe device with lots of hardware queues.  Each CPU has its own queue
assigned to it.  If I allocate all the PRP metadata on the socket with
the NVMe device attached to it, I'm sending a lot of coherency traffic
in the direction of that socket, in addition to the actual data.  If the
PRP lists are allocated randomly on the various sockets, the traffic
is heading all over the fabric.  If the PRP lists are allocated on the
local socket, the only time those lists move off this node is when the
device requests them.
