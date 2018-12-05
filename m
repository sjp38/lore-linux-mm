Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8376B7550
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:42:13 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id b18so12674905oii.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:42:13 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c189si8702063oia.80.2018.12.05.08.42.11
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:42:11 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 6/6] arm64: mm: Allow forcing all userspace addresses to 52-bit
Date: Wed,  5 Dec 2018 16:41:45 +0000
Message-Id: <20181205164145.24568-7-steve.capper@arm.com>
In-Reply-To: <20181205164145.24568-1-steve.capper@arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

On arm64 52-bit VAs are provided to userspace when a hint is supplied to
mmap. This helps maintain compatibility with software that expects at
most 48-bit VAs to be returned.

In order to help identify software that has 48-bit VA assumptions, this
patch allows one to compile a kernel where 52-bit VAs are returned by
default on HW that supports it.

This feature is intended to be for development systems only.

Signed-off-by: Steve Capper <steve.capper@arm.com>
---
 arch/arm64/Kconfig                 | 13 +++++++++++++
 arch/arm64/include/asm/elf.h       |  4 ++++
 arch/arm64/include/asm/processor.h |  9 ++++++++-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eab02d24f5d1..9f50dc8af110 100644
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
