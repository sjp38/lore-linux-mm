Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFA308E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:16:02 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e62-v6so4559833itb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:16:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20-v6sor948464jan.144.2018.09.12.10.16.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 10:16:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
References: <cover.1535462971.git.andreyknvl@google.com> <f5e73b5ead3355932ad8b5fc96b141c3f5b8c16c.1535462971.git.andreyknvl@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 12 Sep 2018 19:15:39 +0200
Message-ID: <CACT4Y+aEwYiaVN--RH_0VBh0wbCcrf-Ndz+_eOaBNi6nKxrfQA@mail.gmail.com>
Subject: Re: [PATCH v6 15/18] khwasan, arm64: add brk handler for inline instrumentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> KHWASAN inline instrumentation mode (which embeds checks of shadow memory
> into the generated code, instead of inserting a callback) generates a brk
> instruction when a tag mismatch is detected.
>
> This commit add a KHWASAN brk handler, that decodes the immediate value
> passed to the brk instructions (to extract information about the memory
> access that triggered the mismatch), reads the register values (x0 contains
> the guilty address) and reports the bug.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/include/asm/brk-imm.h |  2 +
>  arch/arm64/kernel/traps.c        | 69 +++++++++++++++++++++++++++++++-
>  2 files changed, 69 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm64/include/asm/brk-imm.h b/arch/arm64/include/asm/brk-imm.h
> index ed693c5bcec0..e4a7013321dc 100644
> --- a/arch/arm64/include/asm/brk-imm.h
> +++ b/arch/arm64/include/asm/brk-imm.h
> @@ -16,10 +16,12 @@
>   * 0x400: for dynamic BRK instruction
>   * 0x401: for compile time BRK instruction
>   * 0x800: kernel-mode BUG() and WARN() traps
> + * 0x9xx: KHWASAN trap (allowed values 0x900 - 0x9ff)
>   */
>  #define FAULT_BRK_IMM                  0x100
>  #define KGDB_DYN_DBG_BRK_IMM           0x400
>  #define KGDB_COMPILED_DBG_BRK_IMM      0x401
>  #define BUG_BRK_IMM                    0x800
> +#define KHWASAN_BRK_IMM                        0x900
>
>  #endif
> diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
> index 039e9ff379cc..fd70347d1ce7 100644
> --- a/arch/arm64/kernel/traps.c
> +++ b/arch/arm64/kernel/traps.c
> @@ -35,6 +35,7 @@
>  #include <linux/sizes.h>
>  #include <linux/syscalls.h>
>  #include <linux/mm_types.h>
> +#include <linux/kasan.h>
>
>  #include <asm/atomic.h>
>  #include <asm/bug.h>
> @@ -269,10 +270,14 @@ void arm64_notify_die(const char *str, struct pt_regs *regs,
>         }
>  }
>
> -void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +void __arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
>  {
>         regs->pc += size;
> +}
>
> +void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +{
> +       __arm64_skip_faulting_instruction(regs, size);
>         /*
>          * If we were single stepping, we want to get the step exception after
>          * we return from the trap.
> @@ -775,7 +780,7 @@ static int bug_handler(struct pt_regs *regs, unsigned int esr)
>         }
>
>         /* If thread survives, skip over the BUG instruction and continue: */
> -       arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
> +       __arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
>         return DBG_HOOK_HANDLED;
>  }
>
> @@ -785,6 +790,59 @@ static struct break_hook bug_break_hook = {
>         .fn = bug_handler,
>  };
>
> +#ifdef CONFIG_KASAN_HW
> +
> +#define KHWASAN_ESR_RECOVER    0x20
> +#define KHWASAN_ESR_WRITE      0x10
> +#define KHWASAN_ESR_SIZE_MASK  0x0f
> +#define KHWASAN_ESR_SIZE(esr)  (1 << ((esr) & KHWASAN_ESR_SIZE_MASK))
> +
> +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
> +{
> +       bool recover = esr & KHWASAN_ESR_RECOVER;
> +       bool write = esr & KHWASAN_ESR_WRITE;
> +       size_t size = KHWASAN_ESR_SIZE(esr);
> +       u64 addr = regs->regs[0];
> +       u64 pc = regs->pc;
> +
> +       if (user_mode(regs))
> +               return DBG_HOOK_ERROR;
> +
> +       kasan_report(addr, size, write, pc);
> +
> +       /*
> +        * The instrumentation allows to control whether we can proceed after
> +        * a crash was detected. This is done by passing the -recover flag to
> +        * the compiler. Disabling recovery allows to generate more compact
> +        * code.
> +        *
> +        * Unfortunately disabling recovery doesn't work for the kernel right
> +        * now. KHWASAN reporting is disabled in some contexts (for example when
> +        * the allocator accesses slab object metadata; same is true for KASAN;
> +        * this is controlled by current->kasan_depth). All these accesses are
> +        * detected by the tool, even though the reports for them are not
> +        * printed.
> +        *
> +        * This is something that might be fixed at some point in the future.
> +        */
> +       if (!recover)
> +               die("Oops - KHWASAN", regs, 0);

Why die and not panic? Die seems to be much less used function, and it
calls panic anyway, and we call panic in kasan_report if panic_on_warn
is set.

> +       /* If thread survives, skip over the brk instruction and continue: */
> +       __arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
> +       return DBG_HOOK_HANDLED;
> +}
> +
> +#define KHWASAN_ESR_VAL (0xf2000000 | KHWASAN_BRK_IMM)
> +#define KHWASAN_ESR_MASK 0xffffff00
> +
> +static struct break_hook khwasan_break_hook = {
> +       .esr_val = KHWASAN_ESR_VAL,
> +       .esr_mask = KHWASAN_ESR_MASK,
> +       .fn = khwasan_handler,
> +};
> +#endif
> +
>  /*
>   * Initial handler for AArch64 BRK exceptions
>   * This handler only used until debug_traps_init().
> @@ -792,6 +850,10 @@ static struct break_hook bug_break_hook = {
>  int __init early_brk64(unsigned long addr, unsigned int esr,
>                 struct pt_regs *regs)
>  {
> +#ifdef CONFIG_KASAN_HW
> +       if ((esr & KHWASAN_ESR_MASK) == KHWASAN_ESR_VAL)
> +               return khwasan_handler(regs, esr) != DBG_HOOK_HANDLED;
> +#endif
>         return bug_handler(regs, esr) != DBG_HOOK_HANDLED;
>  }
>
> @@ -799,4 +861,7 @@ int __init early_brk64(unsigned long addr, unsigned int esr,
>  void __init trap_init(void)
>  {
>         register_break_hook(&bug_break_hook);
> +#ifdef CONFIG_KASAN_HW
> +       register_break_hook(&khwasan_break_hook);
> +#endif
>  }
> --
> 2.19.0.rc0.228.g281dcd1b4d0-goog
>
