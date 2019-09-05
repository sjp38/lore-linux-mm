Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01BB4C3A5A9
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4FBA20828
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:21:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4FBA20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F1D86B0003; Wed,  4 Sep 2019 22:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A9F6B0005; Wed,  4 Sep 2019 22:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4745E6B0006; Wed,  4 Sep 2019 22:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9706B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:21:17 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B504A180AD802
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:21:16 +0000 (UTC)
X-FDA: 75899264952.28.key98_b097d915d710
X-HE-Tag: key98_b097d915d710
X-Filterd-Recvd-Size: 2528
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:21:15 +0000 (UTC)
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 1C4D95E9A6A9F53753EB;
	Thu,  5 Sep 2019 10:21:12 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS409-HUB.china.huawei.com (10.3.19.209) with Microsoft SMTP Server id
 14.3.439.0; Thu, 5 Sep 2019 10:21:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <vbabka@suse.cz>
CC: <mhocko@kernel.org>, <zhongjiang@huawei.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH v2] mm: Unsigned 'nr_pages' always larger than zero
Date: Thu, 5 Sep 2019 10:17:51 +0800
Message-ID: <1567649871-60594-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages'
compare with zero. And __gup_longterm_locked pass an long local variant
'rc' to check_and_migrate_cma_pages. Hence it is nicer to change the
parameter to long to fix the issue.

Fixes: 932f4a630a69 ("mm/gup: replace get_user_pages_longterm() with FOLL_LONGTERM")
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/gup.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 23a9f9c..ee0b71f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1433,13 +1433,13 @@ static struct page *new_non_cma_page(struct page *page, unsigned long private)
 static long check_and_migrate_cma_pages(struct task_struct *tsk,
 					struct mm_struct *mm,
 					unsigned long start,
-					unsigned long nr_pages,
+					long nr_pages,
 					struct page **pages,
 					struct vm_area_struct **vmas,
 					unsigned int gup_flags)
 {
-	unsigned long i;
-	unsigned long step;
+	long i;
+	long step;
 	bool drain_allow = true;
 	bool migrate_allow = true;
 	LIST_HEAD(cma_page_list);
@@ -1520,7 +1520,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 static long check_and_migrate_cma_pages(struct task_struct *tsk,
 					struct mm_struct *mm,
 					unsigned long start,
-					unsigned long nr_pages,
+					long nr_pages,
 					struct page **pages,
 					struct vm_area_struct **vmas,
 					unsigned int gup_flags)
-- 
1.7.12.4


