Received: from smtp21.orange.fr (mwinf2103 [10.232.7.25])
	by mwinf2115.orange.fr (SMTP Server) with ESMTP id BA88E1C09501
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 18:27:43 +0200 (CEST)
Message-ID: <48D3D2EF.5090808@cosmosbay.com>
Date: Fri, 19 Sep 2008 18:27:27 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [patch 3/4] cpu alloc: The allocator
References: <20080919145859.062069850@quilx.com> <20080919145929.158651064@quilx.com>
In-Reply-To: <20080919145929.158651064@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> The per cpu allocator allows dynamic allocation of memory on all
> processors simultaneously. A bitmap is used to track used areas.
> The allocator implements tight packing to reduce the cache footprint
> and increase speed since cacheline contention is typically not a concern
> for memory mainly used by a single cpu. Small objects will fill up gaps
> left by larger allocations that required alignments.
> 
> The size of the cpu_alloc area can be changed via the percpu=xxx
> kernel parameter.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  include/linux/percpu.h |   46 ++++++++++++
>  include/linux/vmstat.h |    2 
>  mm/Makefile            |    2 
>  mm/cpu_alloc.c         |  181 +++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmstat.c            |    1 
>  5 files changed, 230 insertions(+), 2 deletions(-)
>  create mode 100644 include/linux/cpu_alloc.h
>  create mode 100644 mm/cpu_alloc.c
> 
> Index: linux-2.6/include/linux/vmstat.h
> ===================================================================
> --- linux-2.6.orig/include/linux/vmstat.h	2008-09-19 09:45:02.000000000 -0500
> +++ linux-2.6/include/linux/vmstat.h	2008-09-19 09:49:05.000000000 -0500
> @@ -37,7 +37,7 @@
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
>  		FOR_ALL_ZONES(PGSCAN_DIRECT),
>  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> -		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		PAGEOUTRUN, ALLOCSTALL, PGROTATED, CPU_BYTES,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
>  #endif
> Index: linux-2.6/mm/Makefile
> ===================================================================
> --- linux-2.6.orig/mm/Makefile	2008-09-19 09:45:02.000000000 -0500
> +++ linux-2.6/mm/Makefile	2008-09-19 09:49:05.000000000 -0500
> @@ -11,7 +11,7 @@
>  			   maccess.o page_alloc.o page-writeback.o pdflush.o \
>  			   readahead.o swap.o truncate.o vmscan.o \
>  			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> -			   page_isolation.o mm_init.o $(mmu-y)
> +			   page_isolation.o mm_init.o cpu_alloc.o $(mmu-y)
>  
>  obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
>  obj-$(CONFIG_BOUNCE)	+= bounce.o
> Index: linux-2.6/mm/cpu_alloc.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/mm/cpu_alloc.c	2008-09-19 09:49:59.000000000 -0500
> @@ -0,0 +1,182 @@
> +/*
> + * Cpu allocator - Manage objects allocated for each processor
> + *
> + * (C) 2008 SGI, Christoph Lameter <cl@linux-foundation.org>
> + * 	Basic implementation with allocation and free from a dedicated per
> + * 	cpu area.
> + *
> + * The per cpu allocator allows a dynamic allocation of a piece of memory on
> + * every processor. A bitmap is used to track used areas.
> + * The allocator implements tight packing to reduce the cache footprint
> + * and increase speed since cacheline contention is typically not a concern
> + * for memory mainly used by a single cpu. Small objects will fill up gaps
> + * left by larger allocations that required alignments.
> + */
> +#include <linux/mm.h>
> +#include <linux/mmzone.h>
> +#include <linux/module.h>
> +#include <linux/percpu.h>
> +#include <linux/bitmap.h>
> +#include <asm/sections.h>
> +#include <linux/bootmem.h>
> +
> +/*
> + * Basic allocation unit. A bit map is created to track the use of each
> + * UNIT_SIZE element in the cpu area.
> + */
> +#define UNIT_TYPE int
> +#define UNIT_SIZE sizeof(UNIT_TYPE)
> +
> +int units;	/* Actual available units */
> +
> +/*
> + * How many units are needed for an object of a given size
> + */
> +static int size_to_units(unsigned long size)
> +{
> +	return DIV_ROUND_UP(size, UNIT_SIZE);
> +}
> +
> +/*
> + * Lock to protect the bitmap and the meta data for the cpu allocator.
> + */
> +static DEFINE_SPINLOCK(cpu_alloc_map_lock);
> +static unsigned long *cpu_alloc_map;
> +static int nr_units;		/* Number of available units */
> +static int first_free;		/* First known free unit */
> +
> +/*
> + * Mark an object as used in the cpu_alloc_map
> + *
> + * Must hold cpu_alloc_map_lock
> + */
> +static void set_map(int start, int length)
> +{
> +	while (length-- > 0)
> +		__set_bit(start++, cpu_alloc_map);
> +}
> +
> +/*
> + * Mark an area as freed.
> + *
> + * Must hold cpu_alloc_map_lock
> + */
> +static void clear_map(int start, int length)
> +{
> +	while (length-- > 0)
> +		__clear_bit(start++, cpu_alloc_map);
> +}
> +
> +/*
> + * Allocate an object of a certain size
> + *
> + * Returns a special pointer that can be used with CPU_PTR to find the
> + * address of the object for a certain cpu.
> + */
> +void *cpu_alloc(unsigned long size, gfp_t gfpflags, unsigned long align)
> +{
> +	unsigned long start;
> +	int units = size_to_units(size);
> +	void *ptr;
> +	int first;
> +	unsigned long flags;
> +
> +	if (!size)
> +		return ZERO_SIZE_PTR;
> +
> +	WARN_ON(align > PAGE_SIZE);

if (align < UNIT_SIZE)
	align = UNIT_SIZE;

> +
> +	spin_lock_irqsave(&cpu_alloc_map_lock, flags);
> +
> +	first = 1;
> +	start = first_free;
> +
> +	for ( ; ; ) {
> +
> +		start = find_next_zero_bit(cpu_alloc_map, nr_units, start);
> +		if (start >= nr_units)
> +			goto out_of_memory;
> +
> +		if (first)
> +			first_free = start;
> +
> +		/*
> +		 * Check alignment and that there is enough space after
> +		 * the starting unit.
> +		 */
> +		if (start % (align / UNIT_SIZE) == 0 &&

or else... divide per 0 ?

> +			find_next_bit(cpu_alloc_map, nr_units, start + 1)
> +					>= start + units)
> +				break;
> +		start++;
> +		first = 0;
> +	}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
