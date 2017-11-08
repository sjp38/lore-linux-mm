Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E76206B0308
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z80so3022584pff.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:48 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o18si4617718pgc.140.2017.11.08.11.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:47 -0800 (PST)
Subject: [PATCH 27/30] x86, kaiser: un-poison PGDs at runtime
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:36 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194736.E68E5874@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We poison kernel PGDs that map userspace with the NX bit.  This
ensures that if we miss a kernel->user CR3 switch, userspace
crashes instead of running in an unhardened state.

We will need this code in a moment when we turn kaiser on and off
at runtime.

Note that we now need an __ASSEMBLY__ #ifdef since we are now
indirectly including kaiser.h into assembly.

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

 b/arch/x86/include/asm/pgtable_64.h |   16 ++++++++++++++-
 b/arch/x86/mm/kaiser.c              |   38 ++++++++++++++++++++++++++++++++++++
 b/include/linux/kaiser.h            |    3 +-
 3 files changed, 55 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/pgtable_64.h~kaiser-dynamic-unpoison-pgd arch/x86/include/asm/pgtable_64.h
--- a/arch/x86/include/asm/pgtable_64.h~kaiser-dynamic-unpoison-pgd	2017-11-08 10:45:40.781681366 -0800
+++ b/arch/x86/include/asm/pgtable_64.h	2017-11-08 10:45:40.788681366 -0800
@@ -2,6 +2,7 @@
 #define _ASM_X86_PGTABLE_64_H
 
 #include <linux/const.h>
+#include <linux/kaiser.h>
 #include <asm/pgtable_64_types.h>
 
 #ifndef __ASSEMBLY__
@@ -196,6 +197,18 @@ static inline bool pgd_userspace_access(
 	return (pgd.pgd & _PAGE_USER);
 }
 
+static inline void kaiser_poison_pgd(pgd_t *pgd)
+{
+	if (pgd->pgd & _PAGE_PRESENT)
+		pgd->pgd |= _PAGE_NX;
+}
+
+static inline void kaiser_unpoison_pgd(pgd_t *pgd)
+{
+	if (pgd->pgd & _PAGE_PRESENT)
+		pgd->pgd &= ~_PAGE_NX;
+}
+
 /*
  * Returns the pgd_t that the kernel should use in its page tables.
  */
@@ -216,7 +229,8 @@ static inline pgd_t kaiser_set_shadow_pg
 			 * wrong CR3 value, userspace will crash
 			 * instead of running.
 			 */
-			pgd.pgd |= _PAGE_NX;
+			if (kaiser_active())
+				kaiser_poison_pgd(&pgd);
 		}
 	} else if (!pgd.pgd) {
 		/*
diff -puN arch/x86/mm/kaiser.c~kaiser-dynamic-unpoison-pgd arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-dynamic-unpoison-pgd	2017-11-08 10:45:40.783681366 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-08 10:45:40.788681366 -0800
@@ -477,6 +477,9 @@ static ssize_t kaiser_enabled_write_file
 	if (enable > 1)
 		return -EINVAL;
 
+	if (kaiser_enabled == enable)
+		return count;
+
 	WRITE_ONCE(kaiser_enabled, enable);
 	return count;
 }
@@ -494,3 +497,38 @@ static int __init create_kaiser_enabled(
 	return 0;
 }
 late_initcall(create_kaiser_enabled);
+
+enum poison {
+	KAISER_POISON,
+	KAISER_UNPOISON
+};
+void kaiser_poison_pgd_page(pgd_t *pgd_page, enum poison do_poison)
+{
+	int i = 0;
+
+	for (i = 0; i < PTRS_PER_PGD; i++) {
+		pgd_t *pgd = &pgd_page[i];
+
+		/* Stop once we hit kernel addresses: */
+		if (!pgdp_maps_userspace(pgd))
+			break;
+
+		if (do_poison == KAISER_POISON)
+			kaiser_poison_pgd(pgd);
+		else
+			kaiser_unpoison_pgd(pgd);
+	}
+
+}
+
+void kaiser_poison_pgds(enum poison do_poison)
+{
+	struct page *page;
+
+	spin_lock(&pgd_lock);
+	list_for_each_entry(page, &pgd_list, lru) {
+		pgd_t *pgd = (pgd_t *)page_address(page);
+		kaiser_poison_pgd_page(pgd, do_poison);
+	}
+	spin_unlock(&pgd_lock);
+}
diff -puN include/linux/kaiser.h~kaiser-dynamic-unpoison-pgd include/linux/kaiser.h
--- a/include/linux/kaiser.h~kaiser-dynamic-unpoison-pgd	2017-11-08 10:45:40.784681366 -0800
+++ b/include/linux/kaiser.h	2017-11-08 10:45:40.788681366 -0800
@@ -4,7 +4,7 @@
 #ifdef CONFIG_KAISER
 #include <asm/kaiser.h>
 #else
-
+#ifndef __ASSEMBLY__
 /*
  * These stubs are used whenever CONFIG_KAISER is off, which
  * includes architectures that support KAISER, but have it
@@ -29,5 +29,6 @@ static inline bool kaiser_active(void)
 {
 	return 0;
 }
+#endif /* __ASSEMBLY__ */
 #endif /* !CONFIG_KAISER */
 #endif /* _INCLUDE_KAISER_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
