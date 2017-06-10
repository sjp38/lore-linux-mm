Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF1786B02B4
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 17:56:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u8so39176380pgo.11
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 14:56:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f10si3798064plj.537.2017.06.10.14.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Jun 2017 14:56:00 -0700 (PDT)
Subject: [PATCH 1/2] mm: improve readability of
 transparent_hugepage_enabled()
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 10 Jun 2017 14:49:31 -0700
Message-ID: <149713137177.17377.6712234218256825718.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/huge_mm.h |   35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..c4706e2c3358 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -85,14 +85,26 @@ extern struct kobj_attribute shmem_enabled_attr;
 
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
+	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
+		return true;
+
+	if (transparent_hugepage_flags
+			& (1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
+		/* check vma flags */;
+	else
+		return false;
+
+	if ((vma->vm_flags & (VM_HUGEPAGE | VM_NOHUGEPAGE)) == VM_HUGEPAGE
+			&& !is_vma_temporary_stack(vma))
+		return true;
+
+	return false;
+}
+
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
@@ -104,8 +116,6 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 #define transparent_hugepage_debug_cow() 0
 #endif /* CONFIG_DEBUG_VM */
 
-extern unsigned long transparent_hugepage_flags;
-
 extern unsigned long thp_get_unmapped_area(struct file *filp,
 		unsigned long addr, unsigned long len, unsigned long pgoff,
 		unsigned long flags);
@@ -223,7 +233,10 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 
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
