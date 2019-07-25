Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D38BC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05B7C21871
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:51:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oWNimkmu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05B7C21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D5818E004A; Thu, 25 Jul 2019 03:51:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85F458E0031; Thu, 25 Jul 2019 03:51:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D8B68E004A; Thu, 25 Jul 2019 03:51:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4391A8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:51:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so53965689iol.6
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:51:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=TmgaTiXkuQ0JQAv3RzHXQAmQ/i7QMKlNUf8MnSGnxuo=;
        b=SI8dLpnO0a2ga9/JCoeah0gR0U0Z33n1gn3MGUtR7EDRyCfeCPJfpamY9QN/w6PFOF
         h67wIJl0qlHw1JLqEgsFtG9p4n+6+f/OTnZ8zifQfHPgWqxW3c/kd9rPz+wR7Ypx1pyV
         PGv9XFFQfxP3wUNi1nbNPAsqJiXg93mG+AFEbe6xtsVWoVko1UK32INF912pwPPX0AfO
         U7sGPXM0GngorCz/DL5d5gF1u3+MpwwKlQpTUxtlXuKddcJVa6ExrNsjTE7D0M6WzvqZ
         1HBPJQ2wlQI8LVSO8/NueINzE4BuGJpQIJ3xeZw166CcEMlwRJhTZ/EzQzUkWUPkxR+E
         qMXw==
X-Gm-Message-State: APjAAAUnbjua4HVF0EL0uWga11DnJI/s778IS7K1VlT8HoRgk+l49Mv9
	zfBjpdSA381+67+fXBsvrJLp7LC+6JHvH34ZE5oS3iG17N2lMl1lqU47mpGSAvleQDMPyKu//29
	OCfg22XGFNA4GEkQijbIrUKMdyB4cHekOSmWhNC+J0V2wROId9SL1IF7v0UNQEgL4Hw==
X-Received: by 2002:a02:9a03:: with SMTP id b3mr91721627jal.0.1564041078966;
        Thu, 25 Jul 2019 00:51:18 -0700 (PDT)
X-Received: by 2002:a02:9a03:: with SMTP id b3mr91721567jal.0.1564041077745;
        Thu, 25 Jul 2019 00:51:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564041077; cv=none;
        d=google.com; s=arc-20160816;
        b=T/tzT4aZOW+RIC5fb1ETYadOyRN90e4LC7rGSvPi8R7V++tTKI7zjn+br6hL6ryU5h
         BarUpQuWJKBqR6Me+VOv1172/K0sSMgTXkPMV/izQYODPZ0nER4R/qJFMsDv3lTpH33F
         nBYWB+285SKE8qlhDMaopO7BOCsnnUmJ9rE1pfaUipyxD49fjnVmMVgQkkra36PvBSfX
         TlXAuuyopR8+abUtuO/IhDaaifcdq8aJD7GYV/JPTRIJLwzT3Pn2y6vz0dCDwZsfyq54
         GWZ/UyL9UPJje2E1V7g2VruJzpHKZUpp3dE0o7OBwMCUs/oKwrKGtb74yCsaIcjQQfL6
         agPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=TmgaTiXkuQ0JQAv3RzHXQAmQ/i7QMKlNUf8MnSGnxuo=;
        b=Zi8vqdWd2KZ5dvsa27iZdNuFpsnN4XmefT8y22p6nFv/iyjlj0E1VotgmuS23sopW9
         naGtxlvufiSZfntUZIOUOslKrbIMMYjajlxuyH5bauRgR8SQGSxiWc3vivo6CpKJBD5H
         L0geRSg5/xEea/bi7UJ8F5BsLBs0RGqf0tLorxyYj/8aL4yjLDYAmwQvaYemygvkTfEc
         D8yiOz+Et5sw7tHYTaMSL2KB62pozP7e6lETL1TWIijDMjDRM8LI69UgQKsjIFGefQXZ
         WxB5zsoNCg3k21R9D87JwHHf9rOTONJEOq5/HaSV6e94YkFEC4h1wFhyh0UaOWcVRheK
         VyfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oWNimkmu;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor33774911ioa.6.2019.07.25.00.51.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 00:51:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oWNimkmu;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TmgaTiXkuQ0JQAv3RzHXQAmQ/i7QMKlNUf8MnSGnxuo=;
        b=oWNimkmum4wkSeTqkKOgIn3y7l+j9oFArlapX2QZw6BwBCH+EUmifRXmG9rcCYyqIc
         xC6l6qeyVkqhLmOBiO/X7hN6VqWowRxl2WM+QOxeWASnUwOpAGa62bV8Ck3HDyF4mZlj
         0l1ywsw/hF1hM24b2EhT7FaKwMnN9aHtU9Zbsw0y78HbvKeiNc7FgJbu3ealtXWdiYhK
         +ZZHQX7aGBlG5F7koSQSaLKYQ2KxTnMKRR3lm9GRpZOxizh41//xXhTnp1nedCSLb4EB
         rZBnqlUdjz9FPUUwxPTm2h5V8gvNpMiUmWPttI7gEqfuuX6VgLFiw3LBfV708i9TEzGD
         gS2g==
