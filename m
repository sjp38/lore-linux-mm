Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E67AAC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A78E241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="DVH2GCKN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A78E241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6106B0269; Mon,  3 Jun 2019 17:08:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22EC46B0271; Mon,  3 Jun 2019 17:08:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A5686B0272; Mon,  3 Jun 2019 17:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBCA66B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o184so3890483pfg.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=z23PZhEFw+QhEt/mQOsZQQYtYHRN5d+bP7DeTd5XrzA=;
        b=MBj/xrLvM0pny7ZhDbkqAH8NnUkxFi3UOIuWFOTuhPeQN9SEkgxLJMKwitGQafPUBt
         hmzFNQZMjS7RU6GtC2hQBS5hVZ0XlRr9/9YqVMRWUyf0PhOISr+xKNFclrp0yMxg5k1V
         4goPfoyTYdFMGMUfbgaL79zetdsnNGJABvxYDTa+XPp3T/Et5E34qmFiYiX3GuvluD1n
         GxgxFGG+pQ6aC/Pw2w5C4pZ8RaiQXMgL1QBQ3oOROAIxoeRqp2pfprPhX/TgMZnSFK39
         LTI4fK8V1NmrYvJcSGVIThgA1bYvRoOWnEvGsl0e3tR/5O/s5gITtnwEEtT/GBEAUwvl
         AczQ==
X-Gm-Message-State: APjAAAUBHL6rUR2V7K8Sq8OTD0v81fDeVJg+jEGK9++qDvK2nR1HdcIs
	ZZsDddS8q9wpADPjzpPlUITyFwDDjCiedywNAg02OuawKH8pxobmF1W4DkofPLuy+Guu/csxa6F
	zkzghIsws1Kr3ccWndBnXMwoTNLXpcpObdVXbTmIuCODtZf0ytayOvRLLrRh5M2mKgQ==
X-Received: by 2002:a63:4147:: with SMTP id o68mr31264211pga.76.1559596109150;
        Mon, 03 Jun 2019 14:08:29 -0700 (PDT)
X-Received: by 2002:a63:4147:: with SMTP id o68mr31264050pga.76.1559596107640;
        Mon, 03 Jun 2019 14:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596107; cv=none;
        d=google.com; s=arc-20160816;
        b=0h/XknehBVEGkgE1xBDlkZETzZeolmaGXN9is17mWCj1QoZJ/Yk3EPGj2025CQnvG/
         UAmajrcymPg/bo4LW+pIO2HXhQQV0GcSNUVM0rbLT6xbvDD2/eX6Py+MRH5GMbDG0wAJ
         erYsjQiarXcnpwKX+f7fyChJEV8LgX67+lZrxQ1mfN//vbln1b8MkTt5Lg7/5KigYpGt
         W//eTSSQTuWIELHayZ/1Evw1jxkOR8ZnVh5RMxswGcx6MMqRfsGKA1/dXWFhpm51v+EE
         uY3TS4yWTE+evengZY2/4HvAC+L2AUZYCeczWXkjIvhUYFSIKR1sU2mKeKnEPqVY7RAy
         TpVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=z23PZhEFw+QhEt/mQOsZQQYtYHRN5d+bP7DeTd5XrzA=;
        b=kf9wYsyuh9IqgmG8nz2ngJ2uS1D+7M9Q1jqC+HfrxjLc85kppFxNQApf24w47HEGhF
         wETPEGbKNBnLfLYjvvpSsPO252KLAUAX94kLYYdU2Oh1kBSRmyBKd3c0uMiatal2IfAq
         JC6KmVFmy2jqIwHGbPfcME7plNlZG0GwaIDNFbr+2l7DAYr6MjNQRfBLtPcnRSu13FXx
         U1XMwpnTurPR0Jmr0wFsWfS/ccHEi5blWh+CfvtJ2mOYvLXsALzcJHjNGe8JYpfV8N7T
         w4IPB2mRkONLTXJw0viPY9gS1WkPkDGG6H4AJTNHYacK8xQ6sUj0ebdzf0S949+E3xaI
         PAiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=DVH2GCKN;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h8sor3564675pgv.31.2019.06.03.14.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=DVH2GCKN;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=z23PZhEFw+QhEt/mQOsZQQYtYHRN5d+bP7DeTd5XrzA=;
        b=DVH2GCKNrNgADjceKBBm6o8NfcLS2rdp3xbn242c7DdynX2bTZq4lklw8oXnSFQnsP
         NGyQM9FAa2/b8444R5NSB4X4p380FKi//ZWqYSF8qzZaECNMNRpbAybJZ2BM1iWaV+s3
         3eFr0kg1fA8ronXzk9Pr181m/Ny9gvc2kpgw9erAMN5iYNk2qxPccfp3hm+epjm3HBXt
         1bbGpvoMnBQUqho/8UxBBQGfussO1/i8lX0lnXrCrpNWBTzZQjUao2PJ+zbEwfsPvsbW
         URn6vyjMORUJY2XLzMBMrP5keu32Tll/EFKeFSibqGMVbJAeC06fgohHiwrA/2dgpz5v
         4obA==
