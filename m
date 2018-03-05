Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 557C16B0261
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n14so3914128wmc.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:40 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 30si6615054edy.451.2018.03.05.02.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:16 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 21/34] x86/mm/pae: Populate valid user PGD entries
Date: Mon,  5 Mar 2018 11:25:50 +0100
Message-Id: <1520245563-8444-22-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Generic page-table code populates all non-leaf entries with
_KERNPG_TABLE bits set. This is fine for all paging modes
except PAE.

In PAE mode only a subset of the bits is allowed to be set.
Make sure we only set allowed bits by masking out the
reserved bits.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable_types.h | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 3696398..48fc70b 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -50,6 +50,7 @@
 #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
 #define _PAGE_SOFTW1	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW1)
 #define _PAGE_SOFTW2	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW2)
+#define _PAGE_SOFTW3	(_AT(pteval_t, 1) << _PAGE_BIT_SOFTW3)
 #define _PAGE_PAT	(_AT(pteval_t, 1) << _PAGE_BIT_PAT)
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
@@ -267,14 +268,37 @@ typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
 
 typedef struct { pgdval_t pgd; } pgd_t;
 
+#ifdef CONFIG_X86_PAE
+
+/*
+ * PHYSICAL_PAGE_MASK might be non-constant when SME is compiled in, so we can't
+ * use it here.
+ */
+
+#define PGD_PAE_PAGE_MASK	((signed long)PAGE_MASK)
+#define PGD_PAE_PHYS_MASK	(((1ULL << __PHYSICAL_MASK_SHIFT)-1) & PGD_PAE_PAGE_MASK)
+
+/*
+ * PAE allows Base Address, P, PWT, PCD and AVL bits to be set in PGD entries.
+ * All other bits are Reserved MBZ
+ */
+#define PGD_ALLOWED_BITS	(PGD_PAE_PHYS_MASK | _PAGE_PRESENT | \
+				 _PAGE_PWT | _PAGE_PCD | \
+				 _PAGE_SOFTW1 | _PAGE_SOFTW2 | _PAGE_SOFTW3 )
+
+#else
+/* No need to mask any bits for !PAE */
+#define PGD_ALLOWED_BITS	(~0ULL)
+#endif
+
 static inline pgd_t native_make_pgd(pgdval_t val)
 {
-	return (pgd_t) { val };
+	return (pgd_t) { val & PGD_ALLOWED_BITS };
 }
 
 static inline pgdval_t native_pgd_val(pgd_t pgd)
 {
-	return pgd.pgd;
+	return pgd.pgd & PGD_ALLOWED_BITS;
 }
 
 static inline pgdval_t pgd_flags(pgd_t pgd)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
