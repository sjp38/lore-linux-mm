Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC553C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:47:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83EAD2491B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 04:47:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Cnt8/9rX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83EAD2491B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E5656B000D; Tue,  4 Jun 2019 00:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1974A6B0010; Tue,  4 Jun 2019 00:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05D8A6B0266; Tue,  4 Jun 2019 00:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF0A06B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 00:47:39 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l12so6043950oii.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 21:47:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NIMPqRiIc7VO9Ecs79FZ0/smvxfEMHT4jVxiExc4CdA=;
        b=J09Z3Pv2beuKUTpW+GJB/CGfgkTEKV34L+B1gUVwEx085z5MjefVgl/EzY2mnBB9Wm
         se8mcCZ+8uiAVCmr6tX1fAwDw7b0MJ9XM4DVo86ZNXI3y44YD6nZ4P/p076mjfO011x8
         K64d+uOb4tiLDcBa1tnd+VuT9BoM4dzoeLM40kgKHRCtpgxIDVi3/d/eXf9Ntf17LwDD
         4/9ZRyGfApqNm/3ZyauGNgLlacOBiUnt5ZHLCIZqg8P4e0J0BlBlgFTdYCaqb3ZLO3dg
         rNkG44J61AxjC/b4QlOKAHcj8zL6LlsfzwasCfuM1P8U1GDnyh3oK3HZ7kY3lWMY5t1x
         3Ywg==
X-Gm-Message-State: APjAAAUvevEGz7/L6ZQHHAJhrE9pYe56sNhOP+ZGcNnTFKuHEGefgm/U
	IdZ+fRrCFFY5Ye1zphKoVJzwobhEOuejPT5zVLkoM+Om8J7O7XRH1d4wkdXxWs6gbGTbvdO5Hz6
	mNnqHMKFp5MvBNv2vkf1k2lJdtAbef4gMdVoI+WegOsOdTvPMtecKVJN+CPl9aXwNmg==
X-Received: by 2002:aca:d88b:: with SMTP id p133mr3197414oig.3.1559623659455;
        Mon, 03 Jun 2019 21:47:39 -0700 (PDT)
X-Received: by 2002:aca:d88b:: with SMTP id p133mr3197381oig.3.1559623657999;
        Mon, 03 Jun 2019 21:47:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559623657; cv=none;
        d=google.com; s=arc-20160816;
        b=ZQC4wuLWT+7BrxEkxyNiYZdgiDc1Z7669owIcqxJrL4jFpcdb9wEo5qHK4RrBqsf9n
         EICQSjZL6fFla2PnRV6RArgxKAcYMZfNpDz7BnWzsaNMqdtcboesxbJAkNxsPq/9/Jak
         QDoRUpqR8BHPB/LWw3OaruDwBYwf347ry2xwEOLaJMchJ1qBnm5w5BnZbPnUczpL368S
         O1RhPD8jz2XhkJv9IPGN9HowNZA7+oCTdtfFBVPVp1KwkJdjWOzXijJFvkbhUOpIObYl
         huakNpEHX78Gppcp4A0TUiiLEeTcukBkR6nfNGZ9c+g9z/dqkc64esABUErH4xuPL81Q
         75CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NIMPqRiIc7VO9Ecs79FZ0/smvxfEMHT4jVxiExc4CdA=;
        b=g1UydAY8oNe3IL2k4xdnWyEuiSXzyH0u0ED4avfGzyHmoz7FWXQqUq1v3yAaQ4qDpt
         UAdZ/yLMPk62C5FVLdzOC3S3p9cEbAZabngsoMIy+UzkspRnOQI3M2/RGVdrUmJ7inaJ
         rhmQRnzNZpjypGDkz1rO55OVCEteOHE4Ejhdc6eEFKUx6l1lZb5tcnlw079fPyhwrEVn
         F7X1RruV10qsUyi4UXxNmciryIe6uWdNUdOCkVorAAuiqkbfArqcKaGniQcYN0Ot6jnO
         I7sOQ9DouspyKbJ5kUX74GhlGFQ08psXMKR4DdwFGvYRoIJFE8DsM9PzgowpLLy9c/Ur
         jr4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Cnt8/9rX";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor6037382oif.24.2019.06.03.21.47.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 21:47:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Cnt8/9rX";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NIMPqRiIc7VO9Ecs79FZ0/smvxfEMHT4jVxiExc4CdA=;
        b=Cnt8/9rXTev0n4TZ8V6Pn7Ou3j2r19rDkWIsWPqnviE7o+nosWy84tHUvvUGqI7/Zv
         zX4AOW4iabUYCWul4Mhuv0n3GFJNU/nu66m0/fgV2tB6bOg3nYRwzw/WDlfDJvfQvcTd
         cH23g1Ji/7t+0CKCKnBMsHU4SAZlH+3c+5oAms191FPz/deXAVh7mai6hE8/g0z1t2AT
         wPQS1I/w2eqUWZ5vplV0wZzXYRHLEsFC/49hsYZXKRYRBm+G42b4u6jK/iBv1841EIws
         aUc8vzca6AXpHwuynnM2PtvWpwctdKzjek5rsg0E6FDnY7fSAZudzrIQCiX7fZmc80Hv
         ylqA==
