Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCA1CC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69B59208CB
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lr5iIx9N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69B59208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED9B16B000A; Wed, 29 May 2019 06:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8BA56B000C; Wed, 29 May 2019 06:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D525D6B0010; Wed, 29 May 2019 06:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B02346B000A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:00:44 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id i7so1369488ioh.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=rxJvymeAoiE6sbEeSvvXcrzmW6Hw+VYWW1ocpk8HwTc=;
        b=HecZiplZpS4DhlS0CjHR6OZvU763eU1q9A0q7Zuhdip5CDpB59q8os6mHvBkr07d4L
         z14scMK0qbg4egVpEX7ZQLHYAUfngJm5J+HEhDjwTZT/eeuvI5TNDi0fII8O8OCpOF6x
         hy8Ob8fmlg3YPsLc9VeCiPNSwidpvxejQQNzeroMbRPCk2uRH3KnZ+7pKZCEiHtyFKW1
         ac8e4iuTdDMy+eGRAqvTGnDZ2TndTs3QxdYB2ddrSlM9aA0sPNrWY9OZbw99hxYT+iSs
         5GIWt+Nt6cEvNxaqzo5pw54Os/x2YE7LhqC5agdPdrAOhcJqYMXSXqyyEOr2hU1+y67g
         Xmvg==
X-Gm-Message-State: APjAAAW5GNHJ2TPu1kYh9vn9XEZmUVSdC6Wo4m8bnfDy8vHjQDvuZuTM
	1iidxCSXI5W442Vly1e6ndCqjx2gTFJsXp0R87OpddstQbQtT4f9TKrgse79kJV4nmpfnKb7g/U
	hDDtRLOtbY0/G6FrJvTEiKefT975XlVrU+akPvl/EfUmISBMYB1VRbRDK8Sqra/yhuw==
X-Received: by 2002:a02:a384:: with SMTP id y4mr12747883jak.77.1559124044319;
        Wed, 29 May 2019 03:00:44 -0700 (PDT)
X-Received: by 2002:a02:a384:: with SMTP id y4mr12747788jak.77.1559124042715;
        Wed, 29 May 2019 03:00:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559124042; cv=none;
        d=google.com; s=arc-20160816;
        b=ZNYEQ9zThPZ5vfwyztY8LC4WoDZEl85mgqU0dfxddknF0b+bQ6LVeviAxUzjM212Ir
         vwwGsRLRrxuVm7dlcufqfxVVmlk7mkgrM36J3MaNfwTo47PsGdR8eAXUoNX8SVUb++Jv
         Ub7RoIlomTqDkQFpwutshXKPJ+IQSLDhNXvKNVs+qtHFDEYXQx98kffhueQhsT3Ql4wJ
         kyYsy3S+y2CuB+kRmLK7kY0pIOpBeU5Mg9AijHmR7ylfaocRLd8Yyxe/TrG5mZCjdq15
         fmJE97yktcnkIsFeqfjeoQVmsiGpCGMieh8aJTc95SYcShjdQA5ddxeyi31qa8kDlj6z
         TDYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=rxJvymeAoiE6sbEeSvvXcrzmW6Hw+VYWW1ocpk8HwTc=;
        b=XU1mdjKWqAV+tnC/hPBqkPXs6kAdhoqCLDKpoiPWjCl/I8vZxlCbKmn0nHDJJMAupk
         Bc7jHy78oh4BudlWrr0ZhS5gpfaqJvk77/zo8stZBcRuQ+b0b4HsLLb+VsRaEi3/ezYF
         E3AYF6V/JTO7R5JI7vYCH/yPaxAx+Lad6kXNvMCqxvSSsIoWNucTSloe1fKp5zKJJeVh
         huDBOtcuqUDh0Kdh3z6q0bqe5UWTu95zd9B9q+snV3+8n1wdG631Y0mjvYvUNpL/bXpI
         TdxarWLIU4yQEdOTMFDE7APHivhAMoCVLut0k1djJngOAPtwxnYUiDsayykmFhhVqKBO
         UKZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lr5iIx9N;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6sor2163214itb.24.2019.05.29.03.00.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 03:00:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lr5iIx9N;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=rxJvymeAoiE6sbEeSvvXcrzmW6Hw+VYWW1ocpk8HwTc=;
        b=lr5iIx9NATjU+M9UjJEWn0E9KgC7M/4KFifrJkaOkefAOWO2FcMzmhbmpighSHqLaO
         lrJFrSrrgRlAPdB65Aog+33Dy2z2Ymm5VH3D1Mbcd12BCXXtwpPyD/zCD8v1d7HHv+E2
         CuBq9Cy7QSGHkm7dS06Uq/DoF0XdxtODCmB/NfjIRfdOfxo869r0mAuEIBg32eq8d2mo
         T3ZnuMltEfNUswSA3o70y1vXlE8AasjN9O/BY+cKude15MTafK66OqR+uWmZMJKVtI+b
         d0yK+XCDwjKFlZLIkn2vJVyiOw90kBjP27w0Y0K1iy9/3ur4ZJd7BhQbVcJfL6sKjGmx
         pGWQ==
