Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DF02C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D77BE22CF9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D77BE22CF9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 749676B000E; Tue, 20 Aug 2019 05:49:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ADDB6B0010; Tue, 20 Aug 2019 05:49:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D8DE6B0269; Tue, 20 Aug 2019 05:49:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 27D406B000E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:41 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B7CC78419
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:40 +0000 (UTC)
X-FDA: 75842334120.26.stew41_5468ad16c0d47
X-HE-Tag: stew41_5468ad16c0d47
X-Filterd-Recvd-Size: 3689
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com [115.124.30.54])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:39 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=16;SR=0;TI=SMTPD_---0Ta-BP3A_1566294575;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta-BP3A_1566294575)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:36 +0800
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
Subject: [PATCH 09/14] lru/swap: uer per lruvec lock in pagevec_lru_move_fn
Date: Tue, 20 Aug 2019 17:48:32 +0800
Message-Id: <1566294517-86418-10-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

to replace pgdat lru_lock.

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
 mm/swap.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index d2dad08fcfd0..24a2b3456e10 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -192,26 +192,27 @@ static void pagevec_lru_move_fn(struct pagevec *pvec,
 	void *arg)
 {
 	int i;
-	struct pglist_data *pgdat = NULL;
-	struct lruvec *lruvec;
+	struct lruvec *locked_lruvec = NULL;
 	unsigned long flags = 0;
 
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
-		struct pglist_data *pagepgdat = page_pgdat(page);
-
-		if (pagepgdat != pgdat) {
-			if (pgdat)
-				spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
-			pgdat = pagepgdat;
-			spin_lock_irqsave(&pgdat->lruvec.lru_lock, flags);
+		struct pglist_data *pgdat = page_pgdat(page);
+		struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
+
+		if (locked_lruvec != lruvec) {
+			if (locked_lruvec)
+				spin_unlock_irqrestore(&locked_lruvec->lru_lock, flags);
+			locked_lruvec = lruvec;
+			spin_lock_irqsave(&lruvec->lru_lock, flags);
+			sync_lruvec_pgdat(lruvec, pgdat);
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		(*move_fn)(page, lruvec, arg);
 	}
-	if (pgdat)
-		spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
+	if (locked_lruvec)
+		spin_unlock_irqrestore(&locked_lruvec->lru_lock, flags);
+
 	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
-- 
1.8.3.1


