Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38443C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EED6223401
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="zzXt8J7r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EED6223401
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 986BB6B000D; Wed,  4 Sep 2019 09:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C2956B000E; Wed,  4 Sep 2019 09:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787CD6B0010; Wed,  4 Sep 2019 09:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0108.hostedemail.com [216.40.44.108])
	by kanga.kvack.org (Postfix) with ESMTP id 584FF6B000D
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:25 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id CC78E181AC9BF
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:24 +0000 (UTC)
X-FDA: 75897380328.26.basin78_1db8fde86bf41
X-HE-Tag: basin78_1db8fde86bf41
X-Filterd-Recvd-Size: 4633
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net [77.88.29.217])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:24 +0000 (UTC)
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 5988D2E1609;
	Wed,  4 Sep 2019 16:53:21 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id TNGVWv96P7-rLBaIhm4;
	Wed, 04 Sep 2019 16:53:21 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605201; bh=93aHSjkq8usOa7Vvzbeiada0aVjHgSRCpmsa9gKiW1o=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=zzXt8J7rWoER/p7/CTRZyY4XofxSlIu8HZMnkuI26LqBHm9vtziabp5zDNkU+/nSK
	 c/l/B6DrJA6UYOrifB6EdGmZDmJyTT+rS7G3KaxXLzZmYHhAaqT25Kfy50FMFKtzw8
	 fbSc9u6sHHHBL9pFhN7EpNgbMXo4W4Y/SDtZW4X4=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id LsxziF0vbN-rKD0umIh;
	Wed, 04 Sep 2019 16:53:20 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 6/7] mm/vmscan: allow changing page memory cgroup during
 reclaim
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:20 +0300
Message-ID: <156760520035.6560.17483443614564028347.stgit@buzz>
In-Reply-To: <156760509382.6560.17364256340940314860.stgit@buzz>
References: <156760509382.6560.17364256340940314860.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All LRU lists in one numa node are protected with one spin-lock and
right now move_pages_to_lru() re-evaluates lruvec for each page.
This allows to change page cgroup while page is isolated by reclaimer,
but nobody use that for now. This patch makes this feature clear and
passes into move_pages_to_lru pgdat rather than lruvec pointer.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmscan.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6c5d0b28321..bf7a05e8a717 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1873,15 +1873,15 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
  * The downside is that we have to touch page->_refcount against each page.
  * But we had to alter page->flags anyway.
  *
- * Returns the number of pages moved to the given lruvec.
+ * Returns the number of pages moved to LRU lists.
  */
 
-static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
+static unsigned noinline_for_stack move_pages_to_lru(struct pglist_data *pgdat,
 						     struct list_head *list)
 {
-	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	int nr_pages, nr_moved = 0;
 	LIST_HEAD(pages_to_free);
+	struct lruvec *lruvec;
 	struct page *page;
 	enum lru_list lru;
 
@@ -1895,6 +1895,8 @@ static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
 			spin_lock_irq(&pgdat->lru_lock);
 			continue;
 		}
+
+		/* Re-evaluate lru: isolated page could be moved */
 		lruvec = mem_cgroup_page_lruvec(page, pgdat);
 
 		SetPageLRU(page);
@@ -2005,7 +2007,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
 	reclaim_stat->recent_rotated[1] += stat.nr_activate[1];
 
-	move_pages_to_lru(lruvec, &page_list);
+	move_pages_to_lru(pgdat, &page_list);
 
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 
@@ -2128,8 +2130,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	nr_activate = move_pages_to_lru(lruvec, &l_active);
-	nr_deactivate = move_pages_to_lru(lruvec, &l_inactive);
+	nr_activate = move_pages_to_lru(pgdat, &l_active);
+	nr_deactivate = move_pages_to_lru(pgdat, &l_inactive);
 	/* Keep all free pages in l_active list */
 	list_splice(&l_inactive, &l_active);
 


