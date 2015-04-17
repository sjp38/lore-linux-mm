Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 571436B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:27:45 -0400 (EDT)
Received: by obbfy7 with SMTP id fy7so64770526obb.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 02:27:45 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id jf2si7490083oeb.35.2015.04.17.02.27.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 02:27:44 -0700 (PDT)
Message-ID: <5530CEBB.9030209@huawei.com>
Date: Fri, 17 Apr 2015 17:13:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530B2E9.3010102@huawei.com>
In-Reply-To: <5530B2E9.3010102@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

> ---
>  mm/page_alloc.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e..1a5743e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4667,6 +4667,10 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  {
>  	unsigned long zone_start_pfn, zone_end_pfn;
>  
> +	/* When hotadd a new node, init node's zones as empty zones */
> +	if (!node_online(nid))
> +		return 0;
> +
>  	/* Get the start and end of the zone */
>  	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
>  	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> @@ -4698,6 +4702,10 @@ unsigned long __meminit __absent_pages_in_range(int nid,
>  	unsigned long start_pfn, end_pfn;

I made a mistake here, should change zone_absent_pages_in_node(), sorry!
I'll send V2

>  	int i;
>  
> +	/* When hotadd a new node, init node's zones as empty zones */
> +	if (!node_online(nid))
> +		return 0;
> +
>  	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL) {
>  		start_pfn = clamp(start_pfn, range_start_pfn, range_end_pfn);
>  		end_pfn = clamp(end_pfn, range_start_pfn, range_end_pfn);
> @@ -4746,6 +4754,9 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  					unsigned long node_end_pfn,
>  					unsigned long *zones_size)
>  {
> +	if (!node_online(nid))
> +		return 0;
> +
>  	return zones_size[zone_type];
>  }
>  
> @@ -4755,6 +4766,9 @@ static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
>  						unsigned long node_end_pfn,
>  						unsigned long *zholes_size)
>  {
> +	if (!node_online(nid))
> +		return 0;
> +
>  	if (!zholes_size)
>  		return 0;
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
