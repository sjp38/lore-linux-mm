Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2B3AC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C4A2084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:15:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="PLL+ZIOo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C4A2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3F776B000D; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFDBA6B0010; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A05DB6B026A; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9236B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:15:22 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k13so8973421qtc.23
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vYujH9ql2WWkJyoNj4zC7fKkltAGztxNOgJanRlBf/k=;
        b=IXRYW1TTQcaMTM/XLKPH4aLMZitRIjmzF5uBEp96qd3wKm2UDsns+Wa6O6nKouizGz
         nRKurN4Uh+6VJlHjVA/+GJHcZUsQ4Ur2CI/eKqdETPppiIpJi8+WoY97/5Rfc5aEc8YC
         0MppP28ci1iMeNLECNIrRakAOgJEEpXaMt+CB6JR/bDQ/UzSnM9/opxsWJIlzBJ6gNVQ
         +/zuVYHgp2WQv8Jur+NCZFIiF6KuYYW8XMdgnIPnQZDm+5CeWKgyG2Zg3T3i6c7U4AiU
         snc0pXG8HehKjw+KT8nps5p6fey+6kyOP1r8M8xwkI1ox400mFRi7q7ENpqgisfzohdt
         W/Iw==
X-Gm-Message-State: APjAAAXbbt1wMFnspp/bRhqOVk1qDjc5hX2ZteZA0CIFEGRSj51JfzzU
	xs20fMfz9C+jFQeFDo0Hr+KMM5TJ6+X1ylR6X8CkOGUd2yZVs7uTlwVUayZsHEvSU78cpTAIVzF
	7XK5vwjvFae9hjGAvyOaNVCQ1iaT9JLBDED6LOosJUjKlZCA7BXd+/xoknPq1Po5HOg==
X-Received: by 2002:a05:620a:1438:: with SMTP id k24mr3904276qkj.165.1555082122248;
        Fri, 12 Apr 2019 08:15:22 -0700 (PDT)
X-Received: by 2002:a05:620a:1438:: with SMTP id k24mr3904162qkj.165.1555082120929;
        Fri, 12 Apr 2019 08:15:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082120; cv=none;
        d=google.com; s=arc-20160816;
        b=Eg8mGCNYiHKBDx8Y5IY9KlxniPJLLqyS2iOmPuaBZhEcWqKKHKR59+x8jahU8pu5tr
         nUS26NgFkDDq6HvuHbvfLRQ8hrh5VTynmgAXRTK/gU5v1Epj4OxFFTBGlC+G5IA1r7+t
         aIQx/uybWEjVSvIO4tQjneq1sq8iLGuG0ZL62KHW/02t45HYGOedtkn6xKZT2LVFre1c
         5+T4A5EAQw6CcHL32n0KqYrlGsJTed7MxNfaXDncMtn4acZBKBvBRELzoaW8etqeIETn
         mpwI8Srq0rIYBuPNEc0iXgXh11YkLdq44RGdMPEYKzYC2o9HKepAIpQfoIjnDTkXXvKw
         Nclw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vYujH9ql2WWkJyoNj4zC7fKkltAGztxNOgJanRlBf/k=;
        b=N6VA15+9KQpxc0k/dq3dSsaUU4KPTlL5dbExv43GEx6WEI7DEudIyV/XNO0bwk9la3
         k32xAQsqaFvGH3eJKnTYuV0SPZFs7L6lTpaEXKTYFF7BYajeEOspRXy2LHjwvfTFXjY1
         +vextGLEsNUS3+bZ27xG9A3wngFYopW13PR1FonaQIQMy4kbXIXqgmIMTvra9xIyIFD5
         FhuZJby8I/ykxXL7Hd+2gNA0ITMeA4zGgu8yWxwiaZ/PQtAr8sQYmfrscu9Kai+wvdCw
         qbxLVe8p8Jf2lhvu3IA7qMl45/tGI1zB7eLA6A/D0esvB5Y2oScoJHBJnJVqkvYhi9Tx
         GvFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PLL+ZIOo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor41871962qvr.51.2019.04.12.08.15.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:15:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=PLL+ZIOo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vYujH9ql2WWkJyoNj4zC7fKkltAGztxNOgJanRlBf/k=;
        b=PLL+ZIOovXrfX1wJ1YTZ6L+zDg1hjgBGzySqLyYncg5msMIkS5Ic2UAIQ46BtEetQO
         2XD1BaVaNpjylQD6A7WTKHPwz6kWz7EDemV/kgcnsT0tUXbK1G+pfy9D8VfT9BS1p66X
         FD+ZaoDb3EuL6yBgT+YGLTA0U/Ix4bUhu75FAuHncIA6p8Zn7C5w7sBs31iQR+VHOBh3
         6w3Nwx/SWTeMwaWvCyes6vQT3oV2sIvvzepgVFgTQxMwwXnTSq5V0ZUiEk5u5KTl6H/y
         AWYf4x/nbpo3NE1CAMpnujWd0d+NTo5PGRlmnVbBOXIc518OwHEjkW4S5aGtFyhlxoM3
         tNfA==
