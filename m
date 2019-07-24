Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C227C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:49:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A013F21850
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:49:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="vBsunLdt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A013F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36BA58E000F; Wed, 24 Jul 2019 17:49:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F53A8E0002; Wed, 24 Jul 2019 17:49:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16F8B8E000F; Wed, 24 Jul 2019 17:49:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE65D8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:49:16 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id i6so18677150oib.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:49:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bsGVrNHwPTAmOMLvk4TLoH5B1OMej5ej2NFNpjdGbHQ=;
        b=KwQpRaDm3DQjZL95HITL23kws+JxZ4hfFDh1p6eTpiBnyVhbO/KmoOoiH1F815Esjf
         uMNV6Bi/WJBcBLgUMH0OHGHJ6OVbV1S4iVOxH6yuP5yffh6S8IU2JE2W/JBA6Ayf5Rmy
         1WeF/Jw4lsWBl6oQqQf92Gfd6aLApBeUujPhmiLFCQaIv/Iv/H9q0JZ0RatICuz1A7Wu
         y/ffSShgX2Ksnfag7WxK4RL955zy8dE22ACp6+i7D/QVzWol0oEkqeFIGRpNloKXtQ2T
         AdWTxHfIKM3SFMjRObASImF19uUIqi7PHXeVlohr4pMV2dDiO6lceLIV57NwMQ5u4Ppl
         KcIw==
X-Gm-Message-State: APjAAAWiImG2hHJ6vPmGXCtBmDw9draceCgcZZsrBHF/G2aH4lI7qU5Q
	YJ1LHsgiHxSxA/9CugbdOuhYJoOwrCQvsLsQrzt8n4+XtbX86sNszwDLFlsLwnuxYg1UeM0hhDa
	bXOKOtJ3TiUtBhaNYLaKrYo+T9J6ibD68LWOVmwO8YY/k7bzqkmXgywaYMDWdK1eWPg==
X-Received: by 2002:aca:2b13:: with SMTP id i19mr40769669oik.99.1564004956302;
        Wed, 24 Jul 2019 14:49:16 -0700 (PDT)
X-Received: by 2002:aca:2b13:: with SMTP id i19mr40769640oik.99.1564004954939;
        Wed, 24 Jul 2019 14:49:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564004954; cv=none;
        d=google.com; s=arc-20160816;
        b=lSYLKT6Yuq8yZ32lNvhdpqkGnxcJjILxUjpbAm36GbMDdAQGhe/9TmcDlnZODm00Et
         Q86lycxLza4alRni9Do9Qhzldwh5Nf3Rj3kjQgtSixzcfwYJ47qhfRfhtzOZtR8jh+Wn
         /md7mJgJIQyEaPVCSjSuZyP836EadZm/ax/3xYeOlcHGNGz+dZnY9Y5Of1112jpYgL+u
         cJPmDNrZKwrE0ACfd2aiJYab0YD22Sft4gnWU2/kkkhoAgBLw5WRhIGe+GILa5OYfrwt
         lmcTO6oZZNFc3K5WElEdeayDlan9H3mXZTn/NZzMksLi5JngwAluLm2QYVrLN3ih0L82
         GgzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bsGVrNHwPTAmOMLvk4TLoH5B1OMej5ej2NFNpjdGbHQ=;
        b=sOBE/9PhEspRxjam8hyEAfTmRh84rqCiXG5CAcsp8kDwEr4FbhBOfe8L9Yzal/02Vo
         MhCcyVZLohGANhf8Kw4RSZZu6LTrKyZFL00kyINRjIbuxKmcuUXvUGSMylwaLIRbYmb2
         a1QDXFHs8j8jI8UxtXl7V5pLXcQ7I3zE3yzd5PUUR29R4QxbMEVLixLH/frIQdNGQdmQ
         OsVwRFhXuwlfqmXuLxPs9JwfK3C8rno87hXBnzT/3AuJXsm9B13KGaS9odCLeADGNIqB
         l+P5/Jo6pnPl1XY0igoVJvkgHy9bSYMRMrWH5maOM5kv51lbNohaU+6Ef50nV1o1G0Lz
         whRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vBsunLdt;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor24922607otd.142.2019.07.24.14.49.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 14:49:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vBsunLdt;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bsGVrNHwPTAmOMLvk4TLoH5B1OMej5ej2NFNpjdGbHQ=;
        b=vBsunLdtnscnRRD7VWOrh8PUFocKMK74x7hBDqY5pSGhZiMcykmH6jfowq92kDpybQ
         K904++3PDOpOGAaBc7ulWs64lfqZ3niAf5EU75f/NOerUjLHPsOfmZLH4evorMhpkMY+
         4VeIa3K62mBxqjZBT1QR8/mlM1UVdVwArppFNZFxcU/DqMCul1SUEJGNdRMdWkyVUvqy
         y0slr7qRVbfclvDR6hC6PtPmb/hZz6IAPQrRG/x9jGsrHcnEQGrEz4cgZRTJRUpOmGiO
         Xe1nMSjIlQBVkZyaOyH7hebiuMMLpuHPvxu/uO6HcyK2N16piw7k9UFttDKASe4ptT+k
         JDXw==
