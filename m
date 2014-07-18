Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 12DE56B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 05:53:50 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so4774369pdb.33
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 02:53:49 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id wu6si4226638pab.61.2014.07.18.02.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 02:53:49 -0700 (PDT)
Message-ID: <53C8EE4C.1000204@huawei.com>
Date: Fri, 18 Jul 2014 17:52:12 +0800
From: Wang Nan <wangnan0@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] memory-hotplug: x86_32: suitable memory should go
 to ZONE_MOVABLE
References: <1405670163-53747-1-git-send-email-wangnan0@huawei.com> <1405670163-53747-3-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405670163-53747-3-git-send-email-wangnan0@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pei Feiyue <peifeiyue@huawei.com>, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org

On 2014/7/18 15:56, Wang Nan wrote:
> This patch add new memory to ZONE_MOVABLE if movable zone is setup
> and lower than newly added memory for x86_32.
> 
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> ---
>  arch/x86/mm/init_32.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index e395048..dd69833 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -826,9 +826,15 @@ int arch_add_memory(int nid, u64 start, u64 size)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(nid);
>  	struct zone *zone = pgdata->node_zones + ZONE_HIGHMEM;
> +	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;

Sorry. pgdat should be pgdata.

>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> +	if (!zone_is_empty(movable_zone))
> +		if (zone_spans_pfn(movable_zone, start_pfn) ||
> +				(zone_end_pfn(movable_zone) <= start_pfn))
> +			zone = movable_zone;
> +
>  	return __add_pages(nid, zone, start_pfn, nr_pages);
>  }
>  
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
