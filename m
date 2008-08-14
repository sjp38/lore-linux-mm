Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7EMZDT6006080
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 18:35:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7EMZDjm176054
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 18:35:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7EMZBvu028221
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 18:35:12 -0400
Subject: Re: sparsemem support for mips with highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48A4AC39.7020707@sciatl.com>
References: <48A4AC39.7020707@sciatl.com>
Content-Type: text/plain; charset=UTF-8
Date: Thu, 14 Aug 2008 15:35:08 -0700
Message-Id: <1218753308.23641.56.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-14 at 15:05 -0700, C Michael Sundius wrote:
> I just got sparsemem working on our MIPS 32 platform. I'm not sure if 
> anyone
> has done that before since there seems to be a couple of problems in the 
> arch specific code.
> 
> Well I realize that it is blazingly simple to turn on sparsemem, but for 
> the idiots (like myself)
> out there I created a howto file to put in the Documentation directory 
> just because I thought
> it would be a good idea to have some official info on  it written down 
> somewhere.
> 
> it saved me a ton of space by the way.  it seems to work great.

Cool!  Thanks for writing all that up.

>  arch/mips/kernel/setup.c     |   18 +++++++++++++++++-
>  arch/mips/mm/init.c          |    3 +++
>  include/asm-mips/sparsemem.h |    6 ++++++
>  3 files changed, 26 insertions(+), 1 deletions(-)

Wow!  25 lines of code.  Sparsemem is a pig! :)

> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index f8a535a..6ff0f72 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -405,7 +405,6 @@ static void __init bootmem_init(void)
> 
>  		/* Register lowmem ranges */
>  		free_bootmem(PFN_PHYS(start), size << PAGE_SHIFT);
> -		memory_present(0, start, end);
>  	}
> 
>  	/*
> @@ -417,6 +416,23 @@ static void __init bootmem_init(void)
>  	 * Reserve initrd memory if needed.
>  	 */
>  	finalize_initrd();
> +
> +	/* call memory present for all the ram */
> +	for (i = 0; i < boot_mem_map.nr_map; i++) {
> +		unsigned long start, end;
> +
> +		/*
> + * 		 * memory present only usable memory.
> + * 		 		 */

There's a wee bit of whitespace weirdness in here.  You might want to go
double-check it.

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

Is that aligning really necessary?  I'm just curious because if it is,
it would probably be good to stick it inside memory_present().

<snip>
> +Sparsemem divides up physical memory in your system into N section of M
> +bytes. Page tables are created for only those sections that
> +actually exist (as far as the sparsemem code is concerned). This allows
> +for holes in the physical memory without having to waste space by
> +creating page discriptors for those pages that do not exist.

descriptors

> +When page_to_pfn() or pfn_to_page() are called there is a bit of overhead to
> +look up the proper memory section to get to the page_table, but this
> +is small compared to the memory you are likely to save. So, it's not the
> +default, but should be used if you have big holes in physical memory.
> +
> +Note that discontiguous memory is more closely related to NUMA machines
> +and if you are a single CPU system use sparsemem and not discontig. 
> +It's much simpler. 
> +
> +1) CALL MEMORY_PRESENT()
> +Existing sections are recorded once the bootmem allocator is up and running by
> +calling the sparsemem function "memory_present(node, pfn_start, pfn_end)" for each
> +block of memory that exists in your physical address space. The
> +memory_present() function records valid sections in a data structure called
> +mem_section[].

I might reword this a bit, but it's not big deal:

Once the bootmem allocator is up and running, you should call the
sparsemem function i>>?"memory_present(node, pfn_start, pfn_end)" for each
block of memory that exists on your system.

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

Note: this would be a bug on both DISCONTIG and SPARSEMEM systems.  It
is a common one where ranges of physical memory are walked without
regard for whether there are 'struct page's backing those ares.  These
kinds of coding errors are perhaps the most common when converting from
FLATMEM to DISCONTIG/SPARSEMEM.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
