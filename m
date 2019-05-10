Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09A28C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C468D216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r7XvTFvU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C468D216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7F96B0289; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7CDC6B0293; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 759166B028D; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10D226B028D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 61so2646839plr.21
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=dfTZNTkYRHK8kF0M38AMgEw9C3ttVHJ548y3MQnHBKE=;
        b=G8+wR28SaN4CuNa/3PR4l2EJnaTGNCJ7FxM92Nq8xyDbK1LIXcZ9JmgYdDOUEYYDTh
         cK4+N3kLxuD2sf3wI9SdvpBah98/huAxVheBG0zeVN/9KXsT+niDNJm67zfl1XODZ1nB
         bR2vKkPnYrxV6Z7zfQaeUeFhKjmreim9Rm3inCF1tMq/gjOIKPMjzfh3Ma29gJ/l0F8t
         6xd2mn78BN679HmCLcqbcNALgaNzIp9sruHnq9uUB0HdgIAIKuqqS/D2mABnls73b9/j
         Cnqg9JTn+a8uqKmOsTQre77qIhqBOiNnC4+ls1V0Otr1uyjF8wGvaLViLDpvcu89nULC
         kiOA==
X-Gm-Message-State: APjAAAUoKSMkBlcPfbE1nWVc0L6ngzbFd1eSo2FSkOklHSR4UHxT1Ahc
	Vyl44SyN86t41tfwqPpub5U8tzSV2u1gsZw5h8Nu2PWUcHhKBZvz8sOnI0w8OAFmctmty5AzGxj
	PC4yoSfKlWWoYznV/PekloriiqKuVCdLw+ND2t1A6EEV7OBvBTylX78NL6sw5aQ42Lw==
X-Received: by 2002:a63:4710:: with SMTP id u16mr2821497pga.447.1557496242633;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+GF16ObzBonVdVoUXCD8PA/K3xbEHoxxbJbLKE6VEOjUtRoPTdi3lZsWIfS582Kk/urrz
X-Received: by 2002:a63:4710:: with SMTP id u16mr2821319pga.447.1557496241087;
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496241; cv=none;
        d=google.com; s=arc-20160816;
        b=Brum14NBK+iscMQNdtrXtl6jqkQF1Dx6MBNok4lFnFa6EZ2qLutbUEuSODdMjxj0cy
         U8r6Ny+DaJf9VR0JyNmm+6FSP7mR188Ph1zrV04SUXes+GI6H+ZMvf/yehmTnOAU/9Uj
         zbEgj81Up3/aHT/RPWUAVniL03lGD7stKzGQHmgFAGIXwjoriAzXf35Q3U2Qmfadz4XR
         wprhtj6j0XvzRWyMFLb96nhFAMYa3ONnhuon9WTWgSL9kezEX9vBn5SK3FpguwoKwPTW
         XvhzS8Be4t6lBm3DVEAIc4efV4AEqTx3XFtbR8geXWX7QSdGaDFrDnBGnOP3qVr8FmGn
         L1EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=dfTZNTkYRHK8kF0M38AMgEw9C3ttVHJ548y3MQnHBKE=;
        b=x9TiAREFVLw+0cTObCElhEci0246Z7rXyE3sVQactd/gcUkUvTPrfl0aQFBEXBJZNg
         Uku3lGSEarlLXdoSPB1x2tIs+Vuh420WZme93pxr/v0p9WFAQ/+yYJmmQZKzcqbbWbdy
         kleGma4rnLRSTsJHYZ2PErvpJAayPZc2tCTKQMt1taK3rf9tbc+/o95BVkTvQ9uzLXKn
         NQbuSmFjaSQeuLgULvqOE0g/h3n7wDu4YH7mLlvtdMbdb8E/rhzKkjf/CF2jjGFg65Kn
         mttZk2OMVCVaKymFzfu6KDuR5ZokNa/myI02BkOOAv6W4p4zoRc4TiGfa9Bc1e7AiAv0
         z8JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r7XvTFvU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q197si7116983pgq.411.2019.05.10.06.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r7XvTFvU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dfTZNTkYRHK8kF0M38AMgEw9C3ttVHJ548y3MQnHBKE=; b=r7XvTFvUvtbaqkLFA0EBIY99Z
	UEhWg2KML4+gAOsDFbJFwYFz/0eHVayWVfm+dAYrATCf+k94BVXktRkkIuaNekUM9bOzPDTsigkk3
	rbavvdW18UMXltdkdwjjwPMuVcrTsfXXuxQC6r6yzzK5hwQZavvyJ2o5zUzmNhYFVlVJRW2Mcxm8x
	hLXxDlYocLWq24OOizh99SYfjh732Zej/0szhF81+8B+0ASVGQW/oPvz29rGnOi/WPVggJy51YMJT
	tMIfPWxlbRoZx3Os0gcCMB1E4e0V1v+WsgXTntD/UDzqfRuR4vzpotkfQ3pvdUFgdFQFCZ7nFgKwW
	6R7fhJi3g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v6-0004TY-IU; Fri, 10 May 2019 13:50:40 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 03/15] mm: Pass order to __alloc_pages in GFP flags
Date: Fri, 10 May 2019 06:50:26 -0700
Message-Id: <20190510135038.17129-4-willy@infradead.org>
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
 include/linux/gfp.h | 8 +++-----
 mm/mempolicy.c      | 2 +-
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index c466b08df0ec..9ddc7703ea81 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -478,11 +478,9 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, int preferred_nid, nodemask_t *nodemask);
 
-static inline struct page *
-__alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
+static inline struct page *__alloc_pages(gfp_t gfp, int preferred_nid)
 {
-	return __alloc_pages_nodemask(gfp_mask | __GFP_ORDER(order),
-			preferred_nid, NULL);
+	return __alloc_pages_nodemask(gfp, preferred_nid, NULL);
 }
 
 /*
@@ -495,7 +493,7 @@ __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
 	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
 
-	return __alloc_pages(gfp_mask, order, nid);
+	return __alloc_pages(gfp_mask | __GFP_ORDER(order), nid);
 }
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 310ad69effdd..0a22f106edb2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2011,7 +2011,7 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
 {
 	struct page *page;
 
-	page = __alloc_pages(gfp, order, nid);
+	page = __alloc_pages(gfp | __GFP_ORDER(order), nid);
 	/* skip NUMA_INTERLEAVE_HIT counter update if numa stats is disabled */
 	if (!static_branch_likely(&vm_numa_stat_key))
 		return page;
-- 
2.20.1

