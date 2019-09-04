Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5BECC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 10:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ADAD2339E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 10:29:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ADAD2339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E12E56B0003; Wed,  4 Sep 2019 06:29:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9C906B0006; Wed,  4 Sep 2019 06:29:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8A7E6B0007; Wed,  4 Sep 2019 06:29:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id A24536B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:29:12 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3E370180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:29:12 +0000 (UTC)
X-FDA: 75896865744.17.air74_8a81624d18e62
X-HE-Tag: air74_8a81624d18e62
X-Filterd-Recvd-Size: 1808
Received: from huawei.com (szxga07-in.huawei.com [45.249.212.35])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:29:11 +0000 (UTC)
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id EE76BC91298ED4A67C5A;
	Wed,  4 Sep 2019 18:29:07 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.439.0; Wed, 4 Sep 2019 18:28:57 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <mhocko@kernel.org>
CC: <anshuman.khandual@arm.com>, <vbabka@suse.cz>, <zhongjiang@huawei.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] mm: Unsigned 'nr_pages' always larger than zero
Date: Wed, 4 Sep 2019 18:26:03 +0800
Message-ID: <1567592763-25282-1-git-send-email-zhongjiang@huawei.com>
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

With the help of unsigned_lesser_than_zero.cocci. Unsigned 'nr_pages"'
compare with zero. And __get_user_pages_locked will return an long value.
Hence, Convert the long to compare with zero is feasible.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/gup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 23a9f9c..956d5a1 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1508,7 +1508,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 						   pages, vmas, NULL,
 						   gup_flags);
 
-		if ((nr_pages > 0) && migrate_allow) {
+		if (((long)nr_pages > 0) && migrate_allow) {
 			drain_allow = true;
 			goto check_again;
 		}
-- 
1.7.12.4


