Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F02C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2427241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="bc7TrWgT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2427241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931816B0273; Mon,  3 Jun 2019 17:08:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8949F6B0274; Mon,  3 Jun 2019 17:08:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA9B6B0276; Mon,  3 Jun 2019 17:08:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21E946B0273
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:36 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a13so5375050pgw.19
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xjW+KHnHD//MqYRxY0A82usCY+qgrBu78W4ErXk80GU=;
        b=QlIUEm8I8cLfh6w8Xr1nNnW2FAziXTLpznapT8OFCjr1Ri9gJZubY90FZG3KCqJyQA
         eqvg6sISpWJ1zGSRU4ihGw/y2ep766RS2WueDgaMNJO3tXicf5W1PgJdTglEhSzQ/9Xf
         jhqMogywRSM73hp7zx8FZBLyM8pDDsZsJIFYPf4QKOoi1ygLcgLHHDIU8jVWH+H3gHqC
         czkxQDbq/nzOfc7xdmIrqJa3c+u9TYR0WL/tNVadxFDDqv25hvVleDNa72nXshkPAG7X
         RXSaXx5UoDnWj935GH1SdosGwduQEt+jPXxNjjN7vl/D9lvGXnmDGFd6ea6IgNiABws6
         uwbQ==
X-Gm-Message-State: APjAAAWJ9cHBdTNeIYAICSZoBrB5V6FDsh5WG5Ut8vGOuiWd1B35BH6w
	qEI4mWSIA19qboHttPyY6afGsf5qDAso9yMheBar9EZNZ4DZBsx0d3+y47Fc+BH0avTlepTUIDR
	z/GCNK4BYKsBTM81RMALjd4JSHEYCZ/hAGnHK8aMT/5RbMECAClHmXvgFQVzG2k7uDQ==
X-Received: by 2002:a63:18e:: with SMTP id 136mr31019773pgb.277.1559596115631;
        Mon, 03 Jun 2019 14:08:35 -0700 (PDT)
X-Received: by 2002:a63:18e:: with SMTP id 136mr31019594pgb.277.1559596113904;
        Mon, 03 Jun 2019 14:08:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596113; cv=none;
        d=google.com; s=arc-20160816;
        b=jbV8hONA3Od0R1bM+AXx5QtB2YOwxDV7OmCXkzfqSFLDvwXRqbAbLtvc0EUASNPiRD
         Dtw9r3bdYO95n+5iaEgA2UOlLIcD3YUNplC205AvIMh6wK/P1JfdrkBCGmWs06pyIiHr
         PMUPSTJSceoqil0SdF9zMVVNrAimvvBEs78Hlm5pjH6GmXYAIhpmv0HALS0Q9+aoeDJj
         5kzrfQZC/wPsebWOAmiSTtRggTyjroXQB0+7ce6YisEYC1DYhP0HVw+4077Ct+aZMpoi
         VrcJzPw3t1D+1xt6v98aeOYJf5NOQrwaY6+QKj7MPSQAIhQmp7v+HHT9Qsbe9rraXyEF
         GwuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xjW+KHnHD//MqYRxY0A82usCY+qgrBu78W4ErXk80GU=;
        b=Zq2p4Tnh2UNWkNLe/eocvtDh/45lPAZdvEvqiOmFnJK2lOH2mJnJs5uX8jmRC+S9Xb
         cTg0HFP3zSAcEjH10+ucozjY5TLjzHvLOu/7hFDqBhKVfJPaQzHFOtLEy60ghExL492h
         gZrCPUAsOPEbh9oFEJwWQQ6BwSjQQtB+MWMIctABxY2phTTzGuDv8YwgJ9BNS483XwgM
         rbbLQl0yCe1XtK6D8ZybrEcGKzKRmXHsljVKMjeZLVhXV2RXyOjsNXkPAkbIuQUxSTZk
         GRAG5Y+2FXjntGWwQi47OLesyb3YHqgll8FItdXXrrATuSiUraUrZjj25W2zmtgH4nLc
         XYmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bc7TrWgT;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor17890811pff.45.2019.06.03.14.08.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bc7TrWgT;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xjW+KHnHD//MqYRxY0A82usCY+qgrBu78W4ErXk80GU=;
        b=bc7TrWgTSGZgsPvNADkSHVc76wW+ddItC6br4BoP2u6J2Pd8x17XCsWC3tGSkAaHij
         oDcMSFJAURwkI1EsRGyUV04wA/UtJNTcgot7wyikPKZfLvqoi6mEr5mnVocvC0sTBFhE
         g0b3BThoDChYC55UwB0tCBNdqej7Q0Yz1Gli7Xn8kG9PLT/OKEki2zZyQkfL6rGKUnYs
         IhBE+6SRBybCA4Z4ALlC/2E8iG4/Lj7Ku4+nALz8YwsvMit9wJIScjmbYbcNW8nNdZNK
         TPuwsI7mqRB+pFgEWLd8ALXu3vRcJfmSXTvT9yk7gHuUaX/0bTi7PuDMoT/E+qB+7sUQ
         gyaw==