X-Google-Smtp-Source: APXvYqy9sW2LEKuD1NjiRnAQYvaN7oPBcJ5189ofJPPWbpQKpR0eVVumrOlBe63/lRBgYjPKVWqQYbMsBUdNwgc6RDA=
X-Received: by 2002:aca:4208:: with SMTP id p8mr3327666oia.105.1559623657377;
 Mon, 03 Jun 2019 21:47:37 -0700 (PDT)
MIME-Version: 1.0
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155718601407.130019.14248061058774128227.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190513135317.GA31168@linux>
In-Reply-To: <20190513135317.GA31168@linux>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Jun 2019 21:47:25 -0700
Message-ID: <CAPcyv4hq2yp0d3Tx8HUWJwLhXw2y=0sTRpd8EQhZ+8ffjQgnDg@mail.gmail.com>
Subject: Re: [PATCH v8 09/12] mm/sparsemem: Support sub-section hotplug
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 6:55 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Mon, May 06, 2019 at 04:40:14PM -0700, Dan Williams wrote:
> >
> > +void subsection_mask_set(unsigned long *map, unsigned long pfn,
> > +             unsigned long nr_pages)
> > +{
> > +     int idx = subsection_map_index(pfn);
> > +     int end = subsection_map_index(pfn + nr_pages - 1);
> > +
> > +     bitmap_set(map, idx, end - idx + 1);
> > +}
> > +
> >  void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
> >  {
> >       int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> > @@ -219,20 +235,17 @@ void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
> >               return;
> >
> >       for (i = start_sec; i <= end_sec; i++) {
> > -             int idx, end;
> > -             unsigned long pfns;
> >               struct mem_section *ms;
> > +             unsigned long pfns;
> >
> > -             idx = subsection_map_index(pfn);
> >               pfns = min(nr_pages, PAGES_PER_SECTION
> >                               - (pfn & ~PAGE_SECTION_MASK));
> > -             end = subsection_map_index(pfn + pfns - 1);
> > -
> >               ms = __nr_to_section(i);
> > -             bitmap_set(ms->usage->subsection_map, idx, end - idx + 1);
> > +             subsection_mask_set(ms->usage->subsection_map, pfn, pfns);
> >
> >               pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
> > -                             pfns, idx, end - idx + 1);
> > +                             pfns, subsection_map_index(pfn),
> > +                             subsection_map_index(pfn + pfns - 1));
>
> I would definetely add subsection_mask_set() and above change to Patch#3.
> I think it suits there better than here.

Yes, done.

