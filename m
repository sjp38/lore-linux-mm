Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6CIUSM7275240
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 14:30:28 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j6CIURvb234356
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 12:30:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6CIUQeT013236
	for <linux-mm@kvack.org>; Tue, 12 Jul 2005 12:30:27 -0600
Date: Tue, 12 Jul 2005 11:30:21 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-ID: <20050712183021.GC3987@w-mikek2.ibm.com>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 12, 2005 at 03:50:09PM +0900, Yasunori Goto wrote:
> Index: allocbootmem/mm/bootmem.c
> ===================================================================
> --- allocbootmem.orig/mm/bootmem.c	2005-06-30 11:57:13.000000000 +0900
> +++ allocbootmem/mm/bootmem.c	2005-07-08 20:46:56.209040741 +0900
> @@ -387,10 +387,16 @@
>  	pg_data_t *pgdat = pgdat_list;
>  	void *ptr;
>  
> -	for_each_pgdat(pgdat)
> +	for_each_pgdat(pgdat){
> +
> +		if (goal < __pa(MAX_DMA_ADDRESS) &&
> +		    pgdat->bdata->node_boot_start >= __pa(MAX_DMA_ADDRESS))
> +			continue; /* Skip No DMA node */
> +
>  		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
>  						align, goal)))
>  			return(ptr);
> +	}
>  
>  	/*
>  	 * Whoops, we cannot satisfy the allocation request.

Need to be careful about the use of MAX_DMA_ADDRESS.  It is not always
the case that archs define MAX_DMA_ADDRESS as a real address.  In some
cases, MAX_DMA_ADDRESS is defined as something like -1 to indicate that
all addresses are available for DMA.  I'm not sure that the above code
will always work as desired in such cases.

FYI - While hacking on the memory hotplug code, I added a special
'#define MAX_DMA_PHYSADDR' to get around this issue on such architectures.
Most likely, this isn't elegant enough as a real solution.  But it does
point out that __pa(MAX_DMA_ADDRESS) doesn't always give you what you
expect.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
