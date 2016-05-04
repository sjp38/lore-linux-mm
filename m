Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35C7D6B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:34:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so42409844wme.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:34:07 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id nd10si2034779lbc.76.2016.05.04.01.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 01:34:06 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id j8so50879225lfd.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:34:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1462252403-1106-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1462252403-1106-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 4 May 2016 10:34:05 +0200
Message-ID: <CAG_fn=VwrB3sb9RvMdj0qnafnbNONASTpkxj0zSE7spdEVi7hw@mail.gmail.com>
Subject: Re: [PATCH for v4.6] lib/stackdepot: avoid to return 0 handle
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, May 3, 2016 at 7:13 AM,  <js1304@gmail.com> wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Recently, we allow to save the stacktrace whose hashed value is 0.
> It causes the problem that stackdepot could return 0 even if in success.
> User of stackdepot cannot distinguish whether it is success or not so we
> need to solve this problem. In this patch, 1 bit are added to handle
> and make valid handle none 0 by setting this bit. After that, valid handl=
e
> will not be 0 and 0 handle will represent failure correctly.
Returning success or failure doesn't require a special bit, we can
just make depot_alloc_stack() return a boolean value.
If I'm understanding correctly, your primary intention is to reserve
an invalid handle value that will never collide with valid handles
returned in the future.
Can you reflect this in the description?
> Fixes: 33334e25769c ("lib/stackdepot.c: allow the stack trace hash
> to be zero")
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  lib/stackdepot.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> index 9e0b031..53ad6c0 100644
> --- a/lib/stackdepot.c
> +++ b/lib/stackdepot.c
> @@ -42,12 +42,14 @@
>
>  #define DEPOT_STACK_BITS (sizeof(depot_stack_handle_t) * 8)
>
> +#define STACK_ALLOC_NULL_PROTECTION_BITS 1
>  #define STACK_ALLOC_ORDER 2 /* 'Slab' size order for stack depot, 4 page=
s */
>  #define STACK_ALLOC_SIZE (1LL << (PAGE_SHIFT + STACK_ALLOC_ORDER))
>  #define STACK_ALLOC_ALIGN 4
>  #define STACK_ALLOC_OFFSET_BITS (STACK_ALLOC_ORDER + PAGE_SHIFT - \
>                                         STACK_ALLOC_ALIGN)
> -#define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - STACK_ALLOC_OFFSET_BI=
TS)
> +#define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - \
> +               STACK_ALLOC_NULL_PROTECTION_BITS - STACK_ALLOC_OFFSET_BIT=
S)
>  #define STACK_ALLOC_SLABS_CAP 1024
>  #define STACK_ALLOC_MAX_SLABS \
>         (((1LL << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
> @@ -59,6 +61,7 @@ union handle_parts {
>         struct {
>                 u32 slabindex : STACK_ALLOC_INDEX_BITS;
>                 u32 offset : STACK_ALLOC_OFFSET_BITS;
> +               u32 valid : STACK_ALLOC_NULL_PROTECTION_BITS;
>         };
>  };
>
> @@ -136,6 +139,7 @@ static struct stack_record *depot_alloc_stack(unsigne=
d long *entries, int size,
>         stack->size =3D size;
>         stack->handle.slabindex =3D depot_index;
>         stack->handle.offset =3D depot_offset >> STACK_ALLOC_ALIGN;
> +       stack->handle.valid =3D 1;
>         memcpy(stack->entries, entries, size * sizeof(unsigned long));
>         depot_offset +=3D required_size;
>
> --
> 1.9.1
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
