Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23796440404
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:39:38 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l99so1481909wrc.18
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:39:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 44si7527200wrm.70.2017.12.16.13.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:39:37 -0800 (PST)
Message-Id: <20171216213138.074872626@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:14 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 20/50] x86/mm/pti: Disable global pages if
 PAGE_TABLE_ISOLATION=y
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0028-x86-mm-pti-Disable-global-pages-if-PAGE_TABLE_ISOLAT.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

Global pages stay in the TLB across context switches.  Since all contexts
share the same kernel mapping, these mappings are marked as global pages
so kernel entries in the TLB are not flushed out on a context switch.

But, even having these entries in the TLB opens up something that an
attacker can use, such as the double-page-fault attack:

   http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf

That means that even when PAGE_TABLE_ISOLATION switches page tables
on return to user space the global pages would stay in the TLB cache.

Disable global pages so that kernel TLB entries can be flushed before
returning to user space. This way, all accesses to kernel addresses from
userspace result in a TLB miss independent of the existence of a kernel
mapping.

Suppress global pages via the __supported_pte_mask. The user space
mappings set PAGE_GLOBAL for the minimal kernel mappings which are
required for entry/exit. These mappings are set up manually so the
filtering does not take place.

[ The __supported_pte_mask simplification was written by Thomas Gleixner. ]

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/mm/init.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -160,6 +160,12 @@ struct map_range {
 
 static int page_size_mask;
 
+static void enable_global_pages(void)
+{
+	if (!static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_PTI))
+		__supported_pte_mask |= _PAGE_GLOBAL;
+}
+
 static void __init probe_page_size_mask(void)
 {
 	/*
@@ -177,11 +183,11 @@ static void __init probe_page_size_mask(
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
