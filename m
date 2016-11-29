Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 667056B026B
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:56:07 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id n6so116807950qtd.4
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:56:07 -0800 (PST)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id q45si28258987qtf.38.2016.11.29.10.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:56:06 -0800 (PST)
Received: by mail-qk0-f174.google.com with SMTP id x190so184733361qkb.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:56:06 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 10/10] arm64: Add support for CONFIG_DEBUG_VIRTUAL
Date: Tue, 29 Nov 2016 10:55:29 -0800
Message-Id: <1480445729-27130-11-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-1-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


x86 has an option CONFIG_DEBUG_VIRTUAL to do additional checks
on virt_to_phys calls. The goal is to catch users who are calling
virt_to_phys on non-linear addresses immediately. This inclues callers
using virt_to_phys on image addresses instead of __pa_symbol. As features
such as CONFIG_VMAP_STACK get enabled for arm64, this becomes increasingly
important. Add checks to catch bad virt_to_phys usage.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v4: Refactored virt_to_phys macros for better reuse per suggestions.
---
 arch/arm64/Kconfig              |  1 +
 arch/arm64/include/asm/memory.h | 31 ++++++++++++++++++++++++++++---
 arch/arm64/mm/Makefile          |  2 ++
 arch/arm64/mm/physaddr.c        | 28 ++++++++++++++++++++++++++++
 4 files changed, 59 insertions(+), 3 deletions(-)
 create mode 100644 arch/arm64/mm/physaddr.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 969ef88..83b95bc 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -6,6 +6,7 @@ config ARM64
 	select ACPI_MCFG if ACPI
 	select ACPI_SPCR_TABLE if ACPI
 	select ARCH_CLOCKSOURCE_DATA
+	select ARCH_HAS_DEBUG_VIRTUAL
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
 	select ARCH_HAS_ELF_RANDOMIZE
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index a219d3f..41ee96f 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -167,10 +167,33 @@ extern u64			kimage_voffset;
  * private definitions which should NOT be used outside memory.h
  * files.  Use virt_to_phys/phys_to_virt/__pa/__va instead.
  */
-#define __virt_to_phys(x) ({						\
+
+
+/*
+ * The linear kernel range starts in the middle of the virtual adddress
+ * space. Testing the top bit for the start of the region is a
+ * sufficient check.
+ */
+#define __is_lm_address(addr)	(!!((addr) & BIT(VA_BITS - 1)))
+
+#define __lm_to_phys(addr)	(((addr) & ~PAGE_OFFSET) + PHYS_OFFSET)
+#define __kimg_to_phys(addr)	((addr) - kimage_voffset)
+
+#define __virt_to_phys_nodebug(x) ({					\
 	phys_addr_t __x = (phys_addr_t)(x);				\
-	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
-				 (__x - kimage_voffset); })
+	__is_lm_address(__x) ? __lm_to_phys(__x) :			\
+			       __kimg_to_phys(__x);			\
+})
+
+#define __pa_symbol_nodebug(x)	__kimg_to_phys((phys_addr_t)(x))
+
+#ifdef CONFIG_DEBUG_VIRTUAL
+extern phys_addr_t __virt_to_phys(unsigned long x);
+extern phys_addr_t __phys_addr_symbol(unsigned long x);
+#else
+#define __virt_to_phys(x)	__virt_to_phys_nodebug(x)
+#define __phys_addr_symbol(x)	__pa_symbol_nodebug(x)
+#endif
 
 #define __phys_to_virt(x)	((unsigned long)((x) - PHYS_OFFSET) | PAGE_OFFSET)
 #define __phys_to_kimg(x)	((unsigned long)((x) + kimage_voffset))
@@ -202,6 +225,8 @@ static inline void *phys_to_virt(phys_addr_t x)
  * Drivers should NOT use these either.
  */
 #define __pa(x)			__virt_to_phys((unsigned long)(x))
+#define __pa_symbol(x)		__phys_addr_symbol(RELOC_HIDE((unsigned long)(x), 0))
+#define __pa_nodebug(x)		__virt_to_phys_nodebug((unsigned long)(x))
 #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 #define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 54bb209..38d3811 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -5,6 +5,8 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
 obj-$(CONFIG_NUMA)		+= numa.o
+obj-$(CONFIG_DEBUG_VIRTUAL)	+= physaddr.o
+KASAN_SANITIZE_physaddr.o	+= n
 
 obj-$(CONFIG_KASAN)		+= kasan_init.o
 KASAN_SANITIZE_kasan_init.o	:= n
diff --git a/arch/arm64/mm/physaddr.c b/arch/arm64/mm/physaddr.c
new file mode 100644
index 0000000..6684f43
--- /dev/null
+++ b/arch/arm64/mm/physaddr.c
@@ -0,0 +1,28 @@
+#include <linux/bug.h>
+#include <linux/export.h>
+#include <linux/types.h>
+#include <linux/mmdebug.h>
+#include <linux/mm.h>
+
+#include <asm/memory.h>
+
+phys_addr_t __virt_to_phys(unsigned long x)
+{
+	WARN(!__is_lm_address(x),
+	     "virt_to_phys used for non-linear address :%pK\n", (void *)x);
+
+	return __virt_to_phys_nodebug(x);
+}
+EXPORT_SYMBOL(__virt_to_phys);
+
+phys_addr_t __phys_addr_symbol(unsigned long x)
+{
+	/*
+	 * This is bounds checking against the kernel image only.
+	 * __pa_symbol should only be used on kernel symbol addresses.
+	 */
+	VIRTUAL_BUG_ON(x < (unsigned long) KERNEL_START ||
+		       x > (unsigned long) KERNEL_END);
+	return __pa_symbol_nodebug(x);
+}
+EXPORT_SYMBOL(__phys_addr_symbol);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
