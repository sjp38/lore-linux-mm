Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B80FC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2ECF217D7
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:38:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Zt8jGCiU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2ECF217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51E7E6B0006; Fri, 10 May 2019 15:38:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CE276B0008; Fri, 10 May 2019 15:38:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36F046B000A; Fri, 10 May 2019 15:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09D596B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:38:57 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id a29so2742995oiy.18
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:38:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3zZWqRpm0G05NjcSiIIAbzIcEiDmVjoOHWcOK0h9db0=;
        b=gc0TAVN7pZHNNzowknuMwkuDWncZyhC+3/5uDXbZs9lye1zTqRHzWalq+m92Va4YvL
         sOAFoT7lakBw1b8ZVKmNx+sf9dDCRgCBq2IBXQajV6HTz27fWSgzFJ4aDVwvHtS9dkw6
         xXVMcHK7qoQZNmTfU5ilYdypsZ+z6BiDFvoRShE0e1jJ/YOr/WRx4YMAUHWF0nfDKk1V
         EulQEQqPPcCw9kZrbM52D+ZPCDBfLk8TlX6yJciRdxJ5bIN/AKegYWKjg8HRDqM8ueND
         S09Dcjv9xIec9YMDVPdM+10ye43D5n472xQNNFXvvlYkuxL0tQ3+80MqMkE8iX7UAMlk
         UxTQ==
X-Gm-Message-State: APjAAAWiBe/bAnJDOkRoxD16+edM5JCOHK96VrDtPuSuIvFDB/2gKjqp
	RyQoEPbsx9/5PFQoHlB3sFOhZo3a4rI8T/K51ADTvo9YxUmNjtEQxFUSF9vPs/sWygLOHvjjcUW
	QkAWC8hpVPivqFnuvREVYdkOth4znIzmAuRaoaa03+Gyp14K8MDHmBtJ8TceAY/GAVQ==
X-Received: by 2002:a05:6830:2056:: with SMTP id f22mr8374864otp.323.1557517136639;
        Fri, 10 May 2019 12:38:56 -0700 (PDT)
X-Received: by 2002:a05:6830:2056:: with SMTP id f22mr8374828otp.323.1557517135935;
        Fri, 10 May 2019 12:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557517135; cv=none;
        d=google.com; s=arc-20160816;
        b=a/6JxO5m6mtZTJu1DR9u99ghzPMqinTLa0eaD1fFOcvg9Kx41FVsky3INfmnbT3Pvv
         CaAw4rC2IZWLSmxwlz9P5O7DuJEgMQ2M6I6EuhmElECYQ+ZAmig9mgW+vDjfwK+J3sxK
         NK91HZJugKmU8uHgSf7rQMAEYO6A+9s+uaablfC6BAjXUzwThDhkln9YBb69XxzB8doL
         iIuU+BQUaXHAiRQCB/RPcvIimPz7PyOXksvxhYaLg1ArZ9agHLYgWoj3CCeSdQTBlzKZ
         dfY3AEOLwaMce9FCbfTvlezQOE4p5yfVQxKgdM17qdhV51DGKGu6NTuG3G7Sg074IIv3
         OnxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3zZWqRpm0G05NjcSiIIAbzIcEiDmVjoOHWcOK0h9db0=;
        b=tPXExRv76BgJx0iWxtyZ5oSU7e1ZO0bDrUK23skmjZsBuBnVSlCW2lOazrYwQonfJt
         GCwERhKnQ5sk8BQPwZ6jZDWWb5jHnNGMN2VYNIN/hY1W1/WGGpxonLPV7kfsOEL8KMwo
         HzXUa/u5F077iBpN2VLltwtwxeSsE9qKbQXOwsX4dA6rTcElaAznys5lQxYMhrNGGIYM
         m5c1jnBwc3BHDmB4N50z5YsZkcfPoBkqZMieYsVaKWGv/kLtEiJvq6fOZJQFNKrrxQWV
         5EC0oy9Ws3NZCyK3cFMpQ4+EozPwr6HVuPrNpMgG9pknHKGQzbR+H8bkz/006vOFFKjE
         3FKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Zt8jGCiU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p124sor2926369oia.101.2019.05.10.12.38.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 12:38:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Zt8jGCiU;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3zZWqRpm0G05NjcSiIIAbzIcEiDmVjoOHWcOK0h9db0=;
        b=Zt8jGCiU6tsVp+EvLvEH/lbyUyD0S8Rz6P6AcA7tfrddxC67ogCCxcpPcWKqgoNncU
         u26bqCA1xFFK3nyrZN3NSXUnii3hhRz1OnCgLU3OXi6fDoMD5goKG2VunEj/pVe4FDNR
         QWnGG1KfiHfJLEKn0I9/4BJxx+uOFgBoX9aBBimHHlyeYvWdcOJyEhcMttB9M8QYkZLH
         MS3cw9AXYX4vA5p5vI7ijwbkyNNbhf0SFF8kFb3hQfgh5pyEgogzeKxd+k4VgtyD3l1c
         7WAqnGYDb0k77o8owtjnxY+4cVmWwK1z8YK89qYEpPpQWF45MSURi+S4GYD5g23Yj2rm
         ZtsA==
