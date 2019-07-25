Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F09CCC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:07:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2982E206B8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YfNIyO7E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2982E206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27CBC8E0060; Thu, 25 Jul 2019 06:07:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E2988E0059; Thu, 25 Jul 2019 06:07:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009138E0060; Thu, 25 Jul 2019 06:07:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB8B8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:07:01 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id e11so19376510oiy.0
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:07:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rySXd55FKKmTilhBlm7bWbZ5GsZKu1M1RIHXVXtq9ws=;
        b=hp9bhpxAwvfUONO3ebR0DjGwg5YUP2nDxzLQNqUipyiP9guqpiZgypScw4nnr7eJu/
         N8oGJxPLHAzct5dxSvXSRgqyR5CBaEoQcNOiMTwq8kOSqTwqYQ+VikQBTRIwtlur1urA
         WAxmdWZC8aXWIdLl58BvUkUlxhVtgvuX54Y3XliTmx7QF04248PqnTQrnbPR9ZTTmZt+
         PxZ8/KqHxgSdkjiYX8qFqPCITz9nssqEYTBXWcLbBdbcpBLnpvNt0IJyxQJ9GTqF9fIw
         rDXX/VS4Ouos6zTLVrtr2E17JumXqDNN8xdWffDM3mPWOoOoUtGlxNSOtl0Yl5cv8FNB
         PkxQ==
X-Gm-Message-State: APjAAAVEpST4HJ/z4sqIY6WNgU5ta1aKzXpWw+kDnoYKRCF55ebJrZ1z
	PRASy8gArI3SJqaGGHF29god9mo9wnOqvwAqq/kIN+WH/p0CVD3na5gMYQDizlB3D1kqHoZ/XDd
	/tWuvj0bwEcTLEoeNPWbKfd2fFMxTouPGpMANxgm05JXCChLjs8Jr1wbBkYNM9aXHAA==
X-Received: by 2002:aca:5e88:: with SMTP id s130mr1636517oib.91.1564049220831;
        Thu, 25 Jul 2019 03:07:00 -0700 (PDT)
X-Received: by 2002:aca:5e88:: with SMTP id s130mr1636448oib.91.1564049219433;
        Thu, 25 Jul 2019 03:06:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564049219; cv=none;
        d=google.com; s=arc-20160816;
        b=FlsYhP3Z/LB4fNL48qkksmqIbanv4JVYdb4mXvJfDR2Xp94angIh4OPytF0GkOjHBT
         ZPoNdQZE0wpudhg24hiLBFtxY8H1uDCo2/e4bciqNbzwfxGh2xrwby59fwJxp7yuemfM
         zaTMdjnsXUt40B2AKvH7KP9g+zDzIUptiTcxGiO4OJOnazVMsUZ+KxRsm3HXnwPNhm8U
         rXguJrGCQnKv71dHDQE8+avSBmypjVOQUJK7SApqYjK+HrxTcTsGUIkx5lD/s2/1xs1s
         TwEkZ4QstH6GJ1e4LCF/mY//30f11LKCZ3b4/G26PXSFdK+tzD2N9/4XzagnoFDt3y1M
         uInA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rySXd55FKKmTilhBlm7bWbZ5GsZKu1M1RIHXVXtq9ws=;
        b=zFmBu6qwgvWFE5svr2ZdVd2d6XNXH9wC5/i+8TsupfUVk5DD6Ossf7NUA+KTl7dg9C
         acmgyJ7ICW3xmB6iqonyoOkt1nX7nDwNVIvS4bN7VyGNFyVLBg52uRnUnShN8YhkPbil
         M6Zx3HU5N2LqEVjNi3JXZHF8MXaOg6TwgNHulGsNLfyas3eE6D0MlmfePRPD9OBEJ0Eu
         9VoDtXQEcqQkRKlAVsVqEo6YA4zDo+QqLntY9ucRrIpK81hkHLHK787U7p1Hx7clpi+K
         yEZUghrG6jZT+NGbj7zybkRRY6Wlx9f6hWD1UIL3MjcCYCf3rvoTpbYtz1r8vMMVmubg
         263g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YfNIyO7E;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor24988232otq.42.2019.07.25.03.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 03:06:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YfNIyO7E;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rySXd55FKKmTilhBlm7bWbZ5GsZKu1M1RIHXVXtq9ws=;
        b=YfNIyO7E7hx21MFnduFBCmLfrxvr4J2CG6ojb4m+IMLP7NmiLEUaSAWY5dKNwCL0kJ
         MlPB7XEcRYSh7x5tqAmVWI6yqXGXMV52IoiUD07Maqxq1BKS1polBRMtiyhrJ94AME5A
         8qKPP5KSu2XYBhH5WdMgu5CxCTKm9aEVBix62gLqRaXAWOiyyDBxCnwKsOSdpBGRnndp
         QWFlmb+kaA5tyNoUwCBOrUu/p3+Wx1EIUlNuYL+sQKbcGJei9Q0F+eoLTyjdJj3oqxtb
         q0IOOfUTwveT35j6QA7567ChwY2OVp0A51vo939Ps437mG9Dig5pddz/c4DrAU0tLBkU
         vbbg==
X-Google-Smtp-Source: APXvYqwTLihBsGZbwA2Jhvkd9VbFCvSe7yNWUYK6bG3mXexma1ERXcbjDz+rVgWn4sfy/1KJGlTcSm3Vir2arwiGYDY=
X-Received: by 2002:a9d:7a46:: with SMTP id z6mr3198422otm.2.1564049218422;
 Thu, 25 Jul 2019 03:06:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com> <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
In-Reply-To: <CACT4Y+Z3HNLBh_FtevDvf2fe_BYPTckC19csomR6nK42_w8c1Q@mail.gmail.com>
From: Marco Elver <elver@google.com>
Date: Thu, 25 Jul 2019 12:06:46 +0200
Message-ID: <CANpmjNNhwcYo-3tMkYPGrvSew633FQW7fCUiTgYUp7iKYY7fpw@mail.gmail.com>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Axtens <dja@axtens.net>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>, "the arch/x86 maintainers" <x86@kernel.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Andy Lutomirski <luto@kernel.org>, Mark Rutland <mark.rutland@arm.com>
Content-Type: multipart/mixed; boundary="00000000000013f71a058e7e96ae"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--00000000000013f71a058e7e96ae
Content-Type: text/plain; charset="UTF-8"

On Thu, 25 Jul 2019 at 09:51, Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Thu, Jul 25, 2019 at 9:35 AM Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> > ,On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
> > >
> > > Hook into vmalloc and vmap, and dynamically allocate real shadow
> > > memory to back the mappings.
> > >
> > > Most mappings in vmalloc space are small, requiring less than a full
> > > page of shadow space. Allocating a full shadow page per mapping would
> > > therefore be wasteful. Furthermore, to ensure that different mappings
> > > use different shadow pages, mappings would have to be aligned to
> > > KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> > >
> > > Instead, share backing space across multiple mappings. Allocate
> > > a backing page the first time a mapping in vmalloc space uses a
> > > particular page of the shadow region. Keep this page around
> > > regardless of whether the mapping is later freed - in the mean time
> > > the page could have become shared by another vmalloc mapping.
> > >
> > > This can in theory lead to unbounded memory growth, but the vmalloc
> > > allocator is pretty good at reusing addresses, so the practical memory
> > > usage grows at first but then stays fairly stable.
> > >
> > > This requires architecture support to actually use: arches must stop
> > > mapping the read-only zero page over portion of the shadow region that
> > > covers the vmalloc space and instead leave it unmapped.
> > >
> > > This allows KASAN with VMAP_STACK, and will be needed for architectures
> > > that do not have a separate module space (e.g. powerpc64, which I am
> > > currently working on).
> > >
> > > Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> > > Signed-off-by: Daniel Axtens <dja@axtens.net>
> >
> > Hi Daniel,
> >
> > This is awesome! Thanks so much for taking over this!
> > I agree with memory/simplicity tradeoffs. Provided that virtual
> > addresses are reused, this should be fine (I hope). If we will ever
> > need to optimize memory consumption, I would even consider something
> > like aligning all vmalloc allocations to PAGE_SIZE*KASAN_SHADOW_SCALE
> > to make things simpler.
> >
> > Some comments below.
>
>
> Marco, please test this with your stack overflow test and with
> syzkaller (to estimate the amount of new OOBs :)). Also are there any
> concerns with performance/memory consumption for us?

It appears that stack overflows are *not* detected when KASAN_VMALLOC
and VMAP_STACK are enabled.

Tested with:
insmod drivers/misc/lkdtm/lkdtm.ko cpoint_name=DIRECT cpoint_type=EXHAUST_STACK

I've also attached the .config. Anything I missed?

Thanks,
-- Marco

> > > ---
> > >  Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++++++
> > >  include/linux/kasan.h             | 16 +++++++++
> > >  lib/Kconfig.kasan                 | 16 +++++++++
> > >  lib/test_kasan.c                  | 26 ++++++++++++++
> > >  mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
> > >  mm/kasan/generic_report.c         |  3 ++
> > >  mm/kasan/kasan.h                  |  1 +
> > >  mm/vmalloc.c                      | 15 +++++++-
> > >  8 files changed, 187 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
> > > index b72d07d70239..35fda484a672 100644
> > > --- a/Documentation/dev-tools/kasan.rst
> > > +++ b/Documentation/dev-tools/kasan.rst
> > > @@ -215,3 +215,63 @@ brk handler is used to print bug reports.
> > >  A potential expansion of this mode is a hardware tag-based mode, which would
> > >  use hardware memory tagging support instead of compiler instrumentation and
> > >  manual shadow memory manipulation.
> > > +
> > > +What memory accesses are sanitised by KASAN?
> > > +--------------------------------------------
> > > +
> > > +The kernel maps memory in a number of different parts of the address
> > > +space. This poses something of a problem for KASAN, which requires
> > > +that all addresses accessed by instrumented code have a valid shadow
> > > +region.
> > > +
> > > +The range of kernel virtual addresses is large: there is not enough
> > > +real memory to support a real shadow region for every address that
> > > +could be accessed by the kernel.
> > > +
> > > +By default
> > > +~~~~~~~~~~
> > > +
> > > +By default, architectures only map real memory over the shadow region
> > > +for the linear mapping (and potentially other small areas). For all
> > > +other areas - such as vmalloc and vmemmap space - a single read-only
> > > +page is mapped over the shadow area. This read-only shadow page
> > > +declares all memory accesses as permitted.
> > > +
> > > +This presents a problem for modules: they do not live in the linear
> > > +mapping, but in a dedicated module space. By hooking in to the module
> > > +allocator, KASAN can temporarily map real shadow memory to cover
> > > +them. This allows detection of invalid accesses to module globals, for
> > > +example.
> > > +
> > > +This also creates an incompatibility with ``VMAP_STACK``: if the stack
> > > +lives in vmalloc space, it will be shadowed by the read-only page, and
> > > +the kernel will fault when trying to set up the shadow data for stack
> > > +variables.
> > > +
> > > +CONFIG_KASAN_VMALLOC
> > > +~~~~~~~~~~~~~~~~~~~~
> > > +
> > > +With ``CONFIG_KASAN_VMALLOC``, KASAN can cover vmalloc space at the
> > > +cost of greater memory usage. Currently this is only supported on x86.
> > > +
> > > +This works by hooking into vmalloc and vmap, and dynamically
> > > +allocating real shadow memory to back the mappings.
> > > +
> > > +Most mappings in vmalloc space are small, requiring less than a full
> > > +page of shadow space. Allocating a full shadow page per mapping would
> > > +therefore be wasteful. Furthermore, to ensure that different mappings
> > > +use different shadow pages, mappings would have to be aligned to
> > > +``KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE``.
> > > +
> > > +Instead, we share backing space across multiple mappings. We allocate
> > > +a backing page the first time a mapping in vmalloc space uses a
> > > +particular page of the shadow region. We keep this page around
> > > +regardless of whether the mapping is later freed - in the mean time
> > > +this page could have become shared by another vmalloc mapping.
> > > +
> > > +This can in theory lead to unbounded memory growth, but the vmalloc
> > > +allocator is pretty good at reusing addresses, so the practical memory
> > > +usage grows at first but then stays fairly stable.
> > > +
> > > +This allows ``VMAP_STACK`` support on x86, and enables support of
> > > +architectures that do not have a fixed module region.
> > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > index cc8a03cc9674..fcabc5a03fca 100644
> > > --- a/include/linux/kasan.h
> > > +++ b/include/linux/kasan.h
> > > @@ -70,8 +70,18 @@ struct kasan_cache {
> > >         int free_meta_offset;
> > >  };
> > >
> > > +/*
> > > + * These functions provide a special case to support backing module
> > > + * allocations with real shadow memory. With KASAN vmalloc, the special
> > > + * case is unnecessary, as the work is handled in the generic case.
> > > + */
> > > +#ifndef CONFIG_KASAN_VMALLOC
> > >  int kasan_module_alloc(void *addr, size_t size);
> > >  void kasan_free_shadow(const struct vm_struct *vm);
> > > +#else
> > > +static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
> > > +static inline void kasan_free_shadow(const struct vm_struct *vm) {}
> > > +#endif
> > >
> > >  int kasan_add_zero_shadow(void *start, unsigned long size);
> > >  void kasan_remove_zero_shadow(void *start, unsigned long size);
> > > @@ -194,4 +204,10 @@ static inline void *kasan_reset_tag(const void *addr)
> > >
> > >  #endif /* CONFIG_KASAN_SW_TAGS */
> > >
> > > +#ifdef CONFIG_KASAN_VMALLOC
> > > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area);
> > > +#else
> > > +static inline void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area) {}
> > > +#endif
> > > +
> > >  #endif /* LINUX_KASAN_H */
> > > diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> > > index 4fafba1a923b..a320dc2e9317 100644
> > > --- a/lib/Kconfig.kasan
> > > +++ b/lib/Kconfig.kasan
> > > @@ -6,6 +6,9 @@ config HAVE_ARCH_KASAN
> > >  config HAVE_ARCH_KASAN_SW_TAGS
> > >         bool
> > >
> > > +config HAVE_ARCH_KASAN_VMALLOC
> > > +       bool
> > > +
> > >  config CC_HAS_KASAN_GENERIC
> > >         def_bool $(cc-option, -fsanitize=kernel-address)
> > >
> > > @@ -135,6 +138,19 @@ config KASAN_S390_4_LEVEL_PAGING
> > >           to 3TB of RAM with KASan enabled). This options allows to force
> > >           4-level paging instead.
> > >
> > > +config KASAN_VMALLOC
> > > +       bool "Back mappings in vmalloc space with real shadow memory"
> > > +       depends on KASAN && HAVE_ARCH_KASAN_VMALLOC
> > > +       help
> > > +         By default, the shadow region for vmalloc space is the read-only
> > > +         zero page. This means that KASAN cannot detect errors involving
> > > +         vmalloc space.
> > > +
> > > +         Enabling this option will hook in to vmap/vmalloc and back those
> > > +         mappings with real shadow memory allocated on demand. This allows
> > > +         for KASAN to detect more sorts of errors (and to support vmapped
> > > +         stacks), but at the cost of higher memory usage.
> > > +
> > >  config TEST_KASAN
> > >         tristate "Module for testing KASAN for bug detection"
> > >         depends on m && KASAN
> > > diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> > > index b63b367a94e8..d375246f5f96 100644
> > > --- a/lib/test_kasan.c
> > > +++ b/lib/test_kasan.c
> > > @@ -18,6 +18,7 @@
> > >  #include <linux/slab.h>
> > >  #include <linux/string.h>
> > >  #include <linux/uaccess.h>
> > > +#include <linux/vmalloc.h>
> > >
> > >  /*
> > >   * Note: test functions are marked noinline so that their names appear in
> > > @@ -709,6 +710,30 @@ static noinline void __init kmalloc_double_kzfree(void)
> > >         kzfree(ptr);
> > >  }
> > >
> > > +#ifdef CONFIG_KASAN_VMALLOC
> > > +static noinline void __init vmalloc_oob(void)
> > > +{
> > > +       void *area;
> > > +
> > > +       pr_info("vmalloc out-of-bounds\n");
> > > +
> > > +       /*
> > > +        * We have to be careful not to hit the guard page.
> > > +        * The MMU will catch that and crash us.
> > > +        */
> > > +       area = vmalloc(3000);
> > > +       if (!area) {
> > > +               pr_err("Allocation failed\n");
> > > +               return;
> > > +       }
> > > +
> > > +       ((volatile char *)area)[3100];
> > > +       vfree(area);
> > > +}
> > > +#else
> > > +static void __init vmalloc_oob(void) {}
> > > +#endif
> > > +
> > >  static int __init kmalloc_tests_init(void)
> > >  {
> > >         /*
> > > @@ -752,6 +777,7 @@ static int __init kmalloc_tests_init(void)
> > >         kasan_strings();
> > >         kasan_bitops();
> > >         kmalloc_double_kzfree();
> > > +       vmalloc_oob();
> > >
> > >         kasan_restore_multi_shot(multishot);
> > >
> > > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > > index 2277b82902d8..a3bb84efccbf 100644
> > > --- a/mm/kasan/common.c
> > > +++ b/mm/kasan/common.c
> > > @@ -568,6 +568,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
> > >         /* The object will be poisoned by page_alloc. */
> > >  }
> > >
> > > +#ifndef CONFIG_KASAN_VMALLOC
> > >  int kasan_module_alloc(void *addr, size_t size)
> > >  {
> > >         void *ret;
> > > @@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
> > >         if (vm->flags & VM_KASAN)
> > >                 vfree(kasan_mem_to_shadow(vm->addr));
> > >  }
> > > +#endif
> > >
> > >  extern void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned long ip);
> > >
> > > @@ -722,3 +724,52 @@ static int __init kasan_memhotplug_init(void)
> > >
> > >  core_initcall(kasan_memhotplug_init);
> > >  #endif
> > > +
> > > +#ifdef CONFIG_KASAN_VMALLOC
> > > +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)
> > > +{
> > > +       unsigned long shadow_alloc_start, shadow_alloc_end;
> > > +       unsigned long addr;
> > > +       unsigned long backing;
> > > +       pgd_t *pgdp;
> > > +       p4d_t *p4dp;
> > > +       pud_t *pudp;
> > > +       pmd_t *pmdp;
> > > +       pte_t *ptep;
> > > +       pte_t backing_pte;
> > > +
> > > +       shadow_alloc_start = ALIGN_DOWN(
> > > +               (unsigned long)kasan_mem_to_shadow(area->addr),
> > > +               PAGE_SIZE);
> > > +       shadow_alloc_end = ALIGN(
> > > +               (unsigned long)kasan_mem_to_shadow(area->addr + area->size),
> > > +               PAGE_SIZE);
> > > +
> > > +       addr = shadow_alloc_start;
> > > +       do {
> > > +               pgdp = pgd_offset_k(addr);
> > > +               p4dp = p4d_alloc(&init_mm, pgdp, addr);
> >
> > Page table allocations will be protected by mm->page_table_lock, right?
> >
> >
> > > +               pudp = pud_alloc(&init_mm, p4dp, addr);
> > > +               pmdp = pmd_alloc(&init_mm, pudp, addr);
> > > +               ptep = pte_alloc_kernel(pmdp, addr);
> > > +
> > > +               /*
> > > +                * we can validly get here if pte is not none: it means we
> > > +                * allocated this page earlier to use part of it for another
> > > +                * allocation
> > > +                */
> > > +               if (pte_none(*ptep)) {
> > > +                       backing = __get_free_page(GFP_KERNEL);
> > > +                       backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
> > > +                                             PAGE_KERNEL);
> > > +                       set_pte_at(&init_mm, addr, ptep, backing_pte);
> > > +               }
> > > +       } while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> > > +
> > > +       requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> > > +       kasan_unpoison_shadow(area->addr, requested_size);
> > > +       kasan_poison_shadow(area->addr + requested_size,
> > > +                           area->size - requested_size,
> > > +                           KASAN_VMALLOC_INVALID);
> >
> >
> > Do I read this correctly that if kernel code does vmalloc(64), they
> > will have exactly 64 bytes available rather than full page? To make
> > sure: vmalloc does not guarantee that the available size is rounded up
> > to page size? I suspect we will see a throw out of new bugs related to
> > OOBs on vmalloc memory. So I want to make sure that these will be
> > indeed bugs that we agree need to be fixed.
> > I am sure there will be bugs where the size is controlled by
> > user-space, so these are bad bugs under any circumstances. But there
> > will also probably be OOBs, where people will try to "prove" that
> > that's fine and will work (just based on our previous experiences :)).
> >
> > On impl side: kasan_unpoison_shadow seems to be capable of handling
> > non-KASAN_SHADOW_SCALE_SIZE-aligned sizes exactly in the way we want.
> > So I think it's better to do:
> >
> >        kasan_unpoison_shadow(area->addr, requested_size);
> >        requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> >        kasan_poison_shadow(area->addr + requested_size,
> >                            area->size - requested_size,
> >                            KASAN_VMALLOC_INVALID);
> >
> >
> >
> > > +}
> > > +#endif
> > > diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
> > > index 36c645939bc9..2d97efd4954f 100644
> > > --- a/mm/kasan/generic_report.c
> > > +++ b/mm/kasan/generic_report.c
> > > @@ -86,6 +86,9 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
> > >         case KASAN_ALLOCA_RIGHT:
> > >                 bug_type = "alloca-out-of-bounds";
> > >                 break;
> > > +       case KASAN_VMALLOC_INVALID:
> > > +               bug_type = "vmalloc-out-of-bounds";
> > > +               break;
> > >         }
> > >
> > >         return bug_type;
> > > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> > > index 014f19e76247..8b1f2fbc780b 100644
> > > --- a/mm/kasan/kasan.h
> > > +++ b/mm/kasan/kasan.h
> > > @@ -25,6 +25,7 @@
> > >  #endif
> > >
> > >  #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
> > > +#define KASAN_VMALLOC_INVALID   0xF9  /* unallocated space in vmapped page */
> > >
> > >  /*
> > >   * Stack redzone shadow values
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index 4fa8d84599b0..8cbcb5056c9b 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -2012,6 +2012,15 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
> > >         va->vm = vm;
> > >         va->flags |= VM_VM_AREA;
> > >         spin_unlock(&vmap_area_lock);
> > > +
> > > +       /*
> > > +        * If we are in vmalloc space we need to cover the shadow area with
> > > +        * real memory. If we come here through VM_ALLOC, this is done
> > > +        * by a higher level function that has access to the true size,
> > > +        * which might not be a full page.
> > > +        */
> > > +       if (is_vmalloc_addr(vm->addr) && !(vm->flags & VM_ALLOC))
> > > +               kasan_cover_vmalloc(vm->size, vm);
> > >  }
> > >
> > >  static void clear_vm_uninitialized_flag(struct vm_struct *vm)
> > > @@ -2483,6 +2492,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
> > >         if (!addr)
> > >                 return NULL;
> > >
> > > +       kasan_cover_vmalloc(real_size, area);
> > > +
> > >         /*
> > >          * In this function, newly allocated vm_struct has VM_UNINITIALIZED
> > >          * flag. It means that vm_struct is not fully initialized.
> > > @@ -3324,9 +3335,11 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
> > >         spin_unlock(&vmap_area_lock);
> > >
> > >         /* insert all vm's */
> > > -       for (area = 0; area < nr_vms; area++)
> > > +       for (area = 0; area < nr_vms; area++) {
> > >                 setup_vmalloc_vm(vms[area], vas[area], VM_ALLOC,
> > >                                  pcpu_get_vm_areas);
> > > +               kasan_cover_vmalloc(sizes[area], vms[area]);
> > > +       }
> > >
> > >         kfree(vas);
> > >         return vms;
> > > --
> > > 2.20.1
> > >
> > > --
> > > You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> > > To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> > > To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190725055503.19507-2-dja%40axtens.net.

--00000000000013f71a058e7e96ae
Content-Type: application/octet-stream; name=".config"
Content-Disposition: attachment; filename=".config"
Content-Transfer-Encoding: base64
Content-ID: <f_jyiignf30>
X-Attachment-Id: f_jyiignf30

IwojIEF1dG9tYXRpY2FsbHkgZ2VuZXJhdGVkIGZpbGU7IERPIE5PVCBFRElULgojIExpbnV4L3g4
NiA1LjMuMC1yYzEgS2VybmVsIENvbmZpZ3VyYXRpb24KIwoKIwojIENvbXBpbGVyOiBnY2MgKEdD
QykgOS4wLjAgMjAxODEyMzEgKGV4cGVyaW1lbnRhbCkKIwpDT05GSUdfQ0NfSVNfR0NDPXkKQ09O
RklHX0dDQ19WRVJTSU9OPTkwMDAwCkNPTkZJR19DTEFOR19WRVJTSU9OPTAKQ09ORklHX0NDX0NB
Tl9MSU5LPXkKQ09ORklHX0NDX0hBU19BU01fR09UTz15CkNPTkZJR19DQ19IQVNfV0FSTl9NQVlC
RV9VTklOSVRJQUxJWkVEPXkKQ09ORklHX0NPTlNUUlVDVE9SUz15CkNPTkZJR19JUlFfV09SSz15
CkNPTkZJR19CVUlMRFRJTUVfRVhUQUJMRV9TT1JUPXkKQ09ORklHX1RIUkVBRF9JTkZPX0lOX1RB
U0s9eQoKIwojIEdlbmVyYWwgc2V0dXAKIwpDT05GSUdfSU5JVF9FTlZfQVJHX0xJTUlUPTMyCiMg
Q09ORklHX0NPTVBJTEVfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX0hFQURFUl9URVNUIGlzIG5v
dCBzZXQKQ09ORklHX0xPQ0FMVkVSU0lPTj0iIgojIENPTkZJR19MT0NBTFZFUlNJT05fQVVUTyBp
cyBub3Qgc2V0CkNPTkZJR19CVUlMRF9TQUxUPSIiCkNPTkZJR19IQVZFX0tFUk5FTF9HWklQPXkK
Q09ORklHX0hBVkVfS0VSTkVMX0JaSVAyPXkKQ09ORklHX0hBVkVfS0VSTkVMX0xaTUE9eQpDT05G
SUdfSEFWRV9LRVJORUxfWFo9eQpDT05GSUdfSEFWRV9LRVJORUxfTFpPPXkKQ09ORklHX0hBVkVf
S0VSTkVMX0xaND15CkNPTkZJR19LRVJORUxfR1pJUD15CiMgQ09ORklHX0tFUk5FTF9CWklQMiBp
cyBub3Qgc2V0CiMgQ09ORklHX0tFUk5FTF9MWk1BIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VSTkVM
X1haIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VSTkVMX0xaTyBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
Uk5FTF9MWjQgaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9IT1NUTkFNRT0iKG5vbmUpIgpDT05G
SUdfU1dBUD15CkNPTkZJR19TWVNWSVBDPXkKQ09ORklHX1NZU1ZJUENfU1lTQ1RMPXkKQ09ORklH
X1BPU0lYX01RVUVVRT15CkNPTkZJR19QT1NJWF9NUVVFVUVfU1lTQ1RMPXkKQ09ORklHX0NST1NT
X01FTU9SWV9BVFRBQ0g9eQpDT05GSUdfVVNFTElCPXkKQ09ORklHX0FVRElUPXkKQ09ORklHX0hB
VkVfQVJDSF9BVURJVFNZU0NBTEw9eQpDT05GSUdfQVVESVRTWVNDQUxMPXkKCiMKIyBJUlEgc3Vi
c3lzdGVtCiMKQ09ORklHX0dFTkVSSUNfSVJRX1BST0JFPXkKQ09ORklHX0dFTkVSSUNfSVJRX1NI
T1c9eQpDT05GSUdfR0VORVJJQ19JUlFfRUZGRUNUSVZFX0FGRl9NQVNLPXkKQ09ORklHX0dFTkVS
SUNfUEVORElOR19JUlE9eQpDT05GSUdfR0VORVJJQ19JUlFfTUlHUkFUSU9OPXkKQ09ORklHX0lS
UV9ET01BSU49eQpDT05GSUdfSVJRX0RPTUFJTl9ISUVSQVJDSFk9eQpDT05GSUdfR0VORVJJQ19N
U0lfSVJRPXkKQ09ORklHX0dFTkVSSUNfTVNJX0lSUV9ET01BSU49eQpDT05GSUdfR0VORVJJQ19J
UlFfTUFUUklYX0FMTE9DQVRPUj15CkNPTkZJR19HRU5FUklDX0lSUV9SRVNFUlZBVElPTl9NT0RF
PXkKQ09ORklHX0lSUV9GT1JDRURfVEhSRUFESU5HPXkKQ09ORklHX1NQQVJTRV9JUlE9eQojIENP
TkZJR19HRU5FUklDX0lSUV9ERUJVR0ZTIGlzIG5vdCBzZXQKIyBlbmQgb2YgSVJRIHN1YnN5c3Rl
bQoKQ09ORklHX0NMT0NLU09VUkNFX1dBVENIRE9HPXkKQ09ORklHX0FSQ0hfQ0xPQ0tTT1VSQ0Vf
REFUQT15CkNPTkZJR19BUkNIX0NMT0NLU09VUkNFX0lOSVQ9eQpDT05GSUdfQ0xPQ0tTT1VSQ0Vf
VkFMSURBVEVfTEFTVF9DWUNMRT15CkNPTkZJR19HRU5FUklDX1RJTUVfVlNZU0NBTEw9eQpDT05G
SUdfR0VORVJJQ19DTE9DS0VWRU5UUz15CkNPTkZJR19HRU5FUklDX0NMT0NLRVZFTlRTX0JST0FE
Q0FTVD15CkNPTkZJR19HRU5FUklDX0NMT0NLRVZFTlRTX01JTl9BREpVU1Q9eQpDT05GSUdfR0VO
RVJJQ19DTU9TX1VQREFURT15CgojCiMgVGltZXJzIHN1YnN5c3RlbQojCkNPTkZJR19USUNLX09O
RVNIT1Q9eQpDT05GSUdfTk9fSFpfQ09NTU9OPXkKIyBDT05GSUdfSFpfUEVSSU9ESUMgaXMgbm90
IHNldApDT05GSUdfTk9fSFpfSURMRT15CiMgQ09ORklHX05PX0haX0ZVTEwgaXMgbm90IHNldApD
T05GSUdfTk9fSFo9eQpDT05GSUdfSElHSF9SRVNfVElNRVJTPXkKIyBlbmQgb2YgVGltZXJzIHN1
YnN5c3RlbQoKIyBDT05GSUdfUFJFRU1QVF9OT05FIGlzIG5vdCBzZXQKQ09ORklHX1BSRUVNUFRf
Vk9MVU5UQVJZPXkKIyBDT05GSUdfUFJFRU1QVCBpcyBub3Qgc2V0CgojCiMgQ1BVL1Rhc2sgdGlt
ZSBhbmQgc3RhdHMgYWNjb3VudGluZwojCkNPTkZJR19USUNLX0NQVV9BQ0NPVU5USU5HPXkKIyBD
T05GSUdfVklSVF9DUFVfQUNDT1VOVElOR19HRU4gaXMgbm90IHNldAojIENPTkZJR19JUlFfVElN
RV9BQ0NPVU5USU5HIGlzIG5vdCBzZXQKQ09ORklHX0JTRF9QUk9DRVNTX0FDQ1Q9eQojIENPTkZJ
R19CU0RfUFJPQ0VTU19BQ0NUX1YzIGlzIG5vdCBzZXQKQ09ORklHX1RBU0tTVEFUUz15CkNPTkZJ
R19UQVNLX0RFTEFZX0FDQ1Q9eQpDT05GSUdfVEFTS19YQUNDVD15CkNPTkZJR19UQVNLX0lPX0FD
Q09VTlRJTkc9eQojIENPTkZJR19QU0kgaXMgbm90IHNldAojIGVuZCBvZiBDUFUvVGFzayB0aW1l
IGFuZCBzdGF0cyBhY2NvdW50aW5nCgpDT05GSUdfQ1BVX0lTT0xBVElPTj15CgojCiMgUkNVIFN1
YnN5c3RlbQojCkNPTkZJR19UUkVFX1JDVT15CiMgQ09ORklHX1JDVV9FWFBFUlQgaXMgbm90IHNl
dApDT05GSUdfU1JDVT15CkNPTkZJR19UUkVFX1NSQ1U9eQpDT05GSUdfUkNVX1NUQUxMX0NPTU1P
Tj15CkNPTkZJR19SQ1VfTkVFRF9TRUdDQkxJU1Q9eQojIGVuZCBvZiBSQ1UgU3Vic3lzdGVtCgoj
IENPTkZJR19JS0NPTkZJRyBpcyBub3Qgc2V0CiMgQ09ORklHX0lLSEVBREVSUyBpcyBub3Qgc2V0
CkNPTkZJR19MT0dfQlVGX1NISUZUPTE4CkNPTkZJR19MT0dfQ1BVX01BWF9CVUZfU0hJRlQ9MTIK
Q09ORklHX1BSSU5US19TQUZFX0xPR19CVUZfU0hJRlQ9MTMKQ09ORklHX0hBVkVfVU5TVEFCTEVf
U0NIRURfQ0xPQ0s9eQoKIwojIFNjaGVkdWxlciBmZWF0dXJlcwojCiMgZW5kIG9mIFNjaGVkdWxl
ciBmZWF0dXJlcwoKQ09ORklHX0FSQ0hfU1VQUE9SVFNfTlVNQV9CQUxBTkNJTkc9eQpDT05GSUdf
QVJDSF9XQU5UX0JBVENIRURfVU5NQVBfVExCX0ZMVVNIPXkKQ09ORklHX0FSQ0hfU1VQUE9SVFNf
SU5UMTI4PXkKIyBDT05GSUdfTlVNQV9CQUxBTkNJTkcgaXMgbm90IHNldApDT05GSUdfQ0dST1VQ
Uz15CiMgQ09ORklHX01FTUNHIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0NHUk9VUCBpcyBub3Qg
c2V0CkNPTkZJR19DR1JPVVBfU0NIRUQ9eQpDT05GSUdfRkFJUl9HUk9VUF9TQ0hFRD15CiMgQ09O
RklHX0NGU19CQU5EV0lEVEggaXMgbm90IHNldAojIENPTkZJR19SVF9HUk9VUF9TQ0hFRCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NHUk9VUF9QSURTIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0dST1VQX1JE
TUEgaXMgbm90IHNldApDT05GSUdfQ0dST1VQX0ZSRUVaRVI9eQojIENPTkZJR19DR1JPVVBfSFVH
RVRMQiBpcyBub3Qgc2V0CkNPTkZJR19DUFVTRVRTPXkKQ09ORklHX1BST0NfUElEX0NQVVNFVD15
CiMgQ09ORklHX0NHUk9VUF9ERVZJQ0UgaXMgbm90IHNldApDT05GSUdfQ0dST1VQX0NQVUFDQ1Q9
eQojIENPTkZJR19DR1JPVVBfUEVSRiBpcyBub3Qgc2V0CiMgQ09ORklHX0NHUk9VUF9ERUJVRyBp
cyBub3Qgc2V0CkNPTkZJR19OQU1FU1BBQ0VTPXkKQ09ORklHX1VUU19OUz15CkNPTkZJR19JUENf
TlM9eQojIENPTkZJR19VU0VSX05TIGlzIG5vdCBzZXQKQ09ORklHX1BJRF9OUz15CkNPTkZJR19O
RVRfTlM9eQojIENPTkZJR19DSEVDS1BPSU5UX1JFU1RPUkUgaXMgbm90IHNldAojIENPTkZJR19T
Q0hFRF9BVVRPR1JPVVAgaXMgbm90IHNldAojIENPTkZJR19TWVNGU19ERVBSRUNBVEVEIGlzIG5v
dCBzZXQKQ09ORklHX1JFTEFZPXkKQ09ORklHX0JMS19ERVZfSU5JVFJEPXkKQ09ORklHX0lOSVRS
QU1GU19TT1VSQ0U9IiIKQ09ORklHX1JEX0daSVA9eQpDT05GSUdfUkRfQlpJUDI9eQpDT05GSUdf
UkRfTFpNQT15CkNPTkZJR19SRF9YWj15CkNPTkZJR19SRF9MWk89eQpDT05GSUdfUkRfTFo0PXkK
Q09ORklHX0NDX09QVElNSVpFX0ZPUl9QRVJGT1JNQU5DRT15CiMgQ09ORklHX0NDX09QVElNSVpF
X0ZPUl9TSVpFIGlzIG5vdCBzZXQKQ09ORklHX1NZU0NUTD15CkNPTkZJR19IQVZFX1VJRDE2PXkK
Q09ORklHX1NZU0NUTF9FWENFUFRJT05fVFJBQ0U9eQpDT05GSUdfSEFWRV9QQ1NQS1JfUExBVEZP
Uk09eQpDT05GSUdfQlBGPXkKIyBDT05GSUdfRVhQRVJUIGlzIG5vdCBzZXQKQ09ORklHX1VJRDE2
PXkKQ09ORklHX01VTFRJVVNFUj15CkNPTkZJR19TR0VUTUFTS19TWVNDQUxMPXkKQ09ORklHX1NZ
U0ZTX1NZU0NBTEw9eQpDT05GSUdfRkhBTkRMRT15CkNPTkZJR19QT1NJWF9USU1FUlM9eQpDT05G
SUdfUFJJTlRLPXkKQ09ORklHX1BSSU5US19OTUk9eQpDT05GSUdfQlVHPXkKQ09ORklHX0VMRl9D
T1JFPXkKQ09ORklHX1BDU1BLUl9QTEFURk9STT15CkNPTkZJR19CQVNFX0ZVTEw9eQpDT05GSUdf
RlVURVg9eQpDT05GSUdfRlVURVhfUEk9eQpDT05GSUdfRVBPTEw9eQpDT05GSUdfU0lHTkFMRkQ9
eQpDT05GSUdfVElNRVJGRD15CkNPTkZJR19FVkVOVEZEPXkKQ09ORklHX1NITUVNPXkKQ09ORklH
X0FJTz15CkNPTkZJR19JT19VUklORz15CkNPTkZJR19BRFZJU0VfU1lTQ0FMTFM9eQpDT05GSUdf
TUVNQkFSUklFUj15CkNPTkZJR19LQUxMU1lNUz15CiMgQ09ORklHX0tBTExTWU1TX0FMTCBpcyBu
b3Qgc2V0CkNPTkZJR19LQUxMU1lNU19BQlNPTFVURV9QRVJDUFU9eQpDT05GSUdfS0FMTFNZTVNf
QkFTRV9SRUxBVElWRT15CiMgQ09ORklHX0JQRl9TWVNDQUxMIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNFUkZBVUxURkQgaXMgbm90IHNldApDT05GSUdfQVJDSF9IQVNfTUVNQkFSUklFUl9TWU5DX0NP
UkU9eQpDT05GSUdfUlNFUT15CiMgQ09ORklHX0VNQkVEREVEIGlzIG5vdCBzZXQKQ09ORklHX0hB
VkVfUEVSRl9FVkVOVFM9eQoKIwojIEtlcm5lbCBQZXJmb3JtYW5jZSBFdmVudHMgQW5kIENvdW50
ZXJzCiMKQ09ORklHX1BFUkZfRVZFTlRTPXkKIyBDT05GSUdfREVCVUdfUEVSRl9VU0VfVk1BTExP
QyBpcyBub3Qgc2V0CiMgZW5kIG9mIEtlcm5lbCBQZXJmb3JtYW5jZSBFdmVudHMgQW5kIENvdW50
ZXJzCgpDT05GSUdfVk1fRVZFTlRfQ09VTlRFUlM9eQpDT05GSUdfU0xVQl9ERUJVRz15CiMgQ09O
RklHX0NPTVBBVF9CUksgaXMgbm90IHNldAojIENPTkZJR19TTEFCIGlzIG5vdCBzZXQKQ09ORklH
X1NMVUI9eQpDT05GSUdfU0xBQl9NRVJHRV9ERUZBVUxUPXkKIyBDT05GSUdfU0xBQl9GUkVFTElT
VF9SQU5ET00gaXMgbm90IHNldAojIENPTkZJR19TTEFCX0ZSRUVMSVNUX0hBUkRFTkVEIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0hVRkZMRV9QQUdFX0FMTE9DQVRPUiBpcyBub3Qgc2V0CkNPTkZJR19T
TFVCX0NQVV9QQVJUSUFMPXkKQ09ORklHX1NZU1RFTV9EQVRBX1ZFUklGSUNBVElPTj15CkNPTkZJ
R19QUk9GSUxJTkc9eQpDT05GSUdfVFJBQ0VQT0lOVFM9eQojIGVuZCBvZiBHZW5lcmFsIHNldHVw
CgpDT05GSUdfNjRCSVQ9eQpDT05GSUdfWDg2XzY0PXkKQ09ORklHX1g4Nj15CkNPTkZJR19JTlNU
UlVDVElPTl9ERUNPREVSPXkKQ09ORklHX09VVFBVVF9GT1JNQVQ9ImVsZjY0LXg4Ni02NCIKQ09O
RklHX0FSQ0hfREVGQ09ORklHPSJhcmNoL3g4Ni9jb25maWdzL3g4Nl82NF9kZWZjb25maWciCkNP
TkZJR19MT0NLREVQX1NVUFBPUlQ9eQpDT05GSUdfU1RBQ0tUUkFDRV9TVVBQT1JUPXkKQ09ORklH
X01NVT15CkNPTkZJR19BUkNIX01NQVBfUk5EX0JJVFNfTUlOPTI4CkNPTkZJR19BUkNIX01NQVBf
Uk5EX0JJVFNfTUFYPTMyCkNPTkZJR19BUkNIX01NQVBfUk5EX0NPTVBBVF9CSVRTX01JTj04CkNP
TkZJR19BUkNIX01NQVBfUk5EX0NPTVBBVF9CSVRTX01BWD0xNgpDT05GSUdfR0VORVJJQ19JU0Ff
RE1BPXkKQ09ORklHX0dFTkVSSUNfQlVHPXkKQ09ORklHX0dFTkVSSUNfQlVHX1JFTEFUSVZFX1BP
SU5URVJTPXkKQ09ORklHX0FSQ0hfTUFZX0hBVkVfUENfRkRDPXkKQ09ORklHX0dFTkVSSUNfQ0FM
SUJSQVRFX0RFTEFZPXkKQ09ORklHX0FSQ0hfSEFTX0NQVV9SRUxBWD15CkNPTkZJR19BUkNIX0hB
U19DQUNIRV9MSU5FX1NJWkU9eQpDT05GSUdfQVJDSF9IQVNfRklMVEVSX1BHUFJPVD15CkNPTkZJ
R19IQVZFX1NFVFVQX1BFUl9DUFVfQVJFQT15CkNPTkZJR19ORUVEX1BFUl9DUFVfRU1CRURfRklS
U1RfQ0hVTks9eQpDT05GSUdfTkVFRF9QRVJfQ1BVX1BBR0VfRklSU1RfQ0hVTks9eQpDT05GSUdf
QVJDSF9ISUJFUk5BVElPTl9QT1NTSUJMRT15CkNPTkZJR19BUkNIX1NVU1BFTkRfUE9TU0lCTEU9
eQpDT05GSUdfQVJDSF9XQU5UX0dFTkVSQUxfSFVHRVRMQj15CkNPTkZJR19aT05FX0RNQTMyPXkK
Q09ORklHX0FVRElUX0FSQ0g9eQpDT05GSUdfQVJDSF9TVVBQT1JUU19ERUJVR19QQUdFQUxMT0M9
eQpDT05GSUdfS0FTQU5fU0hBRE9XX09GRlNFVD0weGRmZmZmYzAwMDAwMDAwMDAKQ09ORklHX0hB
VkVfSU5URUxfVFhUPXkKQ09ORklHX1g4Nl82NF9TTVA9eQpDT05GSUdfQVJDSF9TVVBQT1JUU19V
UFJPQkVTPXkKQ09ORklHX0ZJWF9FQVJMWUNPTl9NRU09eQpDT05GSUdfUEdUQUJMRV9MRVZFTFM9
NApDT05GSUdfQ0NfSEFTX1NBTkVfU1RBQ0tQUk9URUNUT1I9eQoKIwojIFByb2Nlc3NvciB0eXBl
IGFuZCBmZWF0dXJlcwojCkNPTkZJR19aT05FX0RNQT15CkNPTkZJR19TTVA9eQpDT05GSUdfWDg2
X0ZFQVRVUkVfTkFNRVM9eQojIENPTkZJR19YODZfWDJBUElDIGlzIG5vdCBzZXQKQ09ORklHX1g4
Nl9NUFBBUlNFPXkKIyBDT05GSUdfR09MREZJU0ggaXMgbm90IHNldApDT05GSUdfUkVUUE9MSU5F
PXkKIyBDT05GSUdfWDg2X0NQVV9SRVNDVFJMIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9FWFRFTkRF
RF9QTEFURk9STT15CiMgQ09ORklHX1g4Nl9WU01QIGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2X0dP
TERGSVNIIGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2X0lOVEVMX01JRCBpcyBub3Qgc2V0CiMgQ09O
RklHX1g4Nl9JTlRFTF9MUFNTIGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2X0FNRF9QTEFURk9STV9E
RVZJQ0UgaXMgbm90IHNldApDT05GSUdfSU9TRl9NQkk9eQojIENPTkZJR19JT1NGX01CSV9ERUJV
RyBpcyBub3Qgc2V0CkNPTkZJR19YODZfU1VQUE9SVFNfTUVNT1JZX0ZBSUxVUkU9eQpDT05GSUdf
U0NIRURfT01JVF9GUkFNRV9QT0lOVEVSPXkKQ09ORklHX0hZUEVSVklTT1JfR1VFU1Q9eQpDT05G
SUdfUEFSQVZJUlQ9eQojIENPTkZJR19QQVJBVklSVF9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklH
X1BBUkFWSVJUX1NQSU5MT0NLUyBpcyBub3Qgc2V0CiMgQ09ORklHX1hFTiBpcyBub3Qgc2V0CkNP
TkZJR19LVk1fR1VFU1Q9eQojIENPTkZJR19QVkggaXMgbm90IHNldAojIENPTkZJR19LVk1fREVC
VUdfRlMgaXMgbm90IHNldAojIENPTkZJR19QQVJBVklSVF9USU1FX0FDQ09VTlRJTkcgaXMgbm90
IHNldApDT05GSUdfUEFSQVZJUlRfQ0xPQ0s9eQojIENPTkZJR19KQUlMSE9VU0VfR1VFU1QgaXMg
bm90IHNldAojIENPTkZJR19BQ1JOX0dVRVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfTUs4IGlzIG5v
dCBzZXQKIyBDT05GSUdfTVBTQyBpcyBub3Qgc2V0CiMgQ09ORklHX01DT1JFMiBpcyBub3Qgc2V0
CiMgQ09ORklHX01BVE9NIGlzIG5vdCBzZXQKQ09ORklHX0dFTkVSSUNfQ1BVPXkKQ09ORklHX1g4
Nl9JTlRFUk5PREVfQ0FDSEVfU0hJRlQ9NgpDT05GSUdfWDg2X0wxX0NBQ0hFX1NISUZUPTYKQ09O
RklHX1g4Nl9UU0M9eQpDT05GSUdfWDg2X0NNUFhDSEc2ND15CkNPTkZJR19YODZfQ01PVj15CkNP
TkZJR19YODZfTUlOSU1VTV9DUFVfRkFNSUxZPTY0CkNPTkZJR19YODZfREVCVUdDVExNU1I9eQpD
T05GSUdfQ1BVX1NVUF9JTlRFTD15CkNPTkZJR19DUFVfU1VQX0FNRD15CkNPTkZJR19DUFVfU1VQ
X0hZR09OPXkKQ09ORklHX0NQVV9TVVBfQ0VOVEFVUj15CkNPTkZJR19DUFVfU1VQX1pIQU9YSU49
eQpDT05GSUdfSFBFVF9USU1FUj15CkNPTkZJR19IUEVUX0VNVUxBVEVfUlRDPXkKQ09ORklHX0RN
ST15CiMgQ09ORklHX0dBUlRfSU9NTVUgaXMgbm90IHNldApDT05GSUdfQ0FMR0FSWV9JT01NVT15
CkNPTkZJR19DQUxHQVJZX0lPTU1VX0VOQUJMRURfQllfREVGQVVMVD15CiMgQ09ORklHX01BWFNN
UCBpcyBub3Qgc2V0CkNPTkZJR19OUl9DUFVTX1JBTkdFX0JFR0lOPTIKQ09ORklHX05SX0NQVVNf
UkFOR0VfRU5EPTUxMgpDT05GSUdfTlJfQ1BVU19ERUZBVUxUPTY0CkNPTkZJR19OUl9DUFVTPTY0
CkNPTkZJR19TQ0hFRF9TTVQ9eQpDT05GSUdfU0NIRURfTUM9eQpDT05GSUdfU0NIRURfTUNfUFJJ
Tz15CkNPTkZJR19YODZfTE9DQUxfQVBJQz15CkNPTkZJR19YODZfSU9fQVBJQz15CkNPTkZJR19Y
ODZfUkVST1VURV9GT1JfQlJPS0VOX0JPT1RfSVJRUz15CkNPTkZJR19YODZfTUNFPXkKIyBDT05G
SUdfWDg2X01DRUxPR19MRUdBQ1kgaXMgbm90IHNldApDT05GSUdfWDg2X01DRV9JTlRFTD15CkNP
TkZJR19YODZfTUNFX0FNRD15CkNPTkZJR19YODZfTUNFX1RIUkVTSE9MRD15CiMgQ09ORklHX1g4
Nl9NQ0VfSU5KRUNUIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9USEVSTUFMX1ZFQ1RPUj15CgojCiMg
UGVyZm9ybWFuY2UgbW9uaXRvcmluZwojCkNPTkZJR19QRVJGX0VWRU5UU19JTlRFTF9VTkNPUkU9
eQpDT05GSUdfUEVSRl9FVkVOVFNfSU5URUxfUkFQTD15CkNPTkZJR19QRVJGX0VWRU5UU19JTlRF
TF9DU1RBVEU9eQojIENPTkZJR19QRVJGX0VWRU5UU19BTURfUE9XRVIgaXMgbm90IHNldAojIGVu
ZCBvZiBQZXJmb3JtYW5jZSBtb25pdG9yaW5nCgpDT05GSUdfWDg2XzE2QklUPXkKQ09ORklHX1g4
Nl9FU1BGSVg2ND15CkNPTkZJR19YODZfVlNZU0NBTExfRU1VTEFUSU9OPXkKIyBDT05GSUdfSThL
IGlzIG5vdCBzZXQKQ09ORklHX01JQ1JPQ09ERT15CkNPTkZJR19NSUNST0NPREVfSU5URUw9eQpD
T05GSUdfTUlDUk9DT0RFX0FNRD15CiMgQ09ORklHX01JQ1JPQ09ERV9PTERfSU5URVJGQUNFIGlz
IG5vdCBzZXQKQ09ORklHX1g4Nl9NU1I9eQpDT05GSUdfWDg2X0NQVUlEPXkKIyBDT05GSUdfWDg2
XzVMRVZFTCBpcyBub3Qgc2V0CkNPTkZJR19YODZfRElSRUNUX0dCUEFHRVM9eQojIENPTkZJR19Y
ODZfQ1BBX1NUQVRJU1RJQ1MgaXMgbm90IHNldApDT05GSUdfQVJDSF9IQVNfTUVNX0VOQ1JZUFQ9
eQojIENPTkZJR19BTURfTUVNX0VOQ1JZUFQgaXMgbm90IHNldApDT05GSUdfTlVNQT15CkNPTkZJ
R19BTURfTlVNQT15CkNPTkZJR19YODZfNjRfQUNQSV9OVU1BPXkKQ09ORklHX05PREVTX1NQQU5f
T1RIRVJfTk9ERVM9eQojIENPTkZJR19OVU1BX0VNVSBpcyBub3Qgc2V0CkNPTkZJR19OT0RFU19T
SElGVD02CkNPTkZJR19BUkNIX1NQQVJTRU1FTV9FTkFCTEU9eQpDT05GSUdfQVJDSF9TUEFSU0VN
RU1fREVGQVVMVD15CkNPTkZJR19BUkNIX1NFTEVDVF9NRU1PUllfTU9ERUw9eQpDT05GSUdfQVJD
SF9QUk9DX0tDT1JFX1RFWFQ9eQpDT05GSUdfSUxMRUdBTF9QT0lOVEVSX1ZBTFVFPTB4ZGVhZDAw
MDAwMDAwMDAwMAojIENPTkZJR19YODZfUE1FTV9MRUdBQ1kgaXMgbm90IHNldApDT05GSUdfWDg2
X0NIRUNLX0JJT1NfQ09SUlVQVElPTj15CkNPTkZJR19YODZfQk9PVFBBUkFNX01FTU9SWV9DT1JS
VVBUSU9OX0NIRUNLPXkKQ09ORklHX1g4Nl9SRVNFUlZFX0xPVz02NApDT05GSUdfTVRSUj15CiMg
Q09ORklHX01UUlJfU0FOSVRJWkVSIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9QQVQ9eQpDT05GSUdf
QVJDSF9VU0VTX1BHX1VOQ0FDSEVEPXkKQ09ORklHX0FSQ0hfUkFORE9NPXkKQ09ORklHX1g4Nl9T
TUFQPXkKQ09ORklHX1g4Nl9JTlRFTF9VTUlQPXkKIyBDT05GSUdfWDg2X0lOVEVMX01QWCBpcyBu
b3Qgc2V0CkNPTkZJR19YODZfSU5URUxfTUVNT1JZX1BST1RFQ1RJT05fS0VZUz15CkNPTkZJR19F
Rkk9eQpDT05GSUdfRUZJX1NUVUI9eQpDT05GSUdfRUZJX01JWEVEPXkKQ09ORklHX1NFQ0NPTVA9
eQojIENPTkZJR19IWl8xMDAgaXMgbm90IHNldAojIENPTkZJR19IWl8yNTAgaXMgbm90IHNldAoj
IENPTkZJR19IWl8zMDAgaXMgbm90IHNldApDT05GSUdfSFpfMTAwMD15CkNPTkZJR19IWj0xMDAw
CkNPTkZJR19TQ0hFRF9IUlRJQ0s9eQpDT05GSUdfS0VYRUM9eQojIENPTkZJR19LRVhFQ19GSUxF
IGlzIG5vdCBzZXQKQ09ORklHX0NSQVNIX0RVTVA9eQojIENPTkZJR19LRVhFQ19KVU1QIGlzIG5v
dCBzZXQKQ09ORklHX1BIWVNJQ0FMX1NUQVJUPTB4MTAwMDAwMApDT05GSUdfUkVMT0NBVEFCTEU9
eQpDT05GSUdfUkFORE9NSVpFX0JBU0U9eQpDT05GSUdfWDg2X05FRURfUkVMT0NTPXkKQ09ORklH
X1BIWVNJQ0FMX0FMSUdOPTB4MjAwMDAwCkNPTkZJR19EWU5BTUlDX01FTU9SWV9MQVlPVVQ9eQpD
T05GSUdfUkFORE9NSVpFX01FTU9SWT15CkNPTkZJR19SQU5ET01JWkVfTUVNT1JZX1BIWVNJQ0FM
X1BBRERJTkc9MHgwCkNPTkZJR19IT1RQTFVHX0NQVT15CiMgQ09ORklHX0JPT1RQQVJBTV9IT1RQ
TFVHX0NQVTAgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19IT1RQTFVHX0NQVTAgaXMgbm90IHNl
dAojIENPTkZJR19DT01QQVRfVkRTTyBpcyBub3Qgc2V0CiMgQ09ORklHX0xFR0FDWV9WU1lTQ0FM
TF9FTVVMQVRFIGlzIG5vdCBzZXQKQ09ORklHX0xFR0FDWV9WU1lTQ0FMTF9YT05MWT15CiMgQ09O
RklHX0xFR0FDWV9WU1lTQ0FMTF9OT05FIGlzIG5vdCBzZXQKIyBDT05GSUdfQ01ETElORV9CT09M
IGlzIG5vdCBzZXQKQ09ORklHX01PRElGWV9MRFRfU1lTQ0FMTD15CkNPTkZJR19IQVZFX0xJVkVQ
QVRDSD15CiMgZW5kIG9mIFByb2Nlc3NvciB0eXBlIGFuZCBmZWF0dXJlcwoKQ09ORklHX0FSQ0hf
SEFTX0FERF9QQUdFUz15CkNPTkZJR19BUkNIX0VOQUJMRV9NRU1PUllfSE9UUExVRz15CkNPTkZJ
R19VU0VfUEVSQ1BVX05VTUFfTk9ERV9JRD15CkNPTkZJR19BUkNIX0VOQUJMRV9TUExJVF9QTURf
UFRMT0NLPXkKQ09ORklHX0FSQ0hfRU5BQkxFX0hVR0VQQUdFX01JR1JBVElPTj15CgojCiMgUG93
ZXIgbWFuYWdlbWVudCBhbmQgQUNQSSBvcHRpb25zCiMKQ09ORklHX0FSQ0hfSElCRVJOQVRJT05f
SEVBREVSPXkKQ09ORklHX1NVU1BFTkQ9eQpDT05GSUdfU1VTUEVORF9GUkVFWkVSPXkKQ09ORklH
X0hJQkVSTkFURV9DQUxMQkFDS1M9eQpDT05GSUdfSElCRVJOQVRJT049eQpDT05GSUdfUE1fU1RE
X1BBUlRJVElPTj0iIgpDT05GSUdfUE1fU0xFRVA9eQpDT05GSUdfUE1fU0xFRVBfU01QPXkKIyBD
T05GSUdfUE1fQVVUT1NMRUVQIGlzIG5vdCBzZXQKIyBDT05GSUdfUE1fV0FLRUxPQ0tTIGlzIG5v
dCBzZXQKQ09ORklHX1BNPXkKQ09ORklHX1BNX0RFQlVHPXkKIyBDT05GSUdfUE1fQURWQU5DRURf
REVCVUcgaXMgbm90IHNldAojIENPTkZJR19QTV9URVNUX1NVU1BFTkQgaXMgbm90IHNldApDT05G
SUdfUE1fU0xFRVBfREVCVUc9eQpDT05GSUdfUE1fVFJBQ0U9eQpDT05GSUdfUE1fVFJBQ0VfUlRD
PXkKQ09ORklHX1BNX0NMSz15CiMgQ09ORklHX1dRX1BPV0VSX0VGRklDSUVOVF9ERUZBVUxUIGlz
IG5vdCBzZXQKIyBDT05GSUdfRU5FUkdZX01PREVMIGlzIG5vdCBzZXQKQ09ORklHX0FSQ0hfU1VQ
UE9SVFNfQUNQST15CkNPTkZJR19BQ1BJPXkKQ09ORklHX0FDUElfTEVHQUNZX1RBQkxFU19MT09L
VVA9eQpDT05GSUdfQVJDSF9NSUdIVF9IQVZFX0FDUElfUERDPXkKQ09ORklHX0FDUElfU1lTVEVN
X1BPV0VSX1NUQVRFU19TVVBQT1JUPXkKIyBDT05GSUdfQUNQSV9ERUJVR0dFUiBpcyBub3Qgc2V0
CkNPTkZJR19BQ1BJX1NQQ1JfVEFCTEU9eQpDT05GSUdfQUNQSV9MUElUPXkKQ09ORklHX0FDUElf
U0xFRVA9eQojIENPTkZJR19BQ1BJX1BST0NGU19QT1dFUiBpcyBub3Qgc2V0CkNPTkZJR19BQ1BJ
X1JFVl9PVkVSUklERV9QT1NTSUJMRT15CiMgQ09ORklHX0FDUElfRUNfREVCVUdGUyBpcyBub3Qg
c2V0CkNPTkZJR19BQ1BJX0FDPXkKQ09ORklHX0FDUElfQkFUVEVSWT15CkNPTkZJR19BQ1BJX0JV
VFRPTj15CkNPTkZJR19BQ1BJX1ZJREVPPXkKQ09ORklHX0FDUElfRkFOPXkKIyBDT05GSUdfQUNQ
SV9UQUQgaXMgbm90IHNldApDT05GSUdfQUNQSV9ET0NLPXkKQ09ORklHX0FDUElfQ1BVX0ZSRVFf
UFNTPXkKQ09ORklHX0FDUElfUFJPQ0VTU09SX0NTVEFURT15CkNPTkZJR19BQ1BJX1BST0NFU1NP
Ul9JRExFPXkKQ09ORklHX0FDUElfQ1BQQ19MSUI9eQpDT05GSUdfQUNQSV9QUk9DRVNTT1I9eQpD
T05GSUdfQUNQSV9IT1RQTFVHX0NQVT15CiMgQ09ORklHX0FDUElfUFJPQ0VTU09SX0FHR1JFR0FU
T1IgaXMgbm90IHNldApDT05GSUdfQUNQSV9USEVSTUFMPXkKQ09ORklHX0FDUElfTlVNQT15CkNP
TkZJR19BUkNIX0hBU19BQ1BJX1RBQkxFX1VQR1JBREU9eQpDT05GSUdfQUNQSV9UQUJMRV9VUEdS
QURFPXkKIyBDT05GSUdfQUNQSV9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUElfUENJX1NM
T1QgaXMgbm90IHNldApDT05GSUdfQUNQSV9DT05UQUlORVI9eQpDT05GSUdfQUNQSV9IT1RQTFVH
X0lPQVBJQz15CiMgQ09ORklHX0FDUElfU0JTIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9IRUQg
aXMgbm90IHNldAojIENPTkZJR19BQ1BJX0NVU1RPTV9NRVRIT0QgaXMgbm90IHNldApDT05GSUdf
QUNQSV9CR1JUPXkKIyBDT05GSUdfQUNQSV9ORklUIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9I
TUFUIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfQUNQSV9BUEVJPXkKQ09ORklHX0hBVkVfQUNQSV9B
UEVJX05NST15CiMgQ09ORklHX0FDUElfQVBFSSBpcyBub3Qgc2V0CiMgQ09ORklHX0RQVEZfUE9X
RVIgaXMgbm90IHNldAojIENPTkZJR19BQ1BJX0VYVExPRyBpcyBub3Qgc2V0CiMgQ09ORklHX1BN
SUNfT1BSRUdJT04gaXMgbm90IHNldAojIENPTkZJR19BQ1BJX0NPTkZJR0ZTIGlzIG5vdCBzZXQK
Q09ORklHX1g4Nl9QTV9USU1FUj15CiMgQ09ORklHX1NGSSBpcyBub3Qgc2V0CgojCiMgQ1BVIEZy
ZXF1ZW5jeSBzY2FsaW5nCiMKQ09ORklHX0NQVV9GUkVRPXkKQ09ORklHX0NQVV9GUkVRX0dPVl9B
VFRSX1NFVD15CkNPTkZJR19DUFVfRlJFUV9HT1ZfQ09NTU9OPXkKIyBDT05GSUdfQ1BVX0ZSRVFf
U1RBVCBpcyBub3Qgc2V0CiMgQ09ORklHX0NQVV9GUkVRX0RFRkFVTFRfR09WX1BFUkZPUk1BTkNF
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BVX0ZSRVFfREVGQVVMVF9HT1ZfUE9XRVJTQVZFIGlzIG5v
dCBzZXQKQ09ORklHX0NQVV9GUkVRX0RFRkFVTFRfR09WX1VTRVJTUEFDRT15CiMgQ09ORklHX0NQ
VV9GUkVRX0RFRkFVTFRfR09WX09OREVNQU5EIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BVX0ZSRVFf
REVGQVVMVF9HT1ZfQ09OU0VSVkFUSVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BVX0ZSRVFfREVG
QVVMVF9HT1ZfU0NIRURVVElMIGlzIG5vdCBzZXQKQ09ORklHX0NQVV9GUkVRX0dPVl9QRVJGT1JN
QU5DRT15CiMgQ09ORklHX0NQVV9GUkVRX0dPVl9QT1dFUlNBVkUgaXMgbm90IHNldApDT05GSUdf
Q1BVX0ZSRVFfR09WX1VTRVJTUEFDRT15CkNPTkZJR19DUFVfRlJFUV9HT1ZfT05ERU1BTkQ9eQoj
IENPTkZJR19DUFVfRlJFUV9HT1ZfQ09OU0VSVkFUSVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BV
X0ZSRVFfR09WX1NDSEVEVVRJTCBpcyBub3Qgc2V0CgojCiMgQ1BVIGZyZXF1ZW5jeSBzY2FsaW5n
IGRyaXZlcnMKIwpDT05GSUdfWDg2X0lOVEVMX1BTVEFURT15CiMgQ09ORklHX1g4Nl9QQ0NfQ1BV
RlJFUSBpcyBub3Qgc2V0CkNPTkZJR19YODZfQUNQSV9DUFVGUkVRPXkKQ09ORklHX1g4Nl9BQ1BJ
X0NQVUZSRVFfQ1BCPXkKIyBDT05GSUdfWDg2X1BPV0VSTk9XX0s4IGlzIG5vdCBzZXQKIyBDT05G
SUdfWDg2X0FNRF9GUkVRX1NFTlNJVElWSVRZIGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2X1NQRUVE
U1RFUF9DRU5UUklOTyBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9QNF9DTE9DS01PRCBpcyBub3Qg
c2V0CgojCiMgc2hhcmVkIG9wdGlvbnMKIwojIGVuZCBvZiBDUFUgRnJlcXVlbmN5IHNjYWxpbmcK
CiMKIyBDUFUgSWRsZQojCkNPTkZJR19DUFVfSURMRT15CiMgQ09ORklHX0NQVV9JRExFX0dPVl9M
QURERVIgaXMgbm90IHNldApDT05GSUdfQ1BVX0lETEVfR09WX01FTlU9eQojIENPTkZJR19DUFVf
SURMRV9HT1ZfVEVPIGlzIG5vdCBzZXQKIyBlbmQgb2YgQ1BVIElkbGUKCiMgQ09ORklHX0lOVEVM
X0lETEUgaXMgbm90IHNldAojIGVuZCBvZiBQb3dlciBtYW5hZ2VtZW50IGFuZCBBQ1BJIG9wdGlv
bnMKCiMKIyBCdXMgb3B0aW9ucyAoUENJIGV0Yy4pCiMKQ09ORklHX1BDSV9ESVJFQ1Q9eQpDT05G
SUdfUENJX01NQ09ORklHPXkKQ09ORklHX01NQ09ORl9GQU0xMEg9eQpDT05GSUdfSVNBX0RNQV9B
UEk9eQpDT05GSUdfQU1EX05CPXkKIyBDT05GSUdfWDg2X1NZU0ZCIGlzIG5vdCBzZXQKIyBlbmQg
b2YgQnVzIG9wdGlvbnMgKFBDSSBldGMuKQoKIwojIEJpbmFyeSBFbXVsYXRpb25zCiMKQ09ORklH
X0lBMzJfRU1VTEFUSU9OPXkKIyBDT05GSUdfWDg2X1gzMiBpcyBub3Qgc2V0CkNPTkZJR19DT01Q
QVRfMzI9eQpDT05GSUdfQ09NUEFUPXkKQ09ORklHX0NPTVBBVF9GT1JfVTY0X0FMSUdOTUVOVD15
CkNPTkZJR19TWVNWSVBDX0NPTVBBVD15CiMgZW5kIG9mIEJpbmFyeSBFbXVsYXRpb25zCgojCiMg
RmlybXdhcmUgRHJpdmVycwojCiMgQ09ORklHX0VERCBpcyBub3Qgc2V0CkNPTkZJR19GSVJNV0FS
RV9NRU1NQVA9eQpDT05GSUdfRE1JSUQ9eQojIENPTkZJR19ETUlfU1lTRlMgaXMgbm90IHNldApD
T05GSUdfRE1JX1NDQU5fTUFDSElORV9OT05fRUZJX0ZBTExCQUNLPXkKIyBDT05GSUdfSVNDU0lf
SUJGVF9GSU5EIGlzIG5vdCBzZXQKIyBDT05GSUdfRldfQ0ZHX1NZU0ZTIGlzIG5vdCBzZXQKIyBD
T05GSUdfR09PR0xFX0ZJUk1XQVJFIGlzIG5vdCBzZXQKCiMKIyBFRkkgKEV4dGVuc2libGUgRmly
bXdhcmUgSW50ZXJmYWNlKSBTdXBwb3J0CiMKQ09ORklHX0VGSV9WQVJTPXkKQ09ORklHX0VGSV9F
U1JUPXkKQ09ORklHX0VGSV9SVU5USU1FX01BUD15CiMgQ09ORklHX0VGSV9GQUtFX01FTU1BUCBp
cyBub3Qgc2V0CkNPTkZJR19FRklfUlVOVElNRV9XUkFQUEVSUz15CiMgQ09ORklHX0VGSV9CT09U
TE9BREVSX0NPTlRST0wgaXMgbm90IHNldAojIENPTkZJR19FRklfQ0FQU1VMRV9MT0FERVIgaXMg
bm90IHNldAojIENPTkZJR19FRklfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FQUExFX1BST1BF
UlRJRVMgaXMgbm90IHNldAojIENPTkZJR19SRVNFVF9BVFRBQ0tfTUlUSUdBVElPTiBpcyBub3Qg
c2V0CiMgZW5kIG9mIEVGSSAoRXh0ZW5zaWJsZSBGaXJtd2FyZSBJbnRlcmZhY2UpIFN1cHBvcnQK
CkNPTkZJR19FRklfRUFSTFlDT049eQoKIwojIFRlZ3JhIGZpcm13YXJlIGRyaXZlcgojCiMgZW5k
IG9mIFRlZ3JhIGZpcm13YXJlIGRyaXZlcgojIGVuZCBvZiBGaXJtd2FyZSBEcml2ZXJzCgpDT05G
SUdfSEFWRV9LVk09eQpDT05GSUdfVklSVFVBTElaQVRJT049eQojIENPTkZJR19LVk0gaXMgbm90
IHNldAojIENPTkZJR19WSE9TVF9ORVQgaXMgbm90IHNldAojIENPTkZJR19WSE9TVF9DUk9TU19F
TkRJQU5fTEVHQUNZIGlzIG5vdCBzZXQKCiMKIyBHZW5lcmFsIGFyY2hpdGVjdHVyZS1kZXBlbmRl
bnQgb3B0aW9ucwojCkNPTkZJR19DUkFTSF9DT1JFPXkKQ09ORklHX0tFWEVDX0NPUkU9eQpDT05G
SUdfSE9UUExVR19TTVQ9eQojIENPTkZJR19PUFJPRklMRSBpcyBub3Qgc2V0CkNPTkZJR19IQVZF
X09QUk9GSUxFPXkKQ09ORklHX09QUk9GSUxFX05NSV9USU1FUj15CkNPTkZJR19LUFJPQkVTPXkK
Q09ORklHX0pVTVBfTEFCRUw9eQojIENPTkZJR19TVEFUSUNfS0VZU19TRUxGVEVTVCBpcyBub3Qg
c2V0CkNPTkZJR19PUFRQUk9CRVM9eQpDT05GSUdfVVBST0JFUz15CkNPTkZJR19IQVZFX0VGRklD
SUVOVF9VTkFMSUdORURfQUNDRVNTPXkKQ09ORklHX0FSQ0hfVVNFX0JVSUxUSU5fQlNXQVA9eQpD
T05GSUdfS1JFVFBST0JFUz15CkNPTkZJR19IQVZFX0lPUkVNQVBfUFJPVD15CkNPTkZJR19IQVZF
X0tQUk9CRVM9eQpDT05GSUdfSEFWRV9LUkVUUFJPQkVTPXkKQ09ORklHX0hBVkVfT1BUUFJPQkVT
PXkKQ09ORklHX0hBVkVfS1BST0JFU19PTl9GVFJBQ0U9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9F
UlJPUl9JTkpFQ1RJT049eQpDT05GSUdfSEFWRV9OTUk9eQpDT05GSUdfSEFWRV9BUkNIX1RSQUNF
SE9PSz15CkNPTkZJR19IQVZFX0RNQV9DT05USUdVT1VTPXkKQ09ORklHX0dFTkVSSUNfU01QX0lE
TEVfVEhSRUFEPXkKQ09ORklHX0FSQ0hfSEFTX0ZPUlRJRllfU09VUkNFPXkKQ09ORklHX0FSQ0hf
SEFTX1NFVF9NRU1PUlk9eQpDT05GSUdfQVJDSF9IQVNfU0VUX0RJUkVDVF9NQVA9eQpDT05GSUdf
SEFWRV9BUkNIX1RIUkVBRF9TVFJVQ1RfV0hJVEVMSVNUPXkKQ09ORklHX0FSQ0hfV0FOVFNfRFlO
QU1JQ19UQVNLX1NUUlVDVD15CkNPTkZJR19IQVZFX1JFR1NfQU5EX1NUQUNLX0FDQ0VTU19BUEk9
eQpDT05GSUdfSEFWRV9SU0VRPXkKQ09ORklHX0hBVkVfRlVOQ1RJT05fQVJHX0FDQ0VTU19BUEk9
eQpDT05GSUdfSEFWRV9DTEs9eQpDT05GSUdfSEFWRV9IV19CUkVBS1BPSU5UPXkKQ09ORklHX0hB
VkVfTUlYRURfQlJFQUtQT0lOVFNfUkVHUz15CkNPTkZJR19IQVZFX1VTRVJfUkVUVVJOX05PVElG
SUVSPXkKQ09ORklHX0hBVkVfUEVSRl9FVkVOVFNfTk1JPXkKQ09ORklHX0hBVkVfSEFSRExPQ0tV
UF9ERVRFQ1RPUl9QRVJGPXkKQ09ORklHX0hBVkVfUEVSRl9SRUdTPXkKQ09ORklHX0hBVkVfUEVS
Rl9VU0VSX1NUQUNLX0RVTVA9eQpDT05GSUdfSEFWRV9BUkNIX0pVTVBfTEFCRUw9eQpDT05GSUdf
SEFWRV9BUkNIX0pVTVBfTEFCRUxfUkVMQVRJVkU9eQpDT05GSUdfSEFWRV9SQ1VfVEFCTEVfRlJF
RT15CkNPTkZJR19BUkNIX0hBVkVfTk1JX1NBRkVfQ01QWENIRz15CkNPTkZJR19IQVZFX0FMSUdO
RURfU1RSVUNUX1BBR0U9eQpDT05GSUdfSEFWRV9DTVBYQ0hHX0xPQ0FMPXkKQ09ORklHX0hBVkVf
Q01QWENIR19ET1VCTEU9eQpDT05GSUdfQVJDSF9XQU5UX0NPTVBBVF9JUENfUEFSU0VfVkVSU0lP
Tj15CkNPTkZJR19BUkNIX1dBTlRfT0xEX0NPTVBBVF9JUEM9eQpDT05GSUdfSEFWRV9BUkNIX1NF
Q0NPTVBfRklMVEVSPXkKQ09ORklHX1NFQ0NPTVBfRklMVEVSPXkKQ09ORklHX0hBVkVfQVJDSF9T
VEFDS0xFQUs9eQpDT05GSUdfSEFWRV9TVEFDS1BST1RFQ1RPUj15CkNPTkZJR19DQ19IQVNfU1RB
Q0tQUk9URUNUT1JfTk9ORT15CkNPTkZJR19TVEFDS1BST1RFQ1RPUj15CkNPTkZJR19TVEFDS1BS
T1RFQ1RPUl9TVFJPTkc9eQpDT05GSUdfSEFWRV9BUkNIX1dJVEhJTl9TVEFDS19GUkFNRVM9eQpD
T05GSUdfSEFWRV9DT05URVhUX1RSQUNLSU5HPXkKQ09ORklHX0hBVkVfVklSVF9DUFVfQUNDT1VO
VElOR19HRU49eQpDT05GSUdfSEFWRV9JUlFfVElNRV9BQ0NPVU5USU5HPXkKQ09ORklHX0hBVkVf
TU9WRV9QTUQ9eQpDT05GSUdfSEFWRV9BUkNIX1RSQU5TUEFSRU5UX0hVR0VQQUdFPXkKQ09ORklH
X0hBVkVfQVJDSF9UUkFOU1BBUkVOVF9IVUdFUEFHRV9QVUQ9eQpDT05GSUdfSEFWRV9BUkNIX0hV
R0VfVk1BUD15CkNPTkZJR19BUkNIX1dBTlRfSFVHRV9QTURfU0hBUkU9eQpDT05GSUdfSEFWRV9B
UkNIX1NPRlRfRElSVFk9eQpDT05GSUdfSEFWRV9NT0RfQVJDSF9TUEVDSUZJQz15CkNPTkZJR19N
T0RVTEVTX1VTRV9FTEZfUkVMQT15CkNPTkZJR19IQVZFX0lSUV9FWElUX09OX0lSUV9TVEFDSz15
CkNPTkZJR19BUkNIX0hBU19FTEZfUkFORE9NSVpFPXkKQ09ORklHX0hBVkVfQVJDSF9NTUFQX1JO
RF9CSVRTPXkKQ09ORklHX0hBVkVfRVhJVF9USFJFQUQ9eQpDT05GSUdfQVJDSF9NTUFQX1JORF9C
SVRTPTI4CkNPTkZJR19IQVZFX0FSQ0hfTU1BUF9STkRfQ09NUEFUX0JJVFM9eQpDT05GSUdfQVJD
SF9NTUFQX1JORF9DT01QQVRfQklUUz04CkNPTkZJR19IQVZFX0FSQ0hfQ09NUEFUX01NQVBfQkFT
RVM9eQpDT05GSUdfSEFWRV9DT1BZX1RIUkVBRF9UTFM9eQpDT05GSUdfSEFWRV9TVEFDS19WQUxJ
REFUSU9OPXkKQ09ORklHX0hBVkVfUkVMSUFCTEVfU1RBQ0tUUkFDRT15CkNPTkZJR19PTERfU0lH
U1VTUEVORDM9eQpDT05GSUdfQ09NUEFUX09MRF9TSUdBQ1RJT049eQpDT05GSUdfNjRCSVRfVElN
RT15CkNPTkZJR19DT01QQVRfMzJCSVRfVElNRT15CkNPTkZJR19IQVZFX0FSQ0hfVk1BUF9TVEFD
Sz15CkNPTkZJR19WTUFQX1NUQUNLPXkKQ09ORklHX0FSQ0hfSEFTX1NUUklDVF9LRVJORUxfUldY
PXkKQ09ORklHX1NUUklDVF9LRVJORUxfUldYPXkKQ09ORklHX0FSQ0hfSEFTX1NUUklDVF9NT0RV
TEVfUldYPXkKQ09ORklHX1NUUklDVF9NT0RVTEVfUldYPXkKQ09ORklHX0FSQ0hfSEFTX1JFRkNP
VU5UPXkKIyBDT05GSUdfUkVGQ09VTlRfRlVMTCBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0FSQ0hf
UFJFTDMyX1JFTE9DQVRJT05TPXkKQ09ORklHX0FSQ0hfVVNFX01FTVJFTUFQX1BST1Q9eQojIENP
TkZJR19MT0NLX0VWRU5UX0NPVU5UUyBpcyBub3Qgc2V0CgojCiMgR0NPVi1iYXNlZCBrZXJuZWwg
cHJvZmlsaW5nCiMKIyBDT05GSUdfR0NPVl9LRVJORUwgaXMgbm90IHNldApDT05GSUdfQVJDSF9I
QVNfR0NPVl9QUk9GSUxFX0FMTD15CiMgZW5kIG9mIEdDT1YtYmFzZWQga2VybmVsIHByb2ZpbGlu
ZwoKQ09ORklHX1BMVUdJTl9IT1NUQ0M9IiIKQ09ORklHX0hBVkVfR0NDX1BMVUdJTlM9eQojIGVu
ZCBvZiBHZW5lcmFsIGFyY2hpdGVjdHVyZS1kZXBlbmRlbnQgb3B0aW9ucwoKQ09ORklHX1JUX01V
VEVYRVM9eQpDT05GSUdfQkFTRV9TTUFMTD0wCkNPTkZJR19NT0RVTEVTPXkKIyBDT05GSUdfTU9E
VUxFX0ZPUkNFX0xPQUQgaXMgbm90IHNldApDT05GSUdfTU9EVUxFX1VOTE9BRD15CkNPTkZJR19N
T0RVTEVfRk9SQ0VfVU5MT0FEPXkKIyBDT05GSUdfTU9EVkVSU0lPTlMgaXMgbm90IHNldAojIENP
TkZJR19NT0RVTEVfU1JDVkVSU0lPTl9BTEwgaXMgbm90IHNldAojIENPTkZJR19NT0RVTEVfU0lH
IGlzIG5vdCBzZXQKIyBDT05GSUdfTU9EVUxFX0NPTVBSRVNTIGlzIG5vdCBzZXQKIyBDT05GSUdf
VFJJTV9VTlVTRURfS1NZTVMgaXMgbm90IHNldApDT05GSUdfTU9EVUxFU19UUkVFX0xPT0tVUD15
CkNPTkZJR19CTE9DSz15CkNPTkZJR19CTEtfU0NTSV9SRVFVRVNUPXkKQ09ORklHX0JMS19ERVZf
QlNHPXkKIyBDT05GSUdfQkxLX0RFVl9CU0dMSUIgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVW
X0lOVEVHUklUWSBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfWk9ORUQgaXMgbm90IHNldAoj
IENPTkZJR19CTEtfQ01ETElORV9QQVJTRVIgaXMgbm90IHNldAojIENPTkZJR19CTEtfV0JUIGlz
IG5vdCBzZXQKQ09ORklHX0JMS19ERUJVR19GUz15CiMgQ09ORklHX0JMS19TRURfT1BBTCBpcyBu
b3Qgc2V0CgojCiMgUGFydGl0aW9uIFR5cGVzCiMKIyBDT05GSUdfUEFSVElUSU9OX0FEVkFOQ0VE
IGlzIG5vdCBzZXQKQ09ORklHX01TRE9TX1BBUlRJVElPTj15CkNPTkZJR19FRklfUEFSVElUSU9O
PXkKIyBlbmQgb2YgUGFydGl0aW9uIFR5cGVzCgpDT05GSUdfQkxPQ0tfQ09NUEFUPXkKQ09ORklH
X0JMS19NUV9QQ0k9eQpDT05GSUdfQkxLX01RX1ZJUlRJTz15CkNPTkZJR19CTEtfUE09eQoKIwoj
IElPIFNjaGVkdWxlcnMKIwpDT05GSUdfTVFfSU9TQ0hFRF9ERUFETElORT15CkNPTkZJR19NUV9J
T1NDSEVEX0tZQkVSPXkKIyBDT05GSUdfSU9TQ0hFRF9CRlEgaXMgbm90IHNldAojIGVuZCBvZiBJ
TyBTY2hlZHVsZXJzCgpDT05GSUdfQVNOMT15CkNPTkZJR19JTkxJTkVfU1BJTl9VTkxPQ0tfSVJR
PXkKQ09ORklHX0lOTElORV9SRUFEX1VOTE9DSz15CkNPTkZJR19JTkxJTkVfUkVBRF9VTkxPQ0tf
SVJRPXkKQ09ORklHX0lOTElORV9XUklURV9VTkxPQ0s9eQpDT05GSUdfSU5MSU5FX1dSSVRFX1VO
TE9DS19JUlE9eQpDT05GSUdfQVJDSF9TVVBQT1JUU19BVE9NSUNfUk1XPXkKQ09ORklHX01VVEVY
X1NQSU5fT05fT1dORVI9eQpDT05GSUdfUldTRU1fU1BJTl9PTl9PV05FUj15CkNPTkZJR19MT0NL
X1NQSU5fT05fT1dORVI9eQpDT05GSUdfQVJDSF9VU0VfUVVFVUVEX1NQSU5MT0NLUz15CkNPTkZJ
R19RVUVVRURfU1BJTkxPQ0tTPXkKQ09ORklHX0FSQ0hfVVNFX1FVRVVFRF9SV0xPQ0tTPXkKQ09O
RklHX1FVRVVFRF9SV0xPQ0tTPXkKQ09ORklHX0FSQ0hfSEFTX1NZTkNfQ09SRV9CRUZPUkVfVVNF
Uk1PREU9eQpDT05GSUdfQVJDSF9IQVNfU1lTQ0FMTF9XUkFQUEVSPXkKQ09ORklHX0ZSRUVaRVI9
eQoKIwojIEV4ZWN1dGFibGUgZmlsZSBmb3JtYXRzCiMKQ09ORklHX0JJTkZNVF9FTEY9eQpDT05G
SUdfQ09NUEFUX0JJTkZNVF9FTEY9eQpDT05GSUdfRUxGQ09SRT15CkNPTkZJR19DT1JFX0RVTVBf
REVGQVVMVF9FTEZfSEVBREVSUz15CkNPTkZJR19CSU5GTVRfU0NSSVBUPXkKQ09ORklHX0JJTkZN
VF9NSVNDPXkKQ09ORklHX0NPUkVEVU1QPXkKIyBlbmQgb2YgRXhlY3V0YWJsZSBmaWxlIGZvcm1h
dHMKCiMKIyBNZW1vcnkgTWFuYWdlbWVudCBvcHRpb25zCiMKQ09ORklHX1NFTEVDVF9NRU1PUllf
TU9ERUw9eQpDT05GSUdfU1BBUlNFTUVNX01BTlVBTD15CkNPTkZJR19TUEFSU0VNRU09eQpDT05G
SUdfTkVFRF9NVUxUSVBMRV9OT0RFUz15CkNPTkZJR19IQVZFX01FTU9SWV9QUkVTRU5UPXkKQ09O
RklHX1NQQVJTRU1FTV9FWFRSRU1FPXkKQ09ORklHX1NQQVJTRU1FTV9WTUVNTUFQX0VOQUJMRT15
CkNPTkZJR19TUEFSU0VNRU1fVk1FTU1BUD15CkNPTkZJR19IQVZFX01FTUJMT0NLX05PREVfTUFQ
PXkKQ09ORklHX0hBVkVfRkFTVF9HVVA9eQojIENPTkZJR19NRU1PUllfSE9UUExVRyBpcyBub3Qg
c2V0CkNPTkZJR19TUExJVF9QVExPQ0tfQ1BVUz00CkNPTkZJR19DT01QQUNUSU9OPXkKQ09ORklH
X01JR1JBVElPTj15CkNPTkZJR19QSFlTX0FERFJfVF82NEJJVD15CkNPTkZJR19CT1VOQ0U9eQpD
T05GSUdfVklSVF9UT19CVVM9eQpDT05GSUdfTU1VX05PVElGSUVSPXkKIyBDT05GSUdfS1NNIGlz
IG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfTU1BUF9NSU5fQUREUj00MDk2CkNPTkZJR19BUkNIX1NV
UFBPUlRTX01FTU9SWV9GQUlMVVJFPXkKIyBDT05GSUdfTUVNT1JZX0ZBSUxVUkUgaXMgbm90IHNl
dAojIENPTkZJR19UUkFOU1BBUkVOVF9IVUdFUEFHRSBpcyBub3Qgc2V0CkNPTkZJR19BUkNIX1dB
TlRTX1RIUF9TV0FQPXkKIyBDT05GSUdfQ0xFQU5DQUNIRSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZS
T05UU1dBUCBpcyBub3Qgc2V0CiMgQ09ORklHX0NNQSBpcyBub3Qgc2V0CiMgQ09ORklHX1pQT09M
IGlzIG5vdCBzZXQKIyBDT05GSUdfWkJVRCBpcyBub3Qgc2V0CiMgQ09ORklHX1pTTUFMTE9DIGlz
IG5vdCBzZXQKQ09ORklHX0dFTkVSSUNfRUFSTFlfSU9SRU1BUD15CiMgQ09ORklHX0RFRkVSUkVE
X1NUUlVDVF9QQUdFX0lOSVQgaXMgbm90IHNldAojIENPTkZJR19JRExFX1BBR0VfVFJBQ0tJTkcg
aXMgbm90IHNldApDT05GSUdfQVJDSF9IQVNfUFRFX0RFVk1BUD15CiMgQ09ORklHX0hNTV9NSVJS
T1IgaXMgbm90IHNldApDT05GSUdfQVJDSF9VU0VTX0hJR0hfVk1BX0ZMQUdTPXkKQ09ORklHX0FS
Q0hfSEFTX1BLRVlTPXkKIyBDT05GSUdfUEVSQ1BVX1NUQVRTIGlzIG5vdCBzZXQKIyBDT05GSUdf
R1VQX0JFTkNITUFSSyBpcyBub3Qgc2V0CkNPTkZJR19BUkNIX0hBU19QVEVfU1BFQ0lBTD15CiMg
ZW5kIG9mIE1lbW9yeSBNYW5hZ2VtZW50IG9wdGlvbnMKCkNPTkZJR19ORVQ9eQpDT05GSUdfTkVU
X0lOR1JFU1M9eQpDT05GSUdfU0tCX0VYVEVOU0lPTlM9eQoKIwojIE5ldHdvcmtpbmcgb3B0aW9u
cwojCkNPTkZJR19QQUNLRVQ9eQojIENPTkZJR19QQUNLRVRfRElBRyBpcyBub3Qgc2V0CkNPTkZJ
R19VTklYPXkKQ09ORklHX1VOSVhfU0NNPXkKIyBDT05GSUdfVU5JWF9ESUFHIGlzIG5vdCBzZXQK
IyBDT05GSUdfVExTIGlzIG5vdCBzZXQKQ09ORklHX1hGUk09eQpDT05GSUdfWEZSTV9BTEdPPXkK
Q09ORklHX1hGUk1fVVNFUj15CiMgQ09ORklHX1hGUk1fSU5URVJGQUNFIGlzIG5vdCBzZXQKIyBD
T05GSUdfWEZSTV9TVUJfUE9MSUNZIGlzIG5vdCBzZXQKIyBDT05GSUdfWEZSTV9NSUdSQVRFIGlz
IG5vdCBzZXQKIyBDT05GSUdfWEZSTV9TVEFUSVNUSUNTIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVU
X0tFWSBpcyBub3Qgc2V0CkNPTkZJR19JTkVUPXkKQ09ORklHX0lQX01VTFRJQ0FTVD15CkNPTkZJ
R19JUF9BRFZBTkNFRF9ST1VURVI9eQojIENPTkZJR19JUF9GSUJfVFJJRV9TVEFUUyBpcyBub3Qg
c2V0CkNPTkZJR19JUF9NVUxUSVBMRV9UQUJMRVM9eQpDT05GSUdfSVBfUk9VVEVfTVVMVElQQVRI
PXkKQ09ORklHX0lQX1JPVVRFX1ZFUkJPU0U9eQpDT05GSUdfSVBfUE5QPXkKQ09ORklHX0lQX1BO
UF9ESENQPXkKQ09ORklHX0lQX1BOUF9CT09UUD15CkNPTkZJR19JUF9QTlBfUkFSUD15CiMgQ09O
RklHX05FVF9JUElQIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0lQR1JFX0RFTVVYIGlzIG5vdCBz
ZXQKQ09ORklHX05FVF9JUF9UVU5ORUw9eQpDT05GSUdfSVBfTVJPVVRFX0NPTU1PTj15CkNPTkZJ
R19JUF9NUk9VVEU9eQojIENPTkZJR19JUF9NUk9VVEVfTVVMVElQTEVfVEFCTEVTIGlzIG5vdCBz
ZXQKQ09ORklHX0lQX1BJTVNNX1YxPXkKQ09ORklHX0lQX1BJTVNNX1YyPXkKQ09ORklHX1NZTl9D
T09LSUVTPXkKIyBDT05GSUdfTkVUX0lQVlRJIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0ZPVSBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9GT1VfSVBfVFVOTkVMUyBpcyBub3Qgc2V0CiMgQ09ORklH
X0lORVRfQUggaXMgbm90IHNldAojIENPTkZJR19JTkVUX0VTUCBpcyBub3Qgc2V0CiMgQ09ORklH
X0lORVRfSVBDT01QIGlzIG5vdCBzZXQKQ09ORklHX0lORVRfVFVOTkVMPXkKIyBDT05GSUdfSU5F
VF9ESUFHIGlzIG5vdCBzZXQKQ09ORklHX1RDUF9DT05HX0FEVkFOQ0VEPXkKIyBDT05GSUdfVENQ
X0NPTkdfQklDIGlzIG5vdCBzZXQKQ09ORklHX1RDUF9DT05HX0NVQklDPXkKIyBDT05GSUdfVENQ
X0NPTkdfV0VTVFdPT0QgaXMgbm90IHNldAojIENPTkZJR19UQ1BfQ09OR19IVENQIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVENQX0NPTkdfSFNUQ1AgaXMgbm90IHNldAojIENPTkZJR19UQ1BfQ09OR19I
WUJMQSBpcyBub3Qgc2V0CiMgQ09ORklHX1RDUF9DT05HX1ZFR0FTIGlzIG5vdCBzZXQKIyBDT05G
SUdfVENQX0NPTkdfTlYgaXMgbm90IHNldAojIENPTkZJR19UQ1BfQ09OR19TQ0FMQUJMRSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1RDUF9DT05HX0xQIGlzIG5vdCBzZXQKIyBDT05GSUdfVENQX0NPTkdf
VkVOTyBpcyBub3Qgc2V0CiMgQ09ORklHX1RDUF9DT05HX1lFQUggaXMgbm90IHNldAojIENPTkZJ
R19UQ1BfQ09OR19JTExJTk9JUyBpcyBub3Qgc2V0CiMgQ09ORklHX1RDUF9DT05HX0RDVENQIGlz
IG5vdCBzZXQKIyBDT05GSUdfVENQX0NPTkdfQ0RHIGlzIG5vdCBzZXQKIyBDT05GSUdfVENQX0NP
TkdfQkJSIGlzIG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfQ1VCSUM9eQojIENPTkZJR19ERUZBVUxU
X1JFTk8gaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9UQ1BfQ09ORz0iY3ViaWMiCkNPTkZJR19U
Q1BfTUQ1U0lHPXkKQ09ORklHX0lQVjY9eQojIENPTkZJR19JUFY2X1JPVVRFUl9QUkVGIGlzIG5v
dCBzZXQKIyBDT05GSUdfSVBWNl9PUFRJTUlTVElDX0RBRCBpcyBub3Qgc2V0CkNPTkZJR19JTkVU
Nl9BSD15CkNPTkZJR19JTkVUNl9FU1A9eQojIENPTkZJR19JTkVUNl9FU1BfT0ZGTE9BRCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lORVQ2X0lQQ09NUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfTUlQ
NiBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfSUxBIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBWNl9W
VEkgaXMgbm90IHNldApDT05GSUdfSVBWNl9TSVQ9eQojIENPTkZJR19JUFY2X1NJVF82UkQgaXMg
bm90IHNldApDT05GSUdfSVBWNl9ORElTQ19OT0RFVFlQRT15CiMgQ09ORklHX0lQVjZfVFVOTkVM
IGlzIG5vdCBzZXQKIyBDT05GSUdfSVBWNl9NVUxUSVBMRV9UQUJMRVMgaXMgbm90IHNldAojIENP
TkZJR19JUFY2X01ST1VURSBpcyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfU0VHNl9MV1RVTk5FTCBp
cyBub3Qgc2V0CiMgQ09ORklHX0lQVjZfU0VHNl9ITUFDIGlzIG5vdCBzZXQKQ09ORklHX05FVExB
QkVMPXkKQ09ORklHX05FVFdPUktfU0VDTUFSSz15CkNPTkZJR19ORVRfUFRQX0NMQVNTSUZZPXkK
IyBDT05GSUdfTkVUV09SS19QSFlfVElNRVNUQU1QSU5HIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJ
TFRFUj15CiMgQ09ORklHX05FVEZJTFRFUl9BRFZBTkNFRCBpcyBub3Qgc2V0CgojCiMgQ29yZSBO
ZXRmaWx0ZXIgQ29uZmlndXJhdGlvbgojCkNPTkZJR19ORVRGSUxURVJfSU5HUkVTUz15CkNPTkZJ
R19ORVRGSUxURVJfTkVUTElOSz15CkNPTkZJR19ORVRGSUxURVJfTkVUTElOS19MT0c9eQpDT05G
SUdfTkZfQ09OTlRSQUNLPXkKQ09ORklHX05GX0xPR19DT01NT049bQojIENPTkZJR19ORl9MT0df
TkVUREVWIGlzIG5vdCBzZXQKQ09ORklHX05GX0NPTk5UUkFDS19TRUNNQVJLPXkKQ09ORklHX05G
X0NPTk5UUkFDS19QUk9DRlM9eQojIENPTkZJR19ORl9DT05OVFJBQ0tfTEFCRUxTIGlzIG5vdCBz
ZXQKQ09ORklHX05GX0NPTk5UUkFDS19GVFA9eQpDT05GSUdfTkZfQ09OTlRSQUNLX0lSQz15CiMg
Q09ORklHX05GX0NPTk5UUkFDS19ORVRCSU9TX05TIGlzIG5vdCBzZXQKQ09ORklHX05GX0NPTk5U
UkFDS19TSVA9eQpDT05GSUdfTkZfQ1RfTkVUTElOSz15CiMgQ09ORklHX05FVEZJTFRFUl9ORVRM
SU5LX0dMVUVfQ1QgaXMgbm90IHNldApDT05GSUdfTkZfTkFUPXkKQ09ORklHX05GX05BVF9GVFA9
eQpDT05GSUdfTkZfTkFUX0lSQz15CkNPTkZJR19ORl9OQVRfU0lQPXkKQ09ORklHX05GX05BVF9N
QVNRVUVSQURFPXkKIyBDT05GSUdfTkZfVEFCTEVTIGlzIG5vdCBzZXQKQ09ORklHX05FVEZJTFRF
Ul9YVEFCTEVTPXkKCiMKIyBYdGFibGVzIGNvbWJpbmVkIG1vZHVsZXMKIwpDT05GSUdfTkVURklM
VEVSX1hUX01BUks9bQoKIwojIFh0YWJsZXMgdGFyZ2V0cwojCkNPTkZJR19ORVRGSUxURVJfWFRf
VEFSR0VUX0NPTk5TRUNNQVJLPXkKQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfTE9HPW0KQ09O
RklHX05FVEZJTFRFUl9YVF9OQVQ9bQojIENPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX05FVE1B
UCBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX05GTE9HPXkKIyBDT05GSUdf
TkVURklMVEVSX1hUX1RBUkdFVF9SRURJUkVDVCBpcyBub3Qgc2V0CkNPTkZJR19ORVRGSUxURVJf
WFRfVEFSR0VUX01BU1FVRVJBREU9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9TRUNNQVJL
PXkKQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVENQTVNTPXkKCiMKIyBYdGFibGVzIG1hdGNo
ZXMKIwpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0FERFJUWVBFPW0KQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9DT05OVFJBQ0s9eQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1BPTElDWT15
CkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfU1RBVEU9eQojIGVuZCBvZiBDb3JlIE5ldGZpbHRl
ciBDb25maWd1cmF0aW9uCgojIENPTkZJR19JUF9TRVQgaXMgbm90IHNldAojIENPTkZJR19JUF9W
UyBpcyBub3Qgc2V0CgojCiMgSVA6IE5ldGZpbHRlciBDb25maWd1cmF0aW9uCiMKQ09ORklHX05G
X0RFRlJBR19JUFY0PXkKIyBDT05GSUdfTkZfU09DS0VUX0lQVjQgaXMgbm90IHNldAojIENPTkZJ
R19ORl9UUFJPWFlfSVBWNCBpcyBub3Qgc2V0CiMgQ09ORklHX05GX0RVUF9JUFY0IGlzIG5vdCBz
ZXQKQ09ORklHX05GX0xPR19BUlA9bQpDT05GSUdfTkZfTE9HX0lQVjQ9bQpDT05GSUdfTkZfUkVK
RUNUX0lQVjQ9eQpDT05GSUdfSVBfTkZfSVBUQUJMRVM9eQpDT05GSUdfSVBfTkZfRklMVEVSPXkK
Q09ORklHX0lQX05GX1RBUkdFVF9SRUpFQ1Q9eQpDT05GSUdfSVBfTkZfTkFUPW0KQ09ORklHX0lQ
X05GX1RBUkdFVF9NQVNRVUVSQURFPW0KQ09ORklHX0lQX05GX01BTkdMRT15CiMgQ09ORklHX0lQ
X05GX1JBVyBpcyBub3Qgc2V0CiMgZW5kIG9mIElQOiBOZXRmaWx0ZXIgQ29uZmlndXJhdGlvbgoK
IwojIElQdjY6IE5ldGZpbHRlciBDb25maWd1cmF0aW9uCiMKIyBDT05GSUdfTkZfU09DS0VUX0lQ
VjYgaXMgbm90IHNldAojIENPTkZJR19ORl9UUFJPWFlfSVBWNiBpcyBub3Qgc2V0CiMgQ09ORklH
X05GX0RVUF9JUFY2IGlzIG5vdCBzZXQKQ09ORklHX05GX1JFSkVDVF9JUFY2PXkKQ09ORklHX05G
X0xPR19JUFY2PW0KQ09ORklHX0lQNl9ORl9JUFRBQkxFUz15CkNPTkZJR19JUDZfTkZfTUFUQ0hf
SVBWNkhFQURFUj15CkNPTkZJR19JUDZfTkZfRklMVEVSPXkKQ09ORklHX0lQNl9ORl9UQVJHRVRf
UkVKRUNUPXkKQ09ORklHX0lQNl9ORl9NQU5HTEU9eQojIENPTkZJR19JUDZfTkZfUkFXIGlzIG5v
dCBzZXQKIyBlbmQgb2YgSVB2NjogTmV0ZmlsdGVyIENvbmZpZ3VyYXRpb24KCkNPTkZJR19ORl9E
RUZSQUdfSVBWNj15CiMgQ09ORklHX05GX0NPTk5UUkFDS19CUklER0UgaXMgbm90IHNldAojIENP
TkZJR19CUEZJTFRFUiBpcyBub3Qgc2V0CiMgQ09ORklHX0lQX0RDQ1AgaXMgbm90IHNldAojIENP
TkZJR19JUF9TQ1RQIGlzIG5vdCBzZXQKIyBDT05GSUdfUkRTIGlzIG5vdCBzZXQKIyBDT05GSUdf
VElQQyBpcyBub3Qgc2V0CiMgQ09ORklHX0FUTSBpcyBub3Qgc2V0CiMgQ09ORklHX0wyVFAgaXMg
bm90IHNldAojIENPTkZJR19CUklER0UgaXMgbm90IHNldApDT05GSUdfSEFWRV9ORVRfRFNBPXkK
IyBDT05GSUdfTkVUX0RTQSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZMQU5fODAyMVEgaXMgbm90IHNl
dAojIENPTkZJR19ERUNORVQgaXMgbm90IHNldAojIENPTkZJR19MTEMyIGlzIG5vdCBzZXQKIyBD
T05GSUdfQVRBTEsgaXMgbm90IHNldAojIENPTkZJR19YMjUgaXMgbm90IHNldAojIENPTkZJR19M
QVBCIGlzIG5vdCBzZXQKIyBDT05GSUdfUEhPTkVUIGlzIG5vdCBzZXQKIyBDT05GSUdfNkxPV1BB
TiBpcyBub3Qgc2V0CiMgQ09ORklHX0lFRUU4MDIxNTQgaXMgbm90IHNldApDT05GSUdfTkVUX1ND
SEVEPXkKCiMKIyBRdWV1ZWluZy9TY2hlZHVsaW5nCiMKIyBDT05GSUdfTkVUX1NDSF9DQlEgaXMg
bm90IHNldAojIENPTkZJR19ORVRfU0NIX0hUQiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hf
SEZTQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfUFJJTyBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9TQ0hfTVVMVElRIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9SRUQgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfU0NIX1NGQiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfU0ZRIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9URVFMIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ND
SF9UQkYgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIX0NCUyBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9TQ0hfRVRGIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9UQVBSSU8gaXMgbm90IHNl
dAojIENPTkZJR19ORVRfU0NIX0dSRUQgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIX0RTTUFS
SyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfTkVURU0gaXMgbm90IHNldAojIENPTkZJR19O
RVRfU0NIX0RSUiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfTVFQUklPIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkVUX1NDSF9TS0JQUklPIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9DSE9L
RSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfUUZRIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVU
X1NDSF9DT0RFTCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfRlFfQ09ERUwgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfU0NIX0NBS0UgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NIX0ZRIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1NDSF9ISEYgaXMgbm90IHNldAojIENPTkZJR19ORVRfU0NI
X1BJRSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfSU5HUkVTUyBpcyBub3Qgc2V0CiMgQ09O
RklHX05FVF9TQ0hfUExVRyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9TQ0hfREVGQVVMVCBpcyBu
b3Qgc2V0CgojCiMgQ2xhc3NpZmljYXRpb24KIwpDT05GSUdfTkVUX0NMUz15CiMgQ09ORklHX05F
VF9DTFNfQkFTSUMgaXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX1RDSU5ERVggaXMgbm90IHNl
dAojIENPTkZJR19ORVRfQ0xTX1JPVVRFNCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9DTFNfRlcg
aXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX1UzMiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9D
TFNfUlNWUCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9DTFNfUlNWUDYgaXMgbm90IHNldAojIENP
TkZJR19ORVRfQ0xTX0ZMT1cgaXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX0NHUk9VUCBpcyBu
b3Qgc2V0CiMgQ09ORklHX05FVF9DTFNfQlBGIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0NMU19G
TE9XRVIgaXMgbm90IHNldAojIENPTkZJR19ORVRfQ0xTX01BVENIQUxMIGlzIG5vdCBzZXQKQ09O
RklHX05FVF9FTUFUQ0g9eQpDT05GSUdfTkVUX0VNQVRDSF9TVEFDSz0zMgojIENPTkZJR19ORVRf
RU1BVENIX0NNUCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9FTUFUQ0hfTkJZVEUgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfRU1BVENIX1UzMiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9FTUFUQ0hf
TUVUQSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9FTUFUQ0hfVEVYVCBpcyBub3Qgc2V0CiMgQ09O
RklHX05FVF9FTUFUQ0hfSVBUIGlzIG5vdCBzZXQKQ09ORklHX05FVF9DTFNfQUNUPXkKIyBDT05G
SUdfTkVUX0FDVF9QT0xJQ0UgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX0dBQ1QgaXMgbm90
IHNldAojIENPTkZJR19ORVRfQUNUX01JUlJFRCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9BQ1Rf
U0FNUExFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0FDVF9JUFQgaXMgbm90IHNldAojIENPTkZJ
R19ORVRfQUNUX05BVCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9BQ1RfUEVESVQgaXMgbm90IHNl
dAojIENPTkZJR19ORVRfQUNUX1NJTVAgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX1NLQkVE
SVQgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX0NTVU0gaXMgbm90IHNldAojIENPTkZJR19O
RVRfQUNUX01QTFMgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX1ZMQU4gaXMgbm90IHNldAoj
IENPTkZJR19ORVRfQUNUX0JQRiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9BQ1RfU0tCTU9EIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX0FDVF9JRkUgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNU
X1RVTk5FTF9LRVkgaXMgbm90IHNldAojIENPTkZJR19ORVRfQUNUX0NUIGlzIG5vdCBzZXQKQ09O
RklHX05FVF9TQ0hfRklGTz15CiMgQ09ORklHX0RDQiBpcyBub3Qgc2V0CkNPTkZJR19ETlNfUkVT
T0xWRVI9eQojIENPTkZJR19CQVRNQU5fQURWIGlzIG5vdCBzZXQKIyBDT05GSUdfT1BFTlZTV0lU
Q0ggaXMgbm90IHNldAojIENPTkZJR19WU09DS0VUUyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVExJ
TktfRElBRyBpcyBub3Qgc2V0CiMgQ09ORklHX01QTFMgaXMgbm90IHNldAojIENPTkZJR19ORVRf
TlNIIGlzIG5vdCBzZXQKIyBDT05GSUdfSFNSIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NXSVRD
SERFViBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9MM19NQVNURVJfREVWIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkVUX05DU0kgaXMgbm90IHNldApDT05GSUdfUlBTPXkKQ09ORklHX1JGU19BQ0NFTD15
CkNPTkZJR19YUFM9eQojIENPTkZJR19DR1JPVVBfTkVUX1BSSU8gaXMgbm90IHNldAojIENPTkZJ
R19DR1JPVVBfTkVUX0NMQVNTSUQgaXMgbm90IHNldApDT05GSUdfTkVUX1JYX0JVU1lfUE9MTD15
CkNPTkZJR19CUUw9eQojIENPTkZJR19CUEZfSklUIGlzIG5vdCBzZXQKQ09ORklHX05FVF9GTE9X
X0xJTUlUPXkKCiMKIyBOZXR3b3JrIHRlc3RpbmcKIwojIENPTkZJR19ORVRfUEtUR0VOIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX0RST1BfTU9OSVRPUiBpcyBub3Qgc2V0CiMgZW5kIG9mIE5ldHdv
cmsgdGVzdGluZwojIGVuZCBvZiBOZXR3b3JraW5nIG9wdGlvbnMKCkNPTkZJR19IQU1SQURJTz15
CgojCiMgUGFja2V0IFJhZGlvIHByb3RvY29scwojCiMgQ09ORklHX0FYMjUgaXMgbm90IHNldAoj
IENPTkZJR19DQU4gaXMgbm90IHNldAojIENPTkZJR19CVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FG
X1JYUlBDIGlzIG5vdCBzZXQKIyBDT05GSUdfQUZfS0NNIGlzIG5vdCBzZXQKQ09ORklHX0ZJQl9S
VUxFUz15CkNPTkZJR19XSVJFTEVTUz15CkNPTkZJR19DRkc4MDIxMT15CiMgQ09ORklHX05MODAy
MTFfVEVTVE1PREUgaXMgbm90IHNldAojIENPTkZJR19DRkc4MDIxMV9ERVZFTE9QRVJfV0FSTklO
R1MgaXMgbm90IHNldApDT05GSUdfQ0ZHODAyMTFfUkVRVUlSRV9TSUdORURfUkVHREI9eQpDT05G
SUdfQ0ZHODAyMTFfVVNFX0tFUk5FTF9SRUdEQl9LRVlTPXkKQ09ORklHX0NGRzgwMjExX0RFRkFV
TFRfUFM9eQojIENPTkZJR19DRkc4MDIxMV9ERUJVR0ZTIGlzIG5vdCBzZXQKQ09ORklHX0NGRzgw
MjExX0NSREFfU1VQUE9SVD15CiMgQ09ORklHX0NGRzgwMjExX1dFWFQgaXMgbm90IHNldApDT05G
SUdfTUFDODAyMTE9eQpDT05GSUdfTUFDODAyMTFfSEFTX1JDPXkKQ09ORklHX01BQzgwMjExX1JD
X01JTlNUUkVMPXkKQ09ORklHX01BQzgwMjExX1JDX0RFRkFVTFRfTUlOU1RSRUw9eQpDT05GSUdf
TUFDODAyMTFfUkNfREVGQVVMVD0ibWluc3RyZWxfaHQiCiMgQ09ORklHX01BQzgwMjExX01FU0gg
aXMgbm90IHNldApDT05GSUdfTUFDODAyMTFfTEVEUz15CiMgQ09ORklHX01BQzgwMjExX0RFQlVH
RlMgaXMgbm90IHNldAojIENPTkZJR19NQUM4MDIxMV9NRVNTQUdFX1RSQUNJTkcgaXMgbm90IHNl
dAojIENPTkZJR19NQUM4MDIxMV9ERUJVR19NRU5VIGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjEx
X1NUQV9IQVNIX01BWF9TSVpFPTAKIyBDT05GSUdfV0lNQVggaXMgbm90IHNldApDT05GSUdfUkZL
SUxMPXkKQ09ORklHX1JGS0lMTF9MRURTPXkKQ09ORklHX1JGS0lMTF9JTlBVVD15CkNPTkZJR19O
RVRfOVA9eQpDT05GSUdfTkVUXzlQX1ZJUlRJTz15CiMgQ09ORklHX05FVF85UF9ERUJVRyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NBSUYgaXMgbm90IHNldAojIENPTkZJR19DRVBIX0xJQiBpcyBub3Qg
c2V0CiMgQ09ORklHX05GQyBpcyBub3Qgc2V0CiMgQ09ORklHX1BTQU1QTEUgaXMgbm90IHNldAoj
IENPTkZJR19ORVRfSUZFIGlzIG5vdCBzZXQKIyBDT05GSUdfTFdUVU5ORUwgaXMgbm90IHNldApD
T05GSUdfRFNUX0NBQ0hFPXkKQ09ORklHX0dST19DRUxMUz15CkNPTkZJR19GQUlMT1ZFUj15CkNP
TkZJR19IQVZFX0VCUEZfSklUPXkKCiMKIyBEZXZpY2UgRHJpdmVycwojCkNPTkZJR19IQVZFX0VJ
U0E9eQojIENPTkZJR19FSVNBIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfUENJPXkKQ09ORklHX1BD
ST15CkNPTkZJR19QQ0lfRE9NQUlOUz15CkNPTkZJR19QQ0lFUE9SVEJVUz15CiMgQ09ORklHX0hP
VFBMVUdfUENJX1BDSUUgaXMgbm90IHNldApDT05GSUdfUENJRUFFUj15CiMgQ09ORklHX1BDSUVB
RVJfSU5KRUNUIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJRV9FQ1JDIGlzIG5vdCBzZXQKQ09ORklH
X1BDSUVBU1BNPXkKIyBDT05GSUdfUENJRUFTUE1fREVCVUcgaXMgbm90IHNldApDT05GSUdfUENJ
RUFTUE1fREVGQVVMVD15CiMgQ09ORklHX1BDSUVBU1BNX1BPV0VSU0FWRSBpcyBub3Qgc2V0CiMg
Q09ORklHX1BDSUVBU1BNX1BPV0VSX1NVUEVSU0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX1BDSUVB
U1BNX1BFUkZPUk1BTkNFIGlzIG5vdCBzZXQKQ09ORklHX1BDSUVfUE1FPXkKIyBDT05GSUdfUENJ
RV9EUEMgaXMgbm90IHNldAojIENPTkZJR19QQ0lFX1BUTSBpcyBub3Qgc2V0CiMgQ09ORklHX1BD
SUVfQlcgaXMgbm90IHNldApDT05GSUdfUENJX01TST15CkNPTkZJR19QQ0lfTVNJX0lSUV9ET01B
SU49eQpDT05GSUdfUENJX1FVSVJLUz15CiMgQ09ORklHX1BDSV9ERUJVRyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BDSV9TVFVCIGlzIG5vdCBzZXQKQ09ORklHX1BDSV9BVFM9eQpDT05GSUdfUENJX0xP
Q0tMRVNTX0NPTkZJRz15CiMgQ09ORklHX1BDSV9JT1YgaXMgbm90IHNldApDT05GSUdfUENJX1BS
ST15CkNPTkZJR19QQ0lfUEFTSUQ9eQpDT05GSUdfUENJX0xBQkVMPXkKQ09ORklHX0hPVFBMVUdf
UENJPXkKIyBDT05GSUdfSE9UUExVR19QQ0lfQUNQSSBpcyBub3Qgc2V0CiMgQ09ORklHX0hPVFBM
VUdfUENJX0NQQ0kgaXMgbm90IHNldAojIENPTkZJR19IT1RQTFVHX1BDSV9TSFBDIGlzIG5vdCBz
ZXQKCiMKIyBQQ0kgY29udHJvbGxlciBkcml2ZXJzCiMKCiMKIyBDYWRlbmNlIFBDSWUgY29udHJv
bGxlcnMgc3VwcG9ydAojCiMgZW5kIG9mIENhZGVuY2UgUENJZSBjb250cm9sbGVycyBzdXBwb3J0
CgojIENPTkZJR19WTUQgaXMgbm90IHNldAoKIwojIERlc2lnbldhcmUgUENJIENvcmUgU3VwcG9y
dAojCiMgQ09ORklHX1BDSUVfRFdfUExBVF9IT1NUIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJX01F
U09OIGlzIG5vdCBzZXQKIyBlbmQgb2YgRGVzaWduV2FyZSBQQ0kgQ29yZSBTdXBwb3J0CiMgZW5k
IG9mIFBDSSBjb250cm9sbGVyIGRyaXZlcnMKCiMKIyBQQ0kgRW5kcG9pbnQKIwojIENPTkZJR19Q
Q0lfRU5EUE9JTlQgaXMgbm90IHNldAojIGVuZCBvZiBQQ0kgRW5kcG9pbnQKCiMKIyBQQ0kgc3dp
dGNoIGNvbnRyb2xsZXIgZHJpdmVycwojCiMgQ09ORklHX1BDSV9TV19TV0lUQ0hURUMgaXMgbm90
IHNldAojIGVuZCBvZiBQQ0kgc3dpdGNoIGNvbnRyb2xsZXIgZHJpdmVycwoKQ09ORklHX1BDQ0FS
RD15CkNPTkZJR19QQ01DSUE9eQpDT05GSUdfUENNQ0lBX0xPQURfQ0lTPXkKQ09ORklHX0NBUkRC
VVM9eQoKIwojIFBDLWNhcmQgYnJpZGdlcwojCkNPTkZJR19ZRU5UQT15CkNPTkZJR19ZRU5UQV9P
Mj15CkNPTkZJR19ZRU5UQV9SSUNPSD15CkNPTkZJR19ZRU5UQV9UST15CkNPTkZJR19ZRU5UQV9F
TkVfVFVORT15CkNPTkZJR19ZRU5UQV9UT1NISUJBPXkKIyBDT05GSUdfUEQ2NzI5IGlzIG5vdCBz
ZXQKIyBDT05GSUdfSTgyMDkyIGlzIG5vdCBzZXQKQ09ORklHX1BDQ0FSRF9OT05TVEFUSUM9eQoj
IENPTkZJR19SQVBJRElPIGlzIG5vdCBzZXQKCiMKIyBHZW5lcmljIERyaXZlciBPcHRpb25zCiMK
IyBDT05GSUdfVUVWRU5UX0hFTFBFUiBpcyBub3Qgc2V0CkNPTkZJR19ERVZUTVBGUz15CkNPTkZJ
R19ERVZUTVBGU19NT1VOVD15CkNPTkZJR19TVEFOREFMT05FPXkKQ09ORklHX1BSRVZFTlRfRklS
TVdBUkVfQlVJTEQ9eQoKIwojIEZpcm13YXJlIGxvYWRlcgojCkNPTkZJR19GV19MT0FERVI9eQpD
T05GSUdfRVhUUkFfRklSTVdBUkU9IiIKIyBDT05GSUdfRldfTE9BREVSX1VTRVJfSEVMUEVSIGlz
IG5vdCBzZXQKIyBDT05GSUdfRldfTE9BREVSX0NPTVBSRVNTIGlzIG5vdCBzZXQKIyBlbmQgb2Yg
RmlybXdhcmUgbG9hZGVyCgpDT05GSUdfQUxMT1dfREVWX0NPUkVEVU1QPXkKIyBDT05GSUdfREVC
VUdfRFJJVkVSIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX0RFVlJFUz15CiMgQ09ORklHX0RFQlVH
X1RFU1RfRFJJVkVSX1JFTU9WRSBpcyBub3Qgc2V0CkNPTkZJR19URVNUX0FTWU5DX0RSSVZFUl9Q
Uk9CRT1tCkNPTkZJR19HRU5FUklDX0NQVV9BVVRPUFJPQkU9eQpDT05GSUdfR0VORVJJQ19DUFVf
VlVMTkVSQUJJTElUSUVTPXkKQ09ORklHX1JFR01BUD15CkNPTkZJR19SRUdNQVBfSTJDPXkKQ09O
RklHX0RNQV9TSEFSRURfQlVGRkVSPXkKIyBDT05GSUdfRE1BX0ZFTkNFX1RSQUNFIGlzIG5vdCBz
ZXQKIyBlbmQgb2YgR2VuZXJpYyBEcml2ZXIgT3B0aW9ucwoKIwojIEJ1cyBkZXZpY2VzCiMKIyBl
bmQgb2YgQnVzIGRldmljZXMKCkNPTkZJR19DT05ORUNUT1I9eQpDT05GSUdfUFJPQ19FVkVOVFM9
eQojIENPTkZJR19HTlNTIGlzIG5vdCBzZXQKIyBDT05GSUdfTVREIGlzIG5vdCBzZXQKIyBDT05G
SUdfT0YgaXMgbm90IHNldApDT05GSUdfQVJDSF9NSUdIVF9IQVZFX1BDX1BBUlBPUlQ9eQojIENP
TkZJR19QQVJQT1JUIGlzIG5vdCBzZXQKQ09ORklHX1BOUD15CkNPTkZJR19QTlBfREVCVUdfTUVT
U0FHRVM9eQoKIwojIFByb3RvY29scwojCkNPTkZJR19QTlBBQ1BJPXkKQ09ORklHX0JMS19ERVY9
eQojIENPTkZJR19CTEtfREVWX05VTExfQkxLIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9G
RCBpcyBub3Qgc2V0CkNPTkZJR19DRFJPTT15CiMgQ09ORklHX0JMS19ERVZfUENJRVNTRF9NVElQ
MzJYWCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfVU1FTSBpcyBub3Qgc2V0CkNPTkZJR19C
TEtfREVWX0xPT1A9eQpDT05GSUdfQkxLX0RFVl9MT09QX01JTl9DT1VOVD04CiMgQ09ORklHX0JM
S19ERVZfQ1JZUFRPTE9PUCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZfRFJCRCBpcyBub3Qg
c2V0CiMgQ09ORklHX0JMS19ERVZfTkJEIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9TS0Qg
aXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX1NYOCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19E
RVZfUkFNIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0RST01fUEtUQ0RWRCBpcyBub3Qgc2V0CiMgQ09O
RklHX0FUQV9PVkVSX0VUSCBpcyBub3Qgc2V0CkNPTkZJR19WSVJUSU9fQkxLPXkKIyBDT05GSUdf
VklSVElPX0JMS19TQ1NJIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9SQkQgaXMgbm90IHNl
dAojIENPTkZJR19CTEtfREVWX1JTWFggaXMgbm90IHNldAoKIwojIE5WTUUgU3VwcG9ydAojCiMg
Q09ORklHX0JMS19ERVZfTlZNRSBpcyBub3Qgc2V0CiMgQ09ORklHX05WTUVfRkMgaXMgbm90IHNl
dAojIENPTkZJR19OVk1FX1RBUkdFVCBpcyBub3Qgc2V0CiMgZW5kIG9mIE5WTUUgU3VwcG9ydAoK
IwojIE1pc2MgZGV2aWNlcwojCiMgQ09ORklHX0FENTI1WF9EUE9UIGlzIG5vdCBzZXQKIyBDT05G
SUdfRFVNTVlfSVJRIGlzIG5vdCBzZXQKIyBDT05GSUdfSUJNX0FTTSBpcyBub3Qgc2V0CiMgQ09O
RklHX1BIQU5UT00gaXMgbm90IHNldAojIENPTkZJR19TR0lfSU9DNCBpcyBub3Qgc2V0CiMgQ09O
RklHX1RJRk1fQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lDUzkzMlM0MDEgaXMgbm90IHNldAoj
IENPTkZJR19FTkNMT1NVUkVfU0VSVklDRVMgaXMgbm90IHNldAojIENPTkZJR19IUF9JTE8gaXMg
bm90IHNldAojIENPTkZJR19BUERTOTgwMkFMUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lTTDI5MDAz
IGlzIG5vdCBzZXQKIyBDT05GSUdfSVNMMjkwMjAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JT
X1RTTDI1NTAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0JIMTc3MCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfQVBEUzk5MFggaXMgbm90IHNldAojIENPTkZJR19ITUM2MzUyIGlzIG5v
dCBzZXQKIyBDT05GSUdfRFMxNjgyIGlzIG5vdCBzZXQKIyBDT05GSUdfU1JBTSBpcyBub3Qgc2V0
CiMgQ09ORklHX1BDSV9FTkRQT0lOVF9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfWElMSU5YX1NE
RkVDIGlzIG5vdCBzZXQKIyBDT05GSUdfUFZQQU5JQyBpcyBub3Qgc2V0CiMgQ09ORklHX0MyUE9S
VCBpcyBub3Qgc2V0CgojCiMgRUVQUk9NIHN1cHBvcnQKIwojIENPTkZJR19FRVBST01fQVQyNCBp
cyBub3Qgc2V0CiMgQ09ORklHX0VFUFJPTV9MRUdBQ1kgaXMgbm90IHNldAojIENPTkZJR19FRVBS
T01fTUFYNjg3NSBpcyBub3Qgc2V0CiMgQ09ORklHX0VFUFJPTV85M0NYNiBpcyBub3Qgc2V0CiMg
Q09ORklHX0VFUFJPTV9JRFRfODlIUEVTWCBpcyBub3Qgc2V0CiMgQ09ORklHX0VFUFJPTV9FRTEw
MDQgaXMgbm90IHNldAojIGVuZCBvZiBFRVBST00gc3VwcG9ydAoKIyBDT05GSUdfQ0I3MTBfQ09S
RSBpcyBub3Qgc2V0CgojCiMgVGV4YXMgSW5zdHJ1bWVudHMgc2hhcmVkIHRyYW5zcG9ydCBsaW5l
IGRpc2NpcGxpbmUKIwojIGVuZCBvZiBUZXhhcyBJbnN0cnVtZW50cyBzaGFyZWQgdHJhbnNwb3J0
IGxpbmUgZGlzY2lwbGluZQoKIyBDT05GSUdfU0VOU09SU19MSVMzX0kyQyBpcyBub3Qgc2V0CiMg
Q09ORklHX0FMVEVSQV9TVEFQTCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX01FSSBpcyBub3Qg
c2V0CiMgQ09ORklHX0lOVEVMX01FSV9NRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX01FSV9U
WEUgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9NRUlfSERDUCBpcyBub3Qgc2V0CiMgQ09ORklH
X1ZNV0FSRV9WTUNJIGlzIG5vdCBzZXQKCiMKIyBJbnRlbCBNSUMgJiByZWxhdGVkIHN1cHBvcnQK
IwoKIwojIEludGVsIE1JQyBCdXMgRHJpdmVyCiMKIyBDT05GSUdfSU5URUxfTUlDX0JVUyBpcyBu
b3Qgc2V0CgojCiMgU0NJRiBCdXMgRHJpdmVyCiMKIyBDT05GSUdfU0NJRl9CVVMgaXMgbm90IHNl
dAoKIwojIFZPUCBCdXMgRHJpdmVyCiMKIyBDT05GSUdfVk9QX0JVUyBpcyBub3Qgc2V0CgojCiMg
SW50ZWwgTUlDIEhvc3QgRHJpdmVyCiMKCiMKIyBJbnRlbCBNSUMgQ2FyZCBEcml2ZXIKIwoKIwoj
IFNDSUYgRHJpdmVyCiMKCiMKIyBJbnRlbCBNSUMgQ29wcm9jZXNzb3IgU3RhdGUgTWFuYWdlbWVu
dCAoQ09TTSkgRHJpdmVycwojCgojCiMgVk9QIERyaXZlcgojCiMgZW5kIG9mIEludGVsIE1JQyAm
IHJlbGF0ZWQgc3VwcG9ydAoKIyBDT05GSUdfR0VOV1FFIGlzIG5vdCBzZXQKIyBDT05GSUdfRUNI
TyBpcyBub3Qgc2V0CiMgQ09ORklHX01JU0NfQUxDT1JfUENJIGlzIG5vdCBzZXQKIyBDT05GSUdf
TUlTQ19SVFNYX1BDSSBpcyBub3Qgc2V0CiMgQ09ORklHX01JU0NfUlRTWF9VU0IgaXMgbm90IHNl
dAojIENPTkZJR19IQUJBTkFfQUkgaXMgbm90IHNldAojIGVuZCBvZiBNaXNjIGRldmljZXMKCkNP
TkZJR19IQVZFX0lERT15CiMgQ09ORklHX0lERSBpcyBub3Qgc2V0CgojCiMgU0NTSSBkZXZpY2Ug
c3VwcG9ydAojCkNPTkZJR19TQ1NJX01PRD15CiMgQ09ORklHX1JBSURfQVRUUlMgaXMgbm90IHNl
dApDT05GSUdfU0NTST15CkNPTkZJR19TQ1NJX0RNQT15CkNPTkZJR19TQ1NJX1BST0NfRlM9eQoK
IwojIFNDU0kgc3VwcG9ydCB0eXBlIChkaXNrLCB0YXBlLCBDRC1ST00pCiMKQ09ORklHX0JMS19E
RVZfU0Q9eQojIENPTkZJR19DSFJfREVWX1NUIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfU1I9
eQpDT05GSUdfQkxLX0RFVl9TUl9WRU5ET1I9eQpDT05GSUdfQ0hSX0RFVl9TRz15CiMgQ09ORklH
X0NIUl9ERVZfU0NIIGlzIG5vdCBzZXQKQ09ORklHX1NDU0lfQ09OU1RBTlRTPXkKIyBDT05GSUdf
U0NTSV9MT0dHSU5HIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9TQ0FOX0FTWU5DIGlzIG5vdCBz
ZXQKCiMKIyBTQ1NJIFRyYW5zcG9ydHMKIwpDT05GSUdfU0NTSV9TUElfQVRUUlM9eQojIENPTkZJ
R19TQ1NJX0ZDX0FUVFJTIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9JU0NTSV9BVFRSUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NDU0lfU0FTX0FUVFJTIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9T
QVNfTElCU0FTIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9TUlBfQVRUUlMgaXMgbm90IHNldAoj
IGVuZCBvZiBTQ1NJIFRyYW5zcG9ydHMKCkNPTkZJR19TQ1NJX0xPV0xFVkVMPXkKIyBDT05GSUdf
SVNDU0lfVENQIGlzIG5vdCBzZXQKIyBDT05GSUdfSVNDU0lfQk9PVF9TWVNGUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NDU0lfQ1hHQjNfSVNDU0kgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0NYR0I0
X0lTQ1NJIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9CTlgyX0lTQ1NJIGlzIG5vdCBzZXQKIyBD
T05GSUdfQkUySVNDU0kgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWXzNXX1hYWFhfUkFJRCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfSFBTQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfM1df
OVhYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfM1dfU0FTIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0NTSV9BQ0FSRCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfQUFDUkFJRCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NDU0lfQUlDN1hYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfQUlDNzlYWCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NDU0lfQUlDOTRYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfTVZT
QVMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX01WVU1JIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NT
SV9EUFRfSTJPIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9BRFZBTlNZUyBpcyBub3Qgc2V0CiMg
Q09ORklHX1NDU0lfQVJDTVNSIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9FU0FTMlIgaXMgbm90
IHNldAojIENPTkZJR19NRUdBUkFJRF9ORVdHRU4gaXMgbm90IHNldAojIENPTkZJR19NRUdBUkFJ
RF9MRUdBQ1kgaXMgbm90IHNldAojIENPTkZJR19NRUdBUkFJRF9TQVMgaXMgbm90IHNldAojIENP
TkZJR19TQ1NJX01QVDNTQVMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX01QVDJTQVMgaXMgbm90
IHNldAojIENPTkZJR19TQ1NJX1NNQVJUUFFJIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9VRlNI
Q0QgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0hQVElPUCBpcyBub3Qgc2V0CiMgQ09ORklHX1ND
U0lfQlVTTE9HSUMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX01ZUkIgaXMgbm90IHNldAojIENP
TkZJR19TQ1NJX01ZUlMgaXMgbm90IHNldAojIENPTkZJR19WTVdBUkVfUFZTQ1NJIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0NTSV9TTklDIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9ETVgzMTkxRCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfRkRPTUFJTl9QQ0kgaXMgbm90IHNldAojIENPTkZJR19T
Q1NJX0dEVEggaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0lTQ0kgaXMgbm90IHNldAojIENPTkZJ
R19TQ1NJX0lQUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfSU5JVElPIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0NTSV9JTklBMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9TVEVYIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0NTSV9TWU01M0M4WFhfMiBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfSVBS
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9RTE9HSUNfMTI4MCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NDU0lfUUxBX0lTQ1NJIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9EQzM5NXggaXMgbm90IHNl
dAojIENPTkZJR19TQ1NJX0FNNTNDOTc0IGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9XRDcxOVgg
aXMgbm90IHNldAojIENPTkZJR19TQ1NJX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9Q
TUNSQUlEIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9QTTgwMDEgaXMgbm90IHNldApDT05GSUdf
U0NTSV9WSVJUSU89eQojIENPTkZJR19TQ1NJX0xPV0xFVkVMX1BDTUNJQSBpcyBub3Qgc2V0CiMg
Q09ORklHX1NDU0lfREggaXMgbm90IHNldAojIGVuZCBvZiBTQ1NJIGRldmljZSBzdXBwb3J0CgpD
T05GSUdfQVRBPXkKQ09ORklHX0FUQV9WRVJCT1NFX0VSUk9SPXkKQ09ORklHX0FUQV9BQ1BJPXkK
IyBDT05GSUdfU0FUQV9aUE9ERCBpcyBub3Qgc2V0CkNPTkZJR19TQVRBX1BNUD15CgojCiMgQ29u
dHJvbGxlcnMgd2l0aCBub24tU0ZGIG5hdGl2ZSBpbnRlcmZhY2UKIwpDT05GSUdfU0FUQV9BSENJ
PXkKQ09ORklHX1NBVEFfTU9CSUxFX0xQTV9QT0xJQ1k9MAojIENPTkZJR19TQVRBX0FIQ0lfUExB
VEZPUk0gaXMgbm90IHNldAojIENPTkZJR19TQVRBX0lOSUMxNjJYIGlzIG5vdCBzZXQKIyBDT05G
SUdfU0FUQV9BQ0FSRF9BSENJIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9TSUwyNCBpcyBub3Qg
c2V0CkNPTkZJR19BVEFfU0ZGPXkKCiMKIyBTRkYgY29udHJvbGxlcnMgd2l0aCBjdXN0b20gRE1B
IGludGVyZmFjZQojCiMgQ09ORklHX1BEQ19BRE1BIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9R
U1RPUiBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfU1g0IGlzIG5vdCBzZXQKQ09ORklHX0FUQV9C
TURNQT15CgojCiMgU0FUQSBTRkYgY29udHJvbGxlcnMgd2l0aCBCTURNQQojCkNPTkZJR19BVEFf
UElJWD15CiMgQ09ORklHX1NBVEFfRFdDIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9NViBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NBVEFfTlYgaXMgbm90IHNldAojIENPTkZJR19TQVRBX1BST01JU0Ug
aXMgbm90IHNldAojIENPTkZJR19TQVRBX1NJTCBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfU0lT
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9TVlcgaXMgbm90IHNldAojIENPTkZJR19TQVRBX1VM
SSBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfVklBIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9W
SVRFU1NFIGlzIG5vdCBzZXQKCiMKIyBQQVRBIFNGRiBjb250cm9sbGVycyB3aXRoIEJNRE1BCiMK
IyBDT05GSUdfUEFUQV9BTEkgaXMgbm90IHNldApDT05GSUdfUEFUQV9BTUQ9eQojIENPTkZJR19Q
QVRBX0FSVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9BVElJWFAgaXMgbm90IHNldAojIENP
TkZJR19QQVRBX0FUUDg2N1ggaXMgbm90IHNldAojIENPTkZJR19QQVRBX0NNRDY0WCBpcyBub3Qg
c2V0CiMgQ09ORklHX1BBVEFfQ1lQUkVTUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfRUZBUiBp
cyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfSFBUMzY2IGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9I
UFQzN1ggaXMgbm90IHNldAojIENPTkZJR19QQVRBX0hQVDNYMk4gaXMgbm90IHNldAojIENPTkZJ
R19QQVRBX0hQVDNYMyBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfSVQ4MjEzIGlzIG5vdCBzZXQK
IyBDT05GSUdfUEFUQV9JVDgyMVggaXMgbm90IHNldAojIENPTkZJR19QQVRBX0pNSUNST04gaXMg
bm90IHNldAojIENPTkZJR19QQVRBX01BUlZFTEwgaXMgbm90IHNldAojIENPTkZJR19QQVRBX05F
VENFTEwgaXMgbm90IHNldAojIENPTkZJR19QQVRBX05JTkpBMzIgaXMgbm90IHNldAojIENPTkZJ
R19QQVRBX05TODc0MTUgaXMgbm90IHNldApDT05GSUdfUEFUQV9PTERQSUlYPXkKIyBDT05GSUdf
UEFUQV9PUFRJRE1BIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9QREMyMDI3WCBpcyBub3Qgc2V0
CiMgQ09ORklHX1BBVEFfUERDX09MRCBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfUkFESVNZUyBp
cyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfUkRDIGlzIG5vdCBzZXQKQ09ORklHX1BBVEFfU0NIPXkK
IyBDT05GSUdfUEFUQV9TRVJWRVJXT1JLUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfU0lMNjgw
IGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9TSVMgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1RP
U0hJQkEgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1RSSUZMRVggaXMgbm90IHNldAojIENPTkZJ
R19QQVRBX1ZJQSBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfV0lOQk9ORCBpcyBub3Qgc2V0Cgoj
CiMgUElPLW9ubHkgU0ZGIGNvbnRyb2xsZXJzCiMKIyBDT05GSUdfUEFUQV9DTUQ2NDBfUENJIGlz
IG5vdCBzZXQKIyBDT05GSUdfUEFUQV9NUElJWCBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfTlM4
NzQxMCBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfT1BUSSBpcyBub3Qgc2V0CiMgQ09ORklHX1BB
VEFfUENNQ0lBIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9SWjEwMDAgaXMgbm90IHNldAoKIwoj
IEdlbmVyaWMgZmFsbGJhY2sgLyBsZWdhY3kgZHJpdmVycwojCiMgQ09ORklHX1BBVEFfQUNQSSBp
cyBub3Qgc2V0CiMgQ09ORklHX0FUQV9HRU5FUklDIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9M
RUdBQ1kgaXMgbm90IHNldApDT05GSUdfTUQ9eQpDT05GSUdfQkxLX0RFVl9NRD15CkNPTkZJR19N
RF9BVVRPREVURUNUPXkKIyBDT05GSUdfTURfTElORUFSIGlzIG5vdCBzZXQKIyBDT05GSUdfTURf
UkFJRDAgaXMgbm90IHNldAojIENPTkZJR19NRF9SQUlEMSBpcyBub3Qgc2V0CiMgQ09ORklHX01E
X1JBSUQxMCBpcyBub3Qgc2V0CiMgQ09ORklHX01EX1JBSUQ0NTYgaXMgbm90IHNldAojIENPTkZJ
R19NRF9NVUxUSVBBVEggaXMgbm90IHNldAojIENPTkZJR19NRF9GQVVMVFkgaXMgbm90IHNldAoj
IENPTkZJR19CQ0FDSEUgaXMgbm90IHNldApDT05GSUdfQkxLX0RFVl9ETV9CVUlMVElOPXkKQ09O
RklHX0JMS19ERVZfRE09eQojIENPTkZJR19ETV9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX0RN
X1VOU1RSSVBFRCBpcyBub3Qgc2V0CiMgQ09ORklHX0RNX0NSWVBUIGlzIG5vdCBzZXQKIyBDT05G
SUdfRE1fU05BUFNIT1QgaXMgbm90IHNldAojIENPTkZJR19ETV9USElOX1BST1ZJU0lPTklORyBp
cyBub3Qgc2V0CiMgQ09ORklHX0RNX0NBQ0hFIGlzIG5vdCBzZXQKIyBDT05GSUdfRE1fV1JJVEVD
QUNIRSBpcyBub3Qgc2V0CiMgQ09ORklHX0RNX0VSQSBpcyBub3Qgc2V0CkNPTkZJR19ETV9NSVJS
T1I9eQojIENPTkZJR19ETV9MT0dfVVNFUlNQQUNFIGlzIG5vdCBzZXQKIyBDT05GSUdfRE1fUkFJ
RCBpcyBub3Qgc2V0CkNPTkZJR19ETV9aRVJPPXkKIyBDT05GSUdfRE1fTVVMVElQQVRIIGlzIG5v
dCBzZXQKIyBDT05GSUdfRE1fREVMQVkgaXMgbm90IHNldAojIENPTkZJR19ETV9EVVNUIGlzIG5v
dCBzZXQKIyBDT05GSUdfRE1fSU5JVCBpcyBub3Qgc2V0CiMgQ09ORklHX0RNX1VFVkVOVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RNX0ZMQUtFWSBpcyBub3Qgc2V0CiMgQ09ORklHX0RNX1ZFUklUWSBp
cyBub3Qgc2V0CiMgQ09ORklHX0RNX1NXSVRDSCBpcyBub3Qgc2V0CiMgQ09ORklHX0RNX0xPR19X
UklURVMgaXMgbm90IHNldAojIENPTkZJR19ETV9JTlRFR1JJVFkgaXMgbm90IHNldAojIENPTkZJ
R19UQVJHRVRfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZVU0lPTiBpcyBub3Qgc2V0CgojCiMg
SUVFRSAxMzk0IChGaXJlV2lyZSkgc3VwcG9ydAojCiMgQ09ORklHX0ZJUkVXSVJFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRklSRVdJUkVfTk9TWSBpcyBub3Qgc2V0CiMgZW5kIG9mIElFRUUgMTM5NCAo
RmlyZVdpcmUpIHN1cHBvcnQKCkNPTkZJR19NQUNJTlRPU0hfRFJJVkVSUz15CkNPTkZJR19NQUNf
RU1VTU9VU0VCVE49eQpDT05GSUdfTkVUREVWSUNFUz15CkNPTkZJR19NSUk9eQpDT05GSUdfTkVU
X0NPUkU9eQojIENPTkZJR19CT05ESU5HIGlzIG5vdCBzZXQKIyBDT05GSUdfRFVNTVkgaXMgbm90
IHNldAojIENPTkZJR19FUVVBTElaRVIgaXMgbm90IHNldAojIENPTkZJR19ORVRfRkMgaXMgbm90
IHNldAojIENPTkZJR19JRkIgaXMgbm90IHNldAojIENPTkZJR19ORVRfVEVBTSBpcyBub3Qgc2V0
CiMgQ09ORklHX01BQ1ZMQU4gaXMgbm90IHNldAojIENPTkZJR19JUFZMQU4gaXMgbm90IHNldAoj
IENPTkZJR19WWExBTiBpcyBub3Qgc2V0CiMgQ09ORklHX0dFTkVWRSBpcyBub3Qgc2V0CiMgQ09O
RklHX0dUUCBpcyBub3Qgc2V0CiMgQ09ORklHX01BQ1NFQyBpcyBub3Qgc2V0CkNPTkZJR19ORVRD
T05TT0xFPXkKIyBDT05GSUdfTkVUQ09OU09MRV9EWU5BTUlDIGlzIG5vdCBzZXQKQ09ORklHX05F
VFBPTEw9eQpDT05GSUdfTkVUX1BPTExfQ09OVFJPTExFUj15CkNPTkZJR19UVU49eQojIENPTkZJ
R19UVU5fVk5FVF9DUk9TU19MRSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZFVEggaXMgbm90IHNldApD
T05GSUdfVklSVElPX05FVD15CiMgQ09ORklHX05MTU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfQVJD
TkVUIGlzIG5vdCBzZXQKCiMKIyBDQUlGIHRyYW5zcG9ydCBkcml2ZXJzCiMKCiMKIyBEaXN0cmli
dXRlZCBTd2l0Y2ggQXJjaGl0ZWN0dXJlIGRyaXZlcnMKIwojIGVuZCBvZiBEaXN0cmlidXRlZCBT
d2l0Y2ggQXJjaGl0ZWN0dXJlIGRyaXZlcnMKCkNPTkZJR19FVEhFUk5FVD15CkNPTkZJR19ORVRf
VkVORE9SXzNDT009eQojIENPTkZJR19QQ01DSUFfM0M1NzQgaXMgbm90IHNldAojIENPTkZJR19Q
Q01DSUFfM0M1ODkgaXMgbm90IHNldAojIENPTkZJR19WT1JURVggaXMgbm90IHNldAojIENPTkZJ
R19UWVBIT09OIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQURBUFRFQz15CiMgQ09ORklH
X0FEQVBURUNfU1RBUkZJUkUgaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9BR0VSRT15CiMg
Q09ORklHX0VUMTMxWCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0FMQUNSSVRFQ0g9eQoj
IENPTkZJR19TTElDT1NTIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQUxURU9OPXkKIyBD
T05GSUdfQUNFTklDIGlzIG5vdCBzZXQKIyBDT05GSUdfQUxURVJBX1RTRSBpcyBub3Qgc2V0CkNP
TkZJR19ORVRfVkVORE9SX0FNQVpPTj15CiMgQ09ORklHX0VOQV9FVEhFUk5FVCBpcyBub3Qgc2V0
CkNPTkZJR19ORVRfVkVORE9SX0FNRD15CiMgQ09ORklHX0FNRDgxMTFfRVRIIGlzIG5vdCBzZXQK
IyBDT05GSUdfUENORVQzMiBpcyBub3Qgc2V0CiMgQ09ORklHX1BDTUNJQV9OTUNMQU4gaXMgbm90
IHNldAojIENPTkZJR19BTURfWEdCRSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0FRVUFO
VElBPXkKIyBDT05GSUdfQVFUSU9OIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQVJDPXkK
Q09ORklHX05FVF9WRU5ET1JfQVRIRVJPUz15CiMgQ09ORklHX0FUTDIgaXMgbm90IHNldAojIENP
TkZJR19BVEwxIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRMMUUgaXMgbm90IHNldAojIENPTkZJR19B
VEwxQyBpcyBub3Qgc2V0CiMgQ09ORklHX0FMWCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9S
X0FVUk9SQT15CiMgQ09ORklHX0FVUk9SQV9OQjg4MDAgaXMgbm90IHNldApDT05GSUdfTkVUX1ZF
TkRPUl9CUk9BRENPTT15CiMgQ09ORklHX0I0NCBpcyBub3Qgc2V0CiMgQ09ORklHX0JDTUdFTkVU
IGlzIG5vdCBzZXQKIyBDT05GSUdfQk5YMiBpcyBub3Qgc2V0CiMgQ09ORklHX0NOSUMgaXMgbm90
IHNldApDT05GSUdfVElHT04zPXkKQ09ORklHX1RJR09OM19IV01PTj15CiMgQ09ORklHX0JOWDJY
IGlzIG5vdCBzZXQKIyBDT05GSUdfU1lTVEVNUE9SVCBpcyBub3Qgc2V0CiMgQ09ORklHX0JOWFQg
aXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9CUk9DQURFPXkKIyBDT05GSUdfQk5BIGlzIG5v
dCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQ0FERU5DRT15CiMgQ09ORklHX01BQ0IgaXMgbm90IHNl
dApDT05GSUdfTkVUX1ZFTkRPUl9DQVZJVU09eQojIENPTkZJR19USFVOREVSX05JQ19QRiBpcyBu
b3Qgc2V0CiMgQ09ORklHX1RIVU5ERVJfTklDX1ZGIGlzIG5vdCBzZXQKIyBDT05GSUdfVEhVTkRF
Ul9OSUNfQkdYIGlzIG5vdCBzZXQKIyBDT05GSUdfVEhVTkRFUl9OSUNfUkdYIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ0FWSVVNX1BUUCBpcyBub3Qgc2V0CiMgQ09ORklHX0xJUVVJRElPIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTElRVUlESU9fVkYgaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9DSEVM
U0lPPXkKIyBDT05GSUdfQ0hFTFNJT19UMSBpcyBub3Qgc2V0CiMgQ09ORklHX0NIRUxTSU9fVDMg
aXMgbm90IHNldAojIENPTkZJR19DSEVMU0lPX1Q0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hFTFNJ
T19UNFZGIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQ0lTQ089eQojIENPTkZJR19FTklD
IGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfQ09SVElOQT15CiMgQ09ORklHX0NYX0VDQVQg
aXMgbm90IHNldAojIENPTkZJR19ETkVUIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfREVD
PXkKQ09ORklHX05FVF9UVUxJUD15CiMgQ09ORklHX0RFMjEwNFggaXMgbm90IHNldAojIENPTkZJ
R19UVUxJUCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFNFg1IGlzIG5vdCBzZXQKIyBDT05GSUdfV0lO
Qk9ORF84NDAgaXMgbm90IHNldAojIENPTkZJR19ETTkxMDIgaXMgbm90IHNldAojIENPTkZJR19V
TEk1MjZYIGlzIG5vdCBzZXQKIyBDT05GSUdfUENNQ0lBX1hJUkNPTSBpcyBub3Qgc2V0CkNPTkZJ
R19ORVRfVkVORE9SX0RMSU5LPXkKIyBDT05GSUdfREwySyBpcyBub3Qgc2V0CiMgQ09ORklHX1NV
TkRBTkNFIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfRU1VTEVYPXkKIyBDT05GSUdfQkUy
TkVUIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfRVpDSElQPXkKQ09ORklHX05FVF9WRU5E
T1JfRlVKSVRTVT15CiMgQ09ORklHX1BDTUNJQV9GTVZKMThYIGlzIG5vdCBzZXQKQ09ORklHX05F
VF9WRU5ET1JfR09PR0xFPXkKIyBDT05GSUdfR1ZFIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5E
T1JfSFA9eQojIENPTkZJR19IUDEwMCBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX0hVQVdF
ST15CiMgQ09ORklHX0hJTklDIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfSTgyNVhYPXkK
Q09ORklHX05FVF9WRU5ET1JfSU5URUw9eQpDT05GSUdfRTEwMD15CkNPTkZJR19FMTAwMD15CkNP
TkZJR19FMTAwMEU9eQpDT05GSUdfRTEwMDBFX0hXVFM9eQojIENPTkZJR19JR0IgaXMgbm90IHNl
dAojIENPTkZJR19JR0JWRiBpcyBub3Qgc2V0CiMgQ09ORklHX0lYR0IgaXMgbm90IHNldAojIENP
TkZJR19JWEdCRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lYR0JFVkYgaXMgbm90IHNldAojIENPTkZJ
R19JNDBFIGlzIG5vdCBzZXQKIyBDT05GSUdfSTQwRVZGIGlzIG5vdCBzZXQKIyBDT05GSUdfSUNF
IGlzIG5vdCBzZXQKIyBDT05GSUdfRk0xMEsgaXMgbm90IHNldAojIENPTkZJR19JR0MgaXMgbm90
IHNldAojIENPTkZJR19KTUUgaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9NQVJWRUxMPXkK
IyBDT05GSUdfTVZNRElPIGlzIG5vdCBzZXQKIyBDT05GSUdfU0tHRSBpcyBub3Qgc2V0CkNPTkZJ
R19TS1kyPXkKIyBDT05GSUdfU0tZMl9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9S
X01FTExBTk9YPXkKIyBDT05GSUdfTUxYNF9FTiBpcyBub3Qgc2V0CiMgQ09ORklHX01MWDVfQ09S
RSBpcyBub3Qgc2V0CiMgQ09ORklHX01MWFNXX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19NTFhG
VyBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX01JQ1JFTD15CiMgQ09ORklHX0tTODg0MiBp
cyBub3Qgc2V0CiMgQ09ORklHX0tTODg1MV9NTEwgaXMgbm90IHNldAojIENPTkZJR19LU1o4ODRY
X1BDSSBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX01JQ1JPQ0hJUD15CiMgQ09ORklHX0xB
Tjc0M1ggaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9NSUNST1NFTUk9eQpDT05GSUdfTkVU
X1ZFTkRPUl9NWVJJPXkKIyBDT05GSUdfTVlSSTEwR0UgaXMgbm90IHNldAojIENPTkZJR19GRUFM
TlggaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRPUl9OQVRTRU1JPXkKIyBDT05GSUdfTkFUU0VN
SSBpcyBub3Qgc2V0CiMgQ09ORklHX05TODM4MjAgaXMgbm90IHNldApDT05GSUdfTkVUX1ZFTkRP
Ul9ORVRFUklPTj15CiMgQ09ORklHX1MySU8gaXMgbm90IHNldAojIENPTkZJR19WWEdFIGlzIG5v
dCBzZXQKQ09ORklHX05FVF9WRU5ET1JfTkVUUk9OT01FPXkKIyBDT05GSUdfTkZQIGlzIG5vdCBz
ZXQKQ09ORklHX05FVF9WRU5ET1JfTkk9eQojIENPTkZJR19OSV9YR0VfTUFOQUdFTUVOVF9FTkVU
IGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfODM5MD15CiMgQ09ORklHX1BDTUNJQV9BWE5F
VCBpcyBub3Qgc2V0CiMgQ09ORklHX05FMktfUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfUENNQ0lB
X1BDTkVUIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfTlZJRElBPXkKQ09ORklHX0ZPUkNF
REVUSD15CkNPTkZJR19ORVRfVkVORE9SX09LST15CiMgQ09ORklHX0VUSE9DIGlzIG5vdCBzZXQK
Q09ORklHX05FVF9WRU5ET1JfUEFDS0VUX0VOR0lORVM9eQojIENPTkZJR19IQU1BQ0hJIGlzIG5v
dCBzZXQKIyBDT05GSUdfWUVMTE9XRklOIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfUUxP
R0lDPXkKIyBDT05GSUdfUUxBM1hYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1FMQ05JQyBpcyBub3Qg
c2V0CiMgQ09ORklHX1FMR0UgaXMgbm90IHNldAojIENPTkZJR19ORVRYRU5fTklDIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUUVEIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfUVVBTENPTU09eQoj
IENPTkZJR19RQ09NX0VNQUMgaXMgbm90IHNldAojIENPTkZJR19STU5FVCBpcyBub3Qgc2V0CkNP
TkZJR19ORVRfVkVORE9SX1JEQz15CiMgQ09ORklHX1I2MDQwIGlzIG5vdCBzZXQKQ09ORklHX05F
VF9WRU5ET1JfUkVBTFRFSz15CiMgQ09ORklHXzgxMzlDUCBpcyBub3Qgc2V0CkNPTkZJR184MTM5
VE9PPXkKQ09ORklHXzgxMzlUT09fUElPPXkKIyBDT05GSUdfODEzOVRPT19UVU5FX1RXSVNURVIg
aXMgbm90IHNldAojIENPTkZJR184MTM5VE9PXzgxMjkgaXMgbm90IHNldAojIENPTkZJR184MTM5
X09MRF9SWF9SRVNFVCBpcyBub3Qgc2V0CkNPTkZJR19SODE2OT15CkNPTkZJR19ORVRfVkVORE9S
X1JFTkVTQVM9eQpDT05GSUdfTkVUX1ZFTkRPUl9ST0NLRVI9eQpDT05GSUdfTkVUX1ZFTkRPUl9T
QU1TVU5HPXkKIyBDT05GSUdfU1hHQkVfRVRIIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1Jf
U0VFUT15CkNPTkZJR19ORVRfVkVORE9SX1NPTEFSRkxBUkU9eQojIENPTkZJR19TRkMgaXMgbm90
IHNldAojIENPTkZJR19TRkNfRkFMQ09OIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU0lM
QU49eQojIENPTkZJR19TQzkyMDMxIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU0lTPXkK
IyBDT05GSUdfU0lTOTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0lTMTkwIGlzIG5vdCBzZXQKQ09O
RklHX05FVF9WRU5ET1JfU01TQz15CiMgQ09ORklHX1BDTUNJQV9TTUM5MUM5MiBpcyBub3Qgc2V0
CiMgQ09ORklHX0VQSUMxMDAgaXMgbm90IHNldAojIENPTkZJR19TTVNDOTExWCBpcyBub3Qgc2V0
CiMgQ09ORklHX1NNU0M5NDIwIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU09DSU9ORVhU
PXkKQ09ORklHX05FVF9WRU5ET1JfU1RNSUNSTz15CiMgQ09ORklHX1NUTU1BQ19FVEggaXMgbm90
IHNldApDT05GSUdfTkVUX1ZFTkRPUl9TVU49eQojIENPTkZJR19IQVBQWU1FQUwgaXMgbm90IHNl
dAojIENPTkZJR19TVU5HRU0gaXMgbm90IHNldAojIENPTkZJR19DQVNTSU5JIGlzIG5vdCBzZXQK
IyBDT05GSUdfTklVIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfU1lOT1BTWVM9eQojIENP
TkZJR19EV0NfWExHTUFDIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfVEVIVVRJPXkKIyBD
T05GSUdfVEVIVVRJIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfVEk9eQojIENPTkZJR19U
SV9DUFNXX1BIWV9TRUwgaXMgbm90IHNldAojIENPTkZJR19UTEFOIGlzIG5vdCBzZXQKQ09ORklH
X05FVF9WRU5ET1JfVklBPXkKIyBDT05GSUdfVklBX1JISU5FIGlzIG5vdCBzZXQKIyBDT05GSUdf
VklBX1ZFTE9DSVRZIGlzIG5vdCBzZXQKQ09ORklHX05FVF9WRU5ET1JfV0laTkVUPXkKIyBDT05G
SUdfV0laTkVUX1c1MTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfV0laTkVUX1c1MzAwIGlzIG5vdCBz
ZXQKQ09ORklHX05FVF9WRU5ET1JfWElMSU5YPXkKIyBDT05GSUdfWElMSU5YX0FYSV9FTUFDIGlz
IG5vdCBzZXQKIyBDT05GSUdfWElMSU5YX0xMX1RFTUFDIGlzIG5vdCBzZXQKQ09ORklHX05FVF9W
RU5ET1JfWElSQ09NPXkKIyBDT05GSUdfUENNQ0lBX1hJUkMyUFMgaXMgbm90IHNldApDT05GSUdf
RkREST15CiMgQ09ORklHX0RFRlhYIGlzIG5vdCBzZXQKIyBDT05GSUdfU0tGUCBpcyBub3Qgc2V0
CiMgQ09ORklHX0hJUFBJIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1NCMTAwMCBpcyBub3Qgc2V0
CkNPTkZJR19NRElPX0RFVklDRT15CkNPTkZJR19NRElPX0JVUz15CiMgQ09ORklHX01ESU9fQkNN
X1VOSU1BQyBpcyBub3Qgc2V0CiMgQ09ORklHX01ESU9fQklUQkFORyBpcyBub3Qgc2V0CiMgQ09O
RklHX01ESU9fTVNDQ19NSUlNIGlzIG5vdCBzZXQKIyBDT05GSUdfTURJT19USFVOREVSIGlzIG5v
dCBzZXQKQ09ORklHX1BIWUxJQj15CiMgQ09ORklHX0xFRF9UUklHR0VSX1BIWSBpcyBub3Qgc2V0
CgojCiMgTUlJIFBIWSBkZXZpY2UgZHJpdmVycwojCiMgQ09ORklHX0FNRF9QSFkgaXMgbm90IHNl
dAojIENPTkZJR19BUVVBTlRJQV9QSFkgaXMgbm90IHNldAojIENPTkZJR19BWDg4Nzk2Ql9QSFkg
aXMgbm90IHNldAojIENPTkZJR19BVDgwM1hfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfQkNNN1hY
WF9QSFkgaXMgbm90IHNldAojIENPTkZJR19CQ004N1hYX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklH
X0JST0FEQ09NX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0NJQ0FEQV9QSFkgaXMgbm90IHNldAoj
IENPTkZJR19DT1JUSU5BX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0RBVklDT01fUEhZIGlzIG5v
dCBzZXQKIyBDT05GSUdfRFA4MzgyMl9QSFkgaXMgbm90IHNldAojIENPTkZJR19EUDgzVEM4MTFf
UEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfRFA4Mzg0OF9QSFkgaXMgbm90IHNldAojIENPTkZJR19E
UDgzODY3X1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZJWEVEX1BIWSBpcyBub3Qgc2V0CiMgQ09O
RklHX0lDUExVU19QSFkgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9YV0FZX1BIWSBpcyBub3Qg
c2V0CiMgQ09ORklHX0xTSV9FVDEwMTFDX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0xYVF9QSFkg
aXMgbm90IHNldAojIENPTkZJR19NQVJWRUxMX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX01BUlZF
TExfMTBHX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX01JQ1JFTF9QSFkgaXMgbm90IHNldAojIENP
TkZJR19NSUNST0NISVBfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfTUlDUk9DSElQX1QxX1BIWSBp
cyBub3Qgc2V0CiMgQ09ORklHX01JQ1JPU0VNSV9QSFkgaXMgbm90IHNldAojIENPTkZJR19OQVRJ
T05BTF9QSFkgaXMgbm90IHNldAojIENPTkZJR19OWFBfVEpBMTFYWF9QSFkgaXMgbm90IHNldAoj
IENPTkZJR19RU0VNSV9QSFkgaXMgbm90IHNldApDT05GSUdfUkVBTFRFS19QSFk9eQojIENPTkZJ
R19SRU5FU0FTX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX1JPQ0tDSElQX1BIWSBpcyBub3Qgc2V0
CiMgQ09ORklHX1NNU0NfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfU1RFMTBYUCBpcyBub3Qgc2V0
CiMgQ09ORklHX1RFUkFORVRJQ1NfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfVklURVNTRV9QSFkg
aXMgbm90IHNldAojIENPTkZJR19YSUxJTlhfR01JSTJSR01JSSBpcyBub3Qgc2V0CiMgQ09ORklH
X1BQUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NMSVAgaXMgbm90IHNldApDT05GSUdfVVNCX05FVF9E
UklWRVJTPXkKIyBDT05GSUdfVVNCX0NBVEMgaXMgbm90IHNldAojIENPTkZJR19VU0JfS0FXRVRI
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1BFR0FTVVMgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
UlRMODE1MCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9SVEw4MTUyIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX0xBTjc4WFggaXMgbm90IHNldAojIENPTkZJR19VU0JfVVNCTkVUIGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX0hTTyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JUEhFVEggaXMgbm90IHNl
dApDT05GSUdfV0xBTj15CkNPTkZJR19XTEFOX1ZFTkRPUl9BRE1URUs9eQojIENPTkZJR19BRE04
MjExIGlzIG5vdCBzZXQKQ09ORklHX1dMQU5fVkVORE9SX0FUSD15CiMgQ09ORklHX0FUSF9ERUJV
RyBpcyBub3Qgc2V0CiMgQ09ORklHX0FUSDVLIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRINUtfUENJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfQVRIOUsgaXMgbm90IHNldAojIENPTkZJR19BVEg5S19IVEMg
aXMgbm90IHNldAojIENPTkZJR19DQVJMOTE3MCBpcyBub3Qgc2V0CiMgQ09ORklHX0FUSDZLTCBp
cyBub3Qgc2V0CiMgQ09ORklHX0FSNTUyMyBpcyBub3Qgc2V0CiMgQ09ORklHX1dJTDYyMTAgaXMg
bm90IHNldAojIENPTkZJR19BVEgxMEsgaXMgbm90IHNldAojIENPTkZJR19XQ04zNlhYIGlzIG5v
dCBzZXQKQ09ORklHX1dMQU5fVkVORE9SX0FUTUVMPXkKIyBDT05GSUdfQVRNRUwgaXMgbm90IHNl
dAojIENPTkZJR19BVDc2QzUwWF9VU0IgaXMgbm90IHNldApDT05GSUdfV0xBTl9WRU5ET1JfQlJP
QURDT009eQojIENPTkZJR19CNDMgaXMgbm90IHNldAojIENPTkZJR19CNDNMRUdBQ1kgaXMgbm90
IHNldAojIENPTkZJR19CUkNNU01BQyBpcyBub3Qgc2V0CiMgQ09ORklHX0JSQ01GTUFDIGlzIG5v
dCBzZXQKQ09ORklHX1dMQU5fVkVORE9SX0NJU0NPPXkKIyBDT05GSUdfQUlSTyBpcyBub3Qgc2V0
CiMgQ09ORklHX0FJUk9fQ1MgaXMgbm90IHNldApDT05GSUdfV0xBTl9WRU5ET1JfSU5URUw9eQoj
IENPTkZJR19JUFcyMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBXMjIwMCBpcyBub3Qgc2V0CiMg
Q09ORklHX0lXTDQ5NjUgaXMgbm90IHNldAojIENPTkZJR19JV0wzOTQ1IGlzIG5vdCBzZXQKIyBD
T05GSUdfSVdMV0lGSSBpcyBub3Qgc2V0CkNPTkZJR19XTEFOX1ZFTkRPUl9JTlRFUlNJTD15CiMg
Q09ORklHX0hPU1RBUCBpcyBub3Qgc2V0CiMgQ09ORklHX0hFUk1FUyBpcyBub3Qgc2V0CiMgQ09O
RklHX1A1NF9DT01NT04gaXMgbm90IHNldAojIENPTkZJR19QUklTTTU0IGlzIG5vdCBzZXQKQ09O
RklHX1dMQU5fVkVORE9SX01BUlZFTEw9eQojIENPTkZJR19MSUJFUlRBUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0xJQkVSVEFTX1RISU5GSVJNIGlzIG5vdCBzZXQKIyBDT05GSUdfTVdJRklFWCBpcyBu
b3Qgc2V0CiMgQ09ORklHX01XTDhLIGlzIG5vdCBzZXQKQ09ORklHX1dMQU5fVkVORE9SX01FRElB
VEVLPXkKIyBDT05GSUdfTVQ3NjAxVSBpcyBub3Qgc2V0CiMgQ09ORklHX01UNzZ4MFUgaXMgbm90
IHNldAojIENPTkZJR19NVDc2eDBFIGlzIG5vdCBzZXQKIyBDT05GSUdfTVQ3NngyRSBpcyBub3Qg
c2V0CiMgQ09ORklHX01UNzZ4MlUgaXMgbm90IHNldAojIENPTkZJR19NVDc2MDNFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTVQ3NjE1RSBpcyBub3Qgc2V0CkNPTkZJR19XTEFOX1ZFTkRPUl9SQUxJTks9
eQojIENPTkZJR19SVDJYMDAgaXMgbm90IHNldApDT05GSUdfV0xBTl9WRU5ET1JfUkVBTFRFSz15
CiMgQ09ORklHX1JUTDgxODAgaXMgbm90IHNldAojIENPTkZJR19SVEw4MTg3IGlzIG5vdCBzZXQK
Q09ORklHX1JUTF9DQVJEUz15CiMgQ09ORklHX1JUTDgxOTJDRSBpcyBub3Qgc2V0CiMgQ09ORklH
X1JUTDgxOTJTRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTDgxOTJERSBpcyBub3Qgc2V0CiMgQ09O
RklHX1JUTDg3MjNBRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTDg3MjNCRSBpcyBub3Qgc2V0CiMg
Q09ORklHX1JUTDgxODhFRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTDgxOTJFRSBpcyBub3Qgc2V0
CiMgQ09ORklHX1JUTDg4MjFBRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTDgxOTJDVSBpcyBub3Qg
c2V0CiMgQ09ORklHX1JUTDhYWFhVIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRXODggaXMgbm90IHNl
dApDT05GSUdfV0xBTl9WRU5ET1JfUlNJPXkKIyBDT05GSUdfUlNJXzkxWCBpcyBub3Qgc2V0CkNP
TkZJR19XTEFOX1ZFTkRPUl9TVD15CiMgQ09ORklHX0NXMTIwMCBpcyBub3Qgc2V0CkNPTkZJR19X
TEFOX1ZFTkRPUl9UST15CiMgQ09ORklHX1dMMTI1MSBpcyBub3Qgc2V0CiMgQ09ORklHX1dMMTJY
WCBpcyBub3Qgc2V0CiMgQ09ORklHX1dMMThYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1dMQ09SRSBp
cyBub3Qgc2V0CkNPTkZJR19XTEFOX1ZFTkRPUl9aWURBUz15CiMgQ09ORklHX1VTQl9aRDEyMDEg
aXMgbm90IHNldAojIENPTkZJR19aRDEyMTFSVyBpcyBub3Qgc2V0CkNPTkZJR19XTEFOX1ZFTkRP
Ul9RVUFOVEVOTkE9eQojIENPTkZJR19RVE5GTUFDX1BDSUUgaXMgbm90IHNldAojIENPTkZJR19Q
Q01DSUFfUkFZQ1MgaXMgbm90IHNldAojIENPTkZJR19QQ01DSUFfV0wzNTAxIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUFDODAyMTFfSFdTSU0gaXMgbm90IHNldAojIENPTkZJR19VU0JfTkVUX1JORElT
X1dMQU4gaXMgbm90IHNldAojIENPTkZJR19WSVJUX1dJRkkgaXMgbm90IHNldAoKIwojIEVuYWJs
ZSBXaU1BWCAoTmV0d29ya2luZyBvcHRpb25zKSB0byBzZWUgdGhlIFdpTUFYIGRyaXZlcnMKIwoj
IENPTkZJR19XQU4gaXMgbm90IHNldAojIENPTkZJR19WTVhORVQzIGlzIG5vdCBzZXQKIyBDT05G
SUdfRlVKSVRTVV9FUyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVERFVlNJTSBpcyBub3Qgc2V0CkNP
TkZJR19ORVRfRkFJTE9WRVI9eQojIENPTkZJR19JU0ROIGlzIG5vdCBzZXQKIyBDT05GSUdfTlZN
IGlzIG5vdCBzZXQKCiMKIyBJbnB1dCBkZXZpY2Ugc3VwcG9ydAojCkNPTkZJR19JTlBVVD15CkNP
TkZJR19JTlBVVF9MRURTPXkKQ09ORklHX0lOUFVUX0ZGX01FTUxFU1M9eQpDT05GSUdfSU5QVVRf
UE9MTERFVj15CkNPTkZJR19JTlBVVF9TUEFSU0VLTUFQPXkKIyBDT05GSUdfSU5QVVRfTUFUUklY
S01BUCBpcyBub3Qgc2V0CgojCiMgVXNlcmxhbmQgaW50ZXJmYWNlcwojCiMgQ09ORklHX0lOUFVU
X01PVVNFREVWIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfSk9ZREVWIGlzIG5vdCBzZXQKQ09O
RklHX0lOUFVUX0VWREVWPXkKIyBDT05GSUdfSU5QVVRfRVZCVUcgaXMgbm90IHNldAoKIwojIElu
cHV0IERldmljZSBEcml2ZXJzCiMKQ09ORklHX0lOUFVUX0tFWUJPQVJEPXkKIyBDT05GSUdfS0VZ
Qk9BUkRfQURQNTU4OCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0FEUDU1ODkgaXMgbm90
IHNldApDT05GSUdfS0VZQk9BUkRfQVRLQkQ9eQojIENPTkZJR19LRVlCT0FSRF9RVDEwNTAgaXMg
bm90IHNldAojIENPTkZJR19LRVlCT0FSRF9RVDEwNzAgaXMgbm90IHNldAojIENPTkZJR19LRVlC
T0FSRF9RVDIxNjAgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9ETElOS19ESVI2ODUgaXMg
bm90IHNldAojIENPTkZJR19LRVlCT0FSRF9MS0tCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJP
QVJEX1RDQTY0MTYgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9UQ0E4NDE4IGlzIG5vdCBz
ZXQKIyBDT05GSUdfS0VZQk9BUkRfTE04MzIzIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRf
TE04MzMzIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfTUFYNzM1OSBpcyBub3Qgc2V0CiMg
Q09ORklHX0tFWUJPQVJEX01DUyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX01QUjEyMSBp
cyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX05FV1RPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
WUJPQVJEX09QRU5DT1JFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1NBTVNVTkcgaXMg
bm90IHNldAojIENPTkZJR19LRVlCT0FSRF9TVE9XQVdBWSBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
WUJPQVJEX1NVTktCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1RNMl9UT1VDSEtFWSBp
cyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1hUS0JEIGlzIG5vdCBzZXQKQ09ORklHX0lOUFVU
X01PVVNFPXkKQ09ORklHX01PVVNFX1BTMj15CkNPTkZJR19NT1VTRV9QUzJfQUxQUz15CkNPTkZJ
R19NT1VTRV9QUzJfQllEPXkKQ09ORklHX01PVVNFX1BTMl9MT0dJUFMyUFA9eQpDT05GSUdfTU9V
U0VfUFMyX1NZTkFQVElDUz15CkNPTkZJR19NT1VTRV9QUzJfU1lOQVBUSUNTX1NNQlVTPXkKQ09O
RklHX01PVVNFX1BTMl9DWVBSRVNTPXkKQ09ORklHX01PVVNFX1BTMl9MSUZFQk9PSz15CkNPTkZJ
R19NT1VTRV9QUzJfVFJBQ0tQT0lOVD15CiMgQ09ORklHX01PVVNFX1BTMl9FTEFOVEVDSCBpcyBu
b3Qgc2V0CiMgQ09ORklHX01PVVNFX1BTMl9TRU5URUxJQyBpcyBub3Qgc2V0CiMgQ09ORklHX01P
VVNFX1BTMl9UT1VDSEtJVCBpcyBub3Qgc2V0CkNPTkZJR19NT1VTRV9QUzJfRk9DQUxURUNIPXkK
IyBDT05GSUdfTU9VU0VfUFMyX1ZNTU9VU0UgaXMgbm90IHNldApDT05GSUdfTU9VU0VfUFMyX1NN
QlVTPXkKIyBDT05GSUdfTU9VU0VfU0VSSUFMIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfQVBQ
TEVUT1VDSCBpcyBub3Qgc2V0CiMgQ09ORklHX01PVVNFX0JDTTU5NzQgaXMgbm90IHNldAojIENP
TkZJR19NT1VTRV9DWUFQQSBpcyBub3Qgc2V0CiMgQ09ORklHX01PVVNFX0VMQU5fSTJDIGlzIG5v
dCBzZXQKIyBDT05GSUdfTU9VU0VfVlNYWFhBQSBpcyBub3Qgc2V0CiMgQ09ORklHX01PVVNFX1NZ
TkFQVElDU19JMkMgaXMgbm90IHNldAojIENPTkZJR19NT1VTRV9TWU5BUFRJQ1NfVVNCIGlzIG5v
dCBzZXQKQ09ORklHX0lOUFVUX0pPWVNUSUNLPXkKIyBDT05GSUdfSk9ZU1RJQ0tfQU5BTE9HIGlz
IG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfQTNEIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJ
Q0tfQURJIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfQ09CUkEgaXMgbm90IHNldAojIENP
TkZJR19KT1lTVElDS19HRjJLIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfR1JJUCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0pPWVNUSUNLX0dSSVBfTVAgaXMgbm90IHNldAojIENPTkZJR19KT1lT
VElDS19HVUlMTEVNT1QgaXMgbm90IHNldAojIENPTkZJR19KT1lTVElDS19JTlRFUkFDVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0pPWVNUSUNLX1NJREVXSU5ERVIgaXMgbm90IHNldAojIENPTkZJR19K
T1lTVElDS19UTURDIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfSUZPUkNFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSk9ZU1RJQ0tfV0FSUklPUiBpcyBub3Qgc2V0CiMgQ09ORklHX0pPWVNUSUNL
X01BR0VMTEFOIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfU1BBQ0VPUkIgaXMgbm90IHNl
dAojIENPTkZJR19KT1lTVElDS19TUEFDRUJBTEwgaXMgbm90IHNldAojIENPTkZJR19KT1lTVElD
S19TVElOR0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfSk9ZU1RJQ0tfVFdJREpPWSBpcyBub3Qgc2V0
CiMgQ09ORklHX0pPWVNUSUNLX1pIRU5IVUEgaXMgbm90IHNldAojIENPTkZJR19KT1lTVElDS19B
UzUwMTEgaXMgbm90IHNldAojIENPTkZJR19KT1lTVElDS19KT1lEVU1QIGlzIG5vdCBzZXQKIyBD
T05GSUdfSk9ZU1RJQ0tfWFBBRCBpcyBub3Qgc2V0CiMgQ09ORklHX0pPWVNUSUNLX1BYUkMgaXMg
bm90IHNldApDT05GSUdfSU5QVVRfVEFCTEVUPXkKIyBDT05GSUdfVEFCTEVUX1VTQl9BQ0VDQUQg
aXMgbm90IHNldAojIENPTkZJR19UQUJMRVRfVVNCX0FJUFRFSyBpcyBub3Qgc2V0CiMgQ09ORklH
X1RBQkxFVF9VU0JfR1RDTyBpcyBub3Qgc2V0CiMgQ09ORklHX1RBQkxFVF9VU0JfSEFOV0FORyBp
cyBub3Qgc2V0CiMgQ09ORklHX1RBQkxFVF9VU0JfS0JUQUIgaXMgbm90IHNldAojIENPTkZJR19U
QUJMRVRfVVNCX1BFR0FTVVMgaXMgbm90IHNldAojIENPTkZJR19UQUJMRVRfU0VSSUFMX1dBQ09N
NCBpcyBub3Qgc2V0CkNPTkZJR19JTlBVVF9UT1VDSFNDUkVFTj15CkNPTkZJR19UT1VDSFNDUkVF
Tl9QUk9QRVJUSUVTPXkKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fQUQ3ODc5IGlzIG5vdCBzZXQKIyBD
T05GSUdfVE9VQ0hTQ1JFRU5fQVRNRUxfTVhUIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JF
RU5fQlUyMTAxMyBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX0JVMjEwMjkgaXMgbm90
IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9DSElQT05FX0lDTjg1MDUgaXMgbm90IHNldAojIENP
TkZJR19UT1VDSFNDUkVFTl9DWVRUU1BfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NS
RUVOX0NZVFRTUDRfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX0RZTkFQUk8g
aXMgbm90IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9IQU1QU0hJUkUgaXMgbm90IHNldAojIENP
TkZJR19UT1VDSFNDUkVFTl9FRVRJIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fRUdB
TEFYX1NFUklBTCBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX0VYQzMwMDAgaXMgbm90
IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9GVUpJVFNVIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9V
Q0hTQ1JFRU5fSElERUVQIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fSUxJMjEwWCBp
cyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1M2U1k3NjEgaXMgbm90IHNldAojIENPTkZJ
R19UT1VDSFNDUkVFTl9HVU5aRSBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX0VLVEYy
MTI3IGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fRUxBTiBpcyBub3Qgc2V0CiMgQ09O
RklHX1RPVUNIU0NSRUVOX0VMTyBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1dBQ09N
X1c4MDAxIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fV0FDT01fSTJDIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fTUFYMTE4MDEgaXMgbm90IHNldAojIENPTkZJR19UT1VD
SFNDUkVFTl9NQ1M1MDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fTU1TMTE0IGlz
IG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fTUVMRkFTX01JUDQgaXMgbm90IHNldAojIENP
TkZJR19UT1VDSFNDUkVFTl9NVE9VQ0ggaXMgbm90IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9J
TkVYSU8gaXMgbm90IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9NSzcxMiBpcyBub3Qgc2V0CiMg
Q09ORklHX1RPVUNIU0NSRUVOX1BFTk1PVU5UIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JF
RU5fRURUX0ZUNVgwNiBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1RPVUNIUklHSFQg
aXMgbm90IHNldAojIENPTkZJR19UT1VDSFNDUkVFTl9UT1VDSFdJTiBpcyBub3Qgc2V0CiMgQ09O
RklHX1RPVUNIU0NSRUVOX1BJWENJUiBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1dE
VDg3WFhfSTJDIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fVVNCX0NPTVBPU0lURSBp
cyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1RPVUNISVQyMTMgaXMgbm90IHNldAojIENP
TkZJR19UT1VDSFNDUkVFTl9UU0NfU0VSSU8gaXMgbm90IHNldAojIENPTkZJR19UT1VDSFNDUkVF
Tl9UU0MyMDA0IGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fVFNDMjAwNyBpcyBub3Qg
c2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1NJTEVBRCBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNI
U0NSRUVOX1NUMTIzMiBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1NUTUZUUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1NYODY1NCBpcyBub3Qgc2V0CiMgQ09ORklHX1RP
VUNIU0NSRUVOX1RQUzY1MDdYIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fWkVUNjIy
MyBpcyBub3Qgc2V0CiMgQ09ORklHX1RPVUNIU0NSRUVOX1JPSE1fQlUyMTAyMyBpcyBub3Qgc2V0
CiMgQ09ORklHX1RPVUNIU0NSRUVOX0lRUzVYWCBpcyBub3Qgc2V0CkNPTkZJR19JTlBVVF9NSVND
PXkKIyBDT05GSUdfSU5QVVRfQUQ3MTRYIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfQk1BMTUw
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfRTNYMF9CVVRUT04gaXMgbm90IHNldAojIENPTkZJ
R19JTlBVVF9NU01fVklCUkFUT1IgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9QQ1NQS1IgaXMg
bm90IHNldAojIENPTkZJR19JTlBVVF9NTUE4NDUwIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRf
QVBBTkVMIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfQVRMQVNfQlROUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0lOUFVUX0FUSV9SRU1PVEUyIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfS0VZU1BB
Tl9SRU1PVEUgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9LWFRKOSBpcyBub3Qgc2V0CiMgQ09O
RklHX0lOUFVUX1BPV0VSTUFURSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX1lFQUxJTksgaXMg
bm90IHNldAojIENPTkZJR19JTlBVVF9DTTEwOSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX1VJ
TlBVVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX1BDRjg1NzQgaXMgbm90IHNldAojIENPTkZJ
R19JTlBVVF9BRFhMMzRYIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfSU1TX1BDVSBpcyBub3Qg
c2V0CiMgQ09ORklHX0lOUFVUX0NNQTMwMDAgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9JREVB
UEFEX1NMSURFQkFSIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfRFJWMjY2NV9IQVBUSUNTIGlz
IG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfRFJWMjY2N19IQVBUSUNTIGlzIG5vdCBzZXQKIyBDT05G
SUdfUk1JNF9DT1JFIGlzIG5vdCBzZXQKCiMKIyBIYXJkd2FyZSBJL08gcG9ydHMKIwpDT05GSUdf
U0VSSU89eQpDT05GSUdfQVJDSF9NSUdIVF9IQVZFX1BDX1NFUklPPXkKQ09ORklHX1NFUklPX0k4
MDQyPXkKQ09ORklHX1NFUklPX1NFUlBPUlQ9eQojIENPTkZJR19TRVJJT19DVDgyQzcxMCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFUklPX1BDSVBTMiBpcyBub3Qgc2V0CkNPTkZJR19TRVJJT19MSUJQ
UzI9eQojIENPTkZJR19TRVJJT19SQVcgaXMgbm90IHNldAojIENPTkZJR19TRVJJT19BTFRFUkFf
UFMyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSU9fUFMyTVVMVCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NFUklPX0FSQ19QUzIgaXMgbm90IHNldAojIENPTkZJR19VU0VSSU8gaXMgbm90IHNldAojIENP
TkZJR19HQU1FUE9SVCBpcyBub3Qgc2V0CiMgZW5kIG9mIEhhcmR3YXJlIEkvTyBwb3J0cwojIGVu
ZCBvZiBJbnB1dCBkZXZpY2Ugc3VwcG9ydAoKIwojIENoYXJhY3RlciBkZXZpY2VzCiMKQ09ORklH
X1RUWT15CkNPTkZJR19WVD15CkNPTkZJR19DT05TT0xFX1RSQU5TTEFUSU9OUz15CkNPTkZJR19W
VF9DT05TT0xFPXkKQ09ORklHX1ZUX0NPTlNPTEVfU0xFRVA9eQpDT05GSUdfSFdfQ09OU09MRT15
CkNPTkZJR19WVF9IV19DT05TT0xFX0JJTkRJTkc9eQpDT05GSUdfVU5JWDk4X1BUWVM9eQojIENP
TkZJR19MRUdBQ1lfUFRZUyBpcyBub3Qgc2V0CkNPTkZJR19TRVJJQUxfTk9OU1RBTkRBUkQ9eQoj
IENPTkZJR19ST0NLRVRQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1lDTEFERVMgaXMgbm90IHNl
dAojIENPTkZJR19NT1hBX0lOVEVMTElPIGlzIG5vdCBzZXQKIyBDT05GSUdfTU9YQV9TTUFSVElP
IGlzIG5vdCBzZXQKIyBDT05GSUdfU1lOQ0xJTksgaXMgbm90IHNldAojIENPTkZJR19TWU5DTElO
S01QIGlzIG5vdCBzZXQKIyBDT05GSUdfU1lOQ0xJTktfR1QgaXMgbm90IHNldAojIENPTkZJR19O
T1pPTUkgaXMgbm90IHNldAojIENPTkZJR19JU0kgaXMgbm90IHNldAojIENPTkZJR19OX0hETEMg
aXMgbm90IHNldAojIENPTkZJR19OX0dTTSBpcyBub3Qgc2V0CiMgQ09ORklHX1RSQUNFX1NJTksg
aXMgbm90IHNldAojIENPTkZJR19OVUxMX1RUWSBpcyBub3Qgc2V0CkNPTkZJR19MRElTQ19BVVRP
TE9BRD15CkNPTkZJR19ERVZNRU09eQojIENPTkZJR19ERVZLTUVNIGlzIG5vdCBzZXQKCiMKIyBT
ZXJpYWwgZHJpdmVycwojCkNPTkZJR19TRVJJQUxfRUFSTFlDT049eQpDT05GSUdfU0VSSUFMXzgy
NTA9eQpDT05GSUdfU0VSSUFMXzgyNTBfREVQUkVDQVRFRF9PUFRJT05TPXkKQ09ORklHX1NFUklB
TF84MjUwX1BOUD15CiMgQ09ORklHX1NFUklBTF84MjUwX0ZJTlRFSyBpcyBub3Qgc2V0CkNPTkZJ
R19TRVJJQUxfODI1MF9DT05TT0xFPXkKQ09ORklHX1NFUklBTF84MjUwX0RNQT15CkNPTkZJR19T
RVJJQUxfODI1MF9QQ0k9eQpDT05GSUdfU0VSSUFMXzgyNTBfRVhBUj15CiMgQ09ORklHX1NFUklB
TF84MjUwX0NTIGlzIG5vdCBzZXQKQ09ORklHX1NFUklBTF84MjUwX05SX1VBUlRTPTMyCkNPTkZJ
R19TRVJJQUxfODI1MF9SVU5USU1FX1VBUlRTPTQKQ09ORklHX1NFUklBTF84MjUwX0VYVEVOREVE
PXkKQ09ORklHX1NFUklBTF84MjUwX01BTllfUE9SVFM9eQpDT05GSUdfU0VSSUFMXzgyNTBfU0hB
UkVfSVJRPXkKQ09ORklHX1NFUklBTF84MjUwX0RFVEVDVF9JUlE9eQpDT05GSUdfU0VSSUFMXzgy
NTBfUlNBPXkKIyBDT05GSUdfU0VSSUFMXzgyNTBfRFcgaXMgbm90IHNldAojIENPTkZJR19TRVJJ
QUxfODI1MF9SVDI4OFggaXMgbm90IHNldApDT05GSUdfU0VSSUFMXzgyNTBfTFBTUz15CkNPTkZJ
R19TRVJJQUxfODI1MF9NSUQ9eQojIENPTkZJR19TRVJJQUxfODI1MF9NT1hBIGlzIG5vdCBzZXQK
CiMKIyBOb24tODI1MCBzZXJpYWwgcG9ydCBzdXBwb3J0CiMKIyBDT05GSUdfU0VSSUFMX1VBUlRM
SVRFIGlzIG5vdCBzZXQKQ09ORklHX1NFUklBTF9DT1JFPXkKQ09ORklHX1NFUklBTF9DT1JFX0NP
TlNPTEU9eQojIENPTkZJR19TRVJJQUxfSlNNIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX1ND
Q05YUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklBTF9TQzE2SVM3WFggaXMgbm90IHNldAojIENP
TkZJR19TRVJJQUxfQUxURVJBX0pUQUdVQVJUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX0FM
VEVSQV9VQVJUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX0FSQyBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFUklBTF9SUDIgaXMgbm90IHNldAojIENPTkZJR19TRVJJQUxfRlNMX0xQVUFSVCBpcyBu
b3Qgc2V0CiMgZW5kIG9mIFNlcmlhbCBkcml2ZXJzCgojIENPTkZJR19TRVJJQUxfREVWX0JVUyBp
cyBub3Qgc2V0CkNPTkZJR19IVkNfRFJJVkVSPXkKQ09ORklHX1ZJUlRJT19DT05TT0xFPXkKIyBD
T05GSUdfSVBNSV9IQU5ETEVSIGlzIG5vdCBzZXQKQ09ORklHX0hXX1JBTkRPTT15CiMgQ09ORklH
X0hXX1JBTkRPTV9USU1FUklPTUVNIGlzIG5vdCBzZXQKIyBDT05GSUdfSFdfUkFORE9NX0lOVEVM
IGlzIG5vdCBzZXQKIyBDT05GSUdfSFdfUkFORE9NX0FNRCBpcyBub3Qgc2V0CkNPTkZJR19IV19S
QU5ET01fVklBPXkKIyBDT05GSUdfSFdfUkFORE9NX1ZJUlRJTyBpcyBub3Qgc2V0CkNPTkZJR19O
VlJBTT15CiMgQ09ORklHX0FQUExJQ09NIGlzIG5vdCBzZXQKCiMKIyBQQ01DSUEgY2hhcmFjdGVy
IGRldmljZXMKIwojIENPTkZJR19TWU5DTElOS19DUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NBUkRN
QU5fNDAwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0NBUkRNQU5fNDA0MCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NDUjI0WCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQV0lSRUxFU1MgaXMgbm90IHNldAojIGVu
ZCBvZiBQQ01DSUEgY2hhcmFjdGVyIGRldmljZXMKCiMgQ09ORklHX01XQVZFIGlzIG5vdCBzZXQK
IyBDT05GSUdfUkFXX0RSSVZFUiBpcyBub3Qgc2V0CkNPTkZJR19IUEVUPXkKIyBDT05GSUdfSFBF
VF9NTUFQIGlzIG5vdCBzZXQKIyBDT05GSUdfSEFOR0NIRUNLX1RJTUVSIGlzIG5vdCBzZXQKIyBD
T05GSUdfVENHX1RQTSBpcyBub3Qgc2V0CiMgQ09ORklHX1RFTENMT0NLIGlzIG5vdCBzZXQKQ09O
RklHX0RFVlBPUlQ9eQojIENPTkZJR19YSUxMWUJVUyBpcyBub3Qgc2V0CiMgZW5kIG9mIENoYXJh
Y3RlciBkZXZpY2VzCgojIENPTkZJR19SQU5ET01fVFJVU1RfQ1BVIGlzIG5vdCBzZXQKCiMKIyBJ
MkMgc3VwcG9ydAojCkNPTkZJR19JMkM9eQpDT05GSUdfQUNQSV9JMkNfT1BSRUdJT049eQpDT05G
SUdfSTJDX0JPQVJESU5GTz15CkNPTkZJR19JMkNfQ09NUEFUPXkKIyBDT05GSUdfSTJDX0NIQVJE
RVYgaXMgbm90IHNldAojIENPTkZJR19JMkNfTVVYIGlzIG5vdCBzZXQKQ09ORklHX0kyQ19IRUxQ
RVJfQVVUTz15CkNPTkZJR19JMkNfU01CVVM9eQpDT05GSUdfSTJDX0FMR09CSVQ9eQoKIwojIEky
QyBIYXJkd2FyZSBCdXMgc3VwcG9ydAojCgojCiMgUEMgU01CdXMgaG9zdCBjb250cm9sbGVyIGRy
aXZlcnMKIwojIENPTkZJR19JMkNfQUxJMTUzNSBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19BTEkx
NTYzIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0FMSTE1WDMgaXMgbm90IHNldAojIENPTkZJR19J
MkNfQU1ENzU2IGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0FNRDgxMTEgaXMgbm90IHNldAojIENP
TkZJR19JMkNfQU1EX01QMiBpcyBub3Qgc2V0CkNPTkZJR19JMkNfSTgwMT15CiMgQ09ORklHX0ky
Q19JU0NIIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0lTTVQgaXMgbm90IHNldAojIENPTkZJR19J
MkNfUElJWDQgaXMgbm90IHNldAojIENPTkZJR19JMkNfTkZPUkNFMiBpcyBub3Qgc2V0CiMgQ09O
RklHX0kyQ19OVklESUFfR1BVIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1NJUzU1OTUgaXMgbm90
IHNldAojIENPTkZJR19JMkNfU0lTNjMwIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1NJUzk2WCBp
cyBub3Qgc2V0CiMgQ09ORklHX0kyQ19WSUEgaXMgbm90IHNldAojIENPTkZJR19JMkNfVklBUFJP
IGlzIG5vdCBzZXQKCiMKIyBBQ1BJIGRyaXZlcnMKIwojIENPTkZJR19JMkNfU0NNSSBpcyBub3Qg
c2V0CgojCiMgSTJDIHN5c3RlbSBidXMgZHJpdmVycyAobW9zdGx5IGVtYmVkZGVkIC8gc3lzdGVt
LW9uLWNoaXApCiMKIyBDT05GSUdfSTJDX0RFU0lHTldBUkVfUExBVEZPUk0gaXMgbm90IHNldAoj
IENPTkZJR19JMkNfREVTSUdOV0FSRV9QQ0kgaXMgbm90IHNldAojIENPTkZJR19JMkNfRU1FVjIg
aXMgbm90IHNldAojIENPTkZJR19JMkNfT0NPUkVTIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1BD
QV9QTEFURk9STSBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19TSU1URUMgaXMgbm90IHNldAojIENP
TkZJR19JMkNfWElMSU5YIGlzIG5vdCBzZXQKCiMKIyBFeHRlcm5hbCBJMkMvU01CdXMgYWRhcHRl
ciBkcml2ZXJzCiMKIyBDT05GSUdfSTJDX0RJT0xBTl9VMkMgaXMgbm90IHNldAojIENPTkZJR19J
MkNfUEFSUE9SVF9MSUdIVCBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19ST0JPVEZVWlpfT1NJRiBp
cyBub3Qgc2V0CiMgQ09ORklHX0kyQ19UQU9TX0VWTSBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19U
SU5ZX1VTQiBpcyBub3Qgc2V0CgojCiMgT3RoZXIgSTJDL1NNQnVzIGJ1cyBkcml2ZXJzCiMKIyBD
T05GSUdfSTJDX01MWENQTEQgaXMgbm90IHNldAojIGVuZCBvZiBJMkMgSGFyZHdhcmUgQnVzIHN1
cHBvcnQKCiMgQ09ORklHX0kyQ19TVFVCIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1NMQVZFIGlz
IG5vdCBzZXQKIyBDT05GSUdfSTJDX0RFQlVHX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19JMkNf
REVCVUdfQUxHTyBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19ERUJVR19CVVMgaXMgbm90IHNldAoj
IGVuZCBvZiBJMkMgc3VwcG9ydAoKIyBDT05GSUdfSTNDIGlzIG5vdCBzZXQKIyBDT05GSUdfU1BJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfU1BNSSBpcyBub3Qgc2V0CiMgQ09ORklHX0hTSSBpcyBub3Qg
c2V0CkNPTkZJR19QUFM9eQojIENPTkZJR19QUFNfREVCVUcgaXMgbm90IHNldAoKIwojIFBQUyBj
bGllbnRzIHN1cHBvcnQKIwojIENPTkZJR19QUFNfQ0xJRU5UX0tUSU1FUiBpcyBub3Qgc2V0CiMg
Q09ORklHX1BQU19DTElFTlRfTERJU0MgaXMgbm90IHNldAojIENPTkZJR19QUFNfQ0xJRU5UX0dQ
SU8gaXMgbm90IHNldAoKIwojIFBQUyBnZW5lcmF0b3JzIHN1cHBvcnQKIwoKIwojIFBUUCBjbG9j
ayBzdXBwb3J0CiMKQ09ORklHX1BUUF8xNTg4X0NMT0NLPXkKCiMKIyBFbmFibGUgUEhZTElCIGFu
ZCBORVRXT1JLX1BIWV9USU1FU1RBTVBJTkcgdG8gc2VlIHRoZSBhZGRpdGlvbmFsIGNsb2Nrcy4K
IwpDT05GSUdfUFRQXzE1ODhfQ0xPQ0tfS1ZNPXkKIyBlbmQgb2YgUFRQIGNsb2NrIHN1cHBvcnQK
CiMgQ09ORklHX1BJTkNUUkwgaXMgbm90IHNldAojIENPTkZJR19HUElPTElCIGlzIG5vdCBzZXQK
IyBDT05GSUdfVzEgaXMgbm90IHNldAojIENPTkZJR19QT1dFUl9BVlMgaXMgbm90IHNldAojIENP
TkZJR19QT1dFUl9SRVNFVCBpcyBub3Qgc2V0CkNPTkZJR19QT1dFUl9TVVBQTFk9eQojIENPTkZJ
R19QT1dFUl9TVVBQTFlfREVCVUcgaXMgbm90IHNldApDT05GSUdfUE9XRVJfU1VQUExZX0hXTU9O
PXkKIyBDT05GSUdfUERBX1BPV0VSIGlzIG5vdCBzZXQKQ09ORklHX1RFU1RfUE9XRVI9bQojIENP
TkZJR19DSEFSR0VSX0FEUDUwNjEgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX0RTMjc4MCBp
cyBub3Qgc2V0CiMgQ09ORklHX0JBVFRFUllfRFMyNzgxIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFU
VEVSWV9EUzI3ODIgaXMgbm90IHNldAojIENPTkZJR19CQVRURVJZX1NCUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0NIQVJHRVJfU0JTIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFUVEVSWV9CUTI3WFhYIGlz
IG5vdCBzZXQKIyBDT05GSUdfQkFUVEVSWV9NQVgxNzA0MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JB
VFRFUllfTUFYMTcwNDIgaXMgbm90IHNldAojIENPTkZJR19DSEFSR0VSX01BWDg5MDMgaXMgbm90
IHNldAojIENPTkZJR19DSEFSR0VSX0xQODcyNyBpcyBub3Qgc2V0CiMgQ09ORklHX0NIQVJHRVJf
QlEyNDE1WCBpcyBub3Qgc2V0CiMgQ09ORklHX0NIQVJHRVJfU01CMzQ3IGlzIG5vdCBzZXQKIyBD
T05GSUdfQkFUVEVSWV9HQVVHRV9MVEMyOTQxIGlzIG5vdCBzZXQKQ09ORklHX0hXTU9OPXkKIyBD
T05GSUdfSFdNT05fREVCVUdfQ0hJUCBpcyBub3Qgc2V0CgojCiMgTmF0aXZlIGRyaXZlcnMKIwoj
IENPTkZJR19TRU5TT1JTX0FCSVRVR1VSVSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQUJJ
VFVHVVJVMyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQUQ3NDE0IGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VOU09SU19BRDc0MTggaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FETTEwMjEg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FETTEwMjUgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0FETTEwMjYgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FETTEwMjkgaXMgbm90
IHNldAojIENPTkZJR19TRU5TT1JTX0FETTEwMzEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JT
X0FETTkyNDAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FEVDc0MTAgaXMgbm90IHNldAoj
IENPTkZJR19TRU5TT1JTX0FEVDc0MTEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FEVDc0
NjIgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FEVDc0NzAgaXMgbm90IHNldAojIENPTkZJ
R19TRU5TT1JTX0FEVDc0NzUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FTQzc2MjEgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX0s4VEVNUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfSzEwVEVNUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRkFNMTVIX1BPV0VSIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0VOU09SU19BUFBMRVNNQyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfQVNCMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BU1BFRUQgaXMgbm90IHNldAoj
IENPTkZJR19TRU5TT1JTX0FUWFAxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19EUzYyMCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRFMxNjIxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VO
U09SU19ERUxMX1NNTSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfSTVLX0FNQiBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfRjcxODA1RiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNf
RjcxODgyRkcgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0Y3NTM3NVMgaXMgbm90IHNldAoj
IENPTkZJR19TRU5TT1JTX0ZTQ0hNRCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRlRTVEVV
VEFURVMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0dMNTE4U00gaXMgbm90IHNldAojIENP
TkZJR19TRU5TT1JTX0dMNTIwU00gaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0c3NjBBIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19HNzYyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19ISUg2MTMwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19JNTUwMCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfQ09SRVRFTVAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0lUODcg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0pDNDIgaXMgbm90IHNldAojIENPTkZJR19TRU5T
T1JTX1BPV1IxMjIwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MSU5FQUdFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19MVEMyOTQ1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19M
VEMyOTkwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MTUxIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VOU09SU19MVEM0MjE1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjIy
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjQ1IGlzIG5vdCBzZXQKIyBDT05GSUdf
U0VOU09SU19MVEM0MjYwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjYxIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0VOU09SU19NQVgxNjA2NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfTUFYMTYxOSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUFYMTY2OCBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfTUFYMTk3IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19NQVg2
NjIxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19NQVg2NjM5IGlzIG5vdCBzZXQKIyBDT05G
SUdfU0VOU09SU19NQVg2NjQyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19NQVg2NjUwIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19NQVg2Njk3IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VO
U09SU19NQVgzMTc5MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUNQMzAyMSBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfVEM2NTQgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xN
NjMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNNzMgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0xNNzUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNNzcgaXMgbm90IHNldAoj
IENPTkZJR19TRU5TT1JTX0xNNzggaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNODAgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNODMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JT
X0xNODUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNODcgaXMgbm90IHNldAojIENPTkZJ
R19TRU5TT1JTX0xNOTAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNOTIgaXMgbm90IHNl
dAojIENPTkZJR19TRU5TT1JTX0xNOTMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNOTUy
MzQgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0xNOTUyNDEgaXMgbm90IHNldAojIENPTkZJ
R19TRU5TT1JTX0xNOTUyNDUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1BDODczNjAgaXMg
bm90IHNldAojIENPTkZJR19TRU5TT1JTX1BDODc0MjcgaXMgbm90IHNldAojIENPTkZJR19TRU5T
T1JTX05UQ19USEVSTUlTVE9SIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19OQ1Q2NjgzIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19OQ1Q2Nzc1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VO
U09SU19OQ1Q3ODAyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19OQ1Q3OTA0IGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19OUENNN1hYIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19Q
Q0Y4NTkxIGlzIG5vdCBzZXQKIyBDT05GSUdfUE1CVVMgaXMgbm90IHNldAojIENPTkZJR19TRU5T
T1JTX1NIVDIxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19TSFQzeCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfU0hUQzEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1NJUzU1OTUg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0RNRTE3MzcgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX0VNQzE0MDMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0VNQzIxMDMgaXMgbm90
IHNldAojIENPTkZJR19TRU5TT1JTX0VNQzZXMjAxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19TTVNDNDdNMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfU01TQzQ3TTE5MiBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfU01TQzQ3QjM5NyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfU0NINTYyNyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfU0NINTYzNiBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfU1RUUzc1MSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfU01N
NjY1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BREMxMjhEODE4IGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VOU09SU19BRFMxMDE1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BRFM3ODI4
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BTUM2ODIxIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0VOU09SU19JTkEyMDkgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0lOQTJYWCBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfSU5BMzIyMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNf
VEM3NCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVEhNQzUwIGlzIG5vdCBzZXQKIyBDT05G
SUdfU0VOU09SU19UTVAxMDIgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1RNUDEwMyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVE1QMTA4IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19UTVA0MDEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1RNUDQyMSBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfVklBX0NQVVRFTVAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1ZJ
QTY4NkEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1ZUMTIxMSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfVlQ4MjMxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19XODM3NzNHIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19XODM3ODFEIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VO
U09SU19XODM3OTFEIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19XODM3OTJEIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19XODM3OTMgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1c4
Mzc5NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVzgzTDc4NVRTIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VOU09SU19XODNMNzg2TkcgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1c4MzYy
N0hGIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19XODM2MjdFSEYgaXMgbm90IHNldAojIENP
TkZJR19TRU5TT1JTX1hHRU5FIGlzIG5vdCBzZXQKCiMKIyBBQ1BJIGRyaXZlcnMKIwojIENPTkZJ
R19TRU5TT1JTX0FDUElfUE9XRVIgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FUSzAxMTAg
aXMgbm90IHNldApDT05GSUdfVEhFUk1BTD15CiMgQ09ORklHX1RIRVJNQUxfU1RBVElTVElDUyBp
cyBub3Qgc2V0CkNPTkZJR19USEVSTUFMX0VNRVJHRU5DWV9QT1dFUk9GRl9ERUxBWV9NUz0wCkNP
TkZJR19USEVSTUFMX0hXTU9OPXkKQ09ORklHX1RIRVJNQUxfV1JJVEFCTEVfVFJJUFM9eQpDT05G
SUdfVEhFUk1BTF9ERUZBVUxUX0dPVl9TVEVQX1dJU0U9eQojIENPTkZJR19USEVSTUFMX0RFRkFV
TFRfR09WX0ZBSVJfU0hBUkUgaXMgbm90IHNldAojIENPTkZJR19USEVSTUFMX0RFRkFVTFRfR09W
X1VTRVJfU1BBQ0UgaXMgbm90IHNldAojIENPTkZJR19USEVSTUFMX0RFRkFVTFRfR09WX1BPV0VS
X0FMTE9DQVRPUiBpcyBub3Qgc2V0CiMgQ09ORklHX1RIRVJNQUxfR09WX0ZBSVJfU0hBUkUgaXMg
bm90IHNldApDT05GSUdfVEhFUk1BTF9HT1ZfU1RFUF9XSVNFPXkKIyBDT05GSUdfVEhFUk1BTF9H
T1ZfQkFOR19CQU5HIGlzIG5vdCBzZXQKQ09ORklHX1RIRVJNQUxfR09WX1VTRVJfU1BBQ0U9eQoj
IENPTkZJR19USEVSTUFMX0dPVl9QT1dFUl9BTExPQ0FUT1IgaXMgbm90IHNldAojIENPTkZJR19U
SEVSTUFMX0VNVUxBVElPTiBpcyBub3Qgc2V0CgojCiMgSW50ZWwgdGhlcm1hbCBkcml2ZXJzCiMK
IyBDT05GSUdfSU5URUxfUE9XRVJDTEFNUCBpcyBub3Qgc2V0CkNPTkZJR19YODZfUEtHX1RFTVBf
VEhFUk1BTD1tCiMgQ09ORklHX0lOVEVMX1NPQ19EVFNfVEhFUk1BTCBpcyBub3Qgc2V0CgojCiMg
QUNQSSBJTlQzNDBYIHRoZXJtYWwgZHJpdmVycwojCiMgQ09ORklHX0lOVDM0MFhfVEhFUk1BTCBp
cyBub3Qgc2V0CiMgZW5kIG9mIEFDUEkgSU5UMzQwWCB0aGVybWFsIGRyaXZlcnMKCiMgQ09ORklH
X0lOVEVMX1BDSF9USEVSTUFMIGlzIG5vdCBzZXQKIyBlbmQgb2YgSW50ZWwgdGhlcm1hbCBkcml2
ZXJzCgpDT05GSUdfV0FUQ0hET0c9eQojIENPTkZJR19XQVRDSERPR19DT1JFIGlzIG5vdCBzZXQK
IyBDT05GSUdfV0FUQ0hET0dfTk9XQVlPVVQgaXMgbm90IHNldApDT05GSUdfV0FUQ0hET0dfSEFO
RExFX0JPT1RfRU5BQkxFRD15CkNPTkZJR19XQVRDSERPR19PUEVOX1RJTUVPVVQ9MAojIENPTkZJ
R19XQVRDSERPR19TWVNGUyBpcyBub3Qgc2V0CgojCiMgV2F0Y2hkb2cgUHJldGltZW91dCBHb3Zl
cm5vcnMKIwoKIwojIFdhdGNoZG9nIERldmljZSBEcml2ZXJzCiMKIyBDT05GSUdfU09GVF9XQVRD
SERPRyBpcyBub3Qgc2V0CiMgQ09ORklHX1dEQVRfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfWElM
SU5YX1dBVENIRE9HIGlzIG5vdCBzZXQKIyBDT05GSUdfWklJUkFWRV9XQVRDSERPRyBpcyBub3Qg
c2V0CiMgQ09ORklHX0NBREVOQ0VfV0FUQ0hET0cgaXMgbm90IHNldAojIENPTkZJR19EV19XQVRD
SERPRyBpcyBub3Qgc2V0CiMgQ09ORklHX01BWDYzWFhfV0FUQ0hET0cgaXMgbm90IHNldAojIENP
TkZJR19BQ1FVSVJFX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FEVkFOVEVDSF9XRFQgaXMgbm90
IHNldAojIENPTkZJR19BTElNMTUzNV9XRFQgaXMgbm90IHNldAojIENPTkZJR19BTElNNzEwMV9X
RFQgaXMgbm90IHNldAojIENPTkZJR19FQkNfQzM4NF9XRFQgaXMgbm90IHNldAojIENPTkZJR19G
NzE4MDhFX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NQNTEwMF9UQ08gaXMgbm90IHNldAojIENP
TkZJR19TQkNfRklUUEMyX1dBVENIRE9HIGlzIG5vdCBzZXQKIyBDT05GSUdfRVVST1RFQ0hfV0RU
IGlzIG5vdCBzZXQKIyBDT05GSUdfSUI3MDBfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfSUJNQVNS
IGlzIG5vdCBzZXQKIyBDT05GSUdfV0FGRVJfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfSTYzMDBF
U0JfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfSUU2WFhfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdf
SVRDT19XRFQgaXMgbm90IHNldAojIENPTkZJR19JVDg3MTJGX1dEVCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lUODdfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfSFBfV0FUQ0hET0cgaXMgbm90IHNldAoj
IENPTkZJR19TQzEyMDBfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfUEM4NzQxM19XRFQgaXMgbm90
IHNldAojIENPTkZJR19OVl9UQ08gaXMgbm90IHNldAojIENPTkZJR182MFhYX1dEVCBpcyBub3Qg
c2V0CiMgQ09ORklHX0NQVTVfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfU01TQ19TQ0gzMTFYX1dE
VCBpcyBub3Qgc2V0CiMgQ09ORklHX1NNU0MzN0I3ODdfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdf
VFFNWDg2X1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJQV9XRFQgaXMgbm90IHNldAojIENPTkZJ
R19XODM2MjdIRl9XRFQgaXMgbm90IHNldAojIENPTkZJR19XODM4NzdGX1dEVCBpcyBub3Qgc2V0
CiMgQ09ORklHX1c4Mzk3N0ZfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFDSFpfV0RUIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0JDX0VQWF9DM19XQVRDSERPRyBpcyBub3Qgc2V0CiMgQ09ORklHX05J
OTAzWF9XRFQgaXMgbm90IHNldAojIENPTkZJR19OSUM3MDE4X1dEVCBpcyBub3Qgc2V0CgojCiMg
UENJLWJhc2VkIFdhdGNoZG9nIENhcmRzCiMKIyBDT05GSUdfUENJUENXQVRDSERPRyBpcyBub3Qg
c2V0CiMgQ09ORklHX1dEVFBDSSBpcyBub3Qgc2V0CgojCiMgVVNCLWJhc2VkIFdhdGNoZG9nIENh
cmRzCiMKIyBDT05GSUdfVVNCUENXQVRDSERPRyBpcyBub3Qgc2V0CkNPTkZJR19TU0JfUE9TU0lC
TEU9eQojIENPTkZJR19TU0IgaXMgbm90IHNldApDT05GSUdfQkNNQV9QT1NTSUJMRT15CiMgQ09O
RklHX0JDTUEgaXMgbm90IHNldAoKIwojIE11bHRpZnVuY3Rpb24gZGV2aWNlIGRyaXZlcnMKIwoj
IENPTkZJR19NRkRfQVMzNzExIGlzIG5vdCBzZXQKIyBDT05GSUdfUE1JQ19BRFA1NTIwIGlzIG5v
dCBzZXQKIyBDT05GSUdfTUZEX0JDTTU5MFhYIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0JEOTU3
MU1XViBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9BWFAyMFhfSTJDIGlzIG5vdCBzZXQKIyBDT05G
SUdfTUZEX0NST1NfRUMgaXMgbm90IHNldAojIENPTkZJR19NRkRfTUFERVJBIGlzIG5vdCBzZXQK
IyBDT05GSUdfUE1JQ19EQTkwM1ggaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5MDUyX0kyQyBp
cyBub3Qgc2V0CiMgQ09ORklHX01GRF9EQTkwNTUgaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5
MDYyIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0RBOTA2MyBpcyBub3Qgc2V0CiMgQ09ORklHX01G
RF9EQTkxNTAgaXMgbm90IHNldAojIENPTkZJR19NRkRfRExOMiBpcyBub3Qgc2V0CiMgQ09ORklH
X01GRF9NQzEzWFhYX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX0hUQ19QQVNJQzMgaXMgbm90IHNl
dAojIENPTkZJR19NRkRfSU5URUxfUVVBUktfSTJDX0dQSU8gaXMgbm90IHNldAojIENPTkZJR19M
UENfSUNIIGlzIG5vdCBzZXQKIyBDT05GSUdfTFBDX1NDSCBpcyBub3Qgc2V0CiMgQ09ORklHX01G
RF9JTlRFTF9MUFNTX0FDUEkgaXMgbm90IHNldAojIENPTkZJR19NRkRfSU5URUxfTFBTU19QQ0kg
aXMgbm90IHNldAojIENPTkZJR19NRkRfSkFOWl9DTU9ESU8gaXMgbm90IHNldAojIENPTkZJR19N
RkRfS0VNUExEIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEXzg4UE04MDAgaXMgbm90IHNldAojIENP
TkZJR19NRkRfODhQTTgwNSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF84OFBNODYwWCBpcyBub3Qg
c2V0CiMgQ09ORklHX01GRF9NQVgxNDU3NyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQVg3NzY5
MyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQVg3Nzg0MyBpcyBub3Qgc2V0CiMgQ09ORklHX01G
RF9NQVg4OTA3IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01BWDg5MjUgaXMgbm90IHNldAojIENP
TkZJR19NRkRfTUFYODk5NyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQVg4OTk4IGlzIG5vdCBz
ZXQKIyBDT05GSUdfTUZEX01UNjM5NyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NRU5GMjFCTUMg
aXMgbm90IHNldAojIENPTkZJR19NRkRfVklQRVJCT0FSRCBpcyBub3Qgc2V0CiMgQ09ORklHX01G
RF9SRVRVIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1BDRjUwNjMzIGlzIG5vdCBzZXQKIyBDT05G
SUdfTUZEX1JEQzMyMVggaXMgbm90IHNldAojIENPTkZJR19NRkRfUlQ1MDMzIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUZEX1JDNVQ1ODMgaXMgbm90IHNldAojIENPTkZJR19NRkRfU0VDX0NPUkUgaXMg
bm90IHNldAojIENPTkZJR19NRkRfU0k0NzZYX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19NRkRf
U001MDEgaXMgbm90IHNldAojIENPTkZJR19NRkRfU0tZODE0NTIgaXMgbm90IHNldAojIENPTkZJ
R19NRkRfU01TQyBpcyBub3Qgc2V0CiMgQ09ORklHX0FCWDUwMF9DT1JFIGlzIG5vdCBzZXQKIyBD
T05GSUdfTUZEX1NZU0NPTiBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9USV9BTTMzNVhfVFNDQURD
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0xQMzk0MyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9M
UDg3ODggaXMgbm90IHNldAojIENPTkZJR19NRkRfVElfTE1VIGlzIG5vdCBzZXQKIyBDT05GSUdf
TUZEX1BBTE1BUyBpcyBub3Qgc2V0CiMgQ09ORklHX1RQUzYxMDVYIGlzIG5vdCBzZXQKIyBDT05G
SUdfVFBTNjUwN1ggaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjUwODYgaXMgbm90IHNldAoj
IENPTkZJR19NRkRfVFBTNjUwOTAgaXMgbm90IHNldAojIENPTkZJR19NRkRfVElfTFA4NzNYIGlz
IG5vdCBzZXQKIyBDT05GSUdfTUZEX1RQUzY1ODZYIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1RQ
UzY1OTEyX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9UUFM4MDAzMSBpcyBub3Qgc2V0CiMg
Q09ORklHX1RXTDQwMzBfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX1RXTDYwNDBfQ09SRSBpcyBu
b3Qgc2V0CiMgQ09ORklHX01GRF9XTDEyNzNfQ09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9M
TTM1MzMgaXMgbm90IHNldAojIENPTkZJR19NRkRfVFFNWDg2IGlzIG5vdCBzZXQKIyBDT05GSUdf
TUZEX1ZYODU1IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0FSSVpPTkFfSTJDIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUZEX1dNODQwMCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9XTTgzMVhfSTJDIGlz
IG5vdCBzZXQKIyBDT05GSUdfTUZEX1dNODM1MF9JMkMgaXMgbm90IHNldAojIENPTkZJR19NRkRf
V004OTk0IGlzIG5vdCBzZXQKIyBlbmQgb2YgTXVsdGlmdW5jdGlvbiBkZXZpY2UgZHJpdmVycwoK
IyBDT05GSUdfUkVHVUxBVE9SIGlzIG5vdCBzZXQKIyBDT05GSUdfUkNfQ09SRSBpcyBub3Qgc2V0
CiMgQ09ORklHX01FRElBX1NVUFBPUlQgaXMgbm90IHNldAoKIwojIEdyYXBoaWNzIHN1cHBvcnQK
IwpDT05GSUdfQUdQPXkKQ09ORklHX0FHUF9BTUQ2ND15CkNPTkZJR19BR1BfSU5URUw9eQojIENP
TkZJR19BR1BfU0lTIGlzIG5vdCBzZXQKIyBDT05GSUdfQUdQX1ZJQSBpcyBub3Qgc2V0CkNPTkZJ
R19JTlRFTF9HVFQ9eQpDT05GSUdfVkdBX0FSQj15CkNPTkZJR19WR0FfQVJCX01BWF9HUFVTPTE2
CiMgQ09ORklHX1ZHQV9TV0lUQ0hFUk9PIGlzIG5vdCBzZXQKQ09ORklHX0RSTT15CkNPTkZJR19E
Uk1fTUlQSV9EU0k9eQojIENPTkZJR19EUk1fRFBfQVVYX0NIQVJERVYgaXMgbm90IHNldAojIENP
TkZJR19EUk1fREVCVUdfTU0gaXMgbm90IHNldAojIENPTkZJR19EUk1fREVCVUdfU0VMRlRFU1Qg
aXMgbm90IHNldApDT05GSUdfRFJNX0tNU19IRUxQRVI9eQpDT05GSUdfRFJNX0tNU19GQl9IRUxQ
RVI9eQpDT05GSUdfRFJNX0ZCREVWX0VNVUxBVElPTj15CkNPTkZJR19EUk1fRkJERVZfT1ZFUkFM
TE9DPTEwMAojIENPTkZJR19EUk1fTE9BRF9FRElEX0ZJUk1XQVJFIGlzIG5vdCBzZXQKIyBDT05G
SUdfRFJNX0RQX0NFQyBpcyBub3Qgc2V0CkNPTkZJR19EUk1fVFRNPXkKCiMKIyBJMkMgZW5jb2Rl
ciBvciBoZWxwZXIgY2hpcHMKIwojIENPTkZJR19EUk1fSTJDX0NINzAwNiBpcyBub3Qgc2V0CiMg
Q09ORklHX0RSTV9JMkNfU0lMMTY0IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX0kyQ19OWFBfVERB
OTk4WCBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9JMkNfTlhQX1REQTk5NTAgaXMgbm90IHNldAoj
IGVuZCBvZiBJMkMgZW5jb2RlciBvciBoZWxwZXIgY2hpcHMKCiMKIyBBUk0gZGV2aWNlcwojCiMg
ZW5kIG9mIEFSTSBkZXZpY2VzCgojIENPTkZJR19EUk1fUkFERU9OIGlzIG5vdCBzZXQKIyBDT05G
SUdfRFJNX0FNREdQVSBpcyBub3Qgc2V0CgojCiMgQUNQIChBdWRpbyBDb1Byb2Nlc3NvcikgQ29u
ZmlndXJhdGlvbgojCiMgZW5kIG9mIEFDUCAoQXVkaW8gQ29Qcm9jZXNzb3IpIENvbmZpZ3VyYXRp
b24KCiMgQ09ORklHX0RSTV9OT1VWRUFVIGlzIG5vdCBzZXQKQ09ORklHX0RSTV9JOTE1PXkKIyBD
T05GSUdfRFJNX0k5MTVfQUxQSEFfU1VQUE9SVCBpcyBub3Qgc2V0CkNPTkZJR19EUk1fSTkxNV9G
T1JDRV9QUk9CRT0iIgpDT05GSUdfRFJNX0k5MTVfQ0FQVFVSRV9FUlJPUj15CkNPTkZJR19EUk1f
STkxNV9DT01QUkVTU19FUlJPUj15CkNPTkZJR19EUk1fSTkxNV9VU0VSUFRSPXkKIyBDT05GSUdf
RFJNX0k5MTVfR1ZUIGlzIG5vdCBzZXQKQ09ORklHX0RSTV9JOTE1X1VTRVJGQVVMVF9BVVRPU1VT
UEVORD0yNTAKQ09ORklHX0RSTV9JOTE1X1NQSU5fUkVRVUVTVD01CiMgQ09ORklHX0RSTV9WR0VN
IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1ZLTVMgaXMgbm90IHNldAojIENPTkZJR19EUk1fVk1X
R0ZYIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX0dNQTUwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0RS
TV9VREwgaXMgbm90IHNldAojIENPTkZJR19EUk1fQVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJN
X01HQUcyMDAgaXMgbm90IHNldAojIENPTkZJR19EUk1fQ0lSUlVTX1FFTVUgaXMgbm90IHNldAoj
IENPTkZJR19EUk1fUVhMIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX0JPQ0hTIGlzIG5vdCBzZXQK
Q09ORklHX0RSTV9WSVJUSU9fR1BVPXkKQ09ORklHX0RSTV9QQU5FTD15CgojCiMgRGlzcGxheSBQ
YW5lbHMKIwojIENPTkZJR19EUk1fUEFORUxfUkFTUEJFUlJZUElfVE9VQ0hTQ1JFRU4gaXMgbm90
IHNldAojIGVuZCBvZiBEaXNwbGF5IFBhbmVscwoKQ09ORklHX0RSTV9CUklER0U9eQpDT05GSUdf
RFJNX1BBTkVMX0JSSURHRT15CgojCiMgRGlzcGxheSBJbnRlcmZhY2UgQnJpZGdlcwojCiMgQ09O
RklHX0RSTV9BTkFMT0dJWF9BTlg3OFhYIGlzIG5vdCBzZXQKIyBlbmQgb2YgRGlzcGxheSBJbnRl
cmZhY2UgQnJpZGdlcwoKIyBDT05GSUdfRFJNX0VUTkFWSVYgaXMgbm90IHNldAojIENPTkZJR19E
Uk1fSElTSV9ISUJNQyBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9USU5ZRFJNIGlzIG5vdCBzZXQK
IyBDT05GSUdfRFJNX1ZCT1hWSURFTyBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9MRUdBQ1kgaXMg
bm90IHNldApDT05GSUdfRFJNX1BBTkVMX09SSUVOVEFUSU9OX1FVSVJLUz15CgojCiMgRnJhbWUg
YnVmZmVyIERldmljZXMKIwpDT05GSUdfRkJfQ01ETElORT15CkNPTkZJR19GQl9OT1RJRlk9eQpD
T05GSUdfRkI9eQojIENPTkZJR19GSVJNV0FSRV9FRElEIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0NG
Ql9GSUxMUkVDVD15CkNPTkZJR19GQl9DRkJfQ09QWUFSRUE9eQpDT05GSUdfRkJfQ0ZCX0lNQUdF
QkxJVD15CkNPTkZJR19GQl9TWVNfRklMTFJFQ1Q9eQpDT05GSUdfRkJfU1lTX0NPUFlBUkVBPXkK
Q09ORklHX0ZCX1NZU19JTUFHRUJMSVQ9eQojIENPTkZJR19GQl9GT1JFSUdOX0VORElBTiBpcyBu
b3Qgc2V0CkNPTkZJR19GQl9TWVNfRk9QUz15CkNPTkZJR19GQl9ERUZFUlJFRF9JTz15CkNPTkZJ
R19GQl9NT0RFX0hFTFBFUlM9eQpDT05GSUdfRkJfVElMRUJMSVRUSU5HPXkKCiMKIyBGcmFtZSBi
dWZmZXIgaGFyZHdhcmUgZHJpdmVycwojCiMgQ09ORklHX0ZCX0NJUlJVUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0ZCX1BNMiBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0NZQkVSMjAwMCBpcyBub3Qgc2V0
CiMgQ09ORklHX0ZCX0FSQyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0FTSUxJQU5UIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRkJfSU1TVFQgaXMgbm90IHNldAojIENPTkZJR19GQl9WR0ExNiBpcyBub3Qg
c2V0CiMgQ09ORklHX0ZCX1VWRVNBIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVkVTQSBpcyBub3Qg
c2V0CkNPTkZJR19GQl9FRkk9eQojIENPTkZJR19GQl9ONDExIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkJfSEdBIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfT1BFTkNPUkVTIGlzIG5vdCBzZXQKIyBDT05G
SUdfRkJfUzFEMTNYWFggaXMgbm90IHNldAojIENPTkZJR19GQl9OVklESUEgaXMgbm90IHNldAoj
IENPTkZJR19GQl9SSVZBIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfSTc0MCBpcyBub3Qgc2V0CiMg
Q09ORklHX0ZCX0xFODA1NzggaXMgbm90IHNldAojIENPTkZJR19GQl9NQVRST1ggaXMgbm90IHNl
dAojIENPTkZJR19GQl9SQURFT04gaXMgbm90IHNldAojIENPTkZJR19GQl9BVFkxMjggaXMgbm90
IHNldAojIENPTkZJR19GQl9BVFkgaXMgbm90IHNldAojIENPTkZJR19GQl9TMyBpcyBub3Qgc2V0
CiMgQ09ORklHX0ZCX1NBVkFHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NJUyBpcyBub3Qgc2V0
CiMgQ09ORklHX0ZCX05FT01BR0lDIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfS1lSTyBpcyBub3Qg
c2V0CiMgQ09ORklHX0ZCXzNERlggaXMgbm90IHNldAojIENPTkZJR19GQl9WT09ET08xIGlzIG5v
dCBzZXQKIyBDT05GSUdfRkJfVlQ4NjIzIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVFJJREVOVCBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX0FSSyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1BNMyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0ZCX0NBUk1JTkUgaXMgbm90IHNldAojIENPTkZJR19GQl9TTVNDVUZY
IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVURMIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfSUJNX0dY
VDQ1MDAgaXMgbm90IHNldAojIENPTkZJR19GQl9WSVJUVUFMIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkJfTUVUUk9OT01FIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfTUI4NjJYWCBpcyBub3Qgc2V0CiMg
Q09ORklHX0ZCX1NJTVBMRSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NNNzEyIGlzIG5vdCBzZXQK
IyBlbmQgb2YgRnJhbWUgYnVmZmVyIERldmljZXMKCiMKIyBCYWNrbGlnaHQgJiBMQ0QgZGV2aWNl
IHN1cHBvcnQKIwojIENPTkZJR19MQ0RfQ0xBU1NfREVWSUNFIGlzIG5vdCBzZXQKQ09ORklHX0JB
Q0tMSUdIVF9DTEFTU19ERVZJQ0U9eQpDT05GSUdfQkFDS0xJR0hUX0dFTkVSSUM9eQojIENPTkZJ
R19CQUNLTElHSFRfQVBQTEUgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfUE04OTQxX1dM
RUQgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfU0FIQVJBIGlzIG5vdCBzZXQKIyBDT05G
SUdfQkFDS0xJR0hUX0FEUDg4NjAgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfQURQODg3
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0JBQ0tMSUdIVF9MTTM2MzkgaXMgbm90IHNldAojIENPTkZJ
R19CQUNLTElHSFRfTFY1MjA3TFAgaXMgbm90IHNldAojIENPTkZJR19CQUNLTElHSFRfQkQ2MTA3
IGlzIG5vdCBzZXQKIyBDT05GSUdfQkFDS0xJR0hUX0FSQ1hDTk4gaXMgbm90IHNldAojIGVuZCBv
ZiBCYWNrbGlnaHQgJiBMQ0QgZGV2aWNlIHN1cHBvcnQKCkNPTkZJR19IRE1JPXkKCiMKIyBDb25z
b2xlIGRpc3BsYXkgZHJpdmVyIHN1cHBvcnQKIwpDT05GSUdfVkdBX0NPTlNPTEU9eQpDT05GSUdf
VkdBQ09OX1NPRlRfU0NST0xMQkFDSz15CkNPTkZJR19WR0FDT05fU09GVF9TQ1JPTExCQUNLX1NJ
WkU9NjQKIyBDT05GSUdfVkdBQ09OX1NPRlRfU0NST0xMQkFDS19QRVJTSVNURU5UX0VOQUJMRV9C
WV9ERUZBVUxUIGlzIG5vdCBzZXQKQ09ORklHX0RVTU1ZX0NPTlNPTEU9eQpDT05GSUdfRFVNTVlf
Q09OU09MRV9DT0xVTU5TPTgwCkNPTkZJR19EVU1NWV9DT05TT0xFX1JPV1M9MjUKQ09ORklHX0ZS
QU1FQlVGRkVSX0NPTlNPTEU9eQpDT05GSUdfRlJBTUVCVUZGRVJfQ09OU09MRV9ERVRFQ1RfUFJJ
TUFSWT15CiMgQ09ORklHX0ZSQU1FQlVGRkVSX0NPTlNPTEVfUk9UQVRJT04gaXMgbm90IHNldAoj
IENPTkZJR19GUkFNRUJVRkZFUl9DT05TT0xFX0RFRkVSUkVEX1RBS0VPVkVSIGlzIG5vdCBzZXQK
IyBlbmQgb2YgQ29uc29sZSBkaXNwbGF5IGRyaXZlciBzdXBwb3J0CgpDT05GSUdfTE9HTz15CiMg
Q09ORklHX0xPR09fTElOVVhfTU9OTyBpcyBub3Qgc2V0CiMgQ09ORklHX0xPR09fTElOVVhfVkdB
MTYgaXMgbm90IHNldApDT05GSUdfTE9HT19MSU5VWF9DTFVUMjI0PXkKIyBlbmQgb2YgR3JhcGhp
Y3Mgc3VwcG9ydAoKQ09ORklHX1NPVU5EPXkKQ09ORklHX1NORD15CkNPTkZJR19TTkRfVElNRVI9
eQpDT05GSUdfU05EX1BDTT15CkNPTkZJR19TTkRfSFdERVA9eQpDT05GSUdfU05EX1NFUV9ERVZJ
Q0U9eQpDT05GSUdfU05EX0pBQ0s9eQpDT05GSUdfU05EX0pBQ0tfSU5QVVRfREVWPXkKIyBDT05G
SUdfU05EX09TU0VNVUwgaXMgbm90IHNldApDT05GSUdfU05EX1BDTV9USU1FUj15CkNPTkZJR19T
TkRfSFJUSU1FUj15CiMgQ09ORklHX1NORF9EWU5BTUlDX01JTk9SUyBpcyBub3Qgc2V0CkNPTkZJ
R19TTkRfU1VQUE9SVF9PTERfQVBJPXkKQ09ORklHX1NORF9QUk9DX0ZTPXkKQ09ORklHX1NORF9W
RVJCT1NFX1BST0NGUz15CiMgQ09ORklHX1NORF9WRVJCT1NFX1BSSU5USyBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19TTkRfVk1BU1RFUj15CkNPTkZJR19T
TkRfRE1BX1NHQlVGPXkKQ09ORklHX1NORF9TRVFVRU5DRVI9eQpDT05GSUdfU05EX1NFUV9EVU1N
WT15CkNPTkZJR19TTkRfU0VRX0hSVElNRVJfREVGQVVMVD15CkNPTkZJR19TTkRfRFJJVkVSUz15
CiMgQ09ORklHX1NORF9QQ1NQIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0RVTU1ZIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0FMT09QIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1ZJUk1JREkgaXMg
bm90IHNldAojIENPTkZJR19TTkRfTVRQQVYgaXMgbm90IHNldAojIENPTkZJR19TTkRfU0VSSUFM
X1UxNjU1MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9NUFU0MDEgaXMgbm90IHNldApDT05GSUdf
U05EX1BDST15CiMgQ09ORklHX1NORF9BRDE4ODkgaXMgbm90IHNldAojIENPTkZJR19TTkRfQUxT
MzAwIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FMUzQwMDAgaXMgbm90IHNldAojIENPTkZJR19T
TkRfQUxJNTQ1MSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9BU0lIUEkgaXMgbm90IHNldAojIENP
TkZJR19TTkRfQVRJSVhQIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FUSUlYUF9NT0RFTSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9BVTg4MTAgaXMgbm90IHNldAojIENPTkZJR19TTkRfQVU4ODIw
IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FVODgzMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9B
VzIgaXMgbm90IHNldAojIENPTkZJR19TTkRfQVpUMzMyOCBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9CVDg3WCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9DQTAxMDYgaXMgbm90IHNldAojIENPTkZJ
R19TTkRfQ01JUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX09YWUdFTiBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9DUzQyODEgaXMgbm90IHNldAojIENPTkZJR19TTkRfQ1M0NlhYIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0NUWEZJIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0RBUkxBMjAgaXMg
bm90IHNldAojIENPTkZJR19TTkRfR0lOQTIwIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0xBWUxB
MjAgaXMgbm90IHNldAojIENPTkZJR19TTkRfREFSTEEyNCBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9HSU5BMjQgaXMgbm90IHNldAojIENPTkZJR19TTkRfTEFZTEEyNCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9NT05BIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX01JQSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9FQ0hPM0cgaXMgbm90IHNldAojIENPTkZJR19TTkRfSU5ESUdPIGlzIG5vdCBzZXQK
IyBDT05GSUdfU05EX0lORElHT0lPIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0lORElHT0RKIGlz
IG5vdCBzZXQKIyBDT05GSUdfU05EX0lORElHT0lPWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9J
TkRJR09ESlggaXMgbm90IHNldAojIENPTkZJR19TTkRfRU1VMTBLMSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9FTVUxMEsxWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9FTlMxMzcwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0VOUzEzNzEgaXMgbm90IHNldAojIENPTkZJR19TTkRfRVMxOTM4IGlz
IG5vdCBzZXQKIyBDT05GSUdfU05EX0VTMTk2OCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9GTTgw
MSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9IRFNQIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hE
U1BNIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0lDRTE3MTIgaXMgbm90IHNldAojIENPTkZJR19T
TkRfSUNFMTcyNCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9JTlRFTDhYMCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9JTlRFTDhYME0gaXMgbm90IHNldAojIENPTkZJR19TTkRfS09SRzEyMTIgaXMg
bm90IHNldAojIENPTkZJR19TTkRfTE9MQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9MWDY0NjRF
UyBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9NQUVTVFJPMyBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9NSVhBUlQgaXMgbm90IHNldAojIENPTkZJR19TTkRfTk0yNTYgaXMgbm90IHNldAojIENPTkZJ
R19TTkRfUENYSFIgaXMgbm90IHNldAojIENPTkZJR19TTkRfUklQVElERSBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9STUUzMiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9STUU5NiBpcyBub3Qgc2V0
CiMgQ09ORklHX1NORF9STUU5NjUyIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1NFNlggaXMgbm90
IHNldAojIENPTkZJR19TTkRfU09OSUNWSUJFUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9UUklE
RU5UIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1ZJQTgyWFggaXMgbm90IHNldAojIENPTkZJR19T
TkRfVklBODJYWF9NT0RFTSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9WSVJUVU9TTyBpcyBub3Qg
c2V0CiMgQ09ORklHX1NORF9WWDIyMiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9ZTUZQQ0kgaXMg
bm90IHNldAoKIwojIEhELUF1ZGlvCiMKQ09ORklHX1NORF9IREE9eQpDT05GSUdfU05EX0hEQV9J
TlRFTD15CkNPTkZJR19TTkRfSERBX0hXREVQPXkKIyBDT05GSUdfU05EX0hEQV9SRUNPTkZJRyBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfSU5QVVRfQkVFUCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NORF9IREFfUEFUQ0hfTE9BREVSIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19S
RUFMVEVLIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19BTkFMT0cgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfSERBX0NPREVDX1NJR01BVEVMIGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X0hEQV9DT0RFQ19WSUEgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERBX0NPREVDX0hETUkgaXMg
bm90IHNldAojIENPTkZJR19TTkRfSERBX0NPREVDX0NJUlJVUyBpcyBub3Qgc2V0CiMgQ09ORklH
X1NORF9IREFfQ09ERUNfQ09ORVhBTlQgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERBX0NPREVD
X0NBMDExMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfQ09ERUNfQ0EwMTMyIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19DTUVESUEgaXMgbm90IHNldAojIENPTkZJR19TTkRf
SERBX0NPREVDX1NJMzA1NCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfR0VORVJJQyBpcyBu
b3Qgc2V0CkNPTkZJR19TTkRfSERBX1BPV0VSX1NBVkVfREVGQVVMVD0wCiMgZW5kIG9mIEhELUF1
ZGlvCgpDT05GSUdfU05EX0hEQV9DT1JFPXkKQ09ORklHX1NORF9IREFfQ09NUE9ORU5UPXkKQ09O
RklHX1NORF9IREFfSTkxNT15CkNPTkZJR19TTkRfSERBX1BSRUFMTE9DX1NJWkU9NjQKQ09ORklH
X1NORF9VU0I9eQojIENPTkZJR19TTkRfVVNCX0FVRElPIGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X1VTQl9VQTEwMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfVVNYMlkgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfVVNCX0NBSUFRIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1VTQl9VUzEyMkwg
aXMgbm90IHNldAojIENPTkZJR19TTkRfVVNCXzZGSVJFIGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X1VTQl9ISUZBQ0UgaXMgbm90IHNldAojIENPTkZJR19TTkRfQkNEMjAwMCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9VU0JfUE9EIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1VTQl9QT0RIRCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfVE9ORVBPUlQgaXMgbm90IHNldAojIENPTkZJR19TTkRf
VVNCX1ZBUklBWCBpcyBub3Qgc2V0CkNPTkZJR19TTkRfUENNQ0lBPXkKIyBDT05GSUdfU05EX1ZY
UE9DS0VUIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1BEQVVESU9DRiBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9TT0MgaXMgbm90IHNldApDT05GSUdfU05EX1g4Nj15CiMgQ09ORklHX0hETUlfTFBF
X0FVRElPIGlzIG5vdCBzZXQKCiMKIyBISUQgc3VwcG9ydAojCkNPTkZJR19ISUQ9eQojIENPTkZJ
R19ISURfQkFUVEVSWV9TVFJFTkdUSCBpcyBub3Qgc2V0CkNPTkZJR19ISURSQVc9eQojIENPTkZJ
R19VSElEIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9HRU5FUklDPXkKCiMKIyBTcGVjaWFsIEhJRCBk
cml2ZXJzCiMKQ09ORklHX0hJRF9BNFRFQ0g9eQojIENPTkZJR19ISURfQUNDVVRPVUNIIGlzIG5v
dCBzZXQKIyBDT05GSUdfSElEX0FDUlVYIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9BUFBMRT15CiMg
Q09ORklHX0hJRF9BUFBMRUlSIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0FTVVMgaXMgbm90IHNl
dAojIENPTkZJR19ISURfQVVSRUFMIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9CRUxLSU49eQojIENP
TkZJR19ISURfQkVUT1BfRkYgaXMgbm90IHNldAojIENPTkZJR19ISURfQklHQkVOX0ZGIGlzIG5v
dCBzZXQKQ09ORklHX0hJRF9DSEVSUlk9eQpDT05GSUdfSElEX0NISUNPTlk9eQojIENPTkZJR19I
SURfQ09SU0FJUiBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9DT1VHQVIgaXMgbm90IHNldAojIENP
TkZJR19ISURfTUFDQUxMWSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9QUk9ESUtFWVMgaXMgbm90
IHNldAojIENPTkZJR19ISURfQ01FRElBIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9DWVBSRVNTPXkK
IyBDT05GSUdfSElEX0RSQUdPTlJJU0UgaXMgbm90IHNldAojIENPTkZJR19ISURfRU1TX0ZGIGlz
IG5vdCBzZXQKIyBDT05GSUdfSElEX0VMQU4gaXMgbm90IHNldAojIENPTkZJR19ISURfRUxFQ09N
IGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0VMTyBpcyBub3Qgc2V0CkNPTkZJR19ISURfRVpLRVk9
eQojIENPTkZJR19ISURfR0VNQklSRCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9HRlJNIGlzIG5v
dCBzZXQKIyBDT05GSUdfSElEX0hPTFRFSyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9HVDY4M1Ig
aXMgbm90IHNldAojIENPTkZJR19ISURfS0VZVE9VQ0ggaXMgbm90IHNldAojIENPTkZJR19ISURf
S1lFIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1VDTE9HSUMgaXMgbm90IHNldAojIENPTkZJR19I
SURfV0FMVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1ZJRVdTT05JQyBpcyBub3Qgc2V0CkNP
TkZJR19ISURfR1lSQVRJT049eQojIENPTkZJR19ISURfSUNBREUgaXMgbm90IHNldApDT05GSUdf
SElEX0lURT15CiMgQ09ORklHX0hJRF9KQUJSQSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9UV0lO
SEFOIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9LRU5TSU5HVE9OPXkKIyBDT05GSUdfSElEX0xDUE9X
RVIgaXMgbm90IHNldAojIENPTkZJR19ISURfTEVEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0xF
Tk9WTyBpcyBub3Qgc2V0CkNPTkZJR19ISURfTE9HSVRFQ0g9eQojIENPTkZJR19ISURfTE9HSVRF
Q0hfREogaXMgbm90IHNldAojIENPTkZJR19ISURfTE9HSVRFQ0hfSElEUFAgaXMgbm90IHNldApD
T05GSUdfTE9HSVRFQ0hfRkY9eQojIENPTkZJR19MT0dJUlVNQkxFUEFEMl9GRiBpcyBub3Qgc2V0
CiMgQ09ORklHX0xPR0lHOTQwX0ZGIGlzIG5vdCBzZXQKQ09ORklHX0xPR0lXSEVFTFNfRkY9eQoj
IENPTkZJR19ISURfTUFHSUNNT1VTRSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9NQUxUUk9OIGlz
IG5vdCBzZXQKIyBDT05GSUdfSElEX01BWUZMQVNIIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9SRURS
QUdPTj15CkNPTkZJR19ISURfTUlDUk9TT0ZUPXkKQ09ORklHX0hJRF9NT05URVJFWT15CiMgQ09O
RklHX0hJRF9NVUxUSVRPVUNIIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX05USSBpcyBub3Qgc2V0
CkNPTkZJR19ISURfTlRSSUc9eQojIENPTkZJR19ISURfT1JURUsgaXMgbm90IHNldApDT05GSUdf
SElEX1BBTlRIRVJMT1JEPXkKQ09ORklHX1BBTlRIRVJMT1JEX0ZGPXkKIyBDT05GSUdfSElEX1BF
Tk1PVU5UIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9QRVRBTFlOWD15CiMgQ09ORklHX0hJRF9QSUNP
TENEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1BMQU5UUk9OSUNTIGlzIG5vdCBzZXQKIyBDT05G
SUdfSElEX1BSSU1BWCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9SRVRST0RFIGlzIG5vdCBzZXQK
IyBDT05GSUdfSElEX1JPQ0NBVCBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9TQUlURUsgaXMgbm90
IHNldApDT05GSUdfSElEX1NBTVNVTkc9eQpDT05GSUdfSElEX1NPTlk9eQojIENPTkZJR19TT05Z
X0ZGIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1NQRUVETElOSyBpcyBub3Qgc2V0CiMgQ09ORklH
X0hJRF9TVEVBTSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9TVEVFTFNFUklFUyBpcyBub3Qgc2V0
CkNPTkZJR19ISURfU1VOUExVUz15CiMgQ09ORklHX0hJRF9STUkgaXMgbm90IHNldAojIENPTkZJ
R19ISURfR1JFRU5BU0lBIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1NNQVJUSk9ZUExVUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0hJRF9USVZPIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9UT1BTRUVEPXkK
IyBDT05GSUdfSElEX1RISU5HTSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9USFJVU1RNQVNURVIg
aXMgbm90IHNldAojIENPTkZJR19ISURfVURSQVdfUFMzIGlzIG5vdCBzZXQKIyBDT05GSUdfSElE
X1UyRlpFUk8gaXMgbm90IHNldAojIENPTkZJR19ISURfV0FDT00gaXMgbm90IHNldAojIENPTkZJ
R19ISURfV0lJTU9URSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9YSU5NTyBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9aRVJPUExVUyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9aWURBQ1JPTiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0hJRF9TRU5TT1JfSFVCIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0FM
UFMgaXMgbm90IHNldAojIGVuZCBvZiBTcGVjaWFsIEhJRCBkcml2ZXJzCgojCiMgVVNCIEhJRCBz
dXBwb3J0CiMKQ09ORklHX1VTQl9ISUQ9eQpDT05GSUdfSElEX1BJRD15CkNPTkZJR19VU0JfSElE
REVWPXkKIyBlbmQgb2YgVVNCIEhJRCBzdXBwb3J0CgojCiMgSTJDIEhJRCBzdXBwb3J0CiMKIyBD
T05GSUdfSTJDX0hJRCBpcyBub3Qgc2V0CiMgZW5kIG9mIEkyQyBISUQgc3VwcG9ydAoKIwojIElu
dGVsIElTSCBISUQgc3VwcG9ydAojCiMgQ09ORklHX0lOVEVMX0lTSF9ISUQgaXMgbm90IHNldAoj
IGVuZCBvZiBJbnRlbCBJU0ggSElEIHN1cHBvcnQKIyBlbmQgb2YgSElEIHN1cHBvcnQKCkNPTkZJ
R19VU0JfT0hDSV9MSVRUTEVfRU5ESUFOPXkKQ09ORklHX1VTQl9TVVBQT1JUPXkKQ09ORklHX1VT
Ql9DT01NT049eQpDT05GSUdfVVNCX0FSQ0hfSEFTX0hDRD15CkNPTkZJR19VU0I9eQpDT05GSUdf
VVNCX1BDST15CkNPTkZJR19VU0JfQU5OT1VOQ0VfTkVXX0RFVklDRVM9eQoKIwojIE1pc2NlbGxh
bmVvdXMgVVNCIG9wdGlvbnMKIwpDT05GSUdfVVNCX0RFRkFVTFRfUEVSU0lTVD15CiMgQ09ORklH
X1VTQl9EWU5BTUlDX01JTk9SUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9PVEcgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfT1RHX1dISVRFTElTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9MRURT
X1RSSUdHRVJfVVNCUE9SVCBpcyBub3Qgc2V0CkNPTkZJR19VU0JfQVVUT1NVU1BFTkRfREVMQVk9
MgpDT05GSUdfVVNCX01PTj15CiMgQ09ORklHX1VTQl9XVVNCX0NCQUYgaXMgbm90IHNldAoKIwoj
IFVTQiBIb3N0IENvbnRyb2xsZXIgRHJpdmVycwojCiMgQ09ORklHX1VTQl9DNjdYMDBfSENEIGlz
IG5vdCBzZXQKQ09ORklHX1VTQl9YSENJX0hDRD15CiMgQ09ORklHX1VTQl9YSENJX0RCR0NBUCBp
cyBub3Qgc2V0CkNPTkZJR19VU0JfWEhDSV9QQ0k9eQojIENPTkZJR19VU0JfWEhDSV9QTEFURk9S
TSBpcyBub3Qgc2V0CkNPTkZJR19VU0JfRUhDSV9IQ0Q9eQojIENPTkZJR19VU0JfRUhDSV9ST09U
X0hVQl9UVCBpcyBub3Qgc2V0CkNPTkZJR19VU0JfRUhDSV9UVF9ORVdTQ0hFRD15CkNPTkZJR19V
U0JfRUhDSV9QQ0k9eQojIENPTkZJR19VU0JfRUhDSV9GU0wgaXMgbm90IHNldAojIENPTkZJR19V
U0JfRUhDSV9IQ0RfUExBVEZPUk0gaXMgbm90IHNldAojIENPTkZJR19VU0JfT1hVMjEwSFBfSENE
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0lTUDExNlhfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX0ZPVEcyMTBfSENEIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9PSENJX0hDRD15CkNPTkZJR19V
U0JfT0hDSV9IQ0RfUENJPXkKIyBDT05GSUdfVVNCX09IQ0lfSENEX1BMQVRGT1JNIGlzIG5vdCBz
ZXQKQ09ORklHX1VTQl9VSENJX0hDRD15CiMgQ09ORklHX1VTQl9TTDgxMV9IQ0QgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfUjhBNjY1OTdfSENEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0hDRF9U
RVNUX01PREUgaXMgbm90IHNldAoKIwojIFVTQiBEZXZpY2UgQ2xhc3MgZHJpdmVycwojCiMgQ09O
RklHX1VTQl9BQ00gaXMgbm90IHNldApDT05GSUdfVVNCX1BSSU5URVI9eQojIENPTkZJR19VU0Jf
V0RNIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1RNQyBpcyBub3Qgc2V0CgojCiMgTk9URTogVVNC
X1NUT1JBR0UgZGVwZW5kcyBvbiBTQ1NJIGJ1dCBCTEtfREVWX1NEIG1heQojCgojCiMgYWxzbyBi
ZSBuZWVkZWQ7IHNlZSBVU0JfU1RPUkFHRSBIZWxwIGZvciBtb3JlIGluZm8KIwpDT05GSUdfVVNC
X1NUT1JBR0U9eQojIENPTkZJR19VU0JfU1RPUkFHRV9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9TVE9SQUdFX1JFQUxURUsgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9EQVRB
RkFCIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfRlJFRUNPTSBpcyBub3Qgc2V0CiMg
Q09ORklHX1VTQl9TVE9SQUdFX0lTRDIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdF
X1VTQkFUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfU0REUjA5IGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX1NUT1JBR0VfU0REUjU1IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JB
R0VfSlVNUFNIT1QgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9BTEFVREEgaXMgbm90
IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9PTkVUT1VDSCBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9TVE9SQUdFX0tBUk1BIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfQ1lQUkVTU19B
VEFDQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX0VORV9VQjYyNTAgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfVUFTIGlzIG5vdCBzZXQKCiMKIyBVU0IgSW1hZ2luZyBkZXZpY2VzCiMK
IyBDT05GSUdfVVNCX01EQzgwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9NSUNST1RFSyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQklQX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19VU0JfTVVTQl9I
RFJDIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0RXQzMgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
RFdDMiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9DSElQSURFQSBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9JU1AxNzYwIGlzIG5vdCBzZXQKCiMKIyBVU0IgcG9ydCBkcml2ZXJzCiMKIyBDT05GSUdf
VVNCX1NFUklBTCBpcyBub3Qgc2V0CgojCiMgVVNCIE1pc2NlbGxhbmVvdXMgZHJpdmVycwojCiMg
Q09ORklHX1VTQl9FTUk2MiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9FTUkyNiBpcyBub3Qgc2V0
CiMgQ09ORklHX1VTQl9BRFVUVVggaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VWU0VHIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX1JJTzUwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9MRUdPVE9X
RVIgaXMgbm90IHNldAojIENPTkZJR19VU0JfTENEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NZ
UFJFU1NfQ1k3QzYzIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NZVEhFUk0gaXMgbm90IHNldAoj
IENPTkZJR19VU0JfSURNT1VTRSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9GVERJX0VMQU4gaXMg
bm90IHNldAojIENPTkZJR19VU0JfQVBQTEVESVNQTEFZIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X1NJU1VTQlZHQSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9MRCBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9UUkFOQ0VWSUJSQVRPUiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JT1dBUlJJT1IgaXMg
bm90IHNldAojIENPTkZJR19VU0JfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9FSFNFVF9U
RVNUX0ZJWFRVUkUgaXMgbm90IHNldAojIENPTkZJR19VU0JfSVNJR0hURlcgaXMgbm90IHNldAoj
IENPTkZJR19VU0JfWVVSRVggaXMgbm90IHNldAojIENPTkZJR19VU0JfRVpVU0JfRlgyIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX0hVQl9VU0IyNTFYQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9I
U0lDX1VTQjM1MDMgaXMgbm90IHNldAojIENPTkZJR19VU0JfSFNJQ19VU0I0NjA0IGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX0xJTktfTEFZRVJfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9D
SEFPU0tFWSBpcyBub3Qgc2V0CgojCiMgVVNCIFBoeXNpY2FsIExheWVyIGRyaXZlcnMKIwojIENP
TkZJR19OT1BfVVNCX1hDRUlWIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0lTUDEzMDEgaXMgbm90
IHNldAojIGVuZCBvZiBVU0IgUGh5c2ljYWwgTGF5ZXIgZHJpdmVycwoKIyBDT05GSUdfVVNCX0dB
REdFVCBpcyBub3Qgc2V0CiMgQ09ORklHX1RZUEVDIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1JP
TEVfU1dJVENIIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0xFRF9UUklHIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX1VMUElfQlVTIGlzIG5vdCBzZXQKIyBDT05GSUdfVVdCIGlzIG5vdCBzZXQKIyBD
T05GSUdfTU1DIGlzIG5vdCBzZXQKIyBDT05GSUdfTUVNU1RJQ0sgaXMgbm90IHNldApDT05GSUdf
TkVXX0xFRFM9eQpDT05GSUdfTEVEU19DTEFTUz15CiMgQ09ORklHX0xFRFNfQ0xBU1NfRkxBU0gg
aXMgbm90IHNldAojIENPTkZJR19MRURTX0JSSUdIVE5FU1NfSFdfQ0hBTkdFRCBpcyBub3Qgc2V0
CgojCiMgTEVEIGRyaXZlcnMKIwojIENPTkZJR19MRURTX0FQVSBpcyBub3Qgc2V0CiMgQ09ORklH
X0xFRFNfTE0zNTMwIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19MTTM1MzIgaXMgbm90IHNldAoj
IENPTkZJR19MRURTX0xNMzY0MiBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfUENBOTUzMiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0xFRFNfTFAzOTQ0IGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19MUDU1
MjEgaXMgbm90IHNldAojIENPTkZJR19MRURTX0xQNTUyMyBpcyBub3Qgc2V0CiMgQ09ORklHX0xF
RFNfTFA1NTYyIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19MUDg1MDEgaXMgbm90IHNldAojIENP
TkZJR19MRURTX0NMRVZPX01BSUwgaXMgbm90IHNldAojIENPTkZJR19MRURTX1BDQTk1NVggaXMg
bm90IHNldAojIENPTkZJR19MRURTX1BDQTk2M1ggaXMgbm90IHNldAojIENPTkZJR19MRURTX0JE
MjgwMiBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfSU5URUxfU1M0MjAwIGlzIG5vdCBzZXQKIyBD
T05GSUdfTEVEU19UQ0E2NTA3IGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19UTEM1OTFYWCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0xFRFNfTE0zNTV4IGlzIG5vdCBzZXQKCiMKIyBMRUQgZHJpdmVyIGZv
ciBibGluaygxKSBVU0IgUkdCIExFRCBpcyB1bmRlciBTcGVjaWFsIEhJRCBkcml2ZXJzIChISURf
VEhJTkdNKQojCiMgQ09ORklHX0xFRFNfQkxJTktNIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19N
TFhDUExEIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19NTFhSRUcgaXMgbm90IHNldAojIENPTkZJ
R19MRURTX1VTRVIgaXMgbm90IHNldAojIENPTkZJR19MRURTX05JQzc4QlggaXMgbm90IHNldAoj
IENPTkZJR19MRURTX1RJX0xNVV9DT01NT04gaXMgbm90IHNldAoKIwojIExFRCBUcmlnZ2Vycwoj
CkNPTkZJR19MRURTX1RSSUdHRVJTPXkKIyBDT05GSUdfTEVEU19UUklHR0VSX1RJTUVSIGlzIG5v
dCBzZXQKIyBDT05GSUdfTEVEU19UUklHR0VSX09ORVNIT1QgaXMgbm90IHNldAojIENPTkZJR19M
RURTX1RSSUdHRVJfRElTSyBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfVFJJR0dFUl9IRUFSVEJF
QVQgaXMgbm90IHNldAojIENPTkZJR19MRURTX1RSSUdHRVJfQkFDS0xJR0hUIGlzIG5vdCBzZXQK
IyBDT05GSUdfTEVEU19UUklHR0VSX0NQVSBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfVFJJR0dF
Ul9BQ1RJVklUWSBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfVFJJR0dFUl9ERUZBVUxUX09OIGlz
IG5vdCBzZXQKCiMKIyBpcHRhYmxlcyB0cmlnZ2VyIGlzIHVuZGVyIE5ldGZpbHRlciBjb25maWcg
KExFRCB0YXJnZXQpCiMKIyBDT05GSUdfTEVEU19UUklHR0VSX1RSQU5TSUVOVCBpcyBub3Qgc2V0
CiMgQ09ORklHX0xFRFNfVFJJR0dFUl9DQU1FUkEgaXMgbm90IHNldAojIENPTkZJR19MRURTX1RS
SUdHRVJfUEFOSUMgaXMgbm90IHNldAojIENPTkZJR19MRURTX1RSSUdHRVJfTkVUREVWIGlzIG5v
dCBzZXQKIyBDT05GSUdfTEVEU19UUklHR0VSX1BBVFRFUk4gaXMgbm90IHNldAojIENPTkZJR19M
RURTX1RSSUdHRVJfQVVESU8gaXMgbm90IHNldAojIENPTkZJR19BQ0NFU1NJQklMSVRZIGlzIG5v
dCBzZXQKIyBDT05GSUdfSU5GSU5JQkFORCBpcyBub3Qgc2V0CkNPTkZJR19FREFDX0FUT01JQ19T
Q1JVQj15CkNPTkZJR19FREFDX1NVUFBPUlQ9eQpDT05GSUdfRURBQz15CkNPTkZJR19FREFDX0xF
R0FDWV9TWVNGUz15CiMgQ09ORklHX0VEQUNfREVCVUcgaXMgbm90IHNldApDT05GSUdfRURBQ19E
RUNPREVfTUNFPXkKIyBDT05GSUdfRURBQ19BTUQ2NCBpcyBub3Qgc2V0CiMgQ09ORklHX0VEQUNf
RTc1MlggaXMgbm90IHNldAojIENPTkZJR19FREFDX0k4Mjk3NVggaXMgbm90IHNldAojIENPTkZJ
R19FREFDX0kzMDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRURBQ19JMzIwMCBpcyBub3Qgc2V0CiMg
Q09ORklHX0VEQUNfSUUzMTIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0VEQUNfWDM4IGlzIG5vdCBz
ZXQKIyBDT05GSUdfRURBQ19JNTQwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0VEQUNfSTdDT1JFIGlz
IG5vdCBzZXQKIyBDT05GSUdfRURBQ19JNTAwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0VEQUNfSTUx
MDAgaXMgbm90IHNldAojIENPTkZJR19FREFDX0k3MzAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRURB
Q19TQlJJREdFIGlzIG5vdCBzZXQKIyBDT05GSUdfRURBQ19TS1ggaXMgbm90IHNldAojIENPTkZJ
R19FREFDX0kxME5NIGlzIG5vdCBzZXQKIyBDT05GSUdfRURBQ19QTkQyIGlzIG5vdCBzZXQKQ09O
RklHX1JUQ19MSUI9eQpDT05GSUdfUlRDX01DMTQ2ODE4X0xJQj15CkNPTkZJR19SVENfQ0xBU1M9
eQojIENPTkZJR19SVENfSENUT1NZUyBpcyBub3Qgc2V0CkNPTkZJR19SVENfU1lTVE9IQz15CkNP
TkZJR19SVENfU1lTVE9IQ19ERVZJQ0U9InJ0YzAiCiMgQ09ORklHX1JUQ19ERUJVRyBpcyBub3Qg
c2V0CkNPTkZJR19SVENfTlZNRU09eQoKIwojIFJUQyBpbnRlcmZhY2VzCiMKQ09ORklHX1JUQ19J
TlRGX1NZU0ZTPXkKQ09ORklHX1JUQ19JTlRGX1BST0M9eQpDT05GSUdfUlRDX0lOVEZfREVWPXkK
IyBDT05GSUdfUlRDX0lOVEZfREVWX1VJRV9FTVVMIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RS
Vl9URVNUIGlzIG5vdCBzZXQKCiMKIyBJMkMgUlRDIGRyaXZlcnMKIwojIENPTkZJR19SVENfRFJW
X0FCQjVaRVMzIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9BQkVPWjkgaXMgbm90IHNldAoj
IENPTkZJR19SVENfRFJWX0FCWDgwWCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfRFMxMzA3
IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9EUzEzNzQgaXMgbm90IHNldAojIENPTkZJR19S
VENfRFJWX0RTMTY3MiBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTUFYNjkwMCBpcyBub3Qg
c2V0CiMgQ09ORklHX1JUQ19EUlZfUlM1QzM3MiBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZf
SVNMMTIwOCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfSVNMMTIwMjIgaXMgbm90IHNldAoj
IENPTkZJR19SVENfRFJWX1gxMjA1IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9QQ0Y4NTIz
IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9QQ0Y4NTA2MyBpcyBub3Qgc2V0CiMgQ09ORklH
X1JUQ19EUlZfUENGODUzNjMgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1BDRjg1NjMgaXMg
bm90IHNldAojIENPTkZJR19SVENfRFJWX1BDRjg1ODMgaXMgbm90IHNldAojIENPTkZJR19SVENf
RFJWX000MVQ4MCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfQkQ3MDUyOCBpcyBub3Qgc2V0
CiMgQ09ORklHX1JUQ19EUlZfQlEzMksgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1MzNTM5
MEEgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0ZNMzEzMCBpcyBub3Qgc2V0CiMgQ09ORklH
X1JUQ19EUlZfUlg4MDEwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9SWDg1ODEgaXMgbm90
IHNldAojIENPTkZJR19SVENfRFJWX1JYODAyNSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZf
RU0zMDI3IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9SVjMwMjggaXMgbm90IHNldAojIENP
TkZJR19SVENfRFJWX1JWODgwMyBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfU0QzMDc4IGlz
IG5vdCBzZXQKCiMKIyBTUEkgUlRDIGRyaXZlcnMKIwpDT05GSUdfUlRDX0kyQ19BTkRfU1BJPXkK
CiMKIyBTUEkgYW5kIEkyQyBSVEMgZHJpdmVycwojCiMgQ09ORklHX1JUQ19EUlZfRFMzMjMyIGlz
IG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9QQ0YyMTI3IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRD
X0RSVl9SVjMwMjlDMiBpcyBub3Qgc2V0CgojCiMgUGxhdGZvcm0gUlRDIGRyaXZlcnMKIwpDT05G
SUdfUlRDX0RSVl9DTU9TPXkKIyBDT05GSUdfUlRDX0RSVl9EUzEyODYgaXMgbm90IHNldAojIENP
TkZJR19SVENfRFJWX0RTMTUxMSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfRFMxNTUzIGlz
IG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9EUzE2ODVfRkFNSUxZIGlzIG5vdCBzZXQKIyBDT05G
SUdfUlRDX0RSVl9EUzE3NDIgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0RTMjQwNCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfU1RLMTdUQTggaXMgbm90IHNldAojIENPTkZJR19SVENf
RFJWX000OFQ4NiBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTTQ4VDM1IGlzIG5vdCBzZXQK
IyBDT05GSUdfUlRDX0RSVl9NNDhUNTkgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX01TTTYy
NDIgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0JRNDgwMiBpcyBub3Qgc2V0CiMgQ09ORklH
X1JUQ19EUlZfUlA1QzAxIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9WMzAyMCBpcyBub3Qg
c2V0CgojCiMgb24tQ1BVIFJUQyBkcml2ZXJzCiMKIyBDT05GSUdfUlRDX0RSVl9GVFJUQzAxMCBp
cyBub3Qgc2V0CgojCiMgSElEIFNlbnNvciBSVEMgZHJpdmVycwojCkNPTkZJR19ETUFERVZJQ0VT
PXkKIyBDT05GSUdfRE1BREVWSUNFU19ERUJVRyBpcyBub3Qgc2V0CgojCiMgRE1BIERldmljZXMK
IwpDT05GSUdfRE1BX0VOR0lORT15CkNPTkZJR19ETUFfVklSVFVBTF9DSEFOTkVMUz15CkNPTkZJ
R19ETUFfQUNQST15CiMgQ09ORklHX0FMVEVSQV9NU0dETUEgaXMgbm90IHNldAojIENPTkZJR19J
TlRFTF9JRE1BNjQgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9JT0FURE1BIGlzIG5vdCBzZXQK
IyBDT05GSUdfUUNPTV9ISURNQV9NR01UIGlzIG5vdCBzZXQKIyBDT05GSUdfUUNPTV9ISURNQSBp
cyBub3Qgc2V0CkNPTkZJR19EV19ETUFDX0NPUkU9eQojIENPTkZJR19EV19ETUFDIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRFdfRE1BQ19QQ0kgaXMgbm90IHNldAojIENPTkZJR19EV19FRE1BIGlzIG5v
dCBzZXQKIyBDT05GSUdfRFdfRURNQV9QQ0lFIGlzIG5vdCBzZXQKQ09ORklHX0hTVV9ETUE9eQoK
IwojIERNQSBDbGllbnRzCiMKIyBDT05GSUdfQVNZTkNfVFhfRE1BIGlzIG5vdCBzZXQKIyBDT05G
SUdfRE1BVEVTVCBpcyBub3Qgc2V0CgojCiMgRE1BQlVGIG9wdGlvbnMKIwpDT05GSUdfU1lOQ19G
SUxFPXkKIyBDT05GSUdfU1dfU1lOQyBpcyBub3Qgc2V0CiMgQ09ORklHX1VETUFCVUYgaXMgbm90
IHNldAojIGVuZCBvZiBETUFCVUYgb3B0aW9ucwoKIyBDT05GSUdfQVVYRElTUExBWSBpcyBub3Qg
c2V0CiMgQ09ORklHX1VJTyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZGSU8gaXMgbm90IHNldAojIENP
TkZJR19WSVJUX0RSSVZFUlMgaXMgbm90IHNldApDT05GSUdfVklSVElPPXkKQ09ORklHX1ZJUlRJ
T19NRU5VPXkKQ09ORklHX1ZJUlRJT19QQ0k9eQpDT05GSUdfVklSVElPX1BDSV9MRUdBQ1k9eQoj
IENPTkZJR19WSVJUSU9fQkFMTE9PTiBpcyBub3Qgc2V0CkNPTkZJR19WSVJUSU9fSU5QVVQ9eQoj
IENPTkZJR19WSVJUSU9fTU1JTyBpcyBub3Qgc2V0CgojCiMgTWljcm9zb2Z0IEh5cGVyLVYgZ3Vl
c3Qgc3VwcG9ydAojCiMgQ09ORklHX0hZUEVSViBpcyBub3Qgc2V0CiMgZW5kIG9mIE1pY3Jvc29m
dCBIeXBlci1WIGd1ZXN0IHN1cHBvcnQKCiMgQ09ORklHX1NUQUdJTkcgaXMgbm90IHNldApDT05G
SUdfWDg2X1BMQVRGT1JNX0RFVklDRVM9eQojIENPTkZJR19BQ0VSX1dJUkVMRVNTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQUNFUkhERiBpcyBub3Qgc2V0CiMgQ09ORklHX0FTVVNfTEFQVE9QIGlzIG5v
dCBzZXQKIyBDT05GSUdfRENEQkFTIGlzIG5vdCBzZXQKIyBDT05GSUdfREVMTF9TTUJJT1MgaXMg
bm90IHNldAojIENPTkZJR19ERUxMX1NNTzg4MDAgaXMgbm90IHNldAojIENPTkZJR19ERUxMX1JC
VE4gaXMgbm90IHNldAojIENPTkZJR19ERUxMX1JCVSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZVSklU
U1VfTEFQVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfRlVKSVRTVV9UQUJMRVQgaXMgbm90IHNldAoj
IENPTkZJR19BTUlMT19SRktJTEwgaXMgbm90IHNldAojIENPTkZJR19HUERfUE9DS0VUX0ZBTiBp
cyBub3Qgc2V0CiMgQ09ORklHX0hQX0FDQ0VMIGlzIG5vdCBzZXQKIyBDT05GSUdfSFBfV0lSRUxF
U1MgaXMgbm90IHNldAojIENPTkZJR19NU0lfTEFQVE9QIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFO
QVNPTklDX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0NPTVBBTF9MQVBUT1AgaXMgbm90IHNl
dAojIENPTkZJR19TT05ZX0xBUFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lERUFQQURfTEFQVE9Q
IGlzIG5vdCBzZXQKIyBDT05GSUdfVEhJTktQQURfQUNQSSBpcyBub3Qgc2V0CiMgQ09ORklHX1NF
TlNPUlNfSERBUFMgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9NRU5MT1cgaXMgbm90IHNldApD
T05GSUdfRUVFUENfTEFQVE9QPXkKIyBDT05GSUdfQVNVU19XSVJFTEVTUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0FDUElfV01JIGlzIG5vdCBzZXQKIyBDT05GSUdfVE9QU1RBUl9MQVBUT1AgaXMgbm90
IHNldAojIENPTkZJR19UT1NISUJBX0JUX1JGS0lMTCBpcyBub3Qgc2V0CiMgQ09ORklHX1RPU0hJ
QkFfSEFQUyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUElfQ01QQyBpcyBub3Qgc2V0CiMgQ09ORklH
X0lOVEVMX0hJRF9FVkVOVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX1ZCVE4gaXMgbm90IHNl
dAojIENPTkZJR19JTlRFTF9JUFMgaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9QTUNfQ09SRSBp
cyBub3Qgc2V0CiMgQ09ORklHX0lCTV9SVEwgaXMgbm90IHNldAojIENPTkZJR19TQU1TVU5HX0xB
UFRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX09BS1RSQUlMIGlzIG5vdCBzZXQKIyBDT05G
SUdfU0FNU1VOR19RMTAgaXMgbm90IHNldAojIENPTkZJR19BUFBMRV9HTVVYIGlzIG5vdCBzZXQK
IyBDT05GSUdfSU5URUxfUlNUIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5URUxfU01BUlRDT05ORUNU
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU5URUxfUE1DX0lQQyBpcyBub3Qgc2V0CiMgQ09ORklHX1NV
UkZBQ0VfUFJPM19CVVRUT04gaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9QVU5JVF9JUEMgaXMg
bm90IHNldAojIENPTkZJR19NTFhfUExBVEZPUk0gaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9U
VVJCT19NQVhfMyBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19NVUxUSV9JTlNUQU5USUFURSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lOVEVMX0FUT01JU1AyX1BNIGlzIG5vdCBzZXQKCiMKIyBJbnRlbCBT
cGVlZCBTZWxlY3QgVGVjaG5vbG9neSBpbnRlcmZhY2Ugc3VwcG9ydAojCiMgQ09ORklHX0lOVEVM
X1NQRUVEX1NFTEVDVF9JTlRFUkZBQ0UgaXMgbm90IHNldAojIGVuZCBvZiBJbnRlbCBTcGVlZCBT
ZWxlY3QgVGVjaG5vbG9neSBpbnRlcmZhY2Ugc3VwcG9ydAoKQ09ORklHX1BNQ19BVE9NPXkKIyBD
T05GSUdfQ0hST01FX1BMQVRGT1JNUyBpcyBub3Qgc2V0CiMgQ09ORklHX01FTExBTk9YX1BMQVRG
T1JNIGlzIG5vdCBzZXQKQ09ORklHX0NMS0RFVl9MT09LVVA9eQpDT05GSUdfSEFWRV9DTEtfUFJF
UEFSRT15CkNPTkZJR19DT01NT05fQ0xLPXkKCiMKIyBDb21tb24gQ2xvY2sgRnJhbWV3b3JrCiMK
IyBDT05GSUdfQ09NTU9OX0NMS19NQVg5NDg1IGlzIG5vdCBzZXQKIyBDT05GSUdfQ09NTU9OX0NM
S19TSTUzNDEgaXMgbm90IHNldAojIENPTkZJR19DT01NT05fQ0xLX1NJNTM1MSBpcyBub3Qgc2V0
CiMgQ09ORklHX0NPTU1PTl9DTEtfU0k1NDQgaXMgbm90IHNldAojIENPTkZJR19DT01NT05fQ0xL
X0NEQ0U3MDYgaXMgbm90IHNldAojIENPTkZJR19DT01NT05fQ0xLX0NTMjAwMF9DUCBpcyBub3Qg
c2V0CiMgZW5kIG9mIENvbW1vbiBDbG9jayBGcmFtZXdvcmsKCiMgQ09ORklHX0hXU1BJTkxPQ0sg
aXMgbm90IHNldAoKIwojIENsb2NrIFNvdXJjZSBkcml2ZXJzCiMKQ09ORklHX0NMS0VWVF9JODI1
Mz15CkNPTkZJR19JODI1M19MT0NLPXkKQ09ORklHX0NMS0JMRF9JODI1Mz15CiMgZW5kIG9mIENs
b2NrIFNvdXJjZSBkcml2ZXJzCgpDT05GSUdfTUFJTEJPWD15CkNPTkZJR19QQ0M9eQojIENPTkZJ
R19BTFRFUkFfTUJPWCBpcyBub3Qgc2V0CkNPTkZJR19JT01NVV9JT1ZBPXkKQ09ORklHX0lPTU1V
X0FQST15CkNPTkZJR19JT01NVV9TVVBQT1JUPXkKCiMKIyBHZW5lcmljIElPTU1VIFBhZ2V0YWJs
ZSBTdXBwb3J0CiMKIyBlbmQgb2YgR2VuZXJpYyBJT01NVSBQYWdldGFibGUgU3VwcG9ydAoKIyBD
T05GSUdfSU9NTVVfREVCVUdGUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lPTU1VX0RFRkFVTFRfUEFT
U1RIUk9VR0ggaXMgbm90IHNldApDT05GSUdfQU1EX0lPTU1VPXkKIyBDT05GSUdfQU1EX0lPTU1V
X1YyIGlzIG5vdCBzZXQKQ09ORklHX0RNQVJfVEFCTEU9eQpDT05GSUdfSU5URUxfSU9NTVU9eQoj
IENPTkZJR19JTlRFTF9JT01NVV9TVk0gaXMgbm90IHNldAojIENPTkZJR19JTlRFTF9JT01NVV9E
RUZBVUxUX09OIGlzIG5vdCBzZXQKQ09ORklHX0lOVEVMX0lPTU1VX0ZMT1BQWV9XQT15CiMgQ09O
RklHX0lSUV9SRU1BUCBpcyBub3Qgc2V0CgojCiMgUmVtb3RlcHJvYyBkcml2ZXJzCiMKIyBDT05G
SUdfUkVNT1RFUFJPQyBpcyBub3Qgc2V0CiMgZW5kIG9mIFJlbW90ZXByb2MgZHJpdmVycwoKIwoj
IFJwbXNnIGRyaXZlcnMKIwojIENPTkZJR19SUE1TR19RQ09NX0dMSU5LX1JQTSBpcyBub3Qgc2V0
CiMgQ09ORklHX1JQTVNHX1ZJUlRJTyBpcyBub3Qgc2V0CiMgZW5kIG9mIFJwbXNnIGRyaXZlcnMK
CiMgQ09ORklHX1NPVU5EV0lSRSBpcyBub3Qgc2V0CgojCiMgU09DIChTeXN0ZW0gT24gQ2hpcCkg
c3BlY2lmaWMgRHJpdmVycwojCgojCiMgQW1sb2dpYyBTb0MgZHJpdmVycwojCiMgZW5kIG9mIEFt
bG9naWMgU29DIGRyaXZlcnMKCiMKIyBBc3BlZWQgU29DIGRyaXZlcnMKIwojIGVuZCBvZiBBc3Bl
ZWQgU29DIGRyaXZlcnMKCiMKIyBCcm9hZGNvbSBTb0MgZHJpdmVycwojCiMgZW5kIG9mIEJyb2Fk
Y29tIFNvQyBkcml2ZXJzCgojCiMgTlhQL0ZyZWVzY2FsZSBRb3JJUSBTb0MgZHJpdmVycwojCiMg
ZW5kIG9mIE5YUC9GcmVlc2NhbGUgUW9ySVEgU29DIGRyaXZlcnMKCiMKIyBpLk1YIFNvQyBkcml2
ZXJzCiMKIyBlbmQgb2YgaS5NWCBTb0MgZHJpdmVycwoKIwojIElYUDR4eCBTb0MgZHJpdmVycwoj
CiMgQ09ORklHX0lYUDRYWF9RTUdSIGlzIG5vdCBzZXQKIyBDT05GSUdfSVhQNFhYX05QRSBpcyBu
b3Qgc2V0CiMgZW5kIG9mIElYUDR4eCBTb0MgZHJpdmVycwoKIwojIFF1YWxjb21tIFNvQyBkcml2
ZXJzCiMKIyBlbmQgb2YgUXVhbGNvbW0gU29DIGRyaXZlcnMKCiMgQ09ORklHX1NPQ19USSBpcyBu
b3Qgc2V0CgojCiMgWGlsaW54IFNvQyBkcml2ZXJzCiMKIyBDT05GSUdfWElMSU5YX1ZDVSBpcyBu
b3Qgc2V0CiMgZW5kIG9mIFhpbGlueCBTb0MgZHJpdmVycwojIGVuZCBvZiBTT0MgKFN5c3RlbSBP
biBDaGlwKSBzcGVjaWZpYyBEcml2ZXJzCgojIENPTkZJR19QTV9ERVZGUkVRIGlzIG5vdCBzZXQK
IyBDT05GSUdfRVhUQ09OIGlzIG5vdCBzZXQKIyBDT05GSUdfTUVNT1JZIGlzIG5vdCBzZXQKIyBD
T05GSUdfSUlPIGlzIG5vdCBzZXQKIyBDT05GSUdfTlRCIGlzIG5vdCBzZXQKIyBDT05GSUdfVk1F
X0JVUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BXTSBpcyBub3Qgc2V0CgojCiMgSVJRIGNoaXAgc3Vw
cG9ydAojCiMgZW5kIG9mIElSUSBjaGlwIHN1cHBvcnQKCiMgQ09ORklHX0lQQUNLX0JVUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX1JFU0VUX0NPTlRST0xMRVIgaXMgbm90IHNldAoKIwojIFBIWSBTdWJz
eXN0ZW0KIwojIENPTkZJR19HRU5FUklDX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0JDTV9LT05B
X1VTQjJfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfUEhZX1BYQV8yOE5NX0hTSUMgaXMgbm90IHNl
dAojIENPTkZJR19QSFlfUFhBXzI4Tk1fVVNCMiBpcyBub3Qgc2V0CiMgZW5kIG9mIFBIWSBTdWJz
eXN0ZW0KCiMgQ09ORklHX1BPV0VSQ0FQIGlzIG5vdCBzZXQKIyBDT05GSUdfTUNCIGlzIG5vdCBz
ZXQKCiMKIyBQZXJmb3JtYW5jZSBtb25pdG9yIHN1cHBvcnQKIwojIGVuZCBvZiBQZXJmb3JtYW5j
ZSBtb25pdG9yIHN1cHBvcnQKCkNPTkZJR19SQVM9eQojIENPTkZJR19USFVOREVSQk9MVCBpcyBu
b3Qgc2V0CgojCiMgQW5kcm9pZAojCiMgQ09ORklHX0FORFJPSUQgaXMgbm90IHNldAojIGVuZCBv
ZiBBbmRyb2lkCgojIENPTkZJR19MSUJOVkRJTU0gaXMgbm90IHNldAojIENPTkZJR19EQVggaXMg
bm90IHNldApDT05GSUdfTlZNRU09eQpDT05GSUdfTlZNRU1fU1lTRlM9eQoKIwojIEhXIHRyYWNp
bmcgc3VwcG9ydAojCiMgQ09ORklHX1NUTSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX1RIIGlz
IG5vdCBzZXQKIyBlbmQgb2YgSFcgdHJhY2luZyBzdXBwb3J0CgojIENPTkZJR19GUEdBIGlzIG5v
dCBzZXQKIyBDT05GSUdfVU5JU1lTX1ZJU09SQlVTIGlzIG5vdCBzZXQKIyBDT05GSUdfU0lPWCBp
cyBub3Qgc2V0CiMgQ09ORklHX1NMSU1CVVMgaXMgbm90IHNldAojIENPTkZJR19JTlRFUkNPTk5F
Q1QgaXMgbm90IHNldAojIENPTkZJR19DT1VOVEVSIGlzIG5vdCBzZXQKIyBlbmQgb2YgRGV2aWNl
IERyaXZlcnMKCiMKIyBGaWxlIHN5c3RlbXMKIwpDT05GSUdfRENBQ0hFX1dPUkRfQUNDRVNTPXkK
IyBDT05GSUdfVkFMSURBVEVfRlNfUEFSU0VSIGlzIG5vdCBzZXQKQ09ORklHX0ZTX0lPTUFQPXkK
IyBDT05GSUdfRVhUMl9GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0VYVDNfRlMgaXMgbm90IHNldApD
T05GSUdfRVhUNF9GUz15CkNPTkZJR19FWFQ0X1VTRV9GT1JfRVhUMj15CkNPTkZJR19FWFQ0X0ZT
X1BPU0lYX0FDTD15CkNPTkZJR19FWFQ0X0ZTX1NFQ1VSSVRZPXkKIyBDT05GSUdfRVhUNF9ERUJV
RyBpcyBub3Qgc2V0CkNPTkZJR19KQkQyPXkKIyBDT05GSUdfSkJEMl9ERUJVRyBpcyBub3Qgc2V0
CkNPTkZJR19GU19NQkNBQ0hFPXkKIyBDT05GSUdfUkVJU0VSRlNfRlMgaXMgbm90IHNldAojIENP
TkZJR19KRlNfRlMgaXMgbm90IHNldApDT05GSUdfWEZTX0ZTPW0KIyBDT05GSUdfWEZTX1FVT1RB
IGlzIG5vdCBzZXQKIyBDT05GSUdfWEZTX1BPU0lYX0FDTCBpcyBub3Qgc2V0CiMgQ09ORklHX1hG
U19SVCBpcyBub3Qgc2V0CiMgQ09ORklHX1hGU19PTkxJTkVfU0NSVUIgaXMgbm90IHNldAojIENP
TkZJR19YRlNfV0FSTiBpcyBub3Qgc2V0CiMgQ09ORklHX1hGU19ERUJVRyBpcyBub3Qgc2V0CiMg
Q09ORklHX0dGUzJfRlMgaXMgbm90IHNldAojIENPTkZJR19PQ0ZTMl9GUyBpcyBub3Qgc2V0CkNP
TkZJR19CVFJGU19GUz1tCiMgQ09ORklHX0JUUkZTX0ZTX1BPU0lYX0FDTCBpcyBub3Qgc2V0CiMg
Q09ORklHX0JUUkZTX0ZTX0NIRUNLX0lOVEVHUklUWSBpcyBub3Qgc2V0CiMgQ09ORklHX0JUUkZT
X0ZTX1JVTl9TQU5JVFlfVEVTVFMgaXMgbm90IHNldAojIENPTkZJR19CVFJGU19ERUJVRyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0JUUkZTX0FTU0VSVCBpcyBub3Qgc2V0CiMgQ09ORklHX0JUUkZTX0ZT
X1JFRl9WRVJJRlkgaXMgbm90IHNldAojIENPTkZJR19OSUxGUzJfRlMgaXMgbm90IHNldAojIENP
TkZJR19GMkZTX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfRlNfREFYIGlzIG5vdCBzZXQKQ09ORklH
X0ZTX1BPU0lYX0FDTD15CkNPTkZJR19FWFBPUlRGUz15CiMgQ09ORklHX0VYUE9SVEZTX0JMT0NL
X09QUyBpcyBub3Qgc2V0CkNPTkZJR19GSUxFX0xPQ0tJTkc9eQpDT05GSUdfTUFOREFUT1JZX0ZJ
TEVfTE9DS0lORz15CiMgQ09ORklHX0ZTX0VOQ1JZUFRJT04gaXMgbm90IHNldApDT05GSUdfRlNO
T1RJRlk9eQpDT05GSUdfRE5PVElGWT15CkNPTkZJR19JTk9USUZZX1VTRVI9eQojIENPTkZJR19G
QU5PVElGWSBpcyBub3Qgc2V0CkNPTkZJR19RVU9UQT15CkNPTkZJR19RVU9UQV9ORVRMSU5LX0lO
VEVSRkFDRT15CiMgQ09ORklHX1BSSU5UX1FVT1RBX1dBUk5JTkcgaXMgbm90IHNldAojIENPTkZJ
R19RVU9UQV9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19RVU9UQV9UUkVFPXkKIyBDT05GSUdfUUZN
VF9WMSBpcyBub3Qgc2V0CkNPTkZJR19RRk1UX1YyPXkKQ09ORklHX1FVT1RBQ1RMPXkKQ09ORklH
X1FVT1RBQ1RMX0NPTVBBVD15CkNPTkZJR19BVVRPRlM0X0ZTPXkKQ09ORklHX0FVVE9GU19GUz15
CiMgQ09ORklHX0ZVU0VfRlMgaXMgbm90IHNldApDT05GSUdfT1ZFUkxBWV9GUz15CiMgQ09ORklH
X09WRVJMQVlfRlNfUkVESVJFQ1RfRElSIGlzIG5vdCBzZXQKQ09ORklHX09WRVJMQVlfRlNfUkVE
SVJFQ1RfQUxXQVlTX0ZPTExPVz15CiMgQ09ORklHX09WRVJMQVlfRlNfSU5ERVggaXMgbm90IHNl
dAojIENPTkZJR19PVkVSTEFZX0ZTX1hJTk9fQVVUTyBpcyBub3Qgc2V0CiMgQ09ORklHX09WRVJM
QVlfRlNfTUVUQUNPUFkgaXMgbm90IHNldAoKIwojIENhY2hlcwojCiMgQ09ORklHX0ZTQ0FDSEUg
aXMgbm90IHNldAojIGVuZCBvZiBDYWNoZXMKCiMKIyBDRC1ST00vRFZEIEZpbGVzeXN0ZW1zCiMK
Q09ORklHX0lTTzk2NjBfRlM9eQpDT05GSUdfSk9MSUVUPXkKQ09ORklHX1pJU09GUz15CiMgQ09O
RklHX1VERl9GUyBpcyBub3Qgc2V0CiMgZW5kIG9mIENELVJPTS9EVkQgRmlsZXN5c3RlbXMKCiMK
IyBET1MvRkFUL05UIEZpbGVzeXN0ZW1zCiMKQ09ORklHX0ZBVF9GUz15CkNPTkZJR19NU0RPU19G
Uz15CkNPTkZJR19WRkFUX0ZTPXkKQ09ORklHX0ZBVF9ERUZBVUxUX0NPREVQQUdFPTQzNwpDT05G
SUdfRkFUX0RFRkFVTFRfSU9DSEFSU0VUPSJpc284ODU5LTEiCiMgQ09ORklHX0ZBVF9ERUZBVUxU
X1VURjggaXMgbm90IHNldAojIENPTkZJR19OVEZTX0ZTIGlzIG5vdCBzZXQKIyBlbmQgb2YgRE9T
L0ZBVC9OVCBGaWxlc3lzdGVtcwoKIwojIFBzZXVkbyBmaWxlc3lzdGVtcwojCkNPTkZJR19QUk9D
X0ZTPXkKQ09ORklHX1BST0NfS0NPUkU9eQpDT05GSUdfUFJPQ19WTUNPUkU9eQojIENPTkZJR19Q
Uk9DX1ZNQ09SRV9ERVZJQ0VfRFVNUCBpcyBub3Qgc2V0CkNPTkZJR19QUk9DX1NZU0NUTD15CkNP
TkZJR19QUk9DX1BBR0VfTU9OSVRPUj15CiMgQ09ORklHX1BST0NfQ0hJTERSRU4gaXMgbm90IHNl
dApDT05GSUdfUFJPQ19QSURfQVJDSF9TVEFUVVM9eQpDT05GSUdfS0VSTkZTPXkKQ09ORklHX1NZ
U0ZTPXkKQ09ORklHX1RNUEZTPXkKQ09ORklHX1RNUEZTX1BPU0lYX0FDTD15CkNPTkZJR19UTVBG
U19YQVRUUj15CkNPTkZJR19IVUdFVExCRlM9eQpDT05GSUdfSFVHRVRMQl9QQUdFPXkKQ09ORklH
X01FTUZEX0NSRUFURT15CkNPTkZJR19BUkNIX0hBU19HSUdBTlRJQ19QQUdFPXkKQ09ORklHX0NP
TkZJR0ZTX0ZTPXkKQ09ORklHX0VGSVZBUl9GUz1tCiMgZW5kIG9mIFBzZXVkbyBmaWxlc3lzdGVt
cwoKQ09ORklHX01JU0NfRklMRVNZU1RFTVM9eQojIENPTkZJR19PUkFOR0VGU19GUyBpcyBub3Qg
c2V0CiMgQ09ORklHX0FERlNfRlMgaXMgbm90IHNldAojIENPTkZJR19BRkZTX0ZTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRUNSWVBUX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfSEZTX0ZTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSEZTUExVU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0JFRlNfRlMgaXMgbm90
IHNldAojIENPTkZJR19CRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19FRlNfRlMgaXMgbm90IHNl
dAojIENPTkZJR19DUkFNRlMgaXMgbm90IHNldAojIENPTkZJR19TUVVBU0hGUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1ZYRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19NSU5JWF9GUyBpcyBub3Qgc2V0
CiMgQ09ORklHX09NRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19IUEZTX0ZTIGlzIG5vdCBzZXQK
IyBDT05GSUdfUU5YNEZTX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfUU5YNkZTX0ZTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUk9NRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19QU1RPUkUgaXMgbm90IHNl
dAojIENPTkZJR19TWVNWX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfVUZTX0ZTIGlzIG5vdCBzZXQK
Q09ORklHX05FVFdPUktfRklMRVNZU1RFTVM9eQpDT05GSUdfTkZTX0ZTPXkKQ09ORklHX05GU19W
Mj15CkNPTkZJR19ORlNfVjM9eQpDT05GSUdfTkZTX1YzX0FDTD15CkNPTkZJR19ORlNfVjQ9eQoj
IENPTkZJR19ORlNfU1dBUCBpcyBub3Qgc2V0CiMgQ09ORklHX05GU19WNF8xIGlzIG5vdCBzZXQK
Q09ORklHX1JPT1RfTkZTPXkKIyBDT05GSUdfTkZTX1VTRV9MRUdBQ1lfRE5TIGlzIG5vdCBzZXQK
Q09ORklHX05GU19VU0VfS0VSTkVMX0ROUz15CiMgQ09ORklHX05GU0QgaXMgbm90IHNldApDT05G
SUdfR1JBQ0VfUEVSSU9EPXkKQ09ORklHX0xPQ0tEPXkKQ09ORklHX0xPQ0tEX1Y0PXkKQ09ORklH
X05GU19BQ0xfU1VQUE9SVD15CkNPTkZJR19ORlNfQ09NTU9OPXkKQ09ORklHX1NVTlJQQz15CkNP
TkZJR19TVU5SUENfR1NTPXkKIyBDT05GSUdfU1VOUlBDX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ0VQSF9GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NJRlMgaXMgbm90IHNldAojIENPTkZJR19D
T0RBX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQUZTX0ZTIGlzIG5vdCBzZXQKQ09ORklHXzlQX0ZT
PXkKIyBDT05GSUdfOVBfRlNfUE9TSVhfQUNMIGlzIG5vdCBzZXQKIyBDT05GSUdfOVBfRlNfU0VD
VVJJVFkgaXMgbm90IHNldApDT05GSUdfTkxTPXkKQ09ORklHX05MU19ERUZBVUxUPSJ1dGY4IgpD
T05GSUdfTkxTX0NPREVQQUdFXzQzNz15CiMgQ09ORklHX05MU19DT0RFUEFHRV83MzcgaXMgbm90
IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfNzc1IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NP
REVQQUdFXzg1MCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NTIgaXMgbm90IHNl
dAojIENPTkZJR19OTFNfQ09ERVBBR0VfODU1IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQ
QUdFXzg1NyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjAgaXMgbm90IHNldAoj
IENPTkZJR19OTFNfQ09ERVBBR0VfODYxIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdF
Xzg2MiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjMgaXMgbm90IHNldAojIENP
TkZJR19OTFNfQ09ERVBBR0VfODY0IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzg2
NSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjYgaXMgbm90IHNldAojIENPTkZJ
R19OTFNfQ09ERVBBR0VfODY5IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzkzNiBp
cyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85NTAgaXMgbm90IHNldAojIENPTkZJR19O
TFNfQ09ERVBBR0VfOTMyIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzk0OSBpcyBu
b3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NzQgaXMgbm90IHNldAojIENPTkZJR19OTFNf
SVNPODg1OV84IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQQUdFXzEyNTAgaXMgbm90IHNl
dAojIENPTkZJR19OTFNfQ09ERVBBR0VfMTI1MSBpcyBub3Qgc2V0CkNPTkZJR19OTFNfQVNDSUk9
eQpDT05GSUdfTkxTX0lTTzg4NTlfMT15CiMgQ09ORklHX05MU19JU084ODU5XzIgaXMgbm90IHNl
dAojIENPTkZJR19OTFNfSVNPODg1OV8zIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlf
NCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzUgaXMgbm90IHNldAojIENPTkZJR19O
TFNfSVNPODg1OV82IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlfNyBpcyBub3Qgc2V0
CiMgQ09ORklHX05MU19JU084ODU5XzkgaXMgbm90IHNldAojIENPTkZJR19OTFNfSVNPODg1OV8x
MyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzE0IGlzIG5vdCBzZXQKIyBDT05GSUdf
TkxTX0lTTzg4NTlfMTUgaXMgbm90IHNldAojIENPTkZJR19OTFNfS09JOF9SIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkxTX0tPSThfVSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19NQUNfUk9NQU4gaXMg
bm90IHNldAojIENPTkZJR19OTFNfTUFDX0NFTFRJQyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19N
QUNfQ0VOVEVVUk8gaXMgbm90IHNldAojIENPTkZJR19OTFNfTUFDX0NST0FUSUFOIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTkxTX01BQ19DWVJJTExJQyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19NQUNf
R0FFTElDIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX01BQ19HUkVFSyBpcyBub3Qgc2V0CiMgQ09O
RklHX05MU19NQUNfSUNFTEFORCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19NQUNfSU5VSVQgaXMg
bm90IHNldAojIENPTkZJR19OTFNfTUFDX1JPTUFOSUFOIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxT
X01BQ19UVVJLSVNIIGlzIG5vdCBzZXQKQ09ORklHX05MU19VVEY4PXkKIyBDT05GSUdfRExNIGlz
IG5vdCBzZXQKIyBDT05GSUdfVU5JQ09ERSBpcyBub3Qgc2V0CiMgZW5kIG9mIEZpbGUgc3lzdGVt
cwoKIwojIFNlY3VyaXR5IG9wdGlvbnMKIwpDT05GSUdfS0VZUz15CkNPTkZJR19LRVlTX0NPTVBB
VD15CiMgQ09ORklHX0tFWVNfUkVRVUVTVF9DQUNIRSBpcyBub3Qgc2V0CiMgQ09ORklHX1BFUlNJ
U1RFTlRfS0VZUklOR1MgaXMgbm90IHNldAojIENPTkZJR19CSUdfS0VZUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0VOQ1JZUFRFRF9LRVlTIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZX0RIX09QRVJBVElP
TlMgaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9ETUVTR19SRVNUUklDVCBpcyBub3Qgc2V0
CkNPTkZJR19TRUNVUklUWT15CkNPTkZJR19TRUNVUklUWV9XUklUQUJMRV9IT09LUz15CkNPTkZJ
R19TRUNVUklUWUZTPXkKQ09ORklHX1NFQ1VSSVRZX05FVFdPUks9eQpDT05GSUdfUEFHRV9UQUJM
RV9JU09MQVRJT049eQojIENPTkZJR19TRUNVUklUWV9ORVRXT1JLX1hGUk0gaXMgbm90IHNldAoj
IENPTkZJR19TRUNVUklUWV9QQVRIIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5URUxfVFhUIGlzIG5v
dCBzZXQKQ09ORklHX0xTTV9NTUFQX01JTl9BRERSPTY1NTM2CkNPTkZJR19IQVZFX0hBUkRFTkVE
X1VTRVJDT1BZX0FMTE9DQVRPUj15CiMgQ09ORklHX0hBUkRFTkVEX1VTRVJDT1BZIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRk9SVElGWV9TT1VSQ0UgaXMgbm90IHNldAojIENPTkZJR19TVEFUSUNfVVNF
Uk1PREVIRUxQRVIgaXMgbm90IHNldApDT05GSUdfU0VDVVJJVFlfU0VMSU5VWD15CkNPTkZJR19T
RUNVUklUWV9TRUxJTlVYX0JPT1RQQVJBTT15CkNPTkZJR19TRUNVUklUWV9TRUxJTlVYX0RJU0FC
TEU9eQpDT05GSUdfU0VDVVJJVFlfU0VMSU5VWF9ERVZFTE9QPXkKQ09ORklHX1NFQ1VSSVRZX1NF
TElOVVhfQVZDX1NUQVRTPXkKQ09ORklHX1NFQ1VSSVRZX1NFTElOVVhfQ0hFQ0tSRVFQUk9UX1ZB
TFVFPTAKIyBDT05GSUdfU0VDVVJJVFlfU01BQ0sgaXMgbm90IHNldAojIENPTkZJR19TRUNVUklU
WV9UT01PWU8gaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9BUFBBUk1PUiBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFQ1VSSVRZX0xPQURQSU4gaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9Z
QU1BIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VDVVJJVFlfU0FGRVNFVElEIGlzIG5vdCBzZXQKQ09O
RklHX0lOVEVHUklUWT15CiMgQ09ORklHX0lOVEVHUklUWV9TSUdOQVRVUkUgaXMgbm90IHNldApD
T05GSUdfSU5URUdSSVRZX0FVRElUPXkKIyBDT05GSUdfSU1BIGlzIG5vdCBzZXQKIyBDT05GSUdf
RVZNIGlzIG5vdCBzZXQKQ09ORklHX0RFRkFVTFRfU0VDVVJJVFlfU0VMSU5VWD15CiMgQ09ORklH
X0RFRkFVTFRfU0VDVVJJVFlfREFDIGlzIG5vdCBzZXQKQ09ORklHX0xTTT0ieWFtYSxsb2FkcGlu
LHNhZmVzZXRpZCxpbnRlZ3JpdHksc2VsaW51eCxzbWFjayx0b21veW8sYXBwYXJtb3IiCgojCiMg
S2VybmVsIGhhcmRlbmluZyBvcHRpb25zCiMKCiMKIyBNZW1vcnkgaW5pdGlhbGl6YXRpb24KIwpD
T05GSUdfSU5JVF9TVEFDS19OT05FPXkKIyBDT05GSUdfSU5JVF9PTl9BTExPQ19ERUZBVUxUX09O
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU5JVF9PTl9GUkVFX0RFRkFVTFRfT04gaXMgbm90IHNldAoj
IGVuZCBvZiBNZW1vcnkgaW5pdGlhbGl6YXRpb24KIyBlbmQgb2YgS2VybmVsIGhhcmRlbmluZyBv
cHRpb25zCiMgZW5kIG9mIFNlY3VyaXR5IG9wdGlvbnMKCkNPTkZJR19YT1JfQkxPQ0tTPW0KQ09O
RklHX0NSWVBUTz15CgojCiMgQ3J5cHRvIGNvcmUgb3IgaGVscGVyCiMKQ09ORklHX0NSWVBUT19B
TEdBUEk9eQpDT05GSUdfQ1JZUFRPX0FMR0FQSTI9eQpDT05GSUdfQ1JZUFRPX0FFQUQ9eQpDT05G
SUdfQ1JZUFRPX0FFQUQyPXkKQ09ORklHX0NSWVBUT19CTEtDSVBIRVI9eQpDT05GSUdfQ1JZUFRP
X0JMS0NJUEhFUjI9eQpDT05GSUdfQ1JZUFRPX0hBU0g9eQpDT05GSUdfQ1JZUFRPX0hBU0gyPXkK
Q09ORklHX0NSWVBUT19STkc9eQpDT05GSUdfQ1JZUFRPX1JORzI9eQpDT05GSUdfQ1JZUFRPX1JO
R19ERUZBVUxUPXkKQ09ORklHX0NSWVBUT19BS0NJUEhFUjI9eQpDT05GSUdfQ1JZUFRPX0FLQ0lQ
SEVSPXkKQ09ORklHX0NSWVBUT19LUFAyPXkKQ09ORklHX0NSWVBUT19BQ09NUDI9eQpDT05GSUdf
Q1JZUFRPX01BTkFHRVI9eQpDT05GSUdfQ1JZUFRPX01BTkFHRVIyPXkKIyBDT05GSUdfQ1JZUFRP
X1VTRVIgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX01BTkFHRVJfRElTQUJMRV9URVNUUz15CkNP
TkZJR19DUllQVE9fR0YxMjhNVUw9eQpDT05GSUdfQ1JZUFRPX05VTEw9eQpDT05GSUdfQ1JZUFRP
X05VTEwyPXkKIyBDT05GSUdfQ1JZUFRPX1BDUllQVCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBU
T19DUllQVEQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0FVVEhFTkM9eQojIENPTkZJR19DUllQ
VE9fVEVTVCBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fRU5HSU5FPW0KCiMKIyBQdWJsaWMta2V5
IGNyeXB0b2dyYXBoeQojCkNPTkZJR19DUllQVE9fUlNBPXkKIyBDT05GSUdfQ1JZUFRPX0RIIGlz
IG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0VDREggaXMgbm90IHNldAojIENPTkZJR19DUllQVE9f
RUNSRFNBIGlzIG5vdCBzZXQKCiMKIyBBdXRoZW50aWNhdGVkIEVuY3J5cHRpb24gd2l0aCBBc3Nv
Y2lhdGVkIERhdGEKIwpDT05GSUdfQ1JZUFRPX0NDTT15CkNPTkZJR19DUllQVE9fR0NNPXkKIyBD
T05GSUdfQ1JZUFRPX0NIQUNIQTIwUE9MWTEzMDUgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9f
QUVHSVMxMjggaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQUVHSVMxMjhMIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1JZUFRPX0FFR0lTMjU2IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0FFR0lT
MTI4X0FFU05JX1NTRTIgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQUVHSVMxMjhMX0FFU05J
X1NTRTIgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQUVHSVMyNTZfQUVTTklfU1NFMiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NSWVBUT19NT1JVUzY0MCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBU
T19NT1JVUzY0MF9TU0UyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX01PUlVTMTI4MCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NSWVBUT19NT1JVUzEyODBfU1NFMiBpcyBub3Qgc2V0CiMgQ09ORklH
X0NSWVBUT19NT1JVUzEyODBfQVZYMiBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fU0VRSVY9eQpD
T05GSUdfQ1JZUFRPX0VDSEFJTklWPXkKCiMKIyBCbG9jayBtb2RlcwojCkNPTkZJR19DUllQVE9f
Q0JDPXkKIyBDT05GSUdfQ1JZUFRPX0NGQiBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fQ1RSPXkK
IyBDT05GSUdfQ1JZUFRPX0NUUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19FQ0IgaXMgbm90
IHNldAojIENPTkZJR19DUllQVE9fTFJXIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX09GQiBp
cyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19QQ0JDIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRP
X1hUUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19LRVlXUkFQIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZUFRPX05IUE9MWTEzMDVfU1NFMiBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19OSFBP
TFkxMzA1X0FWWDIgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQURJQU5UVU0gaXMgbm90IHNl
dAoKIwojIEhhc2ggbW9kZXMKIwpDT05GSUdfQ1JZUFRPX0NNQUM9eQpDT05GSUdfQ1JZUFRPX0hN
QUM9eQojIENPTkZJR19DUllQVE9fWENCQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19WTUFD
IGlzIG5vdCBzZXQKCiMKIyBEaWdlc3QKIwpDT05GSUdfQ1JZUFRPX0NSQzMyQz15CiMgQ09ORklH
X0NSWVBUT19DUkMzMkNfSU5URUwgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ1JDMzIgaXMg
bm90IHNldAojIENPTkZJR19DUllQVE9fQ1JDMzJfUENMTVVMIGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1hYSEFTSCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19DUkNUMTBESUYgaXMgbm90
IHNldApDT05GSUdfQ1JZUFRPX0dIQVNIPXkKIyBDT05GSUdfQ1JZUFRPX1BPTFkxMzA1IGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JZUFRPX1BPTFkxMzA1X1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09ORklH
X0NSWVBUT19NRDQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX01ENT15CiMgQ09ORklHX0NSWVBU
T19NSUNIQUVMX01JQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19STUQxMjggaXMgbm90IHNl
dAojIENPTkZJR19DUllQVE9fUk1EMTYwIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1JNRDI1
NiBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19STUQzMjAgaXMgbm90IHNldApDT05GSUdfQ1JZ
UFRPX1NIQTE9eQojIENPTkZJR19DUllQVE9fU0hBMV9TU1NFMyBpcyBub3Qgc2V0CiMgQ09ORklH
X0NSWVBUT19TSEEyNTZfU1NTRTMgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0hBNTEyX1NT
U0UzIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19TSEEyNTY9eQojIENPTkZJR19DUllQVE9fU0hB
NTEyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NIQTMgaXMgbm90IHNldAojIENPTkZJR19D
UllQVE9fU00zIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NUUkVFQk9HIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1JZUFRPX1RHUjE5MiBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19XUDUxMiBp
cyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19HSEFTSF9DTE1VTF9OSV9JTlRFTCBpcyBub3Qgc2V0
CgojCiMgQ2lwaGVycwojCkNPTkZJR19DUllQVE9fQUVTPXkKIyBDT05GSUdfQ1JZUFRPX0FFU19U
SSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19BRVNfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZUFRPX0FFU19OSV9JTlRFTCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19BTlVCSVMg
aXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0xJQl9BUkM0PXkKIyBDT05GSUdfQ1JZUFRPX0FSQzQg
aXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQkxPV0ZJU0ggaXMgbm90IHNldAojIENPTkZJR19D
UllQVE9fQkxPV0ZJU0hfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0NBTUVMTElB
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0NBTUVMTElBX1g4Nl82NCBpcyBub3Qgc2V0CiMg
Q09ORklHX0NSWVBUT19DQU1FTExJQV9BRVNOSV9BVlhfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZUFRPX0NBTUVMTElBX0FFU05JX0FWWDJfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX0NBU1Q1IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0NBU1Q1X0FWWF9YODZfNjQg
aXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0FTVDYgaXMgbm90IHNldAojIENPTkZJR19DUllQ
VE9fQ0FTVDZfQVZYX1g4Nl82NCBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fREVTPXkKIyBDT05G
SUdfQ1JZUFRPX0RFUzNfRURFX1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19GQ1JZ
UFQgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fS0hBWkFEIGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1NBTFNBMjAgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0hBQ0hBMjAgaXMgbm90
IHNldAojIENPTkZJR19DUllQVE9fQ0hBQ0hBMjBfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1NFRUQgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0VSUEVOVCBpcyBub3Qgc2V0
CiMgQ09ORklHX0NSWVBUT19TRVJQRU5UX1NTRTJfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1NFUlBFTlRfQVZYX1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19TRVJQ
RU5UX0FWWDJfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NNNCBpcyBub3Qgc2V0
CiMgQ09ORklHX0NSWVBUT19URUEgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fVFdPRklTSCBp
cyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19UV09GSVNIX1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09O
RklHX0NSWVBUT19UV09GSVNIX1g4Nl82NF8zV0FZIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRP
X1RXT0ZJU0hfQVZYX1g4Nl82NCBpcyBub3Qgc2V0CgojCiMgQ29tcHJlc3Npb24KIwojIENPTkZJ
R19DUllQVE9fREVGTEFURSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19MWk8gaXMgbm90IHNl
dAojIENPTkZJR19DUllQVE9fODQyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0xaNCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NSWVBUT19MWjRIQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19a
U1REIGlzIG5vdCBzZXQKCiMKIyBSYW5kb20gTnVtYmVyIEdlbmVyYXRpb24KIwojIENPTkZJR19D
UllQVE9fQU5TSV9DUFJORyBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fRFJCR19NRU5VPXkKQ09O
RklHX0NSWVBUT19EUkJHX0hNQUM9eQojIENPTkZJR19DUllQVE9fRFJCR19IQVNIIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1JZUFRPX0RSQkdfQ1RSIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19EUkJH
PXkKQ09ORklHX0NSWVBUT19KSVRURVJFTlRST1BZPXkKIyBDT05GSUdfQ1JZUFRPX1VTRVJfQVBJ
X0hBU0ggaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fVVNFUl9BUElfU0tDSVBIRVIgaXMgbm90
IHNldAojIENPTkZJR19DUllQVE9fVVNFUl9BUElfUk5HIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZ
UFRPX1VTRVJfQVBJX0FFQUQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0hBU0hfSU5GTz15CkNP
TkZJR19DUllQVE9fSFc9eQojIENPTkZJR19DUllQVE9fREVWX1BBRExPQ0sgaXMgbm90IHNldAoj
IENPTkZJR19DUllQVE9fREVWX0FUTUVMX0VDQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19E
RVZfQVRNRUxfU0hBMjA0QSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19ERVZfQ0NQIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JZUFRPX0RFVl9RQVRfREg4OTV4Q0MgaXMgbm90IHNldAojIENPTkZJ
R19DUllQVE9fREVWX1FBVF9DM1hYWCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19ERVZfUUFU
X0M2MlggaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fREVWX1FBVF9ESDg5NXhDQ1ZGIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JZUFRPX0RFVl9RQVRfQzNYWFhWRiBpcyBub3Qgc2V0CiMgQ09ORklH
X0NSWVBUT19ERVZfUUFUX0M2MlhWRiBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19ERVZfTklU
Uk9YX0NOTjU1WFggaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0RFVl9WSVJUSU89bQpDT05GSUdf
QVNZTU1FVFJJQ19LRVlfVFlQRT15CkNPTkZJR19BU1lNTUVUUklDX1BVQkxJQ19LRVlfU1VCVFlQ
RT15CkNPTkZJR19YNTA5X0NFUlRJRklDQVRFX1BBUlNFUj15CiMgQ09ORklHX1BLQ1M4X1BSSVZB
VEVfS0VZX1BBUlNFUiBpcyBub3Qgc2V0CkNPTkZJR19QS0NTN19NRVNTQUdFX1BBUlNFUj15CiMg
Q09ORklHX1BLQ1M3X1RFU1RfS0VZIGlzIG5vdCBzZXQKIyBDT05GSUdfU0lHTkVEX1BFX0ZJTEVf
VkVSSUZJQ0FUSU9OIGlzIG5vdCBzZXQKCiMKIyBDZXJ0aWZpY2F0ZXMgZm9yIHNpZ25hdHVyZSBj
aGVja2luZwojCkNPTkZJR19TWVNURU1fVFJVU1RFRF9LRVlSSU5HPXkKQ09ORklHX1NZU1RFTV9U
UlVTVEVEX0tFWVM9IiIKIyBDT05GSUdfU1lTVEVNX0VYVFJBX0NFUlRJRklDQVRFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VDT05EQVJZX1RSVVNURURfS0VZUklORyBpcyBub3Qgc2V0CiMgQ09ORklH
X1NZU1RFTV9CTEFDS0xJU1RfS0VZUklORyBpcyBub3Qgc2V0CiMgZW5kIG9mIENlcnRpZmljYXRl
cyBmb3Igc2lnbmF0dXJlIGNoZWNraW5nCgpDT05GSUdfQklOQVJZX1BSSU5URj15CgojCiMgTGli
cmFyeSByb3V0aW5lcwojCkNPTkZJR19SQUlENl9QUT1tCkNPTkZJR19SQUlENl9QUV9CRU5DSE1B
Uks9eQojIENPTkZJR19QQUNLSU5HIGlzIG5vdCBzZXQKQ09ORklHX0JJVFJFVkVSU0U9eQpDT05G
SUdfR0VORVJJQ19TVFJOQ1BZX0ZST01fVVNFUj15CkNPTkZJR19HRU5FUklDX1NUUk5MRU5fVVNF
Uj15CkNPTkZJR19HRU5FUklDX05FVF9VVElMUz15CkNPTkZJR19HRU5FUklDX0ZJTkRfRklSU1Rf
QklUPXkKIyBDT05GSUdfQ09SRElDIGlzIG5vdCBzZXQKQ09ORklHX1JBVElPTkFMPXkKQ09ORklH
X0dFTkVSSUNfUENJX0lPTUFQPXkKQ09ORklHX0dFTkVSSUNfSU9NQVA9eQpDT05GSUdfQVJDSF9V
U0VfQ01QWENIR19MT0NLUkVGPXkKQ09ORklHX0FSQ0hfSEFTX0ZBU1RfTVVMVElQTElFUj15CkNP
TkZJR19DUkNfQ0NJVFQ9eQpDT05GSUdfQ1JDMTY9eQojIENPTkZJR19DUkNfVDEwRElGIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JDX0lUVV9UIGlzIG5vdCBzZXQKQ09ORklHX0NSQzMyPXkKIyBDT05G
SUdfQ1JDMzJfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfQ1JDMzJfU0xJQ0VCWTg9eQojIENP
TkZJR19DUkMzMl9TTElDRUJZNCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSQzMyX1NBUldBVEUgaXMg
bm90IHNldAojIENPTkZJR19DUkMzMl9CSVQgaXMgbm90IHNldAojIENPTkZJR19DUkM2NCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NSQzQgaXMgbm90IHNldAojIENPTkZJR19DUkM3IGlzIG5vdCBzZXQK
Q09ORklHX0xJQkNSQzMyQz1tCiMgQ09ORklHX0NSQzggaXMgbm90IHNldApDT05GSUdfWFhIQVNI
PW0KIyBDT05GSUdfUkFORE9NMzJfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfWkxJQl9JTkZM
QVRFPXkKQ09ORklHX1pMSUJfREVGTEFURT15CkNPTkZJR19MWk9fQ09NUFJFU1M9eQpDT05GSUdf
TFpPX0RFQ09NUFJFU1M9eQpDT05GSUdfTFo0X0RFQ09NUFJFU1M9eQpDT05GSUdfWlNURF9DT01Q
UkVTUz1tCkNPTkZJR19aU1REX0RFQ09NUFJFU1M9bQpDT05GSUdfWFpfREVDPXkKQ09ORklHX1ha
X0RFQ19YODY9eQpDT05GSUdfWFpfREVDX1BPV0VSUEM9eQpDT05GSUdfWFpfREVDX0lBNjQ9eQpD
T05GSUdfWFpfREVDX0FSTT15CkNPTkZJR19YWl9ERUNfQVJNVEhVTUI9eQpDT05GSUdfWFpfREVD
X1NQQVJDPXkKQ09ORklHX1haX0RFQ19CQ0o9eQojIENPTkZJR19YWl9ERUNfVEVTVCBpcyBub3Qg
c2V0CkNPTkZJR19ERUNPTVBSRVNTX0daSVA9eQpDT05GSUdfREVDT01QUkVTU19CWklQMj15CkNP
TkZJR19ERUNPTVBSRVNTX0xaTUE9eQpDT05GSUdfREVDT01QUkVTU19YWj15CkNPTkZJR19ERUNP
TVBSRVNTX0xaTz15CkNPTkZJR19ERUNPTVBSRVNTX0xaND15CkNPTkZJR19HRU5FUklDX0FMTE9D
QVRPUj15CkNPTkZJR19JTlRFUlZBTF9UUkVFPXkKQ09ORklHX0FTU09DSUFUSVZFX0FSUkFZPXkK
Q09ORklHX0hBU19JT01FTT15CkNPTkZJR19IQVNfSU9QT1JUX01BUD15CkNPTkZJR19IQVNfRE1B
PXkKQ09ORklHX05FRURfU0dfRE1BX0xFTkdUSD15CkNPTkZJR19ORUVEX0RNQV9NQVBfU1RBVEU9
eQpDT05GSUdfQVJDSF9ETUFfQUREUl9UXzY0QklUPXkKQ09ORklHX1NXSU9UTEI9eQojIENPTkZJ
R19ETUFfQVBJX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX1NHTF9BTExPQz15CkNPTkZJR19JT01N
VV9IRUxQRVI9eQpDT05GSUdfQ0hFQ0tfU0lHTkFUVVJFPXkKQ09ORklHX0NQVV9STUFQPXkKQ09O
RklHX0RRTD15CkNPTkZJR19HTE9CPXkKIyBDT05GSUdfR0xPQl9TRUxGVEVTVCBpcyBub3Qgc2V0
CkNPTkZJR19OTEFUVFI9eQpDT05GSUdfQ0xaX1RBQj15CiMgQ09ORklHX0lSUV9QT0xMIGlzIG5v
dCBzZXQKQ09ORklHX01QSUxJQj15CkNPTkZJR19ESU1MSUI9eQpDT05GSUdfT0lEX1JFR0lTVFJZ
PXkKQ09ORklHX1VDUzJfU1RSSU5HPXkKQ09ORklHX0hBVkVfR0VORVJJQ19WRFNPPXkKQ09ORklH
X0dFTkVSSUNfR0VUVElNRU9GREFZPXkKQ09ORklHX0ZPTlRfU1VQUE9SVD15CiMgQ09ORklHX0ZP
TlRTIGlzIG5vdCBzZXQKQ09ORklHX0ZPTlRfOHg4PXkKQ09ORklHX0ZPTlRfOHgxNj15CkNPTkZJ
R19TR19QT09MPXkKQ09ORklHX0FSQ0hfSEFTX1BNRU1fQVBJPXkKQ09ORklHX0FSQ0hfSEFTX1VB
Q0NFU1NfRkxVU0hDQUNIRT15CkNPTkZJR19BUkNIX0hBU19VQUNDRVNTX01DU0FGRT15CkNPTkZJ
R19BUkNIX1NUQUNLV0FMSz15CkNPTkZJR19TVEFDS0RFUE9UPXkKQ09ORklHX1NCSVRNQVA9eQoj
IENPTkZJR19TVFJJTkdfU0VMRlRFU1QgaXMgbm90IHNldAojIGVuZCBvZiBMaWJyYXJ5IHJvdXRp
bmVzCgojCiMgS2VybmVsIGhhY2tpbmcKIwoKIwojIHByaW50ayBhbmQgZG1lc2cgb3B0aW9ucwoj
CkNPTkZJR19QUklOVEtfVElNRT15CiMgQ09ORklHX1BSSU5US19DQUxMRVIgaXMgbm90IHNldApD
T05GSUdfQ09OU09MRV9MT0dMRVZFTF9ERUZBVUxUPTcKQ09ORklHX0NPTlNPTEVfTE9HTEVWRUxf
UVVJRVQ9NApDT05GSUdfTUVTU0FHRV9MT0dMRVZFTF9ERUZBVUxUPTQKIyBDT05GSUdfQk9PVF9Q
UklOVEtfREVMQVkgaXMgbm90IHNldAojIENPTkZJR19EWU5BTUlDX0RFQlVHIGlzIG5vdCBzZXQK
IyBlbmQgb2YgcHJpbnRrIGFuZCBkbWVzZyBvcHRpb25zCgojCiMgQ29tcGlsZS10aW1lIGNoZWNr
cyBhbmQgY29tcGlsZXIgb3B0aW9ucwojCkNPTkZJR19ERUJVR19JTkZPPXkKIyBDT05GSUdfREVC
VUdfSU5GT19SRURVQ0VEIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfSU5GT19TUExJVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RFQlVHX0lORk9fRFdBUkY0IGlzIG5vdCBzZXQKIyBDT05GSUdfREVC
VUdfSU5GT19CVEYgaXMgbm90IHNldAojIENPTkZJR19HREJfU0NSSVBUUyBpcyBub3Qgc2V0CkNP
TkZJR19FTkFCTEVfTVVTVF9DSEVDSz15CkNPTkZJR19GUkFNRV9XQVJOPTIwNDgKIyBDT05GSUdf
U1RSSVBfQVNNX1NZTVMgaXMgbm90IHNldAojIENPTkZJR19SRUFEQUJMRV9BU00gaXMgbm90IHNl
dAojIENPTkZJR19VTlVTRURfU1lNQk9MUyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19GUz15CiMg
Q09ORklHX0hFQURFUlNfSU5TVEFMTCBpcyBub3Qgc2V0CkNPTkZJR19PUFRJTUlaRV9JTkxJTklO
Rz15CiMgQ09ORklHX0RFQlVHX1NFQ1RJT05fTUlTTUFUQ0ggaXMgbm90IHNldApDT05GSUdfU0VD
VElPTl9NSVNNQVRDSF9XQVJOX09OTFk9eQpDT05GSUdfU1RBQ0tfVkFMSURBVElPTj15CiMgQ09O
RklHX0RFQlVHX0ZPUkNFX1dFQUtfUEVSX0NQVSBpcyBub3Qgc2V0CiMgZW5kIG9mIENvbXBpbGUt
dGltZSBjaGVja3MgYW5kIGNvbXBpbGVyIG9wdGlvbnMKCkNPTkZJR19NQUdJQ19TWVNSUT15CkNP
TkZJR19NQUdJQ19TWVNSUV9ERUZBVUxUX0VOQUJMRT0weDEKQ09ORklHX01BR0lDX1NZU1JRX1NF
UklBTD15CkNPTkZJR19ERUJVR19LRVJORUw9eQpDT05GSUdfREVCVUdfTUlTQz15CgojCiMgTWVt
b3J5IERlYnVnZ2luZwojCiMgQ09ORklHX1BBR0VfRVhURU5TSU9OIGlzIG5vdCBzZXQKIyBDT05G
SUdfREVCVUdfUEFHRUFMTE9DIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFHRV9PV05FUiBpcyBub3Qg
c2V0CiMgQ09ORklHX1BBR0VfUE9JU09OSU5HIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfUEFH
RV9SRUYgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19ST0RBVEFfVEVTVCBpcyBub3Qgc2V0CiMg
Q09ORklHX0RFQlVHX09CSkVDVFMgaXMgbm90IHNldAojIENPTkZJR19TTFVCX0RFQlVHX09OIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0xVQl9TVEFUUyBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0RFQlVH
X0tNRU1MRUFLPXkKIyBDT05GSUdfREVCVUdfS01FTUxFQUsgaXMgbm90IHNldApDT05GSUdfREVC
VUdfU1RBQ0tfVVNBR0U9eQojIENPTkZJR19ERUJVR19WTSBpcyBub3Qgc2V0CkNPTkZJR19BUkNI
X0hBU19ERUJVR19WSVJUVUFMPXkKIyBDT05GSUdfREVCVUdfVklSVFVBTCBpcyBub3Qgc2V0CkNP
TkZJR19ERUJVR19NRU1PUllfSU5JVD15CiMgQ09ORklHX0RFQlVHX1BFUl9DUFVfTUFQUyBpcyBu
b3Qgc2V0CkNPTkZJR19IQVZFX0FSQ0hfS0FTQU49eQpDT05GSUdfSEFWRV9BUkNIX0tBU0FOX1ZN
QUxMT0M9eQpDT05GSUdfQ0NfSEFTX0tBU0FOX0dFTkVSSUM9eQpDT05GSUdfS0FTQU49eQpDT05G
SUdfS0FTQU5fR0VORVJJQz15CiMgQ09ORklHX0tBU0FOX09VVExJTkUgaXMgbm90IHNldApDT05G
SUdfS0FTQU5fSU5MSU5FPXkKQ09ORklHX0tBU0FOX1NUQUNLPTEKQ09ORklHX0tBU0FOX1ZNQUxM
T0M9eQpDT05GSUdfVEVTVF9LQVNBTj1tCiMgZW5kIG9mIE1lbW9yeSBEZWJ1Z2dpbmcKCkNPTkZJ
R19BUkNIX0hBU19LQ09WPXkKQ09ORklHX0NDX0hBU19TQU5DT1ZfVFJBQ0VfUEM9eQpDT05GSUdf
S0NPVj15CiMgQ09ORklHX0tDT1ZfRU5BQkxFX0NPTVBBUklTT05TIGlzIG5vdCBzZXQKQ09ORklH
X0tDT1ZfSU5TVFJVTUVOVF9BTEw9eQojIENPTkZJR19ERUJVR19TSElSUSBpcyBub3Qgc2V0Cgoj
CiMgRGVidWcgTG9ja3VwcyBhbmQgSGFuZ3MKIwojIENPTkZJR19TT0ZUTE9DS1VQX0RFVEVDVE9S
IGlzIG5vdCBzZXQKQ09ORklHX0hBUkRMT0NLVVBfQ0hFQ0tfVElNRVNUQU1QPXkKIyBDT05GSUdf
SEFSRExPQ0tVUF9ERVRFQ1RPUiBpcyBub3Qgc2V0CiMgQ09ORklHX0RFVEVDVF9IVU5HX1RBU0sg
aXMgbm90IHNldAojIENPTkZJR19XUV9XQVRDSERPRyBpcyBub3Qgc2V0CiMgZW5kIG9mIERlYnVn
IExvY2t1cHMgYW5kIEhhbmdzCgojIENPTkZJR19QQU5JQ19PTl9PT1BTIGlzIG5vdCBzZXQKQ09O
RklHX1BBTklDX09OX09PUFNfVkFMVUU9MApDT05GSUdfUEFOSUNfVElNRU9VVD0wCiMgQ09ORklH
X1NDSEVEX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX1NDSEVEX0lORk89eQpDT05GSUdfU0NIRURT
VEFUUz15CiMgQ09ORklHX1NDSEVEX1NUQUNLX0VORF9DSEVDSyBpcyBub3Qgc2V0CiMgQ09ORklH
X0RFQlVHX1RJTUVLRUVQSU5HIGlzIG5vdCBzZXQKCiMKIyBMb2NrIERlYnVnZ2luZyAoc3Bpbmxv
Y2tzLCBtdXRleGVzLCBldGMuLi4pCiMKQ09ORklHX0xPQ0tfREVCVUdHSU5HX1NVUFBPUlQ9eQoj
IENPTkZJR19QUk9WRV9MT0NLSU5HIGlzIG5vdCBzZXQKIyBDT05GSUdfTE9DS19TVEFUIGlzIG5v
dCBzZXQKIyBDT05GSUdfREVCVUdfUlRfTVVURVhFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVH
X1NQSU5MT0NLIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTVVURVhFUyBpcyBub3Qgc2V0CiMg
Q09ORklHX0RFQlVHX1dXX01VVEVYX1NMT1dQQVRIIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdf
UldTRU1TIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTE9DS19BTExPQyBpcyBub3Qgc2V0CiMg
Q09ORklHX0RFQlVHX0FUT01JQ19TTEVFUCBpcyBub3Qgc2V0CiMgQ09ORklHX0RFQlVHX0xPQ0tJ
TkdfQVBJX1NFTEZURVNUUyBpcyBub3Qgc2V0CiMgQ09ORklHX0xPQ0tfVE9SVFVSRV9URVNUIGlz
IG5vdCBzZXQKIyBDT05GSUdfV1dfTVVURVhfU0VMRlRFU1QgaXMgbm90IHNldAojIGVuZCBvZiBM
b2NrIERlYnVnZ2luZyAoc3BpbmxvY2tzLCBtdXRleGVzLCBldGMuLi4pCgpDT05GSUdfU1RBQ0tU
UkFDRT15CiMgQ09ORklHX1dBUk5fQUxMX1VOU0VFREVEX1JBTkRPTSBpcyBub3Qgc2V0CiMgQ09O
RklHX0RFQlVHX0tPQkpFQ1QgaXMgbm90IHNldApDT05GSUdfREVCVUdfQlVHVkVSQk9TRT15CiMg
Q09ORklHX0RFQlVHX0xJU1QgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19QTElTVCBpcyBub3Qg
c2V0CiMgQ09ORklHX0RFQlVHX1NHIGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfTk9USUZJRVJT
IGlzIG5vdCBzZXQKIyBDT05GSUdfREVCVUdfQ1JFREVOVElBTFMgaXMgbm90IHNldAoKIwojIFJD
VSBEZWJ1Z2dpbmcKIwojIENPTkZJR19SQ1VfUEVSRl9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdf
UkNVX1RPUlRVUkVfVEVTVCBpcyBub3Qgc2V0CkNPTkZJR19SQ1VfQ1BVX1NUQUxMX1RJTUVPVVQ9
MjEKQ09ORklHX1JDVV9UUkFDRT15CiMgQ09ORklHX1JDVV9FUVNfREVCVUcgaXMgbm90IHNldAoj
IGVuZCBvZiBSQ1UgRGVidWdnaW5nCgojIENPTkZJR19ERUJVR19XUV9GT1JDRV9SUl9DUFUgaXMg
bm90IHNldAojIENPTkZJR19ERUJVR19CTE9DS19FWFRfREVWVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0NQVV9IT1RQTFVHX1NUQVRFX0NPTlRST0wgaXMgbm90IHNldAojIENPTkZJR19OT1RJRklFUl9F
UlJPUl9JTkpFQ1RJT04gaXMgbm90IHNldApDT05GSUdfRlVOQ1RJT05fRVJST1JfSU5KRUNUSU9O
PXkKIyBDT05GSUdfRkFVTFRfSU5KRUNUSU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfTEFURU5DWVRP
UCBpcyBub3Qgc2V0CkNPTkZJR19VU0VSX1NUQUNLVFJBQ0VfU1VQUE9SVD15CkNPTkZJR19OT1Bf
VFJBQ0VSPXkKQ09ORklHX0hBVkVfRlVOQ1RJT05fVFJBQ0VSPXkKQ09ORklHX0hBVkVfRlVOQ1RJ
T05fR1JBUEhfVFJBQ0VSPXkKQ09ORklHX0hBVkVfRFlOQU1JQ19GVFJBQ0U9eQpDT05GSUdfSEFW
RV9EWU5BTUlDX0ZUUkFDRV9XSVRIX1JFR1M9eQpDT05GSUdfSEFWRV9GVFJBQ0VfTUNPVU5UX1JF
Q09SRD15CkNPTkZJR19IQVZFX1NZU0NBTExfVFJBQ0VQT0lOVFM9eQpDT05GSUdfSEFWRV9GRU5U
Ulk9eQpDT05GSUdfSEFWRV9DX1JFQ09SRE1DT1VOVD15CkNPTkZJR19UUkFDRV9DTE9DSz15CkNP
TkZJR19SSU5HX0JVRkZFUj15CkNPTkZJR19FVkVOVF9UUkFDSU5HPXkKQ09ORklHX0NPTlRFWFRf
U1dJVENIX1RSQUNFUj15CkNPTkZJR19UUkFDSU5HPXkKQ09ORklHX0dFTkVSSUNfVFJBQ0VSPXkK
Q09ORklHX1RSQUNJTkdfU1VQUE9SVD15CkNPTkZJR19GVFJBQ0U9eQojIENPTkZJR19GVU5DVElP
Tl9UUkFDRVIgaXMgbm90IHNldAojIENPTkZJR19QUkVFTVBUSVJRX0VWRU5UUyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lSUVNPRkZfVFJBQ0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NIRURfVFJBQ0VS
IGlzIG5vdCBzZXQKIyBDT05GSUdfSFdMQVRfVFJBQ0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfRlRS
QUNFX1NZU0NBTExTIGlzIG5vdCBzZXQKIyBDT05GSUdfVFJBQ0VSX1NOQVBTSE9UIGlzIG5vdCBz
ZXQKQ09ORklHX0JSQU5DSF9QUk9GSUxFX05PTkU9eQojIENPTkZJR19QUk9GSUxFX0FOTk9UQVRF
RF9CUkFOQ0hFUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BST0ZJTEVfQUxMX0JSQU5DSEVTIGlzIG5v
dCBzZXQKIyBDT05GSUdfU1RBQ0tfVFJBQ0VSIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfSU9f
VFJBQ0U9eQpDT05GSUdfS1BST0JFX0VWRU5UUz15CkNPTkZJR19VUFJPQkVfRVZFTlRTPXkKQ09O
RklHX0RZTkFNSUNfRVZFTlRTPXkKQ09ORklHX1BST0JFX0VWRU5UUz15CiMgQ09ORklHX0ZUUkFD
RV9TVEFSVFVQX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19NTUlPVFJBQ0UgaXMgbm90IHNldAoj
IENPTkZJR19ISVNUX1RSSUdHRVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfVFJBQ0VQT0lOVF9CRU5D
SE1BUksgaXMgbm90IHNldAojIENPTkZJR19SSU5HX0JVRkZFUl9CRU5DSE1BUksgaXMgbm90IHNl
dAojIENPTkZJR19SSU5HX0JVRkZFUl9TVEFSVFVQX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19Q
UkVFTVBUSVJRX0RFTEFZX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19UUkFDRV9FVkFMX01BUF9G
SUxFIGlzIG5vdCBzZXQKQ09ORklHX1BST1ZJREVfT0hDSTEzOTRfRE1BX0lOSVQ9eQpDT05GSUdf
UlVOVElNRV9URVNUSU5HX01FTlU9eQpDT05GSUdfTEtEVE09bQpDT05GSUdfVEVTVF9MSVNUX1NP
UlQ9bQpDT05GSUdfVEVTVF9TT1JUPW0KIyBDT05GSUdfS1BST0JFU19TQU5JVFlfVEVTVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0JBQ0tUUkFDRV9TRUxGX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19S
QlRSRUVfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1JFRURfU09MT01PTl9URVNUIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSU5URVJWQUxfVFJFRV9URVNUIGlzIG5vdCBzZXQKIyBDT05GSUdfUEVSQ1BV
X1RFU1QgaXMgbm90IHNldAojIENPTkZJR19BVE9NSUM2NF9TRUxGVEVTVCBpcyBub3Qgc2V0CkNP
TkZJR19URVNUX0hFWERVTVA9bQpDT05GSUdfVEVTVF9TVFJJTkdfSEVMUEVSUz1tCkNPTkZJR19U
RVNUX1NUUlNDUFk9bQpDT05GSUdfVEVTVF9LU1RSVE9YPW0KQ09ORklHX1RFU1RfUFJJTlRGPW0K
Q09ORklHX1RFU1RfQklUTUFQPW0KQ09ORklHX1RFU1RfQklURklFTEQ9bQpDT05GSUdfVEVTVF9V
VUlEPW0KQ09ORklHX1RFU1RfWEFSUkFZPW0KQ09ORklHX1RFU1RfT1ZFUkZMT1c9bQpDT05GSUdf
VEVTVF9SSEFTSFRBQkxFPW0KQ09ORklHX1RFU1RfSEFTSD1tCkNPTkZJR19URVNUX0lEQT1tCkNP
TkZJR19URVNUX0xLTT1tCkNPTkZJR19URVNUX1ZNQUxMT0M9bQpDT05GSUdfVEVTVF9VU0VSX0NP
UFk9bQpDT05GSUdfVEVTVF9CUEY9bQojIENPTkZJR19URVNUX0JMQUNLSE9MRV9ERVYgaXMgbm90
IHNldAojIENPTkZJR19GSU5EX0JJVF9CRU5DSE1BUksgaXMgbm90IHNldApDT05GSUdfVEVTVF9G
SVJNV0FSRT1tCkNPTkZJR19URVNUX1NZU0NUTD1tCkNPTkZJR19URVNUX1VERUxBWT1tCkNPTkZJ
R19URVNUX1NUQVRJQ19LRVlTPW0KQ09ORklHX1RFU1RfS01PRD1tCkNPTkZJR19URVNUX01FTUNB
VF9QPW0KQ09ORklHX1RFU1RfU1RBQ0tJTklUPW0KIyBDT05GSUdfVEVTVF9NRU1JTklUIGlzIG5v
dCBzZXQKIyBDT05GSUdfTUVNVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX0JVR19PTl9EQVRBX0NP
UlJVUFRJT04gaXMgbm90IHNldAojIENPTkZJR19TQU1QTEVTIGlzIG5vdCBzZXQKQ09ORklHX0hB
VkVfQVJDSF9LR0RCPXkKIyBDT05GSUdfS0dEQiBpcyBub3Qgc2V0CkNPTkZJR19BUkNIX0hBU19V
QlNBTl9TQU5JVElaRV9BTEw9eQojIENPTkZJR19VQlNBTiBpcyBub3Qgc2V0CkNPTkZJR19VQlNB
Tl9BTElHTk1FTlQ9eQpDT05GSUdfQVJDSF9IQVNfREVWTUVNX0lTX0FMTE9XRUQ9eQpDT05GSUdf
U1RSSUNUX0RFVk1FTT15CiMgQ09ORklHX0lPX1NUUklDVF9ERVZNRU0gaXMgbm90IHNldApDT05G
SUdfVFJBQ0VfSVJRRkxBR1NfU1VQUE9SVD15CkNPTkZJR19FQVJMWV9QUklOVEtfVVNCPXkKQ09O
RklHX1g4Nl9WRVJCT1NFX0JPT1RVUD15CkNPTkZJR19FQVJMWV9QUklOVEs9eQpDT05GSUdfRUFS
TFlfUFJJTlRLX0RCR1A9eQojIENPTkZJR19FQVJMWV9QUklOVEtfVVNCX1hEQkMgaXMgbm90IHNl
dAojIENPTkZJR19YODZfUFREVU1QIGlzIG5vdCBzZXQKIyBDT05GSUdfRUZJX1BHVF9EVU1QIGlz
IG5vdCBzZXQKIyBDT05GSUdfREVCVUdfV1ggaXMgbm90IHNldApDT05GSUdfRE9VQkxFRkFVTFQ9
eQojIENPTkZJR19ERUJVR19UTEJGTFVTSCBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX01NSU9UUkFD
RV9TVVBQT1JUPXkKIyBDT05GSUdfWDg2X0RFQ09ERVJfU0VMRlRFU1QgaXMgbm90IHNldApDT05G
SUdfSU9fREVMQVlfMFg4MD15CiMgQ09ORklHX0lPX0RFTEFZXzBYRUQgaXMgbm90IHNldAojIENP
TkZJR19JT19ERUxBWV9VREVMQVkgaXMgbm90IHNldAojIENPTkZJR19JT19ERUxBWV9OT05FIGlz
IG5vdCBzZXQKQ09ORklHX0RFQlVHX0JPT1RfUEFSQU1TPXkKIyBDT05GSUdfQ1BBX0RFQlVHIGlz
IG5vdCBzZXQKIyBDT05GSUdfREVCVUdfRU5UUlkgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19O
TUlfU0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfWDg2X0RFQlVHX0ZQVT15CiMgQ09ORklHX1BV
TklUX0FUT01fREVCVUcgaXMgbm90IHNldApDT05GSUdfVU5XSU5ERVJfT1JDPXkKIyBDT05GSUdf
VU5XSU5ERVJfRlJBTUVfUE9JTlRFUiBpcyBub3Qgc2V0CiMgZW5kIG9mIEtlcm5lbCBoYWNraW5n
Cg==
--00000000000013f71a058e7e96ae--

