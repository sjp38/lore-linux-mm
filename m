Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 370756B0265
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:36:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c189so34520187oia.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:36:21 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0072.outbound.protection.outlook.com. [104.47.42.72])
        by mx.google.com with ESMTPS id 18si95844oie.62.2016.08.22.15.36.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:36:20 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 04/20] x86: Secure Memory Encryption (SME) support
Date: Mon, 22 Aug 2016 17:36:10 -0500
Message-ID: <20160822223610.29880.21739.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Provide support for Secure Memory Encryption (SME). This initial support
defines the memory encryption mask as a variable for quick access and an
accessor for retrieving the number of physical addressing bits lost if
SME is enabled.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   37 ++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/Makefile           |    2 ++
 arch/x86/kernel/mem_encrypt.S      |   29 ++++++++++++++++++++++++++++
 arch/x86/kernel/x8664_ksyms_64.c   |    6 ++++++
 4 files changed, 74 insertions(+)
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/kernel/mem_encrypt.S

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
new file mode 100644
index 0000000..747fc52
--- /dev/null
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -0,0 +1,37 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __X86_MEM_ENCRYPT_H__
+#define __X86_MEM_ENCRYPT_H__
+
+#ifndef __ASSEMBLY__
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+
+extern unsigned long sme_me_mask;
+
+u8 sme_get_me_loss(void);
+
+#else	/* !CONFIG_AMD_MEM_ENCRYPT */
+
+#define sme_me_mask		0UL
+
+static inline u8 sme_get_me_loss(void)
+{
+	return 0;
+}
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
+#endif	/* __ASSEMBLY__ */
+
+#endif	/* __X86_MEM_ENCRYPT_H__ */
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 0503f5b..bda997f 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -125,6 +125,8 @@ obj-$(CONFIG_EFI)			+= sysfb_efi.o
 obj-$(CONFIG_PERF_EVENTS)		+= perf_regs.o
 obj-$(CONFIG_TRACING)			+= tracepoint.o
 
+obj-y					+= mem_encrypt.o
+
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
new file mode 100644
index 0000000..ef7f325
--- /dev/null
+++ b/arch/x86/kernel/mem_encrypt.S
@@ -0,0 +1,29 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/linkage.h>
+
+	.text
+	.code64
+ENTRY(sme_get_me_loss)
+	xor	%rax, %rax
+	mov	sme_me_loss(%rip), %al
+	ret
+ENDPROC(sme_get_me_loss)
+
+	.data
+	.align 16
+ENTRY(sme_me_mask)
+	.quad	0x0000000000000000
+sme_me_loss:
+	.byte	0x00
+	.align	8
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index 95e49f6..651c4c8 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -12,6 +12,7 @@
 #include <asm/uaccess.h>
 #include <asm/desc.h>
 #include <asm/ftrace.h>
+#include <asm/mem_encrypt.h>
 
 #ifdef CONFIG_FUNCTION_TRACER
 /* mcount and __fentry__ are defined in assembly */
@@ -83,3 +84,8 @@ EXPORT_SYMBOL(native_load_gs_index);
 EXPORT_SYMBOL(___preempt_schedule);
 EXPORT_SYMBOL(___preempt_schedule_notrace);
 #endif
+
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+EXPORT_SYMBOL_GPL(sme_me_mask);
+EXPORT_SYMBOL_GPL(sme_get_me_loss);
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
