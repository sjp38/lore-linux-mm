Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 2409E6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 08:28:12 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so3963711pbb.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 05:28:11 -0700 (PDT)
Message-ID: <50644639.9000804@gmail.com>
Date: Thu, 27 Sep 2012 20:27:37 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memory-hotplug: clear hwpoisoned flag when onlining
 pages
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com> <1348724705-23779-4-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1348724705-23779-4-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com

On 09/27/2012 01:45 PM, wency@cn.fujitsu.com wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
>
> hwpoisoned may set when we offline a page by the sysfs interface
> /sys/devices/system/memory/soft_offline_page or
> /sys/devices/system/memory/hard_offline_page. If we don't clear
> this flag when onlining pages, this page can't be freed, and will
> not in free list. So we can't offline these pages again. So we
> should clear this flag when onlining pages.

page hwpoisoned maybe cause by a multi-bit ECC memory or cache failure, 
so this page should not be used, why you online and free it again? can 
any users use it?

>
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>   mm/memory_hotplug.c |    8 ++++++++
>   1 files changed, 8 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6a5b90d..9a5b10f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -431,6 +431,14 @@ EXPORT_SYMBOL_GPL(__online_page_increment_counters);
>   
>   void __online_page_free(struct page *page)
>   {
> +#ifdef CONFIG_MEMORY_FAILURE
> +	/* The page may be marked HWPoisoned by soft/hard offline page */
> +	if (PageHWPoison(page)) {
> +		atomic_long_sub(1, &mce_bad_pages);
> +		ClearPageHWPoison(page);
> +	}
> +#endif
> +
>   	ClearPageReserved(page);
>   	init_page_count(page);
>   	__free_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
