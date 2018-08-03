Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 732DF6B0271
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 16:07:23 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id x13-v6so1487887ljj.11
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 13:07:23 -0700 (PDT)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id u1-v6si2620744lji.295.2018.08.03.13.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 13:07:21 -0700 (PDT)
Date: Fri, 3 Aug 2018 22:07:18 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 1/2] sparc32: switch to NO_BOOTMEM
Message-ID: <20180803200718.GA7789@ravnborg.org>
References: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1533210833-14748-2-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1533210833-14748-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike.

A nice simplification of the arch code - with a potential to do much more.
Some review comments, see the following.

	Sam

On Thu, Aug 02, 2018 at 02:53:52PM +0300, Mike Rapoport wrote:
> Each populated sparc_phys_bank is added to memblock.memory. The
> reserve_bootmem() calls are replaced with memblock_reserve(), and the
> bootmem bitmap initialization is droppped.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> @@ -103,11 +104,15 @@ static unsigned long calc_max_low_pfn(void)
>  
>  unsigned long __init bootmem_init(unsigned long *pages_avail)
>  {
> -	unsigned long bootmap_size, start_pfn;
> +	unsigned long start_pfn;
>  	unsigned long end_of_phys_memory = 0UL;
> -	unsigned long bootmap_pfn, bytes_avail, size;
> +	unsigned long bytes_avail, size;
> +	unsigned long high_pages = 0UL;
>  	int i;
Variable definitions here, but assignments after definitions.
And sort the variable definitions as inverse christmas tree.
(Longest line first, sorter alpabetically if same length)

No reason to use "0UL" for simple zero assignments.

>  
> +	memblock_set_bottom_up(true);
> +	memblock_allow_resize();
> +
>  	bytes_avail = 0UL;
>  	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
>  		end_of_phys_memory = sp_banks[i].base_addr +
> @@ -124,12 +129,15 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
>  				if (sp_banks[i].num_bytes == 0) {
>  					sp_banks[i].base_addr = 0xdeadbeef;
>  				} else {
> +					memblock_add(sp_banks[i].base_addr,
> +						     sp_banks[i].num_bytes);
>  					sp_banks[i+1].num_bytes = 0;
>  					sp_banks[i+1].base_addr = 0xdeadbeef;
>  				}
>  				break;
>  			}
>  		}
> +		memblock_add(sp_banks[i].base_addr, sp_banks[i].num_bytes);

This parts looks OK.
You add the memory blocks to memblock that are relevant, and
ignore the block above a possible limit from the command
line (cmdline_memory_size).

>  	}
>  
>  	/* Start with page aligned address of last symbol in kernel
> @@ -140,8 +148,6 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
>  	/* Now shift down to get the real physical page frame number. */
>  	start_pfn >>= PAGE_SHIFT;
>  
> -	bootmap_pfn = start_pfn;
> -
OK, this is a bootmem artifact.


>  	max_pfn = end_of_phys_memory >> PAGE_SHIFT;
>  
>  	max_low_pfn = max_pfn;
> @@ -150,12 +156,16 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
>  	if (max_low_pfn > pfn_base + (SRMMU_MAXMEM >> PAGE_SHIFT)) {
>  		highstart_pfn = pfn_base + (SRMMU_MAXMEM >> PAGE_SHIFT);
>  		max_low_pfn = calc_max_low_pfn();
> +		high_pages = calc_highpages();
>  		printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
> -		    calc_highpages() >> (20 - PAGE_SHIFT));
> +		    high_pages >> (20 - PAGE_SHIFT));
This change looked un-related, but you need high_pages later. OK

>  	}
>  
>  #ifdef CONFIG_BLK_DEV_INITRD
> -	/* Now have to check initial ramdisk, so that bootmap does not overwrite it */
> +	/*
> +	 * Now have to check initial ramdisk, so that it won't pass
> +	 * the end of memory
> +	 */
This is a reformatting of a comment but you remove the "bootmap" reference.
Please reformat comment to saprc style. No empty "/*" so it should look like this:
	/* Now have to check initial ramdisk, so that it won't pass
	 * the end of memory
	 */

>  	if (sparc_ramdisk_image) {
>  		if (sparc_ramdisk_image >= (unsigned long)&_end - 2 * PAGE_SIZE)
>  			sparc_ramdisk_image -= KERNBASE;
> @@ -167,67 +177,25 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
>  			       initrd_end, end_of_phys_memory);
>  			initrd_start = 0;
>  		}
> -		if (initrd_start) {
> -			if (initrd_start >= (start_pfn << PAGE_SHIFT) &&
> -			    initrd_start < (start_pfn << PAGE_SHIFT) + 2 * PAGE_SIZE)
> -				bootmap_pfn = PAGE_ALIGN (initrd_end) >> PAGE_SHIFT;
> -		}
>  	}
> -#endif	
> -	/* Initialize the boot-time allocator. */
> -	bootmap_size = init_bootmem_node(NODE_DATA(0), bootmap_pfn, pfn_base,
> -					 max_low_pfn);
> -
> -	/* Now register the available physical memory with the
> -	 * allocator.
> -	 */
> -	*pages_avail = 0;
> -	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
> -		unsigned long curr_pfn, last_pfn;
> -
> -		curr_pfn = sp_banks[i].base_addr >> PAGE_SHIFT;
> -		if (curr_pfn >= max_low_pfn)
> -			break;
> -
> -		last_pfn = (sp_banks[i].base_addr + sp_banks[i].num_bytes) >> PAGE_SHIFT;
> -		if (last_pfn > max_low_pfn)
> -			last_pfn = max_low_pfn;
> -
> -		/*
> -		 * .. finally, did all the rounding and playing
> -		 * around just make the area go away?
> -		 */
> -		if (last_pfn <= curr_pfn)
> -			continue;
> +#endif
>  
> -		size = (last_pfn - curr_pfn) << PAGE_SHIFT;
> -		*pages_avail += last_pfn - curr_pfn;
> -
> -		free_bootmem(sp_banks[i].base_addr, size);
> -	}
Good to see all this code gone.

> +	*pages_avail = (memblock_phys_mem_size() >> PAGE_SHIFT) - high_pages;
Can we do this simpler?
memblock knows the amount of memory not reserved.
So we can ask memblock for the amount of non-reserved memory
at the end of this function and then we have the result.
Then we do not have to maintain pages_avail in the following code.

>  
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start) {
>  		/* Reserve the initrd image area. */
>  		size = initrd_end - initrd_start;
> -		reserve_bootmem(initrd_start, size, BOOTMEM_DEFAULT);
> +		memblock_reserve(initrd_start, size);
>  		*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
>  
>  		initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
> -		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;		
> +		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
This is a pure white space change, but leave it in.

>  	}
>  #endif
>  	/* Reserve the kernel text/data/bss. */
>  	size = (start_pfn << PAGE_SHIFT) - phys_base;
> -	reserve_bootmem(phys_base, size, BOOTMEM_DEFAULT);
> -	*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
> -
> -	/* Reserve the bootmem map.   We do not account for it
> -	 * in pages_avail because we will release that memory
> -	 * in free_all_bootmem.
> -	 */
> -	size = bootmap_size;
> -	reserve_bootmem((bootmap_pfn << PAGE_SHIFT), size, BOOTMEM_DEFAULT);
> +	memblock_reserve(phys_base, size);
>  	*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
>  
>  	return max_pfn;
> -- 
> 2.7.4
