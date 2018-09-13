Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 098578E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 04:37:23 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id q5-v6so7545056ith.1
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 01:37:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 68-v6sor1996509jaf.94.2018.09.13.01.37.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 01:37:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG48ez2oT1dtDcH8SfPLnoX5F8d6Pd=M-eOKHhYJ83EuL_j6wQ@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
 <CACT4Y+aEwYiaVN--RH_0VBh0wbCcrf-Ndz+_eOaBNi6nKxrfQA@mail.gmail.com> <CAG48ez2oT1dtDcH8SfPLnoX5F8d6Pd=M-eOKHhYJ83EuL_j6wQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 13 Sep 2018 10:37:00 +0200
Message-ID: <CACT4Y+avu_68GoQcc32zpcOpAu-Pw7m71VmuKtEkOw=vKgxi7w@mail.gmail.com>
Subject: Re: [PATCH v6 15/18] khwasan, arm64: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 7:39 PM, Jann Horn <jannh@google.com> wrote:
> On Wed, Sep 12, 2018 at 7:16 PM Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> [...]
>> > +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
>> > +{
>> > +       bool recover = esr & KHWASAN_ESR_RECOVER;
>> > +       bool write = esr & KHWASAN_ESR_WRITE;
>> > +       size_t size = KHWASAN_ESR_SIZE(esr);
>> > +       u64 addr = regs->regs[0];
>> > +       u64 pc = regs->pc;
>> > +
>> > +       if (user_mode(regs))
>> > +               return DBG_HOOK_ERROR;
>> > +
>> > +       kasan_report(addr, size, write, pc);
>> > +
>> > +       /*
>> > +        * The instrumentation allows to control whether we can proceed after
>> > +        * a crash was detected. This is done by passing the -recover flag to
>> > +        * the compiler. Disabling recovery allows to generate more compact
>> > +        * code.
>> > +        *
>> > +        * Unfortunately disabling recovery doesn't work for the kernel right
>> > +        * now. KHWASAN reporting is disabled in some contexts (for example when
>> > +        * the allocator accesses slab object metadata; same is true for KASAN;
>> > +        * this is controlled by current->kasan_depth). All these accesses are
>> > +        * detected by the tool, even though the reports for them are not
>> > +        * printed.
>> > +        *
>> > +        * This is something that might be fixed at some point in the future.
>> > +        */
>> > +       if (!recover)
>> > +               die("Oops - KHWASAN", regs, 0);
>>
>> Why die and not panic? Die seems to be much less used function, and it
>> calls panic anyway, and we call panic in kasan_report if panic_on_warn
>> is set.
>
> die() is vaguely equivalent to BUG(); die() and BUG() normally only
> terminate the current process, which may or may not leave the system
> somewhat usable, while panic() always brings down the whole system.
> AFAIK panic() shouldn't be used unless you're in some very low-level
> code where you know that trying to just kill the current process can't
> work and the entire system is broken beyond repair.
>
> If KASAN traps on some random memory access, there's a good chance
> that just killing the current process will allow at least parts of the
> system to continue. I'm not sure whether BUG() or die() is more
> appropriate here, but I think it definitely should not be a panic().


Nick, do you know if die() will be enough to catch problems on Android
phones? panic_on_warn would turn this into panic, but I guess one does
not want panic_on_warn on a canary phone.
