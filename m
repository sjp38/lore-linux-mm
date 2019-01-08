Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2288E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:48:30 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id j123so1442327vsd.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:48:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p63sor44789028vsd.106.2019.01.08.01.48.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 01:48:28 -0800 (PST)
MIME-Version: 1.0
References: <20181211133453.2835077-1-arnd@arndb.de> <20190108022659.GA13470@flashbox>
 <CACT4Y+a_LB6aVoLEcFVJhP40D9E4MM3T=7-0aBhFvBffXgNZmw@mail.gmail.com>
In-Reply-To: <CACT4Y+a_LB6aVoLEcFVJhP40D9E4MM3T=7-0aBhFvBffXgNZmw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 8 Jan 2019 10:48:17 +0100
Message-ID: <CAG_fn=XQsZ5AHj2f10_xmOzb3PUeQgT52-0XLD-W6kAb8xx0sg@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Anders Roxell <anders.roxell@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nathan Chancellor <natechancellor@gmail.com>

On Tue, Jan 8, 2019 at 5:51 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Tue, Jan 8, 2019 at 3:27 AM Nathan Chancellor
> <natechancellor@gmail.com> wrote:
> >
> > On Tue, Dec 11, 2018 at 02:34:35PM +0100, Arnd Bergmann wrote:
> > > Building little-endian allmodconfig kernels on arm64 started failing
> > > with the generated atomic.h implementation, since we now try to call
> > > kasan helpers from the EFI stub:
> > >
> > > aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: i=
n function `atomic_set':
> > > include/generated/atomic-instrumented.h:44: undefined reference to `_=
_efistub_kasan_check_write'
> > >
> > > I suspect that we get similar problems in other files that explicitly
> > > disable KASAN for some reason but call atomic_t based helper function=
s.
> > >
> > > We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> > > that the compiler sets instead of checking CONFIG_KASAN, but this in =
turn
> > > requires a small hack in mm/kasan/common.c so we do see the extern
> > > declaration there instead of the inline function.
> > >
> > > Fixes: b1864b828644 ("locking/atomics: build atomic headers as requir=
ed")
> > > Reported-by: Anders Roxell <anders.roxell@linaro.org>
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Alexander Potapenko <glider@google.com>
> > > ---
> > >  include/linux/kasan-checks.h | 2 +-
> > >  mm/kasan/common.c            | 2 ++
> > >  2 files changed, 3 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-check=
s.h
> > > index d314150658a4..a61dc075e2ce 100644
> > > --- a/include/linux/kasan-checks.h
> > > +++ b/include/linux/kasan-checks.h
> > > @@ -2,7 +2,7 @@
> > >  #ifndef _LINUX_KASAN_CHECKS_H
> > >  #define _LINUX_KASAN_CHECKS_H
> > >
> > > -#ifdef CONFIG_KASAN
> > > +#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
> > >  void kasan_check_read(const volatile void *p, unsigned int size);
> > >  void kasan_check_write(const volatile void *p, unsigned int size);
> > >  #else
> > > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > > index 03d5d1374ca7..51a7932c33a3 100644
> > > --- a/mm/kasan/common.c
> > > +++ b/mm/kasan/common.c
> > > @@ -14,6 +14,8 @@
> > >   *
> > >   */
> > >
> > > +#define __KASAN_INTERNAL
> > > +
> > >  #include <linux/export.h>
> > >  #include <linux/interrupt.h>
> > >  #include <linux/init.h>
> > > --
> > > 2.20.0
> > >
> >
> > Hi all,
> >
> > Was there any other movement on this patch? I am noticing this fail as
> > well and I have applied this patch in the meantime; it would be nice fo=
r
> > it to be merged so I could drop it from my stack.
>
> Alexander, ping, you wanted to double-check re KMSAN asm
> instrumentation and then decide on a common approach for KASAN and
> KMSAN.

I like Arnd's approach and will do the same for KMSAN.
Arnd, please go ahead submitting your patch.
The only possible issue I'm anticipating is that in the future we may
want to disable the checks in non-KASAN code (e.g. in arch/ or mm/),
so __KASAN_INTERNAL may not be the best name, but that's up to you.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
