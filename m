Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19433C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B720A241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="yTHNUkzu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B720A241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22D7A6B0277; Mon,  3 Jun 2019 17:08:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DDF96B0278; Mon,  3 Jun 2019 17:08:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CCEA6B0279; Mon,  3 Jun 2019 17:08:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE6056B0277
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so1059887pgk.16
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B6ockcEeDUtUJIvlx/DoCdCq85by+mHeIaqq/AmMtrQ=;
        b=R3jEy7UKHvc5MRnGJ95GCSd5YwjtSY/423jONGH3SV0/JQSgQF0oBo4naHEZGLz02u
         0E2FqSEOQlCw3s3yfhLkjL9gvaqPzHhTODDJjS3urNwc08+oZKSTprCrSj54uOb54iUR
         hmzi07jNoKPR1qLrG9PyMu5rhJ1x5yw4VuTXL1N/7AoDPlYMHkUDDIB1+OQAZJ+4FcKd
         NmsGM7SxVS+R+l/oxd6R34hoPB3+7/6RTM3ezPdDPwpqMqiSmZ/yJFyggWZnv6NhFH0f
         ibNCFIHODX3pn6F0MAPcqaoGVVZyskPvn7nZbczJqrpEvpU6IcoJ4FuRUQWgTRVqWCqr
         xf6g==
X-Gm-Message-State: APjAAAWrid/NOq10ihmb7Cwd/+Y0cKlR4SJ5nanFsrlYA+r6CjJWlPkc
	hQ5bNb7isFjiOnwm4mw+8MH2Qbb9hH34MtWkNt+d0ALhk7+t71swSae2V2OzkVUrd4JXa7KGAL9
	GVL6dHRKxDneVKhSks3vZlPOkkMEcKqkmraxZqX7wAMUsVaGHP0D5pBykBtwCjWeAhw==
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr4927801pjc.71.1559596122291;
        Mon, 03 Jun 2019 14:08:42 -0700 (PDT)
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr4927611pjc.71.1559596120593;
        Mon, 03 Jun 2019 14:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596120; cv=none;
        d=google.com; s=arc-20160816;
        b=nSPpRY4x1WaTTJoMW0+guW8CmRWehQQh0co8U26bfxWLL19yl6ka4SvXx+p1YxxTtM
         fuhPIsYn29tVELWOs9hVGXZn1uUwPfT6102Jcirdt9t8Y14hM64vcWpfBlcSxPHEVNui
         /Zf+egqEcCydNUn89fi4SS6fnuQQgAeSymjhLxKbAbwxE6EQU6iyYubqjznI3isj8c1i
         Fxz5/P5q64PMLMfh5EWy5qPDmjHo8MGZcLxibMXD793CPlrrNY6dtl4Obb8ztRdUy4yq
         9kRFay9+UiBIzsFsMjeZ/YPO55DS7RKWweR6BpCbKb4voMLslJArYsECfX2RcTaDfqFj
         gF8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=B6ockcEeDUtUJIvlx/DoCdCq85by+mHeIaqq/AmMtrQ=;
        b=TnywK8Ch/ggfjW4ww3SrMqdyvFsc14IG7teGt0JNyvfBo+eY7EkZEbi8hJ0pbchKm9
         M7xVHZ7jvpdSUCy5EWRMPlcyni/nTaLadUG9jW58zDbros39LpjPCwThr6uUVwgqmn2t
         +RGn7bawRARUOWRJY76JFlipeSFY7DuN1yPilsQgAkT8Or9pEsOe+MHv2kMxiqNjA6Yu
         ybLofCduYXxSNf5awRxMFBUw6rt1s8AByvPDX7WwMNis1L/GFzJsvwqEueb2J6lY0VL0
         rOa1CqB0+rblDIlxx+r4PZhs5zaFjlLQZqIRpCB6rI1DryN64keCtQ1g3PKjyPrZM97V
         z0XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yTHNUkzu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k13sor17612577pfi.31.2019.06.03.14.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=yTHNUkzu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=B6ockcEeDUtUJIvlx/DoCdCq85by+mHeIaqq/AmMtrQ=;
        b=yTHNUkzufxtfKAvZ8UcncxQaDV9qHqMwPaRk5AmPUtvARbAXYSqoPt3ofMv01d0IVK
         iq5U7nvDJ8vBmko1GaK2TR709/MyNG3qm2uSTW7dRg9eE71uW5vLMYGsmYte6+wfLRaE
         5GKSSrFSsRhMFmNR16jq/rSVOoTVNyroChHLeKRWVj/c2bh0mvOgipIaBpWZcXeGN/D9
         SvQM0GjhTA0oTOIG+m//ObL5L/IiQ6efS1GDg/J2rtN05JnTIU1VTH/rZWVL9SG0APMg
         /Yqy/0xBtIr31FfzTp67H6lg0r6x+o2rQFjdwXB4VjuV6R0OSBzszTpbsOt3VRhQlWSx
         f5kw==
