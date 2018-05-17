Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0516B052E
	for <linux-mm@kvack.org>; Thu, 17 May 2018 15:46:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x14-v6so2009880pgv.18
        for <linux-mm@kvack.org>; Thu, 17 May 2018 12:46:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b73-v6si5891417pli.305.2018.05.17.12.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 12:46:13 -0700 (PDT)
Date: Thu, 17 May 2018 12:46:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/dmapool: localize page allocations
Message-ID: <20180517194612.GG26718@bombadil.infradead.org>
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
 <20180517181815.GC26718@bombadil.infradead.org>
 <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sinan Kaya <okaya@codeaurora.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On Thu, May 17, 2018 at 03:37:21PM -0400, Sinan Kaya wrote:
> On 5/17/2018 2:18 PM, Matthew Wilcox wrote:
> > On Thu, May 17, 2018 at 01:36:19PM -0400, Sinan Kaya wrote:
> >> Try to keep the pool closer to the device's NUMA node by changing kmalloc()
> >> to kmalloc_node() and devres_alloc() to devres_alloc_node().
> > Have you measured any performance gains by doing this?  The thing is that
> > these allocations are for the metadata about the page, and the page is
> > going to be used by CPUs in every node.  So it's not clear to me that
> > allocating it on the node nearest to the device is going to be any sort
> > of a win.
> > 
> 
> It is true that this is metadata but it is one of the things that is most
> frequently used in spite of its small size.
> 
> I don't think it makes any sense to cross a chip boundary for accessing a
> pointer location on every single pool allocation. 
> 
> Remember that the CPU core that is running this driver is most probably on
> the same NUMA node as the device itself.

Umm ... says who?  If my process is running on NUMA node 5 and I submit
an I/O, it should be allocating from a pool on node 5, not from a pool
on whichever node the device is attached to.

If it actually makes a performance difference, then NVMe should allocate
one pool per queue, rather than one pool per device like it currently
does.

> Also, if it was a one time init kind of thing, I'd say "yeah, leave it alone". 
> DMA pool is used by a wide range of drivers and it is used to allocate
> fixed size buffers at runtime. 

 * DMA Pool allocator
 *
 * Copyright 2001 David Brownell
 * Copyright 2007 Intel Corporation
 *   Author: Matthew Wilcox <willy@linux.intel.com>

I know what it's used for.
