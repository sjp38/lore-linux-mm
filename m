Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79100828FF
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so6128814pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b64si10109475pfa.51.2016.08.12.11.38.48
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 22/41] thp: do not threat slab pages as huge in hpage_{nr_pages,size,mask}
Date: Fri, 12 Aug 2016 21:38:05 +0300
Message-Id: <1471027104-115213-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
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
index de2789b4402c..5c5466ba37df 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -133,21 +133,21 @@ static inline spinlock_t *pmd_trans_huge_lock(pmd_t *pmd,
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
