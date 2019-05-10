Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65C43C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B022216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Oj0RDGM2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B022216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E79D6B0298; Fri, 10 May 2019 09:50:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6496D6B029B; Fri, 10 May 2019 09:50:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A1876B029D; Fri, 10 May 2019 09:50:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0A906B0298
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g89so3737960plb.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=VdAkE2CMlufia+8ESx14YyAFjGv8nNJgH1kN9Pr0oN4=;
        b=q3vnKygM69OkjjuWKraXFNesAX80tg9yq9PUonF6mveJsN7qQzumPOYWn51rqzcDqy
         2FtGYnD/dDYgqir85B0tMXQnvlJxpVt2TTSHBnORHxXfZOcZKeBzM/5VjgTyiby/OY6C
         Bq7uIH8UsZCt5VF4yhNW+mJ5/jUVG/S5BBKS+MkTuybkRMzWUmsvEY4EAEqUV/VYsyfu
         8WEZkx73tDHc+DSuHGAeaauBt5+by+6WmU9XttoyITqWe6K0xcKy+0O6SQkQxxwTmReD
         pevPQ4AIIL6sfnibYA6vRBt53X066PW+/fbSBRFN1itu2PSlTd1/zciOwXZs9ZenjjoG
         w0zQ==
X-Gm-Message-State: APjAAAW+oF3ENB4z9m5WaxAsTZmRb+1qhJBxZGagHoleumtLr5oFCFFt
	yGcFeapkIetyRRkhO/jM5cRxSGaHeAKVz8S0QgLkbe9SBbkb4wOXP6qwRbhFAF8yVFcJDouAPPA
	y3qLBpBhQwtoEqIkjR05EZ1Je67aDG93iQVRerGTirxEs5WubTIesUXRJu/rPjl6zmA==
X-Received: by 2002:a65:4105:: with SMTP id w5mr13675247pgp.260.1557496244643;
        Fri, 10 May 2019 06:50:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0RxIF356tj1b7k6ao3/E8s3LzBBl1YW6wB6OMeVViKJlJ1ZHEsWjbvH7U4Ce5WAld8WYR
X-Received: by 2002:a65:4105:: with SMTP id w5mr13675056pgp.260.1557496242890;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496242; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+K/I/pXvTZP9bEuExMuzhwAN97GNb/TEoY4d3DPvqtIC2fKAv2aLBVVNFTrRDzzXy
         RE/ZePPpg/kVAdLfuyei6DCMZ3t1t06CO7IpsNs6+vj1jXXQeVC4greZYW6g0PtRaawN
         Y2igHfb3Jap6cnlhEhNpmpG2fhxmvr0X6B/+je81kRHU2QZX+KldAoyQ+BoNLCWkKYAL
         y2cZid4kDkWXpN4qXLujytvGbo0Exq11BuO0Jf2KWv/m9aTqnbfggFBGeK55hiuyEjIx
         8lHpO3nAmNIlD+r2MSsiyi6gy7pMJdfabq/lW1JBNUSYZh70ng66z2lTjvra6z4/E7fB
         L/KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=VdAkE2CMlufia+8ESx14YyAFjGv8nNJgH1kN9Pr0oN4=;
        b=DqKvEPonHzkIgdxcPA87stgwHmp4PiAiwxB/K133KPd7Ru0Hy2jnQYCHDvNMkW6t34
         qoEjGYu9+WFVL5bMmq1VlolwXTupYIQ5P0uV8YqGHTWMvzg4N5dFn0CTwBoc5xU7FOug
         xzQGExCVbB2cX1la/Ov9SWN3iFNQnXjJsuV6f6V3MmxmvDXezYsfsKefO7JAd4YpuPrX
         9zsr2RnvsFez2BqmyE1e5EmxyffAUu69q/G5jhgGE6vXfx9OPdxYWOEHw0MRIN3T+/gV
         QtHNHo30t5lp+exDnXQwogkMr1VQddldh/7RrGRVpqCD5zpvG+sgDtWv3caguwYpAMwA
         AutQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Oj0RDGM2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r23si48220pgj.234.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Oj0RDGM2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=VdAkE2CMlufia+8ESx14YyAFjGv8nNJgH1kN9Pr0oN4=; b=Oj0RDGM2TCsKpsQH+wafOr2z7
	6A+z19XHmIwZaWhMk3k9/VU8eqrj672l7oLtDzQ8KkA6w6Ez0VcAzfGo9fOwkeifd79ZVccyvGhaB
	PutKpb4l0o14WAtudrjC/g26nJFUdBGUH2WlOxzMKiJm+Eqf5TEGau6SJMUoeGMTpOEupVlCRWzUZ
	V5p7ZyQVXLEuNt55Oh4Fh728TDyNVrgdvOV9zk/xngcnSjNp3SCqDteg6YXqyas61PS0mQTezDzIL
	9VvYcS5WX1AzT+Jm2WwVoJQJbgyz/3QnYRwBKLXVWThx0ZXGyTYURMZl79OwkhGWHLA7ypc5mr1J/
	wWUB/ySFg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v8-0004Uk-Dn; Fri, 10 May 2019 13:50:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 15/15] mm: Pass order to node_reclaim() in GFP flags
