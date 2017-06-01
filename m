Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9066B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a10so31822434itg.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:11 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id 71si19383714itl.84.2017.06.01.01.17.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:10 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id m4so4195481ioe.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 2/9] mm: hugetlb: return immediately for hugetlb page in __delete_from_page_cache()
Date: Thu,  1 Jun 2017 17:16:52 +0900
Message-Id: <1496305019-5493-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

We avoid calling __mod_node_page_state(NR_FILE_PAGES) for hugetlb page
now, but it's not enough because later code doesn't handle hugetlb
properly.  Actually in our testing, WARN_ON_ONCE(PageDirty(page)) at the
end of this function fires for hugetlb, which makes no sense.  So we
should return immediately for hugetlb pages.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/filemap.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git v4.12-rc3/mm/filemap.c v4.12-rc3_patched/mm/filemap.c
index 6f1be57..2867fcb 100644
--- v4.12-rc3/mm/filemap.c
+++ v4.12-rc3_patched/mm/filemap.c
@@ -239,14 +239,16 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	/* Leave page->index set: truncation lookup relies upon it */
 
 	/* hugetlb pages do not participate in page cache accounting. */
-	if (!PageHuge(page))
-		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	if (PageHuge(page))
+		return;
+
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page)) {
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
 		if (PageTransHuge(page))
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page) && !PageHuge(page), page);
+		VM_BUG_ON_PAGE(PageTransHuge(page), page);
 	}
 
 	/*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
