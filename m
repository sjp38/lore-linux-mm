Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 332166B0072
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:15 -0500 (EST)
Received: by obcuz6 with SMTP id uz6so1304786obc.12
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:15 -0800 (PST)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id ix8si736618obc.59.2015.03.03.09.45.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:14 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 5/6] x86, mm: Support huge I/O mapping capability I/F
Date: Tue,  3 Mar 2015 10:44:23 -0700
Message-Id: <1425404664-19675-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

This patch implements huge I/O mapping capability interfaces
for ioremap() on x86.

IOREMAP_MAX_ORDER is defined to PUD_SHIFT on x86/64 and
PMD_SHIFT on x86/32, which overrides the default value
defined in <linux/vmalloc.h>.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/page_types.h |    2 ++
 arch/x86/mm/ioremap.c             |   23 +++++++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index 95e11f7..b526093 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -40,8 +40,10 @@
 
 #ifdef CONFIG_X86_64
 #include <asm/page_64_types.h>
+#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
 #else
 #include <asm/page_32_types.h>
+#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
 #endif	/* CONFIG_X86_64 */
 
 #ifndef __ASSEMBLY__
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index fdf617c..5ead4d6 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -67,8 +67,13 @@ static int __ioremap_check_ram(unsigned long start_pfn, unsigned long nr_pages,
 
 /*
  * Remap an arbitrary physical address space into the kernel virtual
- * address space. Needed when the kernel wants to access high addresses
- * directly.
+ * address space. It transparently creates kernel huge I/O mapping when
+ * the physical address is aligned by a huge page size (1GB or 2MB) and
+ * the requested size is at least the huge page size.
+ *
+ * NOTE: MTRRs can override PAT memory types with a 4KB granularity.
+ * Therefore, the mapping code falls back to use a smaller page toward 4KB
+ * when a mapping range is covered by non-WB type of MTRRs.
  *
  * NOTE! We need to allow non-page-aligned mappings too: we will obviously
  * have to convert them into an offset in a page-aligned mapping, but the
@@ -326,6 +331,20 @@ void iounmap(volatile void __iomem *addr)
 }
 EXPORT_SYMBOL(iounmap);
 
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
+
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
  * access

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
