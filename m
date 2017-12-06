Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3F766B0323
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:43:38 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id j135so1050860oih.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:43:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q67sor626451oig.132.2017.12.05.18.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 18:43:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171205003443.22111-3-hch@lst.de>
References: <20171205003443.22111-1-hch@lst.de> <20171205003443.22111-3-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 5 Dec 2017 18:43:36 -0800
Message-ID: <CAPcyv4i3RP12-3T8R4tazfVvC+UG-FaUjorcbHnC1OPsc-5+YQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: fix dev_pagemap reference counting around get_dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>

On Mon, Dec 4, 2017 at 4:34 PM, Christoph Hellwig <hch@lst.de> wrote:
> Both callers of get_dev_pagemap that pass in a pgmap don't actually hold a
> reference to the pgmap they pass in, contrary to the comment in the function.
>
> Change the calling convention so that get_dev_pagemap always consumes the
> previous reference instead of doing this using an explicit earlier call to
> put_dev_pagemap in the callers.
>
> The callers will still need to put the final reference after finishing the
> loop over the pages.

I don't think we need this change, but perhaps the reasoning should be
added to the code as a comment... details below.

>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  kernel/memremap.c | 17 +++++++++--------
>  mm/gup.c          |  7 +++++--
>  2 files changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index f0b54eca85b0..502fa107a585 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -506,22 +506,23 @@ struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
>   * @pfn: page frame number to lookup page_map
>   * @pgmap: optional known pgmap that already has a reference
>   *
> - * @pgmap allows the overhead of a lookup to be bypassed when @pfn lands in the
> - * same mapping.
> + * If @pgmap is non-NULL and covers @pfn it will be returned as-is.  If @pgmap
> + * is non-NULL but does not cover @pfn the reference to it while be released.
>   */
>  struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
>                 struct dev_pagemap *pgmap)
>  {
> -       const struct resource *res = pgmap ? pgmap->res : NULL;
>         resource_size_t phys = PFN_PHYS(pfn);
>
>         /*
> -        * In the cached case we're already holding a live reference so
> -        * we can simply do a blind increment
> +        * In the cached case we're already holding a live reference.
>          */
> -       if (res && phys >= res->start && phys <= res->end) {
> -               percpu_ref_get(pgmap->ref);
> -               return pgmap;
> +       if (pgmap) {
> +               const struct resource *res = pgmap ? pgmap->res : NULL;
> +
> +               if (res && phys >= res->start && phys <= res->end)
> +                       return pgmap;
> +               put_dev_pagemap(pgmap);
>         }
>
>         /* fall back to slow path lookup */
> diff --git a/mm/gup.c b/mm/gup.c
> index d3fb60e5bfac..9d142eb9e2e9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1410,7 +1410,6 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>
>                 VM_BUG_ON_PAGE(compound_head(page) != head, page);
>
> -               put_dev_pagemap(pgmap);
>                 SetPageReferenced(page);
>                 pages[*nr] = page;
>                 (*nr)++;
> @@ -1420,6 +1419,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>         ret = 1;
>
>  pte_unmap:
> +       if (pgmap)
> +               put_dev_pagemap(pgmap);
>         pte_unmap(ptem);
>         return ret;
>  }
> @@ -1459,10 +1460,12 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>                 SetPageReferenced(page);
>                 pages[*nr] = page;
>                 get_page(page);
> -               put_dev_pagemap(pgmap);

It's safe to do the put_dev_pagemap() here because the pgmap cannot be
released until the corresponding put_page() for that get_page() we
just did occurs. So we're only holding the pgmap reference long enough
to take individual page references.

We used to take and put individual pgmap references inside get_page()
/ put_page(), but that got simplified in this commit to just take and
put page reference at devm_memremap_pages() setup / teardown time:

71389703839e mm, zone_device: Replace {get, put}_zone_device_page()
with a single reference to fix pmem crash

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
