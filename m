Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B32F46B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 05:56:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p7so21022594oif.2
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 02:56:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u35sor1935677otc.93.2017.06.10.02.56.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Jun 2017 02:56:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170515085827.16474-5-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org> <20170515085827.16474-5-mhocko@kernel.org>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Sat, 10 Jun 2017 17:56:02 +0800
Message-ID: <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of is_zone_device_section
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, May 15, 2017 at 4:58 PM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> device memory hotplug hooks into regular memory hotplug only half way.
> It needs memory sections to track struct pages but there is no
> need/desire to associate those sections with memory blocks and export
> them to the userspace via sysfs because they cannot be onlined anyway.
>
> This is currently expressed by for_device argument to arch_add_memory
> which then makes sure to associate the given memory range with
> ZONE_DEVICE. register_new_memory then relies on is_zone_device_section
> to distinguish special memory hotplug from the regular one. While this
> works now, later patches in this series want to move __add_zone outside
> of arch_add_memory path so we have to come up with something else.
>
> Add want_memblock down the __add_pages path and use it to control
> whether the section->memblock association should be done. arch_add_memory
> then just trivially want memblock for everything but for_device hotplug.
>
> remove_memory_section doesn't need is_zone_device_section either. We can
> simply skip all the memblock specific cleanup if there is no memblock
> for the given section.
>
> This shouldn't introduce any functional change.
>

Hmm... one question about the memory_block behavior.

In case one memory_block contains more than one memory section.
If one section is "device zone", the whole memory_block is not visible
in sysfs. Or until the whole memory_block is full, the sysfs is visible.

This is the known behavior right?

And in this case, the memory_block could be found. Would this introduce
some problem when remove_memory_section()?


