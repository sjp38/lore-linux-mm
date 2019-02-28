Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB89C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C98D218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="x12aerec"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C98D218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 627A28E0007; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D9B98E0001; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A2038E0007; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0412C8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d64so13889748ywa.17
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=GSofEg/7r3733pp3UNY0zt5FRcCRJ328CONqofNgUyiu+JG0FlB81J3LCn2T9AuO0d
         9CM2412jdIi1b1E7VAvPOQYLApodrxlZX1eeHesNTTDSZ+MRMaxx3kzDEykKLN8Jf2g0
         +qZJiHEV98/Bsl3lGhgOVWbv+1fu6VAMwx0QAIyGnppLhwMN8Wr8ExkJR8wcPXsoSBhz
         QGWGJOWZs07PqOI7zldIQuBjLu1PNlHNw+OMJ2EyUumo1JxheVAo7wp6wwZCPNmyw9eY
         ZFZioqJcEIHCxSWnPh9Cxj+mRbEcfS9KC8lCdnfVjLtRAmQU4nNKszoU2FchaLULoOSj
         Uf3w==
X-Gm-Message-State: AHQUAubfC9CPwQeTcwFrJLj0/v6aYsC4i/JzM/YQkHPXTTPG04po642d
	1WTKXRCTzhqzhsNIDqOrI5LruEMZzEHdTINgoOxy7bUAqPApm7DuMCm9A/zeoHS7SAJPooc81qN
	55zi+0z0KdBmveFFfYKgMWzYJcd2xRvIURmF360JgoYTXwSSW69gSlMrgBQJqFOMvLRDuPdbVzn
	U6LC6+UplQhdr55donIp+HIJr7sVb57M/2nLiFL+z1j3ZcAiU8L0PBu9l82x27jT2URIzUaYVbv
	EKWrhOa5caRr1iRM3eoSFgCbg+g9gsgkmujg5Jmx4DwdsxvUNMQhIOuazqAWfmWEH+NqDBT6HH9
	UcZdlt2NRkBHp89VLKR9HUXKlmfTIKuqWBhfEAvCTzXZZ0uCitjOlhQwO3BCcyFs/iAyoRGUX0q
	s
X-Received: by 2002:a0d:d98e:: with SMTP id b136mr6362618ywe.485.1551371448716;
        Thu, 28 Feb 2019 08:30:48 -0800 (PST)
X-Received: by 2002:a0d:d98e:: with SMTP id b136mr6362538ywe.485.1551371447661;
        Thu, 28 Feb 2019 08:30:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371447; cv=none;
        d=google.com; s=arc-20160816;
        b=VpPmzUpugWXvMYEm+HfV9U2Xoer+4rnNZKXdIKJmAHwyXQQBZ34s3rVi13LFZnL8uv
         JDBVHqNjyApBeVR4vP9O+obDiNmaUyPgN37f19cJ3CUglJDrIvQBq6B26liI2sER/I5S
         Z4ILK7qDePip3N8NLkjIDFnJI1sCAU4r/UMiPh65vE0prItSwfSk9Z1ZhllV7iP8m2Zb
         NxmOqFfIPiBokgPwLz7A+xDGcny8AGmVRW211mZj41IhSAryfq2GAP286A+eITZu/CZ2
         xenX/vDHf/UMxE17/KpDWsGGwGDrjIhY8ApIFJLumbXyByHis+SsRubULVZPWpfSN6NQ
         A3SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=wCBN3EvQpPqVVW4mqCZNSN65D/W1nfm5aIR+HZfh1qfeTVX6yDhvlowg9dt0ZUwAib
         CUxJCVQrKDCqZxn2C/jRPEnC/NQtsE8CT4quG3Rq2KUYvyH8ms4noG2/C4aJyHafdz8X
         GhRgLCXMUAI0hjrrGpMeCVa2V3FMGU0oE1Dhwlz71uusEXuRoKTz94s+jerUDe0qcXU1
         us8QHn7bmNMTDmuEQUpHP6vRlJNlZPjuPlujVq3eJDS/EfpJYj+50Ag1TsPbHEyHUNHl
         vwrN8SKV586L/BCTIGg3x4Xqb9I5lQ9RQmB/eX3g5+yAaMfbJ0bF3xpsUjWNStzNUkEl
         lZJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=x12aerec;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u31sor3668177ywh.74.2019.02.28.08.30.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:47 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=x12aerec;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=x12aerecO+G2Qi8DCMF2xSNAdXP6sBfvJQFyXJRVQZzC59w0Li6KJcU2pImtwibxdU
         jf1dSlSsVetoPQrYlc7ADovX4Z9ahMPqkLwaA10S6bLaHVLA0w9hGYX7L83qslBlCUmp
         yQyO2YHvfGJbtpNNJp4Jt1rHJvl3Pr7QmtLNylzcYOSY+44ehQkUBWAdlWVslNo6ftDg
         LJM1d+pyrMy9ErHzmV1drh8f3anJphXWFWrNeCPNNAOiRhhiNIVgIEMRO0MCXqL/o+wv
         tTccoxWk0I9ROwOYBJAZIuuupIO4nyL1sRD41Cfz+2izzbY8daIyH18gtRXknFFHxHoI
         6Gpg==
