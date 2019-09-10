Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FB4AC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25A9A21019
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25A9A21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984F36B0269; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90BB36B0008; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 738FA6B000E; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 4B76E6B0008
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0C028181AC9B6
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:52 +0000 (UTC)
X-FDA: 75918642744.22.part19_41b9c497efd35
X-HE-Tag: part19_41b9c497efd35
X-Filterd-Recvd-Size: 2752
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8374FAE5E;
	Tue, 10 Sep 2019 10:30:49 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 03/10] mm,hwpoison-inject: don't pin for hwpoison_filter
Date: Tue, 10 Sep 2019 12:30:09 +0200
Message-Id: <20190910103016.14290-4-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Another memory error injection interface debugfs:hwpoison/corrupt-pfn
also takes bogus refcount for hwpoison_filter(). It's justified
because this does a coarse filter, expecting that memory_failure()
redoes the check for sure.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/hwpoison-inject.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 5b7430bd83a6..0c8cdb80fd7d 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -26,11 +26,6 @@ static int hwpoison_inject(void *data, u64 val)
 
 	p = pfn_to_page(pfn);
 	hpage = compound_head(p);
-	/*
-	 * This implies unable to support free buddy pages.
-	 */
-	if (!get_hwpoison_page(p))
-		return 0;
 
 	if (!hwpoison_filter_enable)
 		goto inject;
@@ -40,23 +35,20 @@ static int hwpoison_inject(void *data, u64 val)
 	 * This implies unable to support non-LRU pages.
 	 */
 	if (!PageLRU(hpage) && !PageHuge(p))
-		goto put_out;
+		return 0;
 
 	/*
-	 * do a racy check with elevated page count, to make sure PG_hwpoison
-	 * will only be set for the targeted owner (or on a free page).
+	 * do a racy check to make sure PG_hwpoison will only be set for
+	 * the targeted owner (or on a free page).
 	 * memory_failure() will redo the check reliably inside page lock.
 	 */
 	err = hwpoison_filter(hpage);
 	if (err)
-		goto put_out;
+		return 0;
 
 inject:
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
-	return memory_failure(pfn, MF_COUNT_INCREASED);
-put_out:
-	put_hwpoison_page(p);
-	return 0;
+	return memory_failure(pfn, 0);
 }
 
 static int hwpoison_unpoison(void *data, u64 val)
-- 
2.12.3


