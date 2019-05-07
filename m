Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98929C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57794206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uq8I9UaK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57794206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 877446B026E; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 789276B000D; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58FF16B026A; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06EA36B000C
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f3so8477284plb.17
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=/u0vOVQKw+fJn1VxLvHzBxuzAWiMbUPY1llj2pC/tb0=;
        b=cuuKWOsEhQ4t/s68HG+WqZ3rI2HQBo8SCNdQX8kJ3jP7CyUfQS+sscyNkMR0xPTUme
         lOJ5vvI7Qad2lDMpEknqMAMyYW41SyLvJ+MWYN9tLhKVGd1yOVk2Qv2k94FI6dLiIRxJ
         37tIvoJ4hf1rAK1+5lhoLQGfjGk0R+e7vCgms01a11bJY/o3sgjo7XPzSUvR2DzDJWaC
         i4hramRL1fHyLs5SKZH2MlEBRupYkWfSjohHSSXl8PowSpBEq1gFbqtvY3qr1Y0tZ0Zh
         Tjdvyis1RD3rg6XO3F4iDcpqfJZUULnq8yApDv/ocEj9S3Wyk+8My9gvuHU0jSnCM44o
         7dww==
X-Gm-Message-State: APjAAAXwck02pC7ezgTkAcKIbjFjkQ9ypOenRcCrc7AgQYqRlsArcBHd
	eE3R6Tjv1lcgMtapqLFm3vd5Q1TAZhwNBrfTv4J0LzXwZVAbJkiupeBmCFiEEoCMzfSaOekGZuu
	4TyqaWfE9byrihM9U/B3BOAop1jICf11m8+izG5u9HMLkwrLkUebeRKN3XMHSuwU9yw==
X-Received: by 2002:a65:4341:: with SMTP id k1mr31185464pgq.88.1557201974659;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCuez4BJet+SuFjlMm7dEy20b5gWeBwqRsCkTnv0V6L8SFcO1QV+Hx4QJkM5QbFoVMBRu9
X-Received: by 2002:a65:4341:: with SMTP id k1mr31185354pgq.88.1557201973294;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=hMlGik/Rf10saxSQo0jZxy/Po9nvzImzFQJ9i5i8LP7k4cATwHHisw/W89mMyH43sm
         xoMgDye2W5S4pY3JYAhmC5x9ZxNrJGQTSXuVjq6q/+m1Q2MilPepqvV5mIdIBJPo+jDc
         QlUwnWUp9uTzksbp/iQwmP/g2fVyN5JToT3dDRPuzcHQ95oSV8HU/0inNCAxhvs2aR7w
         43eKXvNVz/+wYPdqn8BatgEhrydcyF7tG4JnhUrjLo4X4rcm9VXDdeY4qIbaTNRg732I
         g4YJtUlR3CLbKNmUm2KHVZOZh2OAG68rEN6FUoT/6uELYOzWzAQ/BYzDQr2eNxny6XMh
         891Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=/u0vOVQKw+fJn1VxLvHzBxuzAWiMbUPY1llj2pC/tb0=;
        b=b+pc15Xx21EBtkJnI2B6naJDf0Jy2sWf7xVxZzVzLnizsJW3vzM4i53HkAdBsqYKzm
         bbrOdRSYfXOIAwDrrANXN6Pwo37Ggtg9vX+vRlBoUsab2zeBzaJfwMiNH0DAXvQmVWCX
         NzSRgoeZS3S7e8WKahtGl1OBJM1/tgT1CBEa7RU0GQ2RbscFqcFnAZW1/Vy8y3XTXE13
         nUB/Z9R/2DPN3uwP4lbf6Ept46nz7Ea3BoCdMmmMZ7CcGUm9o4SLyqmUNYabrxmtnhVa
         dVq6xk1n3K4MXKjNpABdTKHimXWtnePcfzey0vYryb9EDpF0EeA986PuYL7YjeT9YYnX
         kLfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uq8I9UaK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 36si17530679pgw.281.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uq8I9UaK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/u0vOVQKw+fJn1VxLvHzBxuzAWiMbUPY1llj2pC/tb0=; b=uq8I9UaKu7lWZVBtZFrzS5POw
	oI5d4E8K64K+NvG29/Gnj14X3TJZT3Yh/XKIrWCsa7g8mdB/rkXBH0VDQztXqmq0rtm4yEpbnYvE3
	hT9LnKHiOQiyzfDM4Oyvc2gDuOXmtj4Q96MQnRWB+S2mdf1oPoKKXIOOpBz9r/AYU0WRBIUtKRqOR
	fenZIWjC5PGtIHwBYTugELvok16tDW/zquFWVNTOylcql7QgWlm6uxKehtEKi8kfDTw+PudlwB85k
	pCrOe7+fh8J3X7WaU/48HkWicbOu5kJblxf0UK9DVmNzg3CJEPXUqiJm0KM1ez+RqFDhZK3BOTICH
	jJCx42Xqg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMq-0005iX-9D; Tue, 07 May 2019 04:06:12 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 08/11] mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
Date: Mon,  6 May 2019 21:06:06 -0700
Message-Id: <20190507040609.21746-9-willy@infradead.org>
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
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cf71547be903..f693fec5f555 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3679,8 +3679,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 }
 
 static inline struct page *
-__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
-			      unsigned int alloc_flags,
+__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int alloc_flags,
 			      const struct alloc_context *ac)
 {
 	struct page *page;
@@ -3776,7 +3775,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		 * reserves
 		 */
 		if (gfp_mask & __GFP_NOFAIL)
-			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
+			page = __alloc_pages_cpuset_fallback(gfp_mask,
 					ALLOC_NO_WATERMARKS, ac);
 	}
 out:
@@ -4543,7 +4542,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * could deplete whole memory reserves which would just make
 		 * the situation worse
 		 */
-		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
+		page = __alloc_pages_cpuset_fallback(gfp_mask, ALLOC_HARDER, ac);
 		if (page)
 			goto got_pg;
 
-- 
2.20.1

