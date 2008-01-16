Date: Wed, 16 Jan 2008 18:53:56 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 02/10] x86: Change size of node ids from u8 to u16 V3
Message-Id: <20080116185356.e8d02344.dada1@cosmosbay.com>
In-Reply-To: <20080116170902.328187000@sgi.com>
References: <20080116170902.006151000@sgi.com>
	<20080116170902.328187000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008 09:09:04 -0800
travis@sgi.com wrote:

> Change the size of node ids from 8 bits to 16 bits to
> accomodate more than 256 nodes.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Reviewed-by: Christoph Lameter <clameter@sgi.com>
> ---
> V1->V2:
>     - changed pxm_to_node_map to u16
>     - changed memnode map entries to u16
> V2->V3:
>     - changed memnode.embedded_map from [64-16] to [64-8]
>       (and size comment to 128 bytes)
> ---
>  arch/x86/mm/numa_64.c       |    9 ++++++---
>  arch/x86/mm/srat_64.c       |    2 +-
>  drivers/acpi/numa.c         |    2 +-
>  include/asm-x86/mmzone_64.h |    6 +++---
>  include/asm-x86/numa_64.h   |    4 ++--
>  include/asm-x86/topology.h  |    2 +-
>  6 files changed, 14 insertions(+), 11 deletions(-)

I know new typedefs are not welcome, but in this case, it could be nice
to define a fundamental type node_t (like pte_t, pmd_t, pgd_t, ...).

Clean NUMA code deserves it. 

#if MAX_NUMNODES > 256
typedef u16 node_t;
#else
typedef u8 node_t;
#endif

In 2016, we can add u32 for MAX_NUMNODES > 65536

Another point: you want this change, sorry if my previous mail was not detailed enough :

--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -78,7 +78,7 @@ static int __init allocate_cachealigned_memnodemap(void)
        unsigned long pad, pad_addr;
 
        memnodemap = memnode.embedded_map;
-       if (memnodemapsize <= 48)
+       if (memnodemapsize <= ARRAY_SIZE(memnode.embedded_map))
                return 0;
 
        pad = L1_CACHE_BYTES - 1;


Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
