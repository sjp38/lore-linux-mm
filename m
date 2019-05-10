Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81F74C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43A14216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:51:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PaKHOusx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43A14216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 697C46B02A0; Fri, 10 May 2019 09:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6229F6B02A2; Fri, 10 May 2019 09:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FF5E6B02A1; Fri, 10 May 2019 09:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 092306B029D
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so3703503plt.23
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=DcVuILn13FfUqLdv2VznsgASPoufcMHzUgxnV9bVUr0=;
        b=cJKENHEP09SwwDVAqDG8GOa7oGb387AaBraasb+mUiXbT7VbE0RA2pJoE1JskstCHI
         sytb5AZ+FNHYwwWm3nHepeijegAfGhlUVc6PXSzjydexuZNIcdZKY+0fsx/EsuUKOh0q
         mP2o3nHvNYyac1nKwt1XVNMrd2AXfbaX3Ou70cjpxhMRGpPr85lDGpBGWMUDQWXftUFj
         Yii1aZyQK1/+zBHxfNRQwAu46D7ncqKtrz9IkWSetNI6yYJSPZyQPpG8o3cTtobM2IUF
         XJenXpm+FDGeyg3ZdtBD+ZQm/t76aaX0pyT2TVz0a5MC9QAcBDZG6IHm0wJX/f5Qd4D1
         GYTQ==
X-Gm-Message-State: APjAAAX0CSJTcKYaRgnub4BeqAlTTMzJ9vdTOyNL0WDJ3zkSlTZgqZCc
	lb18MpSZ0iNu85awhmtkZ6x7nuOvq83ufyxP8c8gPM88qyBPOQHe+ErV7Vkj96A8BhOUmFqrky9
	iRbZt4lqQ25x6o/BC2fhMjDGBZVRAx9jBnxWDE9qvtwhVF5KPo9SOC/WlrYCa+atTrQ==
X-Received: by 2002:a65:554d:: with SMTP id t13mr13545436pgr.171.1557496246682;
        Fri, 10 May 2019 06:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzziuLLljQ15M4gzBFqNF9hT+VdMlUp2ceZmqcoDUKPeileBw0N51zAw3GCYOM9dFib2MoX
X-Received: by 2002:a65:554d:: with SMTP id t13mr13545308pgr.171.1557496245490;
        Fri, 10 May 2019 06:50:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496245; cv=none;
        d=google.com; s=arc-20160816;
        b=mT54/2GSEzm++sgQob1YTkE3S1u+KjnisSx+GQNf/+jty3awYhGNKUBOpRGiHqUL19
         Zs1BEZYeMIQbRAgm5NqjKTZKPQ5gA6ewc72JEryz+ZK6DR/ZGWBc4LJFeMQl/aF3R4QF
         GNzhdbiAC+eBOI7wTlVHS9kG5tvnesPM1F7RUzg7b0p/wcRiEDD9qzQiMFzDAs28WHT0
         S7dDlXUMAZTjxHHH8e12PMs8RqjvLqjPRCs2bb0sl2vyVLaGiAhz6RNkDl9mGwgzdP8D
         MwFk+9OweSCh1q1eCGYmXuUJfll3itRGdUUuoqlW0VeD7wwfh8jSqJxxtNm/ljBPUnOL
         Z1rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=DcVuILn13FfUqLdv2VznsgASPoufcMHzUgxnV9bVUr0=;
        b=ZKBVBbwVUm4mOJTCekeO7gIY6NWxIXkdPLYWASUEVt32j0rLpvUqCLsAxCoHNCKhhE
         N/gdrY1JZTPw4XlKMlV0tEcNXi0WoXjlQeBxreoWhIzXg1u4X4Qiz7zxuwguBhcU0Ix5
         nm1tYOknxp/P+9fz5aYCJb51T+MOGlWveIy3F0K6v+YRTr+53eKAVtyeOW/CCS/xhRtl
         a4jiTypGN0L9JainGp2YtIpk/qTq6xpbs6ukW+oInYJtxWX0ggFtn1zt9wnWdd5s+h44
         rhxk99QX76xSJPt9kbjpyyVdMyuLWgjEt5qZrJPDq03DHP8/bD6rgN9d1vTUeS3iBw7d
         pJuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PaKHOusx;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j9si7005855plk.125.2019.05.10.06.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PaKHOusx;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=DcVuILn13FfUqLdv2VznsgASPoufcMHzUgxnV9bVUr0=; b=PaKHOusxuf7k+VDn0MNcz1JTg
	sJrTfbJpHbct6ChkOtdWMUh+gg/Qf0gneIuII+ntTvSaNpLCRg5NWUMAg+Kwp1qCRdir7WZi64O4a
	3ZZsNOw0UYNdXRkg1/GD4Uy7aH2N+K2hg2QR2Qf1lV/G3gs4EOyDZfBDdPhK4iHusF5jffUOHJP4p
	Z5l6e0lFXhrwDm+CLq0tytnsDoNWMuQmYxyzD+uPSE+6n7YkUH0rKesA2c9NyTPvy6n/Twn6DRRfc
	iAIL6/QjoWSB/K6HvMR6E5P0T+EPSqc1OpNurXVQGiL9J5ZGpwYSQhxT5zL+iiVmxrrHZWkeDkCK+
	ECr1JIxXw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004UB-Gi; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 09/15] mm: Pass order to prep_new_page in GFP flags
Date: Fri, 10 May 2019 06:50:32 -0700
Message-Id: <20190510135038.17129-10-willy@infradead.org>
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
 mm/page_alloc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eefe3c81c383..91d8bafa7945 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2071,10 +2071,11 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	set_page_owner(page, order, gfp_flags);
 }
 
-static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-							unsigned int alloc_flags)
+static void prep_new_page(struct page *page, gfp_t gfp_flags,
+						unsigned int alloc_flags)
 {
 	int i;
+	unsigned int order = gfp_order(gfp_flags);
 
 	post_alloc_hook(page, order, gfp_flags);
 
@@ -3615,7 +3616,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
-			prep_new_page(page, order, gfp_mask, alloc_flags);
+			prep_new_page(page, gfp_mask, alloc_flags);
 
 			/*
 			 * If this is a high-order atomic allocation then check
@@ -3840,7 +3841,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	/* Prep a captured page if available */
 	if (page)
-		prep_new_page(page, order, gfp_mask, alloc_flags);
+		prep_new_page(page, gfp_mask, alloc_flags);
 
 	/* Try get a page from the freelist if available */
 	if (!page)
-- 
2.20.1