X-Google-Smtp-Source: APXvYqwW2xQ5NzacN/EZXV09Xd6hmdDoAcI7Jqj6YbOTZQDIG92ILIAFvZ/468Og785TyGk0vKofnA==
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr27923212pgm.433.1559596106992;
        Mon, 03 Jun 2019 14:08:26 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id j15sm18799263pfn.187.2019.06.03.14.08.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:25 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 02/11] mm: clean up and clarify lruvec lookup procedure
Date: Mon,  3 Jun 2019 17:07:37 -0400
Message-Id: <20190603210746.15800-3-hannes@cmpxchg.org>
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

There is a per-memcg lruvec and a NUMA node lruvec. Which one is being
used is somewhat confusing right now, and it's easy to make mistakes -
especially when it comes to global reclaim.

How it works: when memory cgroups are enabled, we always use the
root_mem_cgroup's per-node lruvecs. When memory cgroups are not
compiled in or disabled at runtime, we use pgdat->lruvec.

Document that in a comment.

Due to the way the reclaim code is generalized, all lookups use the
mem_cgroup_lruvec() helper function, and nobody should have to find
the right lruvec manually right now. But to avoid future mistakes,
rename the pgdat->lruvec member to pgdat->__lruvec and delete the
convenience wrapper that suggests it's a commonly accessed member.

While in this area, swap the mem_cgroup_lruvec() argument order. The
name suggests a memcg operation, yet it takes a pgdat first and a
memcg second. I have to double take every time I call this. Fix that.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 26 +++++++++++++-------------
 include/linux/mmzone.h     | 15 ++++++++-------
 mm/memcontrol.c            |  6 +++---
 mm/page_alloc.c            |  2 +-
 mm/vmscan.c                |  6 +++---
 mm/workingset.c            |  8 ++++----
 6 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index fa1e8cb1b3e2..fc32cfaebf32 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -382,22 +382,22 @@ mem_cgroup_nodeinfo(struct mem_cgroup *memcg, int nid)
 }
 
 /**
- * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
- * @node: node of the wanted lruvec
+ * mem_cgroup_lruvec - get the lru list vector for a memcg & node
  * @memcg: memcg of the wanted lruvec
+ * @node: node of the wanted lruvec
  *
- * Returns the lru list vector holding pages for a given @node or a given
- * @memcg and @zone. This can be the node lruvec, if the memory controller
- * is disabled.
+ * Returns the lru list vector holding pages for a given @memcg &
+ * @node combination. This can be the node lruvec, if the memory
+ * controller is disabled.
  */
-static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
-				struct mem_cgroup *memcg)
+static inline struct lruvec *mem_cgroup_lruvec(struct mem_cgroup *memcg,
+					       struct pglist_data *pgdat)
 {
 	struct mem_cgroup_per_node *mz;
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = node_lruvec(pgdat);
+		lruvec = &pgdat->__lruvec;
 		goto out;
 	}
 
@@ -716,7 +716,7 @@ static inline void __mod_lruvec_page_state(struct page *page,
 		return;
 	}
 
-	lruvec = mem_cgroup_lruvec(pgdat, page->mem_cgroup);
+	lruvec = mem_cgroup_lruvec(page->mem_cgroup, pgdat);
 	__mod_lruvec_state(lruvec, idx, val);
 }
 
@@ -887,16 +887,16 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 {
 }
 
