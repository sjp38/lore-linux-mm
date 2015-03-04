Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 05B266B0088
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 11:34:03 -0500 (EST)
Received: by padfb1 with SMTP id fb1so25533426pad.7
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 08:34:02 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id mo6si5840853pbc.30.2015.03.04.08.33.50
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 08:33:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 02/24] mm: change PageAnon() and page_anon_vma() to work on tail pages
Date: Wed,  4 Mar 2015 18:32:50 +0200
Message-Id: <1425486792-93161-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently PageAnon() and page_anon_vma() are always return false/NULL
for tail. We need to look on head page for correct answer.

Let's change the function to give the correct result for tail page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h   | 1 +
 include/linux/rmap.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9c21b42d07bf..1aea94e837a0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1047,6 +1047,7 @@ struct address_space *page_file_mapping(struct page *page)
 
 static inline int PageAnon(struct page *page)
 {
+	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 9c5ff69fa0cd..c4088feac1fc 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -108,6 +108,7 @@ static inline void put_anon_vma(struct anon_vma *anon_vma)
 
 static inline struct anon_vma *page_anon_vma(struct page *page)
 {
+	page = compound_head(page);
 	if (((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) !=
 					    PAGE_MAPPING_ANON)
 		return NULL;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
