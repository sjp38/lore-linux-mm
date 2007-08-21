Date: Tue, 21 Aug 2007 16:49:45 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC][PATCH 9/9] pagemap: export swap ptes
Message-ID: <20070821214944.GL30556@waste.org>
References: <20070821204248.0F506A29@kernel> <20070821204259.1F6E8A44@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070821204259.1F6E8A44@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 21, 2007 at 01:42:59PM -0700, Dave Hansen wrote:
> 
> In addition to understanding which physical pages are
> used by a process, it would also be very nice to
> enumerate how much swap space a process is using.
> 
> This patch enables /proc/<pid>/pagemap to display
> swap ptes.  In the process, it also changes the
> constant that we used to indicate non-present ptes
> before.

Nice. Can you update the doc comment on pagemap_read to match? 

> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> ---
> 
>  lxc-dave/fs/proc/task_mmu.c |   29 ++++++++++++++++++++++++++---
>  1 file changed, 26 insertions(+), 3 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~pagemap-export-swap-ptes fs/proc/task_mmu.c
> --- lxc/fs/proc/task_mmu.c~pagemap-export-swap-ptes	2007-08-21 13:30:55.000000000 -0700
> +++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:55.000000000 -0700
> @@ -7,6 +7,8 @@
>  #include <linux/pagemap.h>
>  #include <linux/ptrace.h>
>  #include <linux/mempolicy.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
>  
>  #include <asm/elf.h>
>  #include <asm/uaccess.h>
> @@ -506,9 +508,13 @@ struct pagemapread {
>  	int index;
>  	unsigned long __user *out;
>  };
> -
>  #define PM_ENTRY_BYTES sizeof(unsigned long)
> -#define PM_NOT_PRESENT ((unsigned long)-1)
> +#define PM_RESERVED_BITS	3
> +#define PM_RESERVED_OFFSET	(BITS_PER_LONG-PM_RESERVED_BITS)
> +#define PM_RESERVED_MASK	(((1<<PM_RESERVED_BITS)-1) << PM_RESERVED_OFFSET)
> +#define PM_SPECIAL(nr)		(((nr) << PM_RESERVED_OFFSET) | PM_RESERVED_MASK)
> +#define PM_NOT_PRESENT	PM_SPECIAL(1)
> +#define PM_SWAP		PM_SPECIAL(2)
>  #define PAGEMAP_END_OF_BUFFER 1
>  
>  static int add_to_pagemap(unsigned long addr, unsigned long pfn,
> @@ -539,6 +545,21 @@ static int pagemap_pte_hole(unsigned lon
>  	return err;
>  }
>  
> +unsigned long swap_pte_to_pagemap_entry(pte_t pte)
> +{
> +	unsigned long ret = 0;

Unused assignment?

> +	swp_entry_t entry = pte_to_swp_entry(pte);
> +	unsigned long offset;
> +	unsigned long swap_file_nr;
> +
> +	offset = swp_offset(entry);
> +	swap_file_nr = swp_type(entry);
> +	ret = PM_SWAP | swap_file_nr | (offset << MAX_SWAPFILES_SHIFT);
> +	return ret;

How about just return <expression>?

> +}

This is a little problematic as we've added another not very visible
magic number to the mix. We're also not masking off swp_offset to
avoid colliding with our reserved bits. And we're also unpacking an
arch-independent value (swp_entry_t) just to repack it in more or less
the same shape? Or are we reversing the fields?

>  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			     void *private)
>  {
> @@ -549,7 +570,9 @@ static int pagemap_pte_range(pmd_t *pmd,
>  	pte = pte_offset_map(pmd, addr);
>  	for (; addr != end; pte++, addr += PAGE_SIZE) {
>  		unsigned long pfn = PM_NOT_PRESENT;
> -		if (pte_present(*pte))
> +		if (is_swap_pte(*pte))

Hmm, unlikely?

> +			pfn = swap_pte_to_pagemap_entry(*pte);
> +		else if (pte_present(*pte))
>  			pfn = pte_pfn(*pte);
>  		err = add_to_pagemap(addr, pfn, pm);
>  		if (err)
> _

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
