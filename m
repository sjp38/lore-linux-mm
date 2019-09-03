Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 202B4C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD60222CF8
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:54:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ikgeVUo3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD60222CF8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71F106B0008; Tue,  3 Sep 2019 11:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9456B000A; Tue,  3 Sep 2019 11:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BCFD6B000C; Tue,  3 Sep 2019 11:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 384106B0008
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 11:54:15 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D643A180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:54:14 +0000 (UTC)
X-FDA: 75894056028.18.toe85_7e3c35617036
X-HE-Tag: toe85_7e3c35617036
X-Filterd-Recvd-Size: 14318
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:54:14 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id 205so8592084pfw.2
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 08:54:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i2XyPuhqSIg3qjxxxx2GWzZfZ8oeUSUoF9dv9bk32A8=;
        b=ikgeVUo3RrOK3p8qkS74u5IaK4o+m9UvtD1MCkPLALzektUPGg2DoxfimNP3MU2dQc
         xtYACvlcm5WzAsYrikdr8PIStPrii2IPda+4zN2eYBo2zHbuqFPkV1A18gwFXPlHaXct
         1C5fHSyOHJGnQPGItkad/m+EDsuddkKO0ofOmTez2pMIkk15IaNVQ4ZJeE0Z/s9gKUBd
         mA/nXQbfsKNa/ukBSeF7132T4N8r9eh4EvGodB6+v6mYKMdZ+YAK/87406/9e3Iz2OyR
         UwjNDmQEwLO7zqYGaaPQ/FvLRBLRiAQ+cpvmnoo14h5ExGof7/9E1Sn1HsruNxWfK1hr
         xIfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=i2XyPuhqSIg3qjxxxx2GWzZfZ8oeUSUoF9dv9bk32A8=;
        b=o7B60doC3vmiTaXHYZNEDEK91+IyZUSDA4YbvSlkUPKIxSMZtGp5+6hfQLZDAsAFG5
         bkcuTyXMcGygdmqNqtf5IMOouHMRcyHTajPSrExrSg9gwLJ25E/Jl0c32uwdPvw0zhL1
         GZENTazSkwwajBl/4kfztq64sQ7sSM08pEd5hdkLp7hVJHrcmajU7QkUGKFqaxAvjaUl
         BJWL4NEtt2YtW3Ps3jkcPJ+HmwQMGwF2VZcxoNokblgfTEpm6VYSE3KjaTI+7qoL+hlS
         d2W5DdnmEwWLmvqvogIIbmt5lHSunWLuhBSH3tETdBbuFMnO4WY/9G9wmeyXz85mwgOH
         qN/w==
X-Gm-Message-State: APjAAAV6ul32qvb2+HfE3CqFrnglrE5srFvAfCmcw1qU/Pr0ieRsZt5A
	qA9cie0yKlg+h7spw6Myr+Qv2us1yW7CguXQDNREWg==
X-Google-Smtp-Source: APXvYqxtJbF+JbbtGN2V7q/8Vhhvdt0ecfct5yOlV8VfpvE1Q4X11qbLbtOU9VXEaA1+yBMTOf/jFKHGk7VUlZPfX/Y=
X-Received: by 2002:a62:db84:: with SMTP id f126mr15457590pfg.25.1567526052507;
 Tue, 03 Sep 2019 08:54:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190821180332.11450-1-aryabinin@virtuozzo.com>
