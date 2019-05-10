Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D403C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 441AF216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r/0QAaBE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 441AF216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FAE76B028C; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 628426B0298; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C7296B0296; Fri, 10 May 2019 09:50:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 867466B028F
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a17so4172911pff.6
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=YXi2Vb1hST3grI1sk61d7V/axR7tySOZeDPQ8IsaO4o=;
        b=qXIHMmIhm2aE1m8H/3Go74qfefRwPUYRFIxicQAKajpAAK+8SGoc78i4HKUMMRkLS/
         EpD+6Tmow3HD+c5gXaU2laxgfO+MYWOoqsfsnVGHTmVAibrwIdFTeqfUjRUDBCDsp7tp
         XDzB2NqDU5psDVk0k19Py7K4fmGKT9886VbnmRKQJsg5llDX+JMA3otc+7CuizUXKkWB
         Fa+WUDV4g6u/HNmtWrhqreyspyD4x4b+zsApeWULIln6yDpBdoE8QViesALpz6CxYIbo
         63rmkl9Dnn/7D4NCJTKEZA4H57+zMMklxWmrltjgPv/XaIAMJGRudoNs1Ixix/ueOwxb
         weyA==
X-Gm-Message-State: APjAAAUZFgkD9fPYLqa5RqWi2HCPh650VJ+293b5qyfwpE6wRtWC/EBZ
	MqXypAy+oyOM9EN23bFr40jx1ENYKbfhEwpRidyVxYOB29B6OgDXiOCj1GYuD4lZ0uhUH9EOqbW
	TX24e/doHp7gWNSBV5Y1k0dkgo0UHj7UBzBM4fVzsBvUh4+8qgp+yiGE8v/w3WAgi8g==
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr13131507pls.215.1557496243133;
        Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoqLtWodtWl08KLD2Df46yILHObzagoHzcs5cvWQKV7IwZbgG6QzsOP6+p3rmgkQPOVmhx
X-Received: by 2002:a17:902:be09:: with SMTP id r9mr13131401pls.215.1557496242142;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496242; cv=none;
        d=google.com; s=arc-20160816;
        b=0TmwaEwWmu5CrJKf4FpJgcNqRYWylgZ/hqXRkhEGe9KAl5Y5jzGn4yES9JzvodAwjS
         lgk2fcWZDdiRTfSMFrTD2qNAxiRdypJ1UogTxj39C+poGEqb1AQq7tbQdLkCYV5i90na
         VEyn3N5Ec6XQv745ePrk6pQXeShZp0f0bJyT+XVT+yS6sNnQSVfygxFUh6q4yaIiHnZ4
         J59EqN9T6J6jp233g751xfUrrBoRM68S449K6zm/djWKTJNkXKRfXW1X4zn2TpXuZaJH
         NifdV7DxOt2HT0qLbP+HFjfVHCvpbU9OdzldleL6UuHIerju6ObyxEdscPGqCYGGsn2e
         ggkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=YXi2Vb1hST3grI1sk61d7V/axR7tySOZeDPQ8IsaO4o=;
        b=E+hRqocoFEEjAYFyY1xpi7+MthTbcAQbUPAluxPa2bBPCfkDQSYv5Ep7W9pdopnIX0
         7cQtlH+rFurk3fn2oLimrHrpkAcNcqnzz8ZT5GW1W4U143MkvOudjU5Zbmf2Ke0VUE4e
         86cY9WkfwC7qId+ZN6y9HFghKayoeSGCZhcwPBwxOBUZErRQvaFZMaGIpNP0H4ZzJ8xN
         UaVh7wUatGEaQJr0vPRCu7xkSMChdBihlJmDhUWv8clb9LkwSmJFaKOawHXENgVS7iuL
         XOluvk9kWOAIOs6wCiI/3mY0qde6VSDZd7k9ZVMscxVLvpQEBDkkuArk+GP2leM61pKS
         sLdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="r/0QAaBE";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b15si7943894pfb.231.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="r/0QAaBE";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YXi2Vb1hST3grI1sk61d7V/axR7tySOZeDPQ8IsaO4o=; b=r/0QAaBET2nYELz9uZmSUU8Se
	/QC0ORBAefxx0rya7fkAsJm05M+NuVuuth/V5L2dBsHzOW0+Lmxnbz7pjLr9zV3pdQUtzvBEj6TLy
	jPavN0ikTdwiN6D9DZgO6doOKE33lMZmlYn9CZUHdCUZjHtMvTnoyt+1r5qBXYCgalk3/vcZ9dY5c
	KpGJvXjztdarzB1Xd2ZxZyC2z9KGmzIjV1O1W59NOzTilUZ/nnxgDLl3CNi/bomPaU6hyxW7tZDbb
	Q5d4e3IFpfYcxqW6m7Y4v37ZiBgxOWtQZcoD6b6nE7pyAqKf/WNL/bfo9ql9WVK/3qyiTMGhZodGY
	uZmo5ULow==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004UH-Lj; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 10/15] mm: Pass order to rmqueue in GFP flags
Date: Fri, 10 May 2019 06:50:33 -0700
Message-Id: <20190510135038.17129-11-willy@infradead.org>
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
 mm/page_alloc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 91d8bafa7945..6cff996289be 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3186,11 +3186,10 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
  * Allocate a page from the given zone. Use pcplists for order-0 allocations.
  */
 static inline
-struct page *rmqueue(struct zone *preferred_zone,
-			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, unsigned int alloc_flags,
-			int migratetype)
+struct page *rmqueue(struct zone *preferred_zone, struct zone *zone,
+		gfp_t gfp_flags, unsigned int alloc_flags, int migratetype)
 {
+	unsigned int order = gfp_order(gfp_flags);
 	unsigned long flags;
 	struct page *page;
 
@@ -3613,7 +3612,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 
 try_this_zone:
-		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
+		page = rmqueue(ac->preferred_zoneref->zone, zone,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
 			prep_new_page(page, gfp_mask, alloc_flags);
-- 
2.20.1

