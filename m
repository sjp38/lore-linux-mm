Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60328C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BB1620850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:44:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="dhjIGj9G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BB1620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1FD66B000D; Fri, 12 Apr 2019 10:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D10F6B026B; Fri, 12 Apr 2019 10:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84D0E6B026C; Fri, 12 Apr 2019 10:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 617EB6B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:44:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so9037259qtb.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=TpJORoHWMkN029iMtW7/72pORwZc7P01cwdjOx9UylM=;
        b=B1+quOCoSIgEj4uexnFHZpR7AYmaTy/ynI9+Qc/7Ig9EEy4TL3MCqfVz800vEwoIdb
         j3i+at+U20PrYs043/f5VUcc4n7R89SW53lNxZ34cAQHajqdzoSWDWAqt/9wtOLqZn8p
         gzu57Tw/HC/LSZqaBYKNQPH3FxvyU1RjQCHpJ/dBg1q4Bh8AzlsNdcz8actxSmtBQH63
         PLwEAiE2hE7Tg7CfV2zG3RcW0f+AAWMn5Mm0cbld2bREDvpZMqbIdZA5g0Tu/9/rvWBR
         qMsPBucQNsKYq1KTJRMbYkG4F/VVplMXWUPBtO9PO4OdhPuXYuc5LM4889x3YccejbjS
         AEyQ==
X-Gm-Message-State: APjAAAUjVhEgUKj7nSMPDPOz0Jdr2uF6NFxwTH3Wi52hgEMjP+taFYlJ
	O7Eoj9rdEdShXd59n4E0i/DZ4baN7ug+RaTHvZf9PNqYHUj9i2cyNa/xiGhuV2Fiiuy2+3d5xW9
	K11R1ngbD/rqDr9x+2J+jiwEWLwT7BG8I3LHLWKn0HujCDCg5/60/KOWB5paDtkKZAQ==
X-Received: by 2002:ac8:32f2:: with SMTP id a47mr46699558qtb.251.1555080287078;
        Fri, 12 Apr 2019 07:44:47 -0700 (PDT)
X-Received: by 2002:ac8:32f2:: with SMTP id a47mr46699468qtb.251.1555080285758;
        Fri, 12 Apr 2019 07:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555080285; cv=none;
        d=google.com; s=arc-20160816;
        b=I2aR2E3RR2jC0Dzvco0D9NRB+EREWY0IYyuksUXB8ARojsbPiglBNDCtjk18MQgrh3
         jnlAQYyipGN89EXejLDIbGwgqmc4OJV1WTLjwEw8MwK4bNBIjXcAj1ViXDPsDrr4S8D2
         /aUG0dzRA3ZxDogeaH1fvOIiBVFzPEPv5hekXH5fRYyWKaeOhHk7C2BTRFyQxA0AqVDU
         ILJFccoNF2DqprGy54gvDwfBuwWws594FM5jLP9T3IfKH2LrwRaBXWFwDYbyVAwBsTuJ
         42nEgJAmm3UUfWoJNSBQX7sNlUTZJRBeCpSuwId/04jUxyJPGE+B95XfU4dDYeia1I5e
         +4+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=TpJORoHWMkN029iMtW7/72pORwZc7P01cwdjOx9UylM=;
        b=uTTw0iaicXcdXAfxLGQSCFpjE9TMxRz7GaxZ9Isca+3kmc3oc7teLmI6Ux7YElfyJ9
         i/SGgyoW3d+R1hYlriVkvOVm2D498LXKQHuLPe7i+Cf2K2gXgQa+jwi/SVYzkXsd3kzR
         ROGOnsUC6SfHPwxmwGVuTMWRkXP3ahhBUwQWmCNEDmqUS9G0/TUv/OP6rk6vGXqmd5rb
         QurgSbU5Jo+/Z2CQRt0d7u9SOA4YTs+47OTwgrkLKM/map1I1gB/wGpLsvfpXvimfUIP
         PpyYA2pYZ+pok2X1T3H/PDP+jUvZIG0RW0EKnbF1wA8jwmoGZTXwuh/KayrVe4hlxdZg
         GnBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=dhjIGj9G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t24sor42046145qvc.44.2019.04.12.07.44.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:44:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=dhjIGj9G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=TpJORoHWMkN029iMtW7/72pORwZc7P01cwdjOx9UylM=;
        b=dhjIGj9GhnlUIw42QmSp6MHvSVLlCu6/A72GkymhOJ1S3wjd/dN17urp2QV0SAlwlo
         AwQwr86bgAy87FPEIYjdQBUK90nHPVdms2Gsk6G7qUOKpg5wj/jo9lb46sDapoIRzvwy
         T3V0zNZJl4I74l4wDv0wZicEmFF35/pHAAqUhE8cCGRCM/IZMlaAdCcZyhksBfUb6m1q
         c0JUuQBx88GqBraoMu0W8Ps11nbd9Wce4xNlJ+8FLUc0fIDBcEc3ZXGBcfboAbIzE/R/
         bOizgsBKHYr3nkBRJj6gTO+8CbjiYSwUGajlKPLOdBLIoJF5An0UZdvQyj+G1meD2gI6
         2bwg==