X-Google-Smtp-Source: APXvYqy1805FeL99np02CekB9UIZRx/rUOItOLKh0I10dd8W10WU+sAnMUj8E/WaSPgOrqy+Tg13OOgizhfmtIvT1TU=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr61423217otf.126.1564004954433;
 Wed, 24 Jul 2019 14:49:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190625075227.15193-1-osalvador@suse.de> <20190625075227.15193-5-osalvador@suse.de>
In-Reply-To: <20190625075227.15193-5-osalvador@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Jul 2019 14:49:02 -0700
Message-ID: <CAPcyv4iPKm7c7-xPN9AVoKdXKdcZqO8v1K=Op1t86P2F8E40YQ@mail.gmail.com>
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, 
	David Hildenbrand <david@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> Physical memory hotadd has to allocate a memmap (struct page array) for
> the newly added memory section. Currently, alloc_pages_node() is used
> for those allocations.
>
> This has some disadvantages:
>  a) an existing memory is consumed for that purpose
>     (~2MB per 128MB memory section on x86_64)
>  b) if the whole node is movable then we have off-node struct pages
>     which has performance drawbacks.
>
> a) has turned out to be a problem for memory hotplug based ballooning
>    because the userspace might not react in time to online memory while
>    the memory consumed during physical hotadd consumes enough memory to
>    push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory") has been added to workaround that
>    problem.
>
> I have also seen hot-add operations failing on powerpc due to the fact
> that we try to use order-8 pages. If the base page size is 64KB, this
> gives us 16MB, and if we run out of those, we simply fail.
> One could arge that we can fall back to basepages as we do in x86_64, but
> we can do better when CONFIG_SPARSEMEM_VMEMMAP is enabled.
>
> Vmemap page tables can map arbitrary memory.
> That means that we can simply use the beginning of each memory section and
> map struct pages there.
> struct pages which back the allocated space then just need to be treated
> carefully.
>
> Implementation wise we reuse vmem_altmap infrastructure to override
> the default allocator used by __vmemap_populate. Once the memmap is
> allocated we need a way to mark altmap pfns used for the allocation.
> If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we call
> mark_vmemmap_pages().
>
> Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
> mark_vmemmap_pages() gets called at a different stage.
> With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
> fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
> sections have been populated.
>
> mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:
>
> The current layout of the Vmemmap pages are:
>
>         [Head->refcount] : Nr sections used by this altmap
>         [Head->private]  : Nr of vmemmap pages
>         [Tail->freelist] : Pointer to the head page
>
> This is done to easy the computation we need in some places.
> E.g:
>
> Example 1)
> We hot-add 1GB on x86_64 (memory block 128MB) using
> MHP_MEMMAP_DEVICE:
>
> head->_refcount = 8 sections
> head->private = 4096 vmemmap pages
> tail's->freelist = head
>
> Example 2)
> We hot-add 1GB on x86_64 using MHP_MEMMAP_MEMBLOCK:
>
> [at the beginning of each memblock]
> head->_refcount = 1 section
> head->private = 512 vmemmap pages
> tail's->freelist = head
>
> We have the refcount because when using MHP_MEMMAP_DEVICE, we need to know
> how much do we have to defer the call to vmemmap_free().
> The thing is that the first pages of the hot-added range are used to create
> the memmap mapping, so we cannot remove those first, otherwise we would blow up
> when accessing the other pages.
>
> What we do is that since when we hot-remove a memory-range, sections are being
> removed sequentially, we wait until we hit the last section, and then we free
> the hole range to vmemmap_free backwards.
> We know that it is the last section because in every pass we
> decrease head->_refcount, and when it reaches 0, we got our last section.
>
> We also have to be careful about those pages during online and offline
> operations. They are simply skipped, so online will keep them
> reserved and so unusable for any other purpose and offline ignores them
> so they do not block the offline operation.
>
> In offline operation we only have to check for one particularity.
> Depending on how large was the hot-added range, and using MHP_MEMMAP_DEVICE,
> can be that one or more than one memory block is filled with only vmemmap pages.
> We just need to check for this case and skip 1) isolating 2) migrating,
> because those pages do not need to be migrated anywhere, they are self-hosted.

