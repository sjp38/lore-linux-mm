Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AEFCC28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:16:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 008A520868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:16:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Gz7G1JiJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 008A520868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 596166B0275; Thu,  6 Jun 2019 14:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D1C6B027C; Thu,  6 Jun 2019 14:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C106B027D; Thu,  6 Jun 2019 14:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D51D6B0275
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:16:45 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id h12so1406811otn.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:16:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IFTusPVhpfiYDlM0cF7USTGMzoOymuyGD1PoRmf3vY4=;
        b=nnMsoGdh2Wyrh8sTQmcWtwfYFlaPzDQAppw1u66Rq3WdYxZlNPoe4PekWg77q5VcjE
         Hvo5WzjqMOzr4wFVa3Vd+zWag9HYufuJJ9EX6OY4YA8w5RR7ug/kVW9DJU7LRBt8MKPm
         baXwJw+e7BoH0dfwti+RVGRGPmfA+V4dw7MUBkSam7NJ3JR5rJ+UpIu1ZwqM9rJiIR2E
         8aktAu2Xc3QhNPW4fz50OZwD6TKNREmfBFNrsuuL138jbDi2H6ftf1VJn3UnUNidYYkT
         AomprSFoGmmQO6qXlSB/A+XAZuvTP7jLFxjNm7lIbsk5AYJkBLyOyWDwlp/jtbWvJJTh
         0igA==
X-Gm-Message-State: APjAAAWud14bjcm6/pt7HvY+SvcG0B+9W1LAbCCUeTOUF3iD40VtA7NW
	3F+Rfty3mFKd9KiFGrEodDUN+fJ1ZNvlhw4THLRko5p3a2PIi+KJFLNdrro5ko0ytsipsNMLi0j
	7ZMsTIEFVWtMJEiInvRWpUSEVuZZOoB1gRyjBF2ctdf5XI1yxOXjhDJt7sBwWPLfiTQ==
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr13674427otp.177.1559845004684;
        Thu, 06 Jun 2019 11:16:44 -0700 (PDT)
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr13674364otp.177.1559845003662;
        Thu, 06 Jun 2019 11:16:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559845003; cv=none;
        d=google.com; s=arc-20160816;
        b=mj2LNWXe57TIpC3nHMu36ILeHQZyOOBhc/mVk+ITGlU/HmEJuO8fI/WVa0zMPGkKNX
         hsd50NywUQItO01CgNxQUJ8SO2X97IanPg1xWIG1LL2yhXX6o3UWBbkG/eS65CKsIrSY
         yj4Q0mBrJw5qEcRSuwW2E1VNUygJIqET2odj4uEoMpp7E/rUgWdtSYLfO69oPxxmhNwS
         oPPQl+rGcZJ4HQYyuvmbhiyNAdoLaMWKoFgUKNgDLY33r8Qg0jfvFupF0rHq5fk8rZw8
         6Tn2NcUWORVE2zBtfdHnIIBTXwevP7zCthgqzfkWhni216lvUhjaKgQDa5v530jWx8OT
         3pfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IFTusPVhpfiYDlM0cF7USTGMzoOymuyGD1PoRmf3vY4=;
        b=k/Vq2tGWwQflPBrHgVWlrE14lEzIOfJsDcDrbT9ssfnJSnu4ktBM3cRhQc0XsMoDkt
         Uvdfm/35fzCXucgQafIWutV2qtuZJgkKicjVkIR3AMQNBsQvyC+G3cDs+qZ3zBtSfSf2
         cx4C8UpaMhCpVXLbFVlFYEukCpq+5+kz4KgoWEQ2l29dhlTzQDJf539VmQeNdjnLY2eI
         OmQjDLt5gsYnp1Vy3ft4QYfwI96hKaz3nz+HxAq+CaZ2G6FhJIDKOpLMANTEQAmrPKdQ
         ZMNeAjegnO1hKp/nkfIJBYswTCD26tsAbhLoyphpqvBTim6ZkT1pltykoertk6K4OILs
         vF+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Gz7G1JiJ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor1236606otm.188.2019.06.06.11.16.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:16:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Gz7G1JiJ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IFTusPVhpfiYDlM0cF7USTGMzoOymuyGD1PoRmf3vY4=;
        b=Gz7G1JiJnLX/6xII/oyzd8Mk94n6nVLGrgbdbhDqr4Dis4ST4qcabAQL+i/iKj5gyq
         ErzL+a3p6d1VkNlfwAuwWnGsTu2M/ET/by+e8dWL05Gt4vg3jMlOAufnxyapEzib6TlN
         hLONYh8TIEvqZ+KQGcAQXHcbapftgGvXItMjTZMux1pD5Ov1cFWfZ63uGBq4Tyd4+ZmC
         HQPYUSTgJUBHOcDcyazfWZv0D5dVEFX5zu5JI8Z1d4Ho3rsHvETHnmo5LcaG4TYaaIkq
         xFz16zm3QydA/VBCMGuYmQZkMstuNeFMgfwP+tPC8uUdiMD+iSJdw1LZm/ClHFq0HxDe
         fNgg==
