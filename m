Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 549396B7CD2
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:51:17 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id c26so924728otl.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:51:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j5si417562oiw.131.2018.12.06.14.51.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 14:51:16 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V5 7/7] arm64: mm: Allow forcing all userspace addresses to 52-bit
Date: Thu,  6 Dec 2018 22:50:42 +0000
Message-Id: <20181206225042.11548-8-steve.capper@arm.com>
In-Reply-To: <20181206225042.11548-1-steve.capper@arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

On arm64 52-bit VAs are provided to userspace when a hint is supplied to
mmap. This helps maintain compatibility with software that expects at
most 48-bit VAs to be returned.

In order to help identify software that has 48-bit VA assumptions, this
patch allows one to compile a kernel where 52-bit VAs are returned by
default on HW that supports it.

This feature is intended to be for development systems only.

Signed-off-by: Steve Capper <steve.capper@arm.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/Kconfig                 | 13 +++++++++++++
 arch/arm64/include/asm/elf.h       |  4 ++++
 arch/arm64/include/asm/processor.h |  9 ++++++++-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6a93d5bc7f76..12658f05bb41 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1165,6 +1165,19 @@ config ARM64_CNP
 	  at runtime, and does not affect PEs that do not implement
 	  this feature.
 
+config ARM64_FORCE_52BIT
+	bool "Force 52-bit virtual addresses for userspace"
+	depends on ARM64_52BIT_VA && EXPERT
+	help
+	  For systems with 52-bit userspace VAs enabled, the kernel will attempt
+	  to maintain compatibility with older software by providing 48-bit VAs
+	  unless a hint is supplied to mmap.
+
+	  This configuration option disables the 48-bit compatibility logic, and
+	  forces all userspace addresses to be 52-bit on HW that supports it. One
+	  should only enable this configuration option for stress testing userspace
+	  memory management code. If unsure say N here.
+
 endmenu
 
 config ARM64_SVE
diff --git a/arch/arm64/include/asm/elf.h b/arch/arm64/include/asm/elf.h
index bc9bd9e77d9d..6adc1a90e7e6 100644
--- a/arch/arm64/include/asm/elf.h
+++ b/arch/arm64/include/asm/elf.h
@@ -117,7 +117,11 @@
  * 64-bit, this is above 4GB to leave the entire 32-bit address
  * space open for things that want to use the area for 32-bit pointers.
  */
+#ifdef CONFIG_ARM64_FORCE_52BIT
+#define ELF_ET_DYN_BASE		(2 * TASK_SIZE_64 / 3)
+#else
 #define ELF_ET_DYN_BASE		(2 * DEFAULT_MAP_WINDOW_64 / 3)
+#endif /* CONFIG_ARM64_FORCE_52BIT */
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index b363fc705be4..9abd91570b5b 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -65,8 +65,13 @@ extern u64 vabits_user;
 #define DEFAULT_MAP_WINDOW	DEFAULT_MAP_WINDOW_64
 #endif /* CONFIG_COMPAT */
 
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
+#ifdef CONFIG_ARM64_FORCE_52BIT
+#define STACK_TOP_MAX		TASK_SIZE_64
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 4))
+#else
 #define STACK_TOP_MAX		DEFAULT_MAP_WINDOW_64
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
+#endif /* CONFIG_ARM64_FORCE_52BIT */
 
 #ifdef CONFIG_COMPAT
 #define AARCH32_VECTORS_BASE	0xffff0000
@@ -76,12 +81,14 @@ extern u64 vabits_user;
 #define STACK_TOP		STACK_TOP_MAX
 #endif /* CONFIG_COMPAT */
 
+#ifndef CONFIG_ARM64_FORCE_52BIT
 #define arch_get_mmap_end(addr) ((addr > DEFAULT_MAP_WINDOW) ? TASK_SIZE :\
 				DEFAULT_MAP_WINDOW)
 
 #define arch_get_mmap_base(addr, base) ((addr > DEFAULT_MAP_WINDOW) ? \
 					base + TASK_SIZE - DEFAULT_MAP_WINDOW :\
 					base)
+#endif /* CONFIG_ARM64_FORCE_52BIT */
 
 extern phys_addr_t arm64_dma_phys_limit;
 #define ARCH_LOW_ADDRESS_LIMIT	(arm64_dma_phys_limit - 1)
-- 
2.19.2