X-Google-Smtp-Source: APXvYqze2WOGrqc7zcRp11zL0Su9NKxuQeLHHGNTzfXyE/gd72jk+MrGfhvjph0MXtK8eEj/GjOljw==
X-Received: by 2002:aa7:8292:: with SMTP id s18mr2491755pfm.111.1559596113541;
        Mon, 03 Jun 2019 14:08:33 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id w62sm2586095pfw.132.2019.06.03.14.08.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:32 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 05/11] mm: vmscan: replace shrink_node() loop with a retry jump
Date: Mon,  3 Jun 2019 17:07:40 -0400
Message-Id: <20190603210746.15800-6-hannes@cmpxchg.org>
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

Most of the function body is inside a loop, which imposes an
additional indentation and scoping level that makes the code a bit
hard to follow and modify.

The looping only happens in case of reclaim-compaction, which isn't
the common case. So rather than adding yet another function level to
the reclaim path and have every reclaim invocation go through a level
that only exists for one specific cornercase, use a retry goto.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 266 ++++++++++++++++++++++++++--------------------------
 1 file changed, 133 insertions(+), 133 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index afd5e2432a8e..304974481146 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2672,164 +2672,164 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct mem_cgroup *root = sc->target_mem_cgroup;
+	struct mem_cgroup_reclaim_cookie reclaim = {
+		.pgdat = pgdat,
+		.priority = sc->priority,
+	};
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	struct mem_cgroup *memcg;
 
