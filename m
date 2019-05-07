Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC6D5C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DE3D206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QpA7NsVg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DE3D206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDBF36B0008; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8B506B000A; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D54756B000C; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 990046B0008
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i8so6962254pfo.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=khFvxsLx4QWnQkDuPul5jtvX7t2XfQXch+bLgFiUiyM=;
        b=jgxNXkiCMC4tffMyLD2yRb+ZM3JfWRxPzoIg0KSsa8ptQ0KHTtGcYN707mYm1BFNc5
         OZK177RqzL4x+Nf08LbHcZaj3JAL2EGzjdUMvimG2XJYFt4eh1geQLZvxr/n2Uvd45IJ
         d098/RzOgGRkMjOZUnpHedEPR4nSu2+GbKWds4Gob5z4xNznn/V6Yx2q4y3nt1p34Y/E
         oyVpXikeIoQ6an8j0rXkwPXMDGpqn99GFOcRl/WJnZGcZQSusAeSLyO4IOYbHLYiH05I
         b+spTf+luGShpR1boB/q93ZMRpUCfmpxxRT9fJlhNqGlRDXJFuWY+d/RDOGG/ZbOTiX4
         9lLQ==
X-Gm-Message-State: APjAAAU/Un8h092avS2ji4JSsN/5ACRIsqDC1lbaNtrtb2x2xsDn3Egg
	BJF/kLX5McLA5Pee3N8ai0akNir0DUN+BJf1wxoN4jb6UXKpjt7eTXr8WZj77Pfnr1P7Z7Ivor5
	4Xnf+LVFBo//jcT6dKNQaAOThLvETlfVgQoHIOOESgFidz9Brut7MXJQ5rbt9ZeQpZQ==
X-Received: by 2002:a62:be13:: with SMTP id l19mr39200855pff.137.1557201973296;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYnM30oeQeIymUoYTTPZatErDjKdSmgbBG2UdywjDBZKnJO0mM69gS12S5M7UDrUL5/C+c
X-Received: by 2002:a62:be13:: with SMTP id l19mr39200752pff.137.1557201972099;
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201972; cv=none;
        d=google.com; s=arc-20160816;
        b=WaYkUkg2LjkupvEs7cUHnFvbzKki4DFmy0QQf+rTsvezFHIcZvuLiKlRwpJinr+sjp
         X33nV2OvBkQP2gHVVI6SVS/rCJ2Rn/QxzNX8LscX/fROsdshpcWbp6oY3rCsMgnkCjwa
         /Q9+Gs16jchsF3wTmscN+AICRCB/3mbXPGA+Ha+zIJ4YXTU6M+qCzP8A1Thzd7KdIpU5
         L4ivP4gauKTH07tHq4MvQJN9Uh8kl9vQoIN5A9qOvJpxUccB+XPDV9hivtr92obfLVGc
         1+ZUMlAxqeSlHAw3sTG6kklwmXJa6yIifumdYhPMNVibxZ7JjyBropu1E/whLj8qDoL2
         6JRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=khFvxsLx4QWnQkDuPul5jtvX7t2XfQXch+bLgFiUiyM=;
        b=OVzetjokvyfcwjXWj7G95WkvVC9wW7wYVm7mi64/vSxZRpyROxDcClp8xdvzkIY5FH
         rBTrIR8xJGi0t45bSv6c63tlO6sM42g1wGBNCJe8WRFAFR9rK2ER/WzjuFP0MzaPxhd8
         2y4GjtNhqXlRx1v0ER5aInQz5WxpT3Jc1VsFtmlYOwc3mBM/bkZ6C50r+8wBiDnc88Mh
         YdJ5TSilbvZqaZq8WgxvJawkhRtJ09fL1e8ABYaG1SXkMw0rw/1abeHZ1FR2wCwj/Sjk
         xOikfXJE1Tfzt7zASZEBZk8gocidtFbgIKiw7Gg9Zuae8dl2aiZ9sL5vDo8fXQply8Ol
         ivUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QpA7NsVg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id co15si19604448plb.136.2019.05.06.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QpA7NsVg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=khFvxsLx4QWnQkDuPul5jtvX7t2XfQXch+bLgFiUiyM=; b=QpA7NsVgcJhGDY7w6wvgzKWhJ
	XSZ0Ha1kTsPZcKq8p1GM9Ngsdwbvh0XEgg8T1JMAgqLM4ERshOmux0R54XdbswvKcF3pZFSbsW1Lm
	EzEUlGeXSJ2RN74qURipWGIxU8o4MSwTbskgQu9RPxFIppqpCg5cFHJYjSHwt7aidyshgB9NVuTq7
	N0Aq0KjAyIm6NA/S4Xl71uWuNvEVrofAxoECPYyQghSeWRzgsrPjH5yB+PjgQ/tAtSNJh9OoCzNJ9
	EUe+mqx0mZbXQXWSg1Xlmm4LICUhOhQDIwC0j03Fs5lIbFNDOMvtNMltcq+F0hC91cdwJuk5Fx3bV
	eqkAf92Pg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005hy-Kh; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 04/11] mm: Pass order to prep_new_page in GFP flags
Date: Mon,  6 May 2019 21:06:02 -0700
Message-Id: <20190507040609.21746-5-willy@infradead.org>
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
 mm/page_alloc.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e26536825a0b..cb997c41c384 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2056,10 +2056,11 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
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
 
@@ -3598,7 +3599,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
-			prep_new_page(page, order, gfp_mask, alloc_flags);
+			prep_new_page(page, gfp_mask, alloc_flags);
 
 			/*
 			 * If this is a high-order atomic allocation then check
@@ -3828,7 +3829,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	/* Prep a captured page if available */
 	if (page)
-		prep_new_page(page, order, gfp_mask, alloc_flags);
+		prep_new_page(page, gfp_mask, alloc_flags);
 
 	/* Try get a page from the freelist if available */
 	if (!page)
-- 
2.20.1

