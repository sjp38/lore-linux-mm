Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64023C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB452554A
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="CfO5Ti2i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB452554A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C68BF6B0276; Mon,  3 Jun 2019 17:08:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC93B6B0277; Mon,  3 Jun 2019 17:08:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A91FE6B0278; Mon,  3 Jun 2019 17:08:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 722AB6B0276
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so5132534pfj.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TqYkozLWwlwjh5tlY84d20KyoxNGzeaiPZCNbBAwhx4=;
        b=VyOlXNC6buTiunA49cG2F/afluNhQbVD4s0Krj/22tXKNurG4/ruLlCy7GsPpWd9aJ
         Fkfpnp4IFmLATXOJYYcgoUjVDglRfU0WmfMjDj2IzV3yEMzzdcAn48rt3hKZTk7Zm3eT
         HY1vblLH00zre5wS75hwmB3YGS7mKz1w3r6iNgr4JRNAziJsutTsG1xpgxwmatImZ4L8
         sFAa/kZogUTINftVY0bbpEaOyMe0c/Cbgv89aRq0IFrQBwiAk3ZPgVBWQsLXdQMgujnS
         +McqcbfA1+4fNb08ThZ9XbOA9GOlaK2dIbJ7CDLkjCtOokAtDfEmTbCJLmRzsRvp+N7x
         U6+w==
X-Gm-Message-State: APjAAAWI3ykByN9KjBF/wpkq1rmupFvecxuSowV5++d6GRy8jOEpRhQI
	aMBMXtQ8YffBOaXyv3ZhZxQMktDhRXvwuLGkJ1EOHTE+ztMyqk5b6NeV19N/rsY0Cd2ALCugDos
	6ScYoKS5HCPShPm2Lc/Uh2gVet4tWfuOk+/ByvCwJA/YyX5iFtu3JTSp9bbwkAaV14Q==
X-Received: by 2002:a63:1516:: with SMTP id v22mr9295230pgl.204.1559596119979;
        Mon, 03 Jun 2019 14:08:39 -0700 (PDT)
X-Received: by 2002:a63:1516:: with SMTP id v22mr9295052pgl.204.1559596118301;
        Mon, 03 Jun 2019 14:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596118; cv=none;
        d=google.com; s=arc-20160816;
        b=Wy6UPI9/ybRIYtpQ//84OsBib+TVcMHVX5fRSeXumGAQ3vCb276T6fBCTQDr5QBuyu
         TMXjXJYthewpxYhUPDc4TfYG/hE3PAVxCF11Y+av6uAql/139OMt1OIebHYM7Obg+rAa
         tRlkE/Z+lzmsjAkGgiVO+3ofo+lMEH5DPWZX62HNLKrRCnSXdrLTL1VIxr2xOvjO9RBf
         GHCldM+EFmpSY00/mG7KMNSyWXEDguCMbPiSljd3LoHM7QQ+2g8/Al38mRDCoeLZW/XO
         N8gwI4WmJ4fEO41nmR4BuX/RFydoTVrYLZSEs1Y7asWHSY41v6JfZIb9oq5FGXCI9eXX
         vzDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TqYkozLWwlwjh5tlY84d20KyoxNGzeaiPZCNbBAwhx4=;
        b=wGgjun0+vEkCD4HyLzwHxcw2KQIxvg559cx9KR2UPiSByG5mnEPtxdWjK7LddhKaOh
         8wBlkdZn3iHUXH118+WanAxiJblPVj5kcHOTLMRLdZ+BnC59qIDi8NBaWObf5YH0hVik
         ivUm2sNqdzW6voNzfDxQP04Hr1ge6gHlGbv2CLlwVXfjMAJQ0x0NFi6jVC1ycOqk9Vw2
         DIJjjT7B5Vf4LWJci5MA+hBP4Ee5vplw7lz9JbGr58JyXYDBuWdndhgvbXIPavZ8Pt3H
         rH1au65r2hs73GAtTvHYV4/UWQqO4S9P9uAwyHL7ULTyqXLWXR+MMQmApsQ3kMCC2LG1
         cllA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CfO5Ti2i;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c9sor10307737pjr.0.2019.06.03.14.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=CfO5Ti2i;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TqYkozLWwlwjh5tlY84d20KyoxNGzeaiPZCNbBAwhx4=;
        b=CfO5Ti2iu2mKkyrYwQLDB8QQe+3afMqMfaNa/wJWa+mXj+X31SmaTgT+uw/gY/rdTf
         jyGegdzwHQpljpHWA2wVsG+b+pBVziQt1WX1xTIGjq8MuGjOuPpGwAopHMkHZqKp3+Ui
         tIjfvPdEXyrjLHGUp3YnhPfJubq1kFYnfoDUBGlOpXwawLoXGpyTrhQT4Z9tXoIbW1ou
         FA5RvsNPdN/E2REMNh3zWT5ebiR0nab16veulDQZkupuNnzCdYJtcdh5eyxzTO6LIVCK
         7VRPrTbECquvW9jgMxA0+O34IrqMJjOL2ObDNuSMq/SrUHZlwsk4bT5BfEeNMBlTPcMO
         wkEw==
