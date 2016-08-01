Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69C2A6B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:47:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so76794942lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:47:16 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id s129si14583006lfd.333.2016.08.01.07.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 07:47:14 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id b199so117417761lfe.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:47:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470062715-14077-3-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com> <1470062715-14077-3-git-send-email-aryabinin@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 1 Aug 2016 16:47:13 +0200
Message-ID: <CAG_fn=Xm9aZ0tsritE3uD3ucNUkWaVLCX-=Wyf_wGC1HTV_EqQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] mm/kasan, slub: don't disable interrupts when object
 leaves quarantine
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Aug 1, 2016 at 4:45 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> SLUB doesn't require disabled interrupts to call ___cache_free().
>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Alexander Potapenko <glider@google.com>
> ---
>  mm/kasan/quarantine.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
> index 65793f1..4852625 100644
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -147,10 +147,14 @@ static void qlink_free(struct qlist_node *qlink, st=
ruct kmem_cache *cache)
>         struct kasan_alloc_meta *alloc_info =3D get_alloc_info(cache, obj=
ect);
>         unsigned long flags;
>
> -       local_irq_save(flags);
> +       if (IS_ENABLED(CONFIG_SLAB))
> +               local_irq_save(flags);
> +
>         alloc_info->state =3D KASAN_STATE_FREE;
>         ___cache_free(cache, object, _THIS_IP_);
> -       local_irq_restore(flags);
> +
> +       if (IS_ENABLED(CONFIG_SLAB))
> +               local_irq_restore(flags);
>  }
>
>  static void qlist_free_all(struct qlist_head *q, struct kmem_cache *cach=
e)
> --
> 2.7.3
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/1470062715-14077-3-git-send-email-aryabinin%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.



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
