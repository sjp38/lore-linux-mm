Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73F8C28026F
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i196so10049726pgd.2
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:22 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b9si9365180pgu.17.2017.11.10.11.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:21 -0800 (PST)
Subject: [PATCH 02/30] x86, tlb: Make CR4-based TLB flushes more robust
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:01 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193101.B4285C6A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The existing CR4-based TLB flush currently requires global pages
to be supported *and* enabled.  But, the hardware only needs for
them to be supported.

Make the code more robust by allowing the initial state of
X86_CR4_PGE to be on *or* off.  In addition, if called in an
unexpected state (X86_CR4_PGE=0), issue a warning.  X86_CR4_PGE=0
is certainly unexpected should not be ignored it if encountered.

This essentially gives the best of both worlds: a TLB flush no
matter what, and a warning if the TLB flush is called in an
unexpected way (X86_CR4_PGE=0).

The XOR change was suggested by Kirill Shutemov.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge	2017-11-10 11:22:05.534244958 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-10 11:22:05.538244958 -0800
@@ -247,12 +247,24 @@ static inline void __native_flush_tlb(vo
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
 {
-	unsigned long cr4;
+	unsigned long cr4 = this_cpu_read(cpu_tlbstate.cr4);
 
-	cr4 = this_cpu_read(cpu_tlbstate.cr4);
-	/* clear PGE */
-	native_write_cr4(cr4 & ~X86_CR4_PGE);
-	/* write old PGE again and flush TLBs */
+	/*
+	 * This function is only called on systems that support X86_CR4_PGE
+	 * and where we expect X86_CR4_PGE to be set.  Warn if we are called
+	 * without PGE set.
+	 */
+	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
+
+	/*
+	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
+	 * TLB of all entries including all entries in all PCIDs and all
+	 * global pages.  Make sure that we _change_ the bit, regardless of
+	 * whether we had X86_CR4_PGE set in the first place.
+	 */
+	native_write_cr4(cr4 ^ X86_CR4_PGE);
+
+	/* Put original CR4 value back: */
 	native_write_cr4(cr4);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