X-Google-Smtp-Source: APXvYqyXLjLm27FhIw6maJfTR4kxMF71cUIqKJy+Jo9wkia0ZNk3nAYkMaV4/Il8gWY2nIg+FIdgcDYEk3cAXN2PRPY=
X-Received: by 2002:a24:104a:: with SMTP id 71mr6684609ity.76.1559124041937;
 Wed, 29 May 2019 03:00:41 -0700 (PDT)
MIME-Version: 1.0
References: <1559027797-30303-1-git-send-email-walter-zh.wu@mediatek.com>
 <CACT4Y+aCnODuffR7PafyYispp_U+ZdY1Dr0XQYvmghkogLJzSw@mail.gmail.com> <1559122529.17186.24.camel@mtksdccf07>
In-Reply-To: <1559122529.17186.24.camel@mtksdccf07>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 May 2019 12:00:30 +0200
Message-ID: <CACT4Y+ZwXsBk8VqvDOJGMqrbVjuZ-HfC9RG4LpgRC-9WqmQJVw@mail.gmail.com>
Subject: Re: [PATCH] kasan: add memory corruption identification for software
 tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Miles Chen <miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-mediatek@lists.infradead.org, 
	wsd_upstream@mediatek.com, Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

 a   On Wed, May 29, 2019 at 11:35 AM Walter Wu
<walter-zh.wu@mediatek.com> wrote:
>
> > Hi Walter,
> >
> > Please describe your use case.
> > For testing context the generic KASAN works better and it does have
> > quarantine already. For prod/canary environment the quarantine may be
> > unacceptable in most cases.
> > I think we also want to use tag-based KASAN as a base for ARM MTE
> > support in near future and quarantine will be most likely unacceptable
> > for main MTE use cases. So at the very least I think this should be
> > configurable. +Catalin for this.
> >
> My patch hope the tag-based KASAN bug report make it easier for
> programmers to see memory corruption problem.
> Because now tag-based KASAN bug report always shows =E2=80=9Cinvalid-acce=
ss=E2=80=9D
> error, my patch can identify it whether it is use-after-free or
> out-of-bound.
>
> We can try to make our patch is feature option. Thanks your suggestion.
> Would you explain why the quarantine is unacceptable for main MTE?
> Thanks.
>
>
> > You don't change total quarantine size and charge only sizeof(struct
> > qlist_object). If I am reading this correctly, this means that
> > quarantine will have the same large overhead as with generic KASAN. We
> > will just cache much more objects there. The boot benchmarks may be
> > unrepresentative for this. Don't we need to reduce quarantine size or
> > something?
> >
> Yes, we will try to choose 2. My original idea is belong to it. So we
> will reduce quarantine size.
>
> 1). If quarantine size is the same with generic KASAN and tag-based
> KASAN, then the miss rate of use-after-free case in generic KASAN is
> larger than tag-based KASAN.
> 2). If tag-based KASAN quarantine size is smaller generic KASAN, then
> the miss rate of use-after-free case may be the same, but tag-based
> KASAN can save slab memory usage.
>
>
> >
> > > Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> > > ---
> > >  include/linux/kasan.h  |  20 +++++---
> > >  mm/kasan/Makefile      |   4 +-
> > >  mm/kasan/common.c      |  15 +++++-
> > >  mm/kasan/generic.c     |  11 -----
> > >  mm/kasan/kasan.h       |  45 ++++++++++++++++-
> > >  mm/kasan/quarantine.c  | 107 ++++++++++++++++++++++++++++++++++++++-=
--
> > >  mm/kasan/report.c      |  36 +++++++++-----
> > >  mm/kasan/tags.c        |  64 ++++++++++++++++++++++++
> > >  mm/kasan/tags_report.c |   5 +-
> > >  mm/slub.c              |   2 -
> > >  10 files changed, 262 insertions(+), 47 deletions(-)
> > >
> > > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > > index b40ea104dd36..bbb52a8bf4a9 100644
> > > --- a/include/linux/kasan.h
> > > +++ b/include/linux/kasan.h
> > > @@ -83,6 +83,9 @@ size_t kasan_metadata_size(struct kmem_cache *cache=
);
> > >  bool kasan_save_enable_multi_shot(void);
> > >  void kasan_restore_multi_shot(bool enabled);
> > >
> > > +void kasan_cache_shrink(struct kmem_cache *cache);
> > > +void kasan_cache_shutdown(struct kmem_cache *cache);
> > > +
> > >  #else /* CONFIG_KASAN */
> > >
> > >  static inline void kasan_unpoison_shadow(const void *address, size_t=
 size) {}
