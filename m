Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id E20C16B0062
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 15:02:05 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2513368oag.14
        for <linux-mm@kvack.org>; Fri, 05 Oct 2012 12:02:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <506D1F1D.9000301@jp.fujitsu.com>
References: <506D1F1D.9000301@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 5 Oct 2012 15:01:44 -0400
Message-ID: <CAHGf_=pA-FPZ7YhM5RRWLOVdNHZhjkO+8HoXSMx0_vWNT-1ngg@mail.gmail.com>
Subject: Re: memory-hotplug : suppres "Trying to free nonexistent resource
 <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>" warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>

CC to Dave Hanse.

Hello Dave,

I think following patch works both x86 and ppc. but I'm not ppc
expert. So I'm glad
if you double check it.

thank you.


<intentional full quote>

> When our x86 box calls __remove_pages(), release_mem_region() shows
> many warnings. And x86 box cannot unregister iomem_resource.
>
> "Trying to free nonexistent resource <XXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYY>"
>
> release_mem_region() has been changed as called in each PAGES_PER_SECTION
> chunk since applying a patch(de7f0cba96786c). Because powerpc registers
> iomem_resource in each PAGES_PER_SECTION chunk. But when I hot add memory
> on x86 box, iomem_resource is register in each _CRS not PAGES_PER_SECTION
> chunk. So x86 box unregisters iomem_resource.
>
> The patch fixes the problem.
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
> ---
>  arch/powerpc/platforms/pseries/hotplug-memory.c |   13 +++++++++----
>  mm/memory_hotplug.c                             |    4 ++--
>  2 files changed, 11 insertions(+), 6 deletions(-)
>
> Index: linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c
> ===================================================================
> --- linux-3.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c      2012-10-04 14:22:59.833520792 +0900
> +++ linux-3.6/arch/powerpc/platforms/pseries/hotplug-memory.c   2012-10-04 14:23:05.150521411 +0900
> @@ -77,7 +77,8 @@ static int pseries_remove_memblock(unsig
>  {
>         unsigned long start, start_pfn;
>         struct zone *zone;
> -       int ret;
> +       int i, ret;
> +       int sections_to_remove;
>
>         start_pfn = base >> PAGE_SHIFT;
>
> @@ -97,9 +98,13 @@ static int pseries_remove_memblock(unsig
>          * to sysfs "state" file and we can't remove sysfs entries
>          * while writing to it. So we have to defer it to here.
>          */
> -       ret = __remove_pages(zone, start_pfn, memblock_size >> PAGE_SHIFT);
> -       if (ret)
> -               return ret;
> +       sections_to_remove = (memblock_size >> PAGE_SHIFT) / PAGES_PER_SECTION;
> +       for (i = 0; i < sections_to_remove; i++) {
> +               unsigned long pfn = start_pfn + i * PAGES_PER_SECTION;
> +               ret = __remove_pages(zone, start_pfn,  PAGES_PER_SECTION);
> +               if (ret)
> +                       return ret;
> +       }
>
>         /*
>          * Update memory regions for memory remove
> Index: linux-3.6/mm/memory_hotplug.c
> ===================================================================
> --- linux-3.6.orig/mm/memory_hotplug.c  2012-10-04 14:22:59.829520788 +0900
> +++ linux-3.6/mm/memory_hotplug.c       2012-10-04 14:23:25.860527278 +0900
> @@ -362,11 +362,11 @@ int __remove_pages(struct zone *zone, un
>         BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
>         BUG_ON(nr_pages % PAGES_PER_SECTION);
>
> +       release_mem_region(phys_start_pfn << PAGE_SHIFT, nr_pages * PAGE_SIZE);
> +
>         sections_to_remove = nr_pages / PAGES_PER_SECTION;
>         for (i = 0; i < sections_to_remove; i++) {
>                 unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
> -               release_mem_region(pfn << PAGE_SHIFT,
> -                                  PAGES_PER_SECTION << PAGE_SHIFT);
>                 ret = __remove_section(zone, __pfn_to_section(pfn));
>                 if (ret)
>                         break;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
