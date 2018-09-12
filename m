Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0EA38E0009
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:39:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m21-v6so3144958oic.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:39:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7-v6sor1608669oia.17.2018.09.12.10.39.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 10:39:58 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1535462971.git.andreyknvl@google.com> <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
 <CACT4Y+aEwYiaVN--RH_0VBh0wbCcrf-Ndz+_eOaBNi6nKxrfQA@mail.gmail.com>
In-Reply-To: <CACT4Y+aEwYiaVN--RH_0VBh0wbCcrf-Ndz+_eOaBNi6nKxrfQA@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 12 Sep 2018 19:39:30 +0200
Message-ID: <CAG48ez2oT1dtDcH8SfPLnoX5F8d6Pd=M-eOKHhYJ83EuL_j6wQ@mail.gmail.com>
Subject: Re: [PATCH v6 15/18] khwasan, arm64: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, dave.martin@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, geert@linux-m68k.org, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kstewart@linuxfoundation.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee.Smith@arm.com, Ramana.Radhakrishnan@arm.com, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, Mark Brand <markbrand@google.com>, cpandya@codeaurora.org, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 7:16 PM Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
[...]
> > +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
> > +{
> > +       bool recover = esr & KHWASAN_ESR_RECOVER;
> > +       bool write = esr & KHWASAN_ESR_WRITE;
> > +       size_t size = KHWASAN_ESR_SIZE(esr);
> > +       u64 addr = regs->regs[0];
> > +       u64 pc = regs->pc;
> > +
> > +       if (user_mode(regs))
> > +               return DBG_HOOK_ERROR;
> > +
> > +       kasan_report(addr, size, write, pc);
> > +
> > +       /*
> > +        * The instrumentation allows to control whether we can proceed after
> > +        * a crash was detected. This is done by passing the -recover flag to
> > +        * the compiler. Disabling recovery allows to generate more compact
> > +        * code.
> > +        *
> > +        * Unfortunately disabling recovery doesn't work for the kernel right
> > +        * now. KHWASAN reporting is disabled in some contexts (for example when
> > +        * the allocator accesses slab object metadata; same is true for KASAN;
> > +        * this is controlled by current->kasan_depth). All these accesses are
> > +        * detected by the tool, even though the reports for them are not
> > +        * printed.
> > +        *
> > +        * This is something that might be fixed at some point in the future.
> > +        */
> > +       if (!recover)
> > +               die("Oops - KHWASAN", regs, 0);
>
> Why die and not panic? Die seems to be much less used function, and it
> calls panic anyway, and we call panic in kasan_report if panic_on_warn
> is set.

die() is vaguely equivalent to BUG(); die() and BUG() normally only
terminate the current process, which may or may not leave the system
somewhat usable, while panic() always brings down the whole system.
AFAIK panic() shouldn't be used unless you're in some very low-level
code where you know that trying to just kill the current process can't
work and the entire system is broken beyond repair.

If KASAN traps on some random memory access, there's a good chance
that just killing the current process will allow at least parts of the
system to continue. I'm not sure whether BUG() or die() is more
appropriate here, but I think it definitely should not be a panic().
