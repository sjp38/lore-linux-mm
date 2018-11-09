Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4346B06A2
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:47 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a72-v6so766576pfj.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t78-v6sor8132087pfa.32.2018.11.08.22.47.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:45 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 07/11] mm: remove flag argument from soft offline functions
Date: Fri,  9 Nov 2018 15:47:11 +0900
Message-Id: <1541746035-13408-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

The argument @flag no longer affects the behavior of soft_offline_page()
and its variants, so let's remove them.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 drivers/base/memory.c |  2 +-
 include/linux/mm.h    |  2 +-
 mm/madvise.c          |  2 +-
 mm/memory-failure.c   | 27 +++++++++++++--------------
 4 files changed, 16 insertions(+), 17 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/drivers/base/memory.c v4.19-mmotm-2018-10-30-16-08_patched/drivers/base/memory.c
index 0e59856..4a554a5 100644
--- v4.19-mmotm-2018-10-30-16-08/drivers/base/memory.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/drivers/base/memory.c
@@ -548,7 +548,7 @@ store_soft_offline_page(struct device *dev,
 	pfn >>= PAGE_SHIFT;
 	if (!pfn_valid(pfn))
 		return -ENXIO;
-	ret = soft_offline_page(pfn_to_page(pfn), 0);
+	ret = soft_offline_page(pfn_to_page(pfn));
 	return ret == 0 ? count : ret;
 }
 
diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
index f85b450..6c496da 100644
--- v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h
+++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
@@ -2738,7 +2738,7 @@ extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
 extern atomic_long_t num_poisoned_pages __read_mostly;
-extern int soft_offline_page(struct page *page, int flags);
+extern int soft_offline_page(struct page *page);
 
 #ifdef CONFIG_MEMORY_FAILURE
 /*
diff --git v4.19-mmotm-2018-10-30-16-08/mm/madvise.c v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
index 9fa0225..86453f3 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/madvise.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
@@ -660,7 +660,7 @@ static int madvise_inject_error(int behavior,
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
 					pfn, start);
 
-			ret = soft_offline_page(page, 0);
+			ret = soft_offline_page(page);
 			if (ret)
 				return ret;
 			continue;
diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index ed347f8..869ff8f 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -1482,7 +1482,7 @@ static void memory_failure_work_func(struct work_struct *work)
 		if (!gotten)
 			break;
 		if (entry.flags & MF_SOFT_OFFLINE)
-			soft_offline_page(pfn_to_page(entry.pfn), entry.flags);
+			soft_offline_page(pfn_to_page(entry.pfn));
 		else
 			memory_failure(entry.pfn, entry.flags);
 	}
@@ -1615,7 +1615,7 @@ static struct page *new_page(struct page *p, unsigned long private)
  * that is not free, and 1 for any other page type.
  * For 1 the page is returned with increased page count, otherwise not.
  */
-static int __get_any_page(struct page *p, unsigned long pfn, int flags)
+static int __get_any_page(struct page *p, unsigned long pfn)
 {
 	int ret;
 
@@ -1642,9 +1642,9 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 	return ret;
 }
 
-static int get_any_page(struct page *page, unsigned long pfn, int flags)
+static int get_any_page(struct page *page, unsigned long pfn)
 {
-	int ret = __get_any_page(page, pfn, flags);
+	int ret = __get_any_page(page, pfn);
 
 	if (ret == 1 && !PageHuge(page) &&
 	    !PageLRU(page) && !__PageMovable(page)) {
@@ -1657,7 +1657,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		/*
 		 * Did it turn free?
 		 */
-		ret = __get_any_page(page, pfn, 0);
+		ret = __get_any_page(page, pfn);
 		if (ret == 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
 			put_hwpoison_page(page);
@@ -1669,7 +1669,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 	return ret;
 }
 
-static int soft_offline_huge_page(struct page *page, int flags)
+static int soft_offline_huge_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1730,7 +1730,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	return ret;
 }
 
-static int __soft_offline_page(struct page *page, int flags)
+static int __soft_offline_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1815,7 +1815,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	return ret;
 }
 
-static int soft_offline_in_use_page(struct page *page, int flags)
+static int soft_offline_in_use_page(struct page *page)
 {
 	int ret;
 	int mt;
@@ -1847,9 +1847,9 @@ static int soft_offline_in_use_page(struct page *page, int flags)
 	mt = get_pageblock_migratetype(page);
 	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 	if (PageHuge(page))
-		ret = soft_offline_huge_page(page, flags);
+		ret = soft_offline_huge_page(page);
 	else
-		ret = __soft_offline_page(page, flags);
+		ret = __soft_offline_page(page);
 	set_pageblock_migratetype(page, mt);
 	return ret;
 }
@@ -1873,7 +1873,6 @@ static int soft_offline_free_page(struct page *page)
 /**
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
- * @flags: flags. Same as memory_failure().
  *
  * Returns 0 on success, otherwise negated errno.
  *
@@ -1892,7 +1891,7 @@ static int soft_offline_free_page(struct page *page)
  * This is not a 100% solution for all memory, but tries to be
  * ``good enough'' for the majority of memory.
  */
-int soft_offline_page(struct page *page, int flags)
+int soft_offline_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1909,11 +1908,11 @@ int soft_offline_page(struct page *page, int flags)
 	}
 
 	get_online_mems();
-	ret = get_any_page(page, pfn, flags);
+	ret = get_any_page(page, pfn);
 	put_online_mems();
 
 	if (ret > 0)
-		ret = soft_offline_in_use_page(page, flags);
+		ret = soft_offline_in_use_page(page);
 	else if (ret == 0)
 		ret = soft_offline_free_page(page);
 
-- 
2.7.0
