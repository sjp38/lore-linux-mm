Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D62CD6B02DF
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id v78so3517436pgb.18
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:01 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v87si4823389pfi.340.2017.11.08.11.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:00 -0800 (PST)
Subject: [PATCH 02/30] x86, tlb: make CR4-based TLB flushes more robust
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:46:49 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194649.61C7A485@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Our CR4-based TLB flush currently requries global pages to be
supported *and* enabled.  But, the hardware only needs for them to
be supported.

Make the code more robust by alllowing the initial state of
X86_CR4_PGE to be on *or* off.  In addition, if we get called in
an unepected state (X86_CR4_PGE=0), issue a warning.  Having
X86_CR4_PGE=0 is certainly unexpected and we should not ignore
it if encountered.

This essentially gives us the best of both worlds: we get a TLB
flush no matter what, and we get a warning if we got called in
an unexpected way (X86_CR4_PGE=0).

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

 b/arch/x86/include/asm/tlbflush.h |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge	2017-11-08 10:45:26.461681402 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-08 10:45:26.464681402 -0800
@@ -250,9 +250,20 @@ static inline void __native_flush_tlb_gl
 	unsigned long cr4;
 
 	cr4 = this_cpu_read(cpu_tlbstate.cr4);
-	/* clear PGE */
-	native_write_cr4(cr4 & ~X86_CR4_PGE);
-	/* write old PGE again and flush TLBs */
+	/*
+	 * This function is only called on systems that support X86_CR4_PGE
+	 * and where always set X86_CR4_PGE.  Warn if we are called without
+	 * PGE set.
+	 */
+	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
+	/*
+	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
+	 * TLB of all entries including all entries in all PCIDs and all
+	 * global pages.  Make sure that we _change_ the bit, regardless of
+	 * whether we had X86_CR4_PGE set in the first place.
+	 */
+	native_write_cr4(cr4 ^ X86_CR4_PGE);
+	/* Put original CR4 value back: */
 	native_write_cr4(cr4);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
