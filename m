Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ABC2C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FF13216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eLBEkc3T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FF13216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33C926B029A; Fri, 10 May 2019 09:50:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF766B029B; Fri, 10 May 2019 09:50:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A5EC6B029C; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4C4D6B0293
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id k22so4147288pfg.18
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=PqulRINVpvsq2J604tj2thFYFHwDrhSryMKnJlWbiV8=;
        b=PLnnroCZMEfgYi5xdFLiDEWBl4LwQ2BWeKUnGMr8tQnnaFGa3LhSjQEXSD0wvEKQfR
         t13Qwkhkip0NPnTekC5TLaaI5HXoxt2EFqSuI0Yh+DWBn0KV1/RBCoGWilDQyH4PqH0y
         AutVvxFwws9KjgYTxDeRLejHJO4dbhgWy09QZLCsjxIXnit9iiLEbfL01VnT2n4mOFTP
         mU5Axi9/gVc5xaEtiCUsPsJYyHg3rNARTmcR1j3peJdDxHI4igpY0pU2GF/tTusAPs/+
         xoJU30IKeTLqc6uvAGtcwAcxegi4zk6JC/k5ZhdtLutVOEThQFZmvIGMoeJ7ORmtNlkl
         tbJQ==
X-Gm-Message-State: APjAAAVDZAFISZa6rji27E3KL2n/cMyoQQHjdQe64EwiCoWJRZNzg1bf
	W1QRqtM9MEyj2damjfTOq/zdVUo8hLAr2SarLPD9dMYb3TgBu6fKVEripgEDxXu6i8xyFnPYNSH
	CbzVEE7NRvHIUikC5EDtz8I4pSncKSEAQ4UYAW5b6RFOjv4MFUZhhQecE7MrtCEDaBQ==
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr13520159pgs.373.1557496244136;
        Fri, 10 May 2019 06:50:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDaV736uVhEim2EF+nDN7ewiAKJgcSSQgaeT0o56E0AIQkmg7J+1v7Xme5M0h8Ob4JXKUJ
X-Received: by 2002:a63:2c4a:: with SMTP id s71mr13520006pgs.373.1557496242764;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496242; cv=none;
        d=google.com; s=arc-20160816;
        b=0BaRB6M+vGJtaqKcWcLM2SC4pMxkyK+oa9bkps6kfrzmxR1wR2IVUEXdgxZGBGjtiM
         3zKDFubp///o8Vb/BTUxVni6TiBozFuYouXGjN8z4Mcn7lOHNjwq55/QyI9eCk5s52qM
         /c03KMBYEA02LQ8C9JqWB+dpux+BpQ6lcDZoilWbqABLyAWR8BlGjCJurREeaWPwAvgM
         fFFI88Jm2PhwqG46zKwYyCAofXCfWl951pyVn5T0C+N6lwF/TezQy7BqFpben5/EaY8T
         K0sd1HuJrpILoy1nerDprL8dnJZiC9+z3X6twoXFIG/GnD+1Hn4ILf+sh4fngcUmURLP
         0o8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=PqulRINVpvsq2J604tj2thFYFHwDrhSryMKnJlWbiV8=;
        b=YizQhgNdI9Ge17V2xRrfN4KAlDCiv0+Fq6WkPJytuUPK/YvBJRhgG6/SBxV+3D5H+C
         I0al4J0DfTzzkMvk8pfEQHYjxNnLNFVRtolY4v5l+rJvhZ5CUBBB6ALfQq1/mla4OQw6
         iXzYQsVsQXTqbUeKMKmC2o95cxvO/5w5x6efqR22t8kD90mKB5Z8t3zgZRHPNItiVjeI
         wBDOml1QqgZ2FBhg6ksLRVKFKc+pZTVk/bMeAMUKxI2a1ara2uJhcUM5FVYJEx3VRpua
         IJsjGYOoII/CxsA8xhK8LhUDpyjEHIq2HSUQaYDuu/Beg5IjaztKNblfhLiBbys8YtMv
         PR/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eLBEkc3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n6si7522973pgv.458.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=eLBEkc3T;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PqulRINVpvsq2J604tj2thFYFHwDrhSryMKnJlWbiV8=; b=eLBEkc3TahbbwK0JMhMPmPMuY
	YWnor/eQWzRz2NVYT12CCftldd4Ej2zlU7KkJ+9pO5edcsV3PFo2JKcGDvRSdidVlMbJkfazQI+0v
	BNlbmv373XE3eXpMx/FcHI9bXAsPtbS0RyKz3UC49QBVEqUekbv+YgcmpsYT03cXpyIAVYTeSd69H
	4/ZdSY19MlwQVorwHTozvJcQ+qc4UxjwO/zdaSr8I/4WtIX8/Ro6gGVIT81sCz4zMcKotkEbqYj4p
	R4l5tzLQgJ3TqwjhvHq200738DmKs6+tfk6tGuMKyq6ODe81dmmRAATLdlCv2bDqSryjoAkQb28xH
	nqjk8t/tw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v8-0004Ue-8w; Fri, 10 May 2019 13:50:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 14/15] mm: Pass order to try_to_free_pages in GFP flags
