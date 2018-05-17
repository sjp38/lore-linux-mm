Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D70046B0542
	for <linux-mm@kvack.org>; Thu, 17 May 2018 17:05:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t5-v6so3598754ply.13
        for <linux-mm@kvack.org>; Thu, 17 May 2018 14:05:56 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 7-v6si6285437pff.154.2018.05.17.14.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 14:05:55 -0700 (PDT)
Subject: Re: [PATCH] mm/dmapool: localize page allocations
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
 <20180517181815.GC26718@bombadil.infradead.org>
 <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
 <20180517194612.GG26718@bombadil.infradead.org>
 <d49e594a-c18a-160f-ca4c-91520ff3b293@codeaurora.org>
 <20180517204103.GJ26718@bombadil.infradead.org>
From: Sinan Kaya <okaya@codeaurora.org>
Message-ID: <bbd1c867-7ca8-1364-cedb-39f52bb586d9@codeaurora.org>
Date: Thu, 17 May 2018 17:05:53 -0400
MIME-Version: 1.0
In-Reply-To: <20180517204103.GJ26718@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On 5/17/2018 4:41 PM, Matthew Wilcox wrote:
> Let's try a different example.  I have a four-socket system with one
> NVMe device with lots of hardware queues.  Each CPU has its own queue
> assigned to it.  If I allocate all the PRP metadata on the socket with
> the NVMe device attached to it, I'm sending a lot of coherency traffic
> in the direction of that socket, in addition to the actual data.  If the
> PRP lists are allocated randomly on the various sockets, the traffic
> is heading all over the fabric.  If the PRP lists are allocated on the
> local socket, the only time those lists move off this node is when the
> device requests them.

So.., your reasoning is that you actually want to keep the memory as close
as possible to the CPU rather than the device itself. CPU would do
frequent updates the buffer until the point where it hands off the buffer
to the hardware. Device would fetch the memory via coherency when it needs
to consume the data but this would be a one time penalty.

It sounds logical to me. I was always told that you want to keep buffers
as close as possible to the device.

Maybe, it makes sense for things that device needs frequent access like
receive buffers.

If the majority user is CPU, then the buffer needs to be kept closer to
the CPU. 

dma_alloc_coherent() is generally used for receiver buffer allocation in
network adapters in general. People allocate a chunk and then create a
queue that hardware owns for dumping events and data.

Since DMA pool is a generic API, we should maybe request where we want
to keep the buffers closer to and allocate buffers from the appropriate
NUMA node based on that.

-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
