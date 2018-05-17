Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 708E96B052C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 15:37:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q22-v6so1197342pgv.22
        for <linux-mm@kvack.org>; Thu, 17 May 2018 12:37:25 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id h16-v6si5648849pli.53.2018.05.17.12.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 12:37:24 -0700 (PDT)
Subject: Re: [PATCH] mm/dmapool: localize page allocations
References: <1526578581-7658-1-git-send-email-okaya@codeaurora.org>
 <20180517181815.GC26718@bombadil.infradead.org>
From: Sinan Kaya <okaya@codeaurora.org>
Message-ID: <9844a638-bc4e-46bd-133e-0c82a3e9d6ea@codeaurora.org>
Date: Thu, 17 May 2018 15:37:21 -0400
MIME-Version: 1.0
In-Reply-To: <20180517181815.GC26718@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, timur@codeaurora.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, open list <linux-kernel@vger.kernel.org>

On 5/17/2018 2:18 PM, Matthew Wilcox wrote:
> On Thu, May 17, 2018 at 01:36:19PM -0400, Sinan Kaya wrote:
>> Try to keep the pool closer to the device's NUMA node by changing kmalloc()
>> to kmalloc_node() and devres_alloc() to devres_alloc_node().
> Have you measured any performance gains by doing this?  The thing is that
> these allocations are for the metadata about the page, and the page is
> going to be used by CPUs in every node.  So it's not clear to me that
> allocating it on the node nearest to the device is going to be any sort
> of a win.
> 

It is true that this is metadata but it is one of the things that is most
frequently used in spite of its small size.

I don't think it makes any sense to cross a chip boundary for accessing a
pointer location on every single pool allocation. 

Remember that the CPU core that is running this driver is most probably on
the same NUMA node as the device itself.

Also, if it was a one time init kind of thing, I'd say "yeah, leave it alone". 
DMA pool is used by a wide range of drivers and it is used to allocate
fixed size buffers at runtime. 

Performance impact changes depending on the driver in use. This particular
code is in use by network adapters as well as the NVMe driver. It does
have a wide range of impact.

-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
