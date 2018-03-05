Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC1636B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:51:24 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id i28so3260521otf.21
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:51:24 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 145si3709693oia.79.2018.03.05.06.51.23
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 06:51:23 -0800 (PST)
Date: Mon, 5 Mar 2018 14:51:12 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 11/14] khwasan: add brk handler for inline
 instrumentation
Message-ID: <20180305145111.bbycnzpgzkir2dz4@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <f22726f1f4343a091f263edd4c988f12b414c752.1520017438.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f22726f1f4343a091f263edd4c988f12b414c752.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 02, 2018 at 08:44:30PM +0100, Andrey Konovalov wrote:
> KHWASAN inline instrumentation mode (which embeds checks of shadow memory
> into the generated code, instead of inserting a callback) generates a brk
> instruction when a tag mismatch is detected.

The compiler generates the BRK?

I'm a little worried about the ABI implications of that. So far we've
assumed that for hte kernel-side, the BRK space is completely under our
control.

How much does this save, compared to having a callback?

> This commit add a KHWASAN brk handler, that decodes the immediate value
> passed to the brk instructions (to extract information about the memory
> access that triggered the mismatch), reads the register values (x0 contains
> the guilty address) and reports the bug.
> ---
>  arch/arm64/include/asm/brk-imm.h |  2 ++
>  arch/arm64/kernel/traps.c        | 40 ++++++++++++++++++++++++++++++++
>  2 files changed, 42 insertions(+)
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
>  #define FAULT_BRK_IMM			0x100
>  #define KGDB_DYN_DBG_BRK_IMM		0x400
>  #define KGDB_COMPILED_DBG_BRK_IMM	0x401
>  #define BUG_BRK_IMM			0x800
> +#define KHWASAN_BRK_IMM			0x900
>  
>  #endif
> diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
> index eb2d15147e8d..5df8cdf5af13 100644
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
> @@ -771,6 +772,38 @@ static struct break_hook bug_break_hook = {
>  	.fn = bug_handler,
>  };
>  
> +#ifdef CONFIG_KASAN_TAGS
> +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
> +{
> +	bool recover = esr & 0x20;
> +	bool write = esr & 0x10;

Can you please add mnemonics for these, e.g.

#define KHWASAN_ESR_RECOVER		0x20
#define KHWASAN_ESR_WRITE		0x10

> +	size_t size = 1 << (esr & 0xf);

#define KHWASAN_ESR_SIZE_MASK		0x4
#define KHWASAN_ESR_SIZE(esr)	(1 << (esr) & KHWASAN_ESR_SIZE_MASK)

> +	u64 addr = regs->regs[0];
> +	u64 pc = regs->pc;
> +
> +	if (user_mode(regs))
> +		return DBG_HOOK_ERROR;
> +
> +	khwasan_report(addr, size, write, pc);
> +
> +	if (!recover)
> +		die("Oops - KHWASAN", regs, 0);

Could you elaborate on what "recover" means, and why it's up the the
compiler to decide if the kernel should die()?

> +
> +	/* If thread survives, skip over the BUG instruction and continue: */
> +	arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);

This is for fast-forwarding user instruction streams, and isn't correct
to call for kernel faults (as it'll mess up the userspace single step
logic).

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
