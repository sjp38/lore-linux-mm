Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 235F46B026A
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so421380617pgd.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:33 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si30856571plm.51.2016.11.29.03.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 15/36] thp: do not threat slab pages as huge in hpage_{nr_pages,size,mask}
Date: Tue, 29 Nov 2016 14:22:43 +0300
Message-Id: <20161129112304.90056-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Slab pages can be compound, but we shouldn't threat them as THP for
pupose of hpage_* helpers, otherwise it would lead to confusing results.

For instance, ext4 uses slab pages for journal pages and we shouldn't
confuse them with THPs. The easiest way is to exclude them in hpage_*
helpers.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index e5c9c26d2439..5e6c408f5b47 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -137,21 +137,21 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
 }
 static inline int hpage_nr_pages(struct page *page)
 {
-	if (unlikely(PageTransHuge(page)))
+	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
 		return HPAGE_PMD_NR;
 	return 1;
 }
 
 static inline int hpage_size(struct page *page)
 {
-	if (unlikely(PageTransHuge(page)))
+	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
 		return HPAGE_PMD_SIZE;
 	return PAGE_SIZE;
 }
 
 static inline unsigned long hpage_mask(struct page *page)
 {
-	if (unlikely(PageTransHuge(page)))
+	if (unlikely(!PageSlab(page) && PageTransHuge(page)))
 		return HPAGE_PMD_MASK;
 	return PAGE_MASK;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
