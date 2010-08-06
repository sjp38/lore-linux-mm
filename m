Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 280586B02A9
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 18:50:53 -0400 (EDT)
Subject: Re: [PATCH 08/43] memblock/microblaze: Use new accessors
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4C5BCD41.3040501@monstr.eu>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
	 <1281071724-28740-9-git-send-email-benh@kernel.crashing.org>
	 <4C5BCD41.3040501@monstr.eu>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 07 Aug 2010 08:50:46 +1000
Message-ID: <1281135046.2168.40.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: monstr@monstr.eu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-06 at 10:52 +0200, Michal Simek wrote:
> Benjamin Herrenschmidt wrote:
> > CC: Michal Simek <monstr@monstr.eu>
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> This patch remove bug which I reported but there is another place which 
> needs to be changed.
> 
> I am not sure if my patch is correct but at least point you on places 
> which is causing compilation errors.
> 
> I tested your memblock branch with this fix and microblaze can boot.

Ok, that's missing in my initial rename patch. I'll fix it up. Thanks.

Cheers,
Ben.

> Thanks,
> Michal
> 
>    CC      arch/microblaze/mm/init.o
> arch/microblaze/mm/init.c: In function 'mm_cmdline_setup':
> arch/microblaze/mm/init.c:236: error: 'struct memblock_type' has no 
> member named 'region'
> arch/microblaze/mm/init.c: In function 'mmu_init':
> arch/microblaze/mm/init.c:279: error: 'struct memblock_type' has no 
> member named 'region'
> arch/microblaze/mm/init.c:284: error: 'struct memblock_type' has no 
> member named 'region'
> arch/microblaze/mm/init.c:285: error: 'struct memblock_type' has no 
> member named 'region'
> arch/microblaze/mm/init.c:286: error: 'struct memblock_type' has no 
> member named 'region'
> make[1]: *** [arch/microblaze/mm/init.o] Error 1
> make: *** [arch/microblaze/mm] Error 2
> 
> 
> diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> index 32a702b..a9d7b9b 100644
> --- a/arch/microblaze/mm/init.c
> +++ b/arch/microblaze/mm/init.c
> @@ -233,7 +233,7 @@ static void mm_cmdline_setup(void)
>                  if (maxmem && memory_size > maxmem) {
>                          memory_size = maxmem;
>                          memory_end = memory_start + memory_size;
> -                       memblock.memory.region[0].size = memory_size;
> +                       memblock.memory.regions[0].size = memory_size;
>                  }
>          }
>   }
> @@ -276,14 +276,14 @@ asmlinkage void __init mmu_init(void)
>                  machine_restart(NULL);
>          }
> 
> -       if ((u32) memblock.memory.region[0].size < 0x1000000) {
> +       if ((u32) memblock.memory.regions[0].size < 0x1000000) {
>                  printk(KERN_EMERG "Memory must be greater than 16MB\n");
>                  machine_restart(NULL);
>          }
>          /* Find main memory where the kernel is */
> -       memory_start = (u32) memblock.memory.region[0].base;
> -       memory_end = (u32) memblock.memory.region[0].base +
> -                               (u32) memblock.memory.region[0].size;
> +       memory_start = (u32) memblock.memory.regions[0].base;
> +       memory_end = (u32) memblock.memory.regions[0].base +
> +                               (u32) memblock.memory.regions[0].size;
>          memory_size = memory_end - memory_start;
> 
>          mm_cmdline_setup(); /* FIXME parse args from command line - not 
> used */
> 
> 
> 
> > ---
> >  arch/microblaze/mm/init.c |   20 +++++++++-----------
> >  1 files changed, 9 insertions(+), 11 deletions(-)
> > 
> > diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> > index afd6494..32a702b 100644
> > --- a/arch/microblaze/mm/init.c
> > +++ b/arch/microblaze/mm/init.c
> > @@ -70,16 +70,16 @@ static void __init paging_init(void)
> >  
> >  void __init setup_memory(void)
> >  {
> > -	int i;
> >  	unsigned long map_size;
> > +	struct memblock_region *reg;
> > +
> >  #ifndef CONFIG_MMU
> >  	u32 kernel_align_start, kernel_align_size;
> >  
> >  	/* Find main memory where is the kernel */
> > -	for (i = 0; i < memblock.memory.cnt; i++) {
> > -		memory_start = (u32) memblock.memory.regions[i].base;
> > -		memory_end = (u32) memblock.memory.regions[i].base
> > -				+ (u32) memblock.memory.region[i].size;
> > +	for_each_memblock(memory, reg) {
> > +		memory_start = (u32)reg->base;
> > +		memory_end = (u32) reg->base + reg->size;
> >  		if ((memory_start <= (u32)_text) &&
> >  					((u32)_text <= memory_end)) {
> >  			memory_size = memory_end - memory_start;
> > @@ -147,12 +147,10 @@ void __init setup_memory(void)
> >  	free_bootmem(memory_start, memory_size);
> >  
> >  	/* reserve allocate blocks */
> > -	for (i = 0; i < memblock.reserved.cnt; i++) {
> > -		pr_debug("reserved %d - 0x%08x-0x%08x\n", i,
> > -			(u32) memblock.reserved.region[i].base,
> > -			(u32) memblock_size_bytes(&memblock.reserved, i));
> > -		reserve_bootmem(memblock.reserved.region[i].base,
> > -			memblock_size_bytes(&memblock.reserved, i) - 1, BOOTMEM_DEFAULT);
> > +	for_each_memblock(reserved, reg) {
> > +		pr_debug("reserved - 0x%08x-0x%08x\n",
> > +			 (u32) reg->base, (u32) reg->size);
> > +		reserve_bootmem(reg->base, reg->size, BOOTMEM_DEFAULT);
> >  	}
> >  #ifdef CONFIG_MMU
> >  	init_bootmem_done = 1;
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
