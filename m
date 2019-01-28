Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB148E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:10:05 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id ay11so11582663plb.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 03:10:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor2402170plb.21.2019.01.28.03.10.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 03:10:03 -0800 (PST)
Date: Mon, 28 Jan 2019 22:09:58 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 0/5] [v4] Allow persistent memory to be used like normal
 RAM
Message-ID: <20190128110958.GH26056@350D>
References: <20190124231441.37A4A305@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124231441.37A4A305@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org, tiwai@suse.de, ying.huang@intel.com, linux-mm@kvack.org, jglisse@redhat.com, bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org, bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org

On Thu, Jan 24, 2019 at 03:14:41PM -0800, Dave Hansen wrote:
> v3 spurred a bunch of really good discussion.  Thanks to everybody
> that made comments and suggestions!
> 
> I would still love some Acks on this from the folks on cc, even if it
> is on just the patch touching your area.
> 
> Note: these are based on commit d2f33c19644 in:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git libnvdimm-pending
> 
> Changes since v3:
>  * Move HMM-related resource warning instead of removing it
>  * Use __request_resource() directly instead of devm.
>  * Create a separate DAX_PMEM Kconfig option, complete with help text
>  * Update patch descriptions and cover letter to give a better
>    overview of use-cases and hardware where this might be useful.
> 
> Changes since v2:
>  * Updates to dev_dax_kmem_probe() in patch 5:
>    * Reject probes for devices with bad NUMA nodes.  Keeps slow
>      memory from being added to node 0.
>    * Use raw request_mem_region()
>    * Add comments about permanent reservation
>    * use dev_*() instead of printk's
>  * Add references to nvdimm documentation in descriptions
>  * Remove unneeded GPL export
>  * Add Kconfig prompt and help text
> 
> Changes since v1:
>  * Now based on git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git
>  * Use binding/unbinding from "dax bus" code
>  * Move over to a "dax bus" driver from being an nvdimm driver
> 
> --
> 
> Persistent memory is cool.  But, currently, you have to rewrite
> your applications to use it.  Wouldn't it be cool if you could
> just have it show up in your system like normal RAM and get to
> it like a slow blob of memory?  Well... have I got the patch
> series for you!
> 
> == Background / Use Cases ==
> 
> Persistent Memory (aka Non-Volatile DIMMs / NVDIMMS) themselves
> are described in detail in Documentation/nvdimm/nvdimm.txt.
> However, this documentation focuses on actually using them as
> storage.  This set is focused on using NVDIMMs as DRAM replacement.
> 
> This is intended for Intel-style NVDIMMs (aka. Intel Optane DC
> persistent memory) NVDIMMs.  These DIMMs are physically persistent,
> more akin to flash than traditional RAM.  They are also expected to
> be more cost-effective than using RAM, which is why folks want this
> set in the first place.

What variant of NVDIMM's F/P or both?

> 
> This set is not intended for RAM-based NVDIMMs.  Those are not
> cost-effective vs. plain RAM, and this using them here would simply
> be a waste.
> 

Sounds like NVDIMM (P)

> But, why would you bother with this approach?  Intel itself [1]
> has announced a hardware feature that does something very similar:
> "Memory Mode" which turns DRAM into a cache in front of persistent
> memory, which is then as a whole used as normal "RAM"?
> 
> Here are a few reasons:
> 1. The capacity of memory mode is the size of your persistent
>    memory that you dedicate.  DRAM capacity is "lost" because it
>    is used for cache.  With this, you get PMEM+DRAM capacity for
>    memory.
> 2. DRAM acts as a cache with memory mode, and caches can lead to
>    unpredictable latencies.  Since memory mode is all-or-nothing
>    (either all your DRAM is used as cache or none is), your entire
>    memory space is exposed to these unpredictable latencies.  This
>    solution lets you guarantee DRAM latencies if you need them.
> 3. The new "tier" of memory is exposed to software.  That means
>    that you can build tiered applications or infrastructure.  A
>    cloud provider could sell cheaper VMs that use more PMEM and
>    more expensive ones that use DRAM.  That's impossible with
>    memory mode.
> 
> Don't take this as criticism of memory mode.  Memory mode is
> awesome, and doesn't strictly require *any* software changes (we
> have software changes proposed for optimizing it though).  It has
> tons of other advantages over *this* approach.  Basically, we
> believe that the approach in these patches is complementary to
> memory mode and that both can live side-by-side in harmony.
> 
> == Patch Set Overview ==
> 
> This series adds a new "driver" to which pmem devices can be
> attached.  Once attached, the memory "owned" by the device is
> hot-added to the kernel and managed like any other memory.  On
> systems with an HMAT (a new ACPI table), each socket (roughly)
> will have a separate NUMA node for its persistent memory so
> this newly-added memory can be selected by its unique NUMA
> node.


NUMA is distance based topology, does HMAT solve these problems?
How do we prevent fallback nodes of normal nodes being pmem nodes?
On an unexpected crash/failure is there a scrubbing mechanism
or do we rely on the allocator to do the right thing prior to
reallocating any memory. Will frequent zero'ing hurt NVDIMM/pmem's
life times?

Balbir Singh.
