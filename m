Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 268698E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 15:12:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e62-v6so14125565itb.3
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 12:12:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3-v6sor9427664iog.108.2018.09.17.12.12.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Sep 2018 12:12:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZwLnk7V1cY-EAHbrfXPBxs6qyynZPhxoSKZZDWSK8Fuw@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
 <CACT4Y+ZwLnk7V1cY-EAHbrfXPBxs6qyynZPhxoSKZZDWSK8Fuw@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 17 Sep 2018 21:12:00 +0200
Message-ID: <CAAeHK+wVgmp2G63c5w4sMH1i97Ju-YW7RUQgOQjr5d8aMgh1EQ@mail.gmail.com>
Subject: Re: [PATCH v6 15/18] khwasan, arm64: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Sep 12, 2018 at 7:13 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>> +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
>> +{
>> +       bool recover = esr & KHWASAN_ESR_RECOVER;
>> +       bool write = esr & KHWASAN_ESR_WRITE;
>> +       size_t size = KHWASAN_ESR_SIZE(esr);
>> +       u64 addr = regs->regs[0];
>> +       u64 pc = regs->pc;
>> +
>> +       if (user_mode(regs))
>> +               return DBG_HOOK_ERROR;
>> +
>> +       kasan_report(addr, size, write, pc);
>> +
>> +       /*
>> +        * The instrumentation allows to control whether we can proceed after
>> +        * a crash was detected. This is done by passing the -recover flag to
>> +        * the compiler. Disabling recovery allows to generate more compact
>> +        * code.
>> +        *
>> +        * Unfortunately disabling recovery doesn't work for the kernel right
>> +        * now. KHWASAN reporting is disabled in some contexts (for example when
>> +        * the allocator accesses slab object metadata; same is true for KASAN;
>> +        * this is controlled by current->kasan_depth). All these accesses are
>> +        * detected by the tool, even though the reports for them are not
>> +        * printed.
>
>
> I am not following this part.
> Slab accesses metadata. OK.
> This is detected as bad access. OK.
> Report is not printed. OK.
> We skip BRK and resume execution.
> What is the problem?

When the kernel is compiled with -fsanitize=kernel-hwaddress without
any additional flags (like it's done now with KASAN_HW) everything
works as you described and there's no problem. However if one were to
recompile the kernel with hwasan recovery disabled, KHWASAN wouldn't
work due to the reasons described in the comment. Should I make it
more clear?

>
>
>
>> +        *
>> +        * This is something that might be fixed at some point in the future.
>> +        */
>> +       if (!recover)
>> +               die("Oops - KHWASAN", regs, 0);
