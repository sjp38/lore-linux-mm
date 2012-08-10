Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6A04A6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 05:43:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 977EC3EE0AE
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:43:43 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7710845DE56
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:43:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56C3D45DE54
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:43:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 47C2F1DB804E
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:43:43 +0900 (JST)
Received: from g01jpexchkw07.g01.fujitsu.local (g01jpexchkw07.g01.fujitsu.local [10.0.194.46])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 014821DB8045
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:43:43 +0900 (JST)
Message-ID: <5024D7AD.3000909@jp.fujitsu.com>
Date: Fri, 10 Aug 2012 18:43:09 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: introduce N_LRU_MEMORY to distinguish between
 normal and movable memory
References: <1344482788-4984-1-git-send-email-guohanjun@huawei.com> <50233EF5.3050605@huawei.com>
In-Reply-To: <50233EF5.3050605@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>, laijs@cn.fujitsu.com
Cc: Christoph Lameter <cl@linux-foundation.org>, Wu Jianguo <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Hi Guo,

I have a question. How do you create the offlinable node? The current linux
cannot offline all memory on node. So we cannot hit the bug.

Recently Lai sent the following patches which create the movable node.
I think these patches consider the problem.

https://lkml.org/lkml/2012/8/6/113
=> Hi Lai,
    I think your patches slove Guo's problem. How do you think?

Thanks,
Yasuaki Ishimatu

