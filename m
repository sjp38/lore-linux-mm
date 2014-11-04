Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BC9366B00DD
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 03:12:44 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so13191133pde.4
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 00:12:44 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id cb9si14988027pdb.114.2014.11.04.00.12.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 00:12:43 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8D40D3EE1D8
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:12:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 67A17AC010A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:12:40 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1571AE08001
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:12:40 +0900 (JST)
Message-ID: <54588A0D.1060207@jp.fujitsu.com>
Date: Tue, 4 Nov 2014 17:10:53 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mem-hotplug: Fix wrong check for zone->pageset initialization
 in online_pages().
References: <1414748812-22610-1-git-send-email-tangchen@cn.fujitsu.com> <1414748812-22610-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1414748812-22610-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

(2014/10/31 18:46), Tang Chen wrote:
> When we are doing memory hot-add, the following functions are called:
> 
> add_memory()
> |--> hotadd_new_pgdat()
>       |--> free_area_init_node()
>            |--> free_area_init_core()
>                 |--> zone->present_pages = realsize;           /* 1. zone is populated */
>                      |--> zone_pcp_init()
>                           |--> zone->pageset = &boot_pageset;  /* 2. zone->pageset is set to boot_pageset */
> 
> There are two problems here:
> 1. Zones could be populated before any memory is onlined.
> 2. All the zones on a newly added node have the same pageset pointing to boot_pageset.
> 
> The above two problems will result in the following problem:
> When we online memory on one node, e.g node2, the following code is executed:
> 
> online_pages()
> {
>          ......
>          if (!populated_zone(zone)) {
>                  need_zonelists_rebuild = 1;
>                  build_all_zonelists(NULL, zone);
>          }
>          ......
> }
> 
> Because of problem 1, the zone has been populated, and the build_all_zonelists()
>                        will never called. zone->pageset won't be updated.
> Because of problem 2, All the zones on a newly added node have the same pageset
>                        pointing to boot_pageset.
> And as a result, when we online memory on node2, node3's meminfo will corrupt.
> Pages on node2 may be freed to node3.
> 
> # for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
> # cat /sys/devices/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB
> Node 2 MemFree:        33549092 kB
> Node 2 MemUsed:            5340 kB
> ......
> # cat /sys/devices/system/node/node3/meminfo
> Node 3 MemTotal:              0 kB
> Node 3 MemFree:               248 kB                    /* corrupted */
> Node 3 MemUsed:               0 kB
> ......
> 
> We have to populate some zones before onlining memory, otherwise no memory could be onlined.
> So when onlining pages, we should also check if zone->pageset is pointing to boot_pageset.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>   include/linux/mm.h  | 1 +
>   mm/memory_hotplug.c | 6 +++++-
>   mm/page_alloc.c     | 5 +++++
>   3 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 02d11ee..83e6505 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1732,6 +1732,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
>   
>   extern void setup_per_cpu_pageset(void);
>   
> +extern bool zone_pcp_initialized(struct zone *zone);
>   extern void zone_pcp_update(struct zone *zone);
>   extern void zone_pcp_reset(struct zone *zone);
>   
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 3ab01b2..bc0de0f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1013,9 +1013,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>   	 * If this zone is not populated, then it is not in zonelist.
>   	 * This means the page allocator ignores this zone.
>   	 * So, zonelist must be updated after online.
> +	 *
> +	 * If this zone is populated, zone->pageset could be initialized
> +	 * to boot_pageset for the first time a node is added. If so,
> +	 * zone->pageset should be allocated.
>   	 */
>   	mutex_lock(&zonelists_mutex);
> -	if (!populated_zone(zone)) {

> +	if (!populated_zone(zone) || !zone_pcp_initialized(zone)) {
>   		need_zonelists_rebuild = 1;
>   		build_all_zonelists(NULL, zone);
>   	}

Why does zone->present_pages of the hot-added memroy have valid value?
In my understading, the present_pages is incremented/decremented by memory
online/offline. So when hot adding memory, the zone->present_pages of the
memory should be 0.

Thanks,
Yasuaki Ishimatsu


> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 736d8e1..4ff1540 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6456,6 +6456,11 @@ void __meminit zone_pcp_update(struct zone *zone)
>   }
>   #endif
>   
> +bool zone_pcp_initialized(struct zone *zone)
> +{
> +	return (zone->pageset != &boot_pageset);
> +}
> +
>   void zone_pcp_reset(struct zone *zone)
>   {
>   	unsigned long flags;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
