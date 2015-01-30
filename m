Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C0D266B0071
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:40 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so53121873pad.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:40 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sm10si13821105pab.239.2015.01.30.06.43.38
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 07/19] m68k: mark PMD folded and expose number of page table levels
Date: Fri, 30 Jan 2015 16:43:16 +0200
Message-Id: <1422629008-13689-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/Kconfig                  | 4 ++++
 arch/m68k/include/asm/pgtable_mm.h | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 87b7c7581b1d..2dd8f63bfbbb 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -67,6 +67,10 @@ config HZ
 	default 1000 if CLEOPATRA
 	default 100
 
+config PGTABLE_LEVELS
+	default 2 if SUN3 || COLDFIRE
+	default 3
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index 28a145bfbb71..35ed4a9981ae 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -54,10 +54,12 @@
  */
 #ifdef CONFIG_SUN3
 #define PTRS_PER_PTE   16
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD   1
 #define PTRS_PER_PGD   2048
 #elif defined(CONFIG_COLDFIRE)
 #define PTRS_PER_PTE	512
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD	1
 #define PTRS_PER_PGD	1024
 #else
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
