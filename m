Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 585776B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:44:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k18so18828333wre.11
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:44:10 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u21si22642408wrc.235.2017.11.27.12.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:44:09 -0800 (PST)
Message-Id: <20171127204257.732566340@linutronix.de>
Date: Mon, 27 Nov 2017 21:34:20 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 4/4] x86/mm/dump_pagetables: Use helper to get the shadow PGD
References: <20171127203416.236563829@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-dump_pagetables--Use-helper-to-get-the-shadow-PGD.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Use kernel_to_shadow_pgdp() instead of open coding it.

Fixes: ca646ac417b8 ("x86/mm/debug_pagetables: Allow dumping current pagetables")
Fixes: 04bafab4b2ee ("x86/mm/dump_pagetables: Check Kaiser shadow page table for WX pages")
Requested-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/mm/dump_pagetables.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -504,8 +504,10 @@ void ptdump_walk_pgd_level(struct seq_fi
 
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool shadow)
 {
+#ifdef CONFIG_KAISER
 	if (shadow && kaiser_enabled)
-		pgd += PTRS_PER_PGD;
+		pgd = kernel_to_shadow_pgdp(pgd);
+#endif
 	ptdump_walk_pgd_level_core(m, pgd, false, false);
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
@@ -518,7 +520,7 @@ void ptdump_walk_shadow_pgd_level_checkw
 	if (!kaiser_enabled)
 		return;
 	pr_info("x86/mm: Checking shadow page tables\n");
-	pgd += PTRS_PER_PGD;
+	pgd = kernel_to_shadow_pgdp(pgd);
 	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
 #endif
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
