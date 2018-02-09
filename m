Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53E7F6B0275
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:27:41 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id f15so3607003wmd.1
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:27:41 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id z12si1658607edm.176.2018.02.09.01.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:26:06 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 25/31] x86/mm/dump_pagetables: Define INIT_PGD
Date: Fri,  9 Feb 2018 10:25:34 +0100
Message-Id: <1518168340-9392-26-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Define INIT_PGD to point to the correct initial page-table
for 32 and 64 bit and use it where needed. This fixes the
build on 32 bit with CONFIG_PAGE_TABLE_ISOLATION enabled.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/dump_pagetables.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 2a4849e..2151ebb 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -105,6 +105,8 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
+#define INIT_PGD	((pgd_t *) &init_top_pgt)
+
 #else /* CONFIG_X86_64 */
 
 enum address_markers_idx {
@@ -133,6 +135,8 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
+#define INIT_PGD	(swapper_pg_dir)
+
 #endif /* !CONFIG_X86_64 */
 
 /* Multipliers for offsets within the PTEs */
@@ -478,11 +482,7 @@ static inline bool is_hypervisor_range(int idx)
 static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 				       bool checkwx, bool dmesg)
 {
-#ifdef CONFIG_X86_64
-	pgd_t *start = (pgd_t *) &init_top_pgt;
-#else
-	pgd_t *start = swapper_pg_dir;
-#endif
+	pgd_t *start = INIT_PGD;
 	pgprotval_t prot;
 	int i;
 	struct pg_state st = {};
@@ -543,7 +543,7 @@ EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
 static void ptdump_walk_user_pgd_level_checkwx(void)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pgd_t *pgd = (pgd_t *) &init_top_pgt;
+	pgd_t *pgd = INIT_PGD;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
