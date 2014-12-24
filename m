Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C5EBC6B00AF
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:29:34 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so10009506pab.40
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:29:34 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ru9si34134461pac.210.2014.12.24.04.23.12
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:13 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 25/38] mn10300: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:33 +0200
Message-Id: <1419423766-114457-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

This patch also increase number of bits availble for swap offset.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
---
 arch/mn10300/include/asm/pgtable.h | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/arch/mn10300/include/asm/pgtable.h b/arch/mn10300/include/asm/pgtable.h
index 2ddaa67e7983..629181ae111e 100644
--- a/arch/mn10300/include/asm/pgtable.h
+++ b/arch/mn10300/include/asm/pgtable.h
@@ -134,7 +134,6 @@ extern pte_t kernel_vmalloc_ptes[(VMALLOC_END - VMALLOC_START) / PAGE_SIZE];
 #define _PAGE_NX		0			/* no-execute bit */
 
 /* If _PAGE_VALID is clear, we use these: */
-#define _PAGE_FILE		xPTEL2_C	/* set:pagecache unset:swap */
 #define _PAGE_PROTNONE		0x000		/* If not present */
 
 #define __PAGE_PROT_UWAUX	0x010
@@ -241,11 +240,6 @@ static inline int pte_young(pte_t pte)	{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)	{ return pte_val(pte) & __PAGE_PROT_WRITE; }
 static inline int pte_special(pte_t pte){ return 0; }
 
-/*
- * The following only works if pte_present() is not true.
- */
-static inline int pte_file(pte_t pte)	{ return pte_val(pte) & _PAGE_FILE; }
-
 static inline pte_t pte_rdprotect(pte_t pte)
 {
 	pte_val(pte) &= ~(__PAGE_PROT_USER|__PAGE_PROT_UWAUX); return pte;
@@ -338,16 +332,11 @@ static inline int pte_exec_kernel(pte_t pte)
 	return 1;
 }
 
-#define PTE_FILE_MAX_BITS	30
-
-#define pte_to_pgoff(pte)	(pte_val(pte) >> 2)
-#define pgoff_to_pte(off)	__pte((off) << 2 | _PAGE_FILE)
-
 /* Encode and de-code a swap entry */
-#define __swp_type(x)			(((x).val >> 2) & 0x3f)
-#define __swp_offset(x)			((x).val >> 8)
+#define __swp_type(x)			(((x).val >> 1) & 0x3f)
+#define __swp_offset(x)			((x).val >> 7)
 #define __swp_entry(type, offset) \
-	((swp_entry_t) { ((type) << 2) | ((offset) << 8) })
+	((swp_entry_t) { ((type) << 1) | ((offset) << 7) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		__pte((x).val)
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
