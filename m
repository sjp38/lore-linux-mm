Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7169028024D
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fu12so85055930pac.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a68si39039746pfb.39.2016.09.15.04.55.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 21/41] thp: introduce hpage_size() and hpage_mask()
Date: Thu, 15 Sep 2016 14:55:03 +0300
Message-Id: <20160915115523.29737-22-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
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
index 6f14de45b5ce..de2789b4402c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -138,6 +138,20 @@ static inline int hpage_nr_pages(struct page *page)
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
 extern int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
@@ -163,6 +177,8 @@ void put_huge_zero_page(void);
 #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
+#define hpage_size(x) PAGE_SIZE
+#define hpage_mask(x) PAGE_MASK
 
 #define transparent_hugepage_enabled(__vma) 0
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
