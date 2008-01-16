Message-ID: <478E4889.5030208@sgi.com>
Date: Wed, 16 Jan 2008 10:10:17 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] x86: Change size of node ids from u8 to u16 V3
References: <20080116170902.006151000@sgi.com>	<20080116170902.328187000@sgi.com> <20080116185356.e8d02344.dada1@cosmosbay.com>
In-Reply-To: <20080116185356.e8d02344.dada1@cosmosbay.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Eric Dumazet wrote:
> On Wed, 16 Jan 2008 09:09:04 -0800
> travis@sgi.com wrote:
> 
>> Change the size of node ids from 8 bits to 16 bits to
>> accomodate more than 256 nodes.
>>
>> Signed-off-by: Mike Travis <travis@sgi.com>
>> Reviewed-by: Christoph Lameter <clameter@sgi.com>
>> ---
>> V1->V2:
>>     - changed pxm_to_node_map to u16
>>     - changed memnode map entries to u16
>> V2->V3:
>>     - changed memnode.embedded_map from [64-16] to [64-8]
>>       (and size comment to 128 bytes)
>> ---
>>  arch/x86/mm/numa_64.c       |    9 ++++++---
>>  arch/x86/mm/srat_64.c       |    2 +-
>>  drivers/acpi/numa.c         |    2 +-
>>  include/asm-x86/mmzone_64.h |    6 +++---
>>  include/asm-x86/numa_64.h   |    4 ++--
>>  include/asm-x86/topology.h  |    2 +-
>>  6 files changed, 14 insertions(+), 11 deletions(-)
> 
> I know new typedefs are not welcome, but in this case, it could be nice
> to define a fundamental type node_t (like pte_t, pmd_t, pgd_t, ...).
> 
> Clean NUMA code deserves it. 
> 
> #if MAX_NUMNODES > 256
> typedef u16 node_t;
> #else
> typedef u8 node_t;
> #endif
> 

Funny, I had this in originally and someone suggested that it was
superfluous. ;-)  But I agree, though I had called it numanode_t.
Even a cpu_t for size of the cpu index could be useful.

I'll wait for other opinions.

> In 2016, we can add u32 for MAX_NUMNODES > 65536

Probably 2010 is closer... ;-)

> 
> Another point: you want this change, sorry if my previous mail was not detailed enough :
> 
> --- a/arch/x86/mm/numa_64.c
> +++ b/arch/x86/mm/numa_64.c
> @@ -78,7 +78,7 @@ static int __init allocate_cachealigned_memnodemap(void)
>         unsigned long pad, pad_addr;
>  
>         memnodemap = memnode.embedded_map;
> -       if (memnodemapsize <= 48)
> +       if (memnodemapsize <= ARRAY_SIZE(memnode.embedded_map))
>                 return 0;
>  
>         pad = L1_CACHE_BYTES - 1;
> 
> 
> Thanks

Thanks!  This hash lookup is still a bit of a mystery to me.

I'll submit a 'fixup' patch momentarily, also removing:

--- linux.orig/arch/x86/mm/numa_64.c    2008-01-16 08:21:00.000000000 -0800
+++ linux/arch/x86/mm/numa_64.c 2008-01-16 09:57:27.168691249 -0800
@@ -35,8 +35,6 @@ u16 x86_cpu_to_node_map_init[NR_CPUS] __
        [0 ... NR_CPUS-1] = NUMA_NO_NODE
 };
 void *x86_cpu_to_node_map_early_ptr;
-EXPORT_SYMBOL(x86_cpu_to_node_map_init);
-EXPORT_SYMBOL(x86_cpu_to_node_map_early_ptr);
 DEFINE_PER_CPU(u16, x86_cpu_to_node_map) = NUMA_NO_NODE;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_node_map);

... to avoid section mismatches.

Thanks,
Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
