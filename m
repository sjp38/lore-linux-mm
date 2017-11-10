Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A42D440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:42 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a19so3971325pfa.23
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:42 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e6si9142169pgn.589.2017.11.10.11.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:41 -0800 (PST)
Subject: [PATCH 10/30] x86, kaiser: allow NX poison to be set in p4d/pgd
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:22 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193122.9C518CD9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

The user portion of the kernel page tables use the NX bit to
poison them for userspace.  But, that trips the p4d/pgd_bad()
checks.  Make sure it does not do that.

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

 b/arch/x86/include/asm/pgtable.h |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/pgtable.h~kaiser-p4d-allow-nx arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~kaiser-p4d-allow-nx	2017-11-10 11:22:10.474244946 -0800
+++ b/arch/x86/include/asm/pgtable.h	2017-11-10 11:22:10.478244946 -0800
@@ -845,7 +845,12 @@ static inline pud_t *pud_offset(p4d_t *p
 
 static inline int p4d_bad(p4d_t p4d)
 {
-	return (p4d_flags(p4d) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
+	unsigned long ignore_flags = _KERNPG_TABLE | _PAGE_USER;
+
+	if (IS_ENABLED(CONFIG_KAISER))
+		ignore_flags |= _PAGE_NX;
+
+	return (p4d_flags(p4d) & ~ignore_flags) != 0;
 }
 #endif  /* CONFIG_PGTABLE_LEVELS > 3 */
 
@@ -879,7 +884,12 @@ static inline p4d_t *p4d_offset(pgd_t *p
 
 static inline int pgd_bad(pgd_t pgd)
 {
-	return (pgd_flags(pgd) & ~_PAGE_USER) != _KERNPG_TABLE;
+	unsigned long ignore_flags = _PAGE_USER;
+
+	if (IS_ENABLED(CONFIG_KAISER))
+		ignore_flags |= _PAGE_NX;
+
+	return (pgd_flags(pgd) & ~ignore_flags) != _KERNPG_TABLE;
 }
 
 static inline int pgd_none(pgd_t pgd)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
