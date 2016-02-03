Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A11CD828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:27:49 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l66so70312613wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:27:49 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id u187si495710wmu.82.2016.02.03.05.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:27:48 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [RFC] ARM: modify pgd_t definition for TRANSPARENT_HUGEPAGE_PUD
Date: Wed, 03 Feb 2016 14:21:48 +0100
Message-ID: <1773775.QWf7OyDGPh@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-arch@vger.kernel.org

I ran into build errors on ARM after Willy's newly added generic
TRANSPARENT_HUGEPAGE_PUD support. We don't support this feature
on ARM at all, but the patch causes a build error anyway:

In file included from ../kernel/memremap.c:17:0:
../include/linux/pfn_t.h:108:7: error: 'pud_mkdevmap' declared as function returning an array
 pud_t pud_mkdevmap(pud_t pud);

We don't use a PUD on ARM, so pud_t is defined as pmd_t, which
in turn is defined as

typedef unsigned long pgd_t[2];

on NOMMU and on 2-level MMU configurations. There is an (unused)
other definition using a struct around the array, which happens to
work fine here.

There is a comment in the file about the fact the other version
is "easier on the compiler", and I've traced that version back
to linux-2.1.80 when ARM support was first merged back in 1998.

It's probably a safe assumption that this is no longer necessary:
The same logic existed in asm-i386 at the time but was removed
a year later in 2.3.23pre3. The STRICT_MM_TYPECHECKS logic
also ended up getting copied into these files:

arch/alpha/include/asm/page.h
arch/arc/include/asm/page.h
arch/arm/include/asm/pgtable-3level-types.h
arch/arm64/include/asm/pgtable-types.h
arch/ia64/include/asm/page.h
arch/parisc/include/asm/page.h
arch/powerpc/include/asm/page.h
arch/sparc/include/asm/page_32.h
arch/sparc/include/asm/page_64.h
arch/tile/include/asm/page.h
arch/unicore32/include/asm/page.h

We should probably remove it everywhere, but for the moment,
this minimal patch gets things to compile on linux-next.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: a27da20ed50e ("mm: add support for PUD-sized transparent hugepages")

diff --git a/arch/arm/include/asm/page-nommu.h b/arch/arm/include/asm/page-nommu.h
index d1b162a18dcb..3db1ca22fecb 100644
--- a/arch/arm/include/asm/page-nommu.h
+++ b/arch/arm/include/asm/page-nommu.h
@@ -31,12 +31,12 @@
  */
 typedef unsigned long pte_t;
 typedef unsigned long pmd_t;
-typedef unsigned long pgd_t[2];
+typedef struct { unsigned long pgd[2]; } pgd_t;
 typedef unsigned long pgprot_t;
 
 #define pte_val(x)      (x)
 #define pmd_val(x)      (x)
-#define pgd_val(x)	((x)[0])
+#define pgd_val(x)	((x).pgd[0])
 #define pgprot_val(x)   (x)
 
 #define __pte(x)        (x)
diff --git a/arch/arm/include/asm/pgtable-2level-types.h b/arch/arm/include/asm/pgtable-2level-types.h
index 66cb5b0e89c5..9b9815d5ebd6 100644
--- a/arch/arm/include/asm/pgtable-2level-types.h
+++ b/arch/arm/include/asm/pgtable-2level-types.h
@@ -24,6 +24,9 @@
 typedef u32 pteval_t;
 typedef u32 pmdval_t;
 
+typedef struct { pmdval_t pgd[2]; } pgd_t;
+#define pgd_val(x)	((x).pgd[0])
+
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
@@ -32,12 +35,10 @@ typedef u32 pmdval_t;
  */
 typedef struct { pteval_t pte; } pte_t;
 typedef struct { pmdval_t pmd; } pmd_t;
-typedef struct { pmdval_t pgd[2]; } pgd_t;
 typedef struct { pteval_t pgprot; } pgprot_t;
 
 #define pte_val(x)      ((x).pte)
 #define pmd_val(x)      ((x).pmd)
-#define pgd_val(x)	((x).pgd[0])
 #define pgprot_val(x)   ((x).pgprot)
 
 #define __pte(x)        ((pte_t) { (x) } )
@@ -50,12 +51,10 @@ typedef struct { pteval_t pgprot; } pgprot_t;
  */
 typedef pteval_t pte_t;
 typedef pmdval_t pmd_t;
-typedef pmdval_t pgd_t[2];
 typedef pteval_t pgprot_t;
 
 #define pte_val(x)      (x)
 #define pmd_val(x)      (x)
-#define pgd_val(x)	((x)[0])
 #define pgprot_val(x)   (x)
 
 #define __pte(x)        (x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
