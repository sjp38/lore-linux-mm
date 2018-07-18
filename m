Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC846B0280
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d5-v6so1699681edq.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:33 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id o16-v6si659572edo.118.2018.07.18.02.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:32 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 19/39] x86/pgtable: Move pti_set_user_pgtbl() to pgtable.h
Date: Wed, 18 Jul 2018 11:40:56 +0200
Message-Id: <1531906876-13451-20-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

There it is also usable from 32 bit code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index eb47432..cc117161 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -640,8 +640,31 @@ static inline int is_new_memtype_allowed(u64 paddr, unsigned long size,
 
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
-- 
2.7.4