X-Google-Smtp-Source: APXvYqzuuFNtUjyKK1QDwjQku2LKUXQVeGjjjtfFcm0GcLid0BXMv6q6FaLzEqUddR/mQYmveXzu6A==
X-Received: by 2002:a62:3741:: with SMTP id e62mr34248051pfa.213.1559596120271;
        Mon, 03 Jun 2019 14:08:40 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id l20sm15695900pff.102.2019.06.03.14.08.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:39 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 08/11] mm: vmscan: harmonize writeback congestion tracking for nodes & memcgs
Date: Mon,  3 Jun 2019 17:07:43 -0400
Message-Id: <20190603210746.15800-9-hannes@cmpxchg.org>
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

The current writeback congestion tracking has separate flags for
kswapd reclaim (node level) and cgroup limit reclaim (memcg-node
level). This is unnecessarily complicated: the lruvec is an existing
abstraction layer for that node-memcg intersection.

Introduce lruvec->flags and LRUVEC_CONGESTED. Then track that at the
reclaim root level, which is either the NUMA node for global reclaim,
or the cgroup-node intersection for cgroup reclaim.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  6 +--
 include/linux/mmzone.h     | 11 ++++--
 mm/vmscan.c                | 80 ++++++++++++--------------------------
 3 files changed, 36 insertions(+), 61 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fc32cfaebf32..d33e09c51acc 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -144,9 +144,6 @@ struct mem_cgroup_per_node {
 	unsigned long		usage_in_excess;/* Set to the value by which */
 						/* the soft limit is exceeded*/
 	bool			on_tree;
-	bool			congested;	/* memcg has many dirty pages */
-						/* backed by a congested BDI */
-
 	struct mem_cgroup	*memcg;		/* Back pointer, we cannot */
 						/* use container_of	   */
 };
@@ -401,6 +398,9 @@ static inline struct lruvec *mem_cgroup_lruvec(struct mem_cgroup *memcg,
 		goto out;
 	}
 
