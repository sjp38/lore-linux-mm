Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6548B6B0266
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 15so420615pgc.21
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y14si2593206pfe.180.2017.10.31.15.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:57 -0700 (PDT)
Subject: [PATCH 05/23] x86, mm: document X86_CR4_PGE toggling behavior
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:56 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223156.B967E819@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


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
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-prep-document-cr4-pge-behavior	2017-10-31 15:03:50.479119470 -0700
+++ b/arch/x86/include/asm/tlbflush.h	2017-10-31 15:03:50.482119612 -0700
@@ -258,9 +258,11 @@ static inline void __native_flush_tlb_gl
 	WARN_ON_ONCE(!(cr4 & X86_CR4_PGE));
 	/*
 	 * Architecturally, any _change_ to X86_CR4_PGE will fully flush the
-	 * TLB of all entries including all entries in all PCIDs and all
-	 * global pages.  Make sure that we _change_ the bit, regardless of
+	 * all entries.  Make sure that we _change_ the bit, regardless of
 	 * whether we had X86_CR4_PGE set in the first place.
+	 *
+	 * Note that just toggling PGE *also* flushes all entries from all
+	 * PCIDs, regardless of the state of X86_CR4_PCIDE.
 	 */
 	native_write_cr4(cr4 ^ X86_CR4_PGE);
 	/* Put original CR3 value back: */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
