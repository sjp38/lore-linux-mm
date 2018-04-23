Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1520E6B0026
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v11-v6so19456908wri.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:55 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 34si509393edm.8.2018.04.23.08.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:53 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 17/37] x86/pgtable/32: Allocate 8k page-tables when PTI is enabled
Date: Mon, 23 Apr 2018 17:47:20 +0200
Message-Id: <1524498460-25530-18-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Allocate a kernel and a user page-table root when PTI is
enabled. Also allocate a full page per root for PAE because
otherwise the bit to flip in cr3 to switch between them
would be non-constant, which creates a lot of hassle.
Keep that for a later optimization.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/kernel/head_32.S | 20 +++++++++++++++-----
 arch/x86/mm/pgtable.c     |  5 +++--
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/arch/x86/kernel/head_32.S b/arch/x86/kernel/head_32.S
index b59e4fb..12a3e8c 100644
--- a/arch/x86/kernel/head_32.S
+++ b/arch/x86/kernel/head_32.S
@@ -512,11 +512,18 @@ ENTRY(initial_code)
 ENTRY(setup_once_ref)
 	.long setup_once
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+#define	PGD_ALIGN	(2 * PAGE_SIZE)
+#define PTI_USER_PGD_FILL	1024
+#else
+#define	PGD_ALIGN	(PAGE_SIZE)
+#define PTI_USER_PGD_FILL	0
+#endif
 /*
  * BSS section
  */
 __PAGE_ALIGNED_BSS
-	.align PAGE_SIZE
+	.align PGD_ALIGN
 #ifdef CONFIG_X86_PAE
 .globl initial_pg_pmd
 initial_pg_pmd:
@@ -526,14 +533,17 @@ initial_pg_pmd:
 initial_page_table:
 	.fill 1024,4,0
 #endif
+	.align PGD_ALIGN
 initial_pg_fixmap:
 	.fill 1024,4,0
-.globl empty_zero_page
-empty_zero_page:
-	.fill 4096,1,0
 .globl swapper_pg_dir
+	.align PGD_ALIGN
 swapper_pg_dir:
 	.fill 1024,4,0
+	.fill PTI_USER_PGD_FILL,4,0
+.globl empty_zero_page
+empty_zero_page:
+	.fill 4096,1,0
 EXPORT_SYMBOL(empty_zero_page)
 
 /*
@@ -542,7 +552,7 @@ EXPORT_SYMBOL(empty_zero_page)
 #ifdef CONFIG_X86_PAE
 __PAGE_ALIGNED_DATA
 	/* Page-aligned for the benefit of paravirt? */
-	.align PAGE_SIZE
+	.align PGD_ALIGN
 ENTRY(initial_page_table)
 	.long	pa(initial_pg_pmd+PGD_IDENT_ATTR),0	/* low identity map */
 # if KPMDS == 3
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index ffc8c13..f4211d2 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -339,7 +339,8 @@ static inline pgd_t *_pgd_alloc(void)
 	 * We allocate one page for pgd.
 	 */
 	if (!SHARED_KERNEL_PMD)
-		return (pgd_t *)__get_free_page(PGALLOC_GFP);
+		return (pgd_t *)__get_free_pages(PGALLOC_GFP,
+						 PGD_ALLOCATION_ORDER);
 
 	/*
 	 * Now PAE kernel is not running as a Xen domain. We can allocate
@@ -351,7 +352,7 @@ static inline pgd_t *_pgd_alloc(void)
 static inline void _pgd_free(pgd_t *pgd)
 {
 	if (!SHARED_KERNEL_PMD)
-		free_page((unsigned long)pgd);
+		free_pages((unsigned long)pgd, PGD_ALLOCATION_ORDER);
 	else
 		kmem_cache_free(pgd_cache, pgd);
 }
-- 
2.7.4
