Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E61C1C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7743720700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7743720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3AB58E0121; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC5EA8E0108; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD86B8E0120; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7479A8E0108
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id g17so566430lfh.19
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:43:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=npWLHy5QXMb4vE/qvQv7Q6UWWDaG70gQpg05ucqiQ+w=;
        b=pxvtBtVAfrV2wUz5A7YZYN+9qUnckZVSRvSy+QXNXm25Mp1mht+glTIhYSXJv9rXFa
         EYu5fBdYeDHgcNRxjb4/NIvMtpoRclyZgjcTeCdqwMiq9avGh/e5SRCQCF/UA1Be66F9
         PV1jX4QbWood/1/SsDQeupjZ4YLCUNYeMGGbpM9G0IdXvbEitszt9vPCEFt/zvjOPLaD
         W85iAC4NVURhFdQwymvOSgzjf9SYoe9UFV2fUnNk3riwtYMwEQAhRR1El8qHfryvUWu2
         NIOCVsUrU77LLIz8dnJzwrpZ6mnEnDwGfmsnsWMFrOpKrgVYn23eF34qoWoq2YD5Qy5U
         KxXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAublqTcay6ZomQriPgGBo+A+1PbY4CJ9+nY+HjrK+aYuzq6BP9Mp
	cc5pq8BU7c8OnMCSavl3v3uqqGyHHWcayVvWF+ukF3oeB+8uDEpP6QHA3Lg5t107aYVnGxR5jc7
	UVydw5i8aSMI/7emJfPtOOybFnowbcm7kjxWAOKer5OyviD6b6v1y2tZKrjmfrJ1LPA==
X-Received: by 2002:a19:7507:: with SMTP id y7mr3368573lfe.140.1550857406657;
        Fri, 22 Feb 2019 09:43:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYz1kbH+cjXTEZOecSkdDW7bH+1Hjd7KClIh68j3rEATdcuwi6/M3c8djdF308jH/0Pqvm5
X-Received: by 2002:a19:7507:: with SMTP id y7mr3368521lfe.140.1550857405558;
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550857405; cv=none;
        d=google.com; s=arc-20160816;
        b=icjCi2ff91Ogohkc5aqRgUvo+1J3XLp4nF+4Tf4nK8xyfE8+WTkPCopEQ3Pc/EO4zg
         tiYPpyKRgiMwcB52xCVocDuTNuI6ll3uXD88oK3pWc13Hfgdf7oEDGxiT33OtOyr5+io
         3yujAVCDYFxiS91IILsognUurPei68eqAEKE9HjHhvTKuOQe7cFrael+YPvgfGFuVTeb
         WtbTlYVesj5zDBmLCPx1u8zJNUqcgkwtNCRRbkJ49FqKbIGIAv2SHlax63Y1EwC6VkEg
         /dnmEr3VfP8Pi+nXbd8PLGmmbkW53D2fzIv1te0pCWjz8N1xafaNR6HDuorxmF5oyIvq
         U4tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=npWLHy5QXMb4vE/qvQv7Q6UWWDaG70gQpg05ucqiQ+w=;
        b=B0AeH0Q5ULEstH2M8zwR7VXvEa578LfQH0wunoTwMVf9ZEaiAPVqcm7oACu54JGBqR
         GPQp01O3mXphwxIOn8wcyAYdsLBbiRmXD23ZQjI8HYhK5v+G6ItxdAKnj8BLCZrfkpji
         uj4a0KQhKMv3nQZj4nwdZQHImiqzu9gfgrCM0gC0xW3uvfVXDoF2KRW9AJx9x16tfX5c
         rA3tAOEKNrBxcbXihnS0V+UPSMZGSIYW7ZCXqsq3uaObuCaD83Q5xy3XelbkuLgxYTYe
         4t7AvhvyOZqSHPhNk3x3tCeOLPp72BULEiU15qwY6LTbmfOnhHRW98jowKMPyxnb8WOk
         LNNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t5si1627833lft.124.2019.02.22.09.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gxEr3-00010r-Bv; Fri, 22 Feb 2019 20:43:21 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/5] mm/compaction: pass pgdat to too_many_isolated() instead of zone
Date: Fri, 22 Feb 2019 20:43:35 +0300
Message-Id: <20190222174337.26390-3-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20190222174337.26390-1-aryabinin@virtuozzo.com>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

too_many_isolated() in mm/compaction.c looks only at node state,
so it makes more sense to change argument to pgdat instead of zone.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a3305f13a138..b2d02aba41d8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -738,16 +738,16 @@ isolate_freepages_range(struct compact_control *cc,
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
-static bool too_many_isolated(struct zone *zone)
+static bool too_many_isolated(pg_data_t *pgdat)
 {
 	unsigned long active, inactive, isolated;
 
-	inactive = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
-			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
-	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
-			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
-	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
-			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
+	inactive = node_page_state(pgdat, NR_INACTIVE_FILE) +
+			node_page_state(pgdat, NR_INACTIVE_ANON);
+	active = node_page_state(pgdat, NR_ACTIVE_FILE) +
+			node_page_state(pgdat, NR_ACTIVE_ANON);
+	isolated = node_page_state(pgdat, NR_ISOLATED_FILE) +
+			node_page_state(pgdat, NR_ISOLATED_ANON);
 
 	return isolated > (inactive + active) / 2;
 }
@@ -774,8 +774,7 @@ static unsigned long
 isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 			unsigned long end_pfn, isolate_mode_t isolate_mode)
 {
-	struct zone *zone = cc->zone;
-	pg_data_t *pgdat = zone->zone_pgdat;
+	pg_data_t *pgdat = cc->zone->zone_pgdat;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
@@ -791,7 +790,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	 * list by either parallel reclaimers or compaction. If there are,
 	 * delay for some time until fewer pages are isolated
 	 */
-	while (unlikely(too_many_isolated(zone))) {
+	while (unlikely(too_many_isolated(pgdat))) {
 		/* async migration should just abort */
 		if (cc->mode == MIGRATE_ASYNC)
 			return 0;
-- 
2.19.2

