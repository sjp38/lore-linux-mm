Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F37598E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:09:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so3227321pfh.11
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:09:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k83-v6sor789580pfg.55.2018.09.13.11.09.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 11:09:52 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1535462971.git.andreyknvl@google.com> <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
 <CACT4Y+aEwYiaVN--RH_0VBh0wbCcrf-Ndz+_eOaBNi6nKxrfQA@mail.gmail.com>
 <CAG48ez2oT1dtDcH8SfPLnoX5F8d6Pd=M-eOKHhYJ83EuL_j6wQ@mail.gmail.com> <CACT4Y+avu_68GoQcc32zpcOpAu-Pw7m71VmuKtEkOw=vKgxi7w@mail.gmail.com>
In-Reply-To: <CACT4Y+avu_68GoQcc32zpcOpAu-Pw7m71VmuKtEkOw=vKgxi7w@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Thu, 13 Sep 2018 11:09:39 -0700
Message-ID: <CAKwvOdns=3bktpXLEpo6o0J8OQPym6YE+x6Dvs_kYSBsuJKtSw@mail.gmail.com>
Subject: Re: [PATCH v6 15/18] khwasan, arm64: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Jann Horn <jannh@google.com>, Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg KH <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Thu, Sep 13, 2018 at 1:37 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Wed, Sep 12, 2018 at 7:39 PM, Jann Horn <jannh@google.com> wrote:
> > On Wed, Sep 12, 2018 at 7:16 PM Dmitry Vyukov <dvyukov@google.com> wrote:
> >> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > [...]
> >> > +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
> >> > +{
> >> > +       bool recover = esr & KHWASAN_ESR_RECOVER;
> >> > +       bool write = esr & KHWASAN_ESR_WRITE;
> >> > +       size_t size = KHWASAN_ESR_SIZE(esr);
> >> > +       u64 addr = regs->regs[0];
> >> > +       u64 pc = regs->pc;
> >> > +
> >> > +       if (user_mode(regs))
> >> > +               return DBG_HOOK_ERROR;
> >> > +
> >> > +       kasan_report(addr, size, write, pc);
> >> > +
> >> > +       /*
> >> > +        * The instrumentation allows to control whether we can proceed after
> >> > +        * a crash was detected. This is done by passing the -recover flag to
> >> > +        * the compiler. Disabling recovery allows to generate more compact
> >> > +        * code.
> >> > +        *
> >> > +        * Unfortunately disabling recovery doesn't work for the kernel right
> >> > +        * now. KHWASAN reporting is disabled in some contexts (for example when
> >> > +        * the allocator accesses slab object metadata; same is true for KASAN;
> >> > +        * this is controlled by current->kasan_depth). All these accesses are
> >> > +        * detected by the tool, even though the reports for them are not
> >> > +        * printed.
> >> > +        *
> >> > +        * This is something that might be fixed at some point in the future.
> >> > +        */
> >> > +       if (!recover)
> >> > +               die("Oops - KHWASAN", regs, 0);
> >>
> >> Why die and not panic? Die seems to be much less used function, and it
> >> calls panic anyway, and we call panic in kasan_report if panic_on_warn
> >> is set.
> >
> > die() is vaguely equivalent to BUG(); die() and BUG() normally only
> > terminate the current process, which may or may not leave the system
> > somewhat usable, while panic() always brings down the whole system.
> > AFAIK panic() shouldn't be used unless you're in some very low-level
> > code where you know that trying to just kill the current process can't
> > work and the entire system is broken beyond repair.
> >
> > If KASAN traps on some random memory access, there's a good chance
> > that just killing the current process will allow at least parts of the
> > system to continue. I'm not sure whether BUG() or die() is more
> > appropriate here, but I think it definitely should not be a panic().
>
>
> Nick, do you know if die() will be enough to catch problems on Android
> phones? panic_on_warn would turn this into panic, but I guess one does
> not want panic_on_warn on a canary phone.

die() has arch specific implementations, so looking at:

arch/arm64/kernel/traps.c:196#die

it looks like panic is invoked if in_interrupt() or panic_on_oops(),
which is a configure option.  So maybe the config for KHWASAN should
also enable that? Otherwise seems easy to forget.  But maybe that
should remain configurable separately?

Looking at the kernel configs for the Pixel 2, it does seem like
CONFIG_PANIC_ON_OOPS=y is already enabled.
https://android.googlesource.com/kernel/msm/+/android-msm-wahoo-4.4-pie/arch/arm64/configs/wahoo_defconfig#746

Specifically to catch problems on Android, our internal debug builds
can report on panics, but not oops, IIUC.
-- 
Thanks,
~Nick Desaulniers
