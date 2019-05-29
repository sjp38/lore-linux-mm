Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4235FC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACFE720B1F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 09:35:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACFE720B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 157396B000A; Wed, 29 May 2019 05:35:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 108F16B000C; Wed, 29 May 2019 05:35:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F13CF6B0010; Wed, 29 May 2019 05:35:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAAE76B000A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 05:35:36 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so1174994plf.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 02:35:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=hw+1Ev5zFt94wvsuAYSmAQUyzNkosySEKNw8VlJkIRc=;
        b=WJ3az2SQrFqNQ7FZ1Gb5KQrcY0x09HvJYLG7vMDyHuMM2cmu+Xt/5yJF1r4Hc1Q0vc
         Dqs/ijbB3fJDS9N8peZ5Z6gkPClzNwdLT9Q2k1D/eyTcESjtIyxnXH7QLW9cDqzHA/q+
         rDJxEUBSggm5idiM0EV6rCWFRLu6GeR0HYKIrkpsQQ8F09jejX5GxXrlyOv+gcdA4oM8
         e2/ZBMVSUkZwwghn+MzBDJEKzEaf3wDkcJOPM4nzN2rj2bG5KiqSVWW02lzMVAZrzOEU
         zNQST6eGjwa1d5JbSauBNMVO+qOQX9xHuP41OCs6KzN1QJsZDFX5ZYqrNFL/Br8DNJI4
         vHsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAUpgHaltwdhKFVSJDujSN4qkDT2ObLHzOcUFS//T1lcC9cR6Fwl
	Ugo1w31Dh2T2TJi7z+OeYOn7rvrbGGju1VV6u/vSaBRXBVAncintfAQV7RXlzBDrk0jbTXD5Xcq
	5jWnuCrN0DZ3iLDO0QIx9ZDIm7CxVNRj8bb7IDUlD80lNbDSCkoqA45sd3TDBU4X/jw==
X-Received: by 2002:a17:902:9b88:: with SMTP id y8mr12597514plp.309.1559122536283;
        Wed, 29 May 2019 02:35:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTsno1MQPEk8O6lWv8amgHB4PthyYXf8xDFhaif6ggQ3l9ig/YHI9MHEjqZL5T9meaFrAL
X-Received: by 2002:a17:902:9b88:: with SMTP id y8mr12597374plp.309.1559122534748;
        Wed, 29 May 2019 02:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559122534; cv=none;
        d=google.com; s=arc-20160816;
        b=z3rfwuFB7zeD4Vppwz0VuIdZ/qKVk/vM5f06/b4rtJuaRw1YRJ5U4zMxiKaDy4zuIn
         MmxOpRT2AXbN6kPZxUxiRWG5NzYHzihFwBbjoutZ29zd1pu4dFuK4Afl08N4Fzcc/Hm/
         HBDfOHsdUWXfx1YBCiy7j1fSMM8Mj7d6rwqFm8kuzfWaXdOYQdGEXHDvWqKM4tByQJYJ
         RARsYw3TZRfjWTpN4UhIvDobYWS+MYKk6z4XdB7zqtKmBT3q2l5oJRHZhHx8MTKqPEH6
         nOokcNmbk0YF2wQb/w6QBt1GMT1IyPuc4oL7LEeHJ2baB6YjoeNMAGuS0/nG3MSn4TgN
         IYDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=hw+1Ev5zFt94wvsuAYSmAQUyzNkosySEKNw8VlJkIRc=;
        b=LLjn0OoRi2/gboDYETE5MMgbiA8UtOJ2zjWEd7a1QokKuYmxQ3FBBvFVDkne6L0SSw
         cIWFdADiMfYXt7dGklCD58OcmCJE8OExs0sXgfAdzjrPxLfs25G1T3itJ6mfQEZHtYOt
         pH6TZXQhal09kTK0LzTxTYBlsSia7B9gx52spuvIa5GyBb6dWY4eo6H+W29LNm4KkX7b
         spEKINAAl36PLx2e9sqCx8AyopV8/Glf70ud9lrSMud8kH7o8oxzFw9HSZbkwe34DoUX
         qZnfJb5aT1WNC8BRA85ueSN/sLG06y5p9ZryAqmqmdGdK4zN39arzxF0+vB/voj8jdJT
         yRPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id d36si16664031pla.113.2019.05.29.02.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 02:35:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: d30e00251bb840368195b29455158f68-20190529
