Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A43F6B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 07:21:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t10-v6so796124eds.7
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 04:21:53 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id u24-v6si3909123edi.415.2018.08.08.04.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 04:21:51 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
Date: Wed,  8 Aug 2018 13:16:40 +0200
Message-Id: <1533727000-9172-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The user page-table gets the updated kernel mappings in
pti_finalize(), which runs after the RO+X permissions got
applied to the kernel page-table in mark_readonly().

But with CONFIG_DEBUG_WX enabled, the user page-table is
already checked in mark_readonly() for insecure mappings.
This causes false-positive warnings, because the user
page-table did not get the updated mappings yet.

Move the W+X check for the user page-table into
pti_finalize() after it updated all required mappings.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable.h | 7 +++++--
 arch/x86/mm/dump_pagetables.c  | 3 +--
 arch/x86/mm/pti.c              | 2 ++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index e39088cb..a1cb333 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -30,11 +30,14 @@ int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
 void ptdump_walk_pgd_level_checkwx(void);
+void ptdump_walk_user_pgd_level_checkwx(void);
 
 #ifdef CONFIG_DEBUG_WX
-#define debug_checkwx() ptdump_walk_pgd_level_checkwx()
+#define debug_checkwx()		ptdump_walk_pgd_level_checkwx()
+#define debug_checkwx_user()	ptdump_walk_user_pgd_level_checkwx()
 #else
-#define debug_checkwx() do { } while (0)
+#define debug_checkwx()		do { } while (0)
+#define debug_checkwx_user()	do { } while (0)
 #endif
 
 /*
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index ccd92c4..b8ab901 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -569,7 +569,7 @@ void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
 
-static void ptdump_walk_user_pgd_level_checkwx(void)
+void ptdump_walk_user_pgd_level_checkwx(void)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	pgd_t *pgd = INIT_PGD;
@@ -586,7 +586,6 @@ static void ptdump_walk_user_pgd_level_checkwx(void)
 void ptdump_walk_pgd_level_checkwx(void)
 {
 	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
-	ptdump_walk_user_pgd_level_checkwx();
 }
 
 static int __init pt_dump_init(void)
diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 69a9d60..026a89a 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -628,4 +628,6 @@ void pti_finalize(void)
 	 */
 	pti_clone_entry_text();
 	pti_clone_kernel_text();
+
+	debug_checkwx_user();
 }
-- 
2.7.4
