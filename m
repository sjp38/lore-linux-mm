Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA008C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A04A2241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="WQm7ItMw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A04A2241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 672A86B0274; Mon,  3 Jun 2019 17:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 622646B0276; Mon,  3 Jun 2019 17:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44DA06B0277; Mon,  3 Jun 2019 17:08:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2996B0274
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so5132445pfj.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TZYaz3eXPzGxVmhv3HMCDwJQRLheeIorOMAlH7HJ9WE=;
        b=K/Q3gG/NEef+FUiYlnXQALxfxqvsaYFL89MnfHIiDFFUOXCsAoYTu/MlmPSTEmOOeU
         3MpeHZGe4YlnvAZutoMvsDqz4Rj4P6fJH09etk1jRPqlb0HeZI3HBezSW47r0+BIX0Er
         UFQqcrGr1z3l7D/B834G6GTMwwuvNxpDXwwfqJNnpX5xK8NKPxr8SxatIj2JTrbyNErP
         H3GDUzIGVfjdw234pkH9//Qc3xbMH/xlAkAcP1ILJlZNJgEVJKbd1+p6AzFyGavWr0az
         54vuPLcCpu1dyI8UasImC9xAnmClzV+rORsy333X2PnEL2q30XunmwXVFNAjCyF1mr24
         lnQg==
X-Gm-Message-State: APjAAAUeToX3O9xH48aoRfye9jueGEVSIFS3Eheef6qPaQgXZ1Vw27z2
	NOGFnlB9dVmMdxG26Kv++kRkqOPcJGohjHAjf0NX+I2JV2i3XB+P2ugQu14q0S7pKu1K7ewU7Hs
	jOMxDNM4QiT4XpFBSyZ8WWBsstWBU9GOoqoWFMyAe+5s7Uu8RFk1WWPNebZjWAEuWbA==
X-Received: by 2002:a62:1c82:: with SMTP id c124mr20987564pfc.39.1559596117574;
        Mon, 03 Jun 2019 14:08:37 -0700 (PDT)
X-Received: by 2002:a62:1c82:: with SMTP id c124mr20987420pfc.39.1559596116225;
        Mon, 03 Jun 2019 14:08:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596116; cv=none;
        d=google.com; s=arc-20160816;
        b=I8xRRlnKIK6LhxMR53Jy0MXy5jD7X8DkuMAx+/UUTDoPzpyAH0FZmMHzZZbmge93ht
         sbX5lN/GCc/wBLWg6KmjpSo1sYooxc68gRb+TSWydWhTRTV5UvVmLGt3XY3WeMckZk1o
         BCLe+4r86le5b+U6vvKejRzlCoMU6d0PEtiTT2EixdB3H9wrJfEcpgvmcpgZ4RJiEFzR
         Rf0z1LwKxrN5lgIwUDzZ5gXhbfBUoxH1SxaMk5JLwEHySyJjym7UICM4T4VKCeXguKBw
         YgJ+rv6X2gCrtUFh4eunjAVlaIu/df+bDvYqXR2syFRDcHV0J72vyLr5EyEAx1JliXdP
         WD0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TZYaz3eXPzGxVmhv3HMCDwJQRLheeIorOMAlH7HJ9WE=;
        b=d9PQBMmAQrSPE4kDJL6DYolvxVzQc1g+O5hjcEhCvlPMcdrLIQeKSd8yKTDjsCrVJY
         2DN9rMG2SUrNcEpnLCLwdC2g55zS41srY15yOz+zBvnRc0oZBcDUleCQ1xibhxJhn8dB
         2Yst49/bLAJ8UQo8pUypOtdgtYjoRuUjQ9rXGjWbD8AcTh8jwTnDhJsfwyROSVtT/I2i
         aN2y/ubbYYRccr/UMNU+J5O+efwCABTFz05CewiDY13xtGT7jJnxgoM+S2HXhSXyPSsT
         gG18J98zXYBlwxCGoxO+T/1Vnby0HmWxwY0kmOtdNnjRby3iYR2CTRWRUA2lLEs9Hhk0
         DnmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WQm7ItMw;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z16sor16037864pgl.47.2019.06.03.14.08.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WQm7ItMw;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TZYaz3eXPzGxVmhv3HMCDwJQRLheeIorOMAlH7HJ9WE=;
        b=WQm7ItMwHktG69xBNCOEpRK0igijLT4KjtCpBChKUtJC8aBS9I40wEtrTmWdpuarBT
         EckEfBxI/uccO9dAsIBtIyhtxBfgqHV0832w0TwgkUwpZ7L5A7gL+qjqAq5+n37IDIcL
         QOnCWjesoJnT4Ik5GCuPeO/EyCm9kSCpcQ26IFQLfuLJY5XXNcXM+pfT84cIDT5o+y6o
         +MhC8h281MnBe0uI2y+qvuR2asCG9iNhPDsNn9dwW9QRXVOtO8309ZMSiP9qFEiRH84p
         fQJBUtGGkOa0hmoDQAgB3Q9oqONyoSWSGmot04Ty0joMo26ffwXfKHDAmgMunBMEa7eZ
         vQvw==
X-Google-Smtp-Source: APXvYqyUI6JZB6XXqVKgsi+gR5x7wSmX1jg48nP5ImJujjIGhoL+bC3ILJjIPqmTRQB1s7taN2/0gw==
X-Received: by 2002:a65:494a:: with SMTP id q10mr30911726pgs.201.1559596115744;
        Mon, 03 Jun 2019 14:08:35 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id g8sm7238285pgd.29.2019.06.03.14.08.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:35 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 06/11] mm: vmscan: turn shrink_node_memcg() into shrink_lruvec()
Date: Mon,  3 Jun 2019 17:07:41 -0400
Message-Id: <20190603210746.15800-7-hannes@cmpxchg.org>
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

A lruvec holds LRU pages owned by a certain NUMA node and cgroup.
Instead of awkwardly passing around a combination of a pgdat and a
memcg pointer, pass down the lruvec as soon as we can look it up.

Nested callers that need to access node or cgroup properties can look
them them up if necessary, but there are only a few cases.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 304974481146..b85111474ee2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2210,9 +2210,10 @@ enum scan_balance {
  * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
-static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
-			   struct scan_control *sc, unsigned long *nr)
+static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
+			   unsigned long *nr)
 {
+	struct mem_cgroup *memcg = lruvec_memcg(lruvec);
 	int swappiness = mem_cgroup_swappiness(memcg);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -2460,13 +2461,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	}
 }
 
-/*
- * This is a basic per-node page freer.  Used by both kswapd and direct reclaim.
- */
-static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memcg,
-			      struct scan_control *sc)
+static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
-	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2476,7 +2472,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, memcg, sc, nr);
+	get_scan_count(lruvec, sc, nr);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2689,6 +2685,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
+		struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
 		unsigned long reclaimed;
 		unsigned long scanned;
 
@@ -2725,7 +2722,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 		reclaimed = sc->nr_reclaimed;
 		scanned = sc->nr_scanned;
-		shrink_node_memcg(pgdat, memcg, sc);
+
+		shrink_lruvec(lruvec, sc);
 
 		if (sc->may_shrinkslab) {
 			shrink_slab(sc->gfp_mask, pgdat->node_id,
@@ -3243,6 +3241,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						pg_data_t *pgdat,
 						unsigned long *nr_scanned)
 {
+	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.target_mem_cgroup = memcg,
@@ -3268,7 +3267,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_node_memcg(pgdat, memcg, &sc);
+	shrink_lruvec(lruvec, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(
 					cgroup_ino(memcg->css.cgroup),
-- 
2.21.0

