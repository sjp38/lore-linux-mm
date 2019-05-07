Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ECBDC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6007206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="du86YBBb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6007206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9FF56B026A; Tue,  7 May 2019 00:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B65D6B0266; Tue,  7 May 2019 00:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB50D6B026A; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1856B026B
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e128so9332532pfc.22
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=OxdSSHoGAqmrkmVLEptBFC1YPta48P8T/Z5/nTGxU7M=;
        b=GDfVxegiRuUfISOJoaTWUVVrEB0RIwfI36KtjCWHdtxpgmO2uQ0Qq+aPmzEVu9WtmM
         7w/M1KnJzGSZKahniF4g4A8j1+Mds3e8STkfW8mX4HAMZGjmp/DU94Tj6/Z9BANAwby8
         +fzRUPMH4yOZKMCkEbbPNINf3eBIAwzRpyVxR7rF5vrKh5rmws0Q+NrNi5oGZev9u0jr
         21o6NgW7wSNK0LT/sceUIaUcm8MJLLIyJ16vv69iI0tyRtB2MSoFeBSIDFkhDPExeMEe
         wCsd0HuFi50NxcRC5i3d8xagDIA4vkJ9FSfI79hU5zEoDK2scR5sLgYywLToeWfGYN5P
         VHbA==
X-Gm-Message-State: APjAAAUa7SsioGstRV5qU3OEYGD4/N+AKuhvAj7tJ9BSarCHG4d97mKm
	TkdKpuHJuFCVLoOP+lFpn+YyglxETpelwkBzNZd+/h+kHXjB3IucyMdb9sfwIVBzlTNyVt673py
	yTlMoMdKEPzoCXjwFmnyImi2plihSLBMRXoHFfI97m980D7pZP6iKBsLsqRzjIQP7/g==
X-Received: by 2002:a65:4302:: with SMTP id j2mr36772500pgq.291.1557201974785;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKY98CBk1uApR58c021PLDh6+W1MQSwVPJuOW175/rBRP0JQFd1+iNfPlqF79LVbKNYmVD
X-Received: by 2002:a65:4302:: with SMTP id j2mr36772380pgq.291.1557201973314;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=Zm8VnF7UaxYVZhm8jWChK+BzOMqPDb+jbd83RL34es7VAAHnBdl7yygZO9FTwCJIfJ
         Or5nAeD3ehPDrvnVZ66yhBTW1znJrKF2MRAE5QU9bImi54xle/38C1/JvRZPPU1tSLIO
         Vnkx3wmI/lFT8nlRYsvnom/0BjAt22vDgc6SdyycBg1zQZkcY2+wzOB8NUdFDkfPEdyL
         zWSMBpRivZIw9Vze4t6g/aBBQAWmZmfRby82XnyuBoQCIxPT8EJ1Y13jyMhrgjaFWdW1
         lhL37ORyFhQ5seynGPlSYulol5uYGU8ITLUWL+gssPW9LJTcDQ4rcacbNebmBu7MHaiT
         B0EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=OxdSSHoGAqmrkmVLEptBFC1YPta48P8T/Z5/nTGxU7M=;
        b=d64S8btMjZuO6d67gXUYDZ3QqrvJgR1g1mwEnwBy7vIA2D1p2BVOhWZBCwHpGDbvA1
         RjpODXYxTff+DaBxKUHJlJDQ8cq02bepdxZ8F6a5yt7Iq7Vwcn/0+3fDxmk0w7tmmS8o
         13otAxnRTT/3M1e5pshxtUrDH5xHX+4KgHl5G0WK0bkMh66skzsKFhLV9B6K7yhYmzX6
         Rx3ik5L+Q0ofelR9KCgqUftEzd6zHsC6Jdn6mgrNkSOOwgSRz9Vb9iJPzXsVaxw2Rwkd
         ndlwZ45Jt/72VPynwCScA8O2FqkztPcKQuLP4ulNoxUIiX9gpR+BUltUG6C9k2wAXbfe
         j51Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=du86YBBb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c11si18130862pga.462.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=du86YBBb;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=OxdSSHoGAqmrkmVLEptBFC1YPta48P8T/Z5/nTGxU7M=; b=du86YBBbxi0LU5yBXgfT0I4sA
	M1CBvj67NZNMmcb8I/6k+oHkeaeRlJaGjiDRbSK/H61K2/vW0PKbzhg4Os4B9umrwPhjsu05AkT47
	njOJyNxEQcD7lFfETGKjDibXDOTKIwZWalvw4Df7uTOkqYLZTD3b1icrTvT+JN/wXQsEvczRYKnHL
	oPzSqjIcRP72d89J0rrLfqbDT+6LBJlPD8w0KQhYWghA/xxYpnUUK030NPrxzB7xpUTuOyezh/7aQ
	6riv7j5+g4pJw7rt/dQ5oLW+g/iSPLWfNa0EdLdGlRrpTiTphrXFycnwanmCkubsAzdKnfg9hZOQi
	gm9eDfqdg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMq-0005id-EH; Tue, 07 May 2019 04:06:12 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 09/11] mm: Pass order to prepare_alloc_pages in GFP flags
Date: Mon,  6 May 2019 21:06:07 -0700
Message-Id: <20190507040609.21746-10-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
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
index f693fec5f555..94ad4727206e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3247,8 +3247,9 @@ static int __init setup_fail_page_alloc(char *str)
 }
 __setup("fail_page_alloc=", setup_fail_page_alloc);
 
-static bool __should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
+static bool __should_fail_alloc_page(gfp_t gfp_mask)
 {
+	unsigned int order = gfp_order(gfp_mask);
 	if (order < fail_page_alloc.min_order)
 		return false;
 	if (gfp_mask & __GFP_NOFAIL)
@@ -3287,16 +3288,16 @@ late_initcall(fail_page_alloc_debugfs);
 
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
 
@@ -4556,7 +4557,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
+static inline bool prepare_alloc_pages(gfp_t gfp_mask,
 		int preferred_nid, nodemask_t *nodemask,
 		struct alloc_context *ac, gfp_t *alloc_mask,
 		unsigned int *alloc_flags)
@@ -4579,7 +4580,7 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
-	if (should_fail_alloc_page(gfp_mask, order))
+	if (should_fail_alloc_page(gfp_mask))
 		return false;
 
 	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
@@ -4626,7 +4627,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask)
 
 	gfp_mask &= gfp_allowed_mask;
 	alloc_mask = gfp_mask;
-	if (!prepare_alloc_pages(gfp_mask, order, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
+	if (!prepare_alloc_pages(gfp_mask, preferred_nid, nodemask, &ac, &alloc_mask, &alloc_flags))
 		return NULL;
 
 	finalise_ac(gfp_mask, &ac);
-- 
2.20.1

