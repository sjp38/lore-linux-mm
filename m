Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB4D76B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:03:27 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r69so12607390ioe.20
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 06:03:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j64sor451930iof.281.2018.03.27.06.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 06:03:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180326093241.lba7k4pdjskr4gsv@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <f22726f1f4343a091f263edd4c988f12b414c752.1520017438.git.andreyknvl@google.com>
 <20180305145111.bbycnzpgzkir2dz4@lakrids.cambridge.arm.com>
 <CAAeHK+zHfgSfZtKhOnfFVa35uB=PSsPiN65BDd9RVNK63f_G0w@mail.gmail.com> <20180326093241.lba7k4pdjskr4gsv@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 27 Mar 2018 15:03:21 +0200
Message-ID: <CAAeHK+xxmPBjw+DzL5sHk5qGiFZmuWT9CN8unjoTzrgvDw1j-Q@mail.gmail.com>
Subject: Re: [RFC PATCH 11/14] khwasan: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Mar 26, 2018 at 11:36 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 23, 2018 at 04:59:36PM +0100, Andrey Konovalov wrote:
>> I saw BUG handler using this (which also inserts a brk), so I used it
>> as well.
>
> Ah; I think that's broken today.
>
>> What should I do instead to jump over the faulting brk instruction?
>
> I don't think we have anything to do this properly today.
>
> The simplest fix would be to split arm64_skip_faulting_instruction()
> into separate functions for user/kernel, something like the below.

OK, will do that!

>
> It would be nice to drop _user_ in the name of the userspace-specific
> helper, though.

I'm not familiar with the code, but having "user" in a
userspace-specific function name sounds logical :) I think I'm not
going to include this change, and it probably needs to be done in a
separate patch/patchset anyway.

>
> Thanks
> Mark.
>
> ---->8----
> diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
> index eb2d15147e8d..101e3d4ed6c8 100644
> --- a/arch/arm64/kernel/traps.c
> +++ b/arch/arm64/kernel/traps.c
> @@ -235,9 +235,14 @@ void arm64_notify_die(const char *str, struct pt_regs *regs,
>         }
>  }
>
> -void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +void __arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
>  {
>         regs->pc += size;
> +}
> +
> +void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +{
> +       __arm64_skip_faulting_instruction(regs, size);
>
>         /*
>          * If we were single stepping, we want to get the step exception after
> @@ -761,7 +766,7 @@ static int bug_handler(struct pt_regs *regs, unsigned int esr)
>         }
>
>         /* If thread survives, skip over the BUG instruction and continue: */
> -       arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
> +       __arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
>         return DBG_HOOK_HANDLED;
>  }
>
>
