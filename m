Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 272E96B0089
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:36:11 -0500 (EST)
Received: by pdev10 with SMTP id v10so12424051pde.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:36:10 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id y15si826775pbt.37.2015.02.26.03.36.06
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:36:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 16/17] mm: define default PGTABLE_LEVELS to two
Date: Thu, 26 Feb 2015 13:35:19 +0200
Message-Id: <1424950520-90188-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

By this time all architectures which support more than two page table
levels should be covered. This patch add default definiton of
PGTABLE_LEVELS equal 2.

We also add assert to detect inconsistence between CONFIG_PGTABLE_LEVELS
and __PAGETABLE_PMD_FOLDED/__PAGETABLE_PUD_FOLDED.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/Kconfig                  | 4 ++++
 include/asm-generic/pgtable.h | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 05d7a8a458d5..a9c95d36ba70 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -484,6 +484,10 @@ config HAVE_IRQ_EXIT_ON_IRQ_STACK
 	  This spares a stack switch and improves cache usage on softirq
 	  processing.
 
+config PGTABLE_LEVELS
+	int
+	default 2
+
 #
 # ABI hall of shame
 #
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 4d46085c1b90..1f9f5da6828f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -7,6 +7,11 @@
 #include <linux/mm_types.h>
 #include <linux/bug.h>
 
+#if 4 - defined(__PAGETABLE_PUD_FOLDED) - defined(__PAGETABLE_PMD_FOLDED) != \
+	CONFIG_PGTABLE_LEVELS
+#error CONFIG_PGTABLE_LEVELS is not consistent with __PAGETABLE_{PUD,PMD}_FOLDED
+#endif
+
 /*
  * On almost all architectures and configurations, 0 can be used as the
  * upper ceiling to free_pgtables(): on many architectures it has the same
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
