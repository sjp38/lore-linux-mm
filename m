Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2656A6B0309
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:17:35 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id c25-v6so1135686ioi.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:17:35 -0800 (PST)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id m19si7116003itn.20.2018.11.15.05.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 05:17:33 -0800 (PST)
Date: Thu, 15 Nov 2018 13:16:43 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCH 5/7] doc/vm: New documentation for memory cache
Message-ID: <20181115131643.00003c0d@huawei.com>
In-Reply-To: <20181114224921.12123-6-keith.busch@intel.com>
References: <20181114224921.12123-2-keith.busch@intel.com>
	<20181114224921.12123-6-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 14 Nov 2018 15:49:18 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Platforms may provide system memory that contains side caches to help

If we can call them "memory-side caches" that would avoid a persistent
confusion on what they actually are.  It took me ages to get to the
bottom of why they were always drawn to the side of the memory
path ;)

> spped up access. These memory caches are part of a memory node and

speed

> the cache attributes are exported by the kernel.
> 
> Add new documentation providing a brief overview of system memory side
> caches and the kernel provided attributes for application optimization.
A few few nits in line, but mostly looks good to me.

Thanks,

Jonathan

> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/vm/numacache.rst | 76 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 76 insertions(+)
>  create mode 100644 Documentation/vm/numacache.rst
> 
> diff --git a/Documentation/vm/numacache.rst b/Documentation/vm/numacache.rst
> new file mode 100644
> index 000000000000..e79c801b7e3b
> --- /dev/null
> +++ b/Documentation/vm/numacache.rst
> @@ -0,0 +1,76 @@
> +.. _numacache:
> +
> +==========
> +NUMA Cache
> +==========
> +
> +System memory may be constructed in a hierarchy of various performing

of elements with various performance

> +characteristics in order to provide large address space of slower
> +performing memory cached by a smaller size of higher performing

cached by smaller higher performing memory.

> +memory. The system physical addresses that software is aware of see

is aware of is provided (no 'see')

> +is provided by the last memory level in the hierarchy, while higher
> +performing memory transparently provides caching to slower levels.
> +
> +The term "far memory" is used to denote the last level memory in the
> +hierarchy. Each increasing cache level provides higher performing CPU

initiator rather than CPU?

> +access, and the term "near memory" represents the highest level cache
> +provided by the system. This number is different than CPU caches where
> +the cache level (ex: L1, L2, L3) uses a CPU centric view with each level
> +being lower performing and closer to system memory. The memory cache
> +level is centric to the last level memory, so the higher numbered cache

from the last level memory?

> +level denotes memory nearer to the CPU, and further from far memory.
> +
> +The memory side caches are not directly addressable by software. When
> +software accesses a system address, the system will return it from the
> +near memory cache if it is present. If it is not present, the system
> +accesses the next level of memory until there is either a hit in that
> +cache level, or it reaches far memory.
> +
> +In order to maximize the performance out of such a setup, software may
> +wish to query the memory cache attributes. If the system provides a way
> +to query this information, for example with ACPI HMAT (Heterogeneous
> +Memory Attribute Table)[1], the kernel will append these attributes to
> +the NUMA node that provides the memory.
> +
> +When the kernel first registers a memory cache with a node, the kernel
> +will create the following directory::
> +
> +	/sys/devices/system/node/nodeX/cache/

Given we have other things with caches in a numa node, should we make
this name more specific?

> +
> +If that directory is not present, then either the memory does not have
> +a side cache, or that information is not provided to the kernel.
> +
> +The attributes for each level of cache is provided under its cache
> +level index::
> +
> +	/sys/devices/system/node/nodeX/cache/indexA/
> +	/sys/devices/system/node/nodeX/cache/indexB/
> +	/sys/devices/system/node/nodeX/cache/indexC/
> +
> +Each cache level's directory provides its attributes. For example,
> +the following is a single cache level and the attributes available for
> +software to query::
> +
> +	# tree sys/devices/system/node/node0/cache/
> +	/sys/devices/system/node/node0/cache/
> +	|-- index1
> +	|   |-- associativity
> +	|   |-- level
> +	|   |-- line_size
> +	|   |-- size
> +	|   `-- write_policy
> +
> +The cache "associativity" will be 0 if it is a direct-mapped cache, and
> +non-zero for any other indexed based, multi-way associativity.
This description is a little vague.  Right now I think we have 3 options
from HMAT,
1) no associativity (which I suppose could also be called fully associative?)
2) direct mapped (0 in your case)
3) Complex (who knows!)

So how do you map 1 and 3?

> +
> +The "level" is the distance from the far memory, and matches the number
> +appended to its "index" directory.
> +
> +The "line_size" is the number of bytes accessed on a cache miss.
> +
> +The "size" is the number of bytes provided by this cache level.
> +
> +The "write_policy" will be 0 for write-back, and non-zero for
> +write-through caching.

Do these not appear if the write_policy provided by acpi is "none".

> +
> +[1] https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
