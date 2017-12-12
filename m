Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66E3D6B0253
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:48 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i83so41901wma.4
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:48 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 93si12879871wrs.362.2017.12.12.09.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:47 -0800 (PST)
Message-Id: <20171212173334.097591438@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:31 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 10/16] x86/ldt: Do not install LDT for kernel threads
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-ldt--Do-not-install-LDT-for-kernel-threads.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

Kernel threads can use the mm of a user process temporarily via use_mm(),
but there is no point in installing the LDT which is associated to that mm
for the kernel thread.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/mmu_context.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -95,8 +95,7 @@ static inline void load_mm_ldt(struct mm
 	 * the local LDT after an IPI loaded a newer value than the one
 	 * that we can see.
 	 */
-
-	if (unlikely(ldt))
+	if (unlikely(ldt && !(current->flags & PF_KTHREAD))
 		set_ldt(ldt->entries, ldt->nr_entries);
 	else
 		clear_LDT();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