X-Google-Smtp-Source: AHgI3IbZrnHxcUzT2L+UlPG1PKqQVD2XJnyr/V/FAeHt3brx1OJMu+HCyA0UNInzg65K9j7PHaJQ2Q==
X-Received: by 2002:a0d:d3c3:: with SMTP id v186mr6413209ywd.15.1551371446919;
        Thu, 28 Feb 2019 08:30:46 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id e21sm1132279ywe.77.2019.02.28.08.30.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:46 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 4/6] mm: memcontrol: push down mem_cgroup_node_nr_lru_pages()
Date: Thu, 28 Feb 2019 11:30:18 -0500
Message-Id: <20190228163020.24100-5-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190228163020.24100-1-hannes@cmpxchg.org>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_node_nr_lru_pages() is just a convenience wrapper around
lruvec_page_state() that takes bitmasks of lru indexes and aggregates
the counts for those.

Replace callsites where the bitmask is simple enough with direct
lruvec_page_state() calls.

This removes the last extern user of mem_cgroup_node_nr_lru_pages(),
so make that function private again, too.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 10 ----------
 mm/memcontrol.c            | 10 +++++++---
 mm/workingset.c            |  5 +++--
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5050d281f67d..57029eefd225 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -514,9 +514,6 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		int zid, int nr_pages);
 
-unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-					   int nid, unsigned int lru_mask);
-
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
@@ -979,13 +976,6 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 	return 0;
 }
 
-static inline unsigned long
-mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-			     int nid, unsigned int lru_mask)
-{
-	return 0;
-}
-
 static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 {
 	return 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e702b67cde41..ad6214b3d20b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -725,7 +725,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->vmstats_percpu->nr_page_events, nr_pages);
 }
 
-unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask)
 {
 	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
@@ -1430,11 +1430,15 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
+	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+
+	if (lruvec_page_state(lruvec, NR_INACTIVE_FILE) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
+	if (lruvec_page_state(lruvec, NR_INACTIVE_ANON) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_ANON))
 		return true;
 	return false;
 
diff --git a/mm/workingset.c b/mm/workingset.c
index dcb994f2acc2..dbc333a21254 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -427,10 +427,11 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 #ifdef CONFIG_MEMCG
 	if (sc->memcg) {
 		struct lruvec *lruvec;
+		int i;
 
-		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
-						     LRU_ALL);
 		lruvec = mem_cgroup_lruvec(NODE_DATA(sc->nid), sc->memcg);
+		for (pages = 0, i = 0; i < NR_LRU_LISTS; i++)
+			pages += lruvec_page_state(lruvec, NR_LRU_BASE + i);
 		pages += lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
 		pages += lruvec_page_state(lruvec, NR_SLAB_UNRECLAIMABLE);
 	} else
-- 
2.20.1