2012/08/09 13:39, Hanjun Guo wrote:
> From: Wu Jianguo <wujianguo@huawei.com>
>
> Hi all,
> Now, We have node masks for both N_NORMAL_MEMORY and
> N_HIGH_MEMORY to distinguish between normal and highmem on platforms such as x86.
> But we still don't have such a mechanism to distinguish between "normal" and "movable"
> memory.
>
> As suggested by Christoph Lameter in threads
> http://marc.info/?l=linux-mm&m=134323057602484&w=2, we introduce N_LRU_MEMORY to
> distinguish between "normal" and "movable" memory.
>
> And this patch will fix the bug described as follow:
>
> When handling a memory node with only movable zone, function
> early_kmem_cache_node_alloc() will allocate a page from remote node but
> still increase object count on local node, which will trigger a BUG_ON()
> as below when hot-removing this memory node. Actually there's no need to
> create kmem_cache_node for memory node with only movable zone at all.
>
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:3590!
> invalid opcode: 0000 [#1] SMP
> CPU 61
> Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table
> mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables
> ipv6 vfat fat dm_mirror dm_region_hash dm_log uinput iTCO_wdt
> iTCO_vendor_support coretemp hwmon kvm_intel kvm crc32c_intel
> ghash_clmulni_intel serio_raw pcspkr cdc_ether usbnet mii i2c_i801 i2c_core sg
> lpc_ich mfd_core shpchp ioatdma i7core_edac edac_core igb dca bnx2 ext4
> mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif aesni_intel cryptd aes_x86_64
> aes_generic bfa scsi_transport_fc scsi_tgt pata_acpi ata_generic ata_piix
> megaraid_sas dm_mod [last unloaded: microcode]
>
> Pid: 46287, comm: sh Not tainted 3.5.0-rc4-pgtable-00215-g35f0828-dirty #85
> IBM System x3850 X5 -[7143O3G]-/Node 1, Processor Card
> RIP: 0010:[<ffffffff81160b2a>]  [<ffffffff81160b2a>]
> slab_memory_callback+0x1ba/0x1c0
> RSP: 0018:ffff880efdcb7c68  EFLAGS: 00010202
> RAX: 0000000000000001 RBX: ffff880f7ec06100 RCX: 0000000100400001
> RDX: 0000000100400002 RSI: ffff880f7ec02000 RDI: ffff880f7ec06100
> RBP: ffff880efdcb7c78 R08: ffff88107b6fb098 R09: ffffffff81160a00
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000019
> R13: 00000000fffffffb R14: 0000000000000000 R15: ffffffff81abe930
> FS:  00007f709f342700(0000) GS:ffff880f7f3a0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000003b5a874570 CR3: 0000000f0da20000 CR4: 00000000000007e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process sh (pid: 46287, threadinfo ffff880efdcb6000, task ffff880f0fa50000)
> Stack:
>   0000000000000004 ffff880efdcb7da8 ffff880efdcb7cb8 ffffffff81524af5
>   0000000000000001 ffffffff81a8b620 ffffffff81a8b640 0000000000000004
>   ffff880efdcb7da8 00000000ffffffff ffff880efdcb7d08 ffffffff8107a89a
> Call Trace:
>   [<ffffffff81524af5>] notifier_call_chain+0x55/0x80
>   [<ffffffff8107a89a>] __blocking_notifier_call_chain+0x5a/0x80
>   [<ffffffff8107a8d6>] blocking_notifier_call_chain+0x16/0x20
>   [<ffffffff81352f0b>] memory_notify+0x1b/0x20
>   [<ffffffff81507104>] offline_pages+0x624/0x700
>   [<ffffffff811619de>] remove_memory+0x1e/0x20
>   [<ffffffff813530cc>] memory_block_change_state+0x13c/0x2e0
>   [<ffffffff81153e96>] ? alloc_pages_current+0xb6/0x120
>   [<ffffffff81353332>] store_mem_state+0xc2/0xd0
>   [<ffffffff8133e190>] dev_attr_store+0x20/0x30
>   [<ffffffff811e2d4f>] sysfs_write_file+0xef/0x170
>   [<ffffffff81173e28>] vfs_write+0xc8/0x190
>   [<ffffffff81173ff1>] sys_write+0x51/0x90
>   [<ffffffff81528d29>] system_call_fastpath+0x16/0x1b
> Code: 8b 3d cb fd c4 00 be d0 00 00 00 e8 71 de ff ff 48 85 c0 75 9c 48 c7 c7
> c0 7f a5 81 e8 c0 89 f1 ff b8 0d 80 00 00 e9 69 fe ff ff <0f> 0b eb fe 66 90
> 55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83
> RIP  [<ffffffff81160b2a>] slab_memory_callback+0x1ba/0x1c0
>   RSP <ffff880efdcb7c68>
> ---[ end trace 749e9e9a67c78c12 ]---
>
> Signed-off-by: Wu Jianguo <wujianguo@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>   arch/alpha/mm/numa.c     |    2 +-
>   arch/m32r/mm/discontig.c |    2 +-
>   arch/m68k/mm/motorola.c  |    2 +-
>   arch/parisc/mm/init.c    |    2 +-
>   arch/tile/kernel/setup.c |    2 +-
>   arch/x86/mm/init_64.c    |    2 +-
>   drivers/base/node.c      |    4 +++-
>   include/linux/nodemask.h |    5 +++--
>   mm/page_alloc.c          |   10 ++++++++--
>   9 files changed, 20 insertions(+), 11 deletions(-)
>
> diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
> index 3973ae3..8402b29 100644
> --- a/arch/alpha/mm/numa.c
> +++ b/arch/alpha/mm/numa.c
> @@ -313,7 +313,7 @@ void __init paging_init(void)
>   			zones_size[ZONE_DMA] = dma_local_pfn;
>   			zones_size[ZONE_NORMAL] = (end_pfn - start_pfn) - dma_local_pfn;
>   		}
> -		node_set_state(nid, N_NORMAL_MEMORY);
> +		node_set_state(nid, N_LRU_MEMORY);
>   		free_area_init_node(nid, zones_size, start_pfn, NULL);
>   	}
>
> diff --git a/arch/m32r/mm/discontig.c b/arch/m32r/mm/discontig.c
> index 2c468e8..4d76e19 100644
> --- a/arch/m32r/mm/discontig.c
> +++ b/arch/m32r/mm/discontig.c
> @@ -149,7 +149,7 @@ unsigned long __init zone_sizes_init(void)
>   		zholes_size[ZONE_DMA] = mp->holes;
>   		holes += zholes_size[ZONE_DMA];
>
> -		node_set_state(nid, N_NORMAL_MEMORY);
> +		node_set_state(nid, N_LRU_MEMORY);
>   		free_area_init_node(nid, zones_size, start_pfn, zholes_size);
>   	}
>
> diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
> index 0dafa69..31a0b00 100644
> --- a/arch/m68k/mm/motorola.c
> +++ b/arch/m68k/mm/motorola.c
> @@ -300,7 +300,7 @@ void __init paging_init(void)
>   		free_area_init_node(i, zones_size,
>   				    m68k_memory[i].addr >> PAGE_SHIFT, NULL);
>   		if (node_present_pages(i))
> -			node_set_state(i, N_NORMAL_MEMORY);
> +			node_set_state(i, N_LRU_MEMORY);
>   	}
>   }
>
> diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
> index 3ac462d..ad286fd 100644
> --- a/arch/parisc/mm/init.c
> +++ b/arch/parisc/mm/init.c
> @@ -277,7 +277,7 @@ static void __init setup_bootmem(void)
>   	memset(pfnnid_map, 0xff, sizeof(pfnnid_map));
>
>   	for (i = 0; i < npmem_ranges; i++) {
> -		node_set_state(i, N_NORMAL_MEMORY);
> +		node_set_state(i, N_LRU_MEMORY);
>   		node_set_online(i);
>   	}
>   #endif
> diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
> index 6a649a4..464672d 100644
> --- a/arch/tile/kernel/setup.c
> +++ b/arch/tile/kernel/setup.c
> @@ -748,7 +748,7 @@ static void __init zone_sizes_init(void)
>
>   		/* Track the type of memory on each node */
>   		if (zones_size[ZONE_NORMAL] || zones_size[ZONE_DMA])
> -			node_set_state(i, N_NORMAL_MEMORY);
> +			node_set_state(i, N_LRU_MEMORY);
>   #ifdef CONFIG_HIGHMEM
>   		if (end != start)
>   			node_set_state(i, N_HIGH_MEMORY);
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 2b6b4a3..43bf392 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -625,7 +625,7 @@ void __init paging_init(void)
>   	 *	 numa support is not compiled in, and later node_set_state
>   	 *	 will not set it back.
>   	 */
> -	node_clear_state(0, N_NORMAL_MEMORY);
> +	node_clear_state(0, N_LRU_MEMORY);
>
>   	zone_sizes_init();
>   }
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index af1a177..4a631f9 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -617,6 +617,7 @@ static struct node_attr node_state_attr[] = {
>   	_NODE_ATTR(possible, N_POSSIBLE),
>   	_NODE_ATTR(online, N_ONLINE),
>   	_NODE_ATTR(has_normal_memory, N_NORMAL_MEMORY),
> +	_NODE_ATTR(has_lru_memory, N_LRU_MEMORY),
>   	_NODE_ATTR(has_cpu, N_CPU),
>   #ifdef CONFIG_HIGHMEM
>   	_NODE_ATTR(has_high_memory, N_HIGH_MEMORY),
> @@ -628,8 +629,9 @@ static struct attribute *node_state_attrs[] = {
>   	&node_state_attr[1].attr.attr,
>   	&node_state_attr[2].attr.attr,
>   	&node_state_attr[3].attr.attr,
> -#ifdef CONFIG_HIGHMEM
>   	&node_state_attr[4].attr.attr,
> +#ifdef CONFIG_HIGHMEM
> +	&node_state_attr[5].attr.attr,
>   #endif
>   	NULL
>   };
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index 7afc363..550f9a1 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -374,11 +374,12 @@ static inline void __nodes_fold(nodemask_t *dstp, const nodemask_t *origp,
>   enum node_states {
>   	N_POSSIBLE,		/* The node could become online at some point */
>   	N_ONLINE,		/* The node is online */
> -	N_NORMAL_MEMORY,	/* The node has regular memory */
> +	N_NORMAL_MEMORY,	/* The node has normal memory */
> +	N_LRU_MEMORY,	/* The node has regular memory */
>   #ifdef CONFIG_HIGHMEM
>   	N_HIGH_MEMORY,		/* The node has regular or high memory */
>   #else
> -	N_HIGH_MEMORY = N_NORMAL_MEMORY,
> +	N_HIGH_MEMORY = N_LRU_MEMORY,
>   #endif
>   	N_CPU,		/* The node has one or more cpus */
>   	NR_NODE_STATES
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 009ac28..5a7eacb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -87,6 +87,7 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
>   	[N_ONLINE] = { { [0] = 1UL } },
>   #ifndef CONFIG_NUMA
>   	[N_NORMAL_MEMORY] = { { [0] = 1UL } },
> +	[N_LRU_MEMORY] = { { [0] = 1UL } },
>   #ifdef CONFIG_HIGHMEM
>   	[N_HIGH_MEMORY] = { { [0] = 1UL } },
>   #endif
> @@ -4796,16 +4797,21 @@ out:
>   /* Any regular memory on that node ? */
>   static void __init check_for_regular_memory(pg_data_t *pgdat)
>   {
> -#ifdef CONFIG_HIGHMEM
> +	struct zone *zone;
>   	enum zone_type zone_type;
>
>   	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
> -		struct zone *zone = &pgdat->node_zones[zone_type];
> +		zone = &pgdat->node_zones[zone_type];
>   		if (zone->present_pages) {
>   			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
>   			break;
>   		}
>   	}
> +
> +#ifdef CONFIG_HIGHMEM
> +	zone = &pgdat->node_zones[ZONE_MOVABLE];
> +	if (zone->present_pages)
> +		node_set_state(zone_to_nid(zone), N_LRU_MEMORY);
>   #endif
>   }
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
