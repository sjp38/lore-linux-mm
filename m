Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F1BFC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7FCB216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dbK+UaqM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7FCB216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD9A76B029B; Fri, 10 May 2019 09:50:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C64D76B029D; Fri, 10 May 2019 09:50:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B559B6B029F; Fri, 10 May 2019 09:50:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEC96B029D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z7so4125625pgc.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=BeA/9uKT7ZXEzolLTDukLC/4yDvl5hwqa5LtLKqZMsw=;
        b=N+6PLZ7x1MAqxLhRmBc23yAZ5EbAsV1GpDi7aJ9J8Jlw1d8O6rgNUmxwhmmYgRwVTg
         7VxNWgUSSKrzBpKCwrp0RNroY2ogNMy3W1g5W43Oja4HeKKxC8IbnkhEF0ig7OP9cbby
         T8xrxbCAaXlVyFzUm4OnQPsa+eQCImz/1aCHbRjEer4u70OVt1LYaIAun8Tb/CeaHesg
         ao26fbIsoSmbiyTCumMhNJWEzDvfTJ8FIjJTkqcl5WevbXzEFSGOEa5MTN+LTRbFYTjq
         BvTMRS3zqTK3voZUw2dvgGaqkyB0GV3QbRdXa2eRsoR6fMBLU9sD7WYpRZuEQ0CiFAN/
         EEoA==
X-Gm-Message-State: APjAAAUiFoaJnCQZzmFd3jP9VL/ndcXfVuwd6jIJBppbefeAQJuFqt2K
	NhdXB/IzCPGuqmjNH6G/VnWxUqvnh+eOxoRIFx0bNZcP94rooRXtRIudvf5ocg9H1nMN3AiGSOB
	0yg4CqwlH4EvB+JzWjNbzd57fUJCx0/p8k8XXjOqkiOutTdNwZKPj+dnETmbzwQBr4A==
X-Received: by 2002:a62:520b:: with SMTP id g11mr13750435pfb.215.1557496244962;
        Fri, 10 May 2019 06:50:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHaP8kxFqevXfWXmOv6jecFCTqlGqb24uQoTU6f8l6hr6Q2g1yLMFz2UOw24qnWeCDjb9I
X-Received: by 2002:a62:520b:: with SMTP id g11mr13750271pfb.215.1557496243622;
        Fri, 10 May 2019 06:50:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496243; cv=none;
        d=google.com; s=arc-20160816;
        b=Fbl3m3I7agFukygkwOWuaZ+eObWGPmAITef8lP9pCg/KCc+TzppbDpggfOB1hibDVl
         m+x4nOBO9gJ5rRD345vfo/2/e+zBFjoPC7ytRF4NQ1pVrPxnCAu+xgn9KYRJgrkuuxcx
         zZWyX+mYo6Tjv08e/Tj8S5DxqfTqWpgrzib+5g4wZCGHNMFyzcio560zumijeXR++ynJ
         k3u6mHm2rgda6ZjecxOgiY0bxgbX/NDQSvdcsRHgxZ2r08WeUEM6oR4Fyfb4D4a1G+kS
         FtGGpS/wTWFyCHAH6eBuRNS/ZCGuFaByA6q72cgt2EAc7NjNfoiE/rW5UvIrUJPYk1nD
         1YBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=BeA/9uKT7ZXEzolLTDukLC/4yDvl5hwqa5LtLKqZMsw=;
        b=dRrfdPlRo5/98qgDs+xNGhdosEweXUS2NQn6Y8TPQ3v/MikWHtRtR9fWZJ6gFG0W5r
         RvWYKNLc1EvkrYQOsxwVySZIBtQEVii3oq0MzB4sV5h6zu4HyZdqte+Z/AWrXzMo8Ywe
         pLqi8hnuciAmmL7VDfUeWVb8lG99Lt5LlZ/OrzR/gEw1EbNre9mQqopxvbk49ZO/nvIc
         py+GiybRsMZKYzd6AryhvGuaZby+x20fhVTWGfOYcyfLnzdy8Nb+e+yQRAHjqtXA+2+8
         BfPrsLc73tAp09KvjTlxNJNIFUm+aXcebYAW8TMiBJ2PU73NwCBiG2d0d1He+v2W+5Li
         KkmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dbK+UaqM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c12si6611803pgq.390.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=dbK+UaqM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BeA/9uKT7ZXEzolLTDukLC/4yDvl5hwqa5LtLKqZMsw=; b=dbK+UaqME/uL/sfYyaa/qoTEC
	Kq5uwi5/gq18XhBUgg8brDI9r44sa+/jOWyGlLXZ+ZqyD1Hmo29EvvXAJoRRSUcNX8v+FSbeQ1Q8y
	QWtTxtDMbf9jHawPu+EMcjueJ90UosyEtsv6jSoYoExU+BM4eaALyLnrenoKZb4MbwT0URS9KVaEL
	fy1GjnhtLdVFJapMA7JIr7QioJzibEFJSn+liNkrCI3bXdgHHjfoRAxhrrTM6kRYcWRQ5lfivnNfF
	FOs9AS6i/WwjDjEIHfUT5yJ8Uhd4/qPYedLVcY34bZLslVMp9FMhFcDi3K+x3Cq5KvcBmbdvRUO/Q
	l17fukKxw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v8-0004UZ-48; Fri, 10 May 2019 13:50:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 13/15] mm: Pass order to prepare_alloc_pages in GFP flags
