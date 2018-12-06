Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6BB6B7970
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:19:17 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id g7so310089itg.7
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:19:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y136sor469679itb.13.2018.12.06.02.19.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 02:19:16 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543337629.git.andreyknvl@google.com> <20728567aae93b5eb88a6636c94c1af73db7cdbc.1543337629.git.andreyknvl@google.com>
 <CAMo8BfK5aEGae--xvboLxMXTe1orA7kmLR_uFNCqC6M-a=Om5Q@mail.gmail.com>
In-Reply-To: <CAMo8BfK5aEGae--xvboLxMXTe1orA7kmLR_uFNCqC6M-a=Om5Q@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 6 Dec 2018 11:19:04 +0100
Message-ID: <CAAeHK+zprEaJMexWRZj1QbuygL0dOC5LqJRok8cairfLw=VVvw@mail.gmail.com>
Subject: Re: [PATCH v12 05/25] kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Tue, Dec 4, 2018 at 11:24 PM Max Filippov <jcmvbkbc@gmail.com> wrote:
>
> Hello,
>
> On Tue, Nov 27, 2018 at 9:00 AM Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> > This commit splits the current CONFIG_KASAN config option into two:
> > 1. CONFIG_KASAN_GENERIC, that enables the generic KASAN mode (the one
> >    that exists now);
> > 2. CONFIG_KASAN_SW_TAGS, that enables the software tag-based KASAN mode.
>
> [...]
>
> > --- a/lib/Kconfig.kasan
> > +++ b/lib/Kconfig.kasan
> > @@ -1,35 +1,95 @@
> > +# This config refers to the generic KASAN mode.
> >  config HAVE_ARCH_KASAN
> >         bool
> >
> > +config HAVE_ARCH_KASAN_SW_TAGS
> > +       bool
> > +
> > +config CC_HAS_KASAN_GENERIC
> > +       def_bool $(cc-option, -fsanitize=kernel-address)
> > +
> > +config CC_HAS_KASAN_SW_TAGS
> > +       def_bool $(cc-option, -fsanitize=kernel-hwaddress)
> > +
> >  if HAVE_ARCH_KASAN
> >
> >  config KASAN
> > -       bool "KASan: runtime memory debugger"
> > +       bool "KASAN: runtime memory debugger"
> > +       help
> > +         Enables KASAN (KernelAddressSANitizer) - runtime memory debugger,
> > +         designed to find out-of-bounds accesses and use-after-free bugs.
> > +         See Documentation/dev-tools/kasan.rst for details.
>
> Perhaps KASAN should depend on
> CC_HAS_KASAN_GENERIC || CC_HAS_KASAN_SW_TAGS,
> otherwise make all*config may enable KASAN
> for a compiler that does not have any -fsanitize=kernel-*address
> support, resulting in build failures like this:
>   http://kisskb.ellerman.id.au/kisskb/buildresult/13606170/log/

Will fix in v13, thanks!

>
> --
> Thanks.
> -- Max
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/CAMo8BfK5aEGae--xvboLxMXTe1orA7kmLR_uFNCqC6M-a%3DOm5Q%40mail.gmail.com.
> For more options, visit https://groups.google.com/d/optout.
