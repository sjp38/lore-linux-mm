Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBD98E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:00:21 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so5033570itc.2
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:00:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor8324484itu.14.2018.12.12.02.00.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 02:00:20 -0800 (PST)
MIME-Version: 1.0
References: <20181211133453.2835077-1-arnd@arndb.de> <CACT4Y+bRzY9hO5b=TjHeXTsVVO1z3eBOHz6oLgBhVR4OSm1d1w@mail.gmail.com>
 <CAG_fn=U2d799W6GiujK4pedkLZr=LJrFrZhfCQ=Kin35quA76g@mail.gmail.com>
In-Reply-To: <CAG_fn=U2d799W6GiujK4pedkLZr=LJrFrZhfCQ=Kin35quA76g@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 12 Dec 2018 11:00:08 +0100
Message-ID: <CACT4Y+bEvJVAS+bdAS+p5SzX4DrfzvTSfV1qzH=BszpGjtoL6g@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, anders.roxell@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Dec 11, 2018 at 11:25 PM Alexander Potapenko <glider@google.com> wr=
ote:
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
> >
> >
> > Alexander, I think you are doing a similar thing for similar reasons
> > in KMSAN patch (see KMSAN_CHECK_ATOMIC_PARAMS):
> > https://github.com/google/kmsan/commit/17ebbfe19624c84adf79b0e5a74fd258=
c49ff12b
> > Namely, non-KMSAN-instrumented files must not get KMSAN callbacks from
> > atomics too.
> I'll need to double-check, but it occurs to me that we won't need
> additional hooks for atomics in KMSAN - the compiler instrumentation
> should suffice.

Compiler asm instrumentation will only insert conservative
initialization, but not checks of arguments, right?
I mean these checks are optional in the sense that it's only false
negatives, but since we already have them and they don't seem to lead
to false positives, why do we want to remove them?


> > Arnd patch does it the other way around: non-instrumented files need
> > to opt-in instead of opt-out.
> Shouldn't we put __SANITIZE_ADDRESS__ somewhere into mm/kasan/kasan.h the=
n?
> > Let's settle on a common way to do this, so that we can use it
> > consistently across all tools.
> >
> >
> >
> > > Fixes: b1864b828644 ("locking/atomics: build atomic headers as requir=
ed")
> > > Reported-by: Anders Roxell <anders.roxell@linaro.org>
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
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
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg
