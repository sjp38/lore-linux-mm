Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id CCB0C6B005C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 23:38:02 -0400 (EDT)
Message-ID: <4FFF9929.4000100@cn.fujitsu.com>
Date: Fri, 13 Jul 2012 11:42:33 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 5/13] memory-hotplug : does not release memory
 region in PAGES_PER_SECTION chunks
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB1F3.1020304@jp.fujitsu.com>
In-Reply-To: <4FFAB1F3.1020304@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/09/2012 06:26 PM, Yasuaki Ishimatsu Wrote:
> Since applying a patch(de7f0cba96786c), release_mem_region() has been changed
> as called in PAGES_PER_SECTION chunks because register_memory_resource() is
> called in PAGES_PER_SECTION chunks by add_memory(). But it seems firmware
> dependency. If CRS are written in the PAGES_PER_SECTION chunks in ACPI DSDT
> Table, register_memory_resource() is called in PAGES_PER_SECTION chunks.
> But if CRS are written in the DIMM unit in ACPI DSDT Table,
> register_memory_resource() is called in DIMM unit. So release_mem_region()
> should not be called in PAGES_PER_SECTION chunks. The patch fixes it.
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
>  arch/powerpc/platforms/pseries/hotplug-memory.c |   13 +++++++++----
>  mm/memory_hotplug.c                             |    4 ++--
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> Index: linux-3.5-rc4/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:03.549198802 +0900
> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:05.919169458 +0900
> @@ -358,11 +358,11 @@ int __remove_pages(struct zone *zone, un
>  	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
>  	BUG_ON(nr_pages % PAGES_PER_SECTION);
> 
> +	release_mem_region(phys_start_pfn << PAGE_SHIFT,  nr_pages * PAGE_SIZE);
> +
>  	sections_to_remove = nr_pages / PAGES_PER_SECTION;
>  	for (i = 0; i < sections_to_remove; i++) {
>  		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
> -		release_mem_region(pfn << PAGE_SHIFT,
> -				   PAGES_PER_SECTION << PAGE_SHIFT);
>  		ret = __remove_section(zone, __pfn_to_section(pfn));
>  		if (ret)
>  			break;
> Index: linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c
> ===================================================================
> --- linux-3.5-rc4.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:21:45.641422678
> +0900

Hmm, I think you should change your mail client's config.

Thanks
Wen Congyang

> +++ linux-3.5-rc4/arch/powerpc/platforms/pseries/hotplug-memory.c	2012-07-03 14:22:05.920169437 +0900
> @@ -77,7 +77,8 @@ static int pseries_remove_memblock(unsig
>  {
>  	unsigned long start, start_pfn;
>  	struct zone *zone;
> -	int ret;
> +	int i, ret;
> +	int sections_to_remove;
> 
>  	start_pfn = base >> PAGE_SHIFT;
> 
> @@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
>  	 * to sysfs "state" file and we can't remove sysfs entries
>  	 * while writing to it. So we have to defer it to here.
>  	 */
> -	ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
> -	if (ret)
> -		return ret;
> +	sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
> +	for (i = 0; i < sections_to_remove; i++) {
> +		unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
> +		ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
> +		if (ret)
> +			return ret;
> +	}
> 
>  	/*
>  	 * Update memory regions for memory remove
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
