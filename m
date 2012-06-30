Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 13E2A6B00AD
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 11:51:32 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6902176dak.14
        for <linux-mm@kvack.org>; Sat, 30 Jun 2012 08:51:31 -0700 (PDT)
Message-ID: <4FEF2075.2050603@gmail.com>
Date: Sat, 30 Jun 2012 23:51:17 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/12] memory-hogplug : check memory offline in offline_pages
References: <4FEA9C88.1070800@jp.fujitsu.com> <4FEA9DB1.7010303@jp.fujitsu.com>
In-Reply-To: <4FEA9DB1.7010303@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On 06/27/2012 01:44 PM, Yasuaki Ishimatsu wrote:
> When offline_pages() is called to offlined memory, the function fails since
> all memory has been offlined. In this case, the function should succeed.
> The patch adds the check function into offline_pages().
> 
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
>  drivers/base/memory.c  |   20 ++++++++++++++++++++
>  include/linux/memory.h |    1 +
>  mm/memory_hotplug.c    |    5 +++++
>  3 files changed, 26 insertions(+)
> 
> Index: linux-3.5-rc4/drivers/base/memory.c
> ===================================================================
> --- linux-3.5-rc4.orig/drivers/base/memory.c	2012-06-26 13:28:16.726211752 +0900
> +++ linux-3.5-rc4/drivers/base/memory.c	2012-06-26 13:34:22.423639904 +0900
> @@ -70,6 +70,26 @@ void unregister_memory_isolate_notifier(
>  }
>  EXPORT_SYMBOL(unregister_memory_isolate_notifier);
> 
> +bool memory_is_offline(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	struct memory_block *mem;
> +	struct mem_section *section;
> +	unsigned long pfn, section_nr;
> +
> +	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
> +		section_nr = pfn_to_section_nr(pfn);
> +		section = __nr_to_section(section_nr);
> +		mem = find_memory_block(section);
Seems find_memory_block_hinted() is more efficient than find_memory_block() here.

> +		if (!mem)
> +			continue;
> +		if (mem->state == MEM_OFFLINE)
> +			continue;
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
>  /*
>   * register_memory - Setup a sysfs device for a memory block
>   */
> Index: linux-3.5-rc4/include/linux/memory.h
> ===================================================================
> --- linux-3.5-rc4.orig/include/linux/memory.h	2012-06-25 04:53:04.000000000 +0900
> +++ linux-3.5-rc4/include/linux/memory.h	2012-06-26 13:34:22.424639891 +0900
> @@ -120,6 +120,7 @@ extern int memory_isolate_notify(unsigne
>  extern struct memory_block *find_memory_block_hinted(struct mem_section *,
>  							struct memory_block *);
>  extern struct memory_block *find_memory_block(struct mem_section *);
> +extern bool memory_is_offline(unsigned long start_pfn, unsigned long end_pfn);
>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>  enum mem_add_context { BOOT, HOTPLUG };
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
> Index: linux-3.5-rc4/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-06-26 13:28:16.743211538 +0900
> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-06-26 13:48:38.264940468 +0900
> @@ -887,6 +887,11 @@ static int __ref offline_pages(unsigned
> 
>  	lock_memory_hotplug();
> 
> +	if (memory_is_offline(start_pfn, end_pfn)) {
> +		ret = 0;
> +		goto out;
> +	}
> +
>  	zone = page_zone(pfn_to_page(start_pfn));
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
