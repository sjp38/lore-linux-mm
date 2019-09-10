Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8929BC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52B8F20872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52B8F20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F4E96B0010; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 231836B000C; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F00A36B0010; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0062.hostedemail.com [216.40.44.62])
	by kanga.kvack.org (Postfix) with ESMTP id B8AF26B000C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6808B813F
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-FDA: 75918642786.17.fuel52_41efec64e613b
X-HE-Tag: fuel52_41efec64e613b
X-Filterd-Recvd-Size: 3947
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9D768AF0B;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 04/10] mm,hwpoison: remove MF_COUNT_INCREASED
Date: Tue, 10 Sep 2019 12:30:10 +0200
Message-Id: <20190910103016.14290-5-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Now there's no user of MF_COUNT_INCREASED, so we can safely remove
it from all calling points.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 include/linux/mm.h  |  7 +++----
 mm/memory-failure.c | 16 +++-------------
 2 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad6766a08f9b..fb36a4165a4e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2814,10 +2814,9 @@ void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long nr_pages);
 
 enum mf_flags {
-	MF_COUNT_INCREASED = 1 << 0,
-	MF_ACTION_REQUIRED = 1 << 1,
-	MF_MUST_KILL = 1 << 2,
-	MF_SOFT_OFFLINE = 1 << 3,
+	MF_ACTION_REQUIRED = 1 << 0,
+	MF_MUST_KILL = 1 << 1,
+	MF_SOFT_OFFLINE = 1 << 2,
 };
 extern int memory_failure(unsigned long pfn, int flags);
 extern void memory_failure_queue(unsigned long pfn, int flags);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e43b61462fd5..1be785b25324 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1092,7 +1092,7 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
 
 	num_poisoned_pages_inc();
 
-	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
+	if (!get_hwpoison_page(p)) {
 		/*
 		 * Check "filter hit" and "race with other subpage."
 		 */
@@ -1286,7 +1286,7 @@ int memory_failure(unsigned long pfn, int flags)
 	 * In fact it's dangerous to directly bump up page count from 0,
 	 * that may make page_ref_freeze()/page_ref_unfreeze() mismatch.
 	 */
-	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
+	if (!get_hwpoison_page(p)) {
 		if (is_free_buddy_page(p)) {
 			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
 			return 0;
@@ -1327,10 +1327,7 @@ int memory_failure(unsigned long pfn, int flags)
 	shake_page(p, 0);
 	/* shake_page could have turned it free. */
 	if (!PageLRU(p) && is_free_buddy_page(p)) {
-		if (flags & MF_COUNT_INCREASED)
-			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
-		else
-			action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
+		action_result(pfn, MF_MSG_BUDDY_2ND, MF_DELAYED);
 		return 0;
 	}
 
@@ -1618,9 +1615,6 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 {
 	int ret;
 
-	if (flags & MF_COUNT_INCREASED)
-		return 1;
-
 	/*
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
@@ -1890,15 +1884,11 @@ int soft_offline_page(struct page *page, int flags)
 	if (is_zone_device_page(page)) {
 		pr_debug_ratelimited("soft_offline: %#lx page is device page\n",
 				pfn);
-		if (flags & MF_COUNT_INCREASED)
-			put_page(page);
 		return -EIO;
 	}
 
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
-		if (flags & MF_COUNT_INCREASED)
-			put_hwpoison_page(page);
 		return -EBUSY;
 	}
 
-- 
2.12.3


