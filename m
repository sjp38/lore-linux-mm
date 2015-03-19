Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D40DE900015
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:10:47 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so81714099pdb.2
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 10:10:47 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id g5si4051260pda.134.2015.03.19.10.10.46
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 10:10:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/16] page-flags: look on head page if the flag is encoded in page->mapping
Date: Thu, 19 Mar 2015 19:08:21 +0200
Message-Id: <1426784902-125149-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

PageAnon() and PageKsm() look on lower bits of page->mapping to check if
the page is Anon or KSM. page->mapping can be overloaded in tail pages.

Let's always look on head page to avoid false-positives.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/page-flags.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 55a69c40e4ae..07fa2781df23 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -385,6 +385,7 @@ PAGEFLAG_FALSE(HWPoison)
 
 static inline int PageAnon(struct page *page)
 {
+	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
@@ -397,6 +398,7 @@ static inline int PageAnon(struct page *page)
  */
 static inline int PageKsm(struct page *page)
 {
+	page = compound_head(page);
 	return ((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) ==
 				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
