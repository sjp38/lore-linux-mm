Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 245E1C5ACAE
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8C8E21479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8C8E21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E98D76B0003; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA58D6B000E; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BE1E6B0266; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0056.hostedemail.com [216.40.44.56])
	by kanga.kvack.org (Postfix) with ESMTP id 4E78D6B000A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0029B8135
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-FDA: 75918642744.11.truck10_41b9b2767545a
X-HE-Tag: truck10_41b9b2767545a
X-Filterd-Recvd-Size: 3221
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 75BC5ABED;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 02/10] mm,madvise: call soft_offline_page() without MF_COUNT_INCREASED
Date: Tue, 10 Sep 2019 12:30:08 +0200
Message-Id: <20190910103016.14290-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently madvise_inject_error() pins the target via get_user_pages_fast.
The call to get_user_pages_fast is only to get the respective page
of a given address, but it is the job of the memory-poisoning handler
to deal with races, so drop the refcount grabbed by get_user_pages_fast.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/madvise.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 6e023414f5c1..fbe6d402232c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -883,6 +883,16 @@ static int madvise_inject_error(int behavior,
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
+		/*
+		 * The get_user_pages_fast() is just to get the pfn of the
+		 * given address, and the refcount has nothing to do with
+		 * what we try to test, so it should be released immediately.
+		 * This is racy but it's intended because the real hardware
+		 * errors could happen at any moment and memory error handlers
+		 * must properly handle the race.
+		 */
+		put_page(page);
+
 		pfn = page_to_pfn(page);
 
 		/*
@@ -892,16 +902,11 @@ static int madvise_inject_error(int behavior,
 		 */
 		order = compound_order(compound_head(page));
 
-		if (PageHWPoison(page)) {
-			put_page(page);
-			continue;
-		}
-
 		if (behavior == MADV_SOFT_OFFLINE) {
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
 					pfn, start);
 
-			ret = soft_offline_page(page, MF_COUNT_INCREASED);
+			ret = soft_offline_page(page, 0);
 			if (ret)
 				return ret;
 			continue;
@@ -909,14 +914,6 @@ static int madvise_inject_error(int behavior,
 
 		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
 				pfn, start);
-
-		/*
-		 * Drop the page reference taken by get_user_pages_fast(). In
-		 * the absence of MF_COUNT_INCREASED the memory_failure()
-		 * routine is responsible for pinning the page to prevent it
-		 * from being released back to the page allocator.
-		 */
-		put_page(page);
 		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
-- 
2.12.3


