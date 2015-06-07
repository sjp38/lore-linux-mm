Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 661646B0074
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:42:04 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so80074260pab.3
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:42:04 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id mv8si396956pdb.4.2015.06.07.10.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:42:02 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:41:19 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-d838270e2516db11084bed4e294017eb7b646a75@git.kernel.org>
Reply-To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        luto@amacapital.net, peterz@infradead.org, hpa@zytor.com, bp@suse.de,
        tglx@linutronix.de, toshi.kani@hp.com, akpm@linux-foundation.org,
        mingo@kernel.org, mcgrof@suse.com, torvalds@linux-foundation.org
In-Reply-To: <1433436928-31903-8-git-send-email-bp@alien8.de>
References: <1433436928-31903-8-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm, asm-generic: Add ioremap_wt()
  for creating Write-Through mappings
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mcgrof@suse.com, toshi.kani@hp.com, akpm@linux-foundation.org, mingo@kernel.org, torvalds@linux-foundation.org, luto@amacapital.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bp@suse.de, tglx@linutronix.de, peterz@infradead.org, hpa@zytor.com

Commit-ID:  d838270e2516db11084bed4e294017eb7b646a75
Gitweb:     http://git.kernel.org/tip/d838270e2516db11084bed4e294017eb7b646a75
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:15 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:56 +0200

x86/mm, asm-generic: Add ioremap_wt() for creating Write-Through mappings

Add ioremap_wt() for creating Write-Through mappings on x86. It
follows the same model as ioremap_wc() for multi-arch support.
Define ARCH_HAS_IOREMAP_WT in the x86 version of io.h to
indicate that ioremap_wt() is implemented on x86.

Also update the PAT documentation file to cover ioremap_wt().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-8-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 Documentation/x86/pat.txt   |  4 +++-
 arch/x86/include/asm/io.h   |  2 ++
 arch/x86/mm/ioremap.c       | 21 +++++++++++++++++++++
 include/asm-generic/io.h    |  9 +++++++++
 include/asm-generic/iomap.h |  4 ++++
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
index a944630..83ec9b1 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -35,6 +35,7 @@
   */
 
 #define ARCH_HAS_IOREMAP_WC
+#define ARCH_HAS_IOREMAP_WT
 
 #include <linux/string.h>
 #include <linux/compiler.h>
@@ -320,6 +321,7 @@ extern void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
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
