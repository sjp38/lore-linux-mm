Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8288B6B0105
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 23:29:51 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so11354906pdj.24
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:29:51 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id aa2si21733523pad.177.2014.11.11.20.29.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 20:29:50 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 39DB03EE0CF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 13:29:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 16DE4AC0710
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 13:29:47 +0900 (JST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94DBC1DB8042
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 13:29:46 +0900 (JST)
Message-ID: <5462E200.6060405@jp.fujitsu.com>
Date: Wed, 12 Nov 2014 13:28:48 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] mem-hotplug: Reset node present pages when hot-adding
 a new pgdat.
References: <1415669227-10996-1-git-send-email-tangchen@cn.fujitsu.com> <1415669227-10996-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1415669227-10996-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, yinghai@kernel.org, luto@amacapital.net
Cc: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, isimatu.yasuaki@jp.fujitsu.com, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miaox@cn.fujitsu.com, stable@vger.kernel.org

(2014/11/11 10:27), Tang Chen wrote:
> When onlining memory on node2, node2 zoneinfo and node3 meminfo corrupted:
> 
> # for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
> # cat /sys/devices/system/node/node2/meminfo
> Node 2 MemTotal:       33554432 kB
> Node 2 MemFree:        33549092 kB
> Node 2 MemUsed:            5340 kB
> ......
> # cat /sys/devices/system/node/node3/meminfo
> Node 3 MemTotal:              0 kB
> Node 3 MemFree:               248 kB      /* corrupted, should be 0 */
> Node 3 MemUsed:               0 kB
> ......
> 
> # cat /proc/zoneinfo
> ......
> Node 2, zone   Movable
> ......
>          spanned  8388608
>          present  16777216               /* corrupted, should be 8388608 */
>          managed  8388608
> 
> 
> When memory is hot-added, all the memory is in offline state. So
> clear all zone->present_pages because they will be updated in
> online_pages() and offline_pages().
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>

> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

I has reviewed your patch. But I have one comment.
Please see below.

> ---
>   mm/memory_hotplug.c | 15 +++++++++++++++
>   1 file changed, 15 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8aba12b..26eac61 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1067,6 +1067,14 @@ out:
>   }
>   #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>   

> +static void reset_node_present_pages(pg_data_t *pgdat)
> +{
> +        struct zone *z;
> +
> +        for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
> +                z->present_pages = 0;
> +}

You should reset pgdat->node_present_pages.
pgdat->node_present_pages is set to realtotalpages by calculate_node_totalpages().
And it is also incremented/decremented by memroy online/offline.
So pgdat->node_present_pages is broken internally too.

Thanks,
Yasuaki Ishimatsu.

> +
>   /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
>   static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>   {
> @@ -1105,6 +1113,13 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>   	 */
>   	reset_node_managed_pages(pgdat);
>   
> +	/*
> +	 * When memory is hot-added, all the memory is in offline state. So
> +	 * clear all zones' present_pages because they will be updated in
> +	 * online_pages() and offline_pages().
> +	 */
> +	reset_node_present_pages(pgdat);
> +
>   	return pgdat;
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
