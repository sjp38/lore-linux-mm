Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BFBBA6B004F
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 08:36:18 -0500 (EST)
Received: by nf-out-0910.google.com with SMTP id h3so267323nfh.6
        for <linux-mm@kvack.org>; Sat, 21 Feb 2009 05:36:16 -0800 (PST)
From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] kmemcheck: rip out REP instruction emulation
Date: Sat, 21 Feb 2009 14:36:02 +0100
Message-Id: <1235223364-2097-3-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

As it turns out, disabling the "fast strings" of the P4 fixed the
REP single-stepping issue, so this code is not needed anymore.

Celebrate, for we just got rid of a LOT of complexity and pain.

Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 arch/x86/mm/kmemcheck/kmemcheck.c |  119 +------------------------------------
 arch/x86/mm/kmemcheck/opcode.c    |   13 +----
 arch/x86/mm/kmemcheck/opcode.h    |    3 +-
 3 files changed, 3 insertions(+), 132 deletions(-)

diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
index 056b4f1..b944f1d 100644
--- a/arch/x86/mm/kmemcheck/kmemcheck.c
+++ b/arch/x86/mm/kmemcheck/kmemcheck.c
@@ -113,18 +113,6 @@ struct kmemcheck_context {
 	unsigned long n_addrs;
 	unsigned long flags;
 
-	/*
-	 * The address of the REP prefix if we are currently emulating a
-	 * REP instruction; otherwise 0.
-	 */
-	const uint8_t *rep;
-
-	/* The address of the REX prefix. */
-	const uint8_t *rex;
-
-	/* Address of the primary instruction opcode. */
-	const uint8_t *insn;
-
 	/* Data size of the instruction that caused a fault. */
 	unsigned int size;
 };
@@ -241,12 +229,6 @@ void kmemcheck_hide(struct pt_regs *regs)
 		return;
 	}
 
-	if (data->rep) {
-		/* Save state and take it up later. */
-		regs->ip = (unsigned long) data->rep;
-		data->rep = NULL;
-	}
-
 	if (kmemcheck_enabled)
 		n = kmemcheck_hide_all();
 	else
