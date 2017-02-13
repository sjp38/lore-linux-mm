Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03E2C6B0038
	for <linux-mm@kvack.org>; Sun, 12 Feb 2017 22:59:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so149544878pgb.0
        for <linux-mm@kvack.org>; Sun, 12 Feb 2017 19:59:49 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id u84si8840457pfi.284.2017.02.12.19.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Feb 2017 19:59:48 -0800 (PST)
Subject: Re: [PATCH V2 1/3] mm: Define coherent device memory (CDM) node
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <20170210100640.26927-2-khandual@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1c183237-d1f0-4fc3-cf5b-73fdfb9cb342@nvidia.com>
Date: Sun, 12 Feb 2017 19:59:47 -0800
MIME-Version: 1.0
In-Reply-To: <20170210100640.26927-2-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/10/2017 02:06 AM, Anshuman Khandual wrote:
> There are certain devices like specialized accelerator, GPU cards, network
> cards, FPGA cards etc which might contain onboard memory which is coherent
> along with the existing system RAM while being accessed either from the CPU
> or from the device. They share some similar properties with that of normal
> system RAM but at the same time can also be different with respect to
> system RAM.
>
> User applications might be interested in using this kind of coherent device
> memory explicitly or implicitly along side the system RAM utilizing all
> possible core memory functions like anon mapping (LRU), file mapping (LRU),
> page cache (LRU), driver managed (non LRU), HW poisoning, NUMA migrations
> etc. To achieve this kind of tight integration with core memory subsystem,
> the device onboard coherent memory must be represented as a memory only
> NUMA node. At the same time arch must export some kind of a function to
> identify of this node as a coherent device memory not any other regular
> cpu less memory only NUMA node.
>
> After achieving the integration with core memory subsystem coherent device
> memory might still need some special consideration inside the kernel. There
> can be a variety of coherent memory nodes with different expectations from
> the core kernel memory. But right now only one kind of special treatment is
> considered which requires certain isolation.
>
> Now consider the case of a coherent device memory node type which requires
> isolation. This kind of coherent memory is onboard an external device
> attached to the system through a link where there is always a chance of a
> link failure taking down the entire memory node with it. More over the
> memory might also have higher chance of ECC failure as compared to the
> system RAM. Hence allocation into this kind of coherent memory node should
> be regulated. Kernel allocations must not come here. Normal user space
> allocations too should not come here implicitly (without user application
> knowing about it). This summarizes isolation requirement of certain kind of
> coherent device memory node as an example. There can be different kinds of
> isolation requirement also.
>
> Some coherent memory devices might not require isolation altogether after
> all. Then there might be other coherent memory devices which might require
> some other special treatment after being part of core memory representation
> . For now, will look into isolation seeking coherent device memory node not
> the other ones.
>

Hi Anshuman,

I'd question the need to avoid kernel allocations in device memory. Maybe we should simply allow 
these pages to *potentially* participate in everything that N_MEMORY pages do: huge pages, kernel 
allocations, for example.

There is a bit too much emphasis being placed on the idea that these devices are less reliable than 
system memory. It's true--they are less reliable. However, they are reliable enough to be allowed 
direct (coherent) addressing. And anything that allows that, is, IMHO, good enough to allow all 
allocations on it.

On the point of what reliability implies: I've been involved in the development (and debugging) of 
similar systems over the years, and what happens is: if the device has a fatal error, you have to 
take the computer down, some time in the near future. There are a few reasons for this:

    -- sometimes the MCE (machine check) is wired up to fire, if the device has errors, in which 
case you are all done very quickly. :)

    -- other times, the operating system relied upon now-corrupted data, that came from the device. 
So even if you claim "OK, the device has a fatal error, but the OS can continue running just fine", 
that's just wrong! You may have corrupted something important.

    -- even if the above two didn't get you, you still have a likely expensive computer that cannot 
do what you bought it for, so you've got to shut it down and replace the failed device.

Given all that, I think it is not especially worthwhile to design in a lot of constraints and 
limitations around coherent device memory.

As for speed, we should be able to put in some hints to help with page placement. I'm still coming 
up to speed with what is already there, and I'm sure other people can comment on that.

