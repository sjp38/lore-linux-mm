Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 422E14403DA
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:45 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r6so8029590itr.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:45 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m62si2707894ioe.219.2017.12.14.03.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:44 -0800 (PST)
Message-Id: <20171214113851.398563731@infradead.org>
Date: Thu, 14 Dec 2017 12:27:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 06/17] x86/ldt: Do not install LDT for kernel threads
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=x86-ldt--Do-not-install-LDT-for-kernel-threads.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

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
+	if (unlikely(ldt && !(current->flags & PF_KTHREAD)))
 		set_ldt(ldt->entries, ldt->nr_entries);
 	else
 		clear_LDT();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
