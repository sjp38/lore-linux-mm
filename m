Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5BC6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 10:17:50 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d23-v6so8715638qtj.12
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 07:17:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q126-v6si2829030qka.249.2018.07.05.07.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 07:17:49 -0700 (PDT)
Message-ID: <535c14f5856b912fb4adb0c4c3c7bd16ae12c691.camel@redhat.com>
Subject: Re: [PATCH] c6x: switch to NO_BOOTMEM
From: Mark Salter <msalter@redhat.com>
Date: Thu, 05 Jul 2018 10:17:47 -0400
In-Reply-To: <20180704132510.GI4352@rapoport-lnx>
References: <1530101360-5768-1-git-send-email-rppt@linux.vnet.ibm.com>
	 <20180704132510.GI4352@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-c6x <linux-c6x-dev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, 2018-07-04 at 16:25 +0300, Mike Rapoport wrote:
> Any comments on this?
> 
> On Wed, Jun 27, 2018 at 03:09:20PM +0300, Mike Rapoport wrote:
> > The c6x is already using memblock and does most of early memory
> > reservations with it, so it was only a matter of removing the bootmem
> > initialization and handover of the memory from memblock to bootmem.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  arch/c6x/Kconfig        |  1 +
> >  arch/c6x/kernel/setup.c | 26 +-------------------------
> >  2 files changed, 2 insertions(+), 25 deletions(-)
> > 
> > diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
> > index bf59855628ac..054c7c963180 100644
> > --- a/arch/c6x/Kconfig
> > +++ b/arch/c6x/Kconfig
> > @@ -14,6 +14,7 @@ config C6X
> >  	select GENERIC_IRQ_SHOW
> >  	select HAVE_ARCH_TRACEHOOK
> >  	select HAVE_MEMBLOCK
> > +	select NO_BOOTMEM
> >  	select SPARSE_IRQ
> >  	select IRQ_DOMAIN
> >  	select OF
> > diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
> > index 786e36e2f61d..cc74cb9d349b 100644
> > --- a/arch/c6x/kernel/setup.c
> > +++ b/arch/c6x/kernel/setup.c
> > @@ -296,7 +296,6 @@ notrace void __init machine_init(unsigned long dt_ptr)
> > 
> >  void __init setup_arch(char **cmdline_p)
> >  {
> > -	int bootmap_size;
> >  	struct memblock_region *reg;
> > 
> >  	printk(KERN_INFO "Initializing kernel\n");
> > @@ -353,16 +352,6 @@ void __init setup_arch(char **cmdline_p)
> >  	init_mm.end_data   = memory_start;
> >  	init_mm.brk        = memory_start;
> > 
> > -	/*
> > -	 * Give all the memory to the bootmap allocator,  tell it to put the
> > -	 * boot mem_map at the start of memory
> > -	 */
> > -	bootmap_size = init_bootmem_node(NODE_DATA(0),
> > -					 memory_start >> PAGE_SHIFT,
> > -					 PAGE_OFFSET >> PAGE_SHIFT,
> > -					 memory_end >> PAGE_SHIFT);
> > -	memblock_reserve(memory_start, bootmap_size);
> > -
> >  	unflatten_device_tree();
> > 
> >  	c6x_cache_init();
> > @@ -397,22 +386,9 @@ void __init setup_arch(char **cmdline_p)
> >  	/* Initialize the coherent memory allocator */
> >  	coherent_mem_init(dma_start, dma_size);
> > 
> > -	/*
> > -	 * Free all memory as a starting point.
> > -	 */
> > -	free_bootmem(PAGE_OFFSET, memory_end - PAGE_OFFSET);
> > -
> > -	/*
> > -	 * Then reserve memory which is already being used.
> > -	 */
> > -	for_each_memblock(reserved, reg) {
> > -		pr_debug("reserved - 0x%08x-0x%08x\n",
> > -			 (u32) reg->base, (u32) reg->size);
> > -		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
> > -	}
> > -
> >  	max_low_pfn = PFN_DOWN(memory_end);
> >  	min_low_pfn = PFN_UP(memory_start);
> > +	max_pfn = max_low_pfn;
> >  	max_mapnr = max_low_pfn - min_low_pfn;
> > 
> >  	/* Get kmalloc into gear */
> > -- 
> > 2.7.4
> > 
> 
> 
Thanks. Looks fine. I'll pull it into c6x tree for next merge window.
