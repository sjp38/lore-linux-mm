Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 75D2D6B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:27:43 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id 131so585985ykp.7
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 07:27:43 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id g10si11283077yhn.159.2014.01.22.07.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 07:27:39 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id w10so497875pde.6
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 07:27:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1390217559-14691-3-git-send-email-phacht@linux.vnet.ibm.com>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1390217559-14691-3-git-send-email-phacht@linux.vnet.ibm.com>
Date: Wed, 22 Jan 2014 09:27:34 -0600
Message-ID: <CAPp3RGoWtvRLcWZGDnvzPntG4HfcXhtg43hxLcrUoFDwyVLcAQ@mail.gmail.com>
Subject: Re: [PATCH V5 2/3] mm/memblock: Add support for excluded memory areas
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, Robin Holt <robin.m.holt@gmail.com>, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Cliff Wickman (SGI)" <cpw@sgi.com>

The reason I have not responded is I do not see the utility of this patch
and did not feel like I had been engaged enough in the design of whatever
is going to be using this to know if this is the right direction to
go.  As for the
code, it all looks like what I would have done assuming I really needed this.

I don't like the _nomap, because that indicates to too many people too many
different things.  That said, without knowing what this is going to be used
for, the only "better" term I could come up with is _reserved which is more
problematic.  Just as I was getting ready to send this email, I got the
flickering though that memblock_set_unusable()/memblock_set_usable()
might be a better pair of furnctions.

Sorry for coming across as difficult, I just don't feel comfortable with
my understanding of the context for this patch (and I am too lazy to
dig into it further).  I have looked at the prior discussions and I also
don't feel you have addressed the other concerns expressed in
those threads.  I, of course, reserve the right to be wrong.  I nearly
always am.

Thanks and sorry,
Robin Holt


On Mon, Jan 20, 2014 at 5:32 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
> Add a new memory state "nomap" to memblock. This can be used to truncate
> the usable memory in the system without forgetting about what is really
> installed.
>
> Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> ---
>  include/linux/memblock.h |  25 +++++++
>  mm/Kconfig               |   3 +
>  mm/memblock.c            | 175 ++++++++++++++++++++++++++++++++++++++++++++++-
>  mm/nobootmem.c           |   8 ++-
>  4 files changed, 209 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 1ef6636..be1c819 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -18,6 +18,7 @@
>  #include <linux/mm.h>
>
>  #define INIT_MEMBLOCK_REGIONS  128
> +#define INIT_MEMBLOCK_NOMAP_REGIONS 4

That 4 seems rather arbitrary.  Care to comment on how 4 was determined?

I think SGI has a special purpose driver that might benefit from _nomap
regions.  I will drag Cliff Whickman in to comment on that if he feels
like it.

>  /* Definition of memblock flags. */
>  #define MEMBLOCK_HOTPLUG       0x1     /* hotpluggable region */
> @@ -43,6 +44,9 @@ struct memblock {
>         phys_addr_t current_limit;
>         struct memblock_type memory;
>         struct memblock_type reserved;
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +       struct memblock_type nomap;
> +#endif
>  };
>
>  extern struct memblock memblock;
> @@ -68,6 +72,10 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
>  int memblock_remove(phys_addr_t base, phys_addr_t size);
>  int memblock_free(phys_addr_t base, phys_addr_t size);
>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +int memblock_nomap(phys_addr_t base, phys_addr_t size);
> +int memblock_remap(phys_addr_t base, phys_addr_t size);

Here is why I dislike _nomap.  The function to reverse the effect becomes
even more misleading.

> +#endif
>  void memblock_trim_memory(phys_addr_t align);
>  int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>  int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
> @@ -133,6 +141,23 @@ void __next_free_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
>              i != (u64)ULLONG_MAX;                                      \
>              __next_free_mem_range(&i, nid, p_start, p_end, p_nid))
>
> +
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +#define for_each_mapped_mem_range(i, nid, p_start, p_end, p_nid)       \

Again with the name.  To me, the _mapped_ implies there is a virtual to
physical translation or something like that which changes one address
into another, yet both resolve to the same physical memory.

