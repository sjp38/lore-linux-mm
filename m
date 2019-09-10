Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1304BC49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2CE620872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2CE620872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFBF56B000E; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71BF6B026D; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8261E6B026B; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 22B3C6B026D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BEF87181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-FDA: 75918642786.09.pail72_41f88ead7ef4c
X-HE-Tag: pail72_41f88ead7ef4c
X-Filterd-Recvd-Size: 5368
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E54D1AF93;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 09/10] mm,hwpoison: Rework soft offline for free pages
Date: Tue, 10 Sep 2019 12:30:15 +0200
Message-Id: <20190910103016.14290-10-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

take_page_off_buddy will be used to take a page meant to be poisoned
off the buddy allocator.
take_page_off_buddy calls break_down_buddy_pages, which will split a
higher-order page in case our page belongs to one.

Once we grab the page, we call page_set_poison to set it as poisoned
and grab a refcount on it.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/page-flags.h |  5 ----
 mm/memory-failure.c        |  6 +++--
 mm/page_alloc.c            | 59 +++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f91cb8898ff0..21df81c9ea57 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -414,13 +414,8 @@ PAGEFLAG_FALSE(Uncached)
 PAGEFLAG(HWPoison, hwpoison, PF_ANY)
 TESTSCFLAG(HWPoison, hwpoison, PF_ANY)
 #define __PG_HWPOISON (1UL << PG_hwpoison)
-extern bool set_hwpoison_free_buddy_page(struct page *page);
 #else
 PAGEFLAG_FALSE(HWPoison)
-static inline bool set_hwpoison_free_buddy_page(struct page *page)
-{
-	return 0;
-}
 #define __PG_HWPOISON 0
 #endif
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ce017a0d79a6..03f07015a106 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -78,6 +78,8 @@ EXPORT_SYMBOL_GPL(hwpoison_filter_dev_minor);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_mask);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_value);
 
+extern bool take_page_off_buddy(struct page *page);
+
 static bool page_set_poison(struct page *page)
 {
 	SetPageHWPoison(page);
@@ -1807,8 +1809,8 @@ static int soft_offline_free_page(struct page *page)
 	int rc = dissolve_free_huge_page(page);
 
 	if (!rc) {
-		if (set_hwpoison_free_buddy_page(page))
-			num_poisoned_pages_inc();
+		if (take_page_off_buddy(page))
+			page_set_poison(page);
 		else
 			rc = -EBUSY;
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fe38229d0a77..68f6c2cda512 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8605,30 +8605,71 @@ bool is_free_buddy_page(struct page *page)
 
 #ifdef CONFIG_MEMORY_FAILURE
 /*
- * Set PG_hwpoison flag if a given page is confirmed to be a free page.  This
- * test is performed under the zone lock to prevent a race against page
- * allocation.
+ * Break down a higher-order page in sub-pages, and keep our target out of
+ * buddy allocator.
  */
-bool set_hwpoison_free_buddy_page(struct page *page)
+static void break_down_buddy_pages(struct zone *zone, struct page *page,
+				   struct page *target, int low, int high,
+				   struct free_area *area, int migratetype)
+{
+	unsigned long size = 1 << high;
+	struct page *current_buddy, *next_page;
+
+	while (high > low) {
+		area--;
+		high--;
+		size >>= 1;
+
+		if (target >= &page[size]) {
+			next_page = page + size;
+			current_buddy = page;
+		} else {
+			next_page = page;
+			current_buddy = page + size;
+		}
+
+		if (set_page_guard(zone, current_buddy, high, migratetype))
+			continue;
+
+		if (current_buddy != target) {
+			add_to_free_area(current_buddy, area, migratetype);
+			set_page_order(current_buddy, high);
+			page = next_page;
+		}
+	}
+}
+
+/*
+ * Take a page that will be marked as poisoned off the buddy allocator.
+ */
+bool take_page_off_buddy(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long flags;
 	unsigned int order;
-	bool hwpoisoned = false;
+	bool ret = false;
 
 	spin_lock_irqsave(&zone->lock, flags);
 	for (order = 0; order < MAX_ORDER; order++) {
 		struct page *page_head = page - (pfn & ((1 << order) - 1));
+		int buddy_order = page_order(page_head);
+		struct free_area *area = &(zone->free_area[buddy_order]);
+
+		if (PageBuddy(page_head) && buddy_order >= order) {
+			unsigned long pfn_head = page_to_pfn(page_head);
+			int migratetype = get_pfnblock_migratetype(page_head,
+								   pfn_head);
 
-		if (PageBuddy(page_head) && page_order(page_head) >= order) {
-			if (!TestSetPageHWPoison(page))
-				hwpoisoned = true;
+			del_page_from_free_area(page_head, area);
+			break_down_buddy_pages(zone, page_head, page, 0,
+					       buddy_order, area, migratetype);
+			ret = true;
 			break;
 		}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
 
-	return hwpoisoned;
+	return ret;
 }
 #endif
-- 
2.12.3


