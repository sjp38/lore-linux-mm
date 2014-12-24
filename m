Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 856DA6B0088
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:43 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so9870781pde.12
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:43 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kz17si34369660pab.60.2014.12.24.04.23.15
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 36/38] unicore32: drop pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:44 +0200
Message-Id: <1419423766-114457-37-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
---
 arch/unicore32/include/asm/pgtable-hwdef.h |  1 -
 arch/unicore32/include/asm/pgtable.h       | 14 --------------
 2 files changed, 15 deletions(-)

diff --git a/arch/unicore32/include/asm/pgtable-hwdef.h b/arch/unicore32/include/asm/pgtable-hwdef.h
index 7314e859cca0..e37fa471c2be 100644
--- a/arch/unicore32/include/asm/pgtable-hwdef.h
+++ b/arch/unicore32/include/asm/pgtable-hwdef.h
@@ -44,7 +44,6 @@
 #define PTE_TYPE_INVALID	(3 << 0)
 
 #define PTE_PRESENT		(1 << 2)
-#define PTE_FILE		(1 << 3)	/* only when !PRESENT */
 #define PTE_YOUNG		(1 << 3)
 #define PTE_DIRTY		(1 << 4)
 #define PTE_CACHEABLE		(1 << 5)
diff --git a/arch/unicore32/include/asm/pgtable.h b/arch/unicore32/include/asm/pgtable.h
index ed6f7d000fba..818d0f5598e3 100644
--- a/arch/unicore32/include/asm/pgtable.h
+++ b/arch/unicore32/include/asm/pgtable.h
@@ -283,20 +283,6 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 #define MAX_SWAPFILES_CHECK()	\
 	BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > __SWP_TYPE_BITS)
 
-/*
- * Encode and decode a file entry.  File entries are stored in the Linux
- * page tables as follows:
- *
- *   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
- *   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
- *   <----------------------- offset ----------------------> 1 0 0 0
- */
-#define pte_file(pte)		(pte_val(pte) & PTE_FILE)
-#define pte_to_pgoff(x)		(pte_val(x) >> 4)
-#define pgoff_to_pte(x)		__pte(((x) << 4) | PTE_FILE)
-
-#define PTE_FILE_MAX_BITS	28
-
 /* Needs to be defined here and not in linux/mm.h, as it is arch dependent */
 /* FIXME: this is not correct */
 #define kern_addr_valid(addr)	(1)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
