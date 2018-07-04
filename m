Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 166106B000A
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:25:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g1-v6so2224138edp.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:25:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k2-v6si3588428edf.196.2018.07.04.06.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 06:25:21 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w64DNevQ010880
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 09:25:19 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0xf2sxt2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 09:25:19 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 14:25:17 +0100
Date: Wed, 4 Jul 2018 16:25:11 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] c6x: switch to NO_BOOTMEM
References: <1530101360-5768-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530101360-5768-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180704132510.GI4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-c6x <linux-c6x-dev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Any comments on this?

On Wed, Jun 27, 2018 at 03:09:20PM +0300, Mike Rapoport wrote:
> The c6x is already using memblock and does most of early memory
> reservations with it, so it was only a matter of removing the bootmem
> initialization and handover of the memory from memblock to bootmem.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  arch/c6x/Kconfig        |  1 +
>  arch/c6x/kernel/setup.c | 26 +-------------------------
>  2 files changed, 2 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
> index bf59855628ac..054c7c963180 100644
> --- a/arch/c6x/Kconfig
> +++ b/arch/c6x/Kconfig
> @@ -14,6 +14,7 @@ config C6X
>  	select GENERIC_IRQ_SHOW
>  	select HAVE_ARCH_TRACEHOOK
>  	select HAVE_MEMBLOCK
> +	select NO_BOOTMEM
>  	select SPARSE_IRQ
>  	select IRQ_DOMAIN
>  	select OF
> diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
> index 786e36e2f61d..cc74cb9d349b 100644
> --- a/arch/c6x/kernel/setup.c
> +++ b/arch/c6x/kernel/setup.c
> @@ -296,7 +296,6 @@ notrace void __init machine_init(unsigned long dt_ptr)
> 
>  void __init setup_arch(char **cmdline_p)
>  {
> -	int bootmap_size;
>  	struct memblock_region *reg;
> 
>  	printk(KERN_INFO "Initializing kernel\n");
> @@ -353,16 +352,6 @@ void __init setup_arch(char **cmdline_p)
>  	init_mm.end_data   = memory_start;
>  	init_mm.brk        = memory_start;
> 
> -	/*
> -	 * Give all the memory to the bootmap allocator,  tell it to put the
> -	 * boot mem_map at the start of memory
> -	 */
> -	bootmap_size = init_bootmem_node(NODE_DATA(0),
> -					 memory_start >> PAGE_SHIFT,
> -					 PAGE_OFFSET >> PAGE_SHIFT,
> -					 memory_end >> PAGE_SHIFT);
> -	memblock_reserve(memory_start, bootmap_size);
> -
>  	unflatten_device_tree();
> 
>  	c6x_cache_init();
> @@ -397,22 +386,9 @@ void __init setup_arch(char **cmdline_p)
>  	/* Initialize the coherent memory allocator */
>  	coherent_mem_init(dma_start, dma_size);
> 
> -	/*
> -	 * Free all memory as a starting point.
> -	 */
> -	free_bootmem(PAGE_OFFSET, memory_end - PAGE_OFFSET);
> -
> -	/*
> -	 * Then reserve memory which is already being used.
> -	 */
> -	for_each_memblock(reserved, reg) {
> -		pr_debug("reserved - 0x%08x-0x%08x\n",
> -			 (u32) reg->base, (u32) reg->size);
> -		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
> -	}
> -
>  	max_low_pfn = PFN_DOWN(memory_end);
>  	min_low_pfn = PFN_UP(memory_start);
> +	max_pfn = max_low_pfn;
>  	max_mapnr = max_low_pfn - min_low_pfn;
> 
>  	/* Get kmalloc into gear */
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.