-	do {
-		struct mem_cgroup *root = sc->target_mem_cgroup;
-		struct mem_cgroup_reclaim_cookie reclaim = {
-			.pgdat = pgdat,
-			.priority = sc->priority,
-		};
-		struct mem_cgroup *memcg;
-
-		memset(&sc->nr, 0, sizeof(sc->nr));
+again:
+	memset(&sc->nr, 0, sizeof(sc->nr));
 
-		nr_reclaimed = sc->nr_reclaimed;
-		nr_scanned = sc->nr_scanned;
+	nr_reclaimed = sc->nr_reclaimed;
+	nr_scanned = sc->nr_scanned;
 
-		memcg = mem_cgroup_iter(root, NULL, &reclaim);
-		do {
-			unsigned long reclaimed;
-			unsigned long scanned;
+	memcg = mem_cgroup_iter(root, NULL, &reclaim);
+	do {
+		unsigned long reclaimed;
+		unsigned long scanned;
 
-			switch (mem_cgroup_protected(root, memcg)) {
-			case MEMCG_PROT_MIN:
-				/*
-				 * Hard protection.
-				 * If there is no reclaimable memory, OOM.
-				 */
+		switch (mem_cgroup_protected(root, memcg)) {
+		case MEMCG_PROT_MIN:
+			/*
+			 * Hard protection.
+			 * If there is no reclaimable memory, OOM.
+			 */
+			continue;
+		case MEMCG_PROT_LOW:
+			/*
+			 * Soft protection.
+			 * Respect the protection only as long as
+			 * there is an unprotected supply
+			 * of reclaimable memory from other cgroups.
+			 */
+			if (!sc->memcg_low_reclaim) {
+				sc->memcg_low_skipped = 1;
 				continue;
-			case MEMCG_PROT_LOW:
-				/*
-				 * Soft protection.
-				 * Respect the protection only as long as
-				 * there is an unprotected supply
-				 * of reclaimable memory from other cgroups.
-				 */
-				if (!sc->memcg_low_reclaim) {
-					sc->memcg_low_skipped = 1;
-					continue;
-				}
-				memcg_memory_event(memcg, MEMCG_LOW);
-				break;
-			case MEMCG_PROT_NONE:
-				/*
-				 * All protection thresholds breached. We may
-				 * still choose to vary the scan pressure
-				 * applied based on by how much the cgroup in
-				 * question has exceeded its protection
-				 * thresholds (see get_scan_count).
-				 */
-				break;
 			}
-
-			reclaimed = sc->nr_reclaimed;
-			scanned = sc->nr_scanned;
-			shrink_node_memcg(pgdat, memcg, sc);
-
-			if (sc->may_shrinkslab) {
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-				    memcg, sc->priority);
-			}
-
-			/* Record the group's reclaim efficiency */
-			vmpressure(sc->gfp_mask, memcg, false,
-				   sc->nr_scanned - scanned,
-				   sc->nr_reclaimed - reclaimed);
-
+			memcg_memory_event(memcg, MEMCG_LOW);
+			break;
+		case MEMCG_PROT_NONE:
 			/*
-			 * Kswapd have to scan all memory cgroups to fulfill
-			 * the overall scan target for the node.
-			 *
-			 * Limit reclaim, on the other hand, only cares about
-			 * nr_to_reclaim pages to be reclaimed and it will
-			 * retry with decreasing priority if one round over the
-			 * whole hierarchy is not sufficient.
+			 * All protection thresholds breached. We may
+			 * still choose to vary the scan pressure
+			 * applied based on by how much the cgroup in
+			 * question has exceeded its protection
+			 * thresholds (see get_scan_count).
 			 */
-			if (!current_is_kswapd() &&
-					sc->nr_reclaimed >= sc->nr_to_reclaim) {
-				mem_cgroup_iter_break(root, memcg);
-				break;
-			}
-		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
+			break;
+		}
+
+		reclaimed = sc->nr_reclaimed;
+		scanned = sc->nr_scanned;
+		shrink_node_memcg(pgdat, memcg, sc);
 
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
+		if (sc->may_shrinkslab) {
+			shrink_slab(sc->gfp_mask, pgdat->node_id,
+				    memcg, sc->priority);
 		}
 
-		/* Record the subtree's reclaim efficiency */
-		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
-			   sc->nr_scanned - nr_scanned,
-			   sc->nr_reclaimed - nr_reclaimed);
+		/* Record the group's reclaim efficiency */
+		vmpressure(sc->gfp_mask, memcg, false,
+			   sc->nr_scanned - scanned,
+			   sc->nr_reclaimed - reclaimed);
 
-		if (sc->nr_reclaimed - nr_reclaimed)
-			reclaimable = true;
+		/*
+		 * Kswapd have to scan all memory cgroups to fulfill
+		 * the overall scan target for the node.
+		 *
+		 * Limit reclaim, on the other hand, only cares about
+		 * nr_to_reclaim pages to be reclaimed and it will
+		 * retry with decreasing priority if one round over the
+		 * whole hierarchy is not sufficient.
+		 */
+		if (!current_is_kswapd() &&
+		    sc->nr_reclaimed >= sc->nr_to_reclaim) {
+			mem_cgroup_iter_break(root, memcg);
+			break;
+		}
+	} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		if (current_is_kswapd()) {
-			/*
-			 * If reclaim is isolating dirty pages under writeback,
-			 * it implies that the long-lived page allocation rate
-			 * is exceeding the page laundering rate. Either the
-			 * global limits are not being effective at throttling
-			 * processes due to the page distribution throughout
-			 * zones or there is heavy usage of a slow backing
-			 * device. The only option is to throttle from reclaim
-			 * context which is not ideal as there is no guarantee
-			 * the dirtying process is throttled in the same way
-			 * balance_dirty_pages() manages.
-			 *
-			 * Once a node is flagged PGDAT_WRITEBACK, kswapd will
-			 * count the number of pages under pages flagged for
-			 * immediate reclaim and stall if any are encountered
-			 * in the nr_immediate check below.
-			 */
-			if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
-				set_bit(PGDAT_WRITEBACK, &pgdat->flags);
+	if (reclaim_state) {
+		sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+		reclaim_state->reclaimed_slab = 0;
+	}
 
-			/*
-			 * Tag a node as congested if all the dirty pages
-			 * scanned were backed by a congested BDI and
-			 * wait_iff_congested will stall.
-			 */
-			if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
-				set_bit(PGDAT_CONGESTED, &pgdat->flags);
+	/* Record the subtree's reclaim efficiency */
+	vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
+		   sc->nr_scanned - nr_scanned,
+		   sc->nr_reclaimed - nr_reclaimed);
 
-			/* Allow kswapd to start writing pages during reclaim.*/
-			if (sc->nr.unqueued_dirty == sc->nr.file_taken)
-				set_bit(PGDAT_DIRTY, &pgdat->flags);
+	if (sc->nr_reclaimed - nr_reclaimed)
+		reclaimable = true;
 
-			/*
-			 * If kswapd scans pages marked marked for immediate
-			 * reclaim and under writeback (nr_immediate), it
-			 * implies that pages are cycling through the LRU
-			 * faster than they are written so also forcibly stall.
-			 */
-			if (sc->nr.immediate)
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
-		}
+	if (current_is_kswapd()) {
+		/*
+		 * If reclaim is isolating dirty pages under writeback,
+		 * it implies that the long-lived page allocation rate
+		 * is exceeding the page laundering rate. Either the
+		 * global limits are not being effective at throttling
+		 * processes due to the page distribution throughout
+		 * zones or there is heavy usage of a slow backing
+		 * device. The only option is to throttle from reclaim
+		 * context which is not ideal as there is no guarantee
+		 * the dirtying process is throttled in the same way
+		 * balance_dirty_pages() manages.
+		 *
+		 * Once a node is flagged PGDAT_WRITEBACK, kswapd will
+		 * count the number of pages under pages flagged for
+		 * immediate reclaim and stall if any are encountered
+		 * in the nr_immediate check below.
+		 */
+		if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
+			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 		/*
-		 * Legacy memcg will stall in page writeback so avoid forcibly
-		 * stalling in wait_iff_congested().
+		 * Tag a node as congested if all the dirty pages
+		 * scanned were backed by a congested BDI and
+		 * wait_iff_congested will stall.
 		 */
-		if (cgroup_reclaim(sc) && writeback_working(sc) &&
-		    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
-			set_memcg_congestion(pgdat, root, true);
+		if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
+			set_bit(PGDAT_CONGESTED, &pgdat->flags);
+
+		/* Allow kswapd to start writing pages during reclaim.*/
+		if (sc->nr.unqueued_dirty == sc->nr.file_taken)
+			set_bit(PGDAT_DIRTY, &pgdat->flags);
 
 		/*
-		 * Stall direct reclaim for IO completions if underlying BDIs
-		 * and node is congested. Allow kswapd to continue until it
-		 * starts encountering unqueued dirty pages or cycling through
-		 * the LRU too quickly.
+		 * If kswapd scans pages marked marked for immediate
+		 * reclaim and under writeback (nr_immediate), it
+		 * implies that pages are cycling through the LRU
+		 * faster than they are written so also forcibly stall.
 		 */
-		if (!sc->hibernation_mode && !current_is_kswapd() &&
-		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
-			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
+		if (sc->nr.immediate)
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+	}
+
+	/*
+	 * Legacy memcg will stall in page writeback so avoid forcibly
+	 * stalling in wait_iff_congested().
+	 */
+	if (cgroup_reclaim(sc) && writeback_working(sc) &&
+	    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
+		set_memcg_congestion(pgdat, root, true);
+
+	/*
+	 * Stall direct reclaim for IO completions if underlying BDIs
+	 * and node is congested. Allow kswapd to continue until it
+	 * starts encountering unqueued dirty pages or cycling through
+	 * the LRU too quickly.
+	 */
+	if (!sc->hibernation_mode && !current_is_kswapd() &&
+	    current_may_throttle() && pgdat_memcg_congested(pgdat, root))
+		wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
-	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
-					 sc->nr_scanned - nr_scanned, sc));
+	if (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
+				    sc->nr_scanned - nr_scanned, sc))
+		goto again;
 
 	/*
 	 * Kswapd gives up on balancing particular nodes after too
-- 
2.21.0

