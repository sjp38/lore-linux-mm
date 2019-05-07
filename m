Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 461D7C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 084CC206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MpBlABxw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 084CC206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1209C6B000A; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2FE6B000E; Tue,  7 May 2019 00:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18286B000D; Tue,  7 May 2019 00:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A98866B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z12so9461576pgs.4
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=saHc0AmwsOE8vEyEvS44cYuqIl0lg5B+4IKiffJ1aEc=;
        b=NrwhrKLgviHMHHC9N5byHSt6WSZf6bD8Pfs8WGmrnTnUKdOP7Nkj0EiYDIqNKJbUOw
         NSkWY7z+3F/Jcux5ia4KhYrr2azRPfHJ57TFVlhBFbRWX7ZPXIbqRHgT/yQvhvkzMlmG
         L6iNiRS19ySxJSn3i91svT6u/kGItmNEoxzf8n0BP1Es5ewff+n1rL9ghYSkDLSKsXjc
         jqKCGVD5g7f8hHg5y2zwd7dqc0P5HbGo2VEuy2gWWqnYdvgUl3YHIlxgf7tZ+sZgQyXw
         kF0VkNl1i06XLK0gRzhGBo1VMIS3Mc2X1lUhI1pelyQCWypPrWd+rVoUu/c0PSqZFca6
         ujyg==
X-Gm-Message-State: APjAAAXKEwhTrWorVzYY6q6tZEQS2YgsYqS29D/gSjHYBOpdTpo/XHfg
	v7BdCy5lDdKbNxv/BWrDnx+Uvao7C4mVnhbTk4Fi8FtEscN4PKvi5AkpMV+QxgXbfqLf9/rUZ4W
	kbBEQ9DYRQ4x8zh5OikorADKHD1p1eWVpsWFVKx1xfPLTGT9Vf8t7E6ZPqoZbCMWOPQ==
X-Received: by 2002:a17:902:b614:: with SMTP id b20mr609065pls.200.1557201974350;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymDl8urmZ6D8RLOXxj3O18EJtWBZNsP9EUyqf/ddrFuU/fPt7Ybd2PSlM5lUYJHBtSoob8
X-Received: by 2002:a17:902:b614:: with SMTP id b20mr608983pls.200.1557201973293;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=f2kRjmloLrO/CV9S0kzNqte7kJCoLhHF3bNh+e4DHFVeKunTtjm99Sq8v2Vz9NPWDS
         g1ogDidb/BOkp7L/8Hi/jYYI0h13vf/M83CPT6LDyebgt0TV6LGC8wsWN4KgAHATcYDa
         7felJ7t+WVrsEehptvCS/IKrjLMC7LfyrT/6tWqQHN3nZ+urFPKibUDeMpFz0mqzhKHv
         dKT7raOGyQyW+PDKl5bKMeDz4s6VvsgibuBAsBGvA1tEROP/dshesEHFHSz37WVHDASX
         crzZENXvUKPd0tw8mHWC5CG9EEmRKvjOSJFlhtnVsoBM+QOvrtoQs+4jaC8xT1kr32TK
         53ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=saHc0AmwsOE8vEyEvS44cYuqIl0lg5B+4IKiffJ1aEc=;
        b=DBGeSjC0mOqHlSoK3ohdnpbHgm3MWPh2W3szVsboQ9+KWwi82cnZuRFvvzqINmbyP2
         xrKTTgnBgFRJYf4TvzIJpY8tDvOVXwBDNNViXWFO29wZ6MK3Tn1CvgsaEc90v83J40i+
         zn7YbTBgFCvLwyW3bux8I7PLpMhOKeIXIbQY98MXNM20JCNKD3/2wEIbEFZIwEnLoWLO
         p23od3vBY3+OqyYYOMDwhizc//ZQ4Kz7dWxJRrq6lqZbrkvcezmgcG5eO/7O8SNEvUGa
         3GVB6qK69C7AADHORwqB+a3SnBlt2yXBp5wR77tqMKQaTm02+fZEF8fBRbj4JGFs2d+S
         LUuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MpBlABxw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t1si4174784pgh.406.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MpBlABxw;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=saHc0AmwsOE8vEyEvS44cYuqIl0lg5B+4IKiffJ1aEc=; b=MpBlABxwNF2L7B1qWsguQlIOx
	WRmt9OY4g3+b/JMlf/udIySt0hk/3x4QEuJxUecz5HlQTINPI5IZcwEfLd7IcP3TDCzvj1kBngTqC
	xQw1KWiEsCG4z1ziRL+r3GVwbjVJnKMjSdJwafbJcQTZcypTs/x9JbepG0pxva8djvkT6czjtq4J2
	KLJicQnQkyNNAQfxCskYaCnqXZu8ZAP5llwuSOtditLMAcGA3cvHoIlj0yfIv+eioYRwX5LWHbo2F
	jIHSSqh60FPqwA6sRhxXDwMK7RhJYSmXxAvDxah0ryWd7MP4oS2exNtluXaobqLLhigW/+PeF7+jg
	GzvcDa3wQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005iE-Un; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 06/11] mm: Pass order to rmqueue in GFP flags
Date: Mon,  6 May 2019 21:06:04 -0700
Message-Id: <20190507040609.21746-7-willy@infradead.org>
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
 mm/page_alloc.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 987d47c9bb37..4705d0e7cf6f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3171,11 +3171,10 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
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
 
@@ -3595,7 +3594,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		}
 
 try_this_zone:
-		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
+		page = rmqueue(ac->preferred_zoneref->zone, zone,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
 			prep_new_page(page, gfp_mask, alloc_flags);
-- 
2.20.1