> > > @@ -153,20 +156,14 @@ static inline void kasan_remove_zero_shadow(voi=
d *start,
> > >  static inline void kasan_unpoison_slab(const void *ptr) { }
> > >  static inline size_t kasan_metadata_size(struct kmem_cache *cache) {=
 return 0; }
> > >
> > > +static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > +static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> > >  #endif /* CONFIG_KASAN */
> > >
> > >  #ifdef CONFIG_KASAN_GENERIC
> > >
> > >  #define KASAN_SHADOW_INIT 0
> > >
> > > -void kasan_cache_shrink(struct kmem_cache *cache);
> > > -void kasan_cache_shutdown(struct kmem_cache *cache);
> > > -
> > > -#else /* CONFIG_KASAN_GENERIC */
> > > -
> > > -static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > > -static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> >
> > Why do we need to move these functions?
> > For generic KASAN that's required because we store the objects
> > themselves in the quarantine, but it's not the case for tag-based mode
> > with your patch...
> >
> The quarantine in tag-based KASAN includes new objects which we create.
> Those objects are the freed information. They can be shrunk by calling
> them. So we move these function into CONFIG_KASAN.
>
>
> > > -
> > >  #endif /* CONFIG_KASAN_GENERIC */
> > >
> > >  #ifdef CONFIG_KASAN_SW_TAGS
> > > @@ -180,6 +177,8 @@ void *kasan_reset_tag(const void *addr);
> > >  void kasan_report(unsigned long addr, size_t size,
> > >                 bool is_write, unsigned long ip);
> > >
> > > +struct kasan_alloc_meta *get_object_track(void);
> > > +
> > >  #else /* CONFIG_KASAN_SW_TAGS */
> > >
> > >  static inline void kasan_init_tags(void) { }
> > > @@ -189,6 +188,11 @@ static inline void *kasan_reset_tag(const void *=
addr)
> > >         return (void *)addr;
> > >  }
> > >
> > > +static inline struct kasan_alloc_meta *get_object_track(void)
> > > +{
> > > +       return 0;
> > > +}
> > > +
> > >  #endif /* CONFIG_KASAN_SW_TAGS */
> > >
> > >  #endif /* LINUX_KASAN_H */
> > > diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> > > index 5d1065efbd47..03b0fe22ec55 100644
> > > --- a/mm/kasan/Makefile
> > > +++ b/mm/kasan/Makefile
> > > @@ -16,6 +16,6 @@ CFLAGS_common.o :=3D $(call cc-option, -fno-conserv=
e-stack -fno-stack-protector)
> > >  CFLAGS_generic.o :=3D $(call cc-option, -fno-conserve-stack -fno-sta=
ck-protector)
> > >  CFLAGS_tags.o :=3D $(call cc-option, -fno-conserve-stack -fno-stack-=
protector)
> > >
> > > -obj-$(CONFIG_KASAN) :=3D common.o init.o report.o
> > > -obj-$(CONFIG_KASAN_GENERIC) +=3D generic.o generic_report.o quaranti=
ne.o
> > > +obj-$(CONFIG_KASAN) :=3D common.o init.o report.o quarantine.o
> > > +obj-$(CONFIG_KASAN_GENERIC) +=3D generic.o generic_report.o
> > >  obj-$(CONFIG_KASAN_SW_TAGS) +=3D tags.o tags_report.o
> > > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > > index 80bbe62b16cd..919f693a58ab 100644
> > > --- a/mm/kasan/common.c
> > > +++ b/mm/kasan/common.c
> > > @@ -81,7 +81,7 @@ static inline depot_stack_handle_t save_stack(gfp_t=
 flags)