>
> >
> >               pfn += pfns;
> >               nr_pages -= pfns;
> > @@ -319,6 +332,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
> >               unsigned long pnum, struct page *mem_map,
> >               struct mem_section_usage *usage)
> >  {
> > +     /*
> > +      * Given that SPARSEMEM_VMEMMAP=y supports sub-section hotplug,
> > +      * ->section_mem_map can not be guaranteed to point to a full
> > +      *  section's worth of memory.  The field is only valid / used
> > +      *  in the SPARSEMEM_VMEMMAP=n case.
> > +      */
> > +     if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
> > +             mem_map = NULL;
> > +
> >       ms->section_mem_map &= ~SECTION_MAP_MASK;
> >       ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
> >                                                       SECTION_HAS_MEM_MAP;
> > @@ -724,10 +746,142 @@ static void free_map_bootmem(struct page *memmap)
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >  #endif /* CONFIG_SPARSEMEM_VMEMMAP */
> >
> > +#ifndef CONFIG_MEMORY_HOTREMOVE
> > +static void free_map_bootmem(struct page *memmap)
> > +{
> > +}
> > +#endif
> > +
> > +static bool is_early_section(struct mem_section *ms)
> > +{
> > +     struct page *usage_page;
> > +
> > +     usage_page = virt_to_page(ms->usage);
> > +     if (PageSlab(usage_page) || PageCompound(usage_page))
> > +             return false;
> > +     else
> > +             return true;
> > +}
> > +
> > +static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
> > +             int nid, struct vmem_altmap *altmap)
> > +{
> > +     DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
> > +     DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
> > +     struct mem_section *ms = __pfn_to_section(pfn);
> > +     bool early_section = is_early_section(ms);
> > +     struct page *memmap = NULL;
> > +     unsigned long *subsection_map = ms->usage
> > +             ? &ms->usage->subsection_map[0] : NULL;
> > +
> > +     subsection_mask_set(map, pfn, nr_pages);
> > +     if (subsection_map)
> > +             bitmap_and(tmp, map, subsection_map, SUBSECTIONS_PER_SECTION);
> > +
> > +     if (WARN(!subsection_map || !bitmap_equal(tmp, map, SUBSECTIONS_PER_SECTION),
> > +                             "section already deactivated (%#lx + %ld)\n",
> > +                             pfn, nr_pages))
> > +             return;
> > +
> > +     if (WARN(!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
> > +                             && nr_pages < PAGES_PER_SECTION,
> > +                             "partial memory section removal not supported\n"))
> > +             return;
> > +
> > +     /*
> > +      * There are 3 cases to handle across two configurations
> > +      * (SPARSEMEM_VMEMMAP={y,n}):
> > +      *
> > +      * 1/ deactivation of a partial hot-added section (only possible
> > +      * in the SPARSEMEM_VMEMMAP=y case).
> > +      *    a/ section was present at memory init
> > +      *    b/ section was hot-added post memory init
> > +      * 2/ deactivation of a complete hot-added section
> > +      * 3/ deactivation of a complete section from memory init
> > +      *
> > +      * For 1/, when subsection_map does not empty we will not be
> > +      * freeing the usage map, but still need to free the vmemmap
> > +      * range.
> > +      *
> > +      * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
> > +      */
> > +     bitmap_xor(subsection_map, map, subsection_map, SUBSECTIONS_PER_SECTION);
> > +     if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
> > +             unsigned long section_nr = pfn_to_section_nr(pfn);
> > +
> > +             if (!early_section) {
> > +                     kfree(ms->usage);
> > +                     ms->usage = NULL;
> > +             }
> > +             memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
> > +             ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
> > +     }
> > +
> > +     if (early_section && memmap)
> > +             free_map_bootmem(memmap);
> > +     else
> > +             depopulate_section_memmap(pfn, nr_pages, altmap);
> > +}
> > +
> > +static struct page * __meminit section_activate(int nid, unsigned long pfn,
> > +             unsigned long nr_pages, struct vmem_altmap *altmap)
> > +{
> > +     DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
> > +     struct mem_section *ms = __pfn_to_section(pfn);
> > +     struct mem_section_usage *usage = NULL;
> > +     unsigned long *subsection_map;
> > +     struct page *memmap;
> > +     int rc = 0;
> > +
> > +     subsection_mask_set(map, pfn, nr_pages);
> > +
> > +     if (!ms->usage) {
> > +             usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
> > +             if (!usage)
> > +                     return ERR_PTR(-ENOMEM);
> > +             ms->usage = usage;
> > +     }
> > +     subsection_map = &ms->usage->subsection_map[0];
> > +
> > +     if (bitmap_empty(map, SUBSECTIONS_PER_SECTION))
> > +             rc = -EINVAL;
> > +     else if (bitmap_intersects(map, subsection_map, SUBSECTIONS_PER_SECTION))
> > +             rc = -EEXIST;
> > +     else
> > +             bitmap_or(subsection_map, map, subsection_map,
> > +                             SUBSECTIONS_PER_SECTION);
> > +
> > +     if (rc) {
> > +             if (usage)
> > +                     ms->usage = NULL;
> > +             kfree(usage);
> > +             return ERR_PTR(rc);
> > +     }
> > +
> > +     /*
> > +      * The early init code does not consider partially populated
> > +      * initial sections, it simply assumes that memory will never be
> > +      * referenced.  If we hot-add memory into such a section then we
> > +      * do not need to populate the memmap and can simply reuse what
> > +      * is already there.
> > +      */
> > +     if (nr_pages < PAGES_PER_SECTION && is_early_section(ms))
> > +             return pfn_to_page(pfn);
> > +
> > +     memmap = populate_section_memmap(pfn, nr_pages, nid, altmap);
> > +     if (!memmap) {
> > +             section_deactivate(pfn, nr_pages, nid, altmap);
> > +             return ERR_PTR(-ENOMEM);
> > +     }
> > +
> > +     return memmap;
> > +}
>
> I do not really like this.
> Sub-section scheme is only available on CONFIG_SPARSE_VMEMMAP, so I would rather
> have two internal __section_{activate,deactivate} functions for sparse-vmemmap and
> sparse-non-vmemmap.
> That way, we can hide all detail implementation and sub-section dance behind
> the __section_{activate,deactivate} functions.

