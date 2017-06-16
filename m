Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17E983293
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:51:05 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m19so34117494ioe.12
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:51:05 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0057.outbound.protection.outlook.com. [104.47.34.57])
        by mx.google.com with ESMTPS id j201si3986000itb.78.2017.06.16.11.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:51:03 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 06/36] x86/mm: Add Secure Memory Encryption (SME) support
Date: Fri, 16 Jun 2017 13:50:54 -0500
Message-ID: <20170616185054.18967.52228.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add support for Secure Memory Encryption (SME). This initial support
provides a Kconfig entry to build the SME support into the kernel and
defines the memory encryption mask that will be used in subsequent
patches to mark pages as encrypted.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/Kconfig                   |   26 ++++++++++++++++++++++++++
 arch/x86/include/asm/mem_encrypt.h |   30 ++++++++++++++++++++++++++++++
 arch/x86/mm/Makefile               |    1 +
 arch/x86/mm/mem_encrypt.c          |   21 +++++++++++++++++++++
 include/linux/mem_encrypt.h        |   35 +++++++++++++++++++++++++++++++++++
 5 files changed, 113 insertions(+)
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/mm/mem_encrypt.c
 create mode 100644 include/linux/mem_encrypt.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7c991d0..cf74791 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1407,6 +1407,32 @@ config X86_DIRECT_GBPAGES
 	  supports them), so don't confuse the user by printing
 	  that we have them enabled.
 
+config ARCH_HAS_MEM_ENCRYPT
+	def_bool y
+	depends on X86
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