X-Google-Smtp-Source: APXvYqwNsbGlsx1+9v9+ud84Fk+Hzj0IOY+FVnt2PYq1q1BnuD2mUpMiQGqdvSgVtP3451UfgttFZRnwMCLNunV6yUc=
X-Received: by 2002:a6b:4101:: with SMTP id n1mr54000678ioa.138.1564041076985;
 Thu, 25 Jul 2019 00:51:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
In-Reply-To: <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Jul 2019 09:51:06 +0200
Message-ID: <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, Marco Elver <elver@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 9:35 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> ,On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
> >
> > Hook into vmalloc and vmap, and dynamically allocate real shadow
> > memory to back the mappings.
> >
> > Most mappings in vmalloc space are small, requiring less than a full
> > page of shadow space. Allocating a full shadow page per mapping would
> > therefore be wasteful. Furthermore, to ensure that different mappings
> > use different shadow pages, mappings would have to be aligned to
> > KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> >
> > Instead, share backing space across multiple mappings. Allocate
> > a backing page the first time a mapping in vmalloc space uses a
> > particular page of the shadow region. Keep this page around
> > regardless of whether the mapping is later freed - in the mean time
> > the page could have become shared by another vmalloc mapping.
> >
> > This can in theory lead to unbounded memory growth, but the vmalloc
> > allocator is pretty good at reusing addresses, so the practical memory
> > usage grows at first but then stays fairly stable.
> >
> > This requires architecture support to actually use: arches must stop
> > mapping the read-only zero page over portion of the shadow region that
> > covers the vmalloc space and instead leave it unmapped.
> >
> > This allows KASAN with VMAP_STACK, and will be needed for architectures
> > that do not have a separate module space (e.g. powerpc64, which I am
> > currently working on).
> >
> > Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> > Signed-off-by: Daniel Axtens <dja@axtens.net>
>
> Hi Daniel,
>
> This is awesome! Thanks so much for taking over this!
> I agree with memory/simplicity tradeoffs. Provided that virtual
> addresses are reused, this should be fine (I hope). If we will ever
> need to optimize memory consumption, I would even consider something
> like aligning all vmalloc allocations to PAGE_SIZE*KASAN_SHADOW_SCALE
> to make things simpler.
>
> Some comments below.


Marco, please test this with your stack overflow test and with
syzkaller (to estimate the amount of new OOBs :)). Also are there any
concerns with performance/memory consumption for us?



