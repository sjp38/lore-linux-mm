Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DC34B6B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 19:45:13 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so4541494pdi.3
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 16:45:13 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id sf10si180959pac.3.2014.10.26.16.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Oct 2014 16:45:12 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5363B3EE0C5
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:45:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 244EAAC0305
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:45:10 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C81BB1DB803A
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:45:09 +0900 (JST)
Message-ID: <544D8709.9020101@jp.fujitsu.com>
Date: Mon, 27 Oct 2014 08:43:05 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] mem-hotplug: Reset node managed pages when hot-adding
 a new pgdat.
References: <1414243866-5853-1-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1414243866-5853-1-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, santosh.shilimkar@ti.com, yinghai@kernel.org, grygorii.strashko@ti.com, tj@kernel.org, toshi.kani@hp.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2014/10/25 22:31), Tang Chen wrote:
> In free_area_init_core(), zone->managed_pages is set to an approximate
> value for lowmem, and will be adjusted when the bootmem allocator frees
> pages into the buddy system. But free_area_init_core() is also called
> by hotadd_new_pgdat() when hot-adding memory. As a result, zone->managed_pages
> of the newly added node's pgdat is set to an approximate value in the
> very beginning. Even if the memory on that node has node been onlined,
> /sys/device/system/node/nodeXXX/meminfo has wrong value.
> 
> hot-add node2 (memory not onlined)
> cat /sys/device/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB
> Node 2 MemFree:               0 kB
> Node 2 MemUsed:        33554432 kB
> Node 2 Active:                0 kB
> 
> This patch fixes this problem by reset node managed pages to 0 after hot-adding
> a new node.
> 
> 1. Move reset_managed_pages_done from reset_node_managed_pages() to reset_all_zones_managed_pages()
> 2. Make reset_node_managed_pages() non-static
> 3. Call reset_node_managed_pages() in hotadd_new_pgdat() after pgdat is initialized
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> ---
>   include/linux/bootmem.h | 1 +
>   mm/bootmem.c            | 9 +++++----
>   mm/memory_hotplug.c     | 9 +++++++++
>   mm/nobootmem.c          | 8 +++++---
>   4 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
> index 4e2bd4c..0995c2d 100644
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -46,6 +46,7 @@ extern unsigned long init_bootmem_node(pg_data_t *pgdat,
>   extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
>   
>   extern unsigned long free_all_bootmem(void);
> +extern void reset_node_managed_pages(pg_data_t *pgdat);
>   extern void reset_all_zones_managed_pages(void);
>   
>   extern void free_bootmem_node(pg_data_t *pgdat,
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 8a000ce..477be69 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -243,13 +243,10 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>   
>   static int reset_managed_pages_done __initdata;
>   
> -static inline void __init reset_node_managed_pages(pg_data_t *pgdat)
> +void reset_node_managed_pages(pg_data_t *pgdat)
>   {
>   	struct zone *z;
>   
> -	if (reset_managed_pages_done)
> -		return;
> -
>   	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>   		z->managed_pages = 0;
>   }
> @@ -258,8 +255,12 @@ void __init reset_all_zones_managed_pages(void)
>   {
>   	struct pglist_data *pgdat;
>   
> +	if (reset_managed_pages_done)
> +		return;
> +
>   	for_each_online_pgdat(pgdat)
>   		reset_node_managed_pages(pgdat);
> +
>   	reset_managed_pages_done = 1;
>   }
>   
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 29d8693..ede9ffe 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -31,6 +31,7 @@
>   #include <linux/stop_machine.h>
>   #include <linux/hugetlb.h>
>   #include <linux/memblock.h>
> +#include <linux/bootmem.h>
>   
>   #include <asm/tlbflush.h>
>   
> @@ -1096,6 +1097,14 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>   	build_all_zonelists(pgdat, NULL);
>   	mutex_unlock(&zonelists_mutex);
>   
> +	/*

> +	 *  zone->managed_pages is set to an approximate value in
> +	 *  free_area_init_core(), which will cause
> +	 *  /sys/device/system/node/nodeX/meminfo has wrong data.
> +	 *  So reset it to 0 before any memory is onlined.

How about it?

	 * zone->managed_pages is set to an approximate value in
	 * free_area_init_core(), even though all memory of the pgdat
	 * is offline. So reset it to 0.

When you send updated patch, please remove RFC from the subject.

Thanks,
Yasuaki Ishimatsu

> +	 */
> +	reset_node_managed_pages(pgdat);
> +
>   	return pgdat;
>   }
>   
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 7c7ab32..90b5046 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -145,12 +145,10 @@ static unsigned long __init free_low_memory_core_early(void)
>   
>   static int reset_managed_pages_done __initdata;
>   
> -static inline void __init reset_node_managed_pages(pg_data_t *pgdat)
> +void reset_node_managed_pages(pg_data_t *pgdat)
>   {
>   	struct zone *z;
>   
> -	if (reset_managed_pages_done)
> -		return;
>   	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>   		z->managed_pages = 0;
>   }
> @@ -159,8 +157,12 @@ void __init reset_all_zones_managed_pages(void)
>   {
>   	struct pglist_data *pgdat;
>   
> +	if (reset_managed_pages_done)
> +		return;
> +
>   	for_each_online_pgdat(pgdat)
>   		reset_node_managed_pages(pgdat);
> +
>   	reset_managed_pages_done = 1;
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
