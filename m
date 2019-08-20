Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97828C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6693622CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6693622CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85C6A6B0010; Tue, 20 Aug 2019 05:49:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E69D6B0269; Tue, 20 Aug 2019 05:49:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6385C6B026A; Tue, 20 Aug 2019 05:49:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB226B0010
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:42 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D06C08419
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:41 +0000 (UTC)
X-FDA: 75842334162.08.able95_548b0b7aaf123
X-HE-Tag: able95_548b0b7aaf123
X-Filterd-Recvd-Size: 3363
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com [115.124.30.54])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:40 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0Ta-6uif_1566294573;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta-6uif_1566294573)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:33 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: [PATCH 03/14] lru/memcg: using per lruvec lock in un/lock_page_lru
Date: Tue, 20 Aug 2019 17:48:26 +0800
Message-Id: <1566294517-86418-4-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we repeatly assign the lruvec->pgdat in memcg. Will remove the
assignment in lruvec getting function after very points are protected.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memcontrol.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e8a1b0d95ba8..19fd911e8098 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2550,12 +2550,12 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 static void lock_page_lru(struct page *page, int *isolated)
 {
 	pg_data_t *pgdat = page_pgdat(page);
+	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
-	spin_lock_irq(&pgdat->lruvec.lru_lock);
+	spin_lock_irq(&lruvec->lru_lock);
+	sync_lruvec_pgdat(lruvec, pgdat);
 	if (PageLRU(page)) {
-		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		ClearPageLRU(page);
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 		*isolated = 1;
@@ -2566,16 +2566,14 @@ static void lock_page_lru(struct page *page, int *isolated)
 static void unlock_page_lru(struct page *page, int isolated)
 {
 	pg_data_t *pgdat = page_pgdat(page);
+	struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 	if (isolated) {
-		struct lruvec *lruvec;
-
-		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		SetPageLRU(page);
 		add_page_to_lru_list(page, lruvec, page_lru(page));
 	}
-	spin_unlock_irq(&pgdat->lruvec.lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 }
 
 static void commit_charge(struct page *page, struct mem_cgroup *memcg,
-- 
1.8.3.1


