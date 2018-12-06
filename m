Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7061B6B7A09
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:25:11 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 127so209873wmm.6
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:25:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor189500wrv.18.2018.12.06.04.25.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:25:10 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v13 13/25] kasan, arm64: fix up fault handling logic
Date: Thu,  6 Dec 2018 13:24:31 +0100
Message-Id: <3f349b0e9e48b5df3298a6b4ae0634332274494a.1544099024.git.andreyknvl@google.com>
In-Reply-To: <cover.1544099024.git.andreyknvl@google.com>
References: <cover.1544099024.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Right now arm64 fault handling code removes pointer tags from addresses
covered by TTBR0 in faults taken from both EL0 and EL1, but doesn't do
that for pointers covered by TTBR1.

This patch adds two helper functions is_ttbr0_addr() and is_ttbr1_addr(),
where the latter one accounts for the fact that TTBR1 pointers might be
tagged when tag-based KASAN is in use, and uses these helper functions to
perform pointer checks in arch/arm64/mm/fault.c.

Suggested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/mm/fault.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 7d9571f4ae3d..c1d98f0a3086 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -40,6 +40,7 @@
 #include <asm/daifflags.h>
 #include <asm/debug-monitors.h>
 #include <asm/esr.h>
+#include <asm/kasan.h>
 #include <asm/sysreg.h>
 #include <asm/system_misc.h>
 #include <asm/pgtable.h>
@@ -132,6 +133,18 @@ static void mem_abort_decode(unsigned int esr)
 		data_abort_decode(esr);
 }
 
+static inline bool is_ttbr0_addr(unsigned long addr)
+{
+	/* entry assembly clears tags for TTBR0 addrs */
+	return addr < TASK_SIZE;
+}
+
+static inline bool is_ttbr1_addr(unsigned long addr)
+{
+	/* TTBR1 addresses may have a tag if KASAN_SW_TAGS is in use */
+	return arch_kasan_reset_tag(addr) >= VA_START;
+}
+
 /*
  * Dump out the page tables associated with 'addr' in the currently active mm.
  */
@@ -141,7 +154,7 @@ void show_pte(unsigned long addr)
 	pgd_t *pgdp;
 	pgd_t pgd;
 
-	if (addr < TASK_SIZE) {
+	if (is_ttbr0_addr(addr)) {
 		/* TTBR0 */
 		mm = current->active_mm;
 		if (mm == &init_mm) {
@@ -149,7 +162,7 @@ void show_pte(unsigned long addr)
 				 addr);
 			return;
 		}
-	} else if (addr >= VA_START) {
+	} else if (is_ttbr1_addr(addr)) {
 		/* TTBR1 */
 		mm = &init_mm;
 	} else {
@@ -254,7 +267,7 @@ static inline bool is_el1_permission_fault(unsigned long addr, unsigned int esr,
 	if (fsc_type == ESR_ELx_FSC_PERM)
 		return true;
 
-	if (addr < TASK_SIZE && system_uses_ttbr0_pan())
+	if (is_ttbr0_addr(addr) && system_uses_ttbr0_pan())
 		return fsc_type == ESR_ELx_FSC_FAULT &&
 			(regs->pstate & PSR_PAN_BIT);
 
@@ -319,7 +332,7 @@ static void set_thread_esr(unsigned long address, unsigned int esr)
 	 * type", so we ignore this wrinkle and just return the translation
 	 * fault.)
 	 */
-	if (current->thread.fault_address >= TASK_SIZE) {
+	if (!is_ttbr0_addr(current->thread.fault_address)) {
 		switch (ESR_ELx_EC(esr)) {
 		case ESR_ELx_EC_DABT_LOW:
 			/*
@@ -455,7 +468,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 		mm_flags |= FAULT_FLAG_WRITE;
 	}
 
-	if (addr < TASK_SIZE && is_el1_permission_fault(addr, esr, regs)) {
+	if (is_ttbr0_addr(addr) && is_el1_permission_fault(addr, esr, regs)) {
 		/* regs->orig_addr_limit may be 0 if we entered from EL0 */
 		if (regs->orig_addr_limit == KERNEL_DS)
 			die_kernel_fault("access to user memory with fs=KERNEL_DS",
@@ -603,7 +616,7 @@ static int __kprobes do_translation_fault(unsigned long addr,
 					  unsigned int esr,
 					  struct pt_regs *regs)
 {
-	if (addr < TASK_SIZE)
+	if (is_ttbr0_addr(addr))
 		return do_page_fault(addr, esr, regs);
 
 	do_bad_area(addr, esr, regs);
@@ -758,7 +771,7 @@ asmlinkage void __exception do_el0_ia_bp_hardening(unsigned long addr,
 	 * re-enabled IRQs. If the address is a kernel address, apply
 	 * BP hardening prior to enabling IRQs and pre-emption.
 	 */
-	if (addr > TASK_SIZE)
+	if (!is_ttbr0_addr(addr))
 		arm64_apply_bp_hardening();
 
 	local_daif_restore(DAIF_PROCCTX);
@@ -771,7 +784,7 @@ asmlinkage void __exception do_sp_pc_abort(unsigned long addr,
 					   struct pt_regs *regs)
 {
 	if (user_mode(regs)) {
-		if (instruction_pointer(regs) > TASK_SIZE)
+		if (!is_ttbr0_addr(instruction_pointer(regs)))
 			arm64_apply_bp_hardening();
 		local_daif_restore(DAIF_PROCCTX);
 	}
@@ -825,7 +838,7 @@ asmlinkage int __exception do_debug_exception(unsigned long addr,
 	if (interrupts_enabled(regs))
 		trace_hardirqs_off();
 
-	if (user_mode(regs) && instruction_pointer(regs) > TASK_SIZE)
+	if (user_mode(regs) && !is_ttbr0_addr(instruction_pointer(regs)))
 		arm64_apply_bp_hardening();
 
 	if (!inf->fn(addr, esr, regs)) {
-- 
2.20.0.rc1.387.gf8505762e3-goog
