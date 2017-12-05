Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E81F26B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:00:01 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z1so217700pfl.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:00:01 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u23si129256pfh.265.2017.12.05.06.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 06:00:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 1/4] x86/boot/compressed/64: Fix build with GCC < 5
Date: Tue,  5 Dec 2017 16:59:39 +0300
Message-Id: <20171205135942.24634-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

0-day reported this build error:

   arch/x86/boot/compressed/pgtable_64.o: In function `l5_paging_required':
   pgtable_64.c:(.text+0x22): undefined reference to `__force_order'

The issue is only with GCC < 5 and when KASLR is disabled. Newer GCC
works fine.

__force_order is used by special_insns.h asm code to force instruction
serialization.

It doesn't actually referenced from the code, but GCC < 5 with -fPIE
would still generate undefined symbol.

I didn't noticed this before and failed to move __force_order definition
from pagetable.c (which compiles only with KASLR enabled) to
pgtable_64.c.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 10c9a5346f72 ("x86/boot/compressed/64: Detect and handle 5-level paging at boot-time")
Cc: stable@vger.kernel.org
---
 arch/x86/boot/compressed/pagetable.c  |  3 ---
 arch/x86/boot/compressed/pgtable_64.c | 11 +++++++++++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index 6bd51de4475c..250826ac216e 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -38,9 +38,6 @@
 #define __PAGE_OFFSET __PAGE_OFFSET_BASE
 #include "../../mm/ident_map.c"
 
-/* Used by pgtable.h asm code to force instruction serialization. */
-unsigned long __force_order;
-
 /* Used to track our page table allocation area. */
 struct alloc_pgt_data {
 	unsigned char *pgt_buf;
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 7bcf03b376da..491fa2d08bca 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -1,5 +1,16 @@
 #include <asm/processor.h>
 
+/*
+ * __force_order is used by special_insns.h asm code to force instruction
+ * serialization.
+ *
+ * It doesn't actually referenced from the code, but GCC < 5 with -fPIE
+ * would still generate undefined symbol.
+ *
+ * Let's workaround this by defining the variable.
+ */
+unsigned long __force_order;
+
 int l5_paging_required(void)
 {
 	/* Check if leaf 7 is supported. */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