Date: Fri, 10 May 2019 06:50:37 -0700
Message-Id: <20190510135038.17129-15-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Also remove the order argument from __perform_reclaim() and
__alloc_pages_direct_reclaim() which only passed the argument down.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/swap.h          |  2 +-
 include/trace/events/vmscan.h | 20 +++++++++-----------
 mm/page_alloc.c               | 15 ++++++---------
 mm/vmscan.c                   | 13 ++++++-------
 4 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..029737fec38b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -348,7 +348,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 
 /* linux/mm/vmscan.c */
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
-extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+extern unsigned long try_to_free_pages(struct zonelist *zonelist,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a5ab2973e8dc..a6b1b20333b4 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -100,45 +100,43 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 
 DECLARE_EVENT_CLASS(mm_vmscan_direct_reclaim_begin_template,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags),
+	TP_ARGS(gfp_flags),
 
 	TP_STRUCT__entry(
-		__field(	int,	order		)
 		__field(	gfp_t,	gfp_flags	)
 	),
 
 	TP_fast_assign(
-		__entry->order		= order;
 		__entry->gfp_flags	= gfp_flags;
 	),
 
 	TP_printk("order=%d gfp_flags=%s",
-		__entry->order,
+		gfp_order(__entry->gfp_flags),
 		show_gfp_flags(__entry->gfp_flags))
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_direct_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(gfp_flags)
 );
 
 #ifdef CONFIG_MEMCG
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(gfp_flags)
 );
 
 DEFINE_EVENT(mm_vmscan_direct_reclaim_begin_template, mm_vmscan_memcg_softlimit_reclaim_begin,
 
-	TP_PROTO(int order, gfp_t gfp_flags),
+	TP_PROTO(gfp_t gfp_flags),
 
-	TP_ARGS(order, gfp_flags)
+	TP_ARGS(gfp_flags)
 );
 #endif /* CONFIG_MEMCG */
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d457dfa8a0ac..29daaf4ae4fb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4024,9 +4024,7 @@ EXPORT_SYMBOL_GPL(fs_reclaim_release);
 #endif
 
 /* Perform direct synchronous page reclaim */
-static int
-__perform_reclaim(gfp_t gfp_mask, unsigned int order,
-					const struct alloc_context *ac)
+static int __perform_reclaim(gfp_t gfp_mask, const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -4043,8 +4041,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
-								ac->nodemask);
+	progress = try_to_free_pages(ac->zonelist, gfp_mask, ac->nodemask);
 
 	current->reclaim_state = NULL;
 	memalloc_noreclaim_restore(noreclaim_flag);
@@ -4058,14 +4055,14 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
-		unsigned int alloc_flags, const struct alloc_context *ac,
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int alloc_flags,
+		const struct alloc_context *ac,
 		unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
 
-	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
+	*did_some_progress = __perform_reclaim(gfp_mask, ac);
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
@@ -4458,7 +4455,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
+	page = __alloc_pages_direct_reclaim(gfp_mask, alloc_flags, ac,
 							&did_some_progress);
 	if (page)
 		goto got_pg;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d9c3e873eca6..e4d4d9c1d7a9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3182,15 +3182,15 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	return false;
 }
 
-unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+unsigned long try_to_free_pages(struct zonelist *zonelist, gfp_t gfp_mask,
+		nodemask_t *nodemask)
 {
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.gfp_mask = current_gfp_context(gfp_mask),
 		.reclaim_idx = gfp_zone(gfp_mask),
-		.order = order,
+		.order = gfp_order(gfp_mask),
 		.nodemask = nodemask,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
@@ -3215,7 +3215,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
-	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
+	trace_mm_vmscan_direct_reclaim_begin(sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -3244,8 +3244,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.gfp_mask);
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3294,7 +3293,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
+	trace_mm_vmscan_memcg_reclaim_begin(sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
-- 
2.20.1