Date: Fri, 10 May 2019 06:50:38 -0700
Message-Id: <20190510135038.17129-16-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/trace/events/vmscan.h |  8 +++-----
 mm/internal.h                 |  5 ++---
 mm/page_alloc.c               |  2 +-
 mm/vmscan.c                   | 13 ++++++-------
 4 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a6b1b20333b4..2714d9ef54e6 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -460,25 +460,23 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
 
 TRACE_EVENT(mm_vmscan_node_reclaim_begin,
 
-	TP_PROTO(int nid, int order, gfp_t gfp_flags),
+	TP_PROTO(int nid, gfp_t gfp_flags),
 
-	TP_ARGS(nid, order, gfp_flags),
+	TP_ARGS(nid, gfp_flags),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(int, order)
 		__field(gfp_t, gfp_flags)
 	),
 
 	TP_fast_assign(
 		__entry->nid = nid;
-		__entry->order = order;
 		__entry->gfp_flags = gfp_flags;
 	),
 
 	TP_printk("nid=%d order=%d gfp_flags=%s",
 		__entry->nid,
-		__entry->order,
+		gfp_order(__entry->gfp_flags),
 		show_gfp_flags(__entry->gfp_flags))
 );
 
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b95166..353cefdc3f34 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -457,10 +457,9 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 #define NODE_RECLAIM_SUCCESS	1
 
 #ifdef CONFIG_NUMA
-extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
+extern int node_reclaim(struct pglist_data *, gfp_t);
 #else
-static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
-				unsigned int order)
+static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask)
 {
 	return NODE_RECLAIM_NOSCAN;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 29daaf4ae4fb..5365ee2e8c0b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3595,7 +3595,7 @@ get_page_from_freelist(gfp_t gfp_mask, int alloc_flags,
 			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
 
-			ret = node_reclaim(zone->zone_pgdat, gfp_mask, order);
+			ret = node_reclaim(zone->zone_pgdat, gfp_mask);
 			switch (ret) {
 			case NODE_RECLAIM_NOSCAN:
 				/* did not scan */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e4d4d9c1d7a9..b7f141de9814 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4124,17 +4124,17 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 /*
  * Try to free up some pages from this node through reclaim.
  */
-static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
+static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask)
 {
 	/* Minimum pages needed in order to stay on node */
-	const unsigned long nr_pages = 1 << order;
+	const unsigned long nr_pages = 1UL << gfp_order(gfp_mask);
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = current_gfp_context(gfp_mask),
-		.order = order,
+		.order = gfp_order(gfp_mask),
 		.priority = NODE_RECLAIM_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
@@ -4142,8 +4142,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
-	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
-					   sc.gfp_mask);
+	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, sc.gfp_mask);
 
 	cond_resched();
 	fs_reclaim_acquire(sc.gfp_mask);
@@ -4177,7 +4176,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
+int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask)
 {
 	int ret;
 
@@ -4213,7 +4212,7 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	if (test_and_set_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags))
 		return NODE_RECLAIM_NOSCAN;
 
-	ret = __node_reclaim(pgdat, gfp_mask, order);
+	ret = __node_reclaim(pgdat, gfp_mask);
 	clear_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags);
 
 	if (!ret)
-- 
2.20.1

