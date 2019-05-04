Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC138C43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:26:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40362205F4
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 19:26:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ZEA36jQG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40362205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA05E6B0003; Sat,  4 May 2019 15:26:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A52456B0006; Sat,  4 May 2019 15:26:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9188B6B0007; Sat,  4 May 2019 15:26:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67DBA6B0003
	for <linux-mm@kvack.org>; Sat,  4 May 2019 15:26:27 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 70so4752176otn.15
        for <linux-mm@kvack.org>; Sat, 04 May 2019 12:26:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=89cKc/1upzZq+P8Ae4aiD1CFSs15MapYdyaJkCMePtw=;
        b=Wk8+8RR+/AnGV0QiWwA+xShgfe2WQaMkXFOXOXv79trvTn6UyHugxBLzTxNgvepvvQ
         kq1rIud0n3umzip5tkjnr+TI5CEwMCmFAA/no7t2mQ4Di9fhcebwen0aSXK7nczOOP1V
         3+hiYAsqT9YAi0qoZ4HtXsrQ8ZJ7O34iblbTAb46GExE2ilutZZKmX9Oq4b5m0JhVdtj
         Ombbm8gx58G8cggtdb2qoRW+fIpL3C22MZH1YP34QgzLqqsAS/lZ1oj0CYo2n5K4ROJ5
         PqCBSAolGdWXti/m4fy3GT6MoklGcC1Xm0vpzNICw633MNtukXGA8VG/paytO7ZEokZl
         GtaQ==
X-Gm-Message-State: APjAAAXZlAs3EmmsXuX1gZr4iY6f4n0hHDz960GVKyqSLzOAC5zACUHf
	iTF7EsTj+FyxMif+p8zXFPJBCp+EABSJLX2fTICjBmcgnb0gEB9Gm9Oz/IuL8jcFcaNoIOq6s/V
	gKCnB/mfpU9vzAOCBgGrQKdUENhyZEc9z7Hv+t76DFZl4FxGPwJCvSqvJBzW2q8ruLg==
X-Received: by 2002:aca:34d6:: with SMTP id b205mr3526961oia.14.1556997986891;
        Sat, 04 May 2019 12:26:26 -0700 (PDT)
X-Received: by 2002:aca:34d6:: with SMTP id b205mr3526924oia.14.1556997985883;
        Sat, 04 May 2019 12:26:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556997985; cv=none;
        d=google.com; s=arc-20160816;
        b=UB9oXRzqT2QBQSJAZ5/0bbcKY5BEEcBgZPpl7wNjeGYtjLXGxTYPr1yDbkPgb+BxIc
         LAtoBdhaxF2621ngcZ5kWskTxYtm/WpCVvUQlRzUzL35mBZR2XBZHeESl5Hctrtqsb25
         apoAEjskYPl9WbwdDxutrqGdMkZ6y8ELWwoF+v95kSa++1dw4YusvULskHPAPg0QNIte
         QajQTo7ATTpn4r+hAe8vkZox/K5Y4Kc+mQU8U1JohH5D1Ubpm4pk8siUWBghdYUiS/l/
         alXPH1ttQnOdC09FflQO9877M6FEb+VVXA0/t+P1mn0V8djzKVlozuQYNGvQfeJ5qtUJ
         ZlBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=89cKc/1upzZq+P8Ae4aiD1CFSs15MapYdyaJkCMePtw=;
        b=zbQ+aTx+9mzBeaRqL4v3RLA1jMtDAGUgqIMmZCWsyqSa1oMfLfZdKRciBR41CtF2MA
         CM/Nwrif/TdgkJLAXt/eRaEAvFr7XJTq23I40mrffGszXkr+Ob8kTDygwepdQcZPwq/c
         4IUsLjZVMG4guK7u5C3elY3cv35H6u5prZFJEm9nhpIt8HuI1jLDVj+54Bqw1ZLbadE7
         ESBqEYOjF7a+F3iynIOg/dgD1z3KtkYBXW7WL8jD5ieFkWakYNF3ewKM3zjFv6cPuWSJ
         7+fE5OxSEWtIb15YPkUxM0bKogbSPFk7TbHgObWqSkymNNaTuMQorv7tSiIvwIxbxTeP
         /7aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZEA36jQG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y79sor2412166oia.95.2019.05.04.12.26.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 May 2019 12:26:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZEA36jQG;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=89cKc/1upzZq+P8Ae4aiD1CFSs15MapYdyaJkCMePtw=;
        b=ZEA36jQGFApzOqLHos1Afgjgxe9rNS/ZjB4sQ/6NAurA/4xrbI73PN/ZOEu5FxwRbL
         XYwwoNLJDorIRZwXpEzYdD3GUHah+R5M0I5c+aZKoCS2GM23+OQwe9Xe3M+JNMCNzU8M
         WZ8l+IuL+PhhWtIEdATHQRv5UYBYYgr+uXAR/kPvYepxWwET7kiie3g8ctsAzf5gf4dq
         PDqlmx+p99HHQZPjh+kVgwkx9bLwgvSkyqGdg9k+UNwSqCpscalkHK5u9y18xyuQbc6J
         7GGPfFHS1FdpVeMwvp2CT+EiuxW276XVhiOZTziUYgg46pcJNCNJ81F1o5nzljG4lxhY
         kvMA==
