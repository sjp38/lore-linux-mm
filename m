Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75AA1C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 112B522BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:50:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rE6HVhCn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 112B522BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68DD48E0077; Thu, 25 Jul 2019 09:50:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E4A8E0059; Thu, 25 Jul 2019 09:50:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E0528E0077; Thu, 25 Jul 2019 09:50:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14FB88E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:50:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so30934087pfk.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=cznC/mia673R12amLE2+NAuwJMmX8y7Trfs12IWdodY=;
        b=dTaV8hX6NQuMebUTYK4uyo4vAtWvGxNMn8b8ASgJ5wFfZNolud13vZoBKsPfeyGwos
         yba6f/dGq8zpLnNPtdAlChQYPIS8x6YW9zAqlnjcFtIaBICcDsXbHGRBE5fx9vuCbDvH
         Gbr+reiJi0qFcjlCAMduwwmyM2/dF2iljZuNnSTu394bim1+WF0eDx7sy8k9ULoLd8+C
         YlRMEWKu0LK7/Z0e9lV+kUYAefGHmT16sCGPuKXH4p5eXOQJlfQd25cYqRBoc8Pso2KK
         TpVl3E3B7D5fwg0av7/TINbvSvQXObC/4ikaIkyANb52f6cGrzCBawaYiOCYfdjctB46
         rmYw==
X-Gm-Message-State: APjAAAXwmYCGtO8OPjgcDVJZJ3Gy+n9bCYlVM1c9PJqFFbSrqPUmkzj1
	QEUgCiWLEarnf5LIBu0UO4TqpqZ322dFG/cY5D2H/Y03DrhEsmtoBET5nzMocSNJFyrm4kfaNOr
	oWRhQrbixzHJ4sJq+UlQJPbfeuZ8aCfmNNuTqek5FPic4ohIVfweJ294WNHqn+g0sgw==
X-Received: by 2002:a65:5cca:: with SMTP id b10mr88415079pgt.365.1564062637272;
        Thu, 25 Jul 2019 06:50:37 -0700 (PDT)
X-Received: by 2002:a65:5cca:: with SMTP id b10mr88415020pgt.365.1564062636410;
        Thu, 25 Jul 2019 06:50:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564062636; cv=none;
        d=google.com; s=arc-20160816;
        b=Bzz8yH4iNJCTjw1Q5yAXCt8Ik9dqlzGNEE7S2QqQx3omI/7qfxIKDOsJVgZocdlqP6
         uOe1Ziw7QUWzswUqPSRJr7XNyB5N8oiwVzlrcDdGKxctbR36nVRJKyqGlHeWVMUW701h
         rfqMKZUfpQaA+A+MuqiiNupQ8zoUVScKFs3at4sZxwndhRzuN/ZagEvmmkiE3kLos2ie
         2/y5hy9q4E+gGnbS54x85F8vjayIO0MxP4/bnpX07R7TmTIbz8GgeTc+X7C4kXFiM5eK
         2nkVuNtieJ3gjMHPWV6RVdgq07kPF7A+S7E+l6RpB0JIti0EEur3HJvN2hpN2npA+v5M
         t9Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=cznC/mia673R12amLE2+NAuwJMmX8y7Trfs12IWdodY=;
        b=xmHUkH8FfnZbs1ZtrUbZBvdK9+mR+KyEulSsb6fbCGJzfbJFqRWeC+ZE41ctcnNN/8
         jkQm73j/aysmSrtVJfS8sHtbmG9L4GRny2rE0VZrJvjJE73SGMcBUhiIb+K486QDjrdz
         WQYjP9unOinN6BuikstDjZxNjaFTnhDjDBc8XYnObw368gXyF/BIXW8z2CQF25YKOXXF
         zlxHNoMT5h5rhfzeVb0kZZnJpF1sP8Gq1XQS6fNP2w+jZtkZAtjvMPFUs4qyJFfiiufN
         /uxh0DpXtFsQRlHKcXhWnwTupLEgFcNCpk95/F1lr1eXNaau+IcUja2kAEh6mwdwncB4
         mOTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rE6HVhCn;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor28846709pgq.25.2019.07.25.06.50.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 06:50:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rE6HVhCn;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=cznC/mia673R12amLE2+NAuwJMmX8y7Trfs12IWdodY=;
        b=rE6HVhCnyS9Fuh8XBydCT0JNwye99wS2LnV3haS5VXjGpKpKIuckW7pCDHtEQr6aW4
         E12yP+AFQBAbmC6NjqFVvZTTsMJUq++VbJorRpr0od2oDmUA2sR/MpMVQ5y5EVh+d+fC
         mdCKkr+a0vIC+/h3u9eHMOY+uumKZJfVxZPLBMUrB50wnT0Vpp3XiYn4g0+k79L9qrgX
         BvHH7owqZoTrODqPDVwvaP+dQvsT0DeTYpdkSnC9dRVdaUfbqhwotfGBTvobTIBFEA2A
         GGlIJyfON3rQRQnGhYV6Ev/hN7VT6OGN10ORo4dIfMATMk/WSYcA+3wU+wVpQkgY8XdZ
         XofQ==
