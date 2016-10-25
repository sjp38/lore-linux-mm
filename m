Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A02B16B026E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so24327072pfe.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m8si17919501pfa.203.2016.10.24.17.14.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 22/43] thp: do not threat slab pages as huge in hpage_{nr_pages,size,mask}
Date: Tue, 25 Oct 2016 03:13:21 +0300
Message-Id: <20161025001342.76126-23-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 42934769f256..1300f8bb7523 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
