Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C30C6B495D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:28 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e17so18224767wrw.13
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor3094079wrw.3.2018.11.27.08.56.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:56:26 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 20/25] kasan, arm64: add brk handler for inline instrumentation
Date: Tue, 27 Nov 2018 17:55:38 +0100
Message-Id: <e825441eda1dbbbb7f583f826a66c94e6f88316a.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Tag-based KASAN inline instrumentation mode (which embeds checks of shadow
memory into the generated code, instead of inserting a callback) generates
a brk instruction when a tag mismatch is detected.

This commit adds a tag-based KASAN specific brk handler, that decodes the
immediate value passed to the brk instructions (to extract information
about the memory access that triggered the mismatch), reads the register
values (x0 contains the guilty address) and reports the bug.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/brk-imm.h |  2 +
 arch/arm64/kernel/traps.c        | 68 +++++++++++++++++++++++++++++++-
 include/linux/kasan.h            |  3 ++
 3 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/brk-imm.h b/arch/arm64/include/asm/brk-imm.h
index ed693c5bcec0..2945fe6cd863 100644
--- a/arch/arm64/include/asm/brk-imm.h
+++ b/arch/arm64/include/asm/brk-imm.h
@@ -16,10 +16,12 @@
  * 0x400: for dynamic BRK instruction
  * 0x401: for compile time BRK instruction
  * 0x800: kernel-mode BUG() and WARN() traps
+ * 0x9xx: tag-based KASAN trap (allowed values 0x900 - 0x9ff)
  */
 #define FAULT_BRK_IMM			0x100
 #define KGDB_DYN_DBG_BRK_IMM		0x400
 #define KGDB_COMPILED_DBG_BRK_IMM	0x401
 #define BUG_BRK_IMM			0x800
+#define KASAN_BRK_IMM			0x900
 
 #endif
diff --git a/arch/arm64/kernel/traps.c b/arch/arm64/kernel/traps.c
index 5f4d9acb32f5..04bdc53716ef 100644
--- a/arch/arm64/kernel/traps.c
+++ b/arch/arm64/kernel/traps.c
@@ -35,6 +35,7 @@
 #include <linux/sizes.h>
 #include <linux/syscalls.h>
 #include <linux/mm_types.h>
+#include <linux/kasan.h>
 
 #include <asm/atomic.h>
 #include <asm/bug.h>
@@ -284,10 +285,14 @@ void arm64_notify_die(const char *str, struct pt_regs *regs,
 	}
 }
 
-void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
+void __arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
 {
 	regs->pc += size;
+}
 
+void arm64_skip_faulting_instruction(struct pt_regs *regs, unsigned long size)
+{
+	__arm64_skip_faulting_instruction(regs, size);
 	/*
 	 * If we were single stepping, we want to get the step exception after
 	 * we return from the trap.
@@ -959,7 +964,7 @@ static int bug_handler(struct pt_regs *regs, unsigned int esr)
 	}
 
 	/* If thread survives, skip over the BUG instruction and continue: */
-	arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
+	__arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
 	return DBG_HOOK_HANDLED;
 }
 
@@ -969,6 +974,58 @@ static struct break_hook bug_break_hook = {
 	.fn = bug_handler,
 };
 
+#ifdef CONFIG_KASAN_SW_TAGS
+
+#define KASAN_ESR_RECOVER	0x20
+#define KASAN_ESR_WRITE	0x10
+#define KASAN_ESR_SIZE_MASK	0x0f
+#define KASAN_ESR_SIZE(esr)	(1 << ((esr) & KASAN_ESR_SIZE_MASK))
+
+static int kasan_handler(struct pt_regs *regs, unsigned int esr)
+{
+	bool recover = esr & KASAN_ESR_RECOVER;
+	bool write = esr & KASAN_ESR_WRITE;
+	size_t size = KASAN_ESR_SIZE(esr);
+	u64 addr = regs->regs[0];
+	u64 pc = regs->pc;
+
+	if (user_mode(regs))
+		return DBG_HOOK_ERROR;
+
+	kasan_report(addr, size, write, pc);
+
+	/*
+	 * The instrumentation allows to control whether we can proceed after
+	 * a crash was detected. This is done by passing the -recover flag to
+	 * the compiler. Disabling recovery allows to generate more compact
+	 * code.
+	 *
+	 * Unfortunately disabling recovery doesn't work for the kernel right
+	 * now. KASAN reporting is disabled in some contexts (for example when
+	 * the allocator accesses slab object metadata; this is controlled by
+	 * current->kasan_depth). All these accesses are detected by the tool,
+	 * even though the reports for them are not printed.
+	 *
+	 * This is something that might be fixed at some point in the future.
+	 */
+	if (!recover)
+		die("Oops - KASAN", regs, 0);
+
+	/* If thread survives, skip over the brk instruction and continue: */
+	__arm64_skip_faulting_instruction(regs, AARCH64_INSN_SIZE);
+	return DBG_HOOK_HANDLED;
+}
+
+#define KASAN_ESR_VAL (0xf2000000 | KASAN_BRK_IMM)
+#define KASAN_ESR_MASK 0xffffff00
+
+static struct break_hook kasan_break_hook = {
+	.esr_val = KASAN_ESR_VAL,
+	.esr_mask = KASAN_ESR_MASK,
+	.fn = kasan_handler,
+};
+#endif
+
 /*
  * Initial handler for AArch64 BRK exceptions
  * This handler only used until debug_traps_init().
@@ -976,6 +1033,10 @@ static struct break_hook bug_break_hook = {
 int __init early_brk64(unsigned long addr, unsigned int esr,
 		struct pt_regs *regs)
 {
+#ifdef CONFIG_KASAN_SW_TAGS
+	if ((esr & KASAN_ESR_MASK) == KASAN_ESR_VAL)
+		return kasan_handler(regs, esr) != DBG_HOOK_HANDLED;
+#endif
 	return bug_handler(regs, esr) != DBG_HOOK_HANDLED;
 }
 
@@ -983,4 +1044,7 @@ int __init early_brk64(unsigned long addr, unsigned int esr,
 void __init trap_init(void)
 {
 	register_break_hook(&bug_break_hook);
+#ifdef CONFIG_KASAN_SW_TAGS
+	register_break_hook(&kasan_break_hook);
+#endif
 }
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index a477ce2abdc9..8da7b7a4397a 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -173,6 +173,9 @@ void kasan_init_tags(void);
 
 void *kasan_reset_tag(const void *addr);
 
+void kasan_report(unsigned long addr, size_t size,
+		bool is_write, unsigned long ip);
+
 #else /* CONFIG_KASAN_SW_TAGS */
 
 static inline void kasan_init_tags(void) { }
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