X-UUID: d30e00251bb840368195b29455158f68-20190529
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 605601674; Wed, 29 May 2019 17:35:31 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 29 May 2019 17:35:29 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 29 May 2019 17:35:29 +0800
Message-ID: <1559122529.17186.24.camel@mtksdccf07>
Subject: Re: [PATCH] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Dmitry Vyukov <dvyukov@google.com>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Miles
 Chen" <miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Linux ARM"
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, "Catalin Marinas" <catalin.marinas@arm.com>
Date: Wed, 29 May 2019 17:35:29 +0800
In-Reply-To: <CACT4Y+aCnODuffR7PafyYispp_U+ZdY1Dr0XQYvmghkogLJzSw@mail.gmail.com>
References: <1559027797-30303-1-git-send-email-walter-zh.wu@mediatek.com>
	 <CACT4Y+aCnODuffR7PafyYispp_U+ZdY1Dr0XQYvmghkogLJzSw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi Walter,
> 
> Please describe your use case.
> For testing context the generic KASAN works better and it does have
> quarantine already. For prod/canary environment the quarantine may be
> unacceptable in most cases.
> I think we also want to use tag-based KASAN as a base for ARM MTE
> support in near future and quarantine will be most likely unacceptable
> for main MTE use cases. So at the very least I think this should be
> configurable. +Catalin for this.
> 
My patch hope the tag-based KASAN bug report make it easier for
programmers to see memory corruption problem. 
Because now tag-based KASAN bug report always shows “invalid-access”
error, my patch can identify it whether it is use-after-free or
out-of-bound.

We can try to make our patch is feature option. Thanks your suggestion.
Would you explain why the quarantine is unacceptable for main MTE?
Thanks.


> You don't change total quarantine size and charge only sizeof(struct
> qlist_object). If I am reading this correctly, this means that
> quarantine will have the same large overhead as with generic KASAN. We
> will just cache much more objects there. The boot benchmarks may be
> unrepresentative for this. Don't we need to reduce quarantine size or
> something?
> 
Yes, we will try to choose 2. My original idea is belong to it. So we
will reduce quarantine size.

1). If quarantine size is the same with generic KASAN and tag-based
KASAN, then the miss rate of use-after-free case in generic KASAN is
larger than tag-based KASAN.
2). If tag-based KASAN quarantine size is smaller generic KASAN, then
the miss rate of use-after-free case may be the same, but tag-based
KASAN can save slab memory usage.


