Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 213E26B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 10:42:30 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s17so10349455pfm.23
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 07:42:30 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k194si7173163pgc.662.2018.02.27.07.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 07:42:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/5] x86/boot/compressed/64: Save and restore trampoline memory
Date: Tue, 27 Feb 2018 18:42:15 +0300
Message-Id: <20180227154217.69347-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
References: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The memory area we found for trampoline shouldn't contain anything
useful. But let's preserve the data anyway. Just to be on safe side.

paging_prepare() would save the data into a buffer.

cleanup_trampoline() would restore it back once we are done with the
trampoline.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/boot/compressed/head_64.S    | 10 ++++++++++
 arch/x86/boot/compressed/pgtable_64.c | 13 +++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index d598d65db32c..8ba0582c65d5 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -355,6 +355,16 @@ ENTRY(startup_64)
 	lretq
 lvl5:
 
+	/*
+	 * cleanup_trampoline() would restore trampoline memory.
+	 *
+	 * RSI holds real mode data and needs to be preserved across
+	 * this function call.
+	 */
+	pushq	%rsi
+	call	cleanup_trampoline
+	popq	%rsi
+
 	/* Zero EFLAGS */
 	pushq	$0
 	popfq
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 21d5cc1cd5fa..01d08d3e3e43 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -1,5 +1,6 @@
 #include <asm/processor.h>
 #include "pgtable.h"
+#include "../string.h"
 
 /*
  * __force_order is used by special_insns.h asm code to force instruction
@@ -18,6 +19,9 @@ struct paging_config {
 	unsigned long l5_required;
 };
 
+/* Buffer to preserve trampoline memory */
+static char trampoline_save[TRAMPOLINE_32BIT_SIZE];
+
 /*
  * Trampoline address will be printed by extract_kernel() for debugging
  * purposes.
@@ -69,5 +73,14 @@ struct paging_config paging_prepare(void)
 
 	trampoline_32bit = (unsigned long *)paging_config.trampoline_start;
 
+	/* Preserve trampoline memory */
+	memcpy(trampoline_save, trampoline_32bit, TRAMPOLINE_32BIT_SIZE);
+
 	return paging_config;
 }
+
+void cleanup_trampoline(void)
+{
+	/* Restore trampoline memory */
+	memcpy(trampoline_32bit, trampoline_save, TRAMPOLINE_32BIT_SIZE);
+}
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
