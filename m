Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FBBEC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:18:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E117A212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 13:18:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fFQZdcxf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E117A212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65BFC6B000C; Fri,  7 Jun 2019 09:18:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60D146B000E; Fri,  7 Jun 2019 09:18:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D42F6B0266; Fri,  7 Jun 2019 09:18:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 260786B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 09:18:54 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so1277929ioj.3
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 06:18:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3RwN85TIST9Pu6olIcDwmmCao8JJAImV1IlPOw2oE0c=;
        b=RC3AGDicBth6qCHcunNTHAusrGbyUsoOiKv/Nn4H7Zc8qU6RPym++C7rE3S69tCYmD
         /D0MvhvgMw1dMkX4t5SKto6j321QEt8anDi+nLrOSo1qamzOCSBST6TBJC3958fseK++
         mt5VpZA399ksJrxxBcOKXMahaeSyUoAFCD8V1xsR8KJ+xHw0R4JmQoeittB6PnS5KfQF
         rFID0wMu4QwZEPsJABlX65GzTSBaxMCvD8ph9Tb0rj2mq5dkTT13n4waZTN63S5/Xrkr
         AFIvAZM/jp+g/saSzRqcNcxr0fJG4iXnrZWVPBZvWr96xckq+Zt7d3W4WruhOCt/lX6W
         BbaQ==
X-Gm-Message-State: APjAAAVVhy+gaYp43w7111ZnQGOu6WwlBqxO+EcXxJAiAYJwzhwEktLM
	xUROQ+J00r9hyGP3h9lSGJ1VLTHQwXsXDA53hMo64rJ66rw+5Vw4XjRw4fT345jcgnR9e7QuCjt
	5KvwdE2LlUjYC4ile9YPh7spZ7XvWnupaM7Chfa29oxtqqvkP78jPUlBOHtiRtUxzlw==
X-Received: by 2002:a24:a43:: with SMTP id 64mr4256028itw.100.1559913533809;
        Fri, 07 Jun 2019 06:18:53 -0700 (PDT)
X-Received: by 2002:a24:a43:: with SMTP id 64mr4255896itw.100.1559913531698;
        Fri, 07 Jun 2019 06:18:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559913531; cv=none;
        d=google.com; s=arc-20160816;
        b=G9LO15o5hdPYWMOtgysaRZ/+SCXUkM4p3KsjUNQj1+GsSwnB/hxDnDpEwqGjnz2MaQ
         Fuv0c2/brdR5UQT+eP4fqA5eCxyl8ZfC8/MY7w6XG8j4xVqxaufldIEdktuZXKRBSbAh
         NuTNn+goH6fGqlcNNYG51361bxuY+Bc29WdOggCYoEDXw2UGPvnNG0OJGJybVfSZLavB
         4FcSxuVm6VrXH65BKuBnGqdokeeWJII/p8sAPX9hA0x+jKQHIxanJJ6t1pgmLt4KCKGY
         0WK8tZ9KTi6GSadsrtQqSOMyijctXy3KbZ5ucTKoFohh47w1iStlOivhnfmeparbU8+Y
         MHSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3RwN85TIST9Pu6olIcDwmmCao8JJAImV1IlPOw2oE0c=;
        b=oS9RKm06t7JuV8IHVBz4RejOTI2E7MRkddC/1B+mOfqR4O1F9ta+wm8CuzMPj7ip6I
         xZ7GdJDhEZPezWBPXo2ZSE1GsUP0kZSXRB86g0u4N1uhnXcKpgrLkIa2W4/74K+CymAr
         DvgWOBLHtAKkOuHyttmZm3s0mmy4JuAwS6i52WRNLy3iQF0dzXI/iLEpL2CjtExfWoYd
         DFNfLPGjNEOeb2vP4sVVSRsTalhKhDHGWCz4dDboI+h1MeznxwrumHS9W47OKvXrnrIY
         RvZEut0uoX4qCk3FF3mUYZToAKAZnWLNvN5sC4mSUEAP1eLWaRm7SlDxnJ7o1RWBwuct
         fuIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fFQZdcxf;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t73sor16276735itb.1.2019.06.07.06.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 06:18:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fFQZdcxf;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3RwN85TIST9Pu6olIcDwmmCao8JJAImV1IlPOw2oE0c=;
        b=fFQZdcxf8rkIhKTJTsVsowJnoqiOilJtvlVg4id2bpDtVr7VVvdpZLyN1keENvAkcF
         QkTR/nfj7yzHwlg88FFk2g4dxX8z5OcTWwHi/PkBIaTqJsi4Ep9WiOJ9MGE57QGlBvS7
         dc4Gm/rdrExsp38gf6LJorrlpuvuYdmbaDuF6n/HKUkAhfNcBZvGgtm75wq8D/orS+sp
         S//dpHReUOqZQwB4aGoNSZ8CwEhKNbLvbLDDoxouLDBUlAct63wofpqivMXpqnD5F36W
         k1OM7lTGXevl7CjDViGCBKQwUkCT90IA4E7qtXbhojqp2I+uuqO/VzdGuDk4Pblna1am
         G3rg==
