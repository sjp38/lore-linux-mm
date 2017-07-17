Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2EF6B0494
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:33 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s20so437116qki.12
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:33 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0054.outbound.protection.outlook.com. [104.47.33.54])
        by mx.google.com with ESMTPS id w40si276146qth.8.2017.07.17.14.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:32 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 11/38] x86/mm: Add SME support for read_cr3_pa()
Date: Mon, 17 Jul 2017 16:10:08 -0500
Message-Id: <767b085c384a46f67f451f8589903a462c7ff68a.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

The cr3 register entry can contain the SME encryption mask that indicates
the PGD is encrypted.  The encryption mask should not be used when
creating a virtual address from the cr3 register, so remove the SME
encryption mask in the read_cr3_pa() function.

During early boot SME will need to use a native version of read_cr3_pa(),
so create native_read_cr3_pa().

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/processor-flags.h | 5 +++--
 arch/x86/include/asm/processor.h       | 5 +++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 79aa2f9..f5d3e50 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -2,6 +2,7 @@
 #define _ASM_X86_PROCESSOR_FLAGS_H
 
 #include <uapi/asm/processor-flags.h>
+#include <linux/mem_encrypt.h>
 
 #ifdef CONFIG_VM86
 #define X86_VM_MASK	X86_EFLAGS_VM
@@ -32,8 +33,8 @@
  * CR3_ADDR_MASK is the mask used by read_cr3_pa().
  */
 #ifdef CONFIG_X86_64
-/* Mask off the address space ID bits. */
-#define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
+/* Mask off the address space ID and SME encryption bits. */
+#define CR3_ADDR_MASK __sme_clr(0x7FFFFFFFFFFFF000ull)
 #define CR3_PCID_MASK 0xFFFull
 #else
 /*
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index a68f70c..973709d 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -240,6 +240,11 @@ static inline unsigned long read_cr3_pa(void)
 	return __read_cr3() & CR3_ADDR_MASK;
 }
 
+static inline unsigned long native_read_cr3_pa(void)
+{
+	return __native_read_cr3() & CR3_ADDR_MASK;
+}
+
 static inline void load_cr3(pgd_t *pgdir)
 {
 	write_cr3(__sme_pa(pgdir));
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
