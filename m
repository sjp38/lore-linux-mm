Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3779F6B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 13:17:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so19697778wma.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 10:17:07 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id 83si5263596lja.62.2016.07.15.10.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 10:17:05 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id l69so35918399lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 10:17:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com>
References: <1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 15 Jul 2016 19:17:04 +0200
Message-ID: <CAG_fn=VjFQs2xOwDH=v9FaKxJjy8rHSSNr3qMrANnFdOEhSXbg@mail.gmail.com>
Subject: Re: [PATCH] mm-kasan-switch-slub-to-stackdepot-enable-memory-quarantine-for-slub-fix
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitriy Vyukov <dvyukov@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 6:50 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> - Remove CONFIG_SLAB ifdefs. The code works just fine with both allocator=
s.
> - Reset metada offsets if metadata doesn't fit. Otherwise kasan_metadata_=
size()
> will give us the wrong results.
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/kasan.c | 17 +++++------------
>  1 file changed, 5 insertions(+), 12 deletions(-)
>
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index d92a7a2..b6f99e8 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -372,9 +372,7 @@ void kasan_cache_create(struct kmem_cache *cache, siz=
e_t *size,
>                         unsigned long *flags)
>  {
>         int redzone_adjust;
> -#ifdef CONFIG_SLAB
>         int orig_size =3D *size;
> -#endif
>
>         /* Add alloc meta. */
>         cache->kasan_info.alloc_meta_offset =3D *size;
> @@ -392,25 +390,20 @@ void kasan_cache_create(struct kmem_cache *cache, s=
ize_t *size,
>         if (redzone_adjust > 0)
>                 *size +=3D redzone_adjust;
>
> -#ifdef CONFIG_SLAB
> -       *size =3D min(KMALLOC_MAX_SIZE,
> -                   max(*size,
> -                       cache->object_size +
> -                       optimal_redzone(cache->object_size)));
> +       *size =3D min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
> +                                       optimal_redzone(cache->object_siz=
e)));
> +
>         /*
>          * If the metadata doesn't fit, don't enable KASAN at all.
>          */
>         if (*size <=3D cache->kasan_info.alloc_meta_offset ||
>                         *size <=3D cache->kasan_info.free_meta_offset) {
> +               cache->kasan_info.alloc_meta_offset =3D 0;
> +               cache->kasan_info.free_meta_offset =3D 0;
>                 *size =3D orig_size;
>                 return;
>         }
> -#else
> -       *size =3D max(*size,
> -                       cache->object_size +
> -                       optimal_redzone(cache->object_size));
>
> -#endif
>         *flags |=3D SLAB_KASAN;
>  }
>
> --
> 2.7.3
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
