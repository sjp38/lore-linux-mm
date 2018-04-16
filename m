Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 833B86B002D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:25:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k27so12977726wre.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:25:47 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id b15si892024edh.143.2018.04.16.08.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 08:25:46 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 19/35] x86/pgtable: Move pti_set_user_pgtbl() to pgtable.h
Date: Mon, 16 Apr 2018 17:25:07 +0200
Message-Id: <1523892323-14741-20-git-send-email-joro@8bytes.org>
In-Reply-To: <1523892323-14741-1-git-send-email-joro@8bytes.org>
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

There it is also usable from 32 bit code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable.h    | 23 +++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h | 21 ---------------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 3055c77..557ddf8 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -635,8 +635,31 @@ static inline int is_new_memtype_allowed(u64 paddr, unsigned long size,
 
 pmd_t *populate_extra_pmd(unsigned long vaddr);
 pte_t *populate_extra_pte(unsigned long vaddr);
+
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+pgd_t __pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd);
+
+/*
+ * Take a PGD location (pgdp) and a pgd value that needs to be set there.
+ * Populates the user and returns the resulting PGD that must be set in
+ * the kernel copy of the page tables.
+ */
+static inline pgd_t pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd)
+{
+	if (!static_cpu_has(X86_FEATURE_PTI))
+		return pgd;
+	return __pti_set_user_pgtbl(pgdp, pgd);
+}
+#else   /* CONFIG_PAGE_TABLE_ISOLATION */
+static inline pgd_t pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd)
+{
+	return pgd;
+}
+#endif  /* CONFIG_PAGE_TABLE_ISOLATION */
+
 #endif	/* __ASSEMBLY__ */
 
+
 #ifdef CONFIG_X86_32
 # include <asm/pgtable_32.h>
 #else
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9934115..6dd2eb6 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -146,27 +146,6 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 	return (ptr & ~PAGE_MASK) < (PAGE_SIZE / 2);
 }
 
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-pgd_t __pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd);
-
-/*
- * Take a PGD location (pgdp) and a pgd value that needs to be set there.
- * Populates the user and returns the resulting PGD that must be set in
- * the kernel copy of the page tables.
- */
-static inline pgd_t pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd)
-{
-	if (!static_cpu_has(X86_FEATURE_PTI))
-		return pgd;
-	return __pti_set_user_pgtbl(pgdp, pgd);
-}
-#else
-static inline pgd_t pti_set_user_pgtbl(pgd_t *pgdp, pgd_t pgd)
-{
-	return pgd;
-}
-#endif
-
 static inline void native_set_p4d(p4d_t *p4dp, p4d_t p4d)
 {
 	pgd_t pgd;
-- 
2.7.4