+	if (!memcg)
+		memcg = root_mem_cgroup;
+
 	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
 	lruvec = &mz->lruvec;
 out:
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 95d63a395f40..b3ab64cf5619 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -293,6 +293,12 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+enum lruvec_flags {
+	LRUVEC_CONGESTED,		/* lruvec has many dirty pages
+					 * backed by a congested BDI
+					 */
+};
+
 struct lruvec {
 	struct list_head		lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat	reclaim_stat;
@@ -300,6 +306,8 @@ struct lruvec {
 	atomic_long_t			inactive_age;
 	/* Refaults at the time of last reclaim cycle */
 	unsigned long			refaults;
+	/* Various lruvec state flags (enum lruvec_flags) */
+	unsigned long			flags;
 #ifdef CONFIG_MEMCG
 	struct pglist_data *pgdat;
 #endif
@@ -562,9 +570,6 @@ struct zone {
 } ____cacheline_internodealigned_in_smp;
 
 enum pgdat_flags {
-	PGDAT_CONGESTED,		/* pgdat has many dirty pages backed by
-					 * a congested BDI
-					 */
 	PGDAT_DIRTY,			/* reclaim scanning has recently found
 					 * many dirty file pages at the tail
 					 * of the LRU.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee79b39d0538..eb535c572733 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -267,29 +267,6 @@ static bool writeback_working(struct scan_control *sc)
 #endif
 	return false;
 }
-
-static void set_memcg_congestion(pg_data_t *pgdat,
-				struct mem_cgroup *memcg,
-				bool congested)
-{
-	struct mem_cgroup_per_node *mn;
-
-	if (!memcg)
-		return;
-
-	mn = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
-	WRITE_ONCE(mn->congested, congested);
-}
-
-static bool memcg_congested(pg_data_t *pgdat,
-			struct mem_cgroup *memcg)
-{
-	struct mem_cgroup_per_node *mn;
-
-	mn = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
-	return READ_ONCE(mn->congested);
-
-}
 #else
 static bool cgroup_reclaim(struct scan_control *sc)
 {
@@ -300,18 +277,6 @@ static bool writeback_working(struct scan_control *sc)
 {
 	return true;
 }
-
-static inline void set_memcg_congestion(struct pglist_data *pgdat,
-				struct mem_cgroup *memcg, bool congested)
-{
-}
-
-static inline bool memcg_congested(struct pglist_data *pgdat,
-			struct mem_cgroup *memcg)
-{
-	return false;
-
-}
 #endif
 
 /*
@@ -2659,12 +2624,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	return true;
 }
 
-static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
-{
-	return test_bit(PGDAT_CONGESTED, &pgdat->flags) ||
-		(memcg && memcg_congested(pgdat, memcg));
-}
-
 static void shrink_node_memcgs(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2748,8 +2707,11 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct mem_cgroup *root = sc->target_mem_cgroup;
 	unsigned long nr_reclaimed, nr_scanned;
+	struct lruvec *target_lruvec;
 	bool reclaimable = false;
 
+	target_lruvec = mem_cgroup_lruvec(sc->target_mem_cgroup, pgdat);
+
 again:
 	memset(&sc->nr, 0, sizeof(sc->nr));
 
@@ -2792,14 +2754,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
 			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
-		/*
-		 * Tag a node as congested if all the dirty pages
-		 * scanned were backed by a congested BDI and
-		 * wait_iff_congested will stall.
-		 */
-		if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
-			set_bit(PGDAT_CONGESTED, &pgdat->flags);
-
 		/* Allow kswapd to start writing pages during reclaim.*/
 		if (sc->nr.unqueued_dirty == sc->nr.file_taken)
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
@@ -2815,12 +2769,17 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	}
 
 	/*
+	 * Tag a node/memcg as congested if all the dirty pages
+	 * scanned were backed by a congested BDI and
+	 * wait_iff_congested will stall.
+	 *
 	 * Legacy memcg will stall in page writeback so avoid forcibly
 	 * stalling in wait_iff_congested().
 	 */
-	if (cgroup_reclaim(sc) && writeback_working(sc) &&
+	if ((current_is_kswapd() ||
+	     (cgroup_reclaim(sc) && writeback_working(sc))) &&
 	    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
-		set_memcg_congestion(pgdat, root, true);
+		set_bit(LRUVEC_CONGESTED, &target_lruvec->flags);
 
 	/*
 	 * Stall direct reclaim for IO completions if underlying BDIs
@@ -2828,8 +2787,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	 * starts encountering unqueued dirty pages or cycling through
 	 * the LRU too quickly.
 	 */
-	if (!sc->hibernation_mode && !current_is_kswapd() &&
-	    current_may_throttle() && pgdat_memcg_congested(pgdat, root))
+	if (!current_is_kswapd() && current_may_throttle() &&
+	    !sc->hibernation_mode &&
+	    test_bit(LRUVEC_CONGESTED, &target_lruvec->flags))
 		wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
 	if (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
@@ -3043,8 +3003,16 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		if (zone->zone_pgdat == last_pgdat)
 			continue;
 		last_pgdat = zone->zone_pgdat;
+
 		snapshot_refaults(sc->target_mem_cgroup, zone->zone_pgdat);
-		set_memcg_congestion(last_pgdat, sc->target_mem_cgroup, false);
+
+		if (cgroup_reclaim(sc)) {
+			struct lruvec *lruvec;
+
+			lruvec = mem_cgroup_lruvec(sc->target_mem_cgroup,
+						   zone->zone_pgdat);
+			clear_bit(LRUVEC_CONGESTED, &lruvec->flags);
+		}
 	}
 
 	delayacct_freepages_end();
@@ -3419,7 +3387,9 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 /* Clear pgdat state for congested, dirty or under writeback. */
 static void clear_pgdat_congested(pg_data_t *pgdat)
 {
-	clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+	struct lruvec *lruvec = mem_cgroup_lruvec(NULL, pgdat);
+
+	clear_bit(LRUVEC_CONGESTED, &lruvec->flags);
 	clear_bit(PGDAT_DIRTY, &pgdat->flags);
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
 }
-- 
2.21.0

