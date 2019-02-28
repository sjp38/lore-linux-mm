Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A061EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F01218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F01218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AEA18E0004; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 061138E0001; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB6528E0004; Thu, 28 Feb 2019 03:35:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80D468E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:48 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id n193so3720589lfb.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:35:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hmvEGKOKplAnFBosu5bUrD8YZOJIDz6WNkKWVzUdHeU=;
        b=ZEWRE/NE4ofPi5zg/VYC5jnz42btPL8JacN210K7hNcPlF3jm9zagGlnrrUGwIXhpS
         fZaGhbtwso2cPcKzQJPxRH+Rr+slQMreKkAJYJpAxAJaLaZKqUy0cIsrCc1k9IVsx2+u
         as8gco8GbVvP0al/gi9JW5kKya5P+vwwEWR9bYLoj3y+HlQhA+0D03fyV2TBa+k+VqoG
         3Ah22NaK3bBMaS6rd2hYoWzIucHwTVe/aZ/oyBw5axVHIYcfROHhEYZPx/fbccr9Y6ns
         Bk4rClIH35mYzOrpSHEauds4v8PNdElkirZgMAOBB2u23CEf9CJLB/FhUnt4XEZR1fck
         SAcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVAO3m8mpBtLNRUD5GZ4f2bPfEa8UqF+5Us3vHFIGFujVjl+QFD
	KCAHZgHlnNpGldx51w/3OE0wydTf1zPGvzrR5pFK5Q6RRpmRZhkFLuiuMM5FfQTnWtVbcHT4DJL
	ntIM4Sl3euAWVAjkjv3jsq01mSXsYb8bUIgoLp6g7Fj6skexir5uHXpwAcKnf6W3JeQ==
X-Received: by 2002:a2e:6c09:: with SMTP id h9mr3974362ljc.139.1551342947675;
        Thu, 28 Feb 2019 00:35:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqwJAQ2+C3MYPhwEukhYCrGqq3NYoaiHiM5U4L48yTNC7WFBybQASly+rZGqv0RuO378kYuh
X-Received: by 2002:a2e:6c09:: with SMTP id h9mr3974304ljc.139.1551342946328;
        Thu, 28 Feb 2019 00:35:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342946; cv=none;
        d=google.com; s=arc-20160816;
        b=yZ+KXf9eycP5QzB5VuLv5VI9sfiKt8Ql/PQxAPVMnMPMsC6H/leaQrumEJHnADDCav
         rrRcVcr7OEgwYWv6NDk6lVK4TOc1D/7szxjIIWJjCbRI90rcWOP9sUghrJvkixhRBPyN
         l0G84VzjcUgopJwV+zlt98U/VqklgVf6DSski9zLi8PQqnFSOCfKbXZvywyQrQSPnOL3
         9NDsS5/Wy3uyE5hWc6pE9kK/jRWRKYDZV3rGGAXTmQJTGR350hEn6tDrU0wxC5q3tiOg
         i4KXL7BoUPyUxMoOuF3CKJRL6VgO+tPFgaFlG/XhAlUljFngehzvCAVnCjCp3A/dYVpN
         S6yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=hmvEGKOKplAnFBosu5bUrD8YZOJIDz6WNkKWVzUdHeU=;
        b=J+UfBDJ9jK/SCxawPN6A/GVKnxe0rYUb/a68sPSmRgL8cVE5zUoYCvF//U1sgicJF4
         pg9bYWs5dgwuibM+HVgvJKaD73HuaZUveKxrPuEnD8/NKkS52rvyxcZ68kXGRNMPN/oC
         TUkmymE2kBGc4Knygb5PPgHcchZ6TaSXgJC0xA2wBQCevmC9XwMzvdNKADS+4TpNWVkY
         fdJwU3WOgcGrvAVWnq2BCqIcP2h5JpT4ZBcLRXQOmbGWi1evm5CoNLzqd8k7QoCAD6Eb
         Pa/cYADeWd7sjI72K5pVshzB7UxoOOrLrDkePTtoc+h/1PvceR3o34YnVaVCFuvTqs6D
         xGKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t13si8619841lji.181.2019.02.28.00.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:35:46 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzHAK-0008R2-6M; Thu, 28 Feb 2019 11:35:40 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH v2 3/4] mm/compaction: pass pgdat to too_many_isolated() instead of zone
Date: Thu, 28 Feb 2019 11:33:28 +0300
Message-Id: <20190228083329.31892-3-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20190228083329.31892-1-aryabinin@virtuozzo.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Rik van Riel <riel@surriel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
---

Changes since v1:
 - Added acks

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

