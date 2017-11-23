Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F61D6B026F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:35:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b77so2544944pfl.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:35:57 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v10si14392895plz.525.2017.11.22.16.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:35:55 -0800 (PST)
Subject: [PATCH 06/23] x86, kaiser: allow NX poison to be set in p4d/pgd
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:34:48 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003448.C6AB3575@viggo.jf.intel.com>
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
--- a/arch/x86/include/asm/pgtable.h~kaiser-p4d-allow-nx	2017-11-22 15:45:47.382619743 -0800
+++ b/arch/x86/include/asm/pgtable.h	2017-11-22 15:45:47.386619743 -0800
@@ -846,7 +846,12 @@ static inline pud_t *pud_offset(p4d_t *p
 
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
 
@@ -880,7 +885,12 @@ static inline p4d_t *p4d_offset(pgd_t *p
 
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
