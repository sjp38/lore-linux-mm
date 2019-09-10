Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50B39C49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25BE32089F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25BE32089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6586B000A; Tue, 10 Sep 2019 06:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1C686B0010; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF2FB6B0008; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0021.hostedemail.com [216.40.44.21])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8276B0010
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:30:52 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 003A6181AC9AE
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-FDA: 75918642744.13.jewel02_41ba2b242c902
X-HE-Tag: jewel02_41ba2b242c902
X-Filterd-Recvd-Size: 1915
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:30:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9D176B12E;
	Tue, 10 Sep 2019 10:30:23 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: n-horiguchi@ah.jp.nec.com
Cc: mhocko@kernel.org,
	mike.kravetz@oracle.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 01/10] mm,hwpoison: cleanup unused PageHuge() check
Date: Tue, 10 Sep 2019 12:30:07 +0200
Message-Id: <20190910103016.14290-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
References: <20190910103016.14290-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

memory_failure() forks to memory_failure_hugetlb() for hugetlb pages,
so a PageHuge() check after the fork should not be necessary.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/memory-failure.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7ef849da8278..e43b61462fd5 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1353,10 +1353,7 @@ int memory_failure(unsigned long pfn, int flags)
 	 * page_remove_rmap() in try_to_unmap_one(). So to determine page status
 	 * correctly, we save a copy of the page flags at this time.
 	 */
-	if (PageHuge(p))
-		page_flags = hpage->flags;
-	else
-		page_flags = p->flags;
+	page_flags = p->flags;
 
 	/*
 	 * unpoison always clear PG_hwpoison inside page lock
-- 
2.12.3


