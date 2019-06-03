Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED407C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAC2824726
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="E5wKX75L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAC2824726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B09826B0278; Mon,  3 Jun 2019 17:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A422B6B0279; Mon,  3 Jun 2019 17:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDA36B027A; Mon,  3 Jun 2019 17:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 512F36B0278
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s4so13405280pfh.14
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uM4S4y/Y5SrPdENg0QBPLDuc00s8nib+/ajfOkcZMik=;
        b=ieCPocYJ+uTSsQOHzqZ52kIKbuz+6nFnrUs28VD2AHEadJOjR/BBu//RQdFAlmbdDV
         ez6MXCdfwdfosMAXV/iBrkeTfwdFzeAZ2l+ls67mddW993didFcUdAaOMr2pbf2EP/ct
         d7JB8NkaUOTjo6jb8OFVCGFdPSeB6O5OkrsZKgyU7UOIdk0BGZquY1euc3UR7LtqcCQv
         WVZyfUsxvwM49Jiwnnm9jrz61gBJOfhWf96jJAA57XdQp4lf47zOnEh2/kgi8BEnh68B
         SjqsiKSwK+XHPM+dDUf1i3Bh/SN/iztQJWwlzNaoAtF1u55TWcHMLyKW0R0uEvBpOsO2
         03ew==
X-Gm-Message-State: APjAAAUrNxBAXLLnZhRxAck2KYNQq8719QkgOhzzNppELQUrwSf3HaCg
	iSSw44ajOCO9H6evZ7XhIfYveuwthmXLhmKs341xgErH9y6y91d1fVxJhegwRkb2zpW9brVAVIr
	A8mawZ6bIcuJBZoWHq5ibRS6dceaxT0RB8fkFGHowpK0fE86TSiHSKaJbNAHQjkG2MQ==
X-Received: by 2002:aa7:8c0f:: with SMTP id c15mr7679189pfd.113.1559596123848;
        Mon, 03 Jun 2019 14:08:43 -0700 (PDT)
X-Received: by 2002:aa7:8c0f:: with SMTP id c15mr7679073pfd.113.1559596122780;
        Mon, 03 Jun 2019 14:08:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596122; cv=none;
        d=google.com; s=arc-20160816;
        b=BJEmDh5s4lLxUMlZOW9qRf0hAkQoyud0R86gXDegMylxialJS+rvJVZFkKJ5wYd/SX
         CL/G6GOnO74/Yzls7TMxW4OV8s5YA5dPQulwpjJDPjRcegzd5MJ6PTKcEpjC/7t1x/gU
         +aJdsPVK4PHp4xtCi7yXIgNj4AUz2v4AsBUUyS1hh4TUsbXqBahwOgBcX7HbJiIUthEm
         dma8AASGgeeQSULKptKvcni4sTCcuPXdUVKmEQHU3mE6qRuzGa8T0XTPSnmSfwCVTkL/
         kR4+gZ0pfTcpxSHqaCnH7DRjQvL5M6y1RwD4HCm9pgfxfLG7P+6fMcQ+r66KIDI6Ly9f
         hSlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uM4S4y/Y5SrPdENg0QBPLDuc00s8nib+/ajfOkcZMik=;
        b=ouRdDk6B3h245/IZXW5FpS4c6HG7aHIvTBO4fqoJk8/aN0x8NP3OJL37EpBpaaHbrO
         9TgKv13ZSHpwZTYon+DlFbjtUUpzV2+H1ZczdUxWPFw1L4ygypgxqFHWIt5VfKnqs1io
         jtS2HlYboen2+Dmw7fjRQ6I9UJN/8gkxnC1mPD9pFctebVgLRiShbZWr0Mjinycya8Ie
         /1fXLNm58HtIlAaD8Rc7dzqWkRHuGvZ0y1hkVb3clTiWrT7bmRNpc3F410oKzT+TPDxp
         Uqy4aeSjog2LcU4cJNXawQBXtsfDWz4ljU4GBPgZrKazsUKDrmvQTA9XquOYwVu1GH6a
         8bpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=E5wKX75L;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22sor15969333pfm.18.2019.06.03.14.08.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=E5wKX75L;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uM4S4y/Y5SrPdENg0QBPLDuc00s8nib+/ajfOkcZMik=;
        b=E5wKX75LYj21K7r3b5uPvJHFB3a+wonjs7ZsPnT7rqWS2Jj94E45SuqIpvC70AjZgc
         JIPqfhBiJe5qxRDHnW0a11OgkMQCZGxN/JgMiMb2uO+dp8dsS4hv+h8pIvllW6xzlqex
         2ajtI1YvJTzHyOEvFyG0WZ424MseQjErWrB1aHCv6+yd8mrPV/JSYvxp5kyasLqQo2Pf
         RCFBx4MsTkG80s0S4efJn9Fsp/kMF8ETw52Oxn7dHom+bNsgFQe2Z7qz52Aj2oZ8A3IN
         cQzPnohrFrwqFS/0osPnM8G9h7NO7drtGI+CLw2kKPFUoAAEjC2xRAV9cMROAgznBSCR
         4Dhg==
