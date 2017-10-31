Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D5A2E6B026D
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t188so371631pfd.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:06 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id g83si2735180pfg.161.2017.10.31.15.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:05 -0700 (PDT)
Subject: [PATCH 10/23] x86, kaiser: make sure static PGDs are 8k in size
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:05 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223205.951EFCB6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


We have a few PGDs that come out of the kernel binary instead of being
allocated dynamically.  Before this patch, they are all 8k-aligned,
but we also need them to be 8k in *size*e

The original KAISER patch did not do this.  It probably just lucked out
that it did not trample over data after the last PGD.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/kernel/head_64.S |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff -puN arch/x86/kernel/head_64.S~kaiser-head_S-pgds-need-8k-too arch/x86/kernel/head_64.S
--- a/arch/x86/kernel/head_64.S~kaiser-head_S-pgds-need-8k-too	2017-10-31 15:03:53.866279568 -0700
+++ b/arch/x86/kernel/head_64.S	2017-10-31 15:03:53.870279757 -0700
@@ -340,11 +340,24 @@ GLOBAL(early_recursion_flag)
 GLOBAL(name)
 
 #ifdef CONFIG_KAISER
+/*
+ * Each PGD needs to be 8k long and 8k aligned.  We do not
+ * ever go out to userspace with these, so we do not
+ * strictly *need* the second page, but this allows us to
+ * have a single set_pgd() implementation that does not
+ * need to worry about whether it has 4k or 8k to work
+ * with.
+ *
+ * This ensures PGDs are 8k long:
+ */
+#define KAISER_USER_PGD_FILL	512
+/* This ensures they are 8k-aligned: */
 #define NEXT_PGD_PAGE(name) \
 	.balign 2 * PAGE_SIZE; \
 GLOBAL(name)
 #else
 #define NEXT_PGD_PAGE(name) NEXT_PAGE(name)
+#define KAISER_USER_PGD_FILL	0
 #endif
 
 /* Automate the creation of 1 to 1 mapping pmd entries */
@@ -363,6 +376,7 @@ NEXT_PGD_PAGE(early_top_pgt)
 #else
 	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 #endif
+	.fill	KAISER_USER_PGD_FILL,8,0
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -372,6 +386,7 @@ NEXT_PAGE(early_dynamic_pgts)
 #ifndef CONFIG_XEN
 NEXT_PGD_PAGE(init_top_pgt)
 	.fill	512,8,0
+	.fill	KAISER_USER_PGD_FILL,8,0
 #else
 NEXT_PGD_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
@@ -380,6 +395,7 @@ NEXT_PGD_PAGE(init_top_pgt)
 	.org    init_top_pgt + PGD_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
+	.fill	KAISER_USER_PGD_FILL,8,0
 
 NEXT_PAGE(level3_ident_pgt)
 	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