X-Google-Smtp-Source: APXvYqyXAc2U9OVVTkJlhijyyyFcw3I1yzqRpW/J5S9roDJzRnWHqxvYbqh6OC5OXma3KlWvNDW/uVv/L6RXEOBtXtU=
X-Received: by 2002:aca:de57:: with SMTP id v84mr6606243oig.149.1557517135140;
 Fri, 10 May 2019 12:38:55 -0700 (PDT)
MIME-Version: 1.0
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155718597192.130019.7128788290111464258.stgit@dwillia2-desk3.amr.corp.intel.com>
 <dd7b53bd986d79a94ac0b08e32336e44@suse.de>
In-Reply-To: <dd7b53bd986d79a94ac0b08e32336e44@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 10 May 2019 12:38:43 -0700
Message-ID: <CAPcyv4i1zQb-D-8iB3hr8ipMHH2yV8ssxh+Zeh2aeMw0ZJASfg@mail.gmail.com>
Subject: Re: [PATCH v8 01/12] mm/sparsemem: Introduce struct mem_section_usage
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, owner-linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 6:30 AM <osalvador@suse.de> wrote:
>
> On 2019-05-07 01:39, Dan Williams wrote:
> > Towards enabling memory hotplug to track partial population of a
> > section, introduce 'struct mem_section_usage'.
> >
> > A pointer to a 'struct mem_section_usage' instance replaces the
> > existing
> > pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> > 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> > house a new 'subsection_map' bitmap.  The new bitmap enables the memory
> > hot{plug,remove} implementation to act on incremental sub-divisions of
> > a
> > section.
> >
> > The default SUBSECTION_SHIFT is chosen to keep the 'subsection_map' no
> > larger than a single 'unsigned long' on the major architectures.
> > Alternatively an architecture can define ARCH_SUBSECTION_SHIFT to
> > override the default PMD_SHIFT. Note that PowerPC needs to use
> > ARCH_SUBSECTION_SHIFT to workaround PMD_SHIFT being a non-constant
> > expression on PowerPC.
> >
> > The primary motivation for this functionality is to support platforms
> > that mix "System RAM" and "Persistent Memory" within a single section,
> > or multiple PMEM ranges with different mapping lifetimes within a
> > single
> > section. The section restriction for hotplug has caused an ongoing saga
> > of hacks and bugs for devm_memremap_pages() users.
> >
> > Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> > from a section, and updates to usemap allocation path, there are no
> > expected behavior changes.
> >
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Cc: Oscar Salvador <osalvador@suse.de>
> > Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Cc: Michael Ellerman <mpe@ellerman.id.au>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  arch/powerpc/include/asm/sparsemem.h |    3 +
> >  include/linux/mmzone.h               |   48 +++++++++++++++++++-
> >  mm/memory_hotplug.c                  |   18 ++++----
> >  mm/page_alloc.c                      |    2 -
> >  mm/sparse.c                          |   81
> > +++++++++++++++++-----------------
> >  5 files changed, 99 insertions(+), 53 deletions(-)
> >
> > diff --git a/arch/powerpc/include/asm/sparsemem.h
> > b/arch/powerpc/include/asm/sparsemem.h
> > index 3192d454a733..1aa3c9303bf8 100644
> > --- a/arch/powerpc/include/asm/sparsemem.h
> > +++ b/arch/powerpc/include/asm/sparsemem.h
> > @@ -10,6 +10,9 @@
> >   */
> >  #define SECTION_SIZE_BITS       24
> >
> > +/* Reflect the largest possible PMD-size as the subsection-size
> > constant */
> > +#define ARCH_SUBSECTION_SHIFT 24
> > +
>
> I guess this is done because PMD_SHIFT is defined at runtime rather at
> compile time,
> right?