> 
> > Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> > ---
> >  include/linux/kasan.h  |  20 +++++---
> >  mm/kasan/Makefile      |   4 +-
> >  mm/kasan/common.c      |  15 +++++-
> >  mm/kasan/generic.c     |  11 -----
> >  mm/kasan/kasan.h       |  45 ++++++++++++++++-
> >  mm/kasan/quarantine.c  | 107 ++++++++++++++++++++++++++++++++++++++---
> >  mm/kasan/report.c      |  36 +++++++++-----
> >  mm/kasan/tags.c        |  64 ++++++++++++++++++++++++
> >  mm/kasan/tags_report.c |   5 +-
> >  mm/slub.c              |   2 -
> >  10 files changed, 262 insertions(+), 47 deletions(-)
> >
> > diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> > index b40ea104dd36..bbb52a8bf4a9 100644
> > --- a/include/linux/kasan.h
> > +++ b/include/linux/kasan.h
> > @@ -83,6 +83,9 @@ size_t kasan_metadata_size(struct kmem_cache *cache);
> >  bool kasan_save_enable_multi_shot(void);
> >  void kasan_restore_multi_shot(bool enabled);
> >
> > +void kasan_cache_shrink(struct kmem_cache *cache);
> > +void kasan_cache_shutdown(struct kmem_cache *cache);
> > +
> >  #else /* CONFIG_KASAN */
> >
> >  static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
> > @@ -153,20 +156,14 @@ static inline void kasan_remove_zero_shadow(void *start,
> >  static inline void kasan_unpoison_slab(const void *ptr) { }
> >  static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
> >
> > +static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > +static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> >  #endif /* CONFIG_KASAN */
> >
> >  #ifdef CONFIG_KASAN_GENERIC
> >
> >  #define KASAN_SHADOW_INIT 0
> >
> > -void kasan_cache_shrink(struct kmem_cache *cache);
> > -void kasan_cache_shutdown(struct kmem_cache *cache);
> > -
> > -#else /* CONFIG_KASAN_GENERIC */
> > -
> > -static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> > -static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
> 
> Why do we need to move these functions?
> For generic KASAN that's required because we store the objects
> themselves in the quarantine, but it's not the case for tag-based mode
> with your patch...
> 
The quarantine in tag-based KASAN includes new objects which we create.
Those objects are the freed information. They can be shrunk by calling
them. So we move these function into CONFIG_KASAN. 


> > -
> >  #endif /* CONFIG_KASAN_GENERIC */
> >
> >  #ifdef CONFIG_KASAN_SW_TAGS
> > @@ -180,6 +177,8 @@ void *kasan_reset_tag(const void *addr);
> >  void kasan_report(unsigned long addr, size_t size,
> >                 bool is_write, unsigned long ip);
> >
> > +struct kasan_alloc_meta *get_object_track(void);
> > +
> >  #else /* CONFIG_KASAN_SW_TAGS */
> >
> >  static inline void kasan_init_tags(void) { }
> > @@ -189,6 +188,11 @@ static inline void *kasan_reset_tag(const void *addr)
> >         return (void *)addr;
> >  }
> >
> > +static inline struct kasan_alloc_meta *get_object_track(void)
> > +{
> > +       return 0;
> > +}
> > +
> >  #endif /* CONFIG_KASAN_SW_TAGS */
> >
> >  #endif /* LINUX_KASAN_H */
> > diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> > index 5d1065efbd47..03b0fe22ec55 100644
> > --- a/mm/kasan/Makefile
> > +++ b/mm/kasan/Makefile
> > @@ -16,6 +16,6 @@ CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
> >  CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
> >  CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
> >
> > -obj-$(CONFIG_KASAN) := common.o init.o report.o
> > -obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o quarantine.o
> > +obj-$(CONFIG_KASAN) := common.o init.o report.o quarantine.o
> > +obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o
> >  obj-$(CONFIG_KASAN_SW_TAGS) += tags.o tags_report.o
> > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > index 80bbe62b16cd..919f693a58ab 100644
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -81,7 +81,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
> >         return depot_save_stack(&trace, flags);
> >  }
> >
> > -static inline void set_track(struct kasan_track *track, gfp_t flags)
> > +void set_track(struct kasan_track *track, gfp_t flags)
> >  {
> >         track->pid = current->pid;
> >         track->stack = save_stack(flags);
> > @@ -457,7 +457,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
> >                 return false;
> >
> >         set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
> > -       quarantine_put(get_free_info(cache, object), cache);
> > +       quarantine_put(get_free_info(cache, tagged_object), cache);
> 
> Why do we need this change?
> 
In order to add freed object information into quarantine.
The freed object information is tag address , size, and free backtrace.


> >
> >         return IS_ENABLED(CONFIG_KASAN_GENERIC);
> >  }
> > @@ -614,6 +614,17 @@ void kasan_free_shadow(const struct vm_struct *vm)
> >                 vfree(kasan_mem_to_shadow(vm->addr));
> >  }
> >
> > +void kasan_cache_shrink(struct kmem_cache *cache)
> > +{
> > +       quarantine_remove_cache(cache);
> > +}
> > +
> > +void kasan_cache_shutdown(struct kmem_cache *cache)
> > +{
> > +       if (!__kmem_cache_empty(cache))
> > +               quarantine_remove_cache(cache);
> > +}
> > +
> >  #ifdef CONFIG_MEMORY_HOTPLUG
> >  static bool shadow_mapped(unsigned long addr)
> >  {
> > diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
> > index 504c79363a34..5f579051dead 100644
> > --- a/mm/kasan/generic.c
> > +++ b/mm/kasan/generic.c
> > @@ -191,17 +191,6 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
> >         check_memory_region_inline(addr, size, write, ret_ip);
> >  }
> >
> > -void kasan_cache_shrink(struct kmem_cache *cache)
> > -{
> > -       quarantine_remove_cache(cache);
> > -}
> > -
> > -void kasan_cache_shutdown(struct kmem_cache *cache)
> > -{
> > -       if (!__kmem_cache_empty(cache))
> > -               quarantine_remove_cache(cache);
> > -}
> > -
> >  static void register_global(struct kasan_global *global)
> >  {
> >         size_t aligned_size = round_up(global->size, KASAN_SHADOW_SCALE_SIZE);
> > diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> > index 3e0c11f7d7a1..6848a93660d9 100644
> > --- a/mm/kasan/kasan.h
> > +++ b/mm/kasan/kasan.h
> > @@ -95,9 +95,21 @@ struct kasan_alloc_meta {
> >         struct kasan_track free_track;
> >  };
> >
> > +#ifdef CONFIG_KASAN_GENERIC
> >  struct qlist_node {
> >         struct qlist_node *next;
> >  };
> > +#else
> > +struct qlist_object {
> > +       unsigned long addr;
> > +       unsigned int size;
> > +       struct kasan_alloc_meta free_track;
> 
> Why is this kasan_alloc_meta rather then kasan_track? We don't
> memorize alloc stack...
> 
Yes, you are right, we only need the free_track of kasan_alloc_meta. We
will change it.


> > +};
> > +struct qlist_node {
> > +       struct qlist_object *qobject;
> > +       struct qlist_node *next;
> > +};
> > +#endif
> >  struct kasan_free_meta {
> >         /* This field is used while the object is in the quarantine.
> >          * Otherwise it might be used for the allocator freelist.
> > @@ -133,16 +145,19 @@ void kasan_report(unsigned long addr, size_t size,
> >                 bool is_write, unsigned long ip);
> >  void kasan_report_invalid_free(void *object, unsigned long ip);
> >
> > -#if defined(CONFIG_KASAN_GENERIC) && \
> > +#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS) && \
> 
> This condition seems to be always true, no?
> 
Yes, it is always true, it should be removed.


> >         (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
> > +
> >  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
> >  void quarantine_reduce(void);
> >  void quarantine_remove_cache(struct kmem_cache *cache);
> > +void set_track(struct kasan_track *track, gfp_t flags);
> >  #else
> >  static inline void quarantine_put(struct kasan_free_meta *info,
> >                                 struct kmem_cache *cache) { }
> >  static inline void quarantine_reduce(void) { }
> >  static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
> > +static inline void set_track(struct kasan_track *track, gfp_t flags) {}
> >  #endif
> >
> >  #ifdef CONFIG_KASAN_SW_TAGS
> > @@ -151,6 +166,15 @@ void print_tags(u8 addr_tag, const void *addr);
> >
> >  u8 random_tag(void);
> >
> > +bool quarantine_find_object(void *object);
> > +
> > +int qobject_add_size(void);
> 
> Would be more reasonable to use size_t type for object sizes.
> 
the sum of qobect and qnode size?


> > +
> > +struct qlist_node *qobject_create(struct kasan_free_meta *info,
> > +               struct kmem_cache *cache);
> > +
> > +void qobject_free(struct qlist_node *qlink, struct kmem_cache *cache);
> > +
> >  #else
> >
> >  static inline void print_tags(u8 addr_tag, const void *addr) { }
> > @@ -160,6 +184,25 @@ static inline u8 random_tag(void)
> >         return 0;
> >  }
> >
> > +static inline bool quarantine_find_object(void *object)
> > +{
> > +       return 0;
> 
> s/0/false/
> 
Thanks for your friendly reminder. we will change it.


> > +}
> > +
> > +static inline int qobject_add_size(void)
> > +{
> > +       return 0;
> > +}
> > +
> > +static inline struct qlist_node *qobject_create(struct kasan_free_meta *info,
> > +               struct kmem_cache *cache)
> > +{
> > +       return 0;
> 
> s/0/NULL/
> 
Thanks for your friendly reminder. we will change it.


> > +}
> > +
> > +static inline void qobject_free(struct qlist_node *qlink,
> > +               struct kmem_cache *cache) {}
> > +
> >  #endif
> >
> >  #ifndef arch_kasan_set_tag
> > diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> > index 978bc4a3eb51..f14c8dbec552 100644
> > --- a/mm/kasan/quarantine.c
> > +++ b/mm/kasan/quarantine.c
> > @@ -67,7 +67,10 @@ static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
> >                 q->tail->next = qlink;
> >         q->tail = qlink;
> >         qlink->next = NULL;
> > -       q->bytes += size;
> > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
> 
> It would be more reasonable to pass the right size from the caller. It
> already have to have the branch on CONFIG_KASAN_SW_TAGS because it
> needs to allocate qobject or not, that would be the right place to
> pass the right size.
> 
In tag-based KASAN, we will pass the sum of qobject and qnode size to it
and review qlist_put() caller whether it pass right size.


> > +               q->bytes += qobject_add_size();
> > +       else
> > +               q->bytes += size;
> >  }
> >
> >  static void qlist_move_all(struct qlist_head *from, struct qlist_head *to)
> > @@ -139,13 +142,18 @@ static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
> >
> >  static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
> >  {
> > -       void *object = qlink_to_object(qlink, cache);
> >         unsigned long flags;
> > +       struct kmem_cache *obj_cache =
> > +                       cache ? cache : qlink_to_cache(qlink);
> > +       void *object = qlink_to_object(qlink, obj_cache);
> > +
> > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
> > +               qobject_free(qlink, cache);
> >
> >         if (IS_ENABLED(CONFIG_SLAB))
> >                 local_irq_save(flags);
> >
> > -       ___cache_free(cache, object, _THIS_IP_);
> > +       ___cache_free(obj_cache, object, _THIS_IP_);
> >
> >         if (IS_ENABLED(CONFIG_SLAB))
> >                 local_irq_restore(flags);
> > @@ -160,11 +168,9 @@ static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
> >
> >         qlink = q->head;
> >         while (qlink) {
> > -               struct kmem_cache *obj_cache =
> > -                       cache ? cache : qlink_to_cache(qlink);
> >                 struct qlist_node *next = qlink->next;
> >
> > -               qlink_free(qlink, obj_cache);
> > +               qlink_free(qlink, cache);
> >                 qlink = next;
> >         }
> >         qlist_init(q);
> > @@ -187,7 +193,18 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
> >         local_irq_save(flags);
> >
> >         q = this_cpu_ptr(&cpu_quarantine);
> > -       qlist_put(q, &info->quarantine_link, cache->size);
> > +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS)) {
> > +               struct qlist_node *free_obj_info = qobject_create(info, cache);
> > +
> > +               if (!free_obj_info) {
> > +                       local_irq_restore(flags);
> > +                       return;
> > +               }
> > +               qlist_put(q, free_obj_info, cache->size);
> > +       } else {
> > +               qlist_put(q, &info->quarantine_link, cache->size);
> > +       }
> > +
> >         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
> >                 qlist_move_all(q, &temp);
> >
> > @@ -327,3 +344,79 @@ void quarantine_remove_cache(struct kmem_cache *cache)
> >
> >         synchronize_srcu(&remove_cache_srcu);
> >  }
> > +
> > +#ifdef CONFIG_KASAN_SW_TAGS
> > +static struct kasan_alloc_meta object_free_track;
> 
> This global is a dirty solution. It's better passed as argument to the
> required functions rather than functions leave part of state in a
> global and somebody picks it up later.
> 
Thanks your suggestion, we will change the implementation here.


> > +
> > +struct kasan_alloc_meta *get_object_track(void)
> > +{
> > +       return &object_free_track;
> > +}
> > +
> > +static bool qlist_find_object(struct qlist_head *from, void *addr)
> > +{
> > +       struct qlist_node *curr;
> > +       struct qlist_object *curr_obj;
> > +
> > +       if (unlikely(qlist_empty(from)))
> > +               return false;
> > +
> > +       curr = from->head;
> > +       while (curr) {
> > +               struct qlist_node *next = curr->next;
> > +
> > +               curr_obj = curr->qobject;
> > +               if (unlikely(((unsigned long)addr >= curr_obj->addr)
> > +                       && ((unsigned long)addr <
> > +                                       (curr_obj->addr + curr_obj->size)))) {
> > +                       object_free_track = curr_obj->free_track;
> > +
> > +                       return true;
> > +               }
> > +
> > +               curr = next;
> > +       }
> > +       return false;
> > +}
> > +
> > +static int per_cpu_find_object(void *arg)
> > +{
> > +       void *addr = arg;
> > +       struct qlist_head *q;
> > +
> > +       q = this_cpu_ptr(&cpu_quarantine);
> > +       return qlist_find_object(q, addr);
> > +}
> > +
> > +struct cpumask cpu_allowed_mask __read_mostly;
> > +
> > +bool quarantine_find_object(void *addr)
> > +{
> > +       unsigned long flags, i;
> > +       bool find = false;
> > +       int cpu;
> > +
> > +       cpumask_copy(&cpu_allowed_mask, cpu_online_mask);
> > +       for_each_cpu(cpu, &cpu_allowed_mask) {
> > +               find = smp_call_on_cpu(cpu, per_cpu_find_object, addr, true);
> 
> There can be multiple qobjects in the quarantine associated with the
> address, right? If so, we need to find the last one rather then a
> random one.
> 
The qobject includes the address which has tag and range, corruption
address must be satisfied with the same tag and within object address
range, then it is found in the quarantine.
It should not easy to get multiple qobjects have the same tag and within
object address range.


> > +               if (find)
> > +                       return true;
> > +       }
> > +
> > +       raw_spin_lock_irqsave(&quarantine_lock, flags);
> > +       for (i = 0; i < QUARANTINE_BATCHES; i++) {
> > +               if (qlist_empty(&global_quarantine[i]))
> > +                       continue;
> > +               find = qlist_find_object(&global_quarantine[i], addr);
> > +               /* Scanning whole quarantine can take a while. */
> > +               raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> > +               cond_resched();
> > +               raw_spin_lock_irqsave(&quarantine_lock, flags);
> > +       }
> > +       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> > +
> > +       synchronize_srcu(&remove_cache_srcu);
> > +
> > +       return find;
> > +}
> > +#endif
> > diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> > index ca9418fe9232..9cfabf2f0c40 100644
> > --- a/mm/kasan/report.c
> > +++ b/mm/kasan/report.c
> > @@ -150,18 +150,26 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
> >  }
> >
> >  static void describe_object(struct kmem_cache *cache, void *object,
> > -                               const void *addr)
> > +                               const void *tagged_addr)
> >  {
> > +       void *untagged_addr = reset_tag(tagged_addr);
> >         struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
> >
> >         if (cache->flags & SLAB_KASAN) {
> > -               print_track(&alloc_info->alloc_track, "Allocated");
> > -               pr_err("\n");
> > -               print_track(&alloc_info->free_track, "Freed");
> > -               pr_err("\n");
> > +               if (IS_ENABLED(CONFIG_KASAN_SW_TAGS) &&
> > +                       quarantine_find_object((void *)tagged_addr)) {
> 
> Can't this be an out-of-bound even if we find the object in quarantine?
> For example, if we've freed an object, then reallocated and accessed
> out-of-bounds within the object bounds?
> Overall suggesting that this is a use-after-free rather than
> out-of-bounds without redzones and quarantining the object itself is
> quite imprecise. We can confuse a user even more...
> 
the qobject stores object range and address which has tag, even if
the object reallocate and accessed out-of-bounds, then new object and
old object in quarantine should be different tag value, so it should be
no found in quarantine.


> 
> > +                       alloc_info = get_object_track();
> > +                       print_track(&alloc_info->free_track, "Freed");
> > +                       pr_err("\n");
> > +               } else {
> > +                       print_track(&alloc_info->alloc_track, "Allocated");
> > +                       pr_err("\n");
> > +                       print_track(&alloc_info->free_track, "Freed");
> > +                       pr_err("\n");
> > +               }
> >         }
> >
> > -       describe_object_addr(cache, object, addr);
> > +       describe_object_addr(cache, object, untagged_addr);
> >  }
> >
> >  static inline bool kernel_or_module_addr(const void *addr)
> > @@ -180,23 +188,25 @@ static inline bool init_task_stack_addr(const void *addr)
> >                         sizeof(init_thread_union.stack));
> >  }
> >
> > -static void print_address_description(void *addr)
> > +static void print_address_description(void *tagged_addr)
> >  {
> > -       struct page *page = addr_to_page(addr);
> > +       void *untagged_addr = reset_tag(tagged_addr);
> > +       struct page *page = addr_to_page(untagged_addr);
> >
> >         dump_stack();
> >         pr_err("\n");
> >
> >         if (page && PageSlab(page)) {
> >                 struct kmem_cache *cache = page->slab_cache;
> > -               void *object = nearest_obj(cache, page, addr);
> > +               void *object = nearest_obj(cache, page, untagged_addr);
> >
> > -               describe_object(cache, object, addr);
> > +               describe_object(cache, object, tagged_addr);
> >         }
> >
> > -       if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
> > +       if (kernel_or_module_addr(untagged_addr) &&
> > +                       !init_task_stack_addr(untagged_addr)) {
> >                 pr_err("The buggy address belongs to the variable:\n");
> > -               pr_err(" %pS\n", addr);
> > +               pr_err(" %pS\n", untagged_addr);
> >         }
> >
> >         if (page) {
> > @@ -314,7 +324,7 @@ void kasan_report(unsigned long addr, size_t size,
> >         pr_err("\n");
> >
> >         if (addr_has_shadow(untagged_addr)) {
> > -               print_address_description(untagged_addr);
> > +               print_address_description(tagged_addr);
> >                 pr_err("\n");
> >                 print_shadow_for_address(info.first_bad_addr);
> >         } else {
> > diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
> > index 63fca3172659..fa5d1e29003d 100644
> > --- a/mm/kasan/tags.c
> > +++ b/mm/kasan/tags.c
> > @@ -124,6 +124,70 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
> >         }
> >  }
> >
> > +int qobject_add_size(void)
> > +{
> > +       return sizeof(struct qlist_object);
> 
> Shouldn't this also account for qlist_node?
> 
yes, we will count it.


> > +}
> > +
> > +static struct kmem_cache *qobject_to_cache(struct qlist_object *qobject)
> > +{
> > +       return virt_to_head_page(qobject)->slab_cache;
> > +}
> > +
> > +struct qlist_node *qobject_create(struct kasan_free_meta *info,
> > +                                               struct kmem_cache *cache)
> > +{
> > +       struct qlist_node *free_obj_info;
> > +       struct qlist_object *qobject_info;
> > +       struct kasan_alloc_meta *object_track;
> > +       void *object;
> > +
> > +       object = ((void *)info) - cache->kasan_info.free_meta_offset;
> > +       qobject_info = kmalloc(sizeof(struct qlist_object), GFP_NOWAIT);
> > +       if (!qobject_info)
> > +               return NULL;
> > +       qobject_info->addr = (unsigned long) object;
> > +       qobject_info->size = cache->object_size;
> > +       object_track = &qobject_info->free_track;
> > +       set_track(&object_track->free_track, GFP_NOWAIT);
> > +
> > +       free_obj_info = kmalloc(sizeof(struct qlist_node), GFP_NOWAIT);
> 
> Why don't we allocate qlist_object and qlist_node in a single
> allocation? Doing 2 allocations is both unnecessary slow and leads to
> more complex code. We need to allocate them with a single allocations.
> Also I think they should be allocated from a dedicated cache that opts
> out of quarantine?
> 
Single allocation is good suggestion, if we only has one allocation.
then we need to move all member of qlist_object to qlist_node?

struct qlist_object {
    unsigned long addr;
    unsigned int size;
    struct kasan_alloc_meta free_track;
};
struct qlist_node {
    struct qlist_object *qobject;
    struct qlist_node *next;
};


We call call ___cache_free() to free the qobject and qnode, it should be
out of quarantine?


Thanks,
Walter

