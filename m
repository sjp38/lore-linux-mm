Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC4D0C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B41822CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B41822CF7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3DFC6B026B; Tue, 20 Aug 2019 05:49:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC8326B026C; Tue, 20 Aug 2019 05:49:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A31B86B026D; Tue, 20 Aug 2019 05:49:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 740EB6B026B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:44 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F0516181AC9B6
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:43 +0000 (UTC)
X-FDA: 75842334246.23.drink96_54d1c83a68216
X-HE-Tag: drink96_54d1c83a68216
X-Filterd-Recvd-Size: 5313
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com [115.124.30.44])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:42 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TZztT4P_1566294573;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZztT4P_1566294573)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:34 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Qian Cai <cai@lca.pw>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 04/14] lru/compaction: use per lruvec lock in isolate_migratepages_block
Date: Tue, 20 Aug 2019 17:48:27 +0800
Message-Id: <1566294517-86418-5-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Using lruvec locking to replace pgdat lru_lock. and then unfold
compact_unlock_should_abort() to fit the replacement.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Qian Cai <cai@lca.pw>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/compaction.c | 48 ++++++++++++++++++++++++++++++------------------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9a737f343183..8877f38410d8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -785,7 +785,7 @@ static bool too_many_isolated(pg_data_t *pgdat)
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
-	bool locked = false;
+	struct lruvec *locked_lruvec = NULL;
 	struct page *page = NULL, *valid_page = NULL;
 	unsigned long start_pfn = low_pfn;
 	bool skip_on_failure = false;
@@ -845,11 +845,20 @@ static bool too_many_isolated(pg_data_t *pgdat)
 		 * contention, to give chance to IRQs. Abort completely if
 		 * a fatal signal is pending.
 		 */
-		if (!(low_pfn % SWAP_CLUSTER_MAX)
-		    && compact_unlock_should_abort(&pgdat->lruvec.lru_lock,
-					    flags, &locked, cc)) {
-			low_pfn = 0;
-			goto fatal_pending;
+		if (!(low_pfn % SWAP_CLUSTER_MAX)) {
+			if (locked_lruvec) {
+				spin_unlock_irqrestore(&locked_lruvec->lru_lock, flags);
+				locked_lruvec = NULL;
+			}
+
+			if (fatal_signal_pending(current)) {
+				cc->contended = true;
+
+				low_pfn = 0;
+				goto fatal_pending;
+			}
+
+			cond_resched();
 		}
 
 		if (!pfn_valid_within(low_pfn))
@@ -918,10 +927,10 @@ static bool too_many_isolated(pg_data_t *pgdat)
 			 */
 			if (unlikely(__PageMovable(page)) &&
 					!PageIsolated(page)) {
-				if (locked) {
-					spin_unlock_irqrestore(&pgdat->lruvec.lru_lock,
+				if (locked_lruvec) {
+					spin_unlock_irqrestore(&locked_lruvec->lru_lock,
 									flags);
-					locked = false;
+					locked_lruvec = NULL;
 				}
 
 				if (!isolate_movable_page(page, isolate_mode))
@@ -947,10 +956,14 @@ static bool too_many_isolated(pg_data_t *pgdat)
 		if (!(cc->gfp_mask & __GFP_FS) && page_mapping(page))
 			goto isolate_fail;
 
+		lruvec = mem_cgroup_page_lruvec(page, pgdat);
+
 		/* If we already hold the lock, we can skip some rechecking */
-		if (!locked) {
-			locked = compact_lock_irqsave(&pgdat->lruvec.lru_lock,
-								&flags, cc);
+		if (lruvec != locked_lruvec) {
+			if (compact_lock_irqsave(&lruvec->lru_lock, &flags, cc))
+				locked_lruvec = lruvec;
+
+			sync_lruvec_pgdat(lruvec, pgdat);
 
 			/* Try get exclusive access under lock */
 			if (!skip_updated) {
@@ -974,7 +987,6 @@ static bool too_many_isolated(pg_data_t *pgdat)
 			}
 		}
 
-		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, isolate_mode) != 0)
@@ -1015,9 +1027,9 @@ static bool too_many_isolated(pg_data_t *pgdat)
 		 * page anyway.
 		 */
 		if (nr_isolated) {
-			if (locked) {
-				spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
-				locked = false;
+			if (locked_lruvec) {
+				spin_unlock_irqrestore(&locked_lruvec->lru_lock, flags);
+				locked_lruvec = NULL;
 			}
 			putback_movable_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
@@ -1042,8 +1054,8 @@ static bool too_many_isolated(pg_data_t *pgdat)
 		low_pfn = end_pfn;
 
 isolate_abort:
-	if (locked)
-		spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
+	if (locked_lruvec)
+		spin_unlock_irqrestore(&locked_lruvec->lru_lock, flags);
 
 	/*
 	 * Updated the cached scanner pfn once the pageblock has been scanned
-- 
1.8.3.1


