Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1C9986B005A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 04:16:39 -0500 (EST)
Message-ID: <509B79DB.1010208@cn.fujitsu.com>
Date: Thu, 08 Nov 2012 17:22:35 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: fix NR_FREE_PAGES mismatch's fix
References: <509B75FF.6070806@cn.fujitsu.com>
In-Reply-To: <509B75FF.6070806@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, lai jiangshan <laijs@cn.fujitsu.com>

At 11/08/2012 05:06 PM, Wen Congyang Wrote:
> 
> When a page is freed and put into pcp list, get_freepage_migratetype()
> doesn't return MIGRATE_ISOLATE even if this pageblock is isolated.
> So we should use get_freepage_migratetype() instead of mt to check
> whether it is isolated.

In my local tree, there are some patches from isimatu, so I don't add
-s option when generating the patch. So I forgot to add:

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Reported-by: Jianguo Wu <wujianguo106@gmail.com>


> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 027afd0..795875f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -667,7 +667,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
>  			__free_one_page(page, zone, 0, mt);
>  			trace_mm_page_pcpu_drain(page, 0, mt);
> -			if (likely(mt != MIGRATE_ISOLATE)) {
> +			if (likely(get_pageblock_migratetype(page) != MIGRATE_ISOLATE)) {
>  				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
>  				if (is_migrate_cma(mt))
>  					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
