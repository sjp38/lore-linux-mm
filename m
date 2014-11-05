Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9486B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:50:19 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so887969pab.41
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:50:18 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k1si3243625pdj.98.2014.11.05.06.50.06
        for <linux-mm@kvack.org>;
        Wed, 05 Nov 2014 06:50:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/19] mm: change PageAnon() to work on tail pages
Date: Wed,  5 Nov 2014 16:49:38 +0200
Message-Id: <1415198994-15252-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Current PageAnon() is always return false for tail. We need to look on
head page for correct answer. Let's change the function to give the
right result.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 98c11c5be0ad..1825c468f158 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -983,6 +983,7 @@ struct address_space *page_file_mapping(struct page *page)
 
 static inline int PageAnon(struct page *page)
 {
+	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