> > ---
> >  Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++++++
> >  include/linux/kasan.h             | 16 +++++++++
> >  lib/Kconfig.kasan                 | 16 +++++++++
> >  lib/test_kasan.c                  | 26 ++++++++++++++
> >  mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
> >  mm/kasan/generic_report.c         |  3 ++
> >  mm/kasan/kasan.h                  |  1 +
> >  mm/vmalloc.c                      | 15 +++++++-
> >  8 files changed, 187 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
> > index b72d07d70239..35fda484a672 100644
> > --- a/Documentation/dev-tools/kasan.rst
> > +++ b/Documentation/dev-tools/kasan.rst
> > @@ -215,3 +215,63 @@ brk handler is used to print bug reports.
> >  A potential expansion of this mode is a hardware tag-based mode, which would
> >  use hardware memory tagging support instead of compiler instrumentation and
> >  manual shadow memory manipulation.
> > +
> > +What memory accesses are sanitised by KASAN?
> > +--------------------------------------------
> > +
> > +The kernel maps memory in a number of different parts of the address
> > +space. This poses something of a problem for KASAN, which requires
> > +that all addresses accessed by instrumented code have a valid shadow
> > +region.
> > +
> > +The range of kernel virtual addresses is large: there is not enough
> > +real memory to support a real shadow region for every address that
> > +could be accessed by the kernel.
> > +
> > +By default
> > +~~~~~~~~~~
> > +
> > +By default, architectures only map real memory over the shadow region
> > +for the linear mapping (and potentially other small areas). For all
> > +other areas - such as vmalloc and vmemmap space - a single read-only
> > +page is mapped over the shadow area. This read-only shadow page
> > +declares all memory accesses as permitted.
> > +
> > +This presents a problem for modules: they do not live in the linear
> > +mapping, but in a dedicated module space. By hooking in to the module
> > +allocator, KASAN can temporarily map real shadow memory to cover
> > +them. This allows detection of invalid accesses to module globals, for
> > +example.
> > +
> > +This also creates an incompatibility with ``VMAP_STACK``: if the stack
> > +lives in vmalloc space, it will be shadowed by the read-only page, and
> > +the kernel will fault when trying to set up the shadow data for stack
> > +variables.
> > +
> > +CONFIG_KASAN_VMALLOC
> > +~~~~~~~~~~~~~~~~~~~~
> > +
> > +With ``CONFIG_KASAN_VMALLOC``, KASAN can cover vmalloc space at the
> > +cost of greater memory usage. Currently this is only supported on x86.
> > +
> > +This works by hooking into vmalloc and vmap, and dynamically
> > +allocating real shadow memory to back the mappings.
> > +
> > +Most mappings in vmalloc space are small, requiring less than a full
> > +page of shadow space. Allocating a full shadow page per mapping would
> > +therefore be wasteful. Furthermore, to ensure that different mappings
> > +use different shadow pages, mappings would have to be aligned to
> > +``KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE``.
> > +
> > +Instead, we share backing space across multiple mappings. We allocate
> > +a backing page the first time a mapping in vmalloc space uses a
> > +particular page of the shadow region. We keep this page around
> > +regardless of whether the mapping is later freed - in the mean time
> > +this page could have become shared by another vmalloc mapping.
> > +
> > +This can in theory lead to unbounded memory growth, but the vmalloc
> > +allocator is pretty good at reusing addresses, so the practical memory
> > +usage grows at first but then stays fairly stable.
> > +
> > +This allows ``VMAP_STACK`` support on x86, and enables support of
> > +architectures that do not have a fixed module region.
> > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > index cc8a03cc9674..fcabc5a03fca 100644
> > --- a/include/linux/kasan.h
> > +++ b/include/linux/kasan.h
> > @@ -70,8 +70,18 @@ struct kasan_cache {
> >         int free_meta_offset;
> >  };
> >
> > +/*
> > + * These functions provide a special case to support backing module
> > + * allocations with real shadow memory. With KASAN vmalloc, the special
> > + * case is unnecessary, as the work is handled in the generic case.
> > + */
> > +#ifndef CONFIG_KASAN_VMALLOC
> >  int kasan_module_alloc(void *addr, size_t size);
> >  void kasan_free_shadow(const struct vm_struct *vm);
> > +#else
> > +static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
> > +static inline void kasan_free_shadow(const struct vm_struct *vm) {}
> > +#endif
> >
> >  int kasan_add_zero_shadow(void *start, unsigned long size);
> >  void kasan_remove_zero_shadow(void *start, unsigned long size);
> > @@ -194,4 +204,10 @@ static inline void *kasan_reset_tag(const void *addr)
> >
> >  #endif /* CONFIG_KASAN_SW_TAGS */
> >
> > +#ifdef CONFIG_KASAN_VMALLOC
> > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area);
> > +#else
> > +static inline void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area) {}
> > +#endif
> > +
> >  #endif /* LINUX_KASAN_H */
> > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > index 4fafba1a923b..a320dc2e9317 100644
> > --- a/lib/Kconfig.kasan
> > +++ b/lib/Kconfig.kasan
> > @@ -6,6 +6,9 @@ config HAVE_ARCH_KASAN
> >  config HAVE_ARCH_KASAN_SW_TAGS
> >         bool
> >
> > +config HAVE_ARCH_KASAN_VMALLOC
> > +       bool
> > +
> >  config CC_HAS_KASAN_GENERIC
> >         def_bool $(cc-option, -fsanitize=kernel-address)
> >
> > @@ -135,6 +138,19 @@ config KASAN_S390_4_LEVEL_PAGING
> >           to 3TB of RAM with KASan enabled). This options allows to force
> >           4-level paging instead.
> >
> > +config KASAN_VMALLOC
> > +       bool "Back mappings in vmalloc space with real shadow memory"
> > +       depends on KASAN && HAVE_ARCH_KASAN_VMALLOC
> > +       help
> > +         By default, the shadow region for vmalloc space is the read-only
> > +         zero page. This means that KASAN cannot detect errors involving
> > +         vmalloc space.
> > +
> > +         Enabling this option will hook in to vmap/vmalloc and back those
> > +         mappings with real shadow memory allocated on demand. This allows
> > +         for KASAN to detect more sorts of errors (and to support vmapped
> > +         stacks), but at the cost of higher memory usage.
> > +
> >  config TEST_KASAN
> >         tristate "Module for testing KASAN for bug detection"
> >         depends on m && KASAN
> > diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> > index b63b367a94e8..d375246f5f96 100644
> > --- a/lib/test_kasan.c
> > +++ b/lib/test_kasan.c
> > @@ -18,6 +18,7 @@
> >  #include <linux/slab.h>
> >  #include <linux/string.h>
> >  #include <linux/uaccess.h>
> > +#include <linux/vmalloc.h>
> >
> >  /*
> >   * Note: test functions are marked noinline so that their names appear in
> > @@ -709,6 +710,30 @@ static noinline void __init kmalloc_double_kzfree(void)
> >         kzfree(ptr);
> >  }
> >
> > +#ifdef CONFIG_KASAN_VMALLOC
> > +static noinline void __init vmalloc_oob(void)
> > +{
> > +       void *area;
> > +
> > +       pr_info("vmalloc out-of-bounds\n");
> > +
> > +       /*
> > +        * We have to be careful not to hit the guard page.
> > +        * The MMU will catch that and crash us.
> > +        */
> > +       area = vmalloc(3000);
> > +       if (!area) {
> > +               pr_err("Allocation failed\n");
> > +               return;
> > +       }
> > +
> > +       ((volatile char *)area)[3100];
> > +       vfree(area);
> > +}
> > +#else
> > +static void __init vmalloc_oob(void) {}
> > +#endif
> > +
> >  static int __init kmalloc_tests_init(void)
> >  {
> >         /*
> > @@ -752,6 +777,7 @@ static int __init kmalloc_tests_init(void)
> >         kasan_strings();
> >         kasan_bitops();
> >         kmalloc_double_kzfree();
> > +       vmalloc_oob();
> >
> >         kasan_restore_multi_shot(multishot);
> >
> > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > index 2277b82902d8..a3bb84efccbf 100644
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -568,6 +568,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
> >         /* The object will be poisoned by page_alloc. */
> >  }
> >
> > +#ifndef CONFIG_KASAN_VMALLOC
> >  int kasan_module_alloc(void *addr, size_t size)
> >  {
> >         void *ret;
> > @@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
> >         if (vm->flags & VM_KASAN)
> >                 vfree(kasan_mem_to_shadow(vm->addr));
> >  }
> > +#endif
> >
> >  extern void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned long ip);
> >
> > @@ -722,3 +724,52 @@ static int __init kasan_memhotplug_init(void)
> >
> >  core_initcall(kasan_memhotplug_init);
> >  #endif
> > +
> > +#ifdef CONFIG_KASAN_VMALLOC
> > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)
> > +{
> > +       unsigned long shadow_alloc_start, shadow_alloc_end;
> > +       unsigned long addr;
> > +       unsigned long backing;
> > +       pgd_t *pgdp;
> > +       p4d_t *p4dp;
> > +       pud_t *pudp;
> > +       pmd_t *pmdp;
> > +       pte_t *ptep;
> > +       pte_t backing_pte;
> > +
> > +       shadow_alloc_start = ALIGN_DOWN(
> > +               (unsigned long)kasan_mem_to_shadow(area->addr),
> > +               PAGE_SIZE);
> > +       shadow_alloc_end = ALIGN(
> > +               (unsigned long)kasan_mem_to_shadow(area->addr + area->size),
> > +               PAGE_SIZE);
> > +
> > +       addr = shadow_alloc_start;
> > +       do {
> > +               pgdp = pgd_offset_k(addr);
> > +               p4dp = p4d_alloc(&init_mm, pgdp, addr);
>
> Page table allocations will be protected by mm->page_table_lock, right?
>
>
> > +               pudp = pud_alloc(&init_mm, p4dp, addr);
> > +               pmdp = pmd_alloc(&init_mm, pudp, addr);
> > +               ptep = pte_alloc_kernel(pmdp, addr);
> > +
> > +               /*
> > +                * we can validly get here if pte is not none: it means we
> > +                * allocated this page earlier to use part of it for another
> > +                * allocation
> > +                */
> > +               if (pte_none(*ptep)) {
> > +                       backing = __get_free_page(GFP_KERNEL);
> > +                       backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
> > +                                             PAGE_KERNEL);
> > +                       set_pte_at(&init_mm, addr, ptep, backing_pte);
> > +               }
> > +       } while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> > +
> > +       requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> > +       kasan_unpoison_shadow(area->addr, requested_size);
> > +       kasan_poison_shadow(area->addr + requested_size,
> > +                           area->size - requested_size,
> > +                           KASAN_VMALLOC_INVALID);
>
>
> Do I read this correctly that if kernel code does vmalloc(64), they
> will have exactly 64 bytes available rather than full page? To make
> sure: vmalloc does not guarantee that the available size is rounded up
> to page size? I suspect we will see a throw out of new bugs related to
> OOBs on vmalloc memory. So I want to make sure that these will be
> indeed bugs that we agree need to be fixed.
> I am sure there will be bugs where the size is controlled by
> user-space, so these are bad bugs under any circumstances. But there
> will also probably be OOBs, where people will try to "prove" that
> that's fine and will work (just based on our previous experiences :)).
>
> On impl side: kasan_unpoison_shadow seems to be capable of handling
> non-KASAN_SHADOW_SCALE_SIZE-aligned sizes exactly in the way we want.
> So I think it's better to do:
>
>        kasan_unpoison_shadow(area->addr, requested_size);
>        requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
>        kasan_poison_shadow(area->addr + requested_size,
>                            area->size - requested_size,
>                            KASAN_VMALLOC_INVALID);
>
>
>
> > +}
> > +#endif
> > diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
> > index 36c645939bc9..2d97efd4954f 100644
> > --- a/mm/kasan/generic_report.c
> > +++ b/mm/kasan/generic_report.c
> > @@ -86,6 +86,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
> >         case KASAN_ALLOCA_RIGHT:
> >                 bug_type = "alloca-out-of-bounds";
> >                 break;
> > +       case KASAN_VMALLOC_INVALID:
> > +               bug_type = "vmalloc-out-of-bounds";
> > +               break;
> >         }
> >
> >         return bug_type;
> > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> > index 014f19e76247..8b1f2fbc780b 100644
> > --- a/mm/kasan/kasan.h
> > +++ b/mm/kasan/kasan.h
> > @@ -25,6 +25,7 @@
> >  #endif
> >
> >  #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
> > +#define KASAN_VMALLOC_INVALID   0xF9  /* unallocated space in vmapped page */
> >
> >  /*
> >   * Stack redzone shadow values
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 4fa8d84599b0..8cbcb5056c9b 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2012,6 +2012,15 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
> >         va->vm = vm;
> >         va->flags |= VM_VM_AREA;
> >         spin_unlock(&vmap_area_lock);
> > +
> > +       /*
> > +        * If we are in vmalloc space we need to cover the shadow area with
> > +        * real memory. If we come here through VM_ALLOC, this is done
> > +        * by a higher level function that has access to the true size,
> > +        * which might not be a full page.
> > +        */
> > +       if (is_vmalloc_addr(vm->addr) && !(vm->flags & VM_ALLOC))
> > +               kasan_cover_vmalloc(vm->size, vm);
> >  }
> >
> >  static void clear_vm_uninitialized_flag(struct vm_struct *vm)
> > @@ -2483,6 +2492,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> >         if (!addr)
> >                 return NULL;
> >
> > +       kasan_cover_vmalloc(real_size, area);
> > +
> >         /*
> >          * In this function, newly allocated vm_struct has VM_UNINITIALIZED
> >          * flag. It means that vm_struct is not fully initialized.
> > @@ -3324,9 +3335,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
> >         spin_unlock(&vmap_area_lock);
> >
> >         /* insert all vm's */
> > -       for (area = 0; area < nr_vms; area++)
> > +       for (area = 0; area < nr_vms; area++) {
> >                 setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
> >                                  pcpu_get_vm_areas);
> > +               kasan_cover_vmalloc(sizes[area], vms[area]);
> > +       }
> >
> >         kfree(vas);
> >         return vms;
> > --
> > 2.20.1
> >
> > --
> > You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> > To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> > To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190725055503.19507-2-dja%40axtens.net.

