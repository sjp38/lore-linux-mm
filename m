Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E637F6B0071
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:44 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so53180858pad.1
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:44 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id je7si14057245pbd.15.2015.01.30.06.43.40
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 18/19] mm: define default PGTABLE_LEVELS to two
Date: Fri, 30 Jan 2015 16:43:27 +0200
Message-Id: <1422629008-13689-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

By this time all architectures which support more than two page table
levels should be covered. This patch add default definiton of
PGTABLE_LEVELS equal 2.

We also add assert to detect inconsistence between CONFIG_PGTABLE_LEVELS
and __PAGETABLE_PMD_FOLDED/__PAGETABLE_PUD_FOLDED.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
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
