Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 241846B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:44:54 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id f12so4907332qad.31
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:44:53 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id h94si26008065yhq.179.2014.07.15.12.44.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:44:53 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 2/11] x86, mm, pat: Define _PAGE_CACHE_WT for PA3/7 of PAT
Date: Tue, 15 Jul 2014 13:34:35 -0600
Message-Id: <1405452884-25688-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

This patch defines _PAGE_CACHE_WT and its relevant macros, which
now use the PA3/7 slot in the PAT MSR.  pat_init() is also changed
to set the WT memory type to the PA3/7 slot in the PAT MSR.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/include/asm/pgtable_types.h |    5 +++++
 arch/x86/mm/pat.c                    |    8 ++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 03d40da..7b905cb 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -132,6 +132,7 @@
 #define _PAGE_CACHE_MASK	(_PAGE_PCD | _PAGE_PWT)
 #define _PAGE_CACHE_WB		(0)
 #define _PAGE_CACHE_WC		(_PAGE_PWT)
+#define _PAGE_CACHE_WT		(_PAGE_PCD | _PAGE_PWT)
 #define _PAGE_CACHE_UC_MINUS	(_PAGE_PCD)
 #define _PAGE_CACHE_UC		(_PAGE_CACHE_UC_MINUS)
 
@@ -159,6 +160,7 @@
 #define __PAGE_KERNEL_RX		(__PAGE_KERNEL_EXEC & ~_PAGE_RW)
 #define __PAGE_KERNEL_EXEC_NOCACHE	(__PAGE_KERNEL_EXEC | _PAGE_CACHE_UC)
 #define __PAGE_KERNEL_WC		(__PAGE_KERNEL | _PAGE_CACHE_WC)
+#define __PAGE_KERNEL_WT		(__PAGE_KERNEL | _PAGE_CACHE_WT)
 #define __PAGE_KERNEL_NOCACHE		(__PAGE_KERNEL | _PAGE_CACHE_UC)
 #define __PAGE_KERNEL_UC_MINUS		(__PAGE_KERNEL | _PAGE_CACHE_UC_MINUS)
 #define __PAGE_KERNEL_VSYSCALL		(__PAGE_KERNEL_RX | _PAGE_USER)
@@ -172,12 +174,14 @@
 #define __PAGE_KERNEL_IO_NOCACHE	(__PAGE_KERNEL_NOCACHE | _PAGE_IOMAP)
 #define __PAGE_KERNEL_IO_UC_MINUS	(__PAGE_KERNEL_UC_MINUS | _PAGE_IOMAP)
 #define __PAGE_KERNEL_IO_WC		(__PAGE_KERNEL_WC | _PAGE_IOMAP)
+#define __PAGE_KERNEL_IO_WT		(__PAGE_KERNEL_WT | _PAGE_IOMAP)
 
 #define PAGE_KERNEL			__pgprot(__PAGE_KERNEL)
 #define PAGE_KERNEL_RO			__pgprot(__PAGE_KERNEL_RO)
 #define PAGE_KERNEL_EXEC		__pgprot(__PAGE_KERNEL_EXEC)
 #define PAGE_KERNEL_RX			__pgprot(__PAGE_KERNEL_RX)
 #define PAGE_KERNEL_WC			__pgprot(__PAGE_KERNEL_WC)
+#define PAGE_KERNEL_WT			__pgprot(__PAGE_KERNEL_WT)
 #define PAGE_KERNEL_NOCACHE		__pgprot(__PAGE_KERNEL_NOCACHE)
 #define PAGE_KERNEL_UC_MINUS		__pgprot(__PAGE_KERNEL_UC_MINUS)
 #define PAGE_KERNEL_EXEC_NOCACHE	__pgprot(__PAGE_KERNEL_EXEC_NOCACHE)
@@ -192,6 +196,7 @@
 #define PAGE_KERNEL_IO_NOCACHE		__pgprot(__PAGE_KERNEL_IO_NOCACHE)
 #define PAGE_KERNEL_IO_UC_MINUS		__pgprot(__PAGE_KERNEL_IO_UC_MINUS)
 #define PAGE_KERNEL_IO_WC		__pgprot(__PAGE_KERNEL_IO_WC)
+#define PAGE_KERNEL_IO_WT		__pgprot(__PAGE_KERNEL_IO_WT)
 
 /*         xwr */
 #define __P000	PAGE_NONE
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index c3567a5..176d4d6 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -101,7 +101,7 @@ void pat_init(void)
 		}
 	}
 
-	/* Set PWT to Write-Combining. All other bits stay the same */
+	/* Set PWT to Write-Combining, and PCD|PWT to Write-Through. */
 	/*
 	 * PTE encoding used in Linux:
 	 *      PAT
@@ -111,11 +111,11 @@ void pat_init(void)
 	 *      000 WB		_PAGE_CACHE_WB
 	 *      001 WC		_PAGE_CACHE_WC
 	 *      010 UC-		_PAGE_CACHE_UC_MINUS
-	 *      011 UC		_PAGE_CACHE_UC
+	 *      011 WT		_PAGE_CACHE_WT
 	 * PAT bit unused
 	 */
-	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
-	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, WT) |
+	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
 
 	/* Boot CPU check */
 	if (!boot_pat_state)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
