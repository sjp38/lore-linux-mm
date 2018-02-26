Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A421B6B0011
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:05:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e1so8757437pfi.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:05:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g7-v6si7004759plt.91.2018.02.26.10.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:05:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/5] x86/boot/compressed/64: Prepare new top-level page table for trampoline
Date: Mon, 26 Feb 2018 21:04:51 +0300
Message-Id: <20180226180451.86788-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If trampoline code would need to switch between 4- and 5-level paging
modes, we have to use a page table in trampoline memory.

Having it in trampoline memory guarantees that it's below 4G and we can
point CR3 to it from 32-bit trampoline code.

We only use the page table if the desired paging mode doesn't match the
mode we are in. Otherwise the page table is unused and trampoline code
wouldn't touch CR3.

For 4- to 5-level paging transition, we set up current (4-level paging)
CR3 as the first and the only entry in a new top-level page table.

For 5- to 4-level paging transition, copy page table pointed by first
entry in the current top-level page table as our new top-level page
table.

If the page table is used by trampoline we would need to copy it to new
page table outside trampoline and update CR3 before restoring trampoline
memory.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/pgtable_64.c | 61 +++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 810c2c32d98e..32af1cbcd903 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -22,6 +22,14 @@ struct paging_config {
 /* Buffer to preserve trampoline memory */
 static char trampoline_save[TRAMPOLINE_32BIT_SIZE];
 
+/*
+ * The page table is going to be used instead of page table in the trampoline
+ * memory.
+ *
+ * It must not be in BSS as BSS is cleared after cleanup_trampoline().
+ */
+static char top_pgtable[PAGE_SIZE] __aligned(PAGE_SIZE) __section(.data);
+
 /*
  * Trampoline address will be printed by extract_kernel() for debugging
  * purposes.
@@ -83,11 +91,64 @@ struct paging_config paging_prepare(void)
 	memcpy(trampoline_32bit + TRAMPOLINE_32BIT_CODE_OFFSET / sizeof(unsigned long),
 			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);
 
+	/*
+	 * The code below prepares page table in trampoline memory.
+	 *
+	 * The new page table will be used by trampoline code for switching
+	 * from 4- to 5-level paging or vice versa.
+	 *
+	 * If switching is not required, the page table is unused: trampoline
+	 * code wouldn't touch CR3.
+	 */
+
+	/*
+	 * We are not going to use the page table in trampoline memory if we
+	 * are already in the desired paging mode.
+	 */
+	if (paging_config.l5_required == !!(native_read_cr4() & X86_CR4_LA57))
+		goto out;
+
+	if (paging_config.l5_required) {
+		/*
+		 * For 4- to 5-level paging transition, set up current CR3 as
+		 * the first and the only entry in a new top-level page table.
+		 */
+		trampoline_32bit[TRAMPOLINE_32BIT_PGTABLE_OFFSET] = __native_read_cr3() | _PAGE_TABLE_NOENC;
+	} else {
+		unsigned long src;
+
+		/*
+		 * For 5- to 4-level paging transition, copy page table pointed
+		 * by first entry in the current top-level page table as our
+		 * new top-level page table.
+		 *
+		 * We cannot just point to the page table from trampoline as it
+		 * may be above 4G.
+		 */
+		src = *(unsigned long *)__native_read_cr3() & PAGE_MASK;
+		memcpy(trampoline_32bit + TRAMPOLINE_32BIT_PGTABLE_OFFSET / sizeof(unsigned long),
+		       (void *)src, PAGE_SIZE);
+	}
+
+out:
 	return paging_config;
 }
 
 void cleanup_trampoline(void)
 {
+	void *trampoline_pgtable;
+
+	trampoline_pgtable = trampoline_32bit + TRAMPOLINE_32BIT_PGTABLE_OFFSET;
+
+	/*
+	 * Move the top level page table out of trampoline memory,
+	 * if it's there.
+	 */
+	if ((void *)__native_read_cr3() == trampoline_pgtable) {
+		memcpy(top_pgtable, trampoline_pgtable, PAGE_SIZE);
+		native_write_cr3((unsigned long)top_pgtable);
+	}
+
 	/* Restore trampoline memory */
 	memcpy(trampoline_32bit, trampoline_save, TRAMPOLINE_32BIT_SIZE);
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
