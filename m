Date: Tue, 26 Aug 2008 10:09:36 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: sparsemem support for mips with highmem
Message-ID: <20080826090936.GC29207@brain>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A4C542.5000308@sciatl.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 14, 2008 at 04:52:34PM -0700, C Michael Sundius wrote:
> fixed patch
>
>

Typically I was on holiday when you posted, how does that always happen.

> diff --git a/Documentation/sparsemem.txt b/Documentation/sparsemem.txt
> new file mode 100644
> index 0000000..6aea0d1
> --- /dev/null
> +++ b/Documentation/sparsemem.txt
> @@ -0,0 +1,93 @@
> +Sparsemem divides up physical memory in your system into N section of M
> +bytes. Page descriptors are created for only those sections that
> +actually exist (as far as the sparsemem code is concerned). This allows
> +for holes in the physical memory without having to waste space by
> +creating page discriptors for those pages that do not exist.
> +When page_to_pfn() or pfn_to_page() are called there is a bit of overhead to
> +look up the proper memory section to get to the descriptors, but this
> +is small compared to the memory you are likely to save. So, it's not the
> +default, but should be used if you have big holes in physical memory.
> +
> +Note that discontiguous memory is more closely related to NUMA machines
> +and if you are a single CPU system use sparsemem and not discontig. 
> +It's much simpler. 
> +
> +1) CALL MEMORY_PRESENT()
> +Once the bootmem allocator is up and running, you should call the
> +sparsemem function "memory_present(node, pfn_start, pfn_end)" for each
> +block of memory that exists on your system.
> +
> +2) DETERMINE AND SET THE SIZE OF SECTIONS AND PHYSMEM
> +The size of N and M above depend upon your architecture
> +and your platform and are specified in the file:
> +
> +      include/asm-<your_arch>/sparsemem.h
> +
> +and you should create the following lines similar to below: 
> +
> +	#ifdef CONFIG_YOUR_PLATFORM
> +	 #define SECTION_SIZE_BITS       27	/* 128 MiB */
> +	#endif
> +	#define MAX_PHYSMEM_BITS        31	/* 2 GiB   */

This example is slightly out of step with the reality of what you add.
I would have expected the two defines to cary together?

> +
> +if they don't already exist, where: 
> +
> + * SECTION_SIZE_BITS            2^M: how big each section will be
> + * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that
> +                                     space
> +
> +3) INITIALIZE SPARSE MEMORY
> +You should make sure that you initialize the sparse memory code by calling 
> +
> +	bootmem_init();
> +  +	sparse_init();
> +	paging_init();
> +
> +just before you call paging_init() and after the bootmem_allocator is
> +turned on in your setup_arch() code.  
> +
> +4) ENABLE SPARSEMEM IN KCONFIG
> +Add a line like this:
> +
> +	select ARCH_SPARSEMEM_ENABLE
> +
> +into the config for your platform in arch/<your_arch>/Kconfig. This will
> +ensure that turning on sparsemem is enabled for your platform. 

One other thing to to worry about here is turning any of the _ENABLEs
on tends to turn off the default models; particularly FLATMEM tends to
turn off if you don't explicitly ask for it.  So you may also need to
add entries for all of your models if none are already specified.

> +
> +5) CONFIG
> +Run make menuconfig or make gconfig, as you like, and turn on the sparsemem
> +memory model under the "Kernel Type" --> "Memory Model" and then build your
> +kernel.
> +
> +
> +6) Gotchas
> +
> +One trick that I encountered when I was turning this on for MIPS was that there
> +was some code in mem_init() that set the "reserved" flag for pages that were not
> +valid RAM. This caused my kernel to crash when I enabled sparsemem since those
> +pages (and page descriptors) didn't actually exist. I changed my code by adding
> +lines like below:
> +
> +
> +	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
> +		struct page *page = pfn_to_page(tmp);
> +
> +   +		if (!pfn_valid(tmp))
> +   +			continue;
> +   +
> +		if (!page_is_ram(tmp)) {
> +			SetPageReserved(page);
> +			continue;
> +		}
> +		ClearPageReserved(page);
> +		init_page_count(page);
> +		__free_page(page);
> +		physmem_record(PFN_PHYS(tmp), PAGE_SIZE, physmem_highmem);
> +		totalhigh_pages++;
> +	}
> +
> +
> +Once I got that straight, it worked!!!! I saved 10MiB of memory.  

That documentation is good whether the mips part is merged or not.  It
is probabally worth making it a separate patch.

> +
> +
> +
> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index c6a063b..5b1af87 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -408,7 +408,6 @@ static void __init bootmem_init(void)
>  
>  		/* Register lowmem ranges */
>  		free_bootmem(PFN_PHYS(start), size << PAGE_SHIFT);
> -		memory_present(0, start, end);
>  	}
>  
>  	/*
> @@ -420,6 +419,23 @@ static void __init bootmem_init(void)
>  	 * Reserve initrd memory if needed.
>  	 */
>  	finalize_initrd();
> +
> +	/* call memory present for all the ram */
> +	for (i = 0; i < boot_mem_map.nr_map; i++) {
> +		unsigned long start, end;
> +
> +		/*
> +		 * memory present only usable memory.
> +		 */
> +		if (boot_mem_map.map[i].type != BOOT_MEM_RAM)
> +			continue;
> +
> +		start = PFN_UP(boot_mem_map.map[i].addr);
> +		end   = PFN_DOWN(boot_mem_map.map[i].addr
> +				    + boot_mem_map.map[i].size);
> +
> +		memory_present(0, start, end);
> +	}
>  }
>  
>  #endif	/* CONFIG_SGI_IP27 */
> diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
> index 137c14b..31496a1 100644
> --- a/arch/mips/mm/init.c
> +++ b/arch/mips/mm/init.c
> @@ -414,6 +414,9 @@ void __init mem_init(void)
>  	for (tmp = highstart_pfn; tmp < highend_pfn; tmp++) {
>  		struct page *page = pfn_to_page(tmp);
>  
> +		if (!pfn_valid(tmp))
> +			continue;
> +
>  		if (!page_is_ram(tmp)) {
>  			SetPageReserved(page);
>  			continue;
> diff --git a/include/asm-mips/sparsemem.h b/include/asm-mips/sparsemem.h
> index 795ac6c..9faaf59 100644
> --- a/include/asm-mips/sparsemem.h
> +++ b/include/asm-mips/sparsemem.h
> @@ -6,8 +6,14 @@
>   * SECTION_SIZE_BITS		2^N: how big each section will be
>   * MAX_PHYSMEM_BITS		2^N: how much memory we can have in that space
>   */
> +
> +#ifndef CONFIG_64BIT
> +#define SECTION_SIZE_BITS       27	/* 128 MiB */
> +#define MAX_PHYSMEM_BITS        31	/* 2 GiB   */
> +#else
>  #define SECTION_SIZE_BITS       28
>  #define MAX_PHYSMEM_BITS        35
> +#endif
>  
>  #endif /* CONFIG_SPARSEMEM */
>  #endif /* _MIPS_SPARSEMEM_H */

Otherwise it looks good to me.  I see from the rest of the thread that
there is some discussion over the sizes of these, with that sorted.

Acked-by: Andy Whitcroft <apw@shadowen.org>

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