X-Google-Smtp-Source: APXvYqwbMD8TVz0HqZSC+oHhO3LjocjnT1Uw0hT+H5KZ3//8wtU6n995qzN2B8+Dl5CLBrRD1SHU2A==
X-Received: by 2002:a63:c106:: with SMTP id w6mr21948229pgf.422.1559596122497;
        Mon, 03 Jun 2019 14:08:42 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id t25sm11786407pgv.30.2019.06.03.14.08.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:41 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 09/11] mm: vmscan: move file exhaustion detection to the node level
Date: Mon,  3 Jun 2019 17:07:44 -0400
Message-Id: <20190603210746.15800-10-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603210746.15800-1-hannes@cmpxchg.org>
References: <20190603210746.15800-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When file pages are lower than the watermark on a node, we try to
force scan anonymous pages to counter-act the balancing algorithms
preference for new file pages when they are likely thrashing. This is
node-level decision, but it's currently made each time we look at an
lruvec. This is unnecessarily expensive and also a layering violation
that makes the code harder to understand.

Clean this up by making the check once per node and setting a flag in
the scan_control.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 80 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 42 insertions(+), 38 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eb535c572733..cabf94dfa92d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -104,6 +104,9 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	/* The file pages on the current node are dangerously low */
+	unsigned int file_is_tiny:1;
+
 	/* Allocation order */
 	s8 order;
 
@@ -2219,45 +2222,16 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	}
 
 	/*
-	 * Prevent the reclaimer from falling into the cache trap: as
-	 * cache pages start out inactive, every cache fault will tip
-	 * the scan balance towards the file LRU.  And as the file LRU
-	 * shrinks, so does the window for rotation from references.
-	 * This means we have a runaway feedback loop where a tiny
-	 * thrashing file LRU becomes infinitely more attractive than
-	 * anon pages.  Try to detect this based on file LRU size.
+	 * If the system is almost out of file pages, force-scan anon.
+	 * But only if there are enough inactive anonymous pages on
+	 * the LRU. Otherwise, the small LRU gets thrashed.
 	 */
-	if (!cgroup_reclaim(sc)) {
-		unsigned long pgdatfile;
-		unsigned long pgdatfree;
-		int z;
-		unsigned long total_high_wmark = 0;
-
-		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
-		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
-			   node_page_state(pgdat, NR_INACTIVE_FILE);
-
-		for (z = 0; z < MAX_NR_ZONES; z++) {
-			struct zone *zone = &pgdat->node_zones[z];
-			if (!managed_zone(zone))
-				continue;
-
-			total_high_wmark += high_wmark_pages(zone);
-		}
-
-		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
-			/*
-			 * Force SCAN_ANON if there are enough inactive
-			 * anonymous pages on the LRU in eligible zones.
-			 * Otherwise, the small LRU gets thrashed.
-			 */
-			if (!inactive_list_is_low(lruvec, false, sc, false) &&
-			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
-					>> sc->priority) {
-				scan_balance = SCAN_ANON;
-				goto out;
-			}
-		}
+	if (sc->file_is_tiny &&
+	    !inactive_list_is_low(lruvec, false, sc, false) &&
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON,
+			    sc->reclaim_idx) >> sc->priority) {
+		scan_balance = SCAN_ANON;
+		goto out;
 	}
 
 	/*
@@ -2718,6 +2692,36 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	nr_reclaimed = sc->nr_reclaimed;
 	nr_scanned = sc->nr_scanned;
 
+	/*
+	 * Prevent the reclaimer from falling into the cache trap: as
+	 * cache pages start out inactive, every cache fault will tip
+	 * the scan balance towards the file LRU.  And as the file LRU
+	 * shrinks, so does the window for rotation from references.
+	 * This means we have a runaway feedback loop where a tiny
+	 * thrashing file LRU becomes infinitely more attractive than
+	 * anon pages.  Try to detect this based on file LRU size.
+	 */
+	if (!cgroup_reclaim(sc)) {
+		unsigned long file;
+		unsigned long free;
+		int z;
+		unsigned long total_high_wmark = 0;
+
+		free = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
+		file = node_page_state(pgdat, NR_ACTIVE_FILE) +
+			   node_page_state(pgdat, NR_INACTIVE_FILE);
+
+		for (z = 0; z < MAX_NR_ZONES; z++) {
+			struct zone *zone = &pgdat->node_zones[z];
+			if (!managed_zone(zone))
+				continue;
+
+			total_high_wmark += high_wmark_pages(zone);
+		}
+
+		sc->file_is_tiny = file + free <= total_high_wmark;
+	}
+
 	shrink_node_memcgs(pgdat, sc);
 
 	if (reclaim_state) {
-- 
2.21.0

