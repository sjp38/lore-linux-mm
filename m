Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4255F6B0293
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 190so17654868pgh.16
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h123si14355140pgc.417.2017.11.22.16.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:28 -0800 (PST)
Subject: [PATCH 21/23] x86, kaiser: un-poison PGDs at runtime
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:21 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003521.A90AC3AF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

With KAISER Kernel PGDs that map userspace are "poisoned" with
the NX bit.  This ensures that if a kernel->user CR3 switch is
missed, userspace crashes instead of running in an unhardened
state.

This code will be needed in a moment when KAISER is turned
on and off at runtime.

Note that an __ASSEMBLY__ #ifdef is now required since kaiser.h
is indirectly included into assembly.

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
--- a/arch/x86/include/asm/pgtable_64.h~kaiser-dynamic-unpoison-pgd	2017-11-22 15:45:55.818619722 -0800
+++ b/arch/x86/include/asm/pgtable_64.h	2017-11-22 15:45:55.824619722 -0800
@@ -3,6 +3,7 @@
 #define _ASM_X86_PGTABLE_64_H
 
 #include <linux/const.h>
+#include <linux/kaiser.h>
 #include <asm/pgtable_64_types.h>
 
 #ifndef __ASSEMBLY__
@@ -199,6 +200,18 @@ static inline bool pgd_userspace_access(
 	return pgd.pgd & _PAGE_USER;
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
  * Take a PGD location (pgdp) and a pgd value that needs
  * to be set there.  Populates the shadow and returns
@@ -222,7 +235,8 @@ static inline pgd_t kaiser_set_shadow_pg
 			 * wrong CR3 value, userspace will crash
 			 * instead of running.
 			 */
-			pgd.pgd |= _PAGE_NX;
+			if (kaiser_active())
+				kaiser_poison_pgd(&pgd);
 		}
 	} else if (pgd_userspace_access(*pgdp)) {
 		/*
diff -puN arch/x86/mm/kaiser.c~kaiser-dynamic-unpoison-pgd arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-dynamic-unpoison-pgd	2017-11-22 15:45:55.819619722 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-22 15:45:55.825619722 -0800
@@ -501,6 +501,9 @@ static ssize_t kaiser_enabled_write_file
 	if (enable > 1)
 		return -EINVAL;
 
+	if (kaiser_enabled == enable)
+		return count;
+
 	WRITE_ONCE(kaiser_enabled, enable);
 	return count;
 }
@@ -518,3 +521,38 @@ static int __init create_kaiser_enabled(
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
--- a/include/linux/kaiser.h~kaiser-dynamic-unpoison-pgd	2017-11-22 15:45:55.821619722 -0800
+++ b/include/linux/kaiser.h	2017-11-22 15:45:55.826619722 -0800
@@ -4,7 +4,7 @@
 #ifdef CONFIG_KAISER
 #include <asm/kaiser.h>
 #else
-
+#ifndef __ASSEMBLY__
 /*
  * These stubs are used whenever CONFIG_KAISER is off, which
  * includes architectures that support KAISER, but have it
@@ -33,5 +33,6 @@ static inline bool kaiser_active(void)
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