-static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
-				struct mem_cgroup *memcg)
+static inline struct lruvec *mem_cgroup_lruvec(struct mem_cgroup *memcg,
+					       struct pglist_data *pgdat)
 {
-	return node_lruvec(pgdat);
+	return &pgdat->__lruvec;
 }
 
 static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 						    struct pglist_data *pgdat)
 {
-	return &pgdat->lruvec;
+	return &pgdat->__lruvec;
 }
 
 static inline bool mm_match_cgroup(struct mm_struct *mm,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 427b79c39b3c..95d63a395f40 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -761,7 +761,13 @@ typedef struct pglist_data {
 #endif
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	struct lruvec		lruvec;
+
+	/*
+	 * NOTE: THIS IS UNUSED IF MEMCG IS ENABLED.
+	 *
+	 * Use mem_cgroup_lruvec() to look up lruvecs.
+	 */
+	struct lruvec		__lruvec;
 
 	unsigned long		flags;
 
@@ -784,11 +790,6 @@ typedef struct pglist_data {
 #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
 
-static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
-{
-	return &pgdat->lruvec;
-}
-
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
 {
 	return pgdat->node_start_pfn + pgdat->node_spanned_pages;
@@ -826,7 +827,7 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 #ifdef CONFIG_MEMCG
 	return lruvec->pgdat;
 #else
-	return container_of(lruvec, struct pglist_data, lruvec);
+	return container_of(lruvec, struct pglist_data, __lruvec);
 #endif
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c193aef3ba9e..6de8ca735ee2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1200,7 +1200,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = &pgdat->lruvec;
+		lruvec = &pgdat->__lruvec;
 		goto out;
 	}
 
@@ -1518,7 +1518,7 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
-	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, NODE_DATA(nid));
 
 	if (lruvec_page_state(lruvec, NR_INACTIVE_FILE) ||
 	    lruvec_page_state(lruvec, NR_ACTIVE_FILE))
@@ -3406,7 +3406,7 @@ static int mem_cgroup_move_charge_write(struct cgroup_subsys_state *css,
 static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask)
 {
-	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, NODE_DATA(nid));
 	unsigned long nr = 0;
 	enum lru_list lru;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a345418b548e..cd8e64e536f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6619,7 +6619,7 @@ static void __meminit pgdat_init_internals(struct pglist_data *pgdat)
 
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
-	lruvec_init(node_lruvec(pgdat));
+	lruvec_init(&pgdat->__lruvec);
 }
 
 static void __meminit zone_init_internals(struct zone *zone, enum zone_type idx, int nid,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f396424850aa..853be16ee5e2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2477,7 +2477,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memcg,
 			      struct scan_control *sc)
 {
-	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
+	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2988,7 +2988,7 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
-		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		lruvec = mem_cgroup_lruvec(memcg, pgdat);
 		refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
@@ -3351,7 +3351,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
 
 		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
diff --git a/mm/workingset.c b/mm/workingset.c
index e0b4edcb88c8..2aaa70bea99c 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -233,7 +233,7 @@ void *workingset_eviction(struct page *page)
 	VM_BUG_ON_PAGE(page_count(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	lruvec = mem_cgroup_lruvec(pgdat, memcg);
+	lruvec = mem_cgroup_lruvec(memcg, pgdat);
 	eviction = atomic_long_inc_return(&lruvec->inactive_age);
 	return pack_shadow(memcgid, pgdat, eviction, PageWorkingset(page));
 }
@@ -280,7 +280,7 @@ void workingset_refault(struct page *page, void *shadow)
 	memcg = mem_cgroup_from_id(memcgid);
 	if (!mem_cgroup_disabled() && !memcg)
 		goto out;
-	lruvec = mem_cgroup_lruvec(pgdat, memcg);
+	lruvec = mem_cgroup_lruvec(memcg, pgdat);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES);
 
@@ -345,7 +345,7 @@ void workingset_activation(struct page *page)
 	memcg = page_memcg_rcu(page);
 	if (!mem_cgroup_disabled() && !memcg)
 		goto out;
-	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+	lruvec = mem_cgroup_lruvec(memcg, page_pgdat(page));
 	atomic_long_inc(&lruvec->inactive_age);
 out:
 	rcu_read_unlock();
@@ -428,7 +428,7 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 		struct lruvec *lruvec;
 		int i;
 
-		lruvec = mem_cgroup_lruvec(NODE_DATA(sc->nid), sc->memcg);
+		lruvec = mem_cgroup_lruvec(sc->memcg, NODE_DATA(sc->nid));
 		for (pages = 0, i = 0; i < NR_LRU_LISTS; i++)
 			pages += lruvec_page_state_local(lruvec,
 							 NR_LRU_BASE + i);
-- 
2.21.0