Can you rewrite the changelog without using the word 'we' I get
confused when it seems to reference the 'we' current implementation vs
the 'we' new implementation.

>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  arch/arm64/mm/mmu.c            |   5 +-
>  arch/powerpc/mm/init_64.c      |   7 +++
>  arch/s390/mm/init.c            |   6 ++
>  arch/x86/mm/init_64.c          |  10 +++
>  drivers/acpi/acpi_memhotplug.c |   2 +-
>  drivers/base/memory.c          |   2 +-
>  include/linux/memory_hotplug.h |   6 ++
>  include/linux/memremap.h       |   2 +-
>  mm/compaction.c                |   7 +++
>  mm/memory_hotplug.c            | 138 +++++++++++++++++++++++++++++++++++------
>  mm/page_alloc.c                |  22 ++++++-
>  mm/page_isolation.c            |  14 ++++-
>  mm/sparse.c                    |  93 +++++++++++++++++++++++++++
>  13 files changed, 289 insertions(+), 25 deletions(-)
>
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 93ed0df4df79..d4b5661fa6b6 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -765,7 +765,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>                 if (pmd_none(READ_ONCE(*pmdp))) {
>                         void *p = NULL;
>
> -                       p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> +                       if (altmap)
> +                               p = altmap_alloc_block_buf(PMD_SIZE, altmap);
> +                       else
> +                               p = vmemmap_alloc_block_buf(PMD_SIZE, node);
>                         if (!p)
>                                 return -ENOMEM;
>
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index a4e17a979e45..ff9d2c245321 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -289,6 +289,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>
>                 if (base_pfn >= alt_start && base_pfn < alt_end) {
>                         vmem_altmap_free(altmap, nr_pages);
> +               } else if (PageVmemmap(page)) {
> +                       /*
> +                        * runtime vmemmap pages are residing inside the memory
> +                        * section so they do not have to be freed anywhere.
> +                        */
> +                       while (PageVmemmap(page))
> +                               __ClearPageVmemmap(page++);
>                 } else if (PageReserved(page)) {
>                         /* allocated from bootmem */
>                         if (page_size < PAGE_SIZE) {
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index ffb81fe95c77..c045411552a3 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -226,6 +226,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
>         unsigned long size_pages = PFN_DOWN(size);
>         int rc;
>
> +       /*
> +        * Physical memory is added only later during the memory online so we
> +        * cannot use the added range at this stage unfortunately.
> +        */
> +       restrictions->flags &= ~restrictions->flags;
> +
>         if (WARN_ON_ONCE(restrictions->altmap))
>                 return -EINVAL;

Perhaps these per-arch changes should be pulled out into separate prep patches?

>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 688fb0687e55..00d17b666337 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -874,6 +874,16 @@ static void __meminit free_pagetable(struct page *page, int order)
>         unsigned long magic;
>         unsigned int nr_pages = 1 << order;
>
> +       /*
> +        * Runtime vmemmap pages are residing inside the memory section so
> +        * they do not have to be freed anywhere.
> +        */
> +       if (PageVmemmap(page)) {
> +               while (nr_pages--)
> +                       __ClearPageVmemmap(page++);
> +               return;
> +       }

If there is nothing to do and these pages are just going to be
released, why spend any effort clearing the vmemmap state?

> +
>         /* bootmem page has reserved flag */
>         if (PageReserved(page)) {
>                 __ClearPageReserved(page);
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 860f84e82dd0..3257edb98d90 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -218,7 +218,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>                 if (node < 0)
>                         node = memory_add_physaddr_to_nid(info->start_addr);
>
> -               result = __add_memory(node, info->start_addr, info->length, 0);
> +               result = __add_memory(node, info->start_addr, info->length, MHP_MEMMAP_DEVICE);

Why is this changed to MHP_MEMMAP_DEVICE? Where does it get the altmap?

>
>                 /*
>                  * If the memory block has been used by the kernel, add_memory()
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index ad9834b8b7f7..e0ac9a3b66f8 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -32,7 +32,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>
>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>
> -static int sections_per_block;
> +int sections_per_block;
>
>  static inline int base_memory_block_id(int section_nr)
>  {
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 6fdbce9d04f9..e28e226c9a20 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -375,4 +375,10 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
>                 int online_type);
>  extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
>                 unsigned long nr_pages);
> +
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +extern void mark_vmemmap_pages(struct vmem_altmap *self);
> +#else
> +static inline void mark_vmemmap_pages(struct vmem_altmap *self) {}
> +#endif
>  #endif /* __LINUX_MEMORY_HOTPLUG_H */
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 1732dea030b2..6de37e168f57 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -16,7 +16,7 @@ struct device;
>   * @alloc: track pages consumed, private to vmemmap_populate()
>   */
>  struct vmem_altmap {
> -       const unsigned long base_pfn;
> +       unsigned long base_pfn;
>         const unsigned long reserve;
>         unsigned long free;
>         unsigned long align;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..40697f74b8b4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -855,6 +855,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>                 nr_scanned++;
>
>                 page = pfn_to_page(low_pfn);
> +               /*
> +                * Vmemmap pages do not need to be isolated.
> +                */
> +               if (PageVmemmap(page)) {
> +                       low_pfn += get_nr_vmemmap_pages(page) - 1;

I'm failing to grok the get_nr_vmemmap_pages() api. It seems this is
more of a get_next_mapped_page() and perhaps it should VM_BUG_ON if it
is not passed a Vmemmap page.

> +                       continue;
> +               }
>
>                 /*
>                  * Check if the pageblock has already been marked skipped.
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e4e3baa6eaa7..b5106cb75795 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -42,6 +42,8 @@
>  #include "internal.h"
>  #include "shuffle.h"
>
> +extern int sections_per_block;
> +
>  /*
>   * online_page_callback contains pointer to current page onlining function.
>   * Initially it is generic_online_page(). If it is required it could be
> @@ -279,6 +281,24 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
>         return 0;
>  }
>
> +static void mhp_reset_altmap(unsigned long next_pfn,
> +                            struct vmem_altmap *altmap)
> +{
> +       altmap->base_pfn = next_pfn;
> +       altmap->alloc = 0;
> +}
> +
> +static void mhp_init_altmap(unsigned long pfn, unsigned long nr_pages,
> +                           unsigned long mhp_flags,
> +                           struct vmem_altmap *altmap)
> +{
> +       if (mhp_flags & MHP_MEMMAP_DEVICE)
> +               altmap->free = nr_pages;
> +       else
> +               altmap->free = PAGES_PER_SECTION * sections_per_block;
> +       altmap->base_pfn = pfn;

The ->free member is meant to be the number of free pages in the
altmap this seems to be set to the number of pages being mapped. Am I
misreading?

> +}
> +
>  /*
>   * Reasonably generic function for adding memory.  It is
>   * expected that archs that support memory hotplug will
> @@ -290,8 +310,17 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  {
>         unsigned long i;
>         int start_sec, end_sec, err;
> -       struct vmem_altmap *altmap = restrictions->altmap;
> +       struct vmem_altmap *altmap;
> +       struct vmem_altmap __memblk_altmap = {};
> +       unsigned long mhp_flags = restrictions->flags;
> +       unsigned long sections_added;
> +
> +       if (mhp_flags & MHP_VMEMMAP_FLAGS) {
> +               mhp_init_altmap(pfn, nr_pages, mhp_flags, &__memblk_altmap);
> +               restrictions->altmap = &__memblk_altmap;
> +       }

So this silently overrides a passed in altmap if a flag is set? The
NVDIMM use case can't necessarily trust __memblk_altmap to be
consistent with what the nvdimm namespace has reserved.

>
> +       altmap = restrictions->altmap;
>         if (altmap) {
>                 /*
>                  * Validate altmap is within bounds of the total request
> @@ -308,9 +337,10 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>         if (err)
>                 return err;
>
> +       sections_added = 1;
>         start_sec = pfn_to_section_nr(pfn);
>         end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> -       for (i = start_sec; i <= end_sec; i++) {
> +       for (i = start_sec; i <= end_sec; i++, sections_added++) {
>                 unsigned long pfns;
>
>                 pfns = min(nr_pages, PAGES_PER_SECTION
> @@ -320,9 +350,19 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>                         break;
>                 pfn += pfns;
>                 nr_pages -= pfns;
> +
> +               if (mhp_flags & MHP_MEMMAP_MEMBLOCK &&
> +                   !(sections_added % sections_per_block)) {
> +                       mark_vmemmap_pages(altmap);
> +                       mhp_reset_altmap(pfn, altmap);
> +               }
>                 cond_resched();
>         }
>         vmemmap_populate_print_last();
> +
> +       if (mhp_flags & MHP_MEMMAP_DEVICE)
> +               mark_vmemmap_pages(altmap);
> +
>         return err;
>  }
>
> @@ -642,6 +682,14 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
>         while (start < end) {
>                 order = min(MAX_ORDER - 1,
>                         get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> +               /*
> +                * Check if the pfn is aligned to its order.
> +                * If not, we decrement the order until it is,
> +                * otherwise __free_one_page will bug us.
> +                */
> +               while (start & ((1 << order) - 1))
> +                       order--;
> +

Is this a candidate for a standalone patch? It seems out of place for
this patch.

>                 (*online_page_callback)(pfn_to_page(start), order);
>
>                 onlined_pages += (1UL << order);
> @@ -654,13 +702,30 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>                         void *arg)
>  {
>         unsigned long onlined_pages = *(unsigned long *)arg;
> +       unsigned long pfn = start_pfn;
> +       unsigned long nr_vmemmap_pages = 0;
>
> -       if (PageReserved(pfn_to_page(start_pfn)))
> -               onlined_pages += online_pages_blocks(start_pfn, nr_pages);
> +       if (PageVmemmap(pfn_to_page(pfn))) {
> +               /*
> +                * Do not send vmemmap pages to the page allocator.
> +                */
> +               nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
> +               nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
> +               pfn += nr_vmemmap_pages;
> +               if (nr_vmemmap_pages == nr_pages)
> +                       /*
> +                        * If the entire range contains only vmemmap pages,
> +                        * there are no pages left for the page allocator.
> +                        */
> +                       goto skip_online;
> +       }

Seems this should be caller (online_pages()) responsibility rather
than making this fixup internal to the helper... and if it's moved up
can it be pushed one more level up so even online_pages() need not
worry about this fixup? It just does not seem to an operation that
belongs to the online path. Might that eliminate the need for tracking
altmap parameters in struct page?

