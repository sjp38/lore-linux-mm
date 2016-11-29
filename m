Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 307EE6B026B
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so249370141pfk.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:33 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b192si56373317pga.202.2016.11.29.03.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 14/36] thp: introduce hpage_size() and hpage_mask()
Date: Tue, 29 Nov 2016 14:22:42 +0300
Message-Id: <20161129112304.90056-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Introduce new helpers which return size/mask of the page:
HPAGE_PMD_SIZE/HPAGE_PMD_MASK if the page is PageTransHuge() and
PAGE_SIZE/PAGE_MASK otherwise.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 97e478d6b690..e5c9c26d2439 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -142,6 +142,20 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
+static inline int hpage_size(struct page *page)
+{
+	if (unlikely(PageTransHuge(page)))
+		return HPAGE_PMD_SIZE;
+	return PAGE_SIZE;
+}
+
+static inline unsigned long hpage_mask(struct page *page)
+{
+	if (unlikely(PageTransHuge(page)))
+		return HPAGE_PMD_MASK;
+	return PAGE_MASK;
+}
+
 extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
@@ -167,6 +181,8 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
+#define hpage_size(x) PAGE_SIZE
+#define hpage_mask(x) PAGE_MASK
 
 #define transparent_hugepage_enabled(__vma) 0
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
