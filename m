Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABD26C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A7A322DA7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:50:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A7A322DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1556E6B026C; Tue, 20 Aug 2019 05:49:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E1FF6B0270; Tue, 20 Aug 2019 05:49:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7B1E6B026C; Tue, 20 Aug 2019 05:49:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6A96B026C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:45 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 217C5180AD809
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:45 +0000 (UTC)
X-FDA: 75842334330.15.shock76_54fe6ab4ad02d
X-HE-Tag: shock76_54fe6ab4ad02d
X-Filterd-Recvd-Size: 5797
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:43 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TZztT4i_1566294574;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZztT4i_1566294574)
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
	Michal Hocko <mhocko@suse.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	swkhack <swkhack@gmail.com>,
	"Potyra, Stefan" <Stefan.Potyra@elektrobit.com>
Subject: [PATCH 06/14] lru/mlock: using per lruvec lock in munlock
Date: Tue, 20 Aug 2019 17:48:29 +0800
Message-Id: <1566294517-86418-7-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch using sperate lruvec lock for each of pages in
__munlock_pagevec().

Also this patch pass a lruvec in __munlock_isolate_lru_page() as
parameter to reduce a repeat lruvec locating.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: swkhack <swkhack@gmail.com>
Cc: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/mlock.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 1279684bada0..9915968d490a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -106,12 +106,10 @@ void mlock_vma_page(struct page *page)
  * Isolate a page from LRU with optional get_page() pin.
  * Assumes lru_lock already held and page already pinned.
  */
-static bool __munlock_isolate_lru_page(struct page *page, bool getpage)
+static bool __munlock_isolate_lru_page(struct page *page,
+			struct lruvec *lruvec, bool getpage)
 {
 	if (PageLRU(page)) {
-		struct lruvec *lruvec;
-
-		lruvec = mem_cgroup_page_lruvec(page, page_pgdat(page));
 		if (getpage)
 			get_page(page);
 		ClearPageLRU(page);
@@ -183,6 +181,9 @@ unsigned int munlock_vma_page(struct page *page)
 {
 	int nr_pages;
 	pg_data_t *pgdat = page_pgdat(page);
+	struct lruvec *lruvec;
+
+	lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 	/* For try_to_munlock() and to serialize with page migration */
 	BUG_ON(!PageLocked(page));
@@ -194,7 +195,8 @@ unsigned int munlock_vma_page(struct page *page)
 	 * might otherwise copy PageMlocked to part of the tail pages before
 	 * we clear it in the head page. It also stabilizes hpage_nr_pages().
 	 */
-	spin_lock_irq(&pgdat->lruvec.lru_lock);
+	spin_lock_irq(&lruvec->lru_lock);
+	sync_lruvec_pgdat(lruvec, pgdat);
 
 	if (!TestClearPageMlocked(page)) {
 		/* Potentially, PTE-mapped THP: do not skip the rest PTEs */
@@ -205,15 +207,15 @@ unsigned int munlock_vma_page(struct page *page)
 	nr_pages = hpage_nr_pages(page);
 	__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 
-	if (__munlock_isolate_lru_page(page, true)) {
-		spin_unlock_irq(&pgdat->lruvec.lru_lock);
+	if (__munlock_isolate_lru_page(page, lruvec, true)) {
+		spin_unlock_irq(&lruvec->lru_lock);
 		__munlock_isolated_page(page);
 		goto out;
 	}
 	__munlock_isolation_failed(page);
 
 unlock_out:
-	spin_unlock_irq(&pgdat->lruvec.lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 
 out:
 	return nr_pages - 1;
@@ -291,28 +293,30 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
 	int i;
 	int nr = pagevec_count(pvec);
-	int delta_munlocked = -nr;
 	struct pagevec pvec_putback;
 	int pgrescued = 0;
 
 	pagevec_init(&pvec_putback);
 
 	/* Phase 1: page isolation */
-	spin_lock_irq(&zone->zone_pgdat->lruvec.lru_lock);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pvec->pages[i];
+		pg_data_t *pgdat = page_pgdat(page);
+		struct lruvec *lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
+		spin_lock_irq(&lruvec->lru_lock);
+		sync_lruvec_pgdat(lruvec, pgdat);
 		if (TestClearPageMlocked(page)) {
 			/*
 			 * We already have pin from follow_page_mask()
 			 * so we can spare the get_page() here.
 			 */
-			if (__munlock_isolate_lru_page(page, false))
+			if (__munlock_isolate_lru_page(page, lruvec, false)) {
+				__mod_zone_page_state(zone, NR_MLOCK,  -1);
+				spin_unlock_irq(&lruvec->lru_lock);
 				continue;
-			else
+			} else
 				__munlock_isolation_failed(page);
-		} else {
-			delta_munlocked++;
 		}
 
 		/*
@@ -323,9 +327,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		 */
 		pagevec_add(&pvec_putback, pvec->pages[i]);
 		pvec->pages[i] = NULL;
+		spin_unlock_irq(&lruvec->lru_lock);
 	}
-	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
-	spin_unlock_irq(&zone->zone_pgdat->lruvec.lru_lock);
 
 	/* Now we can release pins of pages that we are not munlocking */
 	pagevec_release(&pvec_putback);
-- 
1.8.3.1


