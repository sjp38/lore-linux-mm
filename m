Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D32C6B0273
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:52 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t123so3922898wmt.2
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:52 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id q54si1379830eda.48.2018.03.05.02.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:16 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 19/34] x86/pgtable: Move pti_set_user_pgtbl() to pgtable.h
Date: Mon,  5 Mar 2018 11:25:48 +0100
Message-Id: <1520245563-8444-20-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

There it is also usable from 32 bit code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable.h    | 23 +++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h | 21 ---------------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0a9f746..1e900c1 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -618,8 +618,31 @@ static inline int is_new_memtype_allowed(u64 paddr, unsigned long size,
 
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
index 5e68083..4cbf517 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -145,27 +145,6 @@ static inline bool pgdp_maps_userspace(void *__ptr)
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
 #if defined(CONFIG_PAGE_TABLE_ISOLATION) && !defined(CONFIG_X86_5LEVEL)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
