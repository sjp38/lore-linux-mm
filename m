Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BEBC6B0287
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 07:41:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j7so11408980pgv.20
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 04:41:38 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d9si1301848plj.822.2017.12.04.04.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 04:41:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 2/5] x86/boot/compressed/64: Print error if 5-level paging is not supported
Date: Mon,  4 Dec 2017 15:40:56 +0300
Message-Id: <20171204124059.63515-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
References: <20171204124059.63515-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org

We cannot proceed booting if the machine doesn't support the paging mode
kernel was compiled for.

Getting error the usual way -- via validate_cpu() -- is not going to
work. We need to enable appropriate paging mode before that, otherwise
kernel would triple-fault during KASLR setup.

This code will go away once we get support for boot-time switching
between paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: <stable@vger.kernel.org>	[4.14+]
---
 arch/x86/boot/compressed/misc.c       | 16 ++++++++++++++++
 arch/x86/boot/compressed/pgtable_64.c |  2 +-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index b50c42455e25..f7f8d9f76e15 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -169,6 +169,16 @@ void __puthex(unsigned long value)
 	}
 }
 
+static int l5_supported(void)
+{
+	/* Check if leaf 7 is supported. */
+	if (native_cpuid_eax(0) < 7)
+		return 0;
+
+	/* Check if la57 is supported. */
+	return native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31));
+}
+
 #if CONFIG_X86_NEED_RELOCS
 static void handle_relocations(void *output, unsigned long output_len,
 			       unsigned long virt_addr)
@@ -362,6 +372,12 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
 	console_init();
 	debug_putstr("early console in extract_kernel\n");
 
+	if (IS_ENABLED(CONFIG_X86_5LEVEL) && !l5_supported()) {
+		error("This linux kernel as configured requires 5-level paging\n"
+			"This CPU does not support the required 'cr4.la57' feature\n"
+			"Unable to boot - please use a kernel appropriate for your CPU\n");
+	}
+
 	free_mem_ptr     = heap;	/* Heap */
 	free_mem_end_ptr = heap + BOOT_HEAP_SIZE;
 
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index eed3a2c3b577..7bcf03b376da 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -2,7 +2,7 @@
 
 int l5_paging_required(void)
 {
-	/* Check i leaf 7 is supported. */
+	/* Check if leaf 7 is supported. */
 	if (native_cpuid_eax(0) < 7)
 		return 0;
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
