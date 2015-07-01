Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9619C6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 02:32:41 -0400 (EDT)
Received: by oiax193 with SMTP id x193so25028941oia.2
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 23:32:41 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id hm8si841084obb.87.2015.06.30.23.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 23:32:41 -0700 (PDT)
Message-ID: <559387EF.5050701@huawei.com>
Date: Wed, 1 Jul 2015 14:25:51 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mem-hotplug: Handle node hole when initializing numa_meminfo.
References: <1435720614-16480-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1435720614-16480-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2015/7/1 11:16, Tang Chen wrote:

> When parsing SRAT, all memory ranges are added into numa_meminfo.
> In numa_init(), before entering numa_cleanup_meminfo(), all possible
> memory ranges are in numa_meminfo. And numa_cleanup_meminfo() removes
> all ranges over max_pfn or empty.
> 
> But, this only works if the nodes are continuous. Let's have a look
> at the following example:
> 
> We have an SRAT like this:
> SRAT: Node 0 PXM 0 [mem 0x00000000-0x5fffffff]
> SRAT: Node 0 PXM 0 [mem 0x100000000-0x1ffffffffff]
> SRAT: Node 1 PXM 1 [mem 0x20000000000-0x3ffffffffff]
> SRAT: Node 4 PXM 2 [mem 0x40000000000-0x5ffffffffff] hotplug
> SRAT: Node 5 PXM 3 [mem 0x60000000000-0x7ffffffffff] hotplug
> SRAT: Node 2 PXM 4 [mem 0x80000000000-0x9ffffffffff] hotplug
> SRAT: Node 3 PXM 5 [mem 0xa0000000000-0xbffffffffff] hotplug
> SRAT: Node 6 PXM 6 [mem 0xc0000000000-0xdffffffffff] hotplug
> SRAT: Node 7 PXM 7 [mem 0xe0000000000-0xfffffffffff] hotplug
> 
> On boot, only node 0,1,2,3 exist.
> 
> And the numa_meminfo will look like this:
> numa_meminfo.nr_blks = 9
> 1. on node 0: [0, 60000000]
> 2. on node 0: [100000000, 20000000000]
> 3. on node 1: [20000000000, 40000000000]
> 4. on node 4: [40000000000, 60000000000]
> 5. on node 5: [60000000000, 80000000000]
> 6. on node 2: [80000000000, a0000000000]
> 7. on node 3: [a0000000000, a0800000000]
> 8. on node 6: [c0000000000, a0800000000]
> 9. on node 7: [e0000000000, a0800000000]
> 
> And numa_cleanup_meminfo() will merge 1 and 2, and remove 8,9 because
> the end address is over max_pfn, which is a0800000000. But 4 and 5
> are not removed because their end addresses are less then max_pfn.
> But in fact, node 4 and 5 don't exist.
> 
> In a word, numa_cleanup_meminfo() is not able to handle holes between nodes.
> 
> Since memory ranges in node 4 and 5 are in numa_meminfo, in numa_register_memblks(),
> node 4 and 5 will be mistakenly set to online.
> 
> In this patch, we use memblock_overlaps_region() to check if ranges in
> numa_meminfo overlap with ranges in memory_block. Since memory_block contains
> all available memory at boot time, if they overlap, it means the ranges
> exist. If not, then remove them from numa_meminfo.
> 

Hi Tang Chen,

What's the impact of this problem?

Command "numactl --hard" will show an empty node(no cpu and no memory,
but pgdat is created), right?

Thanks,
Xishi Qiu

> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/mm/numa.c       | 6 ++++--
>  include/linux/memblock.h | 2 ++
>  mm/memblock.c            | 2 +-
>  3 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 4053bb5..0c55cc5 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -246,8 +246,10 @@ int __init numa_cleanup_meminfo(struct numa_meminfo *mi)
>  		bi->start = max(bi->start, low);
>  		bi->end = min(bi->end, high);
>  
> -		/* and there's no empty block */
> -		if (bi->start >= bi->end)
> +		/* and there's no empty or non-exist block */
> +		if (bi->start >= bi->end ||
> +		    memblock_overlaps_region(&memblock.memory,
> +			bi->start, bi->end - bi->start) == -1)
>  			numa_remove_memblk_from(i--, mi);
>  	}
>  
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 0215ffd..3bf6cc1 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -77,6 +77,8 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
>  int memblock_free(phys_addr_t base, phys_addr_t size);
>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
>  void memblock_trim_memory(phys_addr_t align);
> +long memblock_overlaps_region(struct memblock_type *type,
> +			      phys_addr_t base, phys_addr_t size);
>  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 1b444c7..55b5f9f 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -91,7 +91,7 @@ static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, p
>  	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
>  }
>  
> -static long __init_memblock memblock_overlaps_region(struct memblock_type *type,
> +long __init_memblock memblock_overlaps_region(struct memblock_type *type,
>  					phys_addr_t base, phys_addr_t size)
>  {
>  	unsigned long i;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