> +       for (i = 0,                                                     \
> +                    __next_mapped_mem_range(&i, nid, &memblock.memory, \
> +                                     &memblock.nomap, p_start,         \
> +                                     p_end, p_nid);                    \
> +            i != (u64)ULLONG_MAX;                                      \
> +            __next_mapped_mem_range(&i, nid, &memblock.memory,         \
> +                                    &memblock.nomap,                   \
> +                                    p_start, p_end, p_nid))
> +
> +void __next_mapped_mem_range(u64 *idx, int nid, phys_addr_t *out_start,
> +                            phys_addr_t *out_end, int *out_nid);
> +
> +#endif
> +
>  void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
>                                phys_addr_t *out_end, int *out_nid);
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 2d9f150..6907654 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config ARCH_DISCARD_MEMBLOCK
>         boolean
>
> +config ARCH_MEMBLOCK_NOMAP
> +       boolean
> +
>  config NO_BOOTMEM
>         boolean
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9c0aeef..b36f5d3 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -28,6 +28,11 @@
>  static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
>  static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
>
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +static struct memblock_region
> +memblock_nomap_init_regions[INIT_MEMBLOCK_NOMAP_REGIONS] __initdata_memblock;
> +#endif
> +
>  struct memblock memblock __initdata_memblock = {
>         .memory.regions         = memblock_memory_init_regions,
>         .memory.cnt             = 1,    /* empty dummy entry */
> @@ -37,6 +42,11 @@ struct memblock memblock __initdata_memblock = {
>         .reserved.cnt           = 1,    /* empty dummy entry */
>         .reserved.max           = INIT_MEMBLOCK_REGIONS,
>
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +       .nomap.regions       = memblock_nomap_init_regions,
> +       .nomap.cnt           = 1,       /* empty dummy entry */
> +       .nomap.max           = INIT_MEMBLOCK_NOMAP_REGIONS,
> +#endif
>         .bottom_up              = false,
>         .current_limit          = MEMBLOCK_ALLOC_ANYWHERE,
>  };
> @@ -292,6 +302,20 @@ phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
>                           memblock.memory.max);
>  }
>
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +phys_addr_t __init_memblock get_allocated_memblock_nomap_regions_info(
> +                                       phys_addr_t *addr)
> +{
> +       if (memblock.memory.regions == memblock_memory_init_regions)
> +               return 0;
> +
> +       *addr = __pa(memblock.memory.regions);
> +
> +       return PAGE_ALIGN(sizeof(struct memblock_region) *
> +                         memblock.memory.max);
> +}
> +
> +#endif /* CONFIG_ARCH_MEMBLOCK_NOMAP */
>  #endif
>
>  /**
> @@ -757,6 +781,60 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
>         return 0;
>  }
>
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +/*
> + * memblock_nomap() - mark a memory range as completely unusable
> + *
> + * This can be used to exclude memory regions from every further treatment
> + * in the running system. Ranges which are added to the nomap list will
> + * also be marked as reserved. So they won't either be allocated by memblock
> + * nor freed to the page allocator.
> + *
> + * The usable (i.e. not in nomap list) memory can be iterated
> + * via for_each_mapped_mem_range().
> + *
> + * memblock_start_of_DRAM() and memblock_end_of_DRAM() still refer to the
> + * whole system memory.
> + */
> +int __init_memblock memblock_nomap(phys_addr_t base, phys_addr_t size)
> +{
> +       int ret;
> +       memblock_dbg("memblock_nomap: [%#016llx-%#016llx] %pF\n",
> +                    (unsigned long long)base,
> +                    (unsigned long long)base + size,
> +                    (void *)_RET_IP_);

Personally, I never like using _RET_IP, but that might just be me.  Since it is
already used in equivalent functions, I would not try to argue against using
it here.

> +
> +       ret = memblock_add_region(&memblock.reserved, base,
> +                                 size, MAX_NUMNODES, 0);
> +       if (ret)
> +               return ret;
> +
> +       return memblock_add_region(&memblock.nomap, base,
> +                                  size, MAX_NUMNODES, 0);
> +}
> +
> +/*
> + * memblock_remap() - remove a memory range from the nomap list
> + *
> + * This is the inverse function to memblock_nomap().

Shouldn't this really be the "reverse" function?

> + */
> +int __init_memblock memblock_remap(phys_addr_t base, phys_addr_t size)
> +{
> +       int ret;
> +       memblock_dbg("memblock_remap: [%#016llx-%#016llx] %pF\n",
> +                    (unsigned long long)base,
> +                    (unsigned long long)base + size,
> +                    (void *)_RET_IP_);
> +
> +       ret = __memblock_remove(&memblock.reserved, base, size);
> +       if (ret)
> +               return ret;
> +
> +       return __memblock_remove(&memblock.nomap, base, size);
> +}
> +
> +#endif
> +
>  /**
>   * __next_free_mem_range - next function for for_each_free_mem_range()
>   * @idx: pointer to u64 loop variable
> @@ -836,6 +914,88 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
>         *idx = ULLONG_MAX;
>  }
>
> +#ifdef ARCH_MEMBLOCK_NOMAP
> +/**
> + * __next_mapped_mem_range - next function for for_each_free_mem_range()
> + * @idx: pointer to u64 loop variable
> + * @nid: node selector, %NUMA_NO_NODE for all nodes
> + * @out_start: ptr to phys_addr_t for start address of the range, can be %NULL
> + * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
> + * @out_nid: ptr to int for nid of the range, can be %NULL
> + *
> + * Find the first free area from *@idx which matches @nid, fill the out
> + * parameters, and update *@idx for the next iteration.  The lower 32bit of
> + * *@idx contains index into memory region and the upper 32bit indexes the
> + * areas before each reserved region.  For example, if reserved regions
> + * look like the following,
> + *
> + *     0:[0-16), 1:[32-48), 2:[128-130)
> + *
> + * The upper 32bit indexes the following regions.
> + *
> + *     0:[0-0), 1:[16-32), 2:[48-128), 3:[130-MAX)
> + *
> + * As both region arrays are sorted, the function advances the two indices
> + * in lockstep and returns each intersection.
> + */
> +void __init_memblock __next_mapped_mem_range(u64 *idx, int nid,
> +                                          phys_addr_t *out_start,
> +                                          phys_addr_t *out_end, int *out_nid)
> +{
> +       struct memblock_type *mem = &memblock.memory;
> +       struct memblock_type *rsv = &memblock.nomap;
> +       int mi = *idx & 0xffffffff;
> +       int ri = *idx >> 32;
> +
> +       if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
> +               nid = NUMA_NO_NODE;
> +
> +       for (; mi < mem->cnt; mi++) {
> +               struct memblock_region *m = &mem->regions[mi];
> +               phys_addr_t m_start = m->base;
> +               phys_addr_t m_end = m->base + m->size;
> +
> +               /* only memory regions are associated with nodes, check it */
> +               if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
> +                       continue;
> +
> +               /* scan areas before each reservation for intersection */
> +               for (; ri < rsv->cnt + 1; ri++) {
> +                       struct memblock_region *r = &rsv->regions[ri];
> +                       phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
> +                       phys_addr_t r_end = ri < rsv->cnt ?
> +                               r->base : ULLONG_MAX;
> +
> +                       /* if ri advanced past mi, break out to advance mi */
> +                       if (r_start >= m_end)
> +                               break;
> +                       /* if the two regions intersect, we're done */
> +                       if (m_start < r_end) {
> +                               if (out_start)
> +                                       *out_start = max(m_start, r_start);
> +                               if (out_end)
> +                                       *out_end = min(m_end, r_end);
> +                               if (out_nid)
> +                                       *out_nid = memblock_get_region_node(m);
> +                               /*
> +                                * The region which ends first is advanced
> +                                * for the next iteration.
> +                                */
> +                               if (m_end <= r_end)
> +                                       mi++;
> +                               else
> +                                       ri++;
> +                               *idx = (u32)mi | (u64)ri << 32;
> +                               return;
> +                       }
> +               }
> +       }
> +
> +       /* signal end of iteration */
> +       *idx = ULLONG_MAX;
> +}
> +#endif
> +
>  /**
>   * __next_free_mem_range_rev - next function for for_each_free_mem_range_reverse()
>   * @idx: pointer to u64 loop variable
> @@ -1438,12 +1598,21 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
>  void __init_memblock __memblock_dump_all(void)
>  {
>         pr_info("MEMBLOCK configuration:\n");
> +#ifndef CONFIG_ARCH_MEMBLOCK_NOMAP
>         pr_info(" memory size = %#llx reserved size = %#llx\n",
>                 (unsigned long long)memblock.memory.total_size,
>                 (unsigned long long)memblock.reserved.total_size);
> -
> +#else
> +       pr_info(" memory size = %#llx reserved size = %#llx nomap size = %#llx\n",
> +               (unsigned long long)memblock.memory.total_size,
> +               (unsigned long long)memblock.reserved.total_size,
> +               (unsigned long long)memblock.nomap.total_size);
> +#endif
>         memblock_dump(&memblock.memory, "memory");
>         memblock_dump(&memblock.reserved, "reserved");
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +       memblock_dump(&memblock.nomap, "nomap");
> +#endif
>  }
>
>  void __init memblock_allow_resize(void)
> @@ -1502,6 +1671,10 @@ static int __init memblock_init_debugfs(void)
>                 return -ENXIO;
>         debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
>         debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +       debugfs_create_file("nomap", S_IRUGO, root,
> +                           &memblock.nomap, &memblock_debug_fops);
> +#endif
>
>         return 0;
>  }
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 0215c77..61966b6 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -138,9 +138,15 @@ static unsigned long __init free_low_memory_core_early(void)
>                 size = get_allocated_memblock_memory_regions_info(&start);
>                 if (size)
>                         count += __free_memory_core(start, start + size);
> +
> +#ifdef CONFIG_ARCH_MEMBLOCK_NOMAP
> +       /* Free memblock.nomap array if it was allocated */
> +       size = get_allocated_memblock_memory_regions_info(&start);
> +       if (size)
> +               count += __free_memory_core(start, start + size);
> +#endif
>         }
>  #endif
> -
>         return count;
>  }
>
> --
> 1.8.4.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
