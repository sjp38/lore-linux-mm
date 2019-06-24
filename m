Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BD83C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:46:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467DB20674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 11:46:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c/f5f/Ez"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467DB20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7F1A8E0006; Mon, 24 Jun 2019 07:46:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2F9A8E0002; Mon, 24 Jun 2019 07:46:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD1298E0006; Mon, 24 Jun 2019 07:46:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFC18E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:46:07 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s83so21625319iod.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:46:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xjyC1woOCk6QoSm3J7dmvFYHQ65jTUd0WwHup6buLdA=;
        b=aJmG+iHlvOlGDsub6aNBGYcF01zIOfMeXnhPZpT0Q0po3MDrgGF4LkSKAyW8ug1HMu
         TS5p13CvPva4qL7HNVIT7NmBIoWze7gUAfIkjPiOCDwlgNezDr4X+afEhx2ubxZcC7qS
         xI6Avp03RFeeAFTpFPgHVVtSfKiHTu2sXuvT+MHjgvrz/ImjNor4Y8MOgHMFdhbVci77
         RrmchSgevxGhA63lLcKwRpdhmuWi7iCTFR+JsYIK84LRKS3MSzhaGCgY+Q3+HCE1e/1C
         kJOhxX9XN8GPev1D5h9V0NrcvicS9qeiCWBeFZ/iuY4CKB7tUEr+a8wo9zXNTX6ZuZ5/
         hSpQ==
X-Gm-Message-State: APjAAAXgKPPebmV0T54bw2c/mmRzFSl4aGL64RslcKfKIwlWh/hf73qU
	gCi6bm94JXA5M0dYDL40UbW9RyEL59aUJ7qWMebHFNMvUDzQdZ6LDmgc+yI3aGVuQ45/kTl26z1
	y/qWwPjyNeZEW7F/U+4JQecDVJKjA0D0Wm1CoxacW64g4Z0rGsLNhmrLbE2/0BXpHJw==
X-Received: by 2002:a02:5502:: with SMTP id e2mr41876080jab.87.1561376767350;
        Mon, 24 Jun 2019 04:46:07 -0700 (PDT)
X-Received: by 2002:a02:5502:: with SMTP id e2mr41876020jab.87.1561376766685;
        Mon, 24 Jun 2019 04:46:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561376766; cv=none;
        d=google.com; s=arc-20160816;
        b=KIJAQeGiz/k0cBE/FtcA/BfYRBSc3Ss38aNwDbSA6mE0iuKAeh6jKRt46JRjhpWW8C
         t4vpe8UXm0m5cavAuontfLZ483F8UlHyHU9Kbc+RrHR5gx9ZL5ed8fyEjf2t681qMbcU
         CQwVfWq4DD9M3op3V1QabwGm56jkH6u2EViWPKgArzv0xpptVTXj8i03BkFLwe2k2A2x
         Dbu5Q1SIyQ0UVWGMMZMTkkUlRwAnY+3SJv8qvKpk+4wHxXxvYowBer7PSyReGbvErXtD
         kmmk6h07IBa342OU4T6jh/UUtY3mt0tpm2OoAPgObzFZb8dEYGXvQroOUy/6JNe2YbWA
         h27Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xjyC1woOCk6QoSm3J7dmvFYHQ65jTUd0WwHup6buLdA=;
        b=oJZgM29HLXJceYUelQRqb9S1GR2N85GcewtRPE61Js3FpbNkmERkF6B05ERB7I3MuD
         89NCYeJ/B23pvfc1zABe1O5Gjct8MHN/A8isJ+3KbY6v7WF8Tnm0MBlF8F5ya3m9+URM
         MqMBR/ZYoammtWRf3gU9xHZ9ABZ1ovGgL5dZWbgWzO/Wrpgt5NJFFlP8ipozEQGvfTH+
         KM0CJIQm/9KLmXnPxOQgh5AyXCRgTzjBCKMog83CRU9iGevcdxPyof2ucvaasn9c/Nju
         +z86S1ed6rJI/WZWej1b2qxPdfUds4ov0V519NgsR60AQAV+fLeF5p/rO2bZmBChUUWG
         Mlmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c/f5f/Ez";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor7743692iob.115.2019.06.24.04.46.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 04:46:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c/f5f/Ez";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xjyC1woOCk6QoSm3J7dmvFYHQ65jTUd0WwHup6buLdA=;
        b=c/f5f/Ezq3qoosgf0iqgNPPcbIYUobo1qpnTyfBhKYcJlD4mJXs5nY2Fk/i59Ypocr
         oQFMXxWneqxFDJ3UlvFYhCbMzeaD0RwSQIePTpoE5ZabZmOc1ubkk2xy9XaV16k1mWpG
         uhW5uB/qv024uac34FQoadj7MRiYeO6H4o0MhAbsqH09bTa0F0KQpiaQXFET3z1MtT/d
         Oju2FzIw+5E6M8TP+z8WD0t/uffACrjPTXLSo1MYDaEtdGk+3Hm/PaRXl5EZWsdpLsO8
         3k6Ap14uTP2sPWcBeX+6gjzk8vGBecUobCh1G6MaumuEeR7EXuz9p88d7wEt2SPezw97
         FmjQ==
X-Google-Smtp-Source: APXvYqx6HEUoIqfS52gzn8y0KrQsf7q1x4CiJ/9P8zJ9QW7nroLu9eqcvYa+03rEne+EbXrDQjNrpkGRT2bTR5Pv1mU=
X-Received: by 2002:a6b:4101:: with SMTP id n1mr14151102ioa.138.1561376765960;
 Mon, 24 Jun 2019 04:46:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190624110532.41065-1-elver@google.com>
In-Reply-To: <20190624110532.41065-1-elver@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 24 Jun 2019 13:45:53 +0200
Message-ID: <CACT4Y+ZP4gkLh5zbwSLzV+ZwJCq_zSrsaQE+1Y94iU0JJzJNqw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: Add shadow memory validation in ksize()
To: Marco Elver <elver@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
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

This does not have anything to do with pagealloc, right?
If so, remove pagealloc here and in the function name. kzfree also
implies kmalloc, so this could be just double_kzfree().

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


I am thinking if we should call kasan_check_read(object, 1) here...
This would not produce a double-free error (use-after-free read
instead), but conceptually why we would allow calling ksize on freed
objects? But more importantly, we just skip unpoisoning shadow, but we
still smash the object contents on the second kzfree, right? This
means that the heap is corrupted after running the tests. As far as I
remember we avoided corrupting heap in tests and in particular a
normal double-free does not. As of now we've smashed the quarantine
link, but if we move the free metadata back into the object (e.g. to
resolve https://bugzilla.kernel.org/show_bug.cgi?id=198437) we also
smash free metadata before we print the double free report (at the
very least we will fail to print free stack, and crash at worst).

Doing kasan_check_read() in ksize() will cause a report _before_ we
smashed the object at the cost of an imprecise report title.
And fixing all of the issues will require changing kzfree I think.


> +               /*
> +                * We assume that ksize callers could use whole allocated area,
> +                * so we need to unpoison this area.
> +                */
> +               kasan_unpoison_shadow(object, size);
> +       }
>         return size;
>  }
>  EXPORT_SYMBOL(ksize);
> --
> 2.22.0.410.gd8fdbe21b5-goog
>

