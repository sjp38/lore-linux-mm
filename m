Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 187B66B03A1
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:14 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g6so423469qkf.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:14 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0077.outbound.protection.outlook.com. [104.47.33.77])
        by mx.google.com with ESMTPS id 131si219604qkg.359.2017.07.17.14.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:12 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 06/38] x86/mm: Add Secure Memory Encryption (SME) support
Date: Mon, 17 Jul 2017 16:10:03 -0500
Message-Id: <a6c34d16caaed3bc3e2d6f0987554275bd291554.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Add support for Secure Memory Encryption (SME). This initial support
provides a Kconfig entry to build the SME support into the kernel and
defines the memory encryption mask that will be used in subsequent
patches to mark pages as encrypted.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/Kconfig                   | 25 +++++++++++++++++++++++++
 arch/x86/include/asm/mem_encrypt.h | 30 ++++++++++++++++++++++++++++++
 arch/x86/mm/Makefile               |  1 +
 arch/x86/mm/mem_encrypt.c          | 21 +++++++++++++++++++++
 include/linux/mem_encrypt.h        | 35 +++++++++++++++++++++++++++++++++++
 5 files changed, 112 insertions(+)
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/mm/mem_encrypt.c
 create mode 100644 include/linux/mem_encrypt.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 781521b..ba7b93d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1415,6 +1415,31 @@ config X86_DIRECT_GBPAGES
 	  supports them), so don't confuse the user by printing
 	  that we have them enabled.
 
+config ARCH_HAS_MEM_ENCRYPT
+	def_bool y
+
+config AMD_MEM_ENCRYPT
+	bool "AMD Secure Memory Encryption (SME) support"
+	depends on X86_64 && CPU_SUP_AMD
+	---help---
+	  Say yes to enable support for the encryption of system memory.
+	  This requires an AMD processor that supports Secure Memory
+	  Encryption (SME).
+
+config AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT
+	bool "Activate AMD Secure Memory Encryption (SME) by default"
+	default y
+	depends on AMD_MEM_ENCRYPT
+	---help---
+	  Say yes to have system memory encrypted by default if running on
+	  an AMD processor that supports Secure Memory Encryption (SME).
+
+	  If set to Y, then the encryption of system memory can be
+	  deactivated with the mem_encrypt=off command line option.
+
+	  If set to N, then the encryption of system memory can be
+	  activated with the mem_encrypt=on command line option.
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
new file mode 100644
index 0000000..a105796
--- /dev/null
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -0,0 +1,30 @@
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
+#else	/* !CONFIG_AMD_MEM_ENCRYPT */
+
+#define sme_me_mask	0UL
+
+#endif	/* CONFIG_AMD_MEM_ENCRYPT */
+
+#endif	/* __ASSEMBLY__ */
+
+#endif	/* __X86_MEM_ENCRYPT_H__ */
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 0fbdcb6..a94a7b6 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -39,3 +39,4 @@ obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
 
+obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
new file mode 100644
index 0000000..b99d469
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt.c
@@ -0,0 +1,21 @@
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
+/*
+ * Since SME related variables are set early in the boot process they must
+ * reside in the .data section so as not to be zeroed out when the .bss
+ * section is later cleared.
+ */
+unsigned long sme_me_mask __section(.data) = 0;
+EXPORT_SYMBOL_GPL(sme_me_mask);
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
new file mode 100644
index 0000000..59769f7
--- /dev/null
+++ b/include/linux/mem_encrypt.h
@@ -0,0 +1,35 @@
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
+#ifndef __MEM_ENCRYPT_H__
+#define __MEM_ENCRYPT_H__
+
+#ifndef __ASSEMBLY__
+
+#ifdef CONFIG_ARCH_HAS_MEM_ENCRYPT
+
+#include <asm/mem_encrypt.h>
+
+#else	/* !CONFIG_ARCH_HAS_MEM_ENCRYPT */
+
+#define sme_me_mask	0UL
+
+#endif	/* CONFIG_ARCH_HAS_MEM_ENCRYPT */
+
+static inline bool sme_active(void)
+{
+	return !!sme_me_mask;
+}
+
+#endif	/* __ASSEMBLY__ */
+
+#endif	/* __MEM_ENCRYPT_H__ */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
