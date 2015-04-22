Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3733C900015
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 02:28:57 -0400 (EDT)
Received: by oift201 with SMTP id t201so172896300oif.3
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 23:28:57 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u5si2926406oem.46.2015.04.21.23.28.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 23:28:56 -0700 (PDT)
Message-ID: <55373F4D.6060901@huawei.com>
Date: Wed, 22 Apr 2015 14:27:25 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 V3] memory-hotplug: remove reset_node_managed_pages()
 and reset_node_managed_pages() in hotadd_new_pgdat()
References: <55362349.3090406@huawei.com>
In-Reply-To: <55362349.3090406@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>

add CC: Tejun Heo <tj@kernel.org>

On 2015/4/21 18:15, Xishi Qiu wrote:

> After hotadd_new_pgdat()->free_area_init_node(), pgdat's spanned/present are 0,
> and zone's spanned/present/managed are 0, so remove reset_node_managed_pages()
> and reset_node_managed_pages().
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/memory_hotplug.c |   25 -------------------------
>  1 files changed, 0 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 49d7c07..ac6462f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1064,16 +1064,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>  
> -static void reset_node_present_pages(pg_data_t *pgdat)
> -{
> -	struct zone *z;
> -
> -	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
> -		z->present_pages = 0;
> -
> -	pgdat->node_present_pages = 0;
> -}
> -
>  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
>  static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  {
> @@ -1108,21 +1098,6 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>  	build_all_zonelists(pgdat, NULL);
>  	mutex_unlock(&zonelists_mutex);
>  
> -	/*
> -	 * zone->managed_pages is set to an approximate value in
> -	 * free_area_init_core(), which will cause
> -	 * /sys/device/system/node/nodeX/meminfo has wrong data.
> -	 * So reset it to 0 before any memory is onlined.
> -	 */
> -	reset_node_managed_pages(pgdat);
> -
> -	/*
> -	 * When memory is hot-added, all the memory is in offline state. So
> -	 * clear all zones' present_pages because they will be updated in
> -	 * online_pages() and offline_pages().
> -	 */
> -	reset_node_present_pages(pgdat);
> -
>  	return pgdat;
>  }
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
