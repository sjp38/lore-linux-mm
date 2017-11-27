Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36CEC6B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:44:10 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v69so15746680wrb.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:44:10 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p63si10991970wme.115.2017.11.27.12.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:44:09 -0800 (PST)
Message-Id: <20171127204257.497387357@linutronix.de>
Date: Mon, 27 Nov 2017 21:34:17 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 1/4] x86/paravirt: Dont patch flush_tlb_single
References: <20171127203416.236563829@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-paravirt--Dont-patch-flush_tlb_single.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

native_flush_tlb_single() is not just INLVPG anymore. With
X86_FEATURE_INVPCID_SINGLE and KAISER enabled it flushes also the shadow
mapping. But even with KAISER disabled flushing the particular ASID is the
right thing to do.

Remove the paravirt patching for it.

Fixes: 1fde25dc8ef4 ("x86/mm/kaiser: Use PCID feature to make user and kernel switches faster")
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/kernel/paravirt_patch_64.c |    2 --
 1 file changed, 2 deletions(-)

--- a/arch/x86/kernel/paravirt_patch_64.c
+++ b/arch/x86/kernel/paravirt_patch_64.c
@@ -10,7 +10,6 @@ DEF_NATIVE(pv_irq_ops, save_fl, "pushfq;
 DEF_NATIVE(pv_mmu_ops, read_cr2, "movq %cr2, %rax");
 DEF_NATIVE(pv_mmu_ops, read_cr3, "movq %cr3, %rax");
 DEF_NATIVE(pv_mmu_ops, write_cr3, "movq %rdi, %cr3");
-DEF_NATIVE(pv_mmu_ops, flush_tlb_single, "invlpg (%rdi)");
 DEF_NATIVE(pv_cpu_ops, wbinvd, "wbinvd");
 
 DEF_NATIVE(pv_cpu_ops, usergs_sysret64, "swapgs; sysretq");
@@ -60,7 +59,6 @@ unsigned native_patch(u8 type, u16 clobb
 		PATCH_SITE(pv_mmu_ops, read_cr2);
 		PATCH_SITE(pv_mmu_ops, read_cr3);
 		PATCH_SITE(pv_mmu_ops, write_cr3);
-		PATCH_SITE(pv_mmu_ops, flush_tlb_single);
 		PATCH_SITE(pv_cpu_ops, wbinvd);
 #if defined(CONFIG_PARAVIRT_SPINLOCKS)
 		case PARAVIRT_PATCH(pv_lock_ops.queued_spin_unlock):


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