X-Google-Smtp-Source: APXvYqzH0EJ92OjOv5FwdHpAISabNaN9/8D6YdAXlhN10L2LyvWxDpYUP+V6sT0plAQOTb0Hmr9Pgg==
X-Received: by 2002:a17:90a:192:: with SMTP id 18mr33065596pjc.107.1559596117989;
        Mon, 03 Jun 2019 14:08:37 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id i25sm16343173pfr.73.2019.06.03.14.08.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:37 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 07/11] mm: vmscan: split shrink_node() into node part and memcgs part
Date: Mon,  3 Jun 2019 17:07:42 -0400
Message-Id: <20190603210746.15800-8-hannes@cmpxchg.org>
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

This function is getting long and unwieldy. The new shrink_node()
handles the generic (node) reclaim aspects:
  - global vmpressure notifications
  - writeback and congestion throttling
  - reclaim/compaction management
  - kswapd giving up on unreclaimable nodes

It then calls shrink_node_memcgs() which handles cgroup specifics:
  - the cgroup tree traversal
  - memory.low considerations
  - per-cgroup slab shrinking callbacks
  - per-cgroup vmpressure notifications

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b85111474ee2..ee79b39d0538 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2665,24 +2665,15 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 		(memcg && memcg_congested(pgdat, memcg));
 }
 
-static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
+static void shrink_node_memcgs(pg_data_t *pgdat, struct scan_control *sc)
 {
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct mem_cgroup *root = sc->target_mem_cgroup;
 	struct mem_cgroup_reclaim_cookie reclaim = {
 		.pgdat = pgdat,
 		.priority = sc->priority,
 	};
-	unsigned long nr_reclaimed, nr_scanned;
-	bool reclaimable = false;
 	struct mem_cgroup *memcg;
 
-again:
-	memset(&sc->nr, 0, sizeof(sc->nr));
-
-	nr_reclaimed = sc->nr_reclaimed;
-	nr_scanned = sc->nr_scanned;
-
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
@@ -2750,6 +2741,22 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			break;
 		}
 	} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
+}
+
+static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
+{
+	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct mem_cgroup *root = sc->target_mem_cgroup;
+	unsigned long nr_reclaimed, nr_scanned;
+	bool reclaimable = false;
+
+again:
+	memset(&sc->nr, 0, sizeof(sc->nr));
+
+	nr_reclaimed = sc->nr_reclaimed;
+	nr_scanned = sc->nr_scanned;
+
+	shrink_node_memcgs(pgdat, sc);
 
 	if (reclaim_state) {
 		sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2757,7 +2764,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	}
 
 	/* Record the subtree's reclaim efficiency */
-	vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
+	vmpressure(sc->gfp_mask, root, true,
 		   sc->nr_scanned - nr_scanned,
 		   sc->nr_reclaimed - nr_reclaimed);
 
-- 
2.21.0

