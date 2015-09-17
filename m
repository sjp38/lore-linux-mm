Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6B22182F64
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:38:25 -0400 (EDT)
Received: by lamp12 with SMTP id p12so7459253lam.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:24 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id dy8si1522683lbb.55.2015.09.17.02.38.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 02:38:24 -0700 (PDT)
Received: by lanb10 with SMTP id b10so7526679lan.3
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:24 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v6 3/6] x86, efi, kasan: #undef memset/memcpy/memmove per arch.
Date: Thu, 17 Sep 2015 12:38:09 +0300
Message-Id: <1442482692-6416-4-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Matt Fleming <matt.fleming@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-efi@vger.kernel.org, fengguang.wu@intel.com, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>

In not-instrumented code KASAN replaces instrumented
memset/memcpy/memmove with not-instrumented analogues
__memset/__memcpy/__memove.
However, on x86 the EFI stub is not linked with the kernel.
It uses not-instrumented mem*() functions from
arch/x86/boot/compressed/string.c
So we don't replace them with __mem*() variants in EFI stub.

On ARM64 the EFI stub is linked with the kernel, so we should
replace mem*() functions with __mem*(), because the EFI stub
runs before KASAN sets up early shadow.

So let's move these #undef mem* into arch's asm/efi.h which is
also included by the EFI stub.

Also, this will fix the warning in 32-bit build reported by
kbuild test robot <fengguang.wu@intel.com>:
	efi-stub-helper.c:599:2: warning: implicit declaration of function 'memcpy'

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
---
 arch/x86/include/asm/efi.h             | 12 ++++++++++++
 drivers/firmware/efi/libstub/efistub.h |  4 ----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/efi.h b/arch/x86/include/asm/efi.h
index 155162e..6db2742 100644
--- a/arch/x86/include/asm/efi.h
+++ b/arch/x86/include/asm/efi.h
@@ -86,6 +86,18 @@ extern u64 asmlinkage efi_call(void *fp, ...);
 extern void __iomem *__init efi_ioremap(unsigned long addr, unsigned long size,
 					u32 type, u64 attribute);
 
+/*
+ * CONFIG_KASAN may redefine memset to __memset.
+ * __memset function is present only in kernel binary.
+ * Since the EFI stub linked into a separate binary it
+ * doesn't have __memset(). So we should use standard
+ * memset from arch/x86/boot/compressed/string.c
+ * The same applies to memcpy and memmove.
+ */
+#undef memcpy
+#undef memset
+#undef memmove
+
 #endif /* CONFIG_X86_32 */
 
 extern struct efi_scratch efi_scratch;
diff --git a/drivers/firmware/efi/libstub/efistub.h b/drivers/firmware/efi/libstub/efistub.h
index e334a01..6b6548f 100644
--- a/drivers/firmware/efi/libstub/efistub.h
+++ b/drivers/firmware/efi/libstub/efistub.h
@@ -5,10 +5,6 @@
 /* error code which can't be mistaken for valid address */
 #define EFI_ERROR	(~0UL)
 
-#undef memcpy
-#undef memset
-#undef memmove
-
 void efi_char16_printk(efi_system_table_t *, efi_char16_t *);
 
 efi_status_t efi_open_volume(efi_system_table_t *sys_table_arg, void *__image,
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
