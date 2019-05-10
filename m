Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBE8EC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FA5A216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SdxTTHMH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FA5A216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E26FC6B0297; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7B216B029A; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AAC66B0296; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8EBE6B0295
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c7so4159704pfp.14
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=sF+bxGTHBBT93BL/DvuLBhBopFxumPieKkRcP90cXYE=;
        b=B25jRK0OcxXcY1G39oD09nPc6Q+aP9odUT8RhpWrfdzjT7Wq4N3210rNdXk/+Z5+nE
         Dwec9udjWD7IktoXn6aD4g3inbitai73V5FcoBJkWB0JYZRVqSH94AM4VbJOyashqiSr
         QNM3fhQd5SxeEoahVOGnZo6QZ2QC9a5tJr8q57GjtHzCyDzIM91JQYQlftlb0bVmg1fu
         3/iehSLV9/wnYbOKrnbIZZPaTPAY8vhkb9iswbtuTtQPc+ogdsUtAMvPTcNf38/+MAt7
         YFW1ynSXkqspYCAE8+B1gYmuqS3Sxhf2z3ZesHXEaOmgC4I/L0l2LD/v5wvfWctRuEnD
         G8GQ==
X-Gm-Message-State: APjAAAWhVYdPK6i4vKM+xyochhZIr2LOLT0DjKNexBytO0R+T/DxKUsV
	uHa8Pbnj8FpBLK7KVlnAfNKtWEAHQ4A87qSme+8MmNJj6+Ko8+qpbWh5CcJBSz8GxW43fMwQnxf
	FRuMuyT6aj1zuKdpzRa2J3o9lZHeFo1rpV8Xbv0acpiR+6/elN3Sl8em06IH4A3I8Bw==
X-Received: by 2002:a62:d44a:: with SMTP id u10mr13852313pfl.227.1557496243558;
        Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcXoxaUQiyCUZSBaPEHURPNBvtsH43wlcIIAVnpOe7Ht3WK9cOQgwNXJH8atvati9QN2uA
X-Received: by 2002:a62:d44a:: with SMTP id u10mr13852132pfl.227.1557496242290;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496242; cv=none;
        d=google.com; s=arc-20160816;
        b=iIIpLb9sKkwpIYHy803DdBrr06fJyNbuaAuRk8x3D3qOFhGX15dQuHgAX2NQxzm7i2
         5wb2fYZSGGEHD3tGfzBqI6J9sMq8OKI9c2f7Sd6/wX//UKnzBU8uvCvEKwv1c8C1w4Nm
         G5OvSN+GJnYI9JOz6Pp2LER49Qe3XMDJtozWQh3GJR4t7ENTwGvpuos9s2+u4vX/5+Lx
         4ccMNdR2wdIoDIBUVhp8h9IjesDrnlXL7G9gr7AffutFlhjfEtyNaqNGJ/ylWSlp+dq0
         3ypuvg7E2FzXPgbZgoOXy7IRiEIiirXlvUv31e/qbaQ9ALcTzcs7zGgzzjvqIepjOSkt
         /O4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=sF+bxGTHBBT93BL/DvuLBhBopFxumPieKkRcP90cXYE=;
        b=BmYADiy1NiKtFZb5yobBAUivU21peK15DxvIb7ikunOl3Pf5nNbWw9Sbqd7+SYZV5B
         sjZFgE7Xs+gywCZbiLApN6p9ulU6RDULiI19yRuk0AKanle70J2LRC25d50W4+Xk9+9i
         /W1TTFrOi2gy8RntNMgjeMWNP/eVZGZY8ZIP+kqLwsiqCs3UuFA0aMCKvk2nOftUk5DG
         p38/cCEDklDE40Dv3P9pBPUgXRVRkW1grqMeRgRbdCyhAt1FfE7S+D+GGDtbqioPB/zy
         zJq99ZSYAXyP2uEhTIy8TSbDteoNOc+cUY1MGlwIEGKWnwKiPgq1VSl6/otpSZ3svc8j
         qqrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SdxTTHMH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1si7857835pgx.176.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SdxTTHMH;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sF+bxGTHBBT93BL/DvuLBhBopFxumPieKkRcP90cXYE=; b=SdxTTHMHG3GpKrqFdl981JFSO
	Tw18atuShga8eoKgdB6WTv6oBwZ8FVssJ/JFM6sg5bo0ELlTk4qHYDRAoC9tzZY+hq9WXet4O5Ky8
	KU9S839uknvxe1H3Ih24KVUKbcIEoelDyHJQuaczKuXpcTQcvrmx3/TYkEWRIzmnW1yxCqDZG73J2
	qsLAbWVeiGeXlnOEJmGXXvO5VZJLdAMjL+U7A0pb+Y2ijoM2fIJj+ui883Yy19Qo302mraEG1t2Ed
	955iwPxBiowk2BuooQz5XYzDoa7GIIz6Y6VHXO/6KMYxBxWc6US88YnuYqMSKh3mgqGTSTSf9O+w+
	IxPO08DGQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004UM-QV; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 11/15] mm: Pass order to get_page_from_freelist in GFP flags
Date: Fri, 10 May 2019 06:50:34 -0700
Message-Id: <20190510135038.17129-12-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Matches the change to the __alloc_pages_nodemask API.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/page_alloc.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cff996289be..38211bc541a7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3500,13 +3500,14 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
-						const struct alloc_context *ac)
+get_page_from_freelist(gfp_t gfp_mask, int alloc_flags,
+			const struct alloc_context *ac)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
 	bool no_fallback;
+	unsigned int order = gfp_order(gfp_mask);
 
 retry:
 	/*
@@ -3702,15 +3703,13 @@ __alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	page = get_page_from_freelist(gfp_mask, order,
-			alloc_flags|ALLOC_CPUSET, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags|ALLOC_CPUSET, ac);
 	/*
 	 * fallback to ignore cpuset restriction if our nodes
 	 * are depleted
 	 */
 	if (!page)
-		page = get_page_from_freelist(gfp_mask, order,
-				alloc_flags, ac);
+		page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 
 	return page;
 }
@@ -3748,7 +3747,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * allocation which will never fail due to oom_lock already held.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+				      ~__GFP_DIRECT_RECLAIM,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
@@ -3844,7 +3843,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	/* Try get a page from the freelist if available */
 	if (!page)
-		page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+		page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -4071,7 +4070,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -4376,7 +4375,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * The adjusted alloc_flags might result in immediate success, so try
 	 * that first
 	 */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -4446,7 +4445,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -4653,7 +4652,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone, gfp_mask);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
 
-- 
2.20.1

