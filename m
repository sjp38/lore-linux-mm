Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6815F6B0268
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:51:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 96so10474849wrk.7
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:51:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id n32si10788410wrb.189.2017.12.04.08.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:51:52 -0800 (PST)
Message-Id: <20171204150607.150578521@linutronix.de>
Date: Mon, 04 Dec 2017 15:07:34 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 28/60] x86/mm/kpti: Disable global pages if
 KERNEL_PAGE_TABLE_ISOLATION=y
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-kpti--Disable_global_pages_if_KERNEL_PAGE_TABLE_ISOLATION-y.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, richard.fellner@student.tugraz.at, michael.schwarz@iaik.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

Global pages stay in the TLB across context switches.  Since all contexts
share the same kernel mapping, these mappings are marked as global pages
so kernel entries in the TLB are not flushed out on a context switch.

But, even having these entries in the TLB opens up something that an
attacker can use, such as the double-page-fault attack:

   http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf

That means that even when KERNEL_PAGE_TABLE_ISOLATION switches page tables
on return to user space the global pages would stay in the TLB cache.

Disable global pages so that kernel TLB entries can be flushed before
returning to user space. This way, all accesses to kernel addresses from
userspace result in a TLB miss independent of the existence of a kernel
mapping.

Supress global pages via the __supported_pte_mask. The user space
mappings set PAGE_GLOBAL for the minimal kernel mappings which are
required for entry/exit. These mappings are set up manually so the
filtering does not take place.

[ The __supported_pte_mask simplification was written by Thomas Gleixner. ]

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: richard.fellner@student.tugraz.at
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/20171123003441.63DDFC6F@viggo.jf.intel.com

---
 arch/x86/mm/init.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -161,6 +161,12 @@ struct map_range {
 
 static int page_size_mask;
 
+static void enable_global_pages(void)
+{
+	if (!static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_KPTI))
+		__supported_pte_mask |= _PAGE_GLOBAL;
+}
+
 static void __init probe_page_size_mask(void)
 {
 	/*
@@ -179,11 +185,11 @@ static void __init probe_page_size_mask(
 		cr4_set_bits_and_update_boot(X86_CR4_PSE);
 
 	/* Enable PGE if available */
+	__supported_pte_mask &= ~_PAGE_GLOBAL;
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		cr4_set_bits_and_update_boot(X86_CR4_PGE);
-		__supported_pte_mask |= _PAGE_GLOBAL;
-	} else
-		__supported_pte_mask &= ~_PAGE_GLOBAL;
+		enable_global_pages();
+	}
 
 	/* Enable 1 GB linear kernel mappings if available: */
 	if (direct_gbpages && boot_cpu_has(X86_FEATURE_GBPAGES)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
