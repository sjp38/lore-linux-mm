Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAC3FC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D09D216C4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:50:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r6bl2BJo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D09D216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2B356B0295; Fri, 10 May 2019 09:50:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA256B0297; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 649716B0293; Fri, 10 May 2019 09:50:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4DCB6B028C
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 17so4156776pfi.12
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=YfkW4qIwUGsBhoWlrqnKDkQtprDC3cp1HvmKaBgk21U=;
        b=aDkB/Z0C9xoM1Vivx5CgOAzmM5hcE5SgQ98t/HjFldlaNHMARpp+kCBuQy/QxkZdqy
         joasoF2ssWNJ+mWr4n3z/33ddC804gepGb/emmvX8BloBNqkKPeu9Wg7cmlBfHsBVgCY
         I/Z5ULOWZNurDhRvquvPGt4YVL+Gh74G4/+eOYu1j3iViXC/uE2sc1wBfSd+FQf8foQP
         ZZ6UdcACp24xHYyW7nGek2wnOEons49qclmYv1lHAIQleb9KJxqjO00Lh12QUs15926S
         tjzDKd91VOufr48AJVkt9PV8oNiwo4Co/jPzgGw3CtRFvee9hZ+bPXBY2IBSSslvm/pr
         /ARw==
X-Gm-Message-State: APjAAAUCf9g9BUxmn9Fxv+7w11/eQnietNqW4RlcXxrsBzeBbxi0RlNk
	r0XzHOE2LphX/qs3dmVh7o2jhpaQGdjpkDZ1YvsxTw2uAkE1769kIg8H1KrcFKk2YQNO1DZ2nAo
	SyDtnHIjSRr09kcnTVOuf5QS5jtBZswTn5/xiolVzgwmH6cMhv6g30XRoVSzc6EQd0Q==
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr14160332pfo.211.1557496243503;
        Fri, 10 May 2019 06:50:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUEx6mD+hlNyVbcEeyhK+/k+3qsYH5FjJ+JO9vWEvq2qhbgCtpmvE2LZtn4KMaJklK/XGu
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr14160190pfo.211.1557496242455;
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557496242; cv=none;
        d=google.com; s=arc-20160816;
        b=XJgRmsPsfFsXkvtAnCnTme3SblUVZyiEC5C1uD5jwKjsgLgEjsvKxlLvL+c60X9Zmm
         c1C1hw+f+sdYplr41Bg15A+u6Hw4IqA+Lo0ybCtSF6GW+SV8SOKbq2n1dSs3005zUKZG
         reOA88Ft1IDyGzYhptJIuti1hSpWpi/VMXRAb9/bEnlRD4pq3MRDBacyfLIQRaIcDFtf
         Cz4cTH7tugzi1A9mb+l+OWYUXvYQUQgiCw/7e8/DyFwr9mBDSRQwPQbLGtgcz+oDCP5o
         qjB74wzR2mvIGcxksHKJEMZ6As6rNf/7ah+icYSAxOTEMFRUWArGRdyrV5fLBclTj1eJ
         I5lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=YfkW4qIwUGsBhoWlrqnKDkQtprDC3cp1HvmKaBgk21U=;
        b=u8A2ZOyEcxFFkQOlTw/h6IXfTTfUUAzA3hejNJU8adh5AxRoqOOlQdc+ST3pvH5J1t
         DJuHpg/V38wcG5xckM0FKEmV+ZGttCGUqfy7bxw0/T8071oHkRtsmUjL3zRmsmpUBsGK
         EdTcGlHlOOzs8fREQ3TBIgf3LHemjk3iURhow1mwiTrrqnb6/2jNrABf3jkQa+SiijbJ
         UJs70aSlqoo0MB3SIMynQ+ide3GdUmUuHe+icMnTKMW78mORpATSLuAehKAb658hN7OS
         q1o26V45apM9TljCxxczjWrAaPoFz5wBT72EoDyuPraesAyet1im1BdQKyqc+es/4jsR
         o9UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r6bl2BJo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 37si7248083pgm.55.2019.05.10.06.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 06:50:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r6bl2BJo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YfkW4qIwUGsBhoWlrqnKDkQtprDC3cp1HvmKaBgk21U=; b=r6bl2BJoeDq9XStVs7LDpm78J
	N+brn3qzoRVrTGMHVJVNOH6OPs4OqDiewvgZCiCiYDnOTqxNFldQcZtKLs0p7tPG7zBG4ay6GB44S
	VnK0Jb8PqeUiiWz2sm1sVrrvz+JGFlL3Mj44iAmHrJkrbhCqmDwJeYRWWvO2ysgKJOHBohsZwVYG4
	lJaVtqCmecRn2QiIEA5fxvrPL9n2uUmyH5yyMMcUDXYV0ofpp2eSOW4Q2tmpXQxteCieeudSxUYiB
	c0OqHWqwSFVG2XviJuhSsF2h3rk+3ArLIFuWeSmiO2Vb1k7UlHqZzcUZF/cNdRKNX5+kB+tlv46pW
	AmkJ0XmWg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP5v7-0004UT-Vb; Fri, 10 May 2019 13:50:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH v2 12/15] mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
Date: Fri, 10 May 2019 06:50:35 -0700
Message-Id: <20190510135038.17129-13-willy@infradead.org>
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
 mm/page_alloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 38211bc541a7..d4ac38780e44 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3697,8 +3697,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 }
 
 static inline struct page *
-__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
-			      unsigned int alloc_flags,
+__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int alloc_flags,
 			      const struct alloc_context *ac)
 {
 	struct page *page;
@@ -3794,7 +3793,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		 * reserves
 		 */
 		if (gfp_mask & __GFP_NOFAIL)
-			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
+			page = __alloc_pages_cpuset_fallback(gfp_mask,
 					ALLOC_NO_WATERMARKS, ac);
 	}
 out:
@@ -4556,7 +4555,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * could deplete whole memory reserves which would just make
 		 * the situation worse
 		 */
-		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
+		page = __alloc_pages_cpuset_fallback(gfp_mask, ALLOC_HARDER, ac);
 		if (page)
 			goto got_pg;
 
-- 
2.20.1

