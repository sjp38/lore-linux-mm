Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9677C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8C86206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fzmshx7b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C86206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35C916B000D; Tue,  7 May 2019 00:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E682E6B0269; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8773B6B026D; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 339CF6B0266
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d12so9384165pfn.9
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=7iko05bFICWOWKRvHr1rp4IZvaezgt7QHxFn4er7634=;
        b=HgAMprmCpc76DdiLfEfM90RP1HxL5dgmRWH5UC64RW//xnpxCIbkOGKkFHLStforh0
         vKEgP5yhjw+yXfeGCoLkk5O+cmelE7nH3qu6QE7bzFzN81FWbfNEyHJo1+pW8rVVnC3M
         +r4vCLyQl1MgFcYCIIQjHDWGbhs2ncFwChA8qaHhQgyRjndwCYy/rup/IOWS27H1UlHn
         usaYDkZpxU/+x0E6GfZty7c65UTgeu8CiWa/kR1n1FDJ7YUIxmqusej6kle2G6/Ad920
         +5QU3QoaAcZYuLY4nhBYCOUG7VvsZ9OgO5fqy37DaWXHkF3eo6rM/NhnfPsOJh3FwdpJ
         HBgA==
X-Gm-Message-State: APjAAAUrMOj98UiWiRLOtPR1eC/ZZmHNLpIkuI4L87OXg8Z5XZBIeQKq
	FZSwuLfJYRmWppZNteaBsX3o1eTn4JcssjA1RhHuT0es473a4vzj7fRUlPDjUPERjVwPP+yp5lq
	zqLa7B+3YpwYR+u4rkLiFwK+ZD2CYjn9zh2E+bF+rTZoGW1dvnlr2F7sm/+1vEUTC2g==
X-Received: by 2002:a63:5c24:: with SMTP id q36mr36959578pgb.314.1557201974855;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLf4lgfhVDvw/zedrE/bxdo7lMN1f0rpfGrWBF49sNAyP7xsAFwinf9dUX42EW2BUc/pQx
X-Received: by 2002:a63:5c24:: with SMTP id q36mr36959451pgb.314.1557201973295;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=hVdy7UnncyIQog02LCP3zTeOjNq027iT9eWHYquFBU62KLcykfc7UISKP9G6zrV68l
         4fQjBDVytzYhB6Kgl7zGrU5dTIYNhL+BULu9ZXASJ6K29XKl/6ySjmaXx2KBt+Y6hz8q
         JSB9TRayvinWDS/Lm8p0Oi2d9Gy2cLM9las8zPoZbYftaTA575erbTzPQAsQpDhj5VkY
         2MVp1bo/0hIdbZIhAfzBLpu0Q1TUsP0isab2UCE3BTwG60mD0HtlB3kEKmb8vyCFHmkA
         U17xihf/3QmrF1VZu10aGvxpig+p3kAZFXCtDAoxmFxA4aUeeKIhUYAoFgXbAaATGmyh
         hP8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=7iko05bFICWOWKRvHr1rp4IZvaezgt7QHxFn4er7634=;
        b=DFDScAr7VVC8ZxQCbzyixjC1J5ZSbzMfeS5geslQykGNQRa8sj4xPOy7ZqbFJq75oG
         AkQtyQVdVhsHFCjFjAKVw0dyPqitdOXHUWpxg4esHtrHhVVZ96QwDv668vuHdgwkoylx
         ac7fvOHLxBlStKJMZ5zVC1Q9bCyTE/+AQbjpNRl2Nmn4m7XkOqpLJS0A43uMaXTfF6hF
         3R9Whzy1dM7HqRnIhBvtg9pS2qi9UTHX0ApOWoRCcWGSQLcAqpxIAsN/GuidOF5WrjPh
         7TjH4ompxcW++IupqCKMuZU0DwpLLoblCh946nJl0hcIw6DjfbxJFlIgAkO69bEVYZdt
         +YlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fzmshx7b;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c193si4080935pga.6.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fzmshx7b;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7iko05bFICWOWKRvHr1rp4IZvaezgt7QHxFn4er7634=; b=fzmshx7bEsTwL0aXx8pQc8Txb
	9ViD+/qd7VDIVn9gyHS5wB0pvK6PdibqR7H+f39Jlc9wMbxDNh5Ljxyc43MA+ZVvcEmclB6v1XCCg
	eND1NZAhN0UgOA8RaRjgn6zWbTN9/epEHKapSA3beepaKC4BKDfp0dIaCzMlUDHVKT2TS9ljV38/M
	x27O8Ujz31YdzNxilCKILJ6H5T2ywxIWcKDRIE6nnedQCWSuSCLukbByzm5doqaD2eBW+RaASqwqP
	GxaGJJEkGy2xVh0xTl2glu9JnC/CDS2gwnBnyNYZoMrWTmXkX+3E5Vo7za7FzFjcTyQsp9CPArik4
	1o5hTVXUw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005i6-Pc; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 05/11] mm: Remove gfp_flags argument from rmqueue_pcplist
Date: Mon,  6 May 2019 21:06:03 -0700
Message-Id: <20190507040609.21746-6-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Unused argument.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/page_alloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb997c41c384..987d47c9bb37 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3148,8 +3148,7 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
 /* Lock and remove page from the per-cpu list */
 static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype,
-			unsigned int alloc_flags)
+			int migratetype, unsigned int alloc_flags)
 {
 	struct per_cpu_pages *pcp;
 	struct list_head *list;
@@ -3182,7 +3181,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 
 	if (likely(order == 0)) {
 		page = rmqueue_pcplist(preferred_zone, zone, order,
-				gfp_flags, migratetype, alloc_flags);
+				migratetype, alloc_flags);
 		goto out;
 	}
 
-- 
2.20.1

