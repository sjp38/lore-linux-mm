Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 873E2C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E2CE20674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:46:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sm2RVRXA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E2CE20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09D88E0007; Mon, 24 Jun 2019 07:46:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9948E0002; Mon, 24 Jun 2019 07:46:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B81C88E0007; Mon, 24 Jun 2019 07:46:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 812708E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:46:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so9435401pfj.4
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:46:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4sCioPXlb29uCUXcWaSeu3ouKfJt5j/bFJ2w/CyNw2c=;
        b=VLTDSm0R2OQzqaschPC23BBIpNatJd/nCZIGnuxongQsjRTJgM3g/Ara1kOR62KKuX
         ezFb3RG1/vwYtdDBxUhpzld+57bwe91haqeOLdFrketh65+AaehesNMS9amp+OVEvsG/
         D64mKopMybSzB8akKM/klj5FdLkU4dJxdJrDg0mpy6LL+NiWS9y3aQuL/7Ib43U+EEiD
         Dz/Y30yJ0pEy3ChrFi6Nsln/MXFKPrLEvAqZsyZ7NAnxovsasTh2/8W1yQRPm+pzO7o9
         diBLYdcEJhEZSvuCmxhw3cvrya5ZXAPZJ15tqXYlloSvSRe5hLGoBbvFManHTIWeFvfC
         cgmw==
X-Gm-Message-State: APjAAAXD0UiJsCPQ9uTaZfMyN1XjPzLoDqkGZ7SiANKAJXMV9VFkBizR
	Z/Q9JiQjUuug4HRji87sRexeiwIfybANICDtIGCqE8WN+xo+4E3ztYefC87/4t7bDGYLXyULPFx
	k7P+I8/WZ/+SaGLFDq0HiQSVj8rxrjso418oDni3eq4F/Iawph1KGx83ggxWM+groCg==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr1896962plp.126.1561376786010;
        Mon, 24 Jun 2019 04:46:26 -0700 (PDT)
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr1896903plp.126.1561376785212;
        Mon, 24 Jun 2019 04:46:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561376785; cv=none;
        d=google.com; s=arc-20160816;
        b=mJnzrg8nZ+jh9tqevHojrtTfnLYd6vvQGpCrHWD1VQy/M2Clrd/g7hm3fZJfJfic6q
         D2S/x48dY5WE4tFCxeDlWdjj7YEhtNMfYr6LoPivRHcjLOvWJhXioMfHEsAtp48boLVh
         ENAde+BoVwsnf59dTiojuvfUBpq6PadYo578oVfNSq8AI6afVtjyydXxVMJBp3kIjZrK
         7TXU1UvZv+6WlGGMO8Gn4bF7YHQVlnyX7q0mJ8CdDqBzgqvHnT2b1/iZTQ3Cet6UBGZo
         DsEmOgIf4dUpHxG/N65A2MNUqakpkwBljbwJvpQuL2EkUqdq8zAWcHB39+psy5DyEjMs
         CYSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4sCioPXlb29uCUXcWaSeu3ouKfJt5j/bFJ2w/CyNw2c=;
        b=Jsgfui/mWCadrB9FrcHHMie4ELN+r5JldDdZrnW0JJtNvM9NEzbr9ps1jTUe2C2XBB
         sVUoZxc5c+Y/npIbWs//H+tQHNT6OEDipXVa2OOsEQsqmPJGzuDBpGUHtHIg/VlnFsbx
         /uCK61Signu4hOJ50ptTKtDVsXSQ4qweamIm/5AT1FXC32GiQXg6j6cH+F3YK+ASBzyW
         sY2wINzXLzTirqsdP+X47qBh6V6JYD746+62B08GCCGrVRKWFDlKJDJZhtBDyl+kzaSC
         Acpi7ckfsqjz3OL6bU3g8uq8jPbU7tbncKhDv2LSr+brjdbuKaww8otlecFRJj52Dr8W
         xDNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sm2RVRXA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor12668028plt.10.2019.06.24.04.46.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 04:46:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sm2RVRXA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4sCioPXlb29uCUXcWaSeu3ouKfJt5j/bFJ2w/CyNw2c=;
        b=sm2RVRXAjwVlXYZLx7geioGtk+BR242iTE1ahR9xHr0PmrJjewpjBjtvnvs/qIFqp/
         abD3pOu/UOwmqUWwwoz0bkUvBMFuuWaXQFhjAYGad/dxwR0f4Yp/p4RLynZO0bl6cB1V
         1ZyAUXh+Yd4XNJ06zBDrmW/UCque+MpGgUQtsNQ1tt+eMg+1fKBtRcLSMQ+q/Tbpty5b
         jCWWBeJWWo8u045J3E9ZVtqB0tk/dsl2ryXKOqdlynQ8YipfI1qGXIScDJ1RhHHu7w6Y
         9C1bXNH2/eJ6LC0wnSD0Henu0S2E6xfL7xnFb63mnmeByrHaxchCLGPrHiJdecHasvM4
         TMZg==
