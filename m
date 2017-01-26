Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50CD2280257
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:59:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so308454859pgi.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:59:16 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h73si1238621pfh.1.2017.01.26.03.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:59:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 14/37] thp: introduce hpage_size() and hpage_mask()
Date: Thu, 26 Jan 2017 14:57:56 +0300
Message-Id: <20170126115819.58875-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
