Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BCFC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C40E320872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C40E320872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDA0C6B0266; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D6E66B026C; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 767006B026A; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 04D6C6B026C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id AEBD58141
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-FDA: 75918642786.26.cakes93_41f2bd5800f25
X-HE-Tag: cakes93_41f2bd5800f25
X-Filterd-Recvd-Size: 7863
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9153AFE4;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 08/10] mm,hwpoison: Refactor soft_offline_huge_page and __soft_offline_page
Date: Tue, 10 Sep 2019 12:30:14 +0200
Message-Id: <20190910103016.14290-9-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

soft_offline_huge_page and __soft_offline_page share quite some code,
and it can be re-joined into one single function without losing neither
functionatilty nor readibility.

This allows us of getting rid of quite some duplicated code.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/memory-failure.c | 145 ++++++++++++++++++++--------------------------------
 1 file changed, 56 insertions(+), 89 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d44dacb8e2ea..ce017a0d79a6 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1689,57 +1689,48 @@ static int get_any_page(struct page *page, unsigned long pfn)
 	return ret;
 }
 
-static int soft_offline_huge_page(struct page *page)
+static bool isolate_page(struct page *page, struct list_head *pagelist)
 {
-	int ret;
-	unsigned long pfn = page_to_pfn(page);
-	struct page *hpage = compound_head(page);
-	LIST_HEAD(pagelist);
+	bool isolated = false;
+	bool lru = PageLRU(page);
 
-	/*
-	 * This double-check of PageHWPoison is to avoid the race with
-	 * memory_failure(). See also comment in __soft_offline_page().
-	 */
-	lock_page(hpage);
-	if (PageHWPoison(hpage)) {
-		unlock_page(hpage);
-		put_hwpoison_page(hpage);
-		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
-		return -EBUSY;
+	if (PageHuge(page)) {
+		isolated = isolate_huge_page(page, pagelist);
+	} else {
+		if (PageLRU(page))
+			isolated = !isolate_lru_page(page);
+		else
+			isolated = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
+
+		if (isolated) {
+			if (lru)
+				inc_node_page_state(page, NR_ISOLATED_ANON +
+						    page_is_file_cache(page));
+			list_add(&page->lru, pagelist);
+		}
 	}
-	unlock_page(hpage);
 
-	ret = isolate_huge_page(hpage, &pagelist);
 	/*
-	 * get_any_page() and isolate_huge_page() takes a refcount each,
-	 * so need to drop one here.
+	 * If we succeed to isolate the page, we grabbed another refcount on
+	 * the page, so we can safely drop the one we got from get_any_pages().
+	 * If we failed to isolate the page, it means that we cannot go further
+	 * any further and we will return an error, so drop the reference we got
+	 * from get_any_pages() as well.
 	 */
-	put_hwpoison_page(hpage);
-	if (!ret) {
-		pr_info("soft offline: %#lx hugepage failed to isolate\n", pfn);
-		return -EBUSY;
-	}
-
-	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-				MIGRATE_SYNC, MR_MEMORY_FAILURE);
-	if (!ret) {
-		if (!page_set_poison(page))
-			ret = -EBUSY;
-	} else {
-		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
-			pfn, ret, page->flags, &page->flags);
-		if (!list_empty(&pagelist))
-			putback_movable_pages(&pagelist);
-		if (ret > 0)
-			ret = -EIO;
-	}
-	return ret;
+	put_hwpoison_page(page);
+	return isolated;
 }