X-Google-Smtp-Source: APXvYqxULIHF7gHec2iqEMR9IBNg7HbcJMq/Fq+YT6crJISDP6QO1qnolhGkKP+j0EvGTftVvC70YQ==
X-Received: by 2002:a0c:d483:: with SMTP id u3mr46384167qvh.54.1555082117403;
        Fri, 12 Apr 2019 08:15:17 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id e6sm21040344qtr.56.2019.04.12.08.15.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 08:15:16 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 1/4] mm: memcontrol: make cgroup stats and events query API explicitly local
Date: Fri, 12 Apr 2019 11:15:04 -0400
Message-Id: <20190412151507.2769-2-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190412151507.2769-1-hannes@cmpxchg.org>
References: <20190412151507.2769-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

memcg_page_state(), lruvec_page_state(), memcg_sum_events() are
currently returning the state of the local memcg or lruvec, not the
recursive state.

In practice there is a demand for both versions, although the callers
that want the recursive counts currently sum them up by hand.

Per default, cgroups are considered recursive entities and generally
we expect more users of the recursive counters, with the local counts
being special cases. To reflect that in the name, add a _local suffix
to the current implementations.

The following patch will re-incarnate these functions with recursive
semantics, but with an O(1) implementation.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 16 +++++++--------
 mm/memcontrol.c            | 40 ++++++++++++++++++++------------------
 mm/vmscan.c                |  4 ++--
 mm/workingset.c            |  7 ++++---
 4 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3823cb335b60..139be7d44c29 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -569,8 +569,8 @@ void unlock_page_memcg(struct page *page);
  * idx can be of type enum memcg_stat_item or node_stat_item.
  * Keep in sync with memcg_exact_page_state().
  */
-static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
-					     int idx)
+static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
+						   int idx)
 {
 	long x = atomic_long_read(&memcg->vmstats[idx]);
 #ifdef CONFIG_SMP
@@ -639,8 +639,8 @@ static inline void mod_memcg_page_state(struct page *page,
 		mod_memcg_state(page->mem_cgroup, idx, val);
 }
 
-static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
-					      enum node_stat_item idx)
+static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
+						    enum node_stat_item idx)
 {
 	struct mem_cgroup_per_node *pn;
 	long x;
@@ -1043,8 +1043,8 @@ static inline void mem_cgroup_print_oom_group(struct mem_cgroup *memcg)
 {
 }
 
-static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
-					     int idx)
+static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
+						   int idx)
 {
 	return 0;
 }
@@ -1073,8 +1073,8 @@ static inline void mod_memcg_page_state(struct page *page,
 {
 }
 
-static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
-					      enum node_stat_item idx)
+static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
+						    enum node_stat_item idx)
 {
 	return node_page_state(lruvec_pgdat(lruvec), idx);
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cd03b1181f7f..109608b8091f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -687,8 +687,8 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 	return mz;
 }
 
-static unsigned long memcg_sum_events(struct mem_cgroup *memcg,
-				      int event)
+static unsigned long memcg_events_local(struct mem_cgroup *memcg,
+					int event)
 {
 	return atomic_long_read(&memcg->vmevents[event]);
 }
@@ -1325,12 +1325,14 @@ void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
 				continue;
 			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(memcg_page_state(iter, memcg1_stats[i])));
+				K(memcg_page_state_local(iter,
+							 memcg1_stats[i])));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
 			pr_cont(" %s:%luKB", mem_cgroup_lru_names[i],
-				K(memcg_page_state(iter, NR_LRU_BASE + i)));
+				K(memcg_page_state_local(iter,
+							 NR_LRU_BASE + i)));
 
 		pr_cont("\n");
 	}
