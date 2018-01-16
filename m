Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAED280244
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:28:45 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id j18so1261572uag.4
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:28:45 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id e45si2650818eda.4.2018.01.16.08.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:20 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 05/16] x86/pgtable: Move pgdp kernel/user conversion functions to pgtable.h
Date: Tue, 16 Jan 2018 17:36:48 +0100
Message-Id: <1516120619-1159-6-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Make them available on 32 bit and clone_pgd_range() happy.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable.h    | 49 +++++++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/pgtable_64.h | 49 ---------------------------------------
 2 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index e42b8943cb1a..0a9f746cbdc1 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1109,6 +1109,55 @@ static inline int pud_write(pud_t pud)
 	return pud_flags(pud) & _PAGE_RW;
 }
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+/*
+ * All top-level PAGE_TABLE_ISOLATION page tables are order-1 pages
+ * (8k-aligned and 8k in size).  The kernel one is at the beginning 4k and
+ * the user one is in the last 4k.  To switch between them, you
+ * just need to flip the 12th bit in their addresses.
+ */
+#define PTI_PGTABLE_SWITCH_BIT	PAGE_SHIFT
+
+/*
+ * This generates better code than the inline assembly in
+ * __set_bit().
+ */
+static inline void *ptr_set_bit(void *ptr, int bit)
+{
+	unsigned long __ptr = (unsigned long)ptr;
+
+	__ptr |= BIT(bit);
+	return (void *)__ptr;
+}
+static inline void *ptr_clear_bit(void *ptr, int bit)
+{
+	unsigned long __ptr = (unsigned long)ptr;
+
+	__ptr &= ~BIT(bit);
+	return (void *)__ptr;
+}
+
+static inline pgd_t *kernel_to_user_pgdp(pgd_t *pgdp)
+{
+	return ptr_set_bit(pgdp, PTI_PGTABLE_SWITCH_BIT);
+}
+
+static inline pgd_t *user_to_kernel_pgdp(pgd_t *pgdp)
+{
+	return ptr_clear_bit(pgdp, PTI_PGTABLE_SWITCH_BIT);
+}
+
+static inline p4d_t *kernel_to_user_p4dp(p4d_t *p4dp)
+{
+	return ptr_set_bit(p4dp, PTI_PGTABLE_SWITCH_BIT);
+}
+
+static inline p4d_t *user_to_kernel_p4dp(p4d_t *p4dp)
+{
+	return ptr_clear_bit(p4dp, PTI_PGTABLE_SWITCH_BIT);
+}
+#endif /* CONFIG_PAGE_TABLE_ISOLATION */
+
 /*
  * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
  *
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 81462e9a34f6..58d7f10e937d 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -131,55 +131,6 @@ static inline pud_t native_pudp_get_and_clear(pud_t *xp)
 #endif
 }
 
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-/*
- * All top-level PAGE_TABLE_ISOLATION page tables are order-1 pages
- * (8k-aligned and 8k in size).  The kernel one is at the beginning 4k and
- * the user one is in the last 4k.  To switch between them, you
- * just need to flip the 12th bit in their addresses.
- */
-#define PTI_PGTABLE_SWITCH_BIT	PAGE_SHIFT
-
-/*
- * This generates better code than the inline assembly in
- * __set_bit().
- */
-static inline void *ptr_set_bit(void *ptr, int bit)
-{
-	unsigned long __ptr = (unsigned long)ptr;
-
-	__ptr |= BIT(bit);
-	return (void *)__ptr;
-}
-static inline void *ptr_clear_bit(void *ptr, int bit)
-{
-	unsigned long __ptr = (unsigned long)ptr;
-
-	__ptr &= ~BIT(bit);
-	return (void *)__ptr;
-}
-
-static inline pgd_t *kernel_to_user_pgdp(pgd_t *pgdp)
-{
-	return ptr_set_bit(pgdp, PTI_PGTABLE_SWITCH_BIT);
-}
-
-static inline pgd_t *user_to_kernel_pgdp(pgd_t *pgdp)
-{
-	return ptr_clear_bit(pgdp, PTI_PGTABLE_SWITCH_BIT);
-}
-
-static inline p4d_t *kernel_to_user_p4dp(p4d_t *p4dp)
-{
-	return ptr_set_bit(p4dp, PTI_PGTABLE_SWITCH_BIT);
-}
-
-static inline p4d_t *user_to_kernel_p4dp(p4d_t *p4dp)
-{
-	return ptr_clear_bit(p4dp, PTI_PGTABLE_SWITCH_BIT);
-}
-#endif /* CONFIG_PAGE_TABLE_ISOLATION */
-
 /*
  * Page table pages are page-aligned.  The lower half of the top
  * level is used for userspace and the top half for the kernel.
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