X-Google-Smtp-Source: APXvYqwtGwqXfKf0YFqGGNqqaIODSyYzqBP+opW0jxwa9SyEbdSS0oG3ciF67nSp+8tfpiP0kQFKFzXpMmOfeZVvhtQ=
X-Received: by 2002:a17:902:4183:: with SMTP id f3mr31396406pld.336.1561376784423;
 Mon, 24 Jun 2019 04:46:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190624110532.41065-1-elver@google.com>
In-Reply-To: <20190624110532.41065-1-elver@google.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 24 Jun 2019 13:46:12 +0200
Message-ID: <CAAeHK+w5oNt+3wvHr2W2+ikd8J=psk2YSjRSARF4P+W7UgUX_Q@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: Add shadow memory validation in ksize()
To: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Alexander Potapenko <glider@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 1:05 PM Marco Elver <elver@google.com> wrote:
>
> ksize() has been unconditionally unpoisoning the whole shadow memory region
> associated with an allocation. This can lead to various undetected bugs,
> for example, double-kzfree().
>
> kzfree() uses ksize() to determine the actual allocation size, and
> subsequently zeroes the memory. Since ksize() used to just unpoison the
> whole shadow memory region, no invalid free was detected.
>
> This patch addresses this as follows:
>
> 1. For each SLAB and SLUB allocators: add a check in ksize() that the
>    pointed to object's shadow memory is valid, and only then unpoison
>    the memory region.
>
> 2. Update kasan_unpoison_slab() to explicitly unpoison the shadow memory
>    region using the size obtained from ksize(); it is possible that
>    double-unpoison can occur if the shadow was already valid, however,
>    this should not be the general case.
>
> Tested:
> 1. With SLAB allocator: a) normal boot without warnings; b) verified the
>    added double-kzfree() is detected.
> 2. With SLUB allocator: a) normal boot without warnings; b) verified the
>    added double-kzfree() is detected.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=199359
> Signed-off-by: Marco Elver <elver@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/kasan.h | 20 +++++++++++++++++++-
>  lib/test_kasan.c      | 17 +++++++++++++++++
>  mm/kasan/common.c     | 15 ++++++++++++---
>  mm/slab.c             | 12 ++++++++----
>  mm/slub.c             | 11 +++++++----
>  5 files changed, 63 insertions(+), 12 deletions(-)
>
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index b40ea104dd36..9778a68fb5cf 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -63,6 +63,14 @@ void * __must_check kasan_krealloc(const void *object, size_t new_size,
>
>  void * __must_check kasan_slab_alloc(struct kmem_cache *s, void *object,
>                                         gfp_t flags);
> +
> +/**
> + * kasan_shadow_invalid - Check if shadow memory of object is invalid.
> + * @object: The pointed to object; the object pointer may be tagged.
> + * @return: true if shadow is invalid, false if valid.
> + */
> +bool kasan_shadow_invalid(const void *object);
> +
>  bool kasan_slab_free(struct kmem_cache *s, void *object, unsigned long ip);
>
>  struct kasan_cache {
> @@ -77,7 +85,11 @@ int kasan_add_zero_shadow(void *start, unsigned long size);
>  void kasan_remove_zero_shadow(void *start, unsigned long size);
>
>  size_t ksize(const void *);
> -static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
> +static inline void kasan_unpoison_slab(const void *ptr)
> +{
> +       /* Force unpoison: ksize() only unpoisons if shadow of ptr is valid. */
> +       kasan_unpoison_shadow(ptr, ksize(ptr));
> +}
>  size_t kasan_metadata_size(struct kmem_cache *cache);
>
>  bool kasan_save_enable_multi_shot(void);
> @@ -133,6 +145,12 @@ static inline void *kasan_slab_alloc(struct kmem_cache *s, void *object,
>  {
>         return object;
>  }
> +
> +static inline bool kasan_shadow_invalid(const void *object)
> +{
> +       return false;
> +}
> +
>  static inline bool kasan_slab_free(struct kmem_cache *s, void *object,
>                                    unsigned long ip)
>  {
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 7de2702621dc..9b710bfa84da 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -623,6 +623,22 @@ static noinline void __init kasan_strings(void)
>         strnlen(ptr, 1);
>  }
>
> +static noinline void __init kmalloc_pagealloc_double_kzfree(void)
> +{
> +       char *ptr;
> +       size_t size = 16;
> +
> +       pr_info("kmalloc pagealloc allocation: double-free (kzfree)\n");
> +       ptr = kmalloc(size, GFP_KERNEL);
> +       if (!ptr) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       kzfree(ptr);
> +       kzfree(ptr);
> +}
> +
>  static int __init kmalloc_tests_init(void)
>  {
>         /*
> @@ -664,6 +680,7 @@ static int __init kmalloc_tests_init(void)
>         kasan_memchr();
>         kasan_memcmp();
>         kasan_strings();
> +       kmalloc_pagealloc_double_kzfree();
>
>         kasan_restore_multi_shot(multishot);
>
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 242fdc01aaa9..357e02e73163 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -413,10 +413,20 @@ static inline bool shadow_invalid(u8 tag, s8 shadow_byte)
>                 return tag != (u8)shadow_byte;
>  }
>
> +bool kasan_shadow_invalid(const void *object)
> +{
> +       u8 tag = get_tag(object);
> +       s8 shadow_byte;
> +
> +       object = reset_tag(object);
> +
> +       shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
> +       return shadow_invalid(tag, shadow_byte);
> +}
> +
>  static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>                               unsigned long ip, bool quarantine)
>  {
> -       s8 shadow_byte;
>         u8 tag;

The tag variable is not used any more in this function, right? If so,
it can be removed.

>         void *tagged_object;
>         unsigned long rounded_up_size;
> @@ -435,8 +445,7 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>         if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
>                 return false;
>
> -       shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
> -       if (shadow_invalid(tag, shadow_byte)) {
> +       if (kasan_shadow_invalid(tagged_object)) {
>                 kasan_report_invalid_free(tagged_object, ip);
>                 return true;
>         }
> diff --git a/mm/slab.c b/mm/slab.c
> index f7117ad9b3a3..3595348c401b 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4226,10 +4226,14 @@ size_t ksize(const void *objp)
>                 return 0;
>
>         size = virt_to_cache(objp)->object_size;
> -       /* We assume that ksize callers could use the whole allocated area,
> -        * so we need to unpoison this area.
> -        */
> -       kasan_unpoison_shadow(objp, size);
> +
> +       if (!kasan_shadow_invalid(objp)) {
> +               /*
> +                * We assume that ksize callers could use the whole allocated
> +                * area, so we need to unpoison this area.
> +                */
> +               kasan_unpoison_shadow(objp, size);
> +       }
>
>         return size;
>  }
> diff --git a/mm/slub.c b/mm/slub.c
> index cd04dbd2b5d0..28231d30358e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3921,10 +3921,13 @@ static size_t __ksize(const void *object)
>  size_t ksize(const void *object)
>  {
>         size_t size = __ksize(object);
> -       /* We assume that ksize callers could use whole allocated area,
> -        * so we need to unpoison this area.
> -        */
> -       kasan_unpoison_shadow(object, size);
> +       if (!kasan_shadow_invalid(object)) {
> +               /*
> +                * We assume that ksize callers could use whole allocated area,
> +                * so we need to unpoison this area.
> +                */
> +               kasan_unpoison_shadow(object, size);
> +       }

I think it's better to add a kasan_ksize() hook that implements this
logic. This way we don't have to duplicate it for SLAB and SLUB.

In this case we also don't need an exported kasan_shadow_invalid()
hook, and its logic can be moved into shadow_invalid().

>         return size;
>  }
>  EXPORT_SYMBOL(ksize);
> --
> 2.22.0.410.gd8fdbe21b5-goog
>

