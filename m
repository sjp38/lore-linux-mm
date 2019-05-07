Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D54F5C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91387206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ue5UACfc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91387206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2BAA6B000E; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA8946B0266; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C4B66B026C; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 280C66B0010
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so9344649pfn.8
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=wGzNr9K0w/HZEu84/iMrFXSJjD26OCxJ1guluG3054U=;
        b=szHP1C8FBl4WW+XWohuF7eqaGDroqVwwXH4kFNLTjrF6sSKrRH+tWAkjKXduYXyfUu
         2p6BJi/GDvWjPRLcdq0m97oT8BzaVOB3PORdAiE0iCydLmJTly1stlDmHXnO+AM49mdW
         UVMN+NVOFWBfxG5xv0Dh++xxdZp6KUmijQvPTXxiTbjkDPqpkbfVk4wqpIqgxf2a7kzP
         UXtypPfGMGmEstNBi328//TZn/FuVgSDMxUB3/zG/gPAjTo2ErIpmi4PiNALhPZ0YKf0
         94Dt6COUP2253R/xS76/78+8fCKwNa6qzbkLkDEmf2tmCXRqTpfrSyk+JEJBGTpx/XVV
         mkZw==
X-Gm-Message-State: APjAAAVuJoi/2XGKdhP0iHJxQMyKd6uuZoiTwUk1j5KaTscamQwJamC+
	ri6zGW8wvNGYz87iRf4wceaHPxsrkLsq0Fmb6gQMDdVjOuZBD/s4cKoF4IwkrNAzghsnpYAwJwU
	8s1mmL2zAhittN83csCCxlsla2KEfhhInRsQTn6fQwlwqM0LfHUg5b7cjkQCm1R3GTA==
X-Received: by 2002:a63:d756:: with SMTP id w22mr9045421pgi.382.1557201974832;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeI8BMkvaR+XLdhnVkBPPklnFg5P3b+AxZu4D9PjekhjlOA/9R82IRMRJ+04sDz1BjVXp8
X-Received: by 2002:a63:d756:: with SMTP id w22mr9045290pgi.382.1557201973295;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=BPxiGeHBCxEWvpEUSwPTJ+87RzIV2w49fxfqfI0TmnxhAhJzqvSOQcKkWJ8qL8TWou
         VQELEAO+hxLco2R8AjUIV5nOtcul38DY8lSlPjLwYBVCjzTO8VtRVWn1A3NNcLN0St5F
         Q24VGImovQSeO7hIWH9UlLtDK/4yWmM43+cU2Ag7rJoqZux97bMoJOhgob6oXvao+dhh
         plsS2silsjl606iBCijeoL7S2KtEBA5wfkitRV2+K/597P8JM7ElGvIAigcpJwz7t8OK
         AHkrkB/UBuG3GqLkvpDfP5wvg+6iaTAEUvqJDVkmBdvZw0K1BFEc+BWyoLIR+j4LUaNf
         tKhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=wGzNr9K0w/HZEu84/iMrFXSJjD26OCxJ1guluG3054U=;
        b=vvoGIpadqLD01Cjy27jgKYzhihcOK6E/br4m1Y3kRL1zLZldKUmOK4bb/ZsWsPx7MB
         jhNMAGLjoBgGr5OIOlwnMwIdCr2+8EwP+X3kPNVEURZt+GLSNqi9zdUErpc5+fAnYtSh
         VSKrV6NtjXQcbqqgEQRyK7g2URzLDMQGPiLy3Hc8hMzLRIP+Ycc3ZELLECZRGqSKFd89
         ar44kKdbxga5Ht+gafIebT7zEsbEuDWzCVUDrFFQkO9y00fLSX0W77ZoGwymnIB6zxs7
         MpyfI9Nx8H6OB0IShNEoDNZpGgVP4u3vSr6uI0DganOqWRFoujRxQ5+FPJxoCwwatABp
         6hvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ue5UACfc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f20si16498259pgj.278.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ue5UACfc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=wGzNr9K0w/HZEu84/iMrFXSJjD26OCxJ1guluG3054U=; b=ue5UACfcKVyG7b7w4n22JBdSi
	DsK9deqmRWyhM3PEBBnYalTSu1RqDOBS7nyNySxs30vqLk+jIGPZhIWneANyhKoVZrwaOc7hIVvyT
	krfi/cbIdkVX3rxFlfKFTSA4lNuvcj985OU41zh1ThXmGWEyUC6llFwIdLxM6esw+zkgLgeduq7V2
	iukFlqfzZ/c3uJuuuFxVZZahjShQxb7Pl76ATe9HPUKzpWdqFiVek+x/Iv7+YzFyUAIcg93BWZKys
	U653/8fX3gdT96EFYt3TWC1vWwx2T9CsHl864uHD8C+UZvCRzt3IfVr2RfMne6ifQ14iaoGQMqkhu
	pJC4gORAA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMq-0005iO-3n; Tue, 07 May 2019 04:06:12 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 07/11] mm: Pass order to get_page_from_freelist in GFP flags
Date: Mon,  6 May 2019 21:06:05 -0700
Message-Id: <20190507040609.21746-8-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
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
index 4705d0e7cf6f..cf71547be903 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3482,13 +3482,14 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
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
@@ -3684,15 +3685,13 @@ __alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
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
@@ -3730,7 +3729,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * allocation which will never fail due to oom_lock already held.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+				      ~__GFP_DIRECT_RECLAIM,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
@@ -3831,7 +3830,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	/* Try get a page from the freelist if available */
 	if (!page)
-		page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+		page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -4058,7 +4057,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -4363,7 +4362,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * The adjusted alloc_flags might result in immediate success, so try
 	 * that first
 	 */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -4433,7 +4432,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -4640,7 +4639,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 	alloc_flags |= alloc_flags_nofragment(ac.preferred_zoneref->zone, gfp_mask);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask, alloc_flags, &ac);
 	if (likely(page))
 		goto out;
 
-- 
2.20.1

