Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id CD54D6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:56:21 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id oe12so11127322lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:56:21 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id yd3si10986272lbc.63.2016.03.14.09.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 09:56:20 -0700 (PDT)
Received: by mail-lb0-x22e.google.com with SMTP id k12so14633633lbb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:56:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
References: <cover.1457949315.git.glider@google.com>
	<4f6880ee0c1545b3ae9c25cfe86a879d724c4e7b.1457949315.git.glider@google.com>
Date: Mon, 14 Mar 2016 19:56:19 +0300
Message-ID: <CAPAsAGx58NuvRB7=qeXr27VFE8PoabLxvNGVGP66MV1WkhDA+g@mail.gmail.com>
Subject: Re: [PATCH v7 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-03-14 13:43 GMT+03:00 Alexander Potapenko <glider@google.com>:

> +
> +       rec = this_cpu_ptr(&depot_recursion);
> +       /* Don't store the stack if we've been called recursively. */
> +       if (unlikely(*rec))
> +               goto fast_exit;
> +       *rec = true;


This just can't work. As long as preemption enabled, task could
migrate on another cpu anytime.
You could use per-task flag, although it's possible to miss some
in-irq stacktraces:

depot_save_stack()
    if (current->stackdeport_recursion)
          goto fast_exit;
    current->stackdepot_recursion++
    <IRQ>
           ....
           depot_save_stack()
                 if (current->stackdeport_recursion)
                      goto fast_exit;




> +       if (unlikely(!smp_load_acquire(&next_slab_inited))) {
> +               /* Zero out zone modifiers, as we don't have specific zone
> +                * requirements. Keep the flags related to allocation in atomic
> +                * contexts and I/O.
> +                */
> +               alloc_flags &= ~GFP_ZONEMASK;
> +               alloc_flags &= (GFP_ATOMIC | GFP_KERNEL);
> +               /* When possible, allocate using vmalloc() to reduce physical
> +                * address space fragmentation. vmalloc() doesn't work if
> +                * kmalloc caches haven't been initialized or if it's being
> +                * called from an interrupt handler.
> +                */
> +               if (kmalloc_caches[KMALLOC_SHIFT_HIGH] && !in_interrupt()) {

This is clearly a wrong way to check whether is slab available or not.
Besides you need to check
vmalloc() for availability, not slab.
Given that STAC_ALLOC_ORDER is 2 now, I think it should be fine to use
alloc_pages() all the time.
Or fix condition, up to you.

> +                       prealloc = __vmalloc(
> +                               STACK_ALLOC_SIZE, alloc_flags, PAGE_KERNEL);
> +               } else {
> +                       page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
> +                       if (page)
> +                               prealloc = page_address(page);
> +               }
> +       }
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
