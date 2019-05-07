Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E8FC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9800D216C4
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:37:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PExlh3Tr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9800D216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 438046B000D; Tue,  7 May 2019 01:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E9916B000E; Tue,  7 May 2019 01:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D67E6B0010; Tue,  7 May 2019 01:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA21C6B000D
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:37:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z7so9594652pgc.1
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:37:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Rqd2cD4vVW3+Sd74LDrUld398jWG+6bIAKO8kOtCuxY=;
        b=DS5eg/40QH4gwzFY0uA9bsXwIuMDGqC8gL0eHaCbW4mQ6FWf+KCYKcSPcZgQPOLvrn
         frBrd7piAYXjdhhljkmzfUBZBZ4++2P/tnYFpoV5wn/V+CkECOSR7SIaQaMGgY3kkDwE
         05OHbFohjvC9ykwUV4xd2EL1dazplI0UpnHEXIi6iCZ3vFGbwJN72JRNZfXTZpkBojXp
         p5rUoNrTU0ZwuCGUJpmD6Dl0KhA7Vfvg15j/sHoxwJ1uCIx+MBqXJ492dqp78LJunc5j
         4j7pcxEhHlPxSgtfvE3QAWFo2AQ4mCsej0Qnms2+A4a+YcGAO91LcRXKt4nD6ZztwMXB
         gImg==
X-Gm-Message-State: APjAAAWLJ8aBK552bvGpe6pJppsliwLpAhcizRSfTj5RWdxegNxum1yi
	lQRP/QP3Pg1HiTJv6n63tPv+G1iu3b2wAbtiXhnVVZXC92nL2WgHCI9EepPFr1XLPvHwAXttcjX
	cAqoQg+KevKEhVfqNTp+Cb9mfKKhq58PmoMBcOQ58NUI0Kjswsci9aI9eNGAJsqPDPg==
X-Received: by 2002:a63:9548:: with SMTP id t8mr22069484pgn.256.1557207435601;
        Mon, 06 May 2019 22:37:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhXapJtwRNH6m0xLHuypshOTSSVLvDwK9l8bCY/k4dfYAubJ6J5a73Nyv4du8HsBFXGtvT
X-Received: by 2002:a63:9548:: with SMTP id t8mr22069432pgn.256.1557207434866;
        Mon, 06 May 2019 22:37:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207434; cv=none;
        d=google.com; s=arc-20160816;
        b=kJSe6sHSLi6WclLc8cy2PA60d/2lg5A+a+h/k28TxiQIyaYl7d2uLOtwgjg/zLhibC
         UBps0ZY/UH/pUxcI5TMHqdk/obNG7OK0zxAyoH5/1NwfsJ9l9ZK3DRcKlAIu6hGTiKyx
         JXjveWPC3ttO1Yq5E1JVzsgr2OtywAXkdbyllXSJtOBz6Y2/AuerllpR3XU3MNYBgjhm
         X1WkKuBAiTiHJq3aQ6XF4Zl0DtBv7oL4pZzEzGBlwXuadFXXCFS7IGmgq3wtOD1wE5nW
         O0ryuvwmns6lVDqh6HeZ8Ui1WbFD4OVxFa6x9KIq8VeAkXEEZ+mspDQFyCpkrMBkxhIF
         lrJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Rqd2cD4vVW3+Sd74LDrUld398jWG+6bIAKO8kOtCuxY=;
        b=FzJhLPNfDBTtBxrBjlJp6rK1oJC9hmqsIkmcznZGdhPPxxwnq9BCqMAExm+VtAxgyU
         /O4dOGuZRh5nFG1wg78n3onEs+cHs7KuFaYAHNA4pfSYV2vTn0OOPLhGgixhEp/5xveW
         8nk1z6vscqVkSGDemDdvg7DepXVDWKnFbMoE5rc39UjEH1MLJ35rfSOdRNA54K62RsDV
         iiRXB7Mgczl56mhjFNQAUD+E9LZaA6Am6sK6AaESC2EFr1/h8IL2zQhkEY5XeaWhtoMR
         une58LD6uVvdj/2jnLtRn3oxDYQcWB6Kw4CXEL6Lvf3ELduSN5gfveG/KCsWUbJDJdLu
         Lc+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PExlh3Tr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m1si8676974pgg.380.2019.05.06.22.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:37:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PExlh3Tr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6E58F20B7C;
	Tue,  7 May 2019 05:37:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207434;
	bh=6eYzvdpLkadmW6qPSEIkeXBgut3LdJXI5R40mz6omm4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PExlh3TrlTqxCOGgxK3rjg7w4u8pvC6bRXwaGj4e5g6zREG2es1Gy9uIa0IqmSFht
	 UlFr/TSGFO5r4VQ9Om4bgcmO1KrxVWUTGkrLOrp9+zhek7nEOa+/Mj+CChYycgx2B6
	 mOK3BcV0elOxHGjTSc4Rw5eN8RNtUTxCqYsFHbJ0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 41/81] mm: fix inactive list balancing between NUMA nodes and cgroups
Date: Tue,  7 May 2019 01:35:12 -0400
Message-Id: <20190507053554.30848-41-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053554.30848-1-sashal@kernel.org>
References: <20190507053554.30848-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Johannes Weiner <hannes@cmpxchg.org>

[ Upstream commit 3b991208b897f52507168374033771a984b947b1 ]

During !CONFIG_CGROUP reclaim, we expand the inactive list size if it's
thrashing on the node that is about to be reclaimed.  But when cgroups
are enabled, we suddenly ignore the node scope and use the cgroup scope
only.  The result is that pressure bleeds between NUMA nodes depending
on whether cgroups are merely compiled into Linux.  This behavioral
difference is unexpected and undesirable.

When the refault adaptivity of the inactive list was first introduced,
there were no statistics at the lruvec level - the intersection of node
and memcg - so it was better than nothing.

But now that we have that infrastructure, use lruvec_page_state() to
make the list balancing decision always NUMA aware.

[hannes@cmpxchg.org: fix bisection hole]
  Link: http://lkml.kernel.org/r/20190417155241.GB23013@cmpxchg.org
Link: http://lkml.kernel.org/r/20190412144438.2645-1-hannes@cmpxchg.org
Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmscan.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3830066018c1..ee545d1e9894 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2190,7 +2190,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct mem_cgroup *memcg,
 				 struct scan_control *sc, bool actual_reclaim)
 {
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
@@ -2211,16 +2210,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
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
@@ -2241,12 +2236,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
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
@@ -2346,7 +2339,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * anonymous pages on the LRU in eligible zones.
 			 * Otherwise, the small LRU gets thrashed.
 			 */
-			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
+			if (!inactive_list_is_low(lruvec, false, sc, false) &&
 			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
 					>> sc->priority) {
 				scan_balance = SCAN_ANON;
@@ -2364,7 +2357,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
+	if (!inactive_list_is_low(lruvec, true, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2517,7 +2510,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, memcg, sc);
+							    lruvec, sc);
 			}
 		}
 
@@ -2584,7 +2577,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+	if (inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2982,12 +2975,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
-		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-		else
-			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
@@ -3344,7 +3333,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.20.1

