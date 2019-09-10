Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBEB0C4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A73DA20872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A73DA20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233776B026E; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 196DB6B000E; Tue, 10 Sep 2019 06:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6FBF6B026A; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id BCAD86B000E
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7C488824376D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:53 +0000 (UTC)
X-FDA: 75918642786.18.bulb57_41f2ee7033a08
X-HE-Tag: bulb57_41f2ee7033a08
X-Filterd-Recvd-Size: 3455
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:52 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 02ADFB008;
	Tue, 10 Sep 2019 10:30:50 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 10/10] mm,hwpoison: Use hugetlb_replace_page to replace free hugetlb pages
Date: Tue, 10 Sep 2019 12:30:16 +0200
Message-Id: <20190910103016.14290-11-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When soft offlining a free hugtlb, try first to allocate a new hugetlb
to the pool and pass the old state to the new one by move_hugetlb_state().
Either we succeed or not, we dissolve the poisoned hugetlb page.

Worst-scenario case is that we cannot allocate a new fresh hugetlb page
as a replacement.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/hugetlb.c        | 16 ++++++++++++++++
 mm/memory-failure.c | 34 ++++++++++++++++++++++++++++------
 2 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 139e1c05c9a1..d0844aec7531 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -5154,3 +5154,19 @@ void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
 		spin_unlock(&hugetlb_lock);
 	}
 }
+
+#ifdef CONFIG_MEMORY_FAILURE
+int hugetlb_replace_page(struct page *page, int reason)
+{
+	int nid = page_to_nid(page);
+	struct hstate *h = page_hstate(page);
+	struct page *new_page;
+
+	new_page = alloc_huge_page_nodemask(h, nid, &node_states[N_MEMORY]);
+	if (!new_page)
+		return -ENOMEM;
+
+	move_hugetlb_state(page, new_page, reason);
+	return 0;
+}
+#endif
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 03f07015a106..fe73fe19c6e9 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -79,6 +79,7 @@ EXPORT_SYMBOL_GPL(hwpoison_filter_flags_mask);
 EXPORT_SYMBOL_GPL(hwpoison_filter_flags_value);
 
 extern bool take_page_off_buddy(struct page *page);
+extern int hugetlb_replace_page(struct page *page, int reason);
 
 static bool page_set_poison(struct page *page)
 {
@@ -1804,16 +1805,37 @@ static int soft_offline_in_use_page(struct page *page)
 	return __soft_offline_page(page);
 }
 
+static int soft_offline_free_huge_page(struct page *page)
+{
+	struct page *hpage = compound_head(page);
+
+	/*
+	 * Try to add a new hugetlb page to the pool
+	 */
+	if (hugetlb_replace_page(hpage, MR_MEMORY_FAILURE))
+		return -EBUSY;
+
+	/*
+	 * Remove old hugetlb from the pool
+	 */
+	if (!page_set_poison(hpage))
+		return -EBUSY;
+
+	return 0;
+}
+
 static int soft_offline_free_page(struct page *page)
 {
-	int rc = dissolve_free_huge_page(page);
+	int rc = -EBUSY;
 
-	if (!rc) {
-		if (take_page_off_buddy(page))
+	if (PageHuge(page))
+		rc = soft_offline_free_huge_page(page);
+	else
+		if (take_page_off_buddy(page)) {
 			page_set_poison(page);
-		else
-			rc = -EBUSY;
-	}
+			rc = 0;
+		}
+
 	return rc;
 }
 
-- 
2.12.3


