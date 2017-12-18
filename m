Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80E096B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:13:26 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j4so9712184wrg.15
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 08:13:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b14si4453487wra.462.2017.12.18.08.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 08:13:25 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 038/178] x86/boot/compressed/64: Print error if 5-level paging is not supported
Date: Mon, 18 Dec 2017 16:47:54 +0100
Message-Id: <20171218152922.135507048@linuxfoundation.org>
In-Reply-To: <20171218152920.567991776@linuxfoundation.org>
References: <20171218152920.567991776@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

commit 6d7e0ba2d2be9e50cccba213baf07e0e183c1b24 upstream.

If the machine does not support the paging mode for which the kernel was
compiled, the boot process cannot continue.

It's not possible to let the kernel detect the mismatch as it does not even
reach the point where cpu features can be evaluted due to a triple fault in
the KASLR setup.

Instead of instantaneous silent reboot, emit an error message which gives
the user the information why the boot fails.

Fixes: 77ef56e4f0fb ("x86: Enable 5-level paging support via CONFIG_X86_5LEVEL=y")
Reported-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Borislav Petkov <bp@suse.de>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/20171204124059.63515-3-kirill.shutemov@linux.intel.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/boot/compressed/misc.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -169,6 +169,16 @@ void __puthex(unsigned long value)
 	}
 }
 
+static bool l5_supported(void)
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
@@ -362,6 +372,12 @@ asmlinkage __visible void *extract_kerne
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
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