@@ -513,8 +495,6 @@ enum kmemcheck_method {
 static void kmemcheck_access(struct pt_regs *regs,
 	unsigned long fallback_address, enum kmemcheck_method fallback_method)
 {
-	const uint8_t *rep_prefix;
-	const uint8_t *rex_prefix;
 	const uint8_t *insn;
 	const uint8_t *insn_primary;
 	unsigned int size;
@@ -533,55 +513,7 @@ static void kmemcheck_access(struct pt_regs *regs,
 	insn = (const uint8_t *) regs->ip;
 	insn_primary = kmemcheck_opcode_get_primary(insn);
 
-	kmemcheck_opcode_decode(insn, &rep_prefix, &rex_prefix, &size);
-
-	if (rep_prefix && *rep_prefix == 0xf3) {
-		/*
-		 * Due to an incredibly silly Intel bug, REP MOVS and
-		 * REP STOS instructions may generate just one single-
-		 * stepping trap on Pentium 4 CPUs. Other CPUs, including
-		 * AMDs, seem to generate traps after each repetition.
-		 *
-		 * What we do is really a very ugly hack; we increment the
-		 * instruction pointer before returning so that the next
-		 * time around we'll hit an ordinary MOVS or STOS
-		 * instruction. Now, in the debug exception, we know that
-		 * the instruction is really a REP MOVS/STOS, so instead
-		 * of clearing the single-stepping flag, we just continue
-		 * single-stepping the instruction until we're done.
-		 *
-		 * We currently don't handle REP MOVS/STOS instructions
-		 * which have other (additional) instruction prefixes in
-		 * front of REP, so we BUG on those.
-		 */
-		switch (insn_primary[0]) {
-			/* REP MOVS */
-		case 0xa4:
-		case 0xa5:
-			BUG_ON(regs->ip != (unsigned long) rep_prefix);
-
-			kmemcheck_copy(regs, regs->si, regs->di, size);
-			data->rep = rep_prefix;
-			data->rex = rex_prefix;
-			data->insn = insn_primary;
-			data->size = size;
-			regs->ip = (unsigned long) data->rep + 1;
-			goto out;
-
-			/* REP STOS */
-		case 0xaa:
-		case 0xab:
-			BUG_ON(regs->ip != (unsigned long) rep_prefix);
-
-			kmemcheck_write(regs, regs->di, size);
-			data->rep = rep_prefix;
-			data->rex = rex_prefix;
-			data->insn = insn_primary;
-			data->size = size;
-			regs->ip = (unsigned long) data->rep + 1;
-			goto out;
-		}
-	}
+	kmemcheck_opcode_decode(insn, &size);
 
 	switch (insn_primary[0]) {
 #ifdef CONFIG_KMEMCHECK_BITOPS_OK
@@ -693,59 +625,10 @@ bool kmemcheck_fault(struct pt_regs *regs, unsigned long address,
 bool kmemcheck_trap(struct pt_regs *regs)
 {
 	struct kmemcheck_context *data = &__get_cpu_var(kmemcheck_context);
-	unsigned long cx;
-#ifdef CONFIG_X86_64
-	uint32_t ecx;
-#endif
 
 	if (!kmemcheck_active(regs))
 		return false;
 
-	if (!data->rep) {
-		kmemcheck_hide(regs);
-		return true;
-	}
-
-	/*
-	 * We're emulating a REP MOVS/STOS instruction. Are we done yet?
-	 * Of course, 64-bit needs to handle CX/ECX/RCX differently...
-	 */
-#ifdef CONFIG_X86_64
-	if (data->rex && data->rex[0] & 0x08) {
-		cx = regs->cx - 1;
-		regs->cx = cx;
-	} else {
-		/* Without REX, 64-bit wants to use %ecx by default. */
-		ecx = regs->cx - 1;
-		cx = ecx;
-		regs->cx = (regs->cx & ~((1UL << 32) - 1)) | ecx;
-	}
-#else
-	cx = regs->cx - 1;
-	regs->cx = cx;
-#endif
-	if (cx) {
-		unsigned long rep = (unsigned long) data->rep;
-		kmemcheck_hide(regs);
-		/* Without the REP prefix, we have to do this ourselves... */
-		data->rep = (void *) rep;
-		regs->ip = rep + 1;
-
-		switch (data->insn[0]) {
-		case 0xa4:
-		case 0xa5:
-			kmemcheck_copy(regs, regs->si, regs->di, data->size);
-			break;
-		case 0xaa:
-		case 0xab:
-			kmemcheck_write(regs, regs->di, data->size);
-			break;
-		}
-
-		kmemcheck_show(regs);
-		return true;
-	}
-
 	/* We're done. */
 	kmemcheck_hide(regs);
 	return true;
diff --git a/arch/x86/mm/kmemcheck/opcode.c b/arch/x86/mm/kmemcheck/opcode.c
index 88a9662..3dff500 100644
--- a/arch/x86/mm/kmemcheck/opcode.c
+++ b/arch/x86/mm/kmemcheck/opcode.c
@@ -27,30 +27,20 @@ static bool opcode_is_rex_prefix(uint8_t b)
  * that we care about. Moreover, the ones who invented this instruction set
  * should be shot.
  */
-void kmemcheck_opcode_decode(const uint8_t *op,
-	const uint8_t **rep_prefix, const uint8_t **rex_prefix,
-	unsigned int *size)
+void kmemcheck_opcode_decode(const uint8_t *op, unsigned int *size)
 {
 	/* Default operand size */
 	int operand_size_override = 4;
 
-	*rep_prefix = NULL;
-
 	/* prefixes */
 	for (; opcode_is_prefix(*op); ++op) {
-		if (*op == 0xf2 || *op == 0xf3)
-			*rep_prefix = op;
 		if (*op == 0x66)
 			operand_size_override = 2;
 	}
 
-	*rex_prefix = NULL;
-
 #ifdef CONFIG_X86_64
 	/* REX prefix */
 	if (opcode_is_rex_prefix(*op)) {
-		*rex_prefix = op;
-
 		if (*op & 0x08) {
 			*size = 8;
 			return;
@@ -87,4 +77,3 @@ const uint8_t *kmemcheck_opcode_get_primary(const uint8_t *op)
 		++op;
 	return op;
 }
-
diff --git a/arch/x86/mm/kmemcheck/opcode.h b/arch/x86/mm/kmemcheck/opcode.h
index f744d8e..6956aad 100644
--- a/arch/x86/mm/kmemcheck/opcode.h
+++ b/arch/x86/mm/kmemcheck/opcode.h
@@ -3,8 +3,7 @@
 
 #include <linux/types.h>
 
-void kmemcheck_opcode_decode(const uint8_t *op,
-	const uint8_t **rep_pfx, const uint8_t **rex_pfx, unsigned int *size);
+void kmemcheck_opcode_decode(const uint8_t *op, unsigned int *size);
 const uint8_t *kmemcheck_opcode_get_primary(const uint8_t *op);
 
 #endif
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
