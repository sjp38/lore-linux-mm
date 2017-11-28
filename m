Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7456B02C7
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:03:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s75so31196296pgs.12
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:03:48 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 1si8053240plb.315.2017.11.28.01.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 01:03:47 -0800 (PST)
Subject: [PATCH] x86/mm/kaiser: remove no-INVPCID user ASID flushing
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 28 Nov 2017 01:02:19 -0800
Message-Id: <20171128090219.7256F849@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, bp@alien8.de, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

As the comment says, there are systems that have PCIDs but no
support for the INVPCID instruction to help flush individual
PCIDs.  Flushing the TLB on those systems is awkward, and even
worse with KAISER.  If faced with one of these when KAISER is
enabled, we simply fall back as if we have no PCID support.

However, there is a remnant in the code from trying to support
these systems.  Remove it, but leave the warning.

Andy Lutomirski points out that the code that this removes
has a hole that could leave entries from the kernel page tables
tagged with the user asid, leaving them vulnerable to being
used to weaken KASLR.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/mm/tlb.c |    9 ---------
 1 file changed, 9 deletions(-)

diff -puN arch/x86/mm/tlb.c~kaiser-remove-unused-tlb-flush-code arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~kaiser-remove-unused-tlb-flush-code	2017-11-28 00:53:41.391460358 -0800
+++ b/arch/x86/mm/tlb.c	2017-11-28 00:55:28.084460092 -0800
@@ -127,15 +127,6 @@ static void flush_user_asid(pgd_t *pgd,
 		invpcid_flush_single_context(user_asid(kern_asid));
 	} else {
 		/*
-		 * On systems with PCIDs, but no INVPCID, the only
-		 * way to flush a PCID is a CR3 write.  Note that
-		 * we use the kernel page tables with the *user*
-		 * ASID here.
-		 */
-		unsigned long user_asid_flush_cr3;
-		user_asid_flush_cr3 = build_cr3(pgd, user_asid(kern_asid));
-		write_cr3(user_asid_flush_cr3);
-		/*
 		 * We do not use PCIDs with KAISER unless we also
 		 * have INVPCID.  Getting here is unexpected.
 		 */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