> > >         return depot_save_stack(&trace, flags);
> > >  }
> > >
> > > -static inline void set_track(struct kasan_track *track, gfp_t flags)
> > > +void set_track(struct kasan_track *track, gfp_t flags)
> > >  {
> > >         track->pid =3D current->pid;
> > >         track->stack =3D save_stack(flags);
> > > @@ -457,7 +457,7 @@ static bool __kasan_slab_free(struct kmem_cache *=
cache, void *object,
> > >                 return false;
> > >
> > >         set_track(&get_alloc_info(cache, object)->free_track, GFP_NOW=
AIT);
> > > -       quarantine_put(get_free_info(cache, object), cache);
> > > +       quarantine_put(get_free_info(cache, tagged_object), cache);
> >
> > Why do we need this change?
> >
> In order to add freed object information into quarantine.
> The freed object information is tag address , size, and free backtrace.

Ah, I see, so we remember the tagged pointer and then search the
object in quarantine using tagged pointer. That's smart.


> > >         return IS_ENABLED(CONFIG_KASAN_GENERIC);
> > >  }
> > > @@ -614,6 +614,17 @@ void kasan_free_shadow(const struct vm_struct *v=
m)
> > >                 vfree(kasan_mem_to_shadow(vm->addr));
> > >  }
> > >
> > > +void kasan_cache_shrink(struct kmem_cache *cache)
> > > +{
> > > +       quarantine_remove_cache(cache);
> > > +}
> > > +
> > > +void kasan_cache_shutdown(struct kmem_cache *cache)
> > > +{
> > > +       if (!__kmem_cache_empty(cache))
> > > +               quarantine_remove_cache(cache);
> > > +}
> > > +
> > >  #ifdef CONFIG_MEMORY_HOTPLUG
> > >  static bool shadow_mapped(unsigned long addr)
> > >  {
> > > diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
> > > index 504c79363a34..5f579051dead 100644
> > > --- a/mm/kasan/generic.c
> > > +++ b/mm/kasan/generic.c
> > > @@ -191,17 +191,6 @@ void check_memory_region(unsigned long addr, siz=
e_t size, bool write,
> > >         check_memory_region_inline(addr, size, write, ret_ip);
> > >  }
> > >
> > > -void kasan_cache_shrink(struct kmem_cache *cache)
> > > -{
> > > -       quarantine_remove_cache(cache);
> > > -}
> > > -
> > > -void kasan_cache_shutdown(struct kmem_cache *cache)
> > > -{
> > > -       if (!__kmem_cache_empty(cache))
> > > -               quarantine_remove_cache(cache);
> > > -}
> > > -
> > >  static void register_global(struct kasan_global *global)
> > >  {
> > >         size_t aligned_size =3D round_up(global->size, KASAN_SHADOW_S=
CALE_SIZE);
> > > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> > > index 3e0c11f7d7a1..6848a93660d9 100644
> > > --- a/mm/kasan/kasan.h
> > > +++ b/mm/kasan/kasan.h
> > > @@ -95,9 +95,21 @@ struct kasan_alloc_meta {
> > >         struct kasan_track free_track;
> > >  };
> > >
> > > +#ifdef CONFIG_KASAN_GENERIC
> > >  struct qlist_node {
> > >         struct qlist_node *next;
> > >  };
> > > +#else
> > > +struct qlist_object {
> > > +       unsigned long addr;
> > > +       unsigned int size;
> > > +       struct kasan_alloc_meta free_track;
> >
> > Why is this kasan_alloc_meta rather then kasan_track? We don't
> > memorize alloc stack...
> >
> Yes, you are right, we only need the free_track of kasan_alloc_meta. We
> will change it.
>
>
> > > +};
> > > +struct qlist_node {
> > > +       struct qlist_object *qobject;
> > > +       struct qlist_node *next;
> > > +};
> > > +#endif
> > >  struct kasan_free_meta {
> > >         /* This field is used while the object is in the quarantine.
> > >          * Otherwise it might be used for the allocator freelist.
> > > @@ -133,16 +145,19 @@ void kasan_report(unsigned long addr, size_t si=
ze,
> > >                 bool is_write, unsigned long ip);
> > >  void kasan_report_invalid_free(void *object, unsigned long ip);
> > >
> > > -#if defined(CONFIG_KASAN_GENERIC) && \
> > > +#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS) &=
& \
> >
> > This condition seems to be always true, no?
> >
> Yes, it is always true, it should be removed.
>
>
> > >         (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
> > > +
> > >  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache =
*cache);
> > >  void quarantine_reduce(void);
> > >  void quarantine_remove_cache(struct kmem_cache *cache);
> > > +void set_track(struct kasan_track *track, gfp_t flags);
> > >  #else
> > >  static inline void quarantine_put(struct kasan_free_meta *info,
> > >                                 struct kmem_cache *cache) { }
> > >  static inline void quarantine_reduce(void) { }
> > >  static inline void quarantine_remove_cache(struct kmem_cache *cache)=
 { }
> > > +static inline void set_track(struct kasan_track *track, gfp_t flags)=
 {}
> > >  #endif
> > >
> > >  #ifdef CONFIG_KASAN_SW_TAGS
> > > @@ -151,6 +166,15 @@ void print_tags(u8 addr_tag, const void *addr);
> > >
> > >  u8 random_tag(void);
> > >
> > > +bool quarantine_find_object(void *object);
> > > +
> > > +int qobject_add_size(void);
> >
> > Would be more reasonable to use size_t type for object sizes.
> >
> the sum of qobect and qnode size?
>
>
> > > +
> > > +struct qlist_node *qobject_create(struct kasan_free_meta *info,
> > > +               struct kmem_cache *cache);
> > > +
> > > +void qobject_free(struct qlist_node *qlink, struct kmem_cache *cache=
);
> > > +
> > >  #else
> > >
> > >  static inline void print_tags(u8 addr_tag, const void *addr) { }
> > > @@ -160,6 +184,25 @@ static inline u8 random_tag(void)
> > >         return 0;
> > >  }
> > >
> > > +static inline bool quarantine_find_object(void *object)
> > > +{
> > > +       return 0;
> >
> > s/0/false/
> >
> Thanks for your friendly reminder. we will change it.
>
>
> > > +}
> > > +
> > > +static inline int qobject_add_size(void)
> > > +{
> > > +       return 0;
> > > +}
> > > +
> > > +static inline struct qlist_node *qobject_create(struct kasan_free_me=
ta *info,
> > > +               struct kmem_cache *cache)
> > > +{
> > > +       return 0;
> >
> > s/0/NULL/
> >
> Thanks for your friendly reminder. we will change it.
>
>
> > > +}
> > > +
> > > +static inline void qobject_free(struct qlist_node *qlink,
> > > +               struct kmem_cache *cache) {}
> > > +
> > >  #endif
> > >
> > >  #ifndef arch_kasan_set_tag
> > > diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> > > index 978bc4a3eb51..f14c8dbec552 100644
> > > --- a/mm/kasan/quarantine.c
> > > +++ b/mm/kasan/quarantine.c
> > > @@ -67,7 +67,10 @@ static void qlist_put(struct qlist_head *q, struct=
 qlist_node *qlink,
> > >                 q->tail->next =3D qlink;
> > >         q->tail =3D qlink;
> > >         qlink->next =3D NULL;
> > > -       q->bytes +=3D size;
> > > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
> >
> > It would be more reasonable to pass the right size from the caller. It
> > already have to have the branch on CONFIG_KASAN_SW_TAGS because it
> > needs to allocate qobject or not, that would be the right place to
> > pass the right size.
> >
> In tag-based KASAN, we will pass the sum of qobject and qnode size to it
> and review qlist_put() caller whether it pass right size.
>
>
> > > +               q->bytes +=3D qobject_add_size();
> > > +       else
> > > +               q->bytes +=3D size;
> > >  }
> > >
> > >  static void qlist_move_all(struct qlist_head *from, struct qlist_hea=
d *to)
> > > @@ -139,13 +142,18 @@ static void *qlink_to_object(struct qlist_node =
*qlink, struct kmem_cache *cache)
> > >
> > >  static void qlink_free(struct qlist_node *qlink, struct kmem_cache *=
cache)
> > >  {
> > > -       void *object =3D qlink_to_object(qlink, cache);
> > >         unsigned long flags;
> > > +       struct kmem_cache *obj_cache =3D
> > > +                       cache ? cache : qlink_to_cache(qlink);
> > > +       void *object =3D qlink_to_object(qlink, obj_cache);
> > > +
> > > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
> > > +               qobject_free(qlink, cache);
> > >
> > >         if (IS_ENABLED(CONFIG_SLAB))
> > >                 local_irq_save(flags);
> > >
> > > -       ___cache_free(cache, object, _THIS_IP_);
> > > +       ___cache_free(obj_cache, object, _THIS_IP_);
> > >
> > >         if (IS_ENABLED(CONFIG_SLAB))
> > >                 local_irq_restore(flags);
> > > @@ -160,11 +168,9 @@ static void qlist_free_all(struct qlist_head *q,=
 struct kmem_cache *cache)
> > >
> > >         qlink =3D q->head;
> > >         while (qlink) {
> > > -               struct kmem_cache *obj_cache =3D
> > > -                       cache ? cache : qlink_to_cache(qlink);
> > >                 struct qlist_node *next =3D qlink->next;
> > >
> > > -               qlink_free(qlink, obj_cache);
> > > +               qlink_free(qlink, cache);
> > >                 qlink =3D next;
> > >         }
> > >         qlist_init(q);
> > > @@ -187,7 +193,18 @@ void quarantine_put(struct kasan_free_meta *info=
, struct kmem_cache *cache)
> > >         local_irq_save(flags);
> > >
> > >         q =3D this_cpu_ptr(&cpu_quarantine);
> > > -       qlist_put(q, &info->quarantine_link, cache->size);
> > > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS)) {
> > > +               struct qlist_node *free_obj_info =3D qobject_create(i=
nfo, cache);
> > > +
> > > +               if (!free_obj_info) {
> > > +                       local_irq_restore(flags);
> > > +                       return;
> > > +               }
> > > +               qlist_put(q, free_obj_info, cache->size);
> > > +       } else {
> > > +               qlist_put(q, &info->quarantine_link, cache->size);
> > > +       }
> > > +
> > >         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
> > >                 qlist_move_all(q, &temp);
> > >
> > > @@ -327,3 +344,79 @@ void quarantine_remove_cache(struct kmem_cache *=
cache)
> > >
> > >         synchronize_srcu(&remove_cache_srcu);
> > >  }
> > > +
> > > +#ifdef CONFIG_KASAN_SW_TAGS
> > > +static struct kasan_alloc_meta object_free_track;
> >
> > This global is a dirty solution. It's better passed as argument to the
> > required functions rather than functions leave part of state in a
> > global and somebody picks it up later.
> >
> Thanks your suggestion, we will change the implementation here.
>
>
> > > +
> > > +struct kasan_alloc_meta *get_object_track(void)
> > > +{
> > > +       return &object_free_track;
> > > +}
> > > +
> > > +static bool qlist_find_object(struct qlist_head *from, void *addr)
> > > +{
> > > +       struct qlist_node *curr;
> > > +       struct qlist_object *curr_obj;
> > > +
> > > +       if (unlikely(qlist_empty(from)))
> > > +               return false;
> > > +
> > > +       curr =3D from->head;
> > > +       while (curr) {
> > > +               struct qlist_node *next =3D curr->next;
> > > +
> > > +               curr_obj =3D curr->qobject;
> > > +               if (unlikely(((unsigned long)addr >=3D curr_obj->addr=
)
> > > +                       && ((unsigned long)addr <
> > > +                                       (curr_obj->addr + curr_obj->s=
ize)))) {
> > > +                       object_free_track =3D curr_obj->free_track;
> > > +
> > > +                       return true;
> > > +               }
> > > +
> > > +               curr =3D next;
> > > +       }
> > > +       return false;
> > > +}
> > > +
> > > +static int per_cpu_find_object(void *arg)
> > > +{
> > > +       void *addr =3D arg;
> > > +       struct qlist_head *q;
> > > +
> > > +       q =3D this_cpu_ptr(&cpu_quarantine);
> > > +       return qlist_find_object(q, addr);
> > > +}
> > > +
> > > +struct cpumask cpu_allowed_mask __read_mostly;
> > > +
> > > +bool quarantine_find_object(void *addr)
> > > +{
> > > +       unsigned long flags, i;
> > > +       bool find =3D false;
> > > +       int cpu;
> > > +
> > > +       cpumask_copy(&cpu_allowed_mask, cpu_online_mask);
> > > +       for_each_cpu(cpu, &cpu_allowed_mask) {
> > > +               find =3D smp_call_on_cpu(cpu, per_cpu_find_object, ad=
dr, true);
> >
> > There can be multiple qobjects in the quarantine associated with the
> > address, right? If so, we need to find the last one rather then a
> > random one.
> >
> The qobject includes the address which has tag and range, corruption
> address must be satisfied with the same tag and within object address
> range, then it is found in the quarantine.
> It should not easy to get multiple qobjects have the same tag and within
> object address range.

Yes, using the tag for matching (which I missed) makes the match less likel=
y.

But I think we should at least try to find the newest object in
best-effort manner.
Consider, both slab and slub reallocate objects in LIFO manner and we
don't have a quarantine for objects themselves. So if we have a loop
that allocates and frees an object of same size a dozen of times.
That's enough to get a duplicate pointer+tag qobject.
This includes:
1. walking the global quarantine from quarantine_tail backwards.
2. walking per-cpu lists in the opposite direction: from tail rather
then from head. I guess we don't have links, so we could change the
order and prepend new objects from head.
This way we significantly increase chances of finding the right
object. This also deserves a comment mentioning that we can find a
wrong objects.



> > > +               if (find)
> > > +                       return true;
> > > +       }
> > > +
> > > +       raw_spin_lock_irqsave(&quarantine_lock, flags);
> > > +       for (i =3D 0; i < QUARANTINE_BATCHES; i++) {
> > > +               if (qlist_empty(&global_quarantine[i]))
> > > +                       continue;
> > > +               find =3D qlist_find_object(&global_quarantine[i], add=
r);
> > > +               /* Scanning whole quarantine can take a while. */
> > > +               raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> > > +               cond_resched();
> > > +               raw_spin_lock_irqsave(&quarantine_lock, flags);
> > > +       }
> > > +       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> > > +
> > > +       synchronize_srcu(&remove_cache_srcu);
> > > +
> > > +       return find;
> > > +}
> > > +#endif
> > > diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> > > index ca9418fe9232..9cfabf2f0c40 100644
> > > --- a/mm/kasan/report.c
> > > +++ b/mm/kasan/report.c
> > > @@ -150,18 +150,26 @@ static void describe_object_addr(struct kmem_ca=
che *cache, void *object,
> > >  }
> > >
> > >  static void describe_object(struct kmem_cache *cache, void *object,
> > > -                               const void *addr)
> > > +                               const void *tagged_addr)
> > >  {
> > > +       void *untagged_addr =3D reset_tag(tagged_addr);
> > >         struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache,=
 object);
