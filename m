Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3BE6B025E
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:52:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so137546095pfx.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 23:52:31 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a2si5052515pfc.204.2016.07.13.23.52.28
        for <linux-mm@kvack.org>;
        Wed, 13 Jul 2016 23:52:30 -0700 (PDT)
Date: Thu, 14 Jul 2016 15:56:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Message-ID: <20160714065621.GC29676@js1304-P5Q-DELUXE>
References: <1467974210-117852-1-git-send-email-glider@google.com>
 <20160711060243.GA14107@js1304-P5Q-DELUXE>
 <CAG_fn=VM=nMFgKCGEHdD+A4TP9-8XoXKbXDyeXCc6ntkB16q0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VM=nMFgKCGEHdD+A4TP9-8XoXKbXDyeXCc6ntkB16q0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 03:02:19PM +0200, Alexander Potapenko wrote:
> >> +
> >>       /* Add alloc meta. */
> >>       cache->kasan_info.alloc_meta_offset = *size;
> >>       *size += sizeof(struct kasan_alloc_meta);
> >> @@ -392,17 +385,36 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
> >>           cache->object_size < sizeof(struct kasan_free_meta)) {
> >>               cache->kasan_info.free_meta_offset = *size;
> >>               *size += sizeof(struct kasan_free_meta);
> >> +     } else {
> >> +             cache->kasan_info.free_meta_offset = 0;
> >>       }
> >>       redzone_adjust = optimal_redzone(cache->object_size) -
> >>               (*size - cache->object_size);
> >> +
> >>       if (redzone_adjust > 0)
> >>               *size += redzone_adjust;
> >> -     *size = min(KMALLOC_MAX_CACHE_SIZE,
> >> +
> >> +#ifdef CONFIG_SLAB
> >> +     *size = min(KMALLOC_MAX_SIZE,
> >>                   max(*size,
> >>                       cache->object_size +
> >>                       optimal_redzone(cache->object_size)));
> >> -}
> >> +     /*
> >> +      * If the metadata doesn't fit, don't enable KASAN at all.
> >> +      */
> >> +     if (*size <= cache->kasan_info.alloc_meta_offset ||
> >> +                     *size <= cache->kasan_info.free_meta_offset) {
> >> +             *size = orig_size;
> >> +             return;
> >> +     }
> >> +#else
> >> +     *size = max(*size,
> >> +                     cache->object_size +
> >> +                     optimal_redzone(cache->object_size));
> >> +
> >>  #endif
> >
> > Hmm... could you explain why SLAB needs min(KMALLOC_MAX_SIZE, XX) but
> > not SLUB?
> 
> Because if the size is bigger than KMALLOC_MAX_SIZE then
> __kmem_cache_create() returns -E2BIG for SLAB. This happens right at
> startup in create_boot_cache().
> As far as I understand, SLUB doesn't have the upper limit (or is it
> that we just aren't hitting it?)

Perhaps, SLUB also has the upper limit although it wasn't triggered
easily since there is no such kmem_cache. Unlikely, SLAB has a such
sized kmem_cache in default (kmalloc-XXXXX). I haven't look at
calculate_order() in detail but it would give you some insight.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
