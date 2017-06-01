Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF6F06B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:15 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id q81so31851757itc.9
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:15 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id v12si17970089iov.62.2017.06.01.01.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:14 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id o12so4179433iod.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:14 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 4/9] mm: hugetlb: soft-offline: dissolve source hugepage after successful migration
Date: Thu,  1 Jun 2017 17:16:54 +0900
Message-Id: <1496305019-5493-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Currently hugepage migrated by soft-offline (i.e. due to correctable
memory errors) is contained as a hugepage, which means many non-error
pages in it are unreusable, i.e. wasted.

This patch solves this issue by dissolving source hugepages into buddy.
As done in previous patch, PageHWPoison is set only on a head page of
the error hugepage. Then in dissoliving we move the PageHWPoison flag to
the raw error page so that all healthy subpages return back to buddy.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  2 ++
 mm/hugetlb.c            | 10 +++++++++-
 mm/memory-failure.c     |  5 +----
 mm/migrate.c            |  2 ++
 4 files changed, 14 insertions(+), 5 deletions(-)

diff --git v4.12-rc3/include/linux/hugetlb.h v4.12-rc3_patched/include/linux/hugetlb.h
index b857fc8..89afe40 100644
--- v4.12-rc3/include/linux/hugetlb.h
+++ v4.12-rc3_patched/include/linux/hugetlb.h
@@ -461,6 +461,7 @@ static inline pgoff_t basepage_index(struct page *page)
 	return __basepage_index(page);
 }
 
+extern int dissolve_free_huge_page(struct page *page);
 extern int dissolve_free_huge_pages(unsigned long start_pfn,
 				    unsigned long end_pfn);
 static inline bool hugepage_migration_supported(struct hstate *h)
@@ -529,6 +530,7 @@ static inline pgoff_t basepage_index(struct page *page)
 {
 	return page->index;
 }
+#define dissolve_free_huge_page(p)	0
 #define dissolve_free_huge_pages(s, e)	0
 #define hugepage_migration_supported(h)	false
 
diff --git v4.12-rc3/mm/hugetlb.c v4.12-rc3_patched/mm/hugetlb.c
index 6d6c659..41c37ed 100644
--- v4.12-rc3/mm/hugetlb.c
+++ v4.12-rc3_patched/mm/hugetlb.c
@@ -1443,7 +1443,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
  * number of free hugepages would be reduced below the number of reserved
  * hugepages.
  */
-static int dissolve_free_huge_page(struct page *page)
+int dissolve_free_huge_page(struct page *page)
 {
 	int rc = 0;
 
@@ -1456,6 +1456,14 @@ static int dissolve_free_huge_page(struct page *page)
 			rc = -EBUSY;
 			goto out;
 		}
+		/*
+		 * Move PageHWPoison flag from head page to the raw error page,
+		 * which makes any subpages rather than the error page reusable.
+		 */
+		if (PageHWPoison(head) && page != head) {
+			SetPageHWPoison(page);
+			ClearPageHWPoison(head);
+		}
 		list_del(&head->lru);
 		h->free_huge_pages--;
 		h->free_huge_pages_node[nid]--;
diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index aae620f..e03903f 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1571,11 +1571,8 @@ static int soft_offline_huge_page(struct page *page, int flags)
 		if (ret > 0)
 			ret = -EIO;
 	} else {
-		/* overcommit hugetlb page will be freed to buddy */
-		SetPageHWPoison(page);
 		if (PageHuge(page))
-			dequeue_hwpoisoned_huge_page(hpage);
-		num_poisoned_pages_inc();
+			dissolve_free_huge_page(page);
 	}
 	return ret;
 }
diff --git v4.12-rc3/mm/migrate.c v4.12-rc3_patched/mm/migrate.c
index 89a0a17..f0319db 100644
--- v4.12-rc3/mm/migrate.c
+++ v4.12-rc3_patched/mm/migrate.c
@@ -1251,6 +1251,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 out:
 	if (rc != -EAGAIN)
 		putback_active_hugepage(hpage);
+	if (reason == MR_MEMORY_FAILURE && !test_set_page_hwpoison(hpage))
+		num_poisoned_pages_inc();
 
 	/*
 	 * If migration was not successful and there's a freeing callback, use
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
