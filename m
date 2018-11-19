Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 933DB6B1D13
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 18:09:18 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so7172pgb.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 15:09:18 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h3-v6si16225707plh.390.2018.11.19.15.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 15:09:17 -0800 (PST)
Date: Mon, 19 Nov 2018 16:06:00 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 4/7] node: Add memory caching attributes
Message-ID: <20181119230600.GC26707@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-5-keith.busch@intel.com>
 <91698cef-cdcd-5143-884f-3da5536e156f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91698cef-cdcd-5143-884f-3da5536e156f@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Nov 19, 2018 at 09:44:00AM +0530, Anshuman Khandual wrote:
> On 11/15/2018 04:19 AM, Keith Busch wrote:
> > System memory may have side caches to help improve access speed. While
> > the system provided cache is transparent to the software accessing
> > these memory ranges, applications can optimize their own access based
> > on cache attributes.
> 
> Cache is not a separate memory attribute. It impacts how the real attributes
> like bandwidth, latency e.g which are already captured in the previous patch.
> What is the purpose of adding this as a separate attribute ? Can you explain
> how this is going to help the user space apart from the hints it has already
> received with bandwidth, latency etc properties.

I am not sure I understand the question here. Access bandwidth and latency
are entirely attributes different than what this patch provides. If the
system side-caches memory, the associativity, line size, and total size
can optionally be used by software to improve performance.
 
> > In preparation for such systems, provide a new API for the kernel to
> > register these memory side caches under the memory node that provides it.
> 
> Under target memory node interface /sys/devices/system/node/nodeY/target* ?

Yes.
 
> > 
> > The kernel's sysfs representation is modeled from the cpu cacheinfo
> > attributes, as seen from /sys/devices/system/cpu/cpuX/cache/. Unlike CPU
> > cacheinfo, though, a higher node's memory cache level is nearer to the
> > CPU, while lower levels are closer to the backing memory. Also unlike
> > CPU cache, the system handles flushing any dirty cached memory to the
> > last level the memory on a power failure if the range is persistent.
> 
> Lets assume that a CPU has got four levels of caches L1, L2, L3, L4 before
> reaching memory. L4 is the backing cache for the memory 

I don't quite understand this question either. The cache doesn't back
the memory; the system side caches access to memory.

> and L1-L3 is from
> CPU till the system bus. Hence some of them will be represented as CPU
> caches and some of them will be represented as memory caches ?
>
> /sys/devices/system/cpu/cpuX/cache/ --> L1, L2, L3
> /sys/devices/system/node/nodeY/target --> L4 
> 
> L4 will be listed even if the node is memory only ?

The system provided memory side caches are independent of the
CPU. I'm just providing the CPU caches as a more familiar example to
compare/contrast system memory cache attributes.
