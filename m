Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40E748E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 15:29:59 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w4so6770408otj.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:29:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5sor7458097oig.111.2018.12.11.12.29.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 12:29:57 -0800 (PST)
MIME-Version: 1.0
References: <20181211010310.8551-1-keith.busch@intel.com> <20181211010310.8551-3-keith.busch@intel.com>
 <CAPcyv4gEpxigPqc0PgDE0YCL3Ot+wPfvChAZqUTtdYR2WDxaJg@mail.gmail.com> <20181211165518.GB8101@localhost.localdomain>
In-Reply-To: <20181211165518.GB8101@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 11 Dec 2018 12:29:45 -0800
Message-ID: <CAPcyv4id0mgjdBPPw8Y26rodOEQ=EHfaTrgasU5g4X7u=dS2xw@mail.gmail.com>
Subject: Re: [PATCHv2 02/12] acpi/hmat: Parse and report heterogeneous memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Dec 11, 2018 at 8:58 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Mon, Dec 10, 2018 at 10:03:40PM -0800, Dan Williams wrote:
> > I have a use case to detect the presence of a memory-side-cache early
> > at init time [1]. To me this means that hmat_init() needs to happen as
> > a part of acpi_numa_init(). Subsequently I think that also means that
> > the sysfs portion needs to be broken out to its own init path that can
> > probably run at module_init() priority.
> >
> > Perhaps we should split this patch set into two? The table parsing
> > with an in-kernel user is a bit easier to reason about and can go in
> > first. Towards that end can I steal / refllow patches 1 & 2 into the
> > memory randomization series? Other ideas how to handle this?
> >
> > [1]: https://lkml.org/lkml/2018/10/12/309
>
> To that end, will something like the following work for you? This just
> needs to happen after patch 1.
>
> ---
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index f5e09c39ff22..03ef3c8ba4ea 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -40,6 +40,8 @@ static int pxm_to_node_map[MAX_PXM_DOMAINS]
>  static int node_to_pxm_map[MAX_NUMNODES]
>                         = { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
>
> +static unsigned long node_side_cached[BITS_TO_LONGS(MAX_PXM_DOMAINS)];
> +
>  unsigned char acpi_srat_revision __initdata;
>  int acpi_numa __initdata;
>
> @@ -262,6 +264,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>         u64 start, end;
>         u32 hotpluggable;
>         int node, pxm;
> +       bool side_cached;
>
>         if (srat_disabled())
>                 goto out_err;
> @@ -308,6 +311,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>                 pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
>                         (unsigned long long)start, (unsigned long long)end - 1);
>
> +       side_cached = test_bit(pxm, node_side_cached);
> +       if (side_cached && memblock_mark_sidecached(start, ma->length))
> +               pr_warn("SRAT: Failed to mark side cached range [mem %#010Lx-%#010Lx] in memblock\n",
> +                       (unsigned long long)start, (unsigned long long)end - 1);
> +
>         max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
>
>         return 0;
> @@ -411,6 +419,19 @@ acpi_parse_memory_affinity(union acpi_subtable_headers * header,
>         return 0;
>  }
>
> +static int __init
> +acpi_parse_cache(union acpi_subtable_headers *header, const unsigned long end)
> +{
> +       struct acpi_hmat_cache *cache = (void *)header;
> +       u32 attrs;
> +
> +       attrs = cache->cache_attributes;
> +       if (((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) ==
> +                                               ACPI_HMAT_CA_DIRECT_MAPPED)
> +               set_bit(cache->memory_PD, node_side_cached);

I'm not sure I see a use case for 'node_side_cached'. Instead I need
to know if a cache intercepts a "System RAM" resource, because a cache
in front of a reserved address range would not be impacted by page
allocator randomization. Or, are you saying have memblock generically
describes this capability and move the responsibility of acting on
that data to a higher level?

The other detail to consider is the cache ratio size, but that would
be a follow on feature. The use case is to automatically determine the
ratio to pass to numa_emulation:

    cc9aec03e58f x86/numa_emulation: Introduce uniform split capability

> +       return 0;
> +}
> +
>  static int __init acpi_parse_srat(struct acpi_table_header *table)
>  {
>         struct acpi_table_srat *srat = (struct acpi_table_srat *)table;
> @@ -422,6 +443,11 @@ static int __init acpi_parse_srat(struct acpi_table_header *table)
>         return 0;
>  }
>
> +static __init int acpi_parse_hmat(struct acpi_table_header *table)
> +{
> +       return 0;
> +}

What's this acpi_parse_hmat() stub for?

> +
>  static int __init
>  acpi_table_parse_srat(enum acpi_srat_type id,
>                       acpi_tbl_entry_handler handler, unsigned int max_entries)
> @@ -460,6 +486,16 @@ int __init acpi_numa_init(void)
>                                         sizeof(struct acpi_table_srat),
>                                         srat_proc, ARRAY_SIZE(srat_proc), 0);
>
> +               if (!acpi_table_parse(ACPI_SIG_HMAT, acpi_parse_hmat)) {
> +                       struct acpi_subtable_proc hmat_proc;
> +
> +                       memset(&hmat_proc, 0, sizeof(hmat_proc));
> +                       hmat_proc.handler = acpi_parse_cache;
> +                       hmat_proc.id = ACPI_HMAT_TYPE_CACHE;
> +                       acpi_table_parse_entries_array(ACPI_SIG_HMAT,
> +                                               sizeof(struct acpi_table_hmat),
> +                                               &hmat_proc, 1, 0);
> +               }
>                 cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
>                                             acpi_parse_memory_affinity, 0);
>         }
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index aee299a6aa76..a24c918a4496 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -44,6 +44,7 @@ enum memblock_flags {
>         MEMBLOCK_HOTPLUG        = 0x1,  /* hotpluggable region */
>         MEMBLOCK_MIRROR         = 0x2,  /* mirrored region */
>         MEMBLOCK_NOMAP          = 0x4,  /* don't add to kernel direct mapping */
> +       MEMBLOCK_SIDECACHED     = 0x8,  /* System side caches memory access */

I'm concerned that we may be stretching memblock past its intended use
case especially for just this randomization case. For example, I think
memblock_find_in_range() gets confused in the presence of
MEMBLOCK_SIDECACHED memblocks.
