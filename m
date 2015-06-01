Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id B565E6B0071
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 15:56:24 -0400 (EDT)
Received: by oifu123 with SMTP id u123so109889969oif.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 12:56:24 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id gk2si9392408obb.103.2015.06.01.12.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 12:56:21 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v12 4/10] x86, mm, asm-gen: Add ioremap_wt() for WT
Date: Mon,  1 Jun 2015 13:36:27 -0600
Message-Id: <1433187393-22688-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
References: <1433187393-22688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

This patch adds ioremap_wt() for creating WT mapping on x86.
It follows the same model as ioremap_wc() for multi-architecture
support.  ARCH_HAS_IOREMAP_WT is defined in the x86 version of
io.h to indicate that ioremap_wt() is implemented on x86.

Also update the PAT documentation file to cover ioremap_wt().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
 Documentation/x86/pat.txt   |    4 +++-
 arch/x86/include/asm/io.h   |    2 ++
 arch/x86/mm/ioremap.c       |   21 +++++++++++++++++++++
 include/asm-generic/io.h    |    9 +++++++++
 include/asm-generic/iomap.h |    4 ++++
 5 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/Documentation/x86/pat.txt b/Documentation/x86/pat.txt
index 521bd8a..db0de6c 100644
--- a/Documentation/x86/pat.txt
+++ b/Documentation/x86/pat.txt
@@ -12,7 +12,7 @@ virtual addresses.
 
 PAT allows for different types of memory attributes. The most commonly used
 ones that will be supported at this time are Write-back, Uncached,
-Write-combined and Uncached Minus.
+Write-combined, Write-through and Uncached Minus.
 
 
 PAT APIs
@@ -40,6 +40,8 @@ ioremap_nocache        |    --    |    UC-     |       UC-        |
                        |          |            |                  |
 ioremap_wc             |    --    |    --      |       WC         |
                        |          |            |                  |
+ioremap_wt             |    --    |    --      |       WT         |
+                       |          |            |                  |
 set_memory_uc          |    UC-   |    --      |       --         |
  set_memory_wb         |          |            |                  |
                        |          |            |                  |
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index a2b9740..6c3a130 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -35,6 +35,7 @@
   */
 
 #define ARCH_HAS_IOREMAP_WC
+#define ARCH_HAS_IOREMAP_WT
 
 #include <linux/string.h>
 #include <linux/compiler.h>
@@ -321,6 +322,7 @@ extern void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 				enum page_cache_mode pcm);
 extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
+extern void __iomem *ioremap_wt(resource_size_t offset, unsigned long size);
 
 extern bool is_early_ioremap_ptep(pte_t *ptep);
 
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index cc0f17c..07cd46a 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -172,6 +172,10 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
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
@@ -297,6 +301,23 @@ void __iomem *ioremap_wc(resource_size_t phys_addr, unsigned long size)
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
+	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WT,
+					__builtin_return_address(0));
+}
+EXPORT_SYMBOL(ioremap_wt);
+
 void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
 {
 	return __ioremap_caller(phys_addr, size, _PAGE_CACHE_MODE_WB,
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index 90ccba7..f56094c 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -785,8 +785,17 @@ static inline void __iomem *ioremap_wc(phys_addr_t offset, size_t size)
 }
 #endif
 
+#ifndef ioremap_wt
+#define ioremap_wt ioremap_wt
+static inline void __iomem *ioremap_wt(phys_addr_t offset, size_t size)
+{
+	return ioremap_nocache(offset, size);
+}
+#endif
+
 #ifndef iounmap
 #define iounmap iounmap
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