X-Google-Smtp-Source: APXvYqzNTE+3pqFQDvswMzvtEyH0ZI6HdnsPnim91anWvOZAggizv9+LzbfRjRWtj8nCnFJbVC/FiZd0byouvSDJRxk=
X-Received: by 2002:a02:22c6:: with SMTP id o189mr22322508jao.35.1559913530765;
 Fri, 07 Jun 2019 06:18:50 -0700 (PDT)
MIME-Version: 1.0
References: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
In-Reply-To: <1559651172-28989-1-git-send-email-walter-zh.wu@mediatek.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 7 Jun 2019 15:18:39 +0200
Message-ID: <CACT4Y+Y9_85YB8CCwmKerDWc45Z00hMd6Pc-STEbr0cmYSqnoA@mail.gmail.com>
Subject: Re: [PATCH v2] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, 
	Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	"Jason A. Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 2:26 PM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>
> This patch adds memory corruption identification at bug report for
> software tag-based mode, the report show whether it is "use-after-free"
> or "out-of-bound" error instead of "invalid-access" error.This will make
> it easier for programmers to see the memory corruption problem.
>
> Now we extend the quarantine to support both generic and tag-based kasan.
> For tag-based kasan, the quarantine stores only freed object information
> to check if an object is freed recently. When tag-based kasan reports an
> error, we can check if the tagged addr is in the quarantine and make a
> good guess if the object is more like "use-after-free" or "out-of-bound".
>
> Due to tag-based kasan, the tag values are stored in the shadow memory,
> all tag comparison failures are memory corruption. Even if those freed
> object have been deallocated, we still can get the memory corruption.
> So the freed object doesn't need to be kept in quarantine, it can be
> immediately released after calling kfree(). We only need the freed object
> information in quarantine, the error handler is able to use object
> information to know if it has been allocated or deallocated, therefore
> every slab memory corruption can be identified whether it's
> "use-after-free" or "out-of-bound".
>
> The difference between generic kasan and tag-based kasan quarantine is
> slab memory usage. Tag-based kasan only stores freed object information
> rather than the object itself. So tag-based kasan quarantine memory usage
> is smaller than generic kasan.
>
>
> ====== Benchmarks
>
> The following numbers were collected in QEMU.
> Both generic and tag-based KASAN were used in inline instrumentation mode
> and no stack checking.
>
> Boot time :
> * ~1.5 sec for clean kernel
> * ~3 sec for generic KASAN
> * ~3.5  sec for tag-based KASAN
> * ~3.5 sec for tag-based KASAN + corruption identification
>
> Slab memory usage after boot :
> * ~10500 kb  for clean kernel
> * ~30500 kb  for generic KASAN
> * ~12300 kb  for tag-based KASAN
> * ~17100 kb  for tag-based KASAN + corruption identification
>
> ====== Changes
>
> Change since v1:
> - add feature option CONFIG_KASAN_SW_TAGS_IDENTIFY.
> - change QUARANTINE_FRACTION to reduce quarantine size.
> - change the qlist order in order to find the newest object in quarantine
> - reduce the number of calling kmalloc() from 2 to 1 time.
> - remove global variable to use argument to pass it.
> - correct the amount of qobject cache->size into the byes of qlist_head.
> - only use kasan_cache_shrink() to shink memory.
>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
> ---
>  include/linux/kasan.h  |   4 ++
>  lib/Kconfig.kasan      |   9 +++
>  mm/kasan/Makefile      |   1 +
>  mm/kasan/common.c      |   4 +-
>  mm/kasan/kasan.h       |  50 +++++++++++++-
>  mm/kasan/quarantine.c  | 146 ++++++++++++++++++++++++++++++++++++-----
>  mm/kasan/report.c      |  37 +++++++----
>  mm/kasan/tags.c        |  47 +++++++++++++
>  mm/kasan/tags_report.c |   8 ++-
>  mm/slub.c              |   2 +-
>  10 files changed, 273 insertions(+), 35 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index b40ea104dd36..be0667225b58 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -164,7 +164,11 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
>
>  #else /* CONFIG_KASAN_GENERIC */
>
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +void kasan_cache_shrink(struct kmem_cache *cache);
> +#else

