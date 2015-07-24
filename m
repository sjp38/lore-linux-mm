Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF896B0255
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:32 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so16070196pdb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:31 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id l14si21899972pdn.60.2015.07.24.09.42.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:31 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS000J5Q3QRSS60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:27 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 1/7] x86/kasan: generate KASAN_SHADOW_OFFSET in Makefile
Date: Fri, 24 Jul 2015 19:41:53 +0300
Message-id: <1437756119-12817-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Michal Marek <mmarek@suse.com>, linux-kbuild@vger.kernel.org

ARM64 has several different address space layouts and its
going to have one more at least. Different address space layouts
have different shadow offsets, so every new layout require adding
new default value for CONFIG_KASAN_SHADOW_OFFSET.
It's possible to generate KASAN_SHADOW_OFFSET in Makefile, so
the shadow address for every possible layout will be auto-generated.

However, we should do this in x86 too, because generic code
depend on having CONFIG_KASAN_SHADOW_OFFSET.
There is no functional changes here.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/Kconfig             |  5 -----
 arch/x86/Makefile            |  2 ++
 arch/x86/include/asm/kasan.h | 21 +++++++++++++--------
 include/linux/kasan.h        |  1 -
 scripts/Makefile.kasan       |  2 +-
 5 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b3a1a5d..6d6dd6f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -255,11 +255,6 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
 config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	def_bool y
 
-config KASAN_SHADOW_OFFSET
-	hex
-	depends on KASAN
-	default 0xdffffc0000000000
-
 config HAVE_INTEL_TXT
 	def_bool y
 	depends on INTEL_IOMMU && ACPI
diff --git a/arch/x86/Makefile b/arch/x86/Makefile
index 118e6de..c666989 100644
--- a/arch/x86/Makefile
+++ b/arch/x86/Makefile
@@ -39,6 +39,8 @@ ifdef CONFIG_X86_NEED_RELOCS
         LDFLAGS_vmlinux := --emit-relocs
 endif
 
+KASAN_SHADOW_OFFSET := 0xdffffc0000000000
+
 ifeq ($(CONFIG_X86_32),y)
         BITS := 32
         UTS_MACHINE := i386
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index 74a2a8d..88881f6 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -1,17 +1,22 @@
 #ifndef _ASM_X86_KASAN_H
 #define _ASM_X86_KASAN_H
 
-/*
- * Compiler uses shadow offset assuming that addresses start
- * from 0. Kernel addresses don't start from 0, so shadow
- * for kernel really starts from compiler's shadow offset +
- * 'kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT
- */
-#define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
-					(0xffff800000000000ULL >> 3))
+#define KASAN_SHADOW_START      (0xffffec0000000000ULL)
 /* 47 bits for kernel address -> (47 - 3) bits for shadow */
 #define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (47 - 3)))
 
+/*
+ * This value is used to map an address to the corresponding shadow
+ * address by the following formula:
+ *	shadow_addr = (address >> 3) + KASAN_SHADOW_OFFSET;
+ *
+ * (1 << 61) shadow addresses - [KASAN_SHADOW_OFFSET,KASAN_SHADOW_END]
+ * cover all 64-bits of virtual addresses. So KASAN_SHADOW_OFFSET
+ * should satisfy the following equation:
+ *      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)
+ */
+#define KASAN_SHADOW_OFFSET (KASAN_SHADOW_END - (1UL << (64 - 3)))
+
 #ifndef __ASSEMBLY__
 
 #ifdef CONFIG_KASAN
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5486d77..6fb1c7d 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -10,7 +10,6 @@ struct vm_struct;
 #ifdef CONFIG_KASAN
 
 #define KASAN_SHADOW_SCALE_SHIFT 3
-#define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
 
 #include <asm/kasan.h>
 #include <linux/sched.h>
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 3f874d2..19d9a61 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -8,7 +8,7 @@ endif
 CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
-		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
+		-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
 		--param asan-stack=1 --param asan-globals=1 \
 		--param asan-instrumentation-with-call-threshold=$(call_threshold))
 
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
