Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 30A966B0073
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:54:34 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so53144856pab.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:54:33 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fl9si8789278pad.109.2015.01.30.06.54.33
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:54:33 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 12/19] s390: expose number of page table levels
Date: Fri, 30 Jan 2015 16:54:24 +0200
Message-Id: <1422629664-19954-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20150130154830.6e5c4774@mschwide>
References: <20150130154830.6e5c4774@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 v2: fix typo
---
 arch/s390/Kconfig               | 5 +++++
 arch/s390/include/asm/pgtable.h | 2 ++
 2 files changed, 7 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 8d11babf9aa5..6870e6ab903f 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -155,6 +155,11 @@ config S390
 config SCHED_OMIT_FRAME_POINTER
 	def_bool y
 
+config PGTABLE_LEVELS
+	int
+	default 4 if 64BIT
+	default 2
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index fbb5ee3ae57c..e08ec38f8c6e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -91,7 +91,9 @@ extern unsigned long zero_page_mask;
  */
 #define PTRS_PER_PTE	256
 #ifndef CONFIG_64BIT
+#define __PAGETABLE_PUD_FOLDED
 #define PTRS_PER_PMD	1
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PUD	1
 #else /* CONFIG_64BIT */
 #define PTRS_PER_PMD	2048
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
