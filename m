Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F05F56B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 05:36:33 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r132-v6so3021902oig.16
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 02:36:33 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i46-v6si4822246otb.122.2018.03.26.02.36.32
        for <linux-mm@kvack.org>;
        Mon, 26 Mar 2018 02:36:32 -0700 (PDT)
Date: Mon, 26 Mar 2018 10:36:18 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 11/14] khwasan: add brk handler for inline
 instrumentation
Message-ID: <20180326093241.lba7k4pdjskr4gsv@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <f22726f1f4343a091f263edd4c988f12b414c752.1520017438.git.andreyknvl@google.com>
 <20180305145111.bbycnzpgzkir2dz4@lakrids.cambridge.arm.com>
 <CAAeHK+zHfgSfZtKhOnfFVa35uB=PSsPiN65BDd9RVNK63f_G0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zHfgSfZtKhOnfFVa35uB=PSsPiN65BDd9RVNK63f_G0w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 23, 2018 at 04:59:36PM +0100, Andrey Konovalov wrote:
> On Mon, Mar 5, 2018 at 3:51 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Mar 02, 2018 at 08:44:30PM +0100, Andrey Konovalov wrote:
> >> +static int khwasan_handler(struct pt_regs *regs, unsigned int esr)
> >> +{

> >> +     /* If thread survives, skip over the BUG instruction and continue: */
> >> +     arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
> >
> > This is for fast-forwarding user instruction streams, and isn't correct
> > to call for kernel faults (as it'll mess up the userspace single step
> > logic).
> 
> I saw BUG handler using this (which also inserts a brk), so I used it
> as well. 

Ah; I think that's broken today.

> What should I do instead to jump over the faulting brk instruction?

I don't think we have anything to do this properly today.

The simplest fix would be to split arm64_skip_faulting_instruction()
into separate functions for user/kernel, something like the below.

It would be nice to drop _user_ in the name of the userspace-specific
helper, though.

Thanks
Mark.

---->8----
diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
index eb2d15147e8d..101e3d4ed6c8 100644
--- a/arch/arm64/kernel/traps.c
+++ b/arch/arm64/kernel/traps.c
@@ -235,9 +235,14 @@ void arm64_notify_die(const char *str, struct pt_regs *regs,
        }
 }
 
-void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
+void __arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
 {
        regs->pc += size;
+}
+
+void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
+{
+       __arm64_skip_faulting_instruction(regs, size);
 
        /*
         * If we were single stepping, we want to get the step exception after
@@ -761,7 +766,7 @@ static int bug_handler(struct pt_regs *regs, unsigned int esr)
        }
 
        /* If thread survives, skip over the BUG instruction and continue: */
-       arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
+       __arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
        return DBG_HOOK_HANDLED;
 }
 
