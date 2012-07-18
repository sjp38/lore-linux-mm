Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E0ADD6B0082
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 06:20:54 -0400 (EDT)
Message-ID: <50068F0A.20100@cn.fujitsu.com>
Date: Wed, 18 Jul 2012 18:25:14 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 3/13] memory-hotplug : check whether memory is present
 or not
References: <50068974.1070409@jp.fujitsu.com> <50068AE9.3050804@jp.fujitsu.com>
In-Reply-To: <50068AE9.3050804@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/18/2012 06:07 PM, Yasuaki Ishimatsu Wrote:
> If system supports memory hot-remove, online_pages() may online removed pages.
> So online_pages() need to check whether onlining pages are present or not.
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org> 
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
> CC: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> 
> ---
>  include/linux/mmzone.h |   21 +++++++++++++++++++++
>  mm/memory_hotplug.c    |   13 +++++++++++++
>  2 files changed, 34 insertions(+)
> 
> Index: linux-3.5-rc6/include/linux/mmzone.h
> ===================================================================
> --- linux-3.5-rc6.orig/include/linux/mmzone.h	2012-07-08 09:23:56.000000000 +0900
> +++ linux-3.5-rc6/include/linux/mmzone.h	2012-07-17 16:10:21.588186145 +0900
> @@ -1168,6 +1168,27 @@ void sparse_init(void);
>  #define sparse_index_init(_sec, _nid)  do {} while (0)
>  #endif /* CONFIG_SPARSEMEM */
>  
> +#ifdef CONFIG_SPARSEMEM
> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
> +{
> +	int i;
> +	for (i = 0; i < nr_pages; i++) {
> +		if (pfn_present(pfn + 1))
> +			continue;
> +		else {
> +			unlock_memory_hotplug();

Why do you unlock memory hotplug here? The caller will do it.

Thanks
Wen Congyang

> +			return -EINVAL;
> +		}
> +	}
> +	return 0;
> +}
> +#else
> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_SPARSEMEM*/
> +
>  #ifdef CONFIG_NODES_SPAN_OTHER_NODES
>  bool early_pfn_in_nid(unsigned long pfn, int nid);
>  #else
> Index: linux-3.5-rc6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc6.orig/mm/memory_hotplug.c	2012-07-17 14:26:40.000000000 +0900
> +++ linux-3.5-rc6/mm/memory_hotplug.c	2012-07-17 16:09:50.070580170 +0900
> @@ -467,6 +467,19 @@ int __ref online_pages(unsigned long pfn
>  	struct memory_notify arg;
>  
>  	lock_memory_hotplug();
> +	/*
> + 	 * If system supports memory hot-remove, the memory may have been
> + 	 * removed. So we check whether the memory has been removed or not.
> + 	 *
> + 	 * Note: When CONFIG_SPARSEMEM is defined, pfns_present() become
> + 	 *       effective. If CONFIG_SPARSEMEM is not defined, pfns_present()
> + 	 *       always returns 0.
> + 	 */
> +	ret = pfns_present(pfn, nr_pages);
> +	if (ret) {
> +		unlock_memory_hotplug();
> +		return ret;
> +	}
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
>  	arg.status_change_nid = -1;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