In-Reply-To: <20190821180332.11450-1-aryabinin@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 3 Sep 2019 17:54:01 +0200
Message-ID: <CAAeHK+xO-gcep1DbuJKqZy4j=aQKukvvJZ=OQYivqCmwXB5dqA@mail.gmail.com>
Subject: Re: [PATCH v5] kasan: add memory corruption identification for
 software tag-based mode
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Walter Wu <walter-zh.wu@mediatek.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 8:03 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
> From: Walter Wu <walter-zh.wu@mediatek.com>
>
> This patch adds memory corruption identification at bug report for
> software tag-based mode, the report show whether it is "use-after-free"
> or "out-of-bound" error instead of "invalid-access" error. This will make
> it easier for programmers to see the memory corruption problem.
>
> We extend the slab to store five old free pointer tag and free backtrace,
> we can check if the tagged address is in the slab record and make a
> good guess if the object is more like "use-after-free" or "out-of-bound".
> therefore every slab memory corruption can be identified whether it's
> "use-after-free" or "out-of-bound".
>
> [aryabinin@virtuozzo.com: simplify & clenup code:
>   https://lkml.kernel.org/r/3318f9d7-a760-3cc8-b700-f06108ae745f@virtuozzo.com]
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> ---
>
> ====== Changes
> Change since v1:
> - add feature option CONFIG_KASAN_SW_TAGS_IDENTIFY.
> - change QUARANTINE_FRACTION to reduce quarantine size.
> - change the qlist order in order to find the newest object in quarantine
> - reduce the number of calling kmalloc() from 2 to 1 time.
> - remove global variable to use argument to pass it.
> - correct the amount of qobject cache->size into the byes of qlist_head.
> - only use kasan_cache_shrink() to shink memory.
>
> Change since v2:
> - remove the shinking memory function kasan_cache_shrink()
> - modify the description of the CONFIG_KASAN_SW_TAGS_IDENTIFY
> - optimize the quarantine_find_object() and qobject_free()
> - fix the duplicating function name 3 times in the header.
> - modify the function name set_track() to kasan_set_track()
>
> Change since v3:
> - change tag-based quarantine to extend slab to identify memory corruption
>
> Changes since v4:
>  - Simplify and cleanup code.
>
>  lib/Kconfig.kasan      |  8 ++++++++
>  mm/kasan/common.c      | 22 +++++++++++++++++++--
>  mm/kasan/kasan.h       | 14 +++++++++++++-
>  mm/kasan/report.c      | 44 ++++++++++++++++++++++++++++++++----------
>  mm/kasan/tags_report.c | 24 +++++++++++++++++++++++
>  5 files changed, 99 insertions(+), 13 deletions(-)
>
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 7fa97a8b5717..6c9682ce0254 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -134,6 +134,14 @@ config KASAN_S390_4_LEVEL_PAGING
>           to 3TB of RAM with KASan enabled). This options allows to force
>           4-level paging instead.
>
> +config KASAN_SW_TAGS_IDENTIFY
> +       bool "Enable memory corruption identification"
> +       depends on KASAN_SW_TAGS
> +       help
> +         This option enables best-effort identification of bug type
> +         (use-after-free or out-of-bounds) at the cost of increased
> +         memory consumption.
> +
>  config TEST_KASAN
>         tristate "Module for testing KASAN for bug detection"
>         depends on m && KASAN
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 3b8cde0cb5b2..6814d6d6a023 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -304,7 +304,6 @@ size_t kasan_metadata_size(struct kmem_cache *cache)
>  struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>                                         const void *object)
>  {
> -       BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
>         return (void *)object + cache->kasan_info.alloc_meta_offset;
>  }
>
> @@ -315,6 +314,24 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>         return (void *)object + cache->kasan_info.free_meta_offset;
>  }
>
> +
> +static void kasan_set_free_info(struct kmem_cache *cache,
> +               void *object, u8 tag)
> +{
> +       struct kasan_alloc_meta *alloc_meta;
> +       u8 idx = 0;
> +
> +       alloc_meta = get_alloc_info(cache, object);
> +
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +       idx = alloc_meta->free_track_idx;
> +       alloc_meta->free_pointer_tag[idx] = tag;
> +       alloc_meta->free_track_idx = (idx + 1) % KASAN_NR_FREE_STACKS;
> +#endif
> +
> +       set_track(&alloc_meta->free_track[idx], GFP_NOWAIT);
> +}
> +
>  void kasan_poison_slab(struct page *page)
>  {
>         unsigned long i;
> @@ -451,7 +468,8 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>                         unlikely(!(cache->flags & SLAB_KASAN)))
>                 return false;
>
> -       set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
> +       kasan_set_free_info(cache, object, tag);
> +
>         quarantine_put(get_free_info(cache, object), cache);
>
>         return IS_ENABLED(CONFIG_KASAN_GENERIC);
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 014f19e76247..35cff6bbb716 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -95,9 +95,19 @@ struct kasan_track {
>         depot_stack_handle_t stack;
>  };
>
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +#define KASAN_NR_FREE_STACKS 5
> +#else
> +#define KASAN_NR_FREE_STACKS 1
> +#endif
> +
>  struct kasan_alloc_meta {
>         struct kasan_track alloc_track;
> -       struct kasan_track free_track;
> +       struct kasan_track free_track[KASAN_NR_FREE_STACKS];
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +       u8 free_pointer_tag[KASAN_NR_FREE_STACKS];
> +       u8 free_track_idx;
> +#endif
>  };
>
>  struct qlist_node {
> @@ -146,6 +156,8 @@ void kasan_report(unsigned long addr, size_t size,
>                 bool is_write, unsigned long ip);
>  void kasan_report_invalid_free(void *object, unsigned long ip);
>
> +struct page *kasan_addr_to_page(const void *addr);
> +
>  #if defined(CONFIG_KASAN_GENERIC) && \
>         (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 0e5f965f1882..621782100eaa 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -111,7 +111,7 @@ static void print_track(struct kasan_track *track, const char *prefix)
>         }
>  }
>
> -static struct page *addr_to_page(const void *addr)
> +struct page *kasan_addr_to_page(const void *addr)
>  {
>         if ((addr >= (void *)PAGE_OFFSET) &&
>                         (addr < high_memory))
> @@ -151,15 +151,38 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
>                 (void *)(object_addr + cache->object_size));
>  }
>
> +static struct kasan_track *kasan_get_free_track(struct kmem_cache *cache,
> +               void *object, u8 tag)
> +{
> +       struct kasan_alloc_meta *alloc_meta;
> +       int i = 0;
> +
> +       alloc_meta = get_alloc_info(cache, object);
> +
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +       for (i = 0; i < KASAN_NR_FREE_STACKS; i++) {
> +               if (alloc_meta->free_pointer_tag[i] == tag)
> +                       break;
> +       }
> +       if (i == KASAN_NR_FREE_STACKS)
> +               i = alloc_meta->free_track_idx;
> +#endif
> +
> +       return &alloc_meta->free_track[i];
> +}
> +
>  static void describe_object(struct kmem_cache *cache, void *object,
> -                               const void *addr)
> +                               const void *addr, u8 tag)
>  {
>         struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
>
>         if (cache->flags & SLAB_KASAN) {
> +               struct kasan_track *free_track;
> +
>                 print_track(&alloc_info->alloc_track, "Allocated");
>                 pr_err("\n");
> -               print_track(&alloc_info->free_track, "Freed");
> +               free_track = kasan_get_free_track(cache, object, tag);
> +               print_track(free_track, "Freed");
>                 pr_err("\n");
>         }
>
> @@ -344,9 +367,9 @@ static void print_address_stack_frame(const void *addr)
>         print_decoded_frame_descr(frame_descr);
>  }
>
> -static void print_address_description(void *addr)
> +static void print_address_description(void *addr, u8 tag)
>  {
> -       struct page *page = addr_to_page(addr);
> +       struct page *page = kasan_addr_to_page(addr);
>
>         dump_stack();
>         pr_err("\n");
> @@ -355,7 +378,7 @@ static void print_address_description(void *addr)
>                 struct kmem_cache *cache = page->slab_cache;
>                 void *object = nearest_obj(cache, page, addr);
>
> -               describe_object(cache, object, addr);
> +               describe_object(cache, object, addr, tag);
>         }
>
>         if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
> @@ -435,13 +458,14 @@ static bool report_enabled(void)
>  void kasan_report_invalid_free(void *object, unsigned long ip)
>  {
>         unsigned long flags;
> +       u8 tag = get_tag(object);
>
> +       object = reset_tag(object);
>         start_report(&flags);
>         pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
> -       print_tags(get_tag(object), reset_tag(object));
> -       object = reset_tag(object);
> +       print_tags(tag, object);
>         pr_err("\n");
> -       print_address_description(object);
> +       print_address_description(object, tag);
>         pr_err("\n");
>         print_shadow_for_address(object);
>         end_report(&flags);
> @@ -479,7 +503,7 @@ void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned lon
>         pr_err("\n");
>
>         if (addr_has_shadow(untagged_addr)) {
> -               print_address_description(untagged_addr);
> +               print_address_description(untagged_addr, get_tag(tagged_addr));
>                 pr_err("\n");
>                 print_shadow_for_address(info.first_bad_addr);
>         } else {
> diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
> index 8eaf5f722271..969ae08f59d7 100644
> --- a/mm/kasan/tags_report.c
> +++ b/mm/kasan/tags_report.c
> @@ -36,6 +36,30 @@
>
>  const char *get_bug_type(struct kasan_access_info *info)
>  {
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +       struct kasan_alloc_meta *alloc_meta;
> +       struct kmem_cache *cache;
> +       struct page *page;
> +       const void *addr;
> +       void *object;
> +       u8 tag;
> +       int i;
> +
> +       tag = get_tag(info->access_addr);
> +       addr = reset_tag(info->access_addr);
> +       page = kasan_addr_to_page(addr);
> +       if (page && PageSlab(page)) {
> +               cache = page->slab_cache;
> +               object = nearest_obj(cache, page, (void *)addr);
> +               alloc_meta = get_alloc_info(cache, object);
> +
> +               for (i = 0; i < KASAN_NR_FREE_STACKS; i++)
> +                       if (alloc_meta->free_pointer_tag[i] == tag)
> +                               return "use-after-free";
> +               return "out-of-bounds";

I think we should keep the "invalid-access" bug type here if we failed
to identify the bug as a "use-after-free" (and change the patch
description accordingly).

Other than that:

Acked-by: Andrey Konovalov <andreyknvl@google.com>

> +       }
> +
> +#endif
>         return "invalid-access";
>  }
>
> --
> 2.21.0
>

