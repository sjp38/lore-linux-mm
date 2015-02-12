Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF3D6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 11:18:56 -0500 (EST)
Received: by pdjy10 with SMTP id y10so12881811pdj.6
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 08:18:56 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id tv6si5283814pab.83.2015.02.12.08.18.54
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 08:18:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 02/24] mm: change PageAnon() and page_anon_vma() to work on tail pages
Date: Thu, 12 Feb 2015 18:18:16 +0200
Message-Id: <1423757918-197669-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently PageAnon() and page_anon_vma() are always return false/NULL
for tail. We need to look on head page for correct answer.

Let's change the function to give the correct result for tail page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h   | 1 +
 include/linux/rmap.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a93928b90f..9071066b7c2e 100644
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
