Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 94F636B0082
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:33 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so9874344pdb.33
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j2si34277738pdo.128.2014.12.24.04.23.09
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 18/38] hexagon: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:26 +0200
Message-Id: <1419423766-114457-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Richard Kuo <rkuo@codeaurora.org>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

This patch also increase number of bits availble for swap offset.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Richard Kuo <rkuo@codeaurora.org>
---
 arch/hexagon/include/asm/pgtable.h | 60 ++++++++++----------------------------
 1 file changed, 16 insertions(+), 44 deletions(-)

diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index d8bd54fa431e..6e35e71d2aea 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -62,13 +62,6 @@ extern unsigned long zero_page_mask;
 #define _PAGE_ACCESSED	(1<<2)
 
 /*
- * _PAGE_FILE is only meaningful if _PAGE_PRESENT is false, while
- * _PAGE_DIRTY is only meaningful if _PAGE_PRESENT is true.
- * So we can overload the bit...
- */
-#define _PAGE_FILE	_PAGE_DIRTY /* set:  pagecache, unset = swap */
-
-/*
  * For now, let's say that Valid and Present are the same thing.
  * Alternatively, we could say that it's the "or" of R, W, and X
  * permissions.
@@ -456,57 +449,36 @@ static inline int pte_exec(pte_t pte)
 #define pgtable_cache_init()    do { } while (0)
 
 /*
- * Swap/file PTE definitions.  If _PAGE_PRESENT is zero, the rest of the
- * PTE is interpreted as swap information.  Depending on the _PAGE_FILE
- * bit, the remaining free bits are eitehr interpreted as a file offset
- * or a swap type/offset tuple.  Rather than have the TLB fill handler
- * test _PAGE_PRESENT, we're going to reserve the permissions bits
- * and set them to all zeros for swap entries, which speeds up the
- * miss handler at the cost of 3 bits of offset.  That trade-off can
- * be revisited if necessary, but Hexagon processor architecture and
- * target applications suggest a lot of TLB misses and not much swap space.
+ * Swap/file PTE definitions.  If _PAGE_PRESENT is zero, the rest of the PTE is
+ * interpreted as swap information.  The remaining free bits are interpreted as
+ * swap type/offset tuple.  Rather than have the TLB fill handler test
+ * _PAGE_PRESENT, we're going to reserve the permissions bits and set them to
+ * all zeros for swap entries, which speeds up the miss handler at the cost of
+ * 3 bits of offset.  That trade-off can be revisited if necessary, but Hexagon
+ * processor architecture and target applications suggest a lot of TLB misses
+ * and not much swap space.
  *
  * Format of swap PTE:
  *	bit	0:	Present (zero)
- *	bit	1:	_PAGE_FILE (zero)
- *	bits	2-6:	swap type (arch independent layer uses 5 bits max)
- *	bits	7-9:	bits 2:0 of offset
- *	bits 10-12:	effectively _PAGE_PROTNONE (all zero)
- *	bits 13-31:  bits 21:3 of swap offset
- *
- * Format of file PTE:
- *	bit	0:	Present (zero)
- *	bit	1:	_PAGE_FILE (zero)
- *	bits	2-9:	bits 7:0 of offset
- *	bits 10-12:	effectively _PAGE_PROTNONE (all zero)
- *	bits 13-31:  bits 26:8 of swap offset
+ *	bits	1-5:	swap type (arch independent layer uses 5 bits max)
+ *	bits	6-9:	bits 3:0 of offset
+ *	bits	10-12:	effectively _PAGE_PROTNONE (all zero)
+ *	bits	13-31:  bits 22:4 of swap offset
  *
  * The split offset makes some of the following macros a little gnarly,
  * but there's plenty of precedent for this sort of thing.
  */
-#define PTE_FILE_MAX_BITS     27
 
 /* Used for swap PTEs */
-#define __swp_type(swp_pte)		(((swp_pte).val >> 2) & 0x1f)
+#define __swp_type(swp_pte)		(((swp_pte).val >> 1) & 0x1f)
 
 #define __swp_offset(swp_pte) \
-	((((swp_pte).val >> 7) & 0x7) | (((swp_pte).val >> 10) & 0x003ffff8))
+	((((swp_pte).val >> 6) & 0xf) | (((swp_pte).val >> 9) & 0x7ffff0))
 
 #define __swp_entry(type, offset) \
 	((swp_entry_t)	{ \
-		((type << 2) | \
-		 ((offset & 0x3ffff8) << 10) | ((offset & 0x7) << 7)) })
-
-/* Used for file PTEs */
-#define pte_file(pte) \
-	((pte_val(pte) & (_PAGE_FILE | _PAGE_PRESENT)) == _PAGE_FILE)
-
-#define pte_to_pgoff(pte) \
-	(((pte_val(pte) >> 2) & 0xff) | ((pte_val(pte) >> 5) & 0x07ffff00))
-
-#define pgoff_to_pte(off) \
-	((pte_t) { ((((off) & 0x7ffff00) << 5) | (((off) & 0xff) << 2)\
-	| _PAGE_FILE) })
+		((type << 1) | \
+		 ((offset & 0x7ffff0) << 9) | ((offset & 0xf) << 6)) })
 
 /*  Oh boy.  There are a lot of possible arch overrides found in this file.  */
 #include <asm-generic/pgtable.h>
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