X-Google-Smtp-Source: APXvYqy/JiV+mpq/lmqwaiYygCKW/w5T4iyoMKlKxGVcJ2MxHcoeWNRNkraAqnesgfBoBPLaRH1TUg==
X-Received: by 2002:a0c:b050:: with SMTP id l16mr46942814qvc.82.1555080280635;
        Fri, 12 Apr 2019 07:44:40 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id r31sm24841599qtj.17.2019.04.12.07.44.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 07:44:39 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH] mm: fix inactive list balancing between NUMA nodes and cgroups
Date: Fri, 12 Apr 2019 10:44:38 -0400
Message-Id: <20190412144438.2645-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

During !CONFIG_CGROUP reclaim, we expand the inactive list size if
it's thrashing on the node that is about to be reclaimed. But when
cgroups are enabled, we suddenly ignore the node scope and use the
cgroup scope only. The result is that pressure bleeds between NUMA
nodes depending on whether cgroups are merely compiled into Linux.
This behavioral difference is unexpected and undesirable.

When the refault adaptivity of the inactive list was first introduced,
there were no statistics at the lruvec level - the intersection of
node and memcg - so it was better than nothing.

But now that we have that infrastructure, use lruvec_page_state() to
make the list balancing decision always NUMA aware.

Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347c9b3b29ac..c9f8afe61ae3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2138,7 +2138,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct mem_cgroup *memcg,
 				 struct scan_control *sc, bool actual_reclaim)
 {
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
@@ -2159,16 +2158,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
-	if (memcg)
-		refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-	else
-		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 	/*
 	 * When refaults are being observed, it means a new workingset
 	 * is being established. Disable active list protection to get
 	 * rid of the stale workingset quickly.
 	 */
+	refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 	if (file && actual_reclaim && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
@@ -2189,12 +2184,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct lruvec *lruvec, struct mem_cgroup *memcg,
-				 struct scan_control *sc)
+				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru),
-					 memcg, sc, true))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2293,7 +2286,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * anonymous pages on the LRU in eligible zones.
 			 * Otherwise, the small LRU gets thrashed.
 			 */
-			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
+			if (!inactive_list_is_low(lruvec, false, sc, false) &&
 			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
 					>> sc->priority) {
 				scan_balance = SCAN_ANON;
@@ -2311,7 +2304,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
+	if (!inactive_list_is_low(lruvec, true, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2515,7 +2508,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, memcg, sc);
+							    lruvec, sc);
 			}
 		}
 
@@ -2582,7 +2575,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+	if (inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2985,12 +2978,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
-		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-		else
-			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
@@ -3346,7 +3335,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.21.0