We should probably just let the allocations happen.


> To implement the integration as well as isolation, the coherent memory node
> must be present in N_MEMORY and a new N_COHERENT_DEVICE node mask inside
> the node_states[] array. During memory hotplug operations, the new nodemask
> N_COHERENT_DEVICE is updated along with N_MEMORY for these coherent device
> memory nodes. This also creates the following new sysfs based interface to
> list down all the coherent memory nodes of the system.
>
> 	/sys/devices/system/node/is_coherent_node

The naming bothers me: all nodes are coherent already. In fact, the Coherent Device Memory naming is 
a little off-base already: what is it *really* trying to say? Less reliable? Slower? 
My-special-device? :) Will those things even always be true?  Makes me question the whole CDM 
concept. Maybe just ZONE_MOVABLE (to handle hotplug) is the way to go.


>
> Architectures must export function arch_check_node_cdm() which identifies
> any coherent device memory node in case they enable CONFIG_COHERENT_DEVICE.
>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node |  7 ++++
>  arch/powerpc/Kconfig                        |  1 +
>  arch/powerpc/mm/numa.c                      |  7 ++++
>  drivers/base/node.c                         |  6 +++
>  include/linux/nodemask.h                    | 58 ++++++++++++++++++++++++++++-
>  mm/Kconfig                                  |  4 ++
>  mm/memory_hotplug.c                         |  3 ++
>  mm/page_alloc.c                             |  8 +++-
>  8 files changed, 91 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 5b2d0f0..fa2f105 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -29,6 +29,13 @@ Description:
>  		Nodes that have regular or high memory.
>  		Depends on CONFIG_HIGHMEM.
>
> +What:		/sys/devices/system/node/is_coherent_device
> +Date:		January 2017
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		Lists the nodemask of nodes that have coherent device memory.
> +		Depends on CONFIG_COHERENT_DEVICE.
> +
>  What:		/sys/devices/system/node/nodeX
>  Date:		October 2002
>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 281f4f1..1cff239 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -164,6 +164,7 @@ config PPC
>  	select ARCH_HAS_SCALED_CPUTIME if VIRT_CPU_ACCOUNTING_NATIVE
>  	select HAVE_ARCH_HARDENED_USERCOPY
>  	select HAVE_KERNEL_GZIP
> +	select COHERENT_DEVICE if PPC_BOOK3S_64 && NEED_MULTIPLE_NODES
>
>  config GENERIC_CSUM
>  	def_bool CPU_LITTLE_ENDIAN
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index b1099cb..14f0b98 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -41,6 +41,13 @@
>  #include <asm/setup.h>
>  #include <asm/vdso.h>
>
> +#ifdef CONFIG_COHERENT_DEVICE
> +inline int arch_check_node_cdm(int nid)
> +{
> +	return 0;
> +}
> +#endif

I'm not sure that we really need this exact sort of arch_ check. Seems like most arches could simply 
support the possibility of a CDM node.

But we can probably table that question until we ensure that we want a new NUMA node type (vs. 
ZONE_MOVABLE).

> +
>  static int numa_enabled = 1;
>

[snip]

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f3e0c69..84d61bb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6080,8 +6080,10 @@ static unsigned long __init early_calculate_totalpages(void)
>  		unsigned long pages = end_pfn - start_pfn;
>
>  		totalpages += pages;
> -		if (pages)
> +		if (pages) {
> +			node_set_state_cdm(nid);
>  			node_set_state(nid, N_MEMORY);
> +		}
>  	}
>  	return totalpages;
>  }
> @@ -6392,8 +6394,10 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  				find_min_pfn_for_node(nid), NULL);
>
>  		/* Any memory on that node */
> -		if (pgdat->node_present_pages)
> +		if (pgdat->node_present_pages) {
> +			node_set_state_cdm(nid);
>  			node_set_state(nid, N_MEMORY);


I like that you provide clean wrapper functions, but air-dropping them into all these routines (none 
of the other node types have to do this) makes it look like CDM is sort of hacked in. :)

thanks
john h

> +		}
>  		check_for_memory(pgdat, nid);
>  	}
>  }
> --
> 2.9.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