X-Google-Smtp-Source: APXvYqx95YTBmfZ2s6irx5QGcKsLYJHHj7SGgLLi4873958KHGS6URkSeVG3+hvXtd1vwQtAjj6vUw==
X-Received: by 2002:a65:5202:: with SMTP id o2mr63140175pgp.29.1564062635792;
        Thu, 25 Jul 2019 06:50:35 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id p65sm49350879pfp.58.2019.07.25.06.50.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 06:50:35 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Arnd Bergmann <arnd@arndb.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Rik van Riel <riel@redhat.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm/compaction: use proper zoneid for compaction_suitable()
Date: Thu, 25 Jul 2019 09:50:21 -0400
Message-Id: <1564062621-8105-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By now there're three compaction paths,
- direct compaction
- kcompactd compcation
- proc triggered compaction
When we do compaction in all these paths, we will use compaction_suitable()
to check whether a zone is suitable to do compaction.

There're some issues around the usage of compaction_suitable().
We don't use the proper zoneid in kcompactd_node_suitable() when try to
wakeup kcompactd. In the kcompactd compaction paths, we call
compaction_suitable() twice and the zoneid isn't proper in the second call.
For proc triggered compaction, the classzone_idx is always zero.

In order to fix these issues, I change the type of classzone_idx in the
struct compact_control from const int to int and assign the proper zoneid
before calling compact_zone().

This patch also fixes some comments in struct compact_control, as these
fields are not only for direct compactor but also for all other compactors.

Fixes: ebff398017c6("mm, compaction: pass classzone_idx and alloc_flags to watermark checking")
Fixes: 698b1b30642f("mm, compaction: introduce kcompactd")
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/compaction.c | 12 +++++-------
 mm/internal.h   | 10 +++++-----
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ac4ead0..984dea7 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2425,6 +2425,7 @@ static void compact_node(int nid)
 			continue;
 
 		cc.zone = zone;
+		cc.classzone_idx = zoneid;
 
 		compact_zone(&cc, NULL);
 
@@ -2508,7 +2509,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 			continue;
 
 		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
-					classzone_idx) == COMPACT_CONTINUE)
+					zoneid) == COMPACT_CONTINUE)
 			return true;
 	}
 
@@ -2526,7 +2527,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
 		.search_order = pgdat->kcompactd_max_order,
-		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = false,
 		.gfp_mask = GFP_KERNEL,
@@ -2535,7 +2535,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 							cc.classzone_idx);
 	count_compact_event(KCOMPACTD_WAKE);
 
-	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
+	for (zoneid = 0; zoneid <= pgdat->kcompactd_classzone_idx; zoneid++) {
 		int status;
 
 		zone = &pgdat->node_zones[zoneid];
@@ -2545,14 +2545,12 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (compaction_deferred(zone, cc.order))
 			continue;
 
-		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
-							COMPACT_CONTINUE)
-			continue;
-
 		if (kthread_should_stop())
 			return;
 
 		cc.zone = zone;
+		cc.classzone_idx = zoneid;
+
 		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
diff --git a/mm/internal.h b/mm/internal.h
index 0d5f720..c224a16 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -190,11 +190,11 @@ struct compact_control {
 	unsigned long total_free_scanned;
 	unsigned short fast_search_fail;/* failures to use free list searches */
 	short search_order;		/* order to start a fast search at */
-	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
-	int order;			/* order a direct compactor needs */
-	int migratetype;		/* migratetype of direct compactor */
-	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
-	const int classzone_idx;	/* zone index of a direct compactor */
+	const gfp_t gfp_mask;		/* gfp mask of a compactor */
+	int order;			/* order a compactor needs */
+	int migratetype;		/* migratetype of a compactor */
+	const unsigned int alloc_flags;	/* alloc flags of a compactor */
+	int classzone_idx;		/* zone index of a compactor */
 	enum migrate_mode mode;		/* Async or sync migration mode */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	bool no_set_skip_hint;		/* Don't mark blocks for skipping */
-- 
1.8.3.1

