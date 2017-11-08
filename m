Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 861306B02E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p9so3561262pgc.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:03 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n14si4700251plp.285.2017.11.08.11.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:02 -0800 (PST)
Subject: [PATCH 03/30] x86, mm: document X86_CR4_PGE toggling behavior
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:46:51 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194651.47745F42@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The comment says it all here.  The problem here is that the
X86_CR4_PGE bit affects all PCIDs in a way that is totally
obscure.

This makes it easier for someone to find if grepping for PCID-
related stuff and documents the hardware behavior that we are
depending on.

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

 b/arch/x86/include/asm/tlbflush.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior	2017-11-08 10:45:26.994681401 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-08 10:45:26.997681401 -0800
@@ -257,10 +257,12 @@ static inline void __native_flush_tlb_gl
 	 */
 	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
 	/*
-	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
-	 * TLB of all entries including all entries in all PCIDs and all
-	 * global pages.  Make sure that we _change_ the bit, regardless of
+	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush
+	 * all entries.  Make sure that we _change_ the bit, regardless of
 	 * whether we had X86_CR4_PGE set in the first place.
+	 *
+	 * Note that just toggling PGE *also* flushes all entries from all
+	 * PCIDs, regardless of the state of X86_CR4_PCIDE.
 	 */
 	native_write_cr4(cr4 ^ X86_CR4_PGE);
 	/* Put original CR4 value back: */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
