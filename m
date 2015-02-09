Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAA2900015
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:46:05 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wp4so28399834obc.10
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:46:05 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id y4si6637849obg.53.2015.02.09.14.46.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:46:05 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
Date: Mon,  9 Feb 2015 15:45:34 -0700
Message-Id: <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

This patch implements huge I/O mapping capability interfaces on x86.

IOREMAP_MAX_ORDER is defined to the size of PUD on X86_64 and PMD
on x86_32.  When IOREMAP_MAX_ORDER is not defined on x86, it is
defined to the generic value in <linux/vmalloc.h>.

On x86, the huge I/O mapping may not be used when a target range is
covered by multiple MTRRs with different memory types.  The caller
must make a separate request for each MTRR range, or the huge I/O
mapping can be disabled with the kernel boot option "nohugeiomap".
The detail of this issue is described in the email below, and this
patch takes option C) in favor of simplicity since MTRRs are legacy
feature.
 https://lkml.org/lkml/2015/2/5/638

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/page_types.h |    8 ++++++++
 arch/x86/mm/ioremap.c             |   26 ++++++++++++++++++++++++--
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index f97fbe3..246426c 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -38,6 +38,14 @@
 
 #define __START_KERNEL		(__START_KERNEL_map + __PHYSICAL_START)
 
+#ifdef CONFIG_HUGE_IOMAP
+#ifdef CONFIG_X86_64
+#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
+#else
+#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
+#endif
+#endif  /* CONFIG_HUGE_IOMAP */
+
 #ifdef CONFIG_X86_64
 #include <asm/page_64_types.h>
 #else
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index fdf617c..f97b587 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -67,8 +67,14 @@ static int __ioremap_check_ram(unsigned long start_pfn, unsigned long nr_pages,
 
 /*
  * Remap an arbitrary physical address space into the kernel virtual
- * address space. Needed when the kernel wants to access high addresses
- * directly.
+ * address space. It transparently creates kernel huge I/O mapping when
+ * the physical address is aligned by a huge page size (1GB or 2MB) and
+ * the requested size is at least the huge page size.
+ *
+ * NOTE: The huge I/O mapping may not be used when a target range is
+ * covered by multiple MTRRs with different memory types. The caller
+ * must make a separate request for each MTRR range, or the huge I/O
+ * mapping can be disabled with the kernel boot option "nohugeiomap".
  *
  * NOTE! We need to allow non-page-aligned mappings too: we will obviously
  * have to convert them into an offset in a page-aligned mapping, but the
@@ -326,6 +332,22 @@ void iounmap(volatile void __iomem *addr)
 }
 EXPORT_SYMBOL(iounmap);
 
+#ifdef CONFIG_HUGE_IOMAP
+int arch_ioremap_pud_supported(void)
+{
+#ifdef CONFIG_X86_64
+	return cpu_has_gbpages;
+#else
+	return 0;
+#endif
+}
+
+int arch_ioremap_pmd_supported(void)
+{
+	return cpu_has_pse;
+}
+#endif	/* CONFIG_HUGE_IOMAP */
+
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
  * access

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
