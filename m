Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8ED6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 11:39:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so14094246lfc.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 08:39:28 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id k65si1888918lfk.168.2016.05.10.08.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 08:39:27 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id y84so19570463lfc.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 08:39:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <48cc05da0a19447843c6479cf1c15dbc174503a0.1458036040.git.glider@google.com>
References: <cover.1458036040.git.glider@google.com>
	<48cc05da0a19447843c6479cf1c15dbc174503a0.1458036040.git.glider@google.com>
Date: Tue, 10 May 2016 18:39:26 +0300
Message-ID: <CAPAsAGySgwbB8Gh_t4DJUjtA1GcpN_AEfNpNOM62GoNLiGNSEQ@mail.gmail.com>
Subject: Re: [PATCH v8 7/7] mm: kasan: Initial memory quarantine implementation
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-15 13:10 GMT+03:00 Alexander Potapenko <glider@google.com>:

>
>  static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
>  static inline void kasan_free_shadow(const struct vm_struct *vm) {}
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index 82169fb..799c98e 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -344,6 +344,32 @@ static noinline void __init kasan_stack_oob(void)
>         *(volatile char *)p;
>  }
>
> +#ifdef CONFIG_SLAB
> +static noinline void __init kasan_quarantine_cache(void)
> +{
> +       struct kmem_cache *cache = kmem_cache_create(
> +                       "test", 137, 8, GFP_KERNEL, NULL);
> +       int i;
> +
> +       for (i = 0; i <  100; i++) {
> +               void *p = kmem_cache_alloc(cache, GFP_KERNEL);
> +
> +               kmem_cache_free(cache, p);
> +               p = kmalloc(sizeof(u64), GFP_KERNEL);
> +               kfree(p);
> +       }
> +       kmem_cache_shrink(cache);
> +       for (i = 0; i <  100; i++) {
> +               u64 *p = kmem_cache_alloc(cache, GFP_KERNEL);
> +
> +               kmem_cache_free(cache, p);
> +               p = kmalloc(sizeof(u64), GFP_KERNEL);
> +               kfree(p);
> +       }
> +       kmem_cache_destroy(cache);
> +}
> +#endif
> +

Test looks quite useless. The kernel does allocations/frees all the
time, so I don't think that this test
adds something valuable.
And what's the result that we expect from this test? No crashes?
I'm thinking it would better to remove it.

[...]

> +
> +/* smp_load_acquire() here pairs with smp_store_release() in
> + * quarantine_reduce().
> + */
> +#define QUARANTINE_LOW_SIZE (smp_load_acquire(&quarantine_size) * 3 / 4)

I'd prefer open coding barrier with a proper comment int place,
instead of sneaking it into macros.

[...]

> +
> +void quarantine_reduce(void)
> +{
> +       size_t new_quarantine_size;
> +       unsigned long flags;
> +       struct qlist to_free = QLIST_INIT;
> +       size_t size_to_free = 0;
> +       void **last;
> +
> +       /* smp_load_acquire() here pairs with smp_store_release() below. */

Besides pairing rules, the comment should also explain *why* we need
this and for what
load/stores it provides memory ordering guarantees. For example take a
look at other
comments near barriers in the kernel tree.

> +       if (likely(ACCESS_ONCE(global_quarantine.bytes) <=
> +                  smp_load_acquire(&quarantine_size)))
> +               return;
> +
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
