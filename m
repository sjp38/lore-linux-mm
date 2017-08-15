Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D46D66B02F3
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 21:52:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k126so60615530qke.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:43 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id n8si7726303qtb.203.2017.08.14.18.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 18:52:42 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [RFC PATCH 2/4] mm: soft-offline: Change soft_offline_page() interface to tell if the page is split or not.
Date: Mon, 14 Aug 2017 21:52:14 -0400
Message-Id: <20170815015216.31827-3-zi.yan@sent.com>
In-Reply-To: <20170815015216.31827-1-zi.yan@sent.com>
References: <20170815015216.31827-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

This prepares for THP migration support. During soft-offlining,
if a THP is migrated without splitting, we need to soft-offline pages
after the THP. Otherwise, we need to soft-offline the next subpage in
that THP.

The new added output parameter in soft_offline_page() help distinguish
the two conditions above. As THPs are split after they are free,
we cannot distinguish the two conditions by examining the soft-offlined
pages.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 drivers/base/memory.c |  2 +-
 include/linux/mm.h    |  2 +-
 mm/madvise.c          |  9 +++++----
 mm/memory-failure.c   | 11 +++++++----
 4 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 4e3b61cda520..3ab25b05d5e8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -551,7 +551,7 @@ store_soft_offline_page(struct device *dev,
 	pfn >>= PAGE_SHIFT;
 	if (!pfn_valid(pfn))
 		return -ENXIO;
-	ret = soft_offline_page(pfn_to_page(pfn), 0);
+	ret = soft_offline_page(pfn_to_page(pfn), 0, NULL);
 	return ret == 0 ? count : ret;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6f543a47fc92..d392fa090ab5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2467,7 +2467,7 @@ extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
 extern atomic_long_t num_poisoned_pages;
-extern int soft_offline_page(struct page *page, int flags);
+extern int soft_offline_page(struct page *page, int flags, int *split);
 
 
 /*
diff --git a/mm/madvise.c b/mm/madvise.c
index 49f6774db259..857255db404a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -634,17 +634,18 @@ static int madvise_inject_error(int behavior,
 		}
 
 		if (behavior == MADV_SOFT_OFFLINE) {
+			int split = 0;
+
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
 						page_to_pfn(page), start);
 
-			ret = soft_offline_page(page, MF_COUNT_INCREASED);
+			ret = soft_offline_page(page, MF_COUNT_INCREASED, &split);
 			if (ret)
 				return ret;
 			/*
-			 * Non hugetlb pages either have PAGE_SIZE
-			 * or are split into PAGE_SIZE
+			 * If the page is split, page_size should be changed.
 			 */
-			if (!PageHuge(page))
+			if (split)
 				page_size = PAGE_SIZE;
 			continue;
 		}
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8b8ff29412b6..8a9ac6f9e1b0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1361,7 +1361,7 @@ static void memory_failure_work_func(struct work_struct *work)
 		if (!gotten)
 			break;
 		if (entry.flags & MF_SOFT_OFFLINE)
-			soft_offline_page(pfn_to_page(entry.pfn), entry.flags);
+			soft_offline_page(pfn_to_page(entry.pfn), entry.flags, NULL);
 		else
 			memory_failure(entry.pfn, entry.trapno, entry.flags);
 	}
@@ -1678,7 +1678,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	return ret;
 }
 
-static int soft_offline_in_use_page(struct page *page, int flags)
+static int soft_offline_in_use_page(struct page *page, int flags, int *split)
 {
 	int ret;
 	struct page *hpage = compound_head(page);
@@ -1694,6 +1694,8 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 			put_hwpoison_page(hpage);
 			return -EBUSY;
 		}
+		if (split)
+			*split = 1;
 		unlock_page(hpage);
 		get_hwpoison_page(page);
 		put_hwpoison_page(hpage);
@@ -1722,6 +1724,7 @@ static void soft_offline_free_page(struct page *page)
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
  * @flags: flags. Same as memory_failure().
+ * @split: output. Tells if page is split or not.
  *
  * Returns 0 on success, otherwise negated errno.
  *
@@ -1740,7 +1743,7 @@ static void soft_offline_free_page(struct page *page)
  * This is not a 100% solution for all memory, but tries to be
  * ``good enough'' for the majority of memory.
  */
-int soft_offline_page(struct page *page, int flags)
+int soft_offline_page(struct page *page, int flags, int *split)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1757,7 +1760,7 @@ int soft_offline_page(struct page *page, int flags)
 	put_online_mems();
 
 	if (ret > 0)
-		ret = soft_offline_in_use_page(page, flags);
+		ret = soft_offline_in_use_page(page, flags, split);
 	else if (ret == 0)
 		soft_offline_free_page(page);
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
