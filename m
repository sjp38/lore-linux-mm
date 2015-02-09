Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id DE7E76B006C
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:45:57 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id u20so9678342oif.11
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:45:57 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id u10si6615268oem.34.2015.02.09.14.45.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:45:57 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 2/7] lib: Add huge I/O map capability interfaces
Date: Mon,  9 Feb 2015 15:45:30 -0700
Message-Id: <1423521935-17454-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Add ioremap_pud_enabled() and ioremap_pmd_enabled(), which
return 1 when I/O mappings of pud/pmd are enabled on the kernel.

ioremap_huge_init() calls arch_ioremap_pud_supported() and
arch_ioremap_pmd_supported() to initialize the capabilities.

A new kernel option "nohugeiomap" is also added, so that user
can disable the huge I/O map capabilities when necessary.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/kernel-parameters.txt |    2 ++
 include/linux/io.h                  |    7 ++++++
 init/main.c                         |    2 ++
 lib/ioremap.c                       |   38 +++++++++++++++++++++++++++++++++++
 4 files changed, 49 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 176d4fe..1872b46 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2304,6 +2304,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			register save and restore. The kernel will only save
 			legacy floating-point registers on task switch.
 
+	nohugeiomap	[KNL,x86] Disable kernel huge I/O mappings.
+
 	noxsave		[BUGS=X86] Disables x86 extended register state save
 			and restore using xsave. The kernel will fallback to
 			enabling legacy floating-point and sse state.
diff --git a/include/linux/io.h b/include/linux/io.h
index fa02e55..9acc588a 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -38,6 +38,13 @@ static inline int ioremap_page_range(unsigned long addr, unsigned long end,
 }
 #endif
 
+void __init ioremap_huge_init(void);
+
+#ifdef CONFIG_HUGE_IOMAP
+int arch_ioremap_pud_supported(void);
+int arch_ioremap_pmd_supported(void);
+#endif
+
 /*
  * Managed iomap interface
  */
diff --git a/init/main.c b/init/main.c
index 61b99376..9f871ac 100644
--- a/init/main.c
+++ b/init/main.c
@@ -80,6 +80,7 @@
 #include <linux/list.h>
 #include <linux/integrity.h>
 #include <linux/proc_ns.h>
+#include <linux/io.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -497,6 +498,7 @@ static void __init mm_init(void)
 	percpu_init_late();
 	pgtable_init();
 	vmalloc_init();
+	ioremap_huge_init();
 }
 
 asmlinkage __visible void __init start_kernel(void)
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 0c9216c..cafd83e 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -13,6 +13,44 @@
 #include <asm/cacheflush.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_HUGE_IOMAP
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
+#else	/* !CONFIG_HUGE_IOMAP */
+void __init ioremap_huge_init(void) { }
+static inline int ioremap_pud_enabled(void) { return 0; }
+static inline int ioremap_pmd_enabled(void) { return 0; }
+#endif	/* CONFIG_HUGE_IOMAP */
+
 static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