> > >
> > >         if (cache->flags & SLAB_KASAN) {
> > > -               print_track(&alloc_info->alloc_track, "Allocated");
> > > -               pr_err("\n");
> > > -               print_track(&alloc_info->free_track, "Freed");
> > > -               pr_err("\n");
> > > +               if (IS_ENABLED(CONFIG_KASAN_SW_TAGS) &&
> > > +                       quarantine_find_object((void *)tagged_addr)) =
{
> >
> > Can't this be an out-of-bound even if we find the object in quarantine?
> > For example, if we've freed an object, then reallocated and accessed
> > out-of-bounds within the object bounds?
> > Overall suggesting that this is a use-after-free rather than
> > out-of-bounds without redzones and quarantining the object itself is
> > quite imprecise. We can confuse a user even more...
> >
> the qobject stores object range and address which has tag, even if
> the object reallocate and accessed out-of-bounds, then new object and
> old object in quarantine should be different tag value, so it should be
> no found in quarantine.
>
>
> >
> > > +                       alloc_info =3D get_object_track();
> > > +                       print_track(&alloc_info->free_track, "Freed")=
;
> > > +                       pr_err("\n");
> > > +               } else {
> > > +                       print_track(&alloc_info->alloc_track, "Alloca=
ted");
> > > +                       pr_err("\n");
> > > +                       print_track(&alloc_info->free_track, "Freed")=
;
> > > +                       pr_err("\n");
> > > +               }
> > >         }
> > >
> > > -       describe_object_addr(cache, object, addr);
> > > +       describe_object_addr(cache, object, untagged_addr);
> > >  }
> > >
> > >  static inline bool kernel_or_module_addr(const void *addr)
> > > @@ -180,23 +188,25 @@ static inline bool init_task_stack_addr(const v=
oid *addr)
> > >                         sizeof(init_thread_union.stack));
> > >  }
> > >
> > > -static void print_address_description(void *addr)
> > > +static void print_address_description(void *tagged_addr)
> > >  {
> > > -       struct page *page =3D addr_to_page(addr);
> > > +       void *untagged_addr =3D reset_tag(tagged_addr);
> > > +       struct page *page =3D addr_to_page(untagged_addr);
> > >
> > >         dump_stack();
> > >         pr_err("\n");
> > >
> > >         if (page && PageSlab(page)) {
> > >                 struct kmem_cache *cache =3D page->slab_cache;
> > > -               void *object =3D nearest_obj(cache, page, addr);
> > > +               void *object =3D nearest_obj(cache, page, untagged_ad=
dr);
> > >
> > > -               describe_object(cache, object, addr);
> > > +               describe_object(cache, object, tagged_addr);
> > >         }
> > >
> > > -       if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr=
)) {
> > > +       if (kernel_or_module_addr(untagged_addr) &&
> > > +                       !init_task_stack_addr(untagged_addr)) {
> > >                 pr_err("The buggy address belongs to the variable:\n"=
);
> > > -               pr_err(" %pS\n", addr);
> > > +               pr_err(" %pS\n", untagged_addr);
> > >         }
> > >
> > >         if (page) {
> > > @@ -314,7 +324,7 @@ void kasan_report(unsigned long addr, size_t size=
,
> > >         pr_err("\n");
> > >
> > >         if (addr_has_shadow(untagged_addr)) {
> > > -               print_address_description(untagged_addr);
> > > +               print_address_description(tagged_addr);
> > >                 pr_err("\n");
> > >                 print_shadow_for_address(info.first_bad_addr);
> > >         } else {
> > > diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
> > > index 63fca3172659..fa5d1e29003d 100644
> > > --- a/mm/kasan/tags.c
> > > +++ b/mm/kasan/tags.c
> > > @@ -124,6 +124,70 @@ void check_memory_region(unsigned long addr, siz=
e_t size, bool write,
> > >         }
> > >  }
> > >
> > > +int qobject_add_size(void)
> > > +{
> > > +       return sizeof(struct qlist_object);
> >
> > Shouldn't this also account for qlist_node?
> >
> yes, we will count it.
>
>
> > > +}
> > > +
> > > +static struct kmem_cache *qobject_to_cache(struct qlist_object *qobj=
ect)
> > > +{
> > > +       return virt_to_head_page(qobject)->slab_cache;
> > > +}
> > > +
> > > +struct qlist_node *qobject_create(struct kasan_free_meta *info,
> > > +                                               struct kmem_cache *ca=
che)
> > > +{
> > > +       struct qlist_node *free_obj_info;
> > > +       struct qlist_object *qobject_info;
> > > +       struct kasan_alloc_meta *object_track;
> > > +       void *object;
> > > +
> > > +       object =3D ((void *)info) - cache->kasan_info.free_meta_offse=
t;
> > > +       qobject_info =3D kmalloc(sizeof(struct qlist_object), GFP_NOW=
AIT);
> > > +       if (!qobject_info)
> > > +               return NULL;
> > > +       qobject_info->addr =3D (unsigned long) object;
> > > +       qobject_info->size =3D cache->object_size;
> > > +       object_track =3D &qobject_info->free_track;
> > > +       set_track(&object_track->free_track, GFP_NOWAIT);
> > > +
> > > +       free_obj_info =3D kmalloc(sizeof(struct qlist_node), GFP_NOWA=
IT);
> >
> > Why don't we allocate qlist_object and qlist_node in a single
> > allocation? Doing 2 allocations is both unnecessary slow and leads to
> > more complex code. We need to allocate them with a single allocations.
> > Also I think they should be allocated from a dedicated cache that opts
> > out of quarantine?
> >
> Single allocation is good suggestion, if we only has one allocation.
> then we need to move all member of qlist_object to qlist_node?
>
> struct qlist_object {
>     unsigned long addr;
>     unsigned int size;
>     struct kasan_alloc_meta free_track;
> };
> struct qlist_node {
>     struct qlist_object *qobject;
>     struct qlist_node *next;
> };

I see 2 options:
1. add addr/size/free_track to qlist_node under ifdef CONFIG_KASAN_SW_TAGS
2. or probably better would be to include qlist_node into qlist_object
as first field, then allocate qlist_object and cast it to qlist_node
when adding to quarantine, and then as we iterate quarantine, we cast
qlist_node back to qlist_object and can access size/addr.


> We call call ___cache_free() to free the qobject and qnode, it should be
> out of quarantine?

This should work.

