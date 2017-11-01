Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E63F6B0069
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:55:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v78so2081705pfk.8
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 04:55:12 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v18si778520pge.275.2017.11.01.04.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 04:55:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] x86/boot/compressed/64: Compile pagetable.c unconditionally
Date: Wed,  1 Nov 2017 14:55:00 +0300
Message-Id: <20171101115503.18358-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to put few helpers into pagetable.c that are not specific
to KASLR.

Let's make compilation of the file independent of KASLR and wrap
KASLR-depended code into ifdef.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/Makefile    | 2 +-
 arch/x86/boot/compressed/pagetable.c | 5 +++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 65a150a7f15c..f7b64ecd09b3 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -77,7 +77,7 @@ vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/head_$(BITS).o $(obj)/misc.o \
 vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
-	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
+	vmlinux-objs-y += $(obj)/pagetable.o
 endif
 
 $(obj)/eboot.o: KBUILD_CFLAGS += -fshort-wchar -mno-red-zone
diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index f1aa43854bed..a15bbfcb3413 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -27,6 +27,9 @@
 /* These actually do the work of building the kernel identity maps. */
 #include <asm/init.h>
 #include <asm/pgtable.h>
+
+#ifdef CONFIG_RANDOMIZE_BASE
+
 /* Use the static base for this part of the boot process */
 #undef __PAGE_OFFSET
 #define __PAGE_OFFSET __PAGE_OFFSET_BASE
@@ -149,3 +152,5 @@ void finalize_identity_maps(void)
 {
 	write_cr3(top_level_pgt);
 }
+
+#endif /* CONFIG_RANDOMIZE_BASE */
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
