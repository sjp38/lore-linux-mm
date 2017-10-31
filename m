Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77BB86B0261
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so422615pgb.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o11si2599032pgd.473.2017.10.31.15.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:55 -0700 (PDT)
Subject: [PATCH 04/23] x86, tlb: make CR4-based TLB flushes more robust
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:54 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223154.67F15B2A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


Our CR4-based TLB flush currently requries global pages to be
supported *and* enabled.  But, we really only need for them to be
supported.  Make the code more robust by alllowing X86_CR4_PGE to
clear as well as set.

This change was suggested by Kirill Shutemov.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-make-cr4-writes-tolerate-clear-pge	2017-10-31 15:03:49.913092716 -0700
+++ b/arch/x86/include/asm/tlbflush.h	2017-10-31 15:03:49.917092905 -0700
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
+	/* Put original CR3 value back: */
 	native_write_cr4(cr4);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
