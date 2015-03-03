Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id E6E116B006E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:09 -0500 (EST)
Received: by obcwp4 with SMTP id wp4so1304232obc.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:09 -0800 (PST)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id as5si720968obd.86.2015.03.03.09.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:09 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 2/6] lib: Add huge I/O map capability interfaces
Date: Tue,  3 Mar 2015 10:44:20 -0700
Message-Id: <1425404664-19675-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Added ioremap_pud_enabled() and ioremap_pmd_enabled(), which
return 1 when I/O mappings with pud/pmd are enabled on the
kernel.

ioremap_huge_init() calls arch_ioremap_pud_supported() and
arch_ioremap_pmd_supported() to initialize the capabilities
at boot-time.

A new kernel option "nohugeiomap" is also added, so that user
can disable the huge I/O map capabilities when necessary.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/kernel-parameters.txt |    2 ++
 arch/Kconfig                        |    3 +++
 include/linux/io.h                  |    7 ++++++
 init/main.c                         |    2 ++
 lib/ioremap.c                       |   38 +++++++++++++++++++++++++++++++++++
 5 files changed, 52 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index bfcb1a6..55a4ec7 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2321,6 +2321,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			register save and restore. The kernel will only save
 			legacy floating-point registers on task switch.
 
+	nohugeiomap	[KNL,x86] Disable kernel huge I/O mappings.
+
 	noxsave		[BUGS=X86] Disables x86 extended register state save
 			and restore using xsave. The kernel will fallback to
 			enabling legacy floating-point and sse state.
diff --git a/arch/Kconfig b/arch/Kconfig
index 05d7a8a..55c4440 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -446,6 +446,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	bool
 
+config HAVE_ARCH_HUGE_VMAP
+	bool
+
 config HAVE_ARCH_SOFT_DIRTY
 	bool
 
diff --git a/include/linux/io.h b/include/linux/io.h
index fa02e55..1ce8b4e 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -38,6 +38,13 @@ static inline int ioremap_page_range(unsigned long addr, unsigned long end,
 }
 #endif
 
+void __init ioremap_huge_init(void);
+
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+int arch_ioremap_pud_supported(void);
+int arch_ioremap_pmd_supported(void);
+#endif
+
 /*
  * Managed iomap interface
  */
diff --git a/init/main.c b/init/main.c
index 6f0f1c5f..119cdf1 100644
--- a/init/main.c
+++ b/init/main.c
@@ -80,6 +80,7 @@
 #include <linux/list.h>
 #include <linux/integrity.h>
 #include <linux/proc_ns.h>
+#include <linux/io.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -484,6 +485,7 @@ static void __init mm_init(void)
 	percpu_init_late();
 	pgtable_init();
 	vmalloc_init();
+	ioremap_huge_init();
 }
 
 asmlinkage __visible void __init start_kernel(void)
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 0c9216c..0ce18aa 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -13,6 +13,44 @@
 #include <asm/cacheflush.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+int __read_mostly ioremap_pud_capable;
+int __read_mostly ioremap_pmd_capable;
+int __read_mostly ioremap_huge_disabled;
+
+static int __init set_nohugeiomap(char *str)
+{
+	ioremap_huge_disabled = 1;
+	return 0;
+}
+early_param("nohugeiomap", set_nohugeiomap);
+
+void __init ioremap_huge_init(void)
+{
+	if (!ioremap_huge_disabled) {
+		if (arch_ioremap_pud_supported())
+			ioremap_pud_capable = 1;
+		if (arch_ioremap_pmd_supported())
+			ioremap_pmd_capable = 1;
+	}
+}
+
+static inline int ioremap_pud_enabled(void)
+{
+	return ioremap_pud_capable;
+}
+
+static inline int ioremap_pmd_enabled(void)
+{
+	return ioremap_pmd_capable;
+}
+
+#else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
+void __init ioremap_huge_init(void) { }
+static inline int ioremap_pud_enabled(void) { return 0; }
+static inline int ioremap_pmd_enabled(void) { return 0; }
+#endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
+
 static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