> Changes since v1
> - return 0 if want_memblock == 0 from __add_section as per Jerome Glisse
>
> Changes since v2
> - fix remove_memory_section unlock on find_memory_block failure
>   as per Jerome - spotted by Evgeny Baskakov
>
> Tested-by: Dan Williams <dan.j.williams@intel.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/ia64/mm/init.c            |  2 +-
>  arch/powerpc/mm/mem.c          |  2 +-
>  arch/s390/mm/init.c            |  2 +-
>  arch/sh/mm/init.c              |  2 +-
>  arch/x86/mm/init_32.c          |  2 +-
>  arch/x86/mm/init_64.c          |  2 +-
>  drivers/base/memory.c          | 23 +++++++++--------------
>  include/linux/memory_hotplug.h |  2 +-
>  mm/memory_hotplug.c            |  9 ++++++---
>  9 files changed, 22 insertions(+), 24 deletions(-)
>
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 8f3efa682ee8..39e2aeb4669d 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -658,7 +658,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>
>         zone = pgdat->node_zones +
>                 zone_for_memory(nid, start, size, ZONE_NORMAL, for_device);
> -       ret = __add_pages(nid, zone, start_pfn, nr_pages);
> +       ret = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>
>         if (ret)
>                 printk("%s: Problem encountered in __add_pages() as ret=%d\n",
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 9ee536ec0739..e6b2e6618b6c 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -151,7 +151,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>         zone = pgdata->node_zones +
>                 zone_for_memory(nid, start, size, 0, for_device);
>
> -       return __add_pages(nid, zone, start_pfn, nr_pages);
> +       return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>  }
>
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index ee6a1d3d4983..893cf88cf02d 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -191,7 +191,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>                         continue;
>                 nr_pages = (start_pfn + size_pages > zone_end_pfn) ?
>                            zone_end_pfn - start_pfn : size_pages;
> -               rc = __add_pages(nid, zone, start_pfn, nr_pages);
> +               rc = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>                 if (rc)
>                         break;
>                 start_pfn += nr_pages;
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 75491862d900..a9d57f75ae8c 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -498,7 +498,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>         ret = __add_pages(nid, pgdat->node_zones +
>                         zone_for_memory(nid, start, size, ZONE_NORMAL,
>                         for_device),
> -                       start_pfn, nr_pages);
> +                       start_pfn, nr_pages, !for_device);
>         if (unlikely(ret))
>                 printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
>
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 99fb83819a5f..94594b889144 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -831,7 +831,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>         unsigned long start_pfn = start >> PAGE_SHIFT;
>         unsigned long nr_pages = size >> PAGE_SHIFT;
>
> -       return __add_pages(nid, zone, start_pfn, nr_pages);
> +       return __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>  }
>
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 41270b96403d..2e004364a373 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -697,7 +697,7 @@ int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
>
>         init_memory_mapping(start, start + size);
>
> -       ret = __add_pages(nid, zone, start_pfn, nr_pages);
> +       ret = __add_pages(nid, zone, start_pfn, nr_pages, !for_device);
>         WARN_ON_ONCE(ret);
>
>         /* update max_pfn, max_low_pfn and high_memory */
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 90225ffee501..f8fd562c3f18 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -685,14 +685,6 @@ static int add_memory_block(int base_section_nr)
>         return 0;
>  }
>
> -static bool is_zone_device_section(struct mem_section *ms)
> -{
> -       struct page *page;
> -
> -       page = sparse_decode_mem_map(ms->section_mem_map, __section_nr(ms));
> -       return is_zone_device_page(page);
> -}
> -
>  /*
>   * need an interface for the VM to add new memory regions,
>   * but without onlining it.
> @@ -702,9 +694,6 @@ int register_new_memory(int nid, struct mem_section *section)
>         int ret = 0;
>         struct memory_block *mem;
>
> -       if (is_zone_device_section(section))
> -               return 0;
> -
>         mutex_lock(&mem_sysfs_mutex);
>
>         mem = find_memory_block(section);
> @@ -741,11 +730,16 @@ static int remove_memory_section(unsigned long node_id,
>  {
>         struct memory_block *mem;
>
> -       if (is_zone_device_section(section))
> -               return 0;
> -
>         mutex_lock(&mem_sysfs_mutex);
> +
> +       /*
> +        * Some users of the memory hotplug do not want/need memblock to
> +        * track all sections. Skip over those.
> +        */
>         mem = find_memory_block(section);
> +       if (!mem)
> +               goto out_unlock;
> +
>         unregister_mem_sect_under_nodes(mem, __section_nr(section));
>
>         mem->section_count--;
> @@ -754,6 +748,7 @@ static int remove_memory_section(unsigned long node_id,
>         else
>                 put_device(&mem->dev);
>
> +out_unlock:
>         mutex_unlock(&mem_sysfs_mutex);
>         return 0;
>  }
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 134a2f69c21a..3c8cf86201c3 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -111,7 +111,7 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>
>  /* reasonably generic interface to expand the physical pages in a zone  */
>  extern int __add_pages(int nid, struct zone *zone, unsigned long start_pfn,
> -       unsigned long nr_pages);
> +       unsigned long nr_pages, bool want_memblock);
>
>  #ifdef CONFIG_NUMA
>  extern int memory_add_physaddr_to_nid(u64 start);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6290d34b6331..a95120c56a9a 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -494,7 +494,7 @@ static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
>  }
>
>  static int __meminit __add_section(int nid, struct zone *zone,
> -                                       unsigned long phys_start_pfn)
> +               unsigned long phys_start_pfn, bool want_memblock)
>  {
>         int ret;
>
> @@ -511,6 +511,9 @@ static int __meminit __add_section(int nid, struct zone *zone,
>         if (ret < 0)
>                 return ret;
>
> +       if (!want_memblock)
> +               return 0;
> +
>         return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
>  }
>
> @@ -521,7 +524,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
>   * add the new pages.
>   */
>  int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
> -                       unsigned long nr_pages)
> +                       unsigned long nr_pages, bool want_memblock)
>  {
>         unsigned long i;
>         int err = 0;
> @@ -549,7 +552,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>         }
>
>         for (i = start_sec; i <= end_sec; i++) {
> -               err = __add_section(nid, zone, section_nr_to_pfn(i));
> +               err = __add_section(nid, zone, section_nr_to_pfn(i), want_memblock);
>
>                 /*
>                  * EEXIST is finally dealt with by ioresource collision
> --
> 2.11.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
