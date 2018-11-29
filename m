Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3F1A6B53DD
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:01:21 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id z14so1421908oig.17
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:01:21 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c13si1187166otm.200.2018.11.29.10.01.20
        for <linux-mm@kvack.org>;
        Thu, 29 Nov 2018 10:01:20 -0800 (PST)
Date: Thu, 29 Nov 2018 18:01:38 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v12 20/25] kasan, arm64: add brk handler for inline
 instrumentation
Message-ID: <20181129180138.GB4318@arm.com>
References: <cover.1543337629.git.andreyknvl@google.com>
 <e825441eda1dbbbb7f583f826a66c94e6f88316a.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e825441eda1dbbbb7f583f826a66c94e6f88316a.1543337629.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Tue, Nov 27, 2018 at 05:55:38PM +0100, Andrey Konovalov wrote:
> Tag-based KASAN inline instrumentation mode (which embeds checks of shadow
> memory into the generated code, instead of inserting a callback) generates
> a brk instruction when a tag mismatch is detected.
> 
> This commit adds a tag-based KASAN specific brk handler, that decodes the
> immediate value passed to the brk instructions (to extract information
> about the memory access that triggered the mismatch), reads the register
> values (x0 contains the guilty address) and reports the bug.
> 
> Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/include/asm/brk-imm.h |  2 +
>  arch/arm64/kernel/traps.c        | 68 +++++++++++++++++++++++++++++++-
>  include/linux/kasan.h            |  3 ++
>  3 files changed, 71 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/brk-imm.h b/arch/arm64/include/asm/brk-imm.h
> index ed693c5bcec0..2945fe6cd863 100644
> --- a/arch/arm64/include/asm/brk-imm.h
> +++ b/arch/arm64/include/asm/brk-imm.h
> @@ -16,10 +16,12 @@
>   * 0x400: for dynamic BRK instruction
>   * 0x401: for compile time BRK instruction
>   * 0x800: kernel-mode BUG() and WARN() traps
> + * 0x9xx: tag-based KASAN trap (allowed values 0x900 - 0x9ff)
>   */
>  #define FAULT_BRK_IMM			0x100
>  #define KGDB_DYN_DBG_BRK_IMM		0x400
>  #define KGDB_COMPILED_DBG_BRK_IMM	0x401
>  #define BUG_BRK_IMM			0x800
> +#define KASAN_BRK_IMM			0x900
>  
>  #endif
> diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
> index 5f4d9acb32f5..04bdc53716ef 100644
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
> @@ -284,10 +285,14 @@ void arm64_notify_die(const char *str, struct pt_regs *regs,
>  	}
>  }
>  
> -void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +void __arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
>  {
>  	regs->pc += size;
> +}
>  
> +void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
> +{
> +	__arm64_skip_faulting_instruction(regs, size);
>  	/*
>  	 * If we were single stepping, we want to get the step exception after
>  	 * we return from the trap.
> @@ -959,7 +964,7 @@ static int bug_handler(struct pt_regs *regs, unsigned int esr)
>  	}
>  
>  	/* If thread survives, skip over the BUG instruction and continue: */
> -	arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
> +	__arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);

Why do you want to avoid the single-step logic here? Given that we're
skipping over the brk instruction, why wouldn't you want that to trigger
a step exception if single-step is enabled?

Will
