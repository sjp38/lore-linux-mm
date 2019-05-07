Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D00A9C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77AF5206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fLPKkGN+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77AF5206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 920F06B0269; Tue,  7 May 2019 00:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 233DD6B026B; Tue,  7 May 2019 00:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1DDC6B000D; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59E256B000C
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a17so4335410pls.5
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=ph57y3psFSboTB6oeGLFzcczorSnDzHodEP/gLy6/C4=;
        b=uJu3WMy1P665mcwh6JduTKBnk11lY/NDG23lNMN2928huDX3WzGmelUIlAWuixUVKY
         RDpy5JaQ5cMP++67rrlQ0GbTFRvKD05FS2E02F8AjYnF6lFcK11/Kp3rLKhrqeVQZUPl
         phxqBmZUCiN1jARrZ2/4iknfSLrKW6bmQ7se89wI9IkLEDbP8a4Dhh8sdigG2Gx+dxP6
         BGma5YQas4HqCfdQFxdXLaJViY57hnziw03amD4kOsW5xYXmSN/MJ95TcPR78khCRMJi
         tsJmZ+C/SrMl4/va8pb5pF0I1bXGohOtIPAUMSxdiUr0D1x9ExhVgxiU/UPpsJXrkMTZ
         72GQ==
X-Gm-Message-State: APjAAAVaFFlTIRm8iUeC41ClKXHdWhxpKmn5awEKDlxyMeER9S6RMG0A
	IH8pmCn2kGM/cPUTM56szkliHdT28R/hfVYvjrXPCKusdzbKBtfHPBPOBH0Q0QX3I4sIBHMy4UL
	KBqgPiPHBfgq0m5iHnTFx0+bCxAaGcbdPRb0ueKxxKMiClp2m1xWTbglYoGrbVEbtog==
X-Received: by 2002:a62:ac0c:: with SMTP id v12mr38067240pfe.59.1557201974598;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoGjRH1K3QdoCdGWpm6zHiMQPlWozjjX1IvUznKVzu4CyR6guC2qz60KEGAc56WdPIkKSv
X-Received: by 2002:a62:ac0c:: with SMTP id v12mr38067124pfe.59.1557201973080;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=ItEC+YIbXAOw77s1ZRePPgD3DgLmiHlqy3oachuYUvJVb3mszn8Nf+dHuqBq2Q4qHF
         xHVNjzhW3WHFuQ/SY9psteyg3VWGdRMb1nWiPZ02BxRMWYSsUAy6nxmu5AS+2vlSSwIY
         qvmYZtZ64Cv1GMwfiznYBR/oSDFougD+hqGt6WeKeynMC+ycT4kKd8kOYXHaWGLxY0K7
         dwiTv6l1l1ubkOM48gIRpF9pP1XzCDB2UvBP+AuVKVAM+0pxKhFA+hTY/+4bG13OgkkH
         onmdAaGtuaQXglrB67kQDCD9hcVF7KXDoXW3Z3lB5BdUUY/5l9MbrtlgKM2hut8V0JwH
         zVVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=ph57y3psFSboTB6oeGLFzcczorSnDzHodEP/gLy6/C4=;
        b=A8hou7BgJLA4VZqr4r5jtLLQjoDZy/470JgKQEWh2Ng1NTPRGmmYhsXXLzxrgJokru
         nhmNHD4vMvNLvCIPxDj/LYwDqTqqzG6ArLy1XB3s4TOYppZ+t4VpdfMazgPwrPFtnqvL
         qB9T5Y0ocH0DrYSr2U1ES2SEMdGO7JM3O6XhPx3E/YFOPlAafZFionwsjQphRoSiD117
         3T3eDe6D8SHUKUSyvBEKl3UCfgnD+Hv29O1AKKjuXRWOIes3G73jWkfXpeKNN/VX1VLC
         p9rJbZGqu95AWogTkBKPCBcg8SacKuawdr4W1l30Y2pahdoJOEem/4euxZddROY6rKIp
         VWqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fLPKkGN+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p1si4599197plr.220.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fLPKkGN+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ph57y3psFSboTB6oeGLFzcczorSnDzHodEP/gLy6/C4=; b=fLPKkGN+xJhpjM3fEvIdk+D3v
	6C0JyeelpBRRqTGVjCRmHT5unuq/gbYy1s0jTv8S8MWhct4Ur2S4zRt7+tr5v3rFVGLv8qKsw3Vzx
	bYicahz/WFcTJ5aiVtZeLSuHvbT9Av77LOB6C7wo4HTq+4oG9+/QC68IZo4humKA28wDQQEC1L17h
	jGBJ2MMTeAsd738rU16XRR8At9Lhq1rLiwXQfpgNbekMZF3txZM3fpfjODwCsD9+tcVi9x0GPKFWG
	lBzbTaFTpwQkkwMtAwp4Yq4WqGhaao2y90Zny04vfoU0+uH8hzyP2fnZi9ZNiT4PREaZuuhVhnxSY
	yZGEnkDRw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMq-0005ij-JP; Tue, 07 May 2019 04:06:12 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 10/11] mm: Pass order to try_to_free_pages in GFP flags
Date: Mon,  6 May 2019 21:06:08 -0700
Message-Id: <20190507040609.21746-11-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
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
index 0aa882a4e870..fd8b468570c8 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -106,45 +106,43 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 
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
index 94ad4727206e..5ac2cbb105c3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4011,9 +4011,7 @@ EXPORT_SYMBOL_GPL(fs_reclaim_release);
 #endif
 
 /* Perform direct synchronous page reclaim */
-static int
-__perform_reclaim(gfp_t gfp_mask, unsigned int order,
-					const struct alloc_context *ac)
+static int __perform_reclaim(gfp_t gfp_mask, const struct alloc_context *ac)
 {
 	struct reclaim_state reclaim_state;
 	int progress;
@@ -4030,8 +4028,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
-								ac->nodemask);
+	progress = try_to_free_pages(ac->zonelist, gfp_mask, ac->nodemask);
 
 	current->reclaim_state = NULL;
 	memalloc_noreclaim_restore(noreclaim_flag);
@@ -4045,14 +4042,14 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 
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
 
@@ -4445,7 +4442,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
+	page = __alloc_pages_direct_reclaim(gfp_mask, alloc_flags, ac,
 							&did_some_progress);
 	if (page)
 		goto got_pg;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 836b28913bd7..5d465bdaf225 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3206,15 +3206,15 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
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
@@ -3239,7 +3239,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
-	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
+	trace_mm_vmscan_direct_reclaim_begin(sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
@@ -3268,8 +3268,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
-						      sc.gfp_mask);
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.gfp_mask);
 
 	/*
 	 * NOTE: Although we can get the priority field, using it
@@ -3318,7 +3317,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = &NODE_DATA(nid)->node_zonelists[ZONELIST_FALLBACK];
 
-	trace_mm_vmscan_memcg_reclaim_begin(0, sc.gfp_mask);
+	trace_mm_vmscan_memcg_reclaim_begin(sc.gfp_mask);
 
 	psi_memstall_enter(&pflags);
 	noreclaim_flag = memalloc_noreclaim_save();
-- 
2.20.1

