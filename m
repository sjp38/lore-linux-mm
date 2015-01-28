Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 46F1E6B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:24:25 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id v10so25638720pde.10
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:24:25 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fp6si393259pdb.222.2015.01.28.05.24.24
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 05:24:24 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] mm: do not add nr_pmds into mm_struct if PMD is folded
Date: Wed, 28 Jan 2015 15:17:44 +0200
Message-Id: <1422451064-109023-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Everything seems in place. We can now include <asm/pgtable.h> in
<linux/mm_struct.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_struct.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/mm_struct.h b/include/linux/mm_struct.h
index 0a233c232a39..1759bed3dc61 100644
--- a/include/linux/mm_struct.h
+++ b/include/linux/mm_struct.h
@@ -8,6 +8,7 @@
 #include <linux/uprobes.h>
 
 #include <asm/mmu.h>
+#include <asm/pgtable.h>
 
 struct kioctx_table;
 struct vm_area_struct;
@@ -54,7 +55,9 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	atomic_long_t nr_ptes;			/* PTE page table pages */
+#if !__PAGETABLE_PMD_FOLDED
 	atomic_long_t nr_pmds;			/* PMD page table pages */
+#endif
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