@@ -1401,13 +1403,13 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 {
 	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
 
-	if (lruvec_page_state(lruvec, NR_INACTIVE_FILE) ||
-	    lruvec_page_state(lruvec, NR_ACTIVE_FILE))
+	if (lruvec_page_state_local(lruvec, NR_INACTIVE_FILE) ||
+	    lruvec_page_state_local(lruvec, NR_ACTIVE_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (lruvec_page_state(lruvec, NR_INACTIVE_ANON) ||
-	    lruvec_page_state(lruvec, NR_ACTIVE_ANON))
+	if (lruvec_page_state_local(lruvec, NR_INACTIVE_ANON) ||
+	    lruvec_page_state_local(lruvec, NR_ACTIVE_ANON))
 		return true;
 	return false;
 
@@ -2976,16 +2978,16 @@ static void accumulate_vmstats(struct mem_cgroup *memcg,
 
 	for_each_mem_cgroup_tree(mi, memcg) {
 		for (i = 0; i < acc->vmstats_size; i++)
-			acc->vmstats[i] += memcg_page_state(mi,
+			acc->vmstats[i] += memcg_page_state_local(mi,
 				acc->vmstats_array ? acc->vmstats_array[i] : i);
 
 		for (i = 0; i < acc->vmevents_size; i++)
-			acc->vmevents[i] += memcg_sum_events(mi,
+			acc->vmevents[i] += memcg_events_local(mi,
 				acc->vmevents_array
 				? acc->vmevents_array[i] : i);
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
-			acc->lru_pages[i] += memcg_page_state(mi,
+			acc->lru_pages[i] += memcg_page_state_local(mi,
 							      NR_LRU_BASE + i);
 	}
 }
@@ -2998,10 +3000,10 @@ static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 		struct mem_cgroup *iter;
 
 		for_each_mem_cgroup_tree(iter, memcg) {
-			val += memcg_page_state(iter, MEMCG_CACHE);
-			val += memcg_page_state(iter, MEMCG_RSS);
+			val += memcg_page_state_local(iter, MEMCG_CACHE);
+			val += memcg_page_state_local(iter, MEMCG_RSS);
 			if (swap)
-				val += memcg_page_state(iter, MEMCG_SWAP);
+				val += memcg_page_state_local(iter, MEMCG_SWAP);
 		}
 	} else {
 		if (!swap)
@@ -3343,7 +3345,7 @@ static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	for_each_lru(lru) {
 		if (!(BIT(lru) & lru_mask))
 			continue;
-		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
+		nr += lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
 	}
 	return nr;
 }
@@ -3357,7 +3359,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 	for_each_lru(lru) {
 		if (!(BIT(lru) & lru_mask))
 			continue;
-		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+		nr += memcg_page_state_local(memcg, NR_LRU_BASE + lru);
 	}
 	return nr;
 }
@@ -3442,17 +3444,17 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		seq_printf(m, "%s %lu\n", memcg1_stat_names[i],
-			   memcg_page_state(memcg, memcg1_stats[i]) *
+			   memcg_page_state_local(memcg, memcg1_stats[i]) *
 			   PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
 		seq_printf(m, "%s %lu\n", memcg1_event_names[i],
-			   memcg_sum_events(memcg, memcg1_events[i]));
+			   memcg_events_local(memcg, memcg1_events[i]));
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
-			   memcg_page_state(memcg, NR_LRU_BASE + i) *
+			   memcg_page_state_local(memcg, NR_LRU_BASE + i) *
 			   PAGE_SIZE);
 
 	/* Hierarchical information */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c9f8afe61ae3..6e99a8b9b2ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -346,7 +346,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 	int zid;
 
 	if (!mem_cgroup_disabled())
-		lru_size = lruvec_page_state(lruvec, NR_LRU_BASE + lru);
+		lru_size = lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
 	else
 		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 
@@ -2163,7 +2163,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * is being established. Disable active list protection to get
 	 * rid of the stale workingset quickly.
 	 */
-	refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
+	refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
 	if (file && actual_reclaim && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
diff --git a/mm/workingset.c b/mm/workingset.c
index 6419baebd306..e0b4edcb88c8 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -430,9 +430,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 
 		lruvec = mem_cgroup_lruvec(NODE_DATA(sc->nid), sc->memcg);
 		for (pages = 0, i = 0; i < NR_LRU_LISTS; i++)
-			pages += lruvec_page_state(lruvec, NR_LRU_BASE + i);
-		pages += lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
-		pages += lruvec_page_state(lruvec, NR_SLAB_UNRECLAIMABLE);
+			pages += lruvec_page_state_local(lruvec,
+							 NR_LRU_BASE + i);
+		pages += lruvec_page_state_local(lruvec, NR_SLAB_RECLAIMABLE);
+		pages += lruvec_page_state_local(lruvec, NR_SLAB_UNRECLAIMABLE);
 	} else
 #endif
 		pages = node_present_pages(sc->nid);
-- 
2.21.0

