Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id DFAB36B00C0
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:18:51 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so11567459obc.35
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:18:51 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id d126si1761286oia.135.2014.11.04.14.18.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:18:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 4/8] x86, mm, asm-gen: Add ioremap_wt() for WT
Date: Tue,  4 Nov 2014 15:04:34 -0700
Message-Id: <1415138678-22958-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
References: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch adds ioremap_wt() for creating WT mapping on x86.
It follows the same model as ioremap_wc() for multi-architecture
support.  ARCH_HAS_IOREMAP_WT is defined in the x86 version of
io.h to indicate that ioremap_wt() is implemented on x86.

Also update the PAT documentation file to cover ioremap_wt().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 Documentation/x86/pat.txt   |    4 +++-
 arch/x86/include/asm/io.h   |    2 ++
 arch/x86/mm/ioremap.c       |   24 ++++++++++++++++++++++++
 include/asm-generic/io.h    |    4 ++++
 include/asm-generic/iomap.h |    4 ++++
 5 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index cf08c9f..be7b8c2 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -12,7 +12,7 @@ virtual addresses.
 
 PAT allows for different types of memory attributes. The most commonly used
 ones that will be supported at this time are Write-back, Uncached,
-Write-combined and Uncached Minus.
+Write-combined, Write-through and Uncached Minus.
 
 
 PAT APIs
@@ -38,6 +38,8 @@ ioremap_nocache        |    --    |    UC-     |       UC-        |
                        |          |            |                  |
 ioremap_wc             |    --    |    --      |       WC         |
                        |          |            |                  |
+ioremap_wt             |    --    |    --      |       WT         |
+                       |          |            |                  |
 set_memory_uc          |    UC-   |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 71b9e65..c813c86 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -35,6 +35,7 @@
   */
 
 #define ARCH_HAS_IOREMAP_WC
+#define ARCH_HAS_IOREMAP_WT
 
 #include <linux/string.h>
 #include <linux/compiler.h>
@@ -316,6 +317,7 @@ extern void unxlate_dev_mem_ptr(unsigned long phys, void *addr);
 extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 				enum page_cache_mode pcm);
 extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
+extern void __iomem *ioremap_wt(resource_size_t offset, unsigned long size);
 
 extern bool is_early_ioremap_ptep(pte_t *ptep);
 
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 8832e51..ee6e55a 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -167,6 +167,10 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 		prot = __pgprot(pgprot_val(prot) |
 				cachemode2protval(_PAGE_CACHE_MODE_WC));
 		break;
+	case _PAGE_CACHE_MODE_WT:
+		prot = __pgprot(pgprot_val(prot) |
+				cachemode2protval(_PAGE_CACHE_MODE_WT));
+		break;
 	case _PAGE_CACHE_MODE_WB:
 		break;
 	}
@@ -261,6 +265,26 @@ void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
 }
 EXPORT_SYMBOL(ioremap_wc);
 
+/**
+ * ioremap_wt	-	map memory into CPU space write through
+ * @phys_addr:	bus address of the memory
+ * @size:	size of the resource to map
+ *
+ * This version of ioremap ensures that the memory is marked write through.
+ * Write through stores data into memory while keeping the cache up-to-date.
+ *
+ * Must be freed with iounmap.
+ */
+void __iomem *ioremap_wt(resource_size_t phys_addr, unsigned long size)
+{
+	if (pat_enabled)
+		return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
+					__builtin_return_address(0));
+	else
+		return ioremap_nocache(phys_addr, size);
+}
+EXPORT_SYMBOL(ioremap_wt);
+
 void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
 {
 	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WB,
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index b8fdc57..9dd07bf 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -322,6 +322,10 @@ static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
 #define ioremap_wc ioremap_nocache
 #endif
 
+#ifndef ioremap_wt
+#define ioremap_wt ioremap_nocache
+#endif
+
 static inline void iounmap(void __iomem *addr)
 {
 }
diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
index 1b41011..d8f8622 100644
--- a/include/asm-generic/iomap.h
+++ b/include/asm-generic/iomap.h
@@ -66,6 +66,10 @@ extern void ioport_unmap(void __iomem *);
 #define ioremap_wc ioremap_nocache
 #endif
 
+#ifndef ARCH_HAS_IOREMAP_WT
+#define ioremap_wt ioremap_nocache
+#endif
+
 #ifdef CONFIG_PCI
 /* Destroy a virtual mapping cookie for a PCI BAR (memory or IO) */
 struct pci_dev;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