I don't see the win for doing that. The code would have 2 places to
check when making a change that might apply to both cases. If one
function can handle both configurations then it makes sense to keep
them unified. However, this did prompt me to go kill the unnecessary
WARN(!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP...) in section_deactivate()
since that is already covered by check_pfn_span() (formerly
subsection_check()).

>
> > +
> > @@ -741,49 +895,31 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
> >               unsigned long nr_pages, struct vmem_altmap *altmap)
> >  {
> >       unsigned long section_nr = pfn_to_section_nr(start_pfn);
> > -     struct mem_section_usage *usage;
> >       struct mem_section *ms;
> >       struct page *memmap;
> >       int ret;
> >
> > -     /*
> > -      * no locking for this, because it does its own
> > -      * plus, it does a kmalloc
> > -      */
> >       ret = sparse_index_init(section_nr, nid);
> >       if (ret < 0 && ret != -EEXIST)
> >               return ret;
> > -     ret = 0;
> > -     memmap = populate_section_memmap(start_pfn, PAGES_PER_SECTION, nid,
> > -                     altmap);
> > -     if (!memmap)
> > -             return -ENOMEM;
> > -     usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
> > -     if (!usage) {
> > -             depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
> > -             return -ENOMEM;
> > -     }
> >
> > -     ms = __pfn_to_section(start_pfn);
> > -     if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
> > -             ret = -EEXIST;
> > -             goto out;
> > -     }
> > +     memmap = section_activate(nid, start_pfn, nr_pages, altmap);
> > +     if (IS_ERR(memmap))
> > +             return PTR_ERR(memmap);
> > +     ret = 0;
> >
> >       /*
> >        * Poison uninitialized struct pages in order to catch invalid flags
> >        * combinations.
> >        */
> > -     page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
> > +     page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages);
> >
> > +     ms = __pfn_to_section(start_pfn);
> >       section_mark_present(ms);
> > -     sparse_init_one_section(ms, section_nr, memmap, usage);
> > +     sparse_init_one_section(ms, section_nr, memmap, ms->usage);
> >
> > -out:
> > -     if (ret < 0) {
> > -             kfree(usage);
> > -             depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
> > -     }
> > +     if (ret < 0)
> > +             section_deactivate(start_pfn, nr_pages, nid, altmap);
> >       return ret;
> >  }
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 34f322d14e62..daeb2d7d8dd0 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -900,13 +900,12 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>         int ret;
>
>         ret = sparse_index_init(section_nr, nid);
> -       if (ret < 0 && ret != -EEXIST)
> +       if (ret < 0)
>                 return ret;
>
>         memmap = section_activate(nid, start_pfn, nr_pages, altmap);
>         if (IS_ERR(memmap))
>                 return PTR_ERR(memmap);
> -       ret = 0;
>
>         /*
>          * Poison uninitialized struct pages in order to catch invalid flags
> @@ -918,8 +917,6 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>         section_mark_present(ms);
>         sparse_init_one_section(ms, section_nr, memmap, ms->usage);
>
> -       if (ret < 0)
> -               section_deactivate(start_pfn, nr_pages, nid, altmap);
>         return ret;
>  }

Done.

