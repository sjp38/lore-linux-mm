Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 48D676B005C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 04:32:24 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1986706wgb.26
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 01:32:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50068BF4.1080603@jp.fujitsu.com>
References: <50068974.1070409@jp.fujitsu.com>
	<50068BF4.1080603@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 16:32:22 +0800
Message-ID: <CAA_GA1dPdjO7jwMaQsx+ywWpZe4fyGm+aTeJcjUgJPKuVZd9xA@mail.gmail.com>
Subject: Re: [RFC PATCH v4 7/13] memory-hotplug : remove_memory calls __remove_pages
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

On Wed, Jul 18, 2012 at 6:12 PM, Yasuaki Ishimatsu
<isimatu.yasuaki@jp.fujitsu.com> wrote:
> The patch adds __remove_pages() to remove_memory(). Then the range of
> phys_start_pfn argument and nr_pages argument in __remove_pagse() may
> have different zone. So zone argument is removed from __remove_pages()
> and __remove_pages() caluculates zone in each section.
>
> When CONFIG_SPARSEMEM_VMEMMAP is defined, there is no way to remove a memmap.
> So __remove_section only calls unregister_memory_section().
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
>  arch/powerpc/platforms/pseries/hotplug-memory.c |    5 +----
>  include/linux/memory_hotplug.h                  |    3 +--
>  mm/memory_hotplug.c                             |   19 ++++++++++++-------
>  3 files changed, 14 insertions(+), 13 deletions(-)
>
> Index: linux-3.5-rc6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.5-rc6.orig/mm/memory_hotplug.c      2012-07-18 18:00:27.440145432 +0900
> +++ linux-3.5-rc6/mm/memory_hotplug.c   2012-07-18 18:01:02.070712487 +0900
> @@ -275,11 +275,14 @@ static int __meminit __add_section(int n
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
>  static int __remove_section(struct zone *zone, struct mem_section *ms)
>  {
> -       /*
> -        * XXX: Freeing memmap with vmemmap is not implement yet.
> -        *      This should be removed later.
> -        */
> -       return -EBUSY;
> +       int ret = -EINVAL;
> +
> +       if (!valid_section(ms))
> +               return ret;
> +
> +       ret = unregister_memory_section(ms);
> +

I saw a patch from Jiang Liu "mm/hotplug: free zone->pageset when a
zone becomes empty" to
free the zone->pageset and i think there may more cleanup needed when
a zone becomes empty.

We already have __add_zone() in __add_section(), what about add a
function like __remove_zone()
to do the cleanup here?

> +       return ret;
>  }
>  #else
>  static int __remove_section(struct zone *zone, struct mem_section *ms)
> @@ -346,11 +349,11 @@ EXPORT_SYMBOL_GPL(__add_pages);
>   * sure that pages are marked reserved and zones are adjust properly by
>   * calling offline_pages().
>   */
> -int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
> -                unsigned long nr_pages)
> +int __remove_pages(unsigned long phys_start_pfn, unsigned long nr_pages)
>  {
>         unsigned long i, ret = 0;
>         int sections_to_remove;
> +       struct zone *zone;
>
>         /*
>          * We can only remove entire sections
> @@ -363,6 +366,7 @@ int __remove_pages(struct zone *zone, un
>         sections_to_remove = nr_pages / PAGES_PER_SECTION;
>         for (i = 0; i < sections_to_remove; i++) {
>                 unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
> +               zone = page_zone(pfn_to_page(pfn));
>                 ret = __remove_section(zone, __pfn_to_section(pfn));
>                 if (ret)
>                         break;
> @@ -1031,6 +1035,7 @@ int __ref remove_memory(int nid, u64 sta
>         /* remove memmap entry */
>         firmware_map_remove(start, start + size, "System RAM");
>
> +       __remove_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT);
>  out:
>         unlock_memory_hotplug();
>         return ret;
> Index: linux-3.5-rc6/include/linux/memory_hotplug.h
> ===================================================================
> --- linux-3.5-rc6.orig/include/linux/memory_hotplug.h   2012-07-18 18:00:27.445145371 +0900
> +++ linux-3.5-rc6/include/linux/memory_hotplug.h        2012-07-18 18:00:40.461982690 +0900
> @@ -89,8 +89,7 @@ extern bool is_pageblock_removable_noloc
>  /* reasonably generic interface to expand the physical pages in a zone  */
>  extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
>         unsigned long nr_pages);
> -extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
> -       unsigned long nr_pages);
> +extern int __remove_pages(unsigned long start_pfn, unsigned long nr_pages);
>
>  #ifdef CONFIG_NUMA
>  extern int memory_add_physaddr_to_nid(u64 start);
> Index: linux-3.5-rc6/arch/powerpc/platforms/pseries/hotplug-memory.c
> ===================================================================
> --- linux-3.5-rc6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c  2012-07-18 18:00:27.442145407 +0900
> +++ linux-3.5-rc6/arch/powerpc/platforms/pseries/hotplug-memory.c       2012-07-18 18:00:40.470982578 +0900
> @@ -76,7 +76,6 @@ unsigned long memory_block_size_bytes(vo
>  static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
>  {
>         unsigned long start, start_pfn;
> -       struct zone *zone;
>         int i, ret;
>         int sections_to_remove;
>
> @@ -87,8 +86,6 @@ static int pseries_remove_memblock(unsig
>                 return 0;
>         }
>
> -       zone = page_zone(pfn_to_page(start_pfn));
> -
>         /*
>          * Remove section mappings and sysfs entries for the
>          * section of the memory we are removing.
> @@ -101,7 +98,7 @@ static int pseries_remove_memblock(unsig
>         sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
>         for (i = 0; i < sections_to_remove; i++) {
>                 unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
> -               ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
> +               ret = __remove_pages(start_pfn,  PAGES_PER_SECTION);
>                 if (ret)
>                         return ret;
>         }
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
