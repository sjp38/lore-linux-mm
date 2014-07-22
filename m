Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7086B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 23:10:54 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so10322949pdj.14
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 20:10:53 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id cl4si16117104pbb.175.2014.07.21.20.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 20:10:53 -0700 (PDT)
Message-ID: <53CDD5EE.1030805@huawei.com>
Date: Tue, 22 Jul 2014 11:09:34 +0800
From: Wang Nan <wangnan0@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 7/7] memory-hotplug: tile: suitable memory should go
 to ZONE_MOVABLE
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com> <1405914402-66212-8-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-8-git-send-email-wangnan0@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wang Nan <wangnan0@huawei.com>, Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>

Hi Andrew,

Please drop patch 7/7 from -mm tree and keep other 6 patches.

arch_add_memory() in tile is different from others: no nid parameter.
Patch 7/7 will block compiling.

I cc this mail to Chris Metcalf and hope he can look at this issue.

Other 6 patches looks good.

On 2014/7/21 11:46, Wang Nan wrote:
> This patch introduces zone_for_memory() to arch_add_memory() on tile to
> ensure new, higher memory added into ZONE_MOVABLE if movable zone has
> already setup.
> 
> This patch also fix a problem: on tile, new memory should be added into
> ZONE_HIGHMEM by default, not MAX_NR_ZONES-1, which is ZONE_MOVABLE.
> 
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> ---
>  arch/tile/mm/init.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
> index bfb3127..22ac6c1 100644
> --- a/arch/tile/mm/init.c
> +++ b/arch/tile/mm/init.c
> @@ -872,7 +872,8 @@ void __init mem_init(void)
>  int arch_add_memory(u64 start, u64 size)
>  {
>  	struct pglist_data *pgdata = &contig_page_data;
> -	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
> +	struct zone *zone = pgdata->node_zones +
> +		zone_for_memory(nid, start, size, ZONE_HIGHMEM);
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
>  
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
