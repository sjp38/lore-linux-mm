Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D79446B0033
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 06:37:27 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k38so1642468wre.23
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 03:37:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d15si4928293wra.341.2018.02.15.03.37.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 03:37:26 -0800 (PST)
Date: Thu, 15 Feb 2018 12:37:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/4] x86/mm/memory_hotplug: determine block size based
 on the end of boot memory
Message-ID: <20180215113725.GC7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180213193159.14606-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Tue 13-02-18 14:31:57, Pavel Tatashin wrote:
> Memory sections are combined into "memory block" chunks. These chunks are
> the units upon which memory can be added and removed.
> 
> On x86, the new memory may be added after the end of the boot memory,
> therefore, if block size does not align with end of boot memory, memory
> hot-plugging/hot-removing can be broken.
> 
> Currently, whenever machine is boot with more than 64G the block size
> unconditionally increased to 2G from the base 128M in order to reduce
> number of memory devices in sysfs:
> 	/sys/devices/system/memory/memoryXXX
> 
> But, we must use the largest allowed block size that aligns to the next
> address to be able to hotplug the next block of memory.
> 
> So, when memory is larger than 64G, we check the end address and find the
> largest block size that is still power of two but smaller or equal to 2G.
> 
> Before, the fix:
> Run qemu with:
> -m 64G,slots=2,maxmem=66G -object memory-backend-ram,id=mem1,size=2G
> 
> (qemu) device_add pc-dimm,id=dimm1,memdev=mem1
> Block size [0x80000000] unaligned hotplug range: start 0x1040000000,
> 							size 0x80000000
> acpi PNP0C80:00: add_memory failed
> acpi PNP0C80:00: acpi_memory_enable_device() error
> acpi PNP0C80:00: Enumeration failure
> 
> With the fix memory is added successfully, as the block size is set to 1G,
> and therefore aligns with start address 0x1040000000.

I dunno. If x86 maintainers are OK with this then why not, but I do not
like how this is x86 specific. I would much rather address this by
making the memblock user interface more sane.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/x86/mm/init_64.c | 33 +++++++++++++++++++++++++++++----
>  1 file changed, 29 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 1ab42c852069..f7dc80364397 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1326,14 +1326,39 @@ int kern_addr_valid(unsigned long addr)
>  	return pfn_valid(pte_pfn(*pte));
>  }
>  
> +/*
> + * Block size is the minimum quantum of memory which can be hot-plugged or
> + * hot-removed. It must be power of two, and must be equal or larger than
> + * MIN_MEMORY_BLOCK_SIZE.
> + */
> +#define MAX_BLOCK_SIZE (2UL << 30)
> +
> +/* Amount of ram needed to start using large blocks */
> +#define MEM_SIZE_FOR_LARGE_BLOCK (64UL << 30)
> +
>  static unsigned long probe_memory_block_size(void)
>  {
> -	unsigned long bz = MIN_MEMORY_BLOCK_SIZE;
> +	unsigned long boot_mem_end = max_pfn << PAGE_SHIFT;
> +	unsigned long bz;
>  
> -	/* if system is UV or has 64GB of RAM or more, use large blocks */
> -	if (is_uv_system() || ((max_pfn << PAGE_SHIFT) >= (64UL << 30)))
> -		bz = 2UL << 30; /* 2GB */
> +	/* If this is UV system, always set 2G block size */
> +	if (is_uv_system()) {
> +		bz = MAX_BLOCK_SIZE;
> +		goto done;
> +	}
>  
> +	/* Use regular block if RAM is smaller than MEM_SIZE_FOR_LARGE_BLOCK */
> +	if (boot_mem_end < MEM_SIZE_FOR_LARGE_BLOCK) {
> +		bz = MIN_MEMORY_BLOCK_SIZE;
> +		goto done;
> +	}
> +
> +	/* Find the largest allowed block size that aligns to memory end */
> +	for (bz = MAX_BLOCK_SIZE; bz > MIN_MEMORY_BLOCK_SIZE; bz >>= 1) {
> +		if (IS_ALIGNED(boot_mem_end, bz))
> +			break;
> +	}
> +done:
>  	pr_info("x86/mm: Memory block size: %ldMB\n", bz >> 20);
>  
>  	return bz;
> -- 
> 2.16.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