Date: Fri, 10 May 2019 06:50:36 -0700
Message-Id: <20190510135038.17129-14-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190510135038.17129-1-willy@infradead.org>
References: <20190510135038.17129-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Also pass the order to should_fail_alloc_page() in the GFP flags,
which only used the order when calling prepare_alloc_pages().

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/page_alloc.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d4ac38780e44..d457dfa8a0ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3262,8 +3262,9 @@ static int __init setup_fail_page_alloc(char *str)
 }
 __setup("fail_page_alloc=", setup_fail_page_alloc);
 
-static bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static bool __should_fail_alloc_page(gfp_t gfp_mask)
 {
+	unsigned int order = gfp_order(gfp_mask);
 	if (order < fail_page_alloc.min_order)
 		return false;
 	if (gfp_mask & __GFP_NOFAIL)
@@ -3302,16 +3303,16 @@ late_initcall(fail_page_alloc_debugfs);
 
 #else /* CONFIG_FAIL_PAGE_ALLOC */
 
-static inline bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static inline bool __should_fail_alloc_page(gfp_t gfp_mask)
 {
 	return false;
 }
 
 #endif /* CONFIG_FAIL_PAGE_ALLOC */
 
-static noinline bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static noinline bool should_fail_alloc_page(gfp_t gfp_mask)
 {
-	return __should_fail_alloc_page(gfp_mask, order);
+	return __should_fail_alloc_page(gfp_mask);
 }
 ALLOW_ERROR_INJECTION(should_fail_alloc_page, TRUE);
 
@@ -4569,7 +4570,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
+static inline bool prepare_alloc_pages(gfp_t gfp_mask,
 		int preferred_nid, nodemask_t *nodemask,
 		struct alloc_context *ac, gfp_t *alloc_mask,
 		unsigned int *alloc_flags)
@@ -4592,7 +4593,7 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
-	if (should_fail_alloc_page(gfp_mask, order))
+	if (should_fail_alloc_page(gfp_mask))
 		return false;
 
 	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
@@ -4639,7 +4640,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 
 	gfp_mask &= gfp_allowed_mask;
 	alloc_mask = gfp_mask;
-	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
+	if (!prepare_alloc_pages(gfp_mask, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
 		return NULL;
 
 	finalise_ac(gfp_mask, &ac);
-- 
2.20.1

