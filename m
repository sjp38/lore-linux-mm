Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id D66638E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:25:42 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id y139so8703533vsc.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:25:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor8693498vsq.95.2018.12.11.14.25.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 14:25:41 -0800 (PST)
MIME-Version: 1.0
References: <20181211133453.2835077-1-arnd@arndb.de> <CACT4Y+bRzY9hO5b=TjHeXTsVVO1z3eBOHz6oLgBhVR4OSm1d1w@mail.gmail.com>
In-Reply-To: <CACT4Y+bRzY9hO5b=TjHeXTsVVO1z3eBOHz6oLgBhVR4OSm1d1w@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 11 Dec 2018 23:25:28 +0100
Message-ID: <CAG_fn=U2d799W6GiujK4pedkLZr=LJrFrZhfCQ=Kin35quA76g@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitriy Vyukov <dvyukov@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, anders.roxell@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Dec 11, 2018 at 2:45 PM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Tue, Dec 11, 2018 at 2:35 PM Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > Building little-endian allmodconfig kernels on arm64 started failing
> > with the generated atomic.h implementation, since we now try to call
> > kasan helpers from the EFI stub:
> >
> > aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in =
function `atomic_set':
> > include/generated/atomic-instrumented.h:44: undefined reference to `__e=
fistub_kasan_check_write'
> >
> > I suspect that we get similar problems in other files that explicitly
> > disable KASAN for some reason but call atomic_t based helper functions.
> >
> > We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> > that the compiler sets instead of checking CONFIG_KASAN, but this in tu=
rn
> > requires a small hack in mm/kasan/common.c so we do see the extern
> > declaration there instead of the inline function.
>
>
> Alexander, I think you are doing a similar thing for similar reasons
> in KMSAN patch (see KMSAN_CHECK_ATOMIC_PARAMS):
> https://github.com/google/kmsan/commit/17ebbfe19624c84adf79b0e5a74fd258c4=
9ff12b
> Namely, non-KMSAN-instrumented files must not get KMSAN callbacks from
> atomics too.
I'll need to double-check, but it occurs to me that we won't need
additional hooks for atomics in KMSAN - the compiler instrumentation
should suffice.

> Arnd patch does it the other way around: non-instrumented files need
> to opt-in instead of opt-out.
Shouldn't we put __SANITIZE_ADDRESS__ somewhere into mm/kasan/kasan.h then?
> Let's settle on a common way to do this, so that we can use it
> consistently across all tools.
>
>
>
> > Fixes: b1864b828644 ("locking/atomics: build atomic headers as required=
")
> > Reported-by: Anders Roxell <anders.roxell@linaro.org>
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  include/linux/kasan-checks.h | 2 +-
> >  mm/kasan/common.c            | 2 ++
> >  2 files changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.=
h
> > index d314150658a4..a61dc075e2ce 100644
> > --- a/include/linux/kasan-checks.h
> > +++ b/include/linux/kasan-checks.h
> > @@ -2,7 +2,7 @@
> >  #ifndef _LINUX_KASAN_CHECKS_H
> >  #define _LINUX_KASAN_CHECKS_H
> >
> > -#ifdef CONFIG_KASAN
> > +#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
> >  void kasan_check_read(const volatile void *p, unsigned int size);
> >  void kasan_check_write(const volatile void *p, unsigned int size);
> >  #else
> > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > index 03d5d1374ca7..51a7932c33a3 100644
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -14,6 +14,8 @@
> >   *
> >   */
> >
> > +#define __KASAN_INTERNAL
> > +
> >  #include <linux/export.h>
> >  #include <linux/interrupt.h>
> >  #include <linux/init.h>
> > --
> > 2.20.0
> >



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
