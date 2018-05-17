Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 287516B03AB
	for <linux-mm@kvack.org>; Thu, 17 May 2018 04:54:07 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id d199-v6so3170214vke.18
        for <linux-mm@kvack.org>; Thu, 17 May 2018 01:54:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p25-v6sor3332433uac.70.2018.05.17.01.54.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 01:54:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180516153434.24479-1-glider@google.com> <f8a737c1-8cb9-15e1-2d98-454a4cafc1ed@virtuozzo.com>
In-Reply-To: <f8a737c1-8cb9-15e1-2d98-454a4cafc1ed@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 17 May 2018 10:53:53 +0200
Message-ID: <CAG_fn=WfY6izR9OhCxm1JndgAeGxHgE2VNUAqDkG36O1-aTSrw@mail.gmail.com>
Subject: Re: [PATCH] lib/stackdepot.c: use a non-instrumented version of memcpy()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitriy Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 16, 2018 at 6:45 PM Andrey Ryabinin <aryabinin@virtuozzo.com>
wrote:

> On 05/16/2018 06:34 PM, Alexander Potapenko wrote:
> > stackdepot used to call memcpy(), which compiler tools normally
> > instrument, therefore every lookup used to unnecessarily call
instrumented
> > code.  This is somewhat ok in the case of KASAN, but under KMSAN a lot
of
> > time was spent in the instrumentation.
> >
> > (A similar change has been previously committed for memcmp())
> >
> > Signed-off-by: Alexander Potapenko <glider@google.com>
> > Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > ---
> >  lib/stackdepot.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/lib/stackdepot.c b/lib/stackdepot.c
> > index e513459a5601..d48c744fa750 100644
> > --- a/lib/stackdepot.c
> > +++ b/lib/stackdepot.c
> > @@ -140,7 +140,7 @@ static struct stack_record
*depot_alloc_stack(unsigned long *entries, int size,
> >       stack->handle.slabindex =3D depot_index;
> >       stack->handle.offset =3D depot_offset >> STACK_ALLOC_ALIGN;
> >       stack->handle.valid =3D 1;
> > -     memcpy(stack->entries, entries, size * sizeof(unsigned long));
> > +     __memcpy(stack->entries, entries, size * sizeof(unsigned long));

> This has no effect. Since the whole file is not instrumented memcpy
automagically replaced with __memcpy.
You're right, we just didn't have the code defining memcpy() to __memcpy()
in KMSAN. I'll fix that instead.


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
