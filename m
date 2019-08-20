Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38903C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F115A22CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F115A22CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A08336B0271; Tue, 20 Aug 2019 05:50:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B77C6B0272; Tue, 20 Aug 2019 05:50:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F4866B0274; Tue, 20 Aug 2019 05:50:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 6914F6B0271
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:50:27 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1A288269DE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:50:27 +0000 (UTC)
X-FDA: 75842336094.17.loss67_5b2242519fc0d
X-HE-Tag: loss67_5b2242519fc0d
X-Filterd-Recvd-Size: 3047
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com [115.124.30.54])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:50:25 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=16;SR=0;TI=SMTPD_---0TZzk.Bv_1566294575;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZzk.Bv_1566294575)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:35 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Peng Fan <peng.fan@nxp.com>,
	Nikolay Borisov <nborisov@suse.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 07/14] lru/swap: using per lruvec lock in page_cache_release
Date: Tue, 20 Aug 2019 17:48:30 +0800
Message-Id: <1566294517-86418-8-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Also cares the lruvec->pgdat syncing.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Peng Fan <peng.fan@nxp.com>
Cc: Nikolay Borisov <nborisov@suse.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/swap.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 63f4782af57a..2a8fe6df08fc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -63,12 +63,13 @@ static void __page_cache_release(struct page *page)
 		struct lruvec *lruvec;
 		unsigned long flags;
 
-		spin_lock_irqsave(&pgdat->lruvec.lru_lock, flags);
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
+		spin_lock_irqsave(&lruvec->lru_lock, flags);
+		sync_lruvec_pgdat(lruvec, pgdat);
 		VM_BUG_ON_PAGE(!PageLRU(page), page);
 		__ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
-		spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 	}
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
-- 
1.8.3.1