Correct, PowerPC has:

    #define PMD_SHIFT (PAGE_SHIFT + PTE_INDEX_SIZE)
    #define PTE_INDEX_SIZE  __pte_index_size

...where __pte_index_size is variable established at kernel init time.

> >  #endif /* CONFIG_SPARSEMEM */
> >
> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 70394cabaf4e..ef8d878079f9 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -1160,6 +1160,44 @@ static inline unsigned long
> > section_nr_to_pfn(unsigned long sec)
> >  #define SECTION_ALIGN_UP(pfn)        (((pfn) + PAGES_PER_SECTION - 1) &
> > PAGE_SECTION_MASK)
> >  #define SECTION_ALIGN_DOWN(pfn)      ((pfn) & PAGE_SECTION_MASK)
> >
> > +/*
> > + * SUBSECTION_SHIFT must be constant since it is used to declare
> > + * subsection_map and related bitmaps without triggering the
> > generation
> > + * of variable-length arrays. The most natural size for a subsection
> > is
> > + * a PMD-page. For architectures that do not have a constant PMD-size
> > + * ARCH_SUBSECTION_SHIFT can be set to a constant max size, or
> > otherwise
> > + * fallback to 2MB.
> > + */
> > +#if defined(ARCH_SUBSECTION_SHIFT)
> > +#define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> > +#elif defined(PMD_SHIFT)
> > +#define SUBSECTION_SHIFT (PMD_SHIFT)
> > +#else
> > +/*
> > + * Memory hotplug enabled platforms avoid this default because they
> > + * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant,
> > but
> > + * this is kept as a backstop to allow compilation on
> > + * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
> > + */
> > +#define SUBSECTION_SHIFT 21
> > +#endif
> > +
> > +#define PFN_SUBSECTION_SHIFT (SUBSECTION_SHIFT - PAGE_SHIFT)
> > +#define PAGES_PER_SUBSECTION (1UL << PFN_SUBSECTION_SHIFT)
> > +#define PAGE_SUBSECTION_MASK ((~(PAGES_PER_SUBSECTION-1)))
> > +
> > +#if SUBSECTION_SHIFT > SECTION_SIZE_BITS
> > +#error Subsection size exceeds section size
> > +#else
> > +#define SUBSECTIONS_PER_SECTION (1UL << (SECTION_SIZE_BITS -
> > SUBSECTION_SHIFT))
> > +#endif
>
> On powerpc, SUBSECTIONS_PER_SECTION will equal 1 (so one big section),
> is that to be expected?

Yes, it turns out that PowerPC has no real need for subsection support
since they were already using small 16MB sections from day one.

> Will subsection_map_init handle this right?

Yes, should work as subsection_map_index() will always return 0. Which
means that 'end' will always be 0:

    pfns = min(nr_pages, PAGES_PER_SECTION
        - (pfn & ~PAGE_SECTION_MASK));
    end = subsection_map_index(pfn + pfns - 1);

...and then the bitmap manipulation:

    bitmap_set(ms->usage->subsection_map, idx, end - idx + 1);

...will only ever set bit0.

