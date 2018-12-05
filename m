Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E24416B7548
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:42:04 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id t184so12456484oih.22
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:42:04 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d64si9016062oia.186.2018.12.05.08.42.02
        for <linux-mm@kvack.org>;
        Wed, 05 Dec 2018 08:42:03 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V4 2/6] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Date: Wed,  5 Dec 2018 16:41:41 +0000
Message-Id: <20181205164145.24568-3-steve.capper@arm.com>
In-Reply-To: <20181205164145.24568-1-steve.capper@arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com, Steve Capper <steve.capper@arm.com>

We wish to introduce a 52-bit virtual address space for userspace but
maintain compatibility with software that assumes the maximum VA space
size is 48 bit.

In order to achieve this, on 52-bit VA systems, we make mmap behave as
if it were running on a 48-bit VA system (unless userspace explicitly
requests a VA where addr[51:48] != 0).

On a system running a 52-bit userspace we need TASK_SIZE to represent
the 52-bit limit as it is used in various places to distinguish between
kernelspace and userspace addresses.

Thus we need a new limit for mmap, stack, ELF loader and EFI (which uses
TTBR0) to represent the non-extended VA space.

This patch introduces DEFAULT_MAP_WINDOW and DEFAULT_MAP_WINDOW_64 and
switches the appropriate logic to use that instead of TASK_SIZE.

Signed-off-by: Steve Capper <steve.capper@arm.com>

---

Changed in V3: corrections to allow COMPAT 32-bit EL0 mode to work
---
 arch/arm64/include/asm/elf.h            |  2 +-
 arch/arm64/include/asm/processor.h      | 10 ++++++++--
 arch/arm64/mm/init.c                    |  2 +-
 drivers/firmware/efi/arm-runtime.c      |  2 +-
 drivers/firmware/efi/libstub/arm-stub.c |  2 +-
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/include/asm/elf.h b/arch/arm64/include/asm/elf.h
index 433b9554c6a1..bc9bd9e77d9d 100644
--- a/arch/arm64/include/asm/elf.h
+++ b/arch/arm64/include/asm/elf.h
@@ -117,7 +117,7 @@
  * 64-bit, this is above 4GB to leave the entire 32-bit address
  * space open for things that want to use the area for 32-bit pointers.
  */
-#define ELF_ET_DYN_BASE		(2 * TASK_SIZE_64 / 3)
+#define ELF_ET_DYN_BASE		(2 * DEFAULT_MAP_WINDOW_64 / 3)
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index 3e2091708b8e..50586ca6bacb 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -45,19 +45,25 @@
  * TASK_SIZE - the maximum size of a user space task.
  * TASK_UNMAPPED_BASE - the lower boundary of the mmap VM area.
  */
+
+#define DEFAULT_MAP_WINDOW_64	(UL(1) << VA_BITS)
+
 #ifdef CONFIG_COMPAT
 #define TASK_SIZE_32		UL(0x100000000)
 #define TASK_SIZE		(test_thread_flag(TIF_32BIT) ? \
 				TASK_SIZE_32 : TASK_SIZE_64)
 #define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_32BIT) ? \
 				TASK_SIZE_32 : TASK_SIZE_64)
+#define DEFAULT_MAP_WINDOW	(test_thread_flag(TIF_32BIT) ? \
+				TASK_SIZE_32 : DEFAULT_MAP_WINDOW_64)
 #else
 #define TASK_SIZE		TASK_SIZE_64
+#define DEFAULT_MAP_WINDOW	DEFAULT_MAP_WINDOW_64
 #endif /* CONFIG_COMPAT */
 
-#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 4))
+#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
+#define STACK_TOP_MAX		DEFAULT_MAP_WINDOW_64
 
-#define STACK_TOP_MAX		TASK_SIZE_64
 #ifdef CONFIG_COMPAT
 #define AARCH32_VECTORS_BASE	0xffff0000
 #define STACK_TOP		(test_thread_flag(TIF_32BIT) ? \
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 9d9582cac6c4..7239c103be06 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -609,7 +609,7 @@ void __init mem_init(void)
 	 * detected at build time already.
 	 */
 #ifdef CONFIG_COMPAT
-	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
+	BUILD_BUG_ON(TASK_SIZE_32 > DEFAULT_MAP_WINDOW_64);
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index 922cfb813109..952cec5b611a 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -38,7 +38,7 @@ static struct ptdump_info efi_ptdump_info = {
 	.mm		= &efi_mm,
 	.markers	= (struct addr_marker[]){
 		{ 0,		"UEFI runtime start" },
-		{ TASK_SIZE_64,	"UEFI runtime end" }
+		{ DEFAULT_MAP_WINDOW_64, "UEFI runtime end" }
 	},
 	.base_addr	= 0,
 };
diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware/efi/libstub/arm-stub.c
index 30ac0c975f8a..d1ec7136e3e1 100644
--- a/drivers/firmware/efi/libstub/arm-stub.c
+++ b/drivers/firmware/efi/libstub/arm-stub.c
@@ -33,7 +33,7 @@
 #define EFI_RT_VIRTUAL_SIZE	SZ_512M
 
 #ifdef CONFIG_ARM64
-# define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE_64
+# define EFI_RT_VIRTUAL_LIMIT	DEFAULT_MAP_WINDOW_64
 #else
 # define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE
 #endif
-- 
2.19.2
