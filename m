Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B18B26B0292
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 19:14:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d191so7337657pga.15
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 16:14:54 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g14si871015plm.218.2017.06.13.16.14.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 16:14:54 -0700 (PDT)
Subject: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 13 Jun 2017 16:08:26 -0700
Message-ID: <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Turn the macro into a static inline and rewrite the condition checks for
better readability in preparation for adding another condition.

Cc: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
[ross: fix logic to make conversion equivalent]
Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/huge_mm.h |   32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..c8119e856eb1 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -85,14 +85,23 @@ extern struct kobj_attribute shmem_enabled_attr;
 
 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
-#define transparent_hugepage_enabled(__vma)				\
-	((transparent_hugepage_flags &					\
-	  (1<<TRANSPARENT_HUGEPAGE_FLAG) ||				\
-	  (transparent_hugepage_flags &					\
-	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
-	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
-	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
-	 !is_vma_temporary_stack(__vma))
+extern unsigned long transparent_hugepage_flags;
+
+static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
+		return false;
+
+	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
+		return true;
+
+	if (transparent_hugepage_flags &
+				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
+		return !!(vma->vm_flags & VM_HUGEPAGE);
+
+	return false;
+}
+
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
@@ -104,8 +113,6 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 #define transparent_hugepage_debug_cow() 0
 #endif /* CONFIG_DEBUG_VM */
 
-extern unsigned long transparent_hugepage_flags;
-
 extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
@@ -223,7 +230,10 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define hpage_nr_pages(x) 1
 
-#define transparent_hugepage_enabled(__vma) 0
+static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	return false;
+}
 
 static inline void prep_transhuge_page(struct page *page) {}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
