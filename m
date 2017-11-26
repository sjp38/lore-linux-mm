Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5C296B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 18:26:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b189so10049825wmd.5
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 15:26:11 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 2si20194517wrg.320.2017.11.26.15.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 15:26:10 -0800 (PST)
Message-Id: <20171126232414.313869499@linutronix.de>
Date: Mon, 27 Nov 2017 00:14:04 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
References: <20171126231403.657575796@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-kaiser--Respect-disabled-features.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

PAGE_NX and PAGE_GLOBAL might be not supported or disabled on the command
line, but KAISER sets them unconditionally.

Add proper protection against that.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/pgtable_64.h |    3 ++-
 arch/x86/mm/kaiser.c              |   12 +++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -222,7 +222,8 @@ static inline pgd_t kaiser_set_shadow_pg
 			 * wrong CR3 value, userspace will crash
 			 * instead of running.
 			 */
-			pgd.pgd |= _PAGE_NX;
+			if (__supported_pte_mask & _PAGE_NX)
+				pgd.pgd |= _PAGE_NX;
 		}
 	} else if (pgd_userspace_access(*pgdp)) {
 		/*
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -42,6 +42,8 @@
 
 #define KAISER_WALK_ATOMIC  0x1
 
+static pteval_t kaiser_pte_mask __ro_after_init = ~(_PAGE_NX | _PAGE_GLOBAL);
+
 /*
  * At runtime, the only things we map are some things for CPU
  * hotplug, and stacks for new processes.  No two CPUs will ever
@@ -244,11 +246,14 @@ static pte_t *kaiser_shadow_pagetable_wa
 int kaiser_add_user_map(const void *__start_addr, unsigned long size,
 			unsigned long flags)
 {
-	pte_t *pte;
 	unsigned long start_addr = (unsigned long)__start_addr;
 	unsigned long address = start_addr & PAGE_MASK;
 	unsigned long end_addr = PAGE_ALIGN(start_addr + size);
 	unsigned long target_address;
+	pte_t *pte;
+
+	/* Clear not supported bits */
+	flags &= kaiser_pte_mask;
 
 	for (; address < end_addr; address += PAGE_SIZE) {
 		target_address = get_pa_from_kernel_map(address);
@@ -308,6 +313,11 @@ static void __init kaiser_init_all_pgds(
 	pgd_t *pgd;
 	int i;
 
+	if (__supported_pte_mask & _PAGE_NX)
+		kaiser_pte_mask |= _PAGE_NX;
+	if (boot_cpu_has(X86_FEATURE_PGE))
+		kaiser_pte_mask |= _PAGE_GLOBAL;
+
 	pgd = kernel_to_shadow_pgdp(pgd_offset_k(0UL));
 	for (i = PTRS_PER_PGD / 2; i < PTRS_PER_PGD; i++) {
 		/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
