Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3EDAC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56A9420842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="pR8Us5zo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56A9420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC6D98E0011; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFC438E000C; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AFCB8E0013; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49C1F8E0011
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:52 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id r67so7090549ywd.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=l2JnsU4wfZhGx/VZIsJbUUnCYbKxQBbC5/5oLGTTJml7zLLWG9psquSctp5CbRjGsl
         9g2MIbWK5kSWwb/y1NPmxcrRz+gM+lFDOcXQla6mAwJ7FOdhxpkg5mb/jPpT3/ZEbn/Q
         ZEHn6j0VLJxetxjmO9/davStwI853QhAwaaSSvcJVO6NpprUcGlcuCcS1bN/3qdmv3DZ
         cuSRueMPzY9ZD6AgSrzSiCJBcLXVCkH1pZZG50rOeylgzIpbP4OXMWz327bmJVM5lU+p
         HxWAlqb5wtZt9o7MYrvF2Q7mRuXncwZPeEANTEEx8bVvUwyan38TlKJKH2fRMlQZRcPC
         k/pw==
X-Gm-Message-State: AHQUAuYhbcjq+RWwDgAKb8mWSnvkGwicQthWVgBOj+17KuziZS4lQ9sm
	GURwI4U1awZB3RA/t/IedT4MOc0cEJBaICkvVXBo9woGUsFaZbRwSKbm7cDrhsmi/HUzdYt/q8A
	fYjiw24A+rEJDPbzHdzw6GTuYaA+P0m/k+hdnEyv4nbyba4jbsoH5FhwV/rcYHWID7+DyLSGV8h
	mscNgmZDBVqv0w/chvWURIMwic6TGe9sagLzQ6STnSgKaICM9x+qdmcvfDz6UEvgzM8L+2cCa9H
	4WpeCshEXS+FeQW3V1kAICALc7hwwZ8Hkzm1cxuqzjW+SCVVcZ4MrNrkWcUo1LpDgegf4ON0sQI
	x/x7XLpkAEiSYfxP176a6le8E9VfC0u1b425fS2RcBesb9LVQuVKM2h54s4O7nSNd/s45pWn0Qi
	x
X-Received: by 2002:a25:abc2:: with SMTP id v60mr9298162ybi.65.1551125812007;
        Mon, 25 Feb 2019 12:16:52 -0800 (PST)
X-Received: by 2002:a25:abc2:: with SMTP id v60mr9298108ybi.65.1551125811203;
        Mon, 25 Feb 2019 12:16:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125811; cv=none;
        d=google.com; s=arc-20160816;
        b=mUaZ41CLK4ySGOBHI8g4v5XDyQNw7oRToDJE8RMCcWae7vb/q0u7reAPV/iqY5IQNr
         kJSRzFJP+p3XSlYiczODBYxWHVpsqsDOHy0ujKme40NjzUlpw5Tm3OmubY/cPVb38aQf
         PtTY+39ru569bp3q1Amuphzdkl0ILW0YtfCUlyksbEk8n4RQAo47wp/RymioQSiZQn7c
         yjDmBVx5rWjOqgq6E96ze96x1xTrFbYBNsd1+6Lqsqyx22pgWLPX1Bq9mUOs6uvnzuqF
         ZMab3E3tWzqe8wY0CbwZHrBSvCM9o8IzsJHaVNawsmQcVmXhNAkbe1wEhmAWbYjMAKVx
         8ptQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=op22rMnmMrx7tg5yvH6tMWAnIxGeQIBfqAd3RmGGQItNRvhkS5+qDnk/qn80OsByRY
         89hpDcKgUg1sHY3+cDF4RY95i5u60H7As+BZLO6SAU4ZqPN3bBbGRRLGARGKPQUyGDPC
         rSDykoKVYd7+dnHSKrBKkvsB7CUIazDDOFnpASkRYA08vNx42wWrVHdpFBovhpmTXaX9
         K3JxlBZPuOH6qDgnXR/1GUsYom0VNgCVyOIFG/Zwezyf9B07pExw1Tfki/SZCcy89YW7
         gvWfzQkR2hNTC+CYvOzDW9V+xLsIQ20L6DcbR8VNS0VO2UaNsj9xgwrXDUh1pJAbn4wG
         +WLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=pR8Us5zo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e186sor2878218yba.97.2019.02.25.12.16.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:49 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=pR8Us5zo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=+fTCozRbLMGgETAnd6XOzTuCoFNGxxYSxApGaKudEvQ=;
        b=pR8Us5zofqdHOL4z7jHKcjDL0WMwNUIA+4YsVBz/vOIhQUeoq76MDYAD5oviLzLJfn
         2D1C9zAIeLeSEEhP53FwAZHe9NM/Epdv936v7im5qIt1jgE6S+7Px6v1XbNEYtlN89M1
         44/2b8uxRICmk8ggo80YoUieuN/doUEheNw2g68ujbcRRM00q42HE8mnuKxJWMIajJAH
         V82x9OJZZe2kz/yCugc2C3VyZVvcOn7n71J1f+PRkpjX5g8gH2pze5Cp6Pl3mJh1aIfC
         vcQyVmCUvG+dpoV5lCRUKVlTdWS0my4SAcuGGp+td8VifO8dgLiOgpR4fO62HOkMrV1n
         ixUQ==
X-Google-Smtp-Source: AHgI3IYquf0P7kdz6fMvgtKH/Y6f8yrqS+E09Wo566O2FGLUSSk3jjAv5YLqPHwUAIlmveFazoeurA==
X-Received: by 2002:a25:7284:: with SMTP id n126mr16346072ybc.504.1551125808763;
        Mon, 25 Feb 2019 12:16:48 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id v4sm3734174ywb.98.2019.02.25.12.16.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:48 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 4/6] mm: memcontrol: push down mem_cgroup_node_nr_lru_pages()
Date: Mon, 25 Feb 2019 15:16:33 -0500
Message-Id: <20190225201635.4648-5-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225201635.4648-1-hannes@cmpxchg.org>
References: <20190225201635.4648-1-hannes@cmpxchg.org>
Reply-To: "[PATCH 0/6]"@kvack.org, "mm:memcontrol:clean"@kvack.org,
	up@kvack.org, the@kvack.org, LRU@kvack.org, counts@kvack.org,
	tracking@kvack.org
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