Please restructure the code so that we don't duplicate this function
name 3 times in this header.

>  static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
> +#endif
>  static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
>
>  #endif /* CONFIG_KASAN_GENERIC */
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index 9950b660e62d..17a4952c5eee 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -134,6 +134,15 @@ config KASAN_S390_4_LEVEL_PAGING
>           to 3TB of RAM with KASan enabled). This options allows to force
>           4-level paging instead.
>
> +config KASAN_SW_TAGS_IDENTIFY
> +       bool "Enable memory corruption idenitfication"

s/idenitfication/identification/

> +       depends on KASAN_SW_TAGS
> +       help
> +         Now tag-based KASAN bug report always shows invalid-access error, This
> +         options can identify it whether it is use-after-free or out-of-bound.
> +         This will make it easier for programmers to see the memory corruption
> +         problem.

This description looks like a change description, i.e. it describes
the current behavior and how it changes. I think code comments should
not have such, they should describe the current state of the things.
It should also mention the trade-off, otherwise it raises reasonable
questions like "why it's not enabled by default?" and "why do I ever
want to not enable it?".
I would do something like:

This option enables best-effort identification of bug type
(use-after-free or out-of-bounds)
at the cost of increased memory consumption for object quarantine.




> +
>  config TEST_KASAN
>         tristate "Module for testing KASAN for bug detection"
>         depends on m && KASAN
> diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
> index 5d1065efbd47..d8540e5070cb 100644
> --- a/mm/kasan/Makefile
> +++ b/mm/kasan/Makefile
> @@ -19,3 +19,4 @@ CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
>  obj-$(CONFIG_KASAN) := common.o init.o report.o
>  obj-$(CONFIG_KASAN_GENERIC) += generic.o generic_report.o quarantine.o
>  obj-$(CONFIG_KASAN_SW_TAGS) += tags.o tags_report.o
> +obj-$(CONFIG_KASAN_SW_TAGS_IDENTIFY) += quarantine.o
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 80bbe62b16cd..e309fbbee831 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -81,7 +81,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
>         return depot_save_stack(&trace, flags);
>  }
>
> -static inline void set_track(struct kasan_track *track, gfp_t flags)
> +void set_track(struct kasan_track *track, gfp_t flags)

If you make it non-static, it should get kasan_ prefix. The name is too generic.