X-Google-Smtp-Source: APXvYqzgWpwq249atnj9kvwy3BXcHz7i8mu5jxzGWLKmGgXpXfK2Afblv75AdGVNtYoG5P/AWqs7eHQTGU5RPJi9kCk=
X-Received: by 2002:aca:b108:: with SMTP id a8mr3478255oif.0.1556997985071;
 Sat, 04 May 2019 12:26:25 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bAfnCVYz956jPTNQ+AqHJs7uY1ZqWfL8fSUFWQOdKxHcg@mail.gmail.com>
In-Reply-To: <CA+CK2bAfnCVYz956jPTNQ+AqHJs7uY1ZqWfL8fSUFWQOdKxHcg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 4 May 2019 12:26:13 -0700
Message-ID: <CAPcyv4hH2733FEs4bAroa4zscM_PkshEWEmRw7LwXwVJb9pDWg@mail.gmail.com>
Subject: Re: [PATCH v6 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 9:12 AM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>
> On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> > section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> > map_active bitmask length (64)). If it turns out that 2MB is too large
> > of an active tracking granularity it is trivial to increase the size of
> > the map_active bitmap.
>
> Please mention that 2M on Intel, and 16M on Arm64.
>
> >
> > The implications of a partially populated section is that pfn_valid()
> > needs to go beyond a valid_section() check and read the sub-section
> > active ranges from the bitmask.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> >  mm/page_alloc.c        |    4 +++-
> >  mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 79 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 6726fc175b51..cffde898e345 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1175,6 +1175,8 @@ struct mem_section_usage {
> >         unsigned long pageblock_flags[0];
> >  };
> >
> > +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> > +
> >  struct page;
> >  struct page_ext;
> >  struct mem_section {
> > @@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> >
> >  extern int __highest_present_section_nr;
> >
> > +static inline int section_active_index(phys_addr_t phys)
> > +{
> > +       return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
>
> How about also defining SECTION_ACTIVE_SHIFT like this:
>
> /* BITS_PER_LONG = 2^6 */
> #define BITS_PER_LONG_SHIFT 6
> #define SECTION_ACTIVE_SHIFT (SECTION_SIZE_BITS - BITS_PER_LONG_SHIFT)
> #define SECTION_ACTIVE_SIZE (1 << SECTION_ACTIVE_SHIFT)
>
> The return above would become:
> return (phys & ~(PA_SECTION_MASK)) >> SECTION_ACTIVE_SHIFT;
>
> > +}
> > +
> > +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> > +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> > +{
> > +       int idx = section_active_index(PFN_PHYS(pfn));
> > +
> > +       return !!(ms->usage->map_active & (1UL << idx));
> > +}
> > +#else
> > +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> > +{
> > +       return 1;
> > +}
> > +#endif
> > +
> >  #ifndef CONFIG_HAVE_ARCH_PFN_VALID
> >  static inline int pfn_valid(unsigned long pfn)
> >  {
> > +       struct mem_section *ms;
> > +
> >         if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> >                 return 0;
> > -       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> > +       ms = __nr_to_section(pfn_to_section_nr(pfn));
> > +       if (!valid_section(ms))
> > +               return 0;
> > +       return pfn_section_valid(ms, pfn);
> >  }
> >  #endif
> >
> > @@ -1349,6 +1375,7 @@ void sparse_init(void);
> >  #define sparse_init()  do {} while (0)
> >  #define sparse_index_init(_sec, _nid)  do {} while (0)
> >  #define pfn_present pfn_valid
> > +#define section_active_init(_pfn, _nr_pages) do {} while (0)
> >  #endif /* CONFIG_SPARSEMEM */
> >
> >  /*
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f671401a7c0b..c9ad28a78018 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7273,10 +7273,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> >
> >         /* Print out the early node map */
> >         pr_info("Early memory node ranges\n");
> > -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
> > +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> >                 pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> >                         (u64)start_pfn << PAGE_SHIFT,
> >                         ((u64)end_pfn << PAGE_SHIFT) - 1);
> > +               section_active_init(start_pfn, end_pfn - start_pfn);
> > +       }
> >
> >         /* Initialise every node */
> >         mminit_verify_pageflags_layout();
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index f87de7ad32c8..5ef2f884c4e1 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -210,6 +210,54 @@ static inline unsigned long first_present_section_nr(void)
> >         return next_present_section_nr(-1);
> >  }
> >
> > +static unsigned long section_active_mask(unsigned long pfn,
> > +               unsigned long nr_pages)
> > +{
> > +       int idx_start, idx_size;
> > +       phys_addr_t start, size;
> > +
> > +       if (!nr_pages)
> > +               return 0;
> > +
> > +       start = PFN_PHYS(pfn);
> > +       size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> > +                               - (pfn & ~PAGE_SECTION_MASK)));
> > +       size = ALIGN(size, SECTION_ACTIVE_SIZE);
> > +
> > +       idx_start = section_active_index(start);
> > +       idx_size = section_active_index(size);
> > +
> > +       if (idx_size == 0)
> > +               return -1;
> > +       return ((1UL << idx_size) - 1) << idx_start;
> > +}
> > +
> > +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> > +{
> > +       int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> > +       int i, start_sec = pfn_to_section_nr(pfn);
> > +
> > +       if (!nr_pages)
> > +               return;
> > +
> > +       for (i = start_sec; i <= end_sec; i++) {
> > +               struct mem_section *ms;
> > +               unsigned long mask;
> > +               unsigned long pfns;
> > +
> > +               pfns = min(nr_pages, PAGES_PER_SECTION
> > +                               - (pfn & ~PAGE_SECTION_MASK));
> > +               mask = section_active_mask(pfn, pfns);
> > +
> > +               ms = __nr_to_section(i);
> > +               pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, mask);
> > +               ms->usage->map_active = mask;
> > +
> > +               pfn += pfns;
> > +               nr_pages -= pfns;
> > +       }
> > +}
>
> For some reasons the above code is confusing to me. It seems all the
> code supposed to do is set all map_active to -1, and trim the first
> and last sections (can be the same section of course). So, I would
> replace the above two functions with one function like this:
>
> void section_active_init(unsigned long pfn, unsigned long nr_pages)
> {
>         int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
>         int i, idx, start_sec = pfn_to_section_nr(pfn);
>         struct mem_section *ms;
>
>         if (!nr_pages)
>                 return;
>
>         for (i = start_sec; i <= end_sec; i++) {
>                 ms = __nr_to_section(i);
>                 ms->usage->map_active = ~0ul;
>         }
>
>         /* Might need to trim active pfns from the beginning and end */
>         idx = section_active_index(PFN_PHYS(pfn));
>         ms = __nr_to_section(start_sec);
>         ms->usage->map_active &= (~0ul << idx);
>
>         idx = section_active_index(PFN_PHYS(pfn + nr_pages -1));
>         ms = __nr_to_section(end_sec);
>         ms->usage->map_active &= (~0ul >> (BITS_PER_LONG - idx - 1));
> }

I like the cleanup, but one of the fixes in v7 resulted in the
realization that a given section may be populated twice at init time.
For example, enabling that pr_debug() yields:

    section_active_init: sec: 12 mask: 0x00000003ffffffff
    section_active_init: sec: 12 mask: 0xe000000000000000

So, the implementation can't blindly clear bits based on the current
parameters. However, I'm switching this code over to use bitmap_*()
helpers which should help with the readability.

