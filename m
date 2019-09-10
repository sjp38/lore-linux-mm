Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A71FDC49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 634A220872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634A220872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 184016B0008; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE346B000C; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 981F26B0003; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3FA6B000C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 11E2D824376E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:52 +0000 (UTC)
X-FDA: 75918642744.19.match90_41b91e8a4cd27
X-HE-Tag: match90_41b91e8a4cd27
X-Filterd-Recvd-Size: 6671
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9D29BAE84;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 05/10] mm: remove flag argument from soft offline functions
Date: Tue, 10 Sep 2019 12:30:11 +0200
Message-Id: <20190910103016.14290-6-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

The argument @flag no longer affects the behavior of soft_offline_page()
and its variants, so let's remove them.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/memory.c |  2 +-
 include/linux/mm.h    |  2 +-
 mm/madvise.c          |  2 +-
 mm/memory-failure.c   | 27 +++++++++++++--------------
 4 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 6bea4f3f8040..e5485c22ef77 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -540,7 +540,7 @@ static ssize_t soft_offline_page_store(struct device *dev,
 	pfn >>= PAGE_SHIFT;
 	if (!pfn_valid(pfn))
 		return -ENXIO;
-	ret = soft_offline_page(pfn_to_page(pfn), 0);
+	ret = soft_offline_page(pfn_to_page(pfn));
 	return ret == 0 ? count : ret;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fb36a4165a4e..3cc800d9f57a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2827,7 +2827,7 @@ extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
 extern atomic_long_t num_poisoned_pages __read_mostly;
-extern int soft_offline_page(struct page *page, int flags);
+extern int soft_offline_page(struct page *page);
 
 
 /*
diff --git a/mm/madvise.c b/mm/madvise.c
index fbe6d402232c..ece128211400 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -906,7 +906,7 @@ static int madvise_inject_error(int behavior,
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
 					pfn, start);
 
-			ret = soft_offline_page(page, 0);
+			ret = soft_offline_page(page);
 			if (ret)
 				return ret;
 			continue;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1be785b25324..5071d39bdfef 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1478,7 +1478,7 @@ static void memory_failure_work_func(struct work_struct *work)
 		if (!gotten)
 			break;
 		if (entry.flags & MF_SOFT_OFFLINE)
-			soft_offline_page(pfn_to_page(entry.pfn), entry.flags);
+			soft_offline_page(pfn_to_page(entry.pfn));
 		else
 			memory_failure(entry.pfn, entry.flags);
 	}
@@ -1611,7 +1611,7 @@ static struct page *new_page(struct page *p, unsigned long private)
  * that is not free, and 1 for any other page type.
  * For 1 the page is returned with increased page count, otherwise not.
  */
-static int __get_any_page(struct page *p, unsigned long pfn, int flags)
+static int __get_any_page(struct page *p, unsigned long pfn)
 {
 	int ret;
 
@@ -1638,9 +1638,9 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 	return ret;
 }
 
-static int get_any_page(struct page *page, unsigned long pfn, int flags)
+static int get_any_page(struct page *page, unsigned long pfn)
 {
-	int ret = __get_any_page(page, pfn, flags);
+	int ret = __get_any_page(page, pfn);
 
 	if (ret == 1 && !PageHuge(page) &&
 	    !PageLRU(page) && !__PageMovable(page)) {
@@ -1653,7 +1653,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		/*
 		 * Did it turn free?
 		 */
-		ret = __get_any_page(page, pfn, 0);
+		ret = __get_any_page(page, pfn);
 		if (ret == 1 && !PageLRU(page)) {
 			/* Drop page reference which is from __get_any_page() */
 			put_hwpoison_page(page);
@@ -1665,7 +1665,7 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 	return ret;
 }
 
-static int soft_offline_huge_page(struct page *page, int flags)
+static int soft_offline_huge_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1724,7 +1724,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	return ret;
 }
 
-static int __soft_offline_page(struct page *page, int flags)
+static int __soft_offline_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1804,7 +1804,7 @@ static int __soft_offline_page(struct page *page, int flags)
 	return ret;
 }
 
-static int soft_offline_in_use_page(struct page *page, int flags)
+static int soft_offline_in_use_page(struct page *page)
 {
 	int ret;
 	int mt;
@@ -1834,9 +1834,9 @@ static int soft_offline_in_use_page(struct page *page, int flags)
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
@@ -1857,7 +1857,6 @@ static int soft_offline_free_page(struct page *page)
 /**
  * soft_offline_page - Soft offline a page.
  * @page: page to offline
- * @flags: flags. Same as memory_failure().
  *
  * Returns 0 on success, otherwise negated errno.
  *
@@ -1876,7 +1875,7 @@ static int soft_offline_free_page(struct page *page)
  * This is not a 100% solution for all memory, but tries to be
  * ``good enough'' for the majority of memory.
  */
-int soft_offline_page(struct page *page, int flags)
+int soft_offline_page(struct page *page)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
@@ -1893,11 +1892,11 @@ int soft_offline_page(struct page *page, int flags)
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
2.12.3