>  {
>         track->pid = current->pid;
>         track->stack = save_stack(flags);
> @@ -457,7 +457,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>                 return false;
>
>         set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
> -       quarantine_put(get_free_info(cache, object), cache);
> +       quarantine_put(get_free_info(cache, tagged_object), cache);
>
>         return IS_ENABLED(CONFIG_KASAN_GENERIC);
>  }
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 3e0c11f7d7a1..1be04abe2e0d 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -98,6 +98,12 @@ struct kasan_alloc_meta {
>  struct qlist_node {
>         struct qlist_node *next;
>  };
> +struct qlist_object {
> +       unsigned long addr;
> +       unsigned int size;
> +       struct kasan_track free_track;
> +       struct qlist_node qnode;
> +};
>  struct kasan_free_meta {
>         /* This field is used while the object is in the quarantine.
>          * Otherwise it might be used for the allocator freelist.
> @@ -133,11 +139,12 @@ void kasan_report(unsigned long addr, size_t size,
>                 bool is_write, unsigned long ip);
>  void kasan_report_invalid_free(void *object, unsigned long ip);
>
> -#if defined(CONFIG_KASAN_GENERIC) && \
> -       (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
> +#if (defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS_IDENTIFY)) \
> +       && (defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
>  void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
>  void quarantine_reduce(void);
>  void quarantine_remove_cache(struct kmem_cache *cache);
> +void set_track(struct kasan_track *track, gfp_t flags);
>  #else
>  static inline void quarantine_put(struct kasan_free_meta *info,
>                                 struct kmem_cache *cache) { }
> @@ -151,6 +158,31 @@ void print_tags(u8 addr_tag, const void *addr);
>
>  u8 random_tag(void);
>
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +bool quarantine_find_object(void *object,
> +               struct kasan_track *free_track);
> +
> +struct qlist_object *qobject_create(struct kasan_free_meta *info,
> +               struct kmem_cache *cache);
> +
> +void qobject_free(struct qlist_node *qlink, struct kmem_cache *cache);
> +#else
> +static inline bool quarantine_find_object(void *object,
> +               struct kasan_track *free_track)
> +{
> +       return false;
> +}
> +
> +static inline struct qlist_object *qobject_create(struct kasan_free_meta *info,
> +               struct kmem_cache *cache)
> +{
> +       return NULL;
> +}
> +
> +static inline void qobject_free(struct qlist_node *qlink,
> +               struct kmem_cache *cache) {}
> +#endif
> +
>  #else
>
>  static inline void print_tags(u8 addr_tag, const void *addr) { }
> @@ -160,6 +192,20 @@ static inline u8 random_tag(void)
>         return 0;
>  }
>
> +static inline bool quarantine_find_object(void *object,


Please restructure the code so that we don't duplicate this function
name 3 times in this header.

> +               struct kasan_track *free_track)
> +{
> +       return false;
> +}
> +
> +static inline struct qlist_object *qobject_create(struct kasan_free_meta *info,
> +               struct kmem_cache *cache)
> +{
> +       return NULL;
> +}
> +
> +static inline void qobject_free(struct qlist_node *qlink,
> +               struct kmem_cache *cache) {}
>  #endif
>
>  #ifndef arch_kasan_set_tag
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 978bc4a3eb51..43b009659d80 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -61,12 +61,16 @@ static void qlist_init(struct qlist_head *q)
>  static void qlist_put(struct qlist_head *q, struct qlist_node *qlink,
>                 size_t size)
>  {
> -       if (unlikely(qlist_empty(q)))
> +       struct qlist_node *prev_qlink = q->head;
> +
> +       if (unlikely(qlist_empty(q))) {
>                 q->head = qlink;
> -       else
> -               q->tail->next = qlink;
> -       q->tail = qlink;
> -       qlink->next = NULL;
> +               q->tail = qlink;
> +               qlink->next = NULL;
> +       } else {
> +               q->head = qlink;
> +               qlink->next = prev_qlink;
> +       }
>         q->bytes += size;
>  }
>
> @@ -121,7 +125,11 @@ static unsigned long quarantine_batch_size;
>   * Quarantine doesn't support memory shrinker with SLAB allocator, so we keep
>   * the ratio low to avoid OOM.
>   */
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +#define QUARANTINE_FRACTION 128

Explain in a comment why we use lower value for sw tags mode.

> +#else
>  #define QUARANTINE_FRACTION 32
> +#endif
>
>  static struct kmem_cache *qlink_to_cache(struct qlist_node *qlink)
>  {
> @@ -139,16 +147,24 @@ static void *qlink_to_object(struct qlist_node *qlink, struct kmem_cache *cache)
>
>  static void qlink_free(struct qlist_node *qlink, struct kmem_cache *cache)
>  {
> -       void *object = qlink_to_object(qlink, cache);
>         unsigned long flags;
> +       struct kmem_cache *obj_cache;
> +       void *object;
>
> -       if (IS_ENABLED(CONFIG_SLAB))
> -               local_irq_save(flags);
> +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
> +               qobject_free(qlink, cache);
> +       } else {
> +               obj_cache = cache ? cache :     qlink_to_cache(qlink);
> +               object = qlink_to_object(qlink, obj_cache);
>
> -       ___cache_free(cache, object, _THIS_IP_);
> +               if (IS_ENABLED(CONFIG_SLAB))
> +                       local_irq_save(flags);
>
> -       if (IS_ENABLED(CONFIG_SLAB))
> -               local_irq_restore(flags);
> +               ___cache_free(obj_cache, object, _THIS_IP_);
> +
> +               if (IS_ENABLED(CONFIG_SLAB))
> +                       local_irq_restore(flags);
> +       }
>  }
>
>  static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
> @@ -160,11 +176,9 @@ static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cache)
>
>         qlink = q->head;
>         while (qlink) {
> -               struct kmem_cache *obj_cache =
> -                       cache ? cache : qlink_to_cache(qlink);
>                 struct qlist_node *next = qlink->next;
>
> -               qlink_free(qlink, obj_cache);
> +               qlink_free(qlink, cache);
>                 qlink = next;
>         }
>         qlist_init(q);
> @@ -175,6 +189,8 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
>         unsigned long flags;
>         struct qlist_head *q;
>         struct qlist_head temp = QLIST_INIT;
> +       struct kmem_cache *qobject_cache;
> +       struct qlist_object *free_obj_info;
>
>         /*
>          * Note: irq must be disabled until after we move the batch to the
> @@ -187,7 +203,19 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
>         local_irq_save(flags);
>
>         q = this_cpu_ptr(&cpu_quarantine);
> -       qlist_put(q, &info->quarantine_link, cache->size);
> +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
> +               free_obj_info = qobject_create(info, cache);
> +               if (!free_obj_info) {
> +                       local_irq_restore(flags);
> +                       return;
> +               }
> +
> +               qobject_cache = qlink_to_cache(&free_obj_info->qnode);
> +               qlist_put(q, &free_obj_info->qnode, qobject_cache->size);

We could use sizeof(*free_obj_info), which looks simpler. Any reason
to do another hop through the cache?

> +       } else {
> +               qlist_put(q, &info->quarantine_link, cache->size);
> +       }
> +
>         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
>                 qlist_move_all(q, &temp);
>
> @@ -220,7 +248,6 @@ void quarantine_reduce(void)
>         if (likely(READ_ONCE(quarantine_size) <=
>                    READ_ONCE(quarantine_max_size)))
>                 return;
> -
>         /*
>          * srcu critical section ensures that quarantine_remove_cache()
>          * will not miss objects belonging to the cache while they are in our
> @@ -327,3 +354,90 @@ void quarantine_remove_cache(struct kmem_cache *cache)
>
>         synchronize_srcu(&remove_cache_srcu);
>  }
> +
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +static noinline bool qlist_find_object(struct qlist_head *from, void *arg)
> +{
> +       struct qlist_node *curr;
> +       struct qlist_object *curr_obj;
> +       struct qlist_object *target = (struct qlist_object *)arg;
> +
> +       if (unlikely(qlist_empty(from)))
> +               return false;
> +
> +       curr = from->head;
> +       while (curr) {
> +               struct qlist_node *next = curr->next;
> +
> +               curr_obj = container_of(curr, struct qlist_object, qnode);
> +               if (unlikely((target->addr >= curr_obj->addr) &&
> +                       (target->addr < (curr_obj->addr + curr_obj->size)))) {
> +                       target->free_track = curr_obj->free_track;
> +                       return true;
> +               }
> +
> +               curr = next;
> +       }
> +       return false;
> +}
> +
> +static noinline int per_cpu_find_object(void *arg)
> +{
> +       struct qlist_head *q;
> +
> +       q = this_cpu_ptr(&cpu_quarantine);
> +       return qlist_find_object(q, arg);
> +}
> +
> +struct cpumask cpu_allowed_mask __read_mostly;
> +
> +bool quarantine_find_object(void *addr, struct kasan_track *free_track)
> +{
> +       unsigned long flags;
> +       bool find = false;
> +       int cpu, i;
> +       struct qlist_object target;
> +
> +       target.addr = (unsigned long)addr;
> +
> +       cpumask_copy(&cpu_allowed_mask, cpu_online_mask);
> +       for_each_cpu(cpu, &cpu_allowed_mask) {
> +               find = smp_call_on_cpu(cpu, per_cpu_find_object,
> +                               (void *)&target, true);
> +               if (find) {
> +                       if (free_track)
> +                               *free_track = target.free_track;
> +                       return true;
> +               }
> +       }
> +
> +       raw_spin_lock_irqsave(&quarantine_lock, flags);
> +       for (i = quarantine_tail; i >= 0; i--) {
> +               if (qlist_empty(&global_quarantine[i]))
> +                       continue;
> +               find = qlist_find_object(&global_quarantine[i],
> +                               (void *)&target);
> +               if (find) {
> +                       if (free_track)
> +                               *free_track = target.free_track;
> +                       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> +                       return true;
> +               }
> +       }
> +       for (i = QUARANTINE_BATCHES-1; i > quarantine_tail; i--) {

Find a way to calculate the right index using a single loop, rather
that copy-paste the whole loop body to do a small adjustment to index.

> +               if (qlist_empty(&global_quarantine[i]))
> +                       continue;
> +               find = qlist_find_object(&global_quarantine[i],
> +                               (void *)&target);
> +               if (find) {
> +                       if (free_track)
> +                               *free_track = target.free_track;
> +                       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> +                       return true;
> +               }
> +       }
> +       raw_spin_unlock_irqrestore(&quarantine_lock, flags);
> +
> +       return false;
> +}
> +#endif
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index ca9418fe9232..3cbc24cd3d43 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -150,18 +150,27 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
>  }
>
>  static void describe_object(struct kmem_cache *cache, void *object,
> -                               const void *addr)
> +                               const void *tagged_addr)
>  {
> +       void *untagged_addr = reset_tag(tagged_addr);
>         struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
> +       struct kasan_track free_track;
>
>         if (cache->flags & SLAB_KASAN) {
> -               print_track(&alloc_info->alloc_track, "Allocated");
> -               pr_err("\n");
> -               print_track(&alloc_info->free_track, "Freed");
> -               pr_err("\n");
> +               if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY) &&
> +                       quarantine_find_object((void *)tagged_addr,
> +                               &free_track)) {
> +                       print_track(&free_track, "Freed");
> +                       pr_err("\n");
> +               } else {
> +                       print_track(&alloc_info->alloc_track, "Allocated");
> +                       pr_err("\n");
> +                       print_track(&alloc_info->free_track, "Freed");
> +                       pr_err("\n");
> +               }
>         }
>
> -       describe_object_addr(cache, object, addr);
> +       describe_object_addr(cache, object, untagged_addr);
>  }
>
>  static inline bool kernel_or_module_addr(const void *addr)
> @@ -180,23 +189,25 @@ static inline bool init_task_stack_addr(const void *addr)
>                         sizeof(init_thread_union.stack));
>  }
>
> -static void print_address_description(void *addr)
> +static void print_address_description(void *tagged_addr)
>  {
> -       struct page *page = addr_to_page(addr);
> +       void *untagged_addr = reset_tag(tagged_addr);
> +       struct page *page = addr_to_page(untagged_addr);
>
>         dump_stack();
>         pr_err("\n");
>
>         if (page && PageSlab(page)) {
>                 struct kmem_cache *cache = page->slab_cache;
> -               void *object = nearest_obj(cache, page, addr);
> +               void *object = nearest_obj(cache, page, untagged_addr);
>
> -               describe_object(cache, object, addr);
> +               describe_object(cache, object, tagged_addr);
>         }
>
> -       if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
> +       if (kernel_or_module_addr(untagged_addr) &&
> +                       !init_task_stack_addr(untagged_addr)) {
>                 pr_err("The buggy address belongs to the variable:\n");
> -               pr_err(" %pS\n", addr);
> +               pr_err(" %pS\n", untagged_addr);
>         }
>
>         if (page) {
> @@ -314,7 +325,7 @@ void kasan_report(unsigned long addr, size_t size,
>         pr_err("\n");
>
>         if (addr_has_shadow(untagged_addr)) {
> -               print_address_description(untagged_addr);
> +               print_address_description(tagged_addr);
>                 pr_err("\n");
>                 print_shadow_for_address(info.first_bad_addr);
>         } else {
> diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
> index 63fca3172659..7804b48f760e 100644
> --- a/mm/kasan/tags.c
> +++ b/mm/kasan/tags.c
> @@ -124,6 +124,53 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
>         }
>  }
>
> +#ifdef CONFIG_KASAN_SW_TAGS_IDENTIFY
> +void kasan_cache_shrink(struct kmem_cache *cache)
> +{
> +       quarantine_remove_cache(cache);

This does not look to be necessary. There are no objects from that
cache in the quarantine in general. Let's not over-complicate this.



> +}
> +
> +struct qlist_object *qobject_create(struct kasan_free_meta *info,
> +                                               struct kmem_cache *cache)
> +{
> +       struct qlist_object *qobject_info;
> +       void *object;
> +
> +       object = ((void *)info) - cache->kasan_info.free_meta_offset;
> +       qobject_info = kmalloc(sizeof(struct qlist_object), GFP_NOWAIT);
> +       if (!qobject_info)
> +               return NULL;
> +       qobject_info->addr = (unsigned long) object;
> +       qobject_info->size = cache->object_size;
> +       set_track(&qobject_info->free_track, GFP_NOWAIT);
> +
> +       return qobject_info;
> +}
> +
> +static struct kmem_cache *qobject_to_cache(struct qlist_object *qobject)
> +{
> +       return virt_to_head_page(qobject)->slab_cache;

This looks identical to the existing qlink_to_cache, please use the
existing function.

> +}
> +
> +void qobject_free(struct qlist_node *qlink, struct kmem_cache *cache)
> +{
> +       struct qlist_object *qobject = container_of(qlink,
> +                       struct qlist_object, qnode);
> +       unsigned long flags;
> +
> +       struct kmem_cache *qobject_cache =
> +                       cache ? cache : qobject_to_cache(qobject);

I don't understand this part.
Will caller ever pass us the right cache? Or cache is always NULL? If
it's always NULL, why do we accept it at all?
We also allocate qobjects with kmalloc always, so we must use kfree,
why do we even mess with caches?


> +
> +       if (IS_ENABLED(CONFIG_SLAB))
> +               local_irq_save(flags);
> +
> +       ___cache_free(qobject_cache, (void *)qobject, _THIS_IP_);
> +
> +       if (IS_ENABLED(CONFIG_SLAB))
> +               local_irq_restore(flags);
> +}
> +#endif
> +
>  #define DEFINE_HWASAN_LOAD_STORE(size)                                 \
>         void __hwasan_load##size##_noabort(unsigned long addr)          \
>         {                                                               \
> diff --git a/mm/kasan/tags_report.c b/mm/kasan/tags_report.c
> index 8eaf5f722271..63b0b1f381ff 100644
> --- a/mm/kasan/tags_report.c
> +++ b/mm/kasan/tags_report.c
> @@ -36,7 +36,13 @@
>
>  const char *get_bug_type(struct kasan_access_info *info)
>  {
> -       return "invalid-access";
> +       if (IS_ENABLED(CONFIG_KASAN_SW_TAGS_IDENTIFY)) {
> +               if (quarantine_find_object((void *)info->access_addr, NULL))
> +                       return "use-after-free";
> +               else
> +                       return "out-of-bounds";
> +       } else
> +               return "invalid-access";
>  }
>
>  void *find_first_bad_addr(void *addr, size_t size)
> diff --git a/mm/slub.c b/mm/slub.c
> index 1b08fbcb7e61..751429d02846 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3004,7 +3004,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
>                 do_slab_free(s, page, head, tail, cnt, addr);
>  }
>
> -#ifdef CONFIG_KASAN_GENERIC
> +#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS_IDENTIFY)
>  void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
>  {
>         do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);