X-Google-Smtp-Source: APXvYqzq12PqN/4fGA6npNZeNZT1mnGgPW8x4nWGby/gAe0sYyFomK8fvZ89O7QQ/4vBEBBt6v4K/FhuFrg/EXjx2EA=
X-Received: by 2002:a9d:6e96:: with SMTP id a22mr15628006otr.207.1559845003058;
 Thu, 06 Jun 2019 11:16:43 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977191770.2443951.1506588644989416699.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190606172110.GC31194@linux>
In-Reply-To: <20190606172110.GC31194@linux>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 6 Jun 2019 11:16:31 -0700
Message-ID: <CAPcyv4jy-TN9xzWd_tJW0ezbZoXJCQozWwcQcTfJwzTcy2BGMQ@mail.gmail.com>
Subject: Re: [PATCH v9 07/12] mm/sparsemem: Prepare for sub-section ranges
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 10:21 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Wed, Jun 05, 2019 at 02:58:37PM -0700, Dan Williams wrote:
> > Prepare the memory hot-{add,remove} paths for handling sub-section
> > ranges by plumbing the starting page frame and number of pages being
> > handled through arch_{add,remove}_memory() to
> > sparse_{add,remove}_one_section().
> >
> > This is simply plumbing, small cleanups, and some identifier renames. No
> > intended functional changes.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/memory_hotplug.h |    5 +-
> >  mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
> >  mm/sparse.c                    |   15 ++---
> >  3 files changed, 81 insertions(+), 53 deletions(-)
> >
> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 79e0add6a597..3ab0282b4fe5 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -348,9 +348,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
> >  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
> >               unsigned long nr_pages, struct vmem_altmap *altmap);
> >  extern bool is_memblock_offlined(struct memory_block *mem);
> > -extern int sparse_add_one_section(int nid, unsigned long start_pfn,
> > -                               struct vmem_altmap *altmap);
> > +extern int sparse_add_section(int nid, unsigned long pfn,
> > +             unsigned long nr_pages, struct vmem_altmap *altmap);
> >  extern void sparse_remove_one_section(struct mem_section *ms,
> > +             unsigned long pfn, unsigned long nr_pages,
> >               unsigned long map_offset, struct vmem_altmap *altmap);
> >  extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
> >                                         unsigned long pnum);
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 4b882c57781a..399bf78bccc5 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -252,51 +252,84 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
> >  }
> >  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
> >
> > -static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> > -                                struct vmem_altmap *altmap)
> > +static int __meminit __add_section(int nid, unsigned long pfn,
> > +             unsigned long nr_pages, struct vmem_altmap *altmap)
> >  {
> >       int ret;
> >
> > -     if (pfn_valid(phys_start_pfn))
> > +     if (pfn_valid(pfn))
> >               return -EEXIST;
> >
> > -     ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> > +     ret = sparse_add_section(nid, pfn, nr_pages, altmap);
> >       return ret < 0 ? ret : 0;
> >  }
> >
> > +static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
> > +             const char *reason)
> > +{
> > +     /*
> > +      * Disallow all operations smaller than a sub-section and only
> > +      * allow operations smaller than a section for
> > +      * SPARSEMEM_VMEMMAP. Note that check_hotplug_memory_range()
> > +      * enforces a larger memory_block_size_bytes() granularity for
> > +      * memory that will be marked online, so this check should only
> > +      * fire for direct arch_{add,remove}_memory() users outside of
> > +      * add_memory_resource().
> > +      */
> > +     unsigned long min_align;
> > +
> > +     if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
> > +             min_align = PAGES_PER_SUBSECTION;
> > +     else
> > +             min_align = PAGES_PER_SECTION;
> > +     if (!IS_ALIGNED(pfn, min_align)
> > +                     || !IS_ALIGNED(nr_pages, min_align)) {
> > +             WARN(1, "Misaligned __%s_pages start: %#lx end: #%lx\n",
> > +                             reason, pfn, pfn + nr_pages - 1);
> > +             return -EINVAL;
> > +     }
> > +     return 0;
> > +}
>
>
> This caught my eye.
> Back in patch#4 "Convert kmalloc_section_memmap() to populate_section_memmap()",
> you placed a mis-usage check for !CONFIG_SPARSEMEM_VMEMMAP in
> populate_section_memmap().
>
> populate_section_memmap() gets called from sparse_add_one_section(), which means
> that we should have passed this check, otherwise we cannot go further and call
> __add_section().
>
> So, unless I am missing something it seems to me that the check from patch#4 could go?
> And I think the same applies to depopulate_section_memmap()?

Yes, good catch, I can kill those extra checks in favor of this one.

> Besides that, it looks good to me:

Thanks Oscar!

>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>
> --
> Oscar Salvador
> SUSE L3