-
+/*
+ * This routine handles both hugetlb and normal pages
+ */
 static int __soft_offline_page(struct page *page)
 {
-	int ret;
+	int ret = 0;
 	unsigned long pfn = page_to_pfn(page);
+	struct page *hpage = compound_head(page);
+	const char *msg_page[] = { "page", "hugepage"};
+	bool huge = PageHuge(page);
+	LIST_HEAD(pagelist);
 
 	/*
 	 * Check PageHWPoison again inside page lock because PageHWPoison
@@ -1747,92 +1738,68 @@ static int __soft_offline_page(struct page *page)
 	 * memory_failure() also double-checks PageHWPoison inside page lock,
 	 * so there's no race between soft_offline_page() and memory_failure().
 	 */
-	lock_page(page);
-	wait_on_page_writeback(page);
-	if (PageHWPoison(page)) {
-		unlock_page(page);
-		put_hwpoison_page(page);
+	lock_page(hpage);
+	if (!PageHuge(page))
+		wait_on_page_writeback(page);
+	if (PageHWPoison(hpage)) {
+		unlock_page(hpage);
+		put_hwpoison_page(hpage);
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
 		return -EBUSY;
 	}
-	/*
-	 * Try to invalidate first. This should work for
-	 * non dirty unmapped page cache pages.
-	 */
-	ret = invalidate_inode_page(page);
+
+	if (!PageHuge(page))
+		/*
+		 * Try to invalidate first. This should work for
+		 * non dirty unmapped page cache pages.
+		 */
+		ret = invalidate_inode_page(page);
 	unlock_page(page);
 	/*
 	 * RED-PEN would be better to keep it isolated here, but we
 	 * would need to fix isolation locking first.
 	 */
-	if (ret == 1) {
+	if (ret) {
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		page_set_poison(page);
 		return 0;
 	}
 
-	/*
-	 * Simple invalidation didn't work.
-	 * Try to migrate to a new page instead. migrate.c
-	 * handles a large number of cases for us.
-	 */
-	if (PageLRU(page))
-		ret = isolate_lru_page(page);
-	else
-		ret = isolate_movable_page(page, ISOLATE_UNEVICTABLE);
-	/*
-	 * Drop page reference which is came from get_any_page()
-	 * successful isolate_lru_page() already took another one.
-	 */
-	put_hwpoison_page(page);
-	if (!ret) {
-		LIST_HEAD(pagelist);
-		/*
-		 * After isolated lru page, the PageLRU will be cleared,
-		 * so use !__PageMovable instead for LRU page's mapping
-		 * cannot have PAGE_MAPPING_MOVABLE.
-		 */
-		if (!__PageMovable(page))
-			inc_node_page_state(page, NR_ISOLATED_ANON +
-						page_is_file_cache(page));
-		list_add(&page->lru, &pagelist);
+	if (isolate_page(hpage, &pagelist)) {
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-					MIGRATE_SYNC, MR_MEMORY_FAILURE);
+				    MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (!ret) {
 			/*
 			 * Page was succesfully migrated.
 			 */
-			page_set_poison(page);
+			if (!page_set_poison(page))
+				ret = -EBUSY;
 		} else {
 			if (!list_empty(&pagelist))
 				putback_movable_pages(&pagelist);
 
-			pr_info("soft offline: %#lx: migration failed %d, type %lx (%pGp)\n",
-				pfn, ret, page->flags, &page->flags);
+			pr_info("soft offline: %#lx: %s migration failed %d, type %lx (%pGp)\n",
+				 pfn, msg_page[huge], ret, page->flags, &page->flags);
 			if (ret > 0)
 				ret = -EIO;
 		}
 	} else {
-		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx (%pGp)\n",
-			pfn, ret, page_count(page), page->flags, &page->flags);
+		pr_info("soft offline: %#lx %s isolation failed: %d, page count %d, type %lx (%pGp)\n",
+			 pfn, msg_page[huge], ret, page_count(page), page->flags, &page->flags);
 	}
+
 	return ret;
 }
 
 static int soft_offline_in_use_page(struct page *page)
 {
-	int ret;
 	struct page *hpage = compound_head(page);
 
 	if (!PageHuge(page) && PageTransHuge(hpage))
 		if (try_to_split_thp_page(page, "soft offline") < 0)
 			return -EBUSY;
 
-	if (PageHuge(page))
-		ret = soft_offline_huge_page(page);
-	else
-		ret = __soft_offline_page(page);
-	return ret;
+	return __soft_offline_page(page);
 }
 
 static int soft_offline_free_page(struct page *page)
-- 
2.12.3


