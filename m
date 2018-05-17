Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D49F6B0532
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:05:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so3493147plb.20
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:05:49 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 206-v6si5811908pfw.130.2018.05.17.13.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 13:05:48 -0700 (PDT)
Subject: Re: [PATCH] mm/dmapool: localize page allocations
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
 <20180517181815.GC26718@bombadil.infradead.org>
 <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
 <20180517194612.GG26718@bombadil.infradead.org>
From: Sinan Kaya <okaya@codeaurora.org>
Message-ID: <d49e594a-c18a-160f-ca4c-91520ff3b293@codeaurora.org>
Date: Thu, 17 May 2018 16:05:45 -0400
MIME-Version: 1.0
In-Reply-To: <20180517194612.GG26718@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On 5/17/2018 3:46 PM, Matthew Wilcox wrote:
>> Remember that the CPU core that is running this driver is most probably on
>> the same NUMA node as the device itself.
> Umm ... says who?  If my process is running on NUMA node 5 and I submit
> an I/O, it should be allocating from a pool on node 5, not from a pool
> on whichever node the device is attached to.

OK, let's do an exercise. Maybe, I'm missing something in the big picture.

If a user process is running at node 5, it submits some work to the hardware
via block layer that is eventually invoked by syscall. 

Whatever buffer process is using, it gets copied into the kernel space as
it is crossing a userspace/kernel space boundary.

Block layer packages a block request with the kernel pointers and makes a
request to the NVMe driver for consumption.

Last time I checked, dma_alloc_coherent() API uses the locality information
from the device not from the CPU for allocation.

While the metadata for dma_pool is pointing to the currently running CPU core,
the DMA buffer itself is created using the device node itself today without
my patch.

I would think that you actually want to run the process at the same NUMA node
as the CPU and device itself for performance reasons. Otherwise, performance
expectations should be low. 

Even if user says please keep my process to a particular NUMA node,
we keep pointing to the memory on the other node today. 

I don't know what is so special about memory on the default node. IMO, all memory
allocations used by a driver need to follow the device. 

I wish I could do this in kmalloc(). devm_kmalloc() follows the device as another
example not CPU.

With these assumptions, even though user said please use the NUMA node from the
device, we still keep pointing to the default domain for pointers.

Isn't this wrong?

> 
> If it actually makes a performance difference, then NVMe should allocate
> one pool per queue, rather than one pool per device like it currently
> does.
> 
>> Also, if it was a one time init kind of thing, I'd say "yeah, leave it alone". 
>> DMA pool is used by a wide range of drivers and it is used to allocate
>> fixed size buffers at runtime. 
>  * DMA Pool allocator
>  *
>  * Copyright 2001 David Brownell
>  * Copyright 2007 Intel Corporation
>  *   Author: Matthew Wilcox <willy@linux.intel.com>
> 
> I know what it's used for.
> 

cool, good to know.

-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
