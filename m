Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 048EA8299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 06:30:31 -0400 (EDT)
Received: by pdjy10 with SMTP id y10so27833566pdj.8
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 03:30:30 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id zq9si3199446pab.162.2015.03.13.03.30.29
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 03:30:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] parisc: fix pmd accounting with 3-level page tables
Date: Fri, 13 Mar 2015 12:30:02 +0200
Message-Id: <1426242602-52804-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, John David Anglin <dave.anglin@bell.net>, Aaro Koskinen <aaro.koskinen@iki.fi>, Graham Gower <graham.gower@gmail.com>, Domenico Andreoli <cavokz@gmail.com>

There's hack in pgd_alloc() on parisc to initialize one pmd, which is
not accounted. It leads to underflow on exit.

Let's adjust nr_pmds on pgd_alloc() to get accounting correct.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: John David Anglin <dave.anglin@bell.net>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
Cc: Graham Gower <graham.gower@gmail.com>
Cc: Domenico Andreoli <cavokz@gmail.com>
---
 arch/parisc/include/asm/pgalloc.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index 55ad8be9b7f3..068b2fb9a47c 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -38,6 +38,7 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 		/* The first pmd entry also is marked with _PAGE_GATEWAY as
 		 * a signal that this pmd may not be freed */
 		__pgd_val_set(*pgd, PxD_FLAG_ATTACHED);
+		mm_inc_nr_pmds(mm);
 #endif
 	}
 	return actual_pgd;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
