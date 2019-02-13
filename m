Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8665CC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A7E1222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="THQG++2+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A7E1222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F2E78E0001; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CAEE8E0002; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8508E0001; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED408E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b4so2203854plb.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EqKUxXuSonkTTvkNlEundh14K2DWfFZ464FMZZAxl7E=;
        b=jqkqhSDwf2CVBKDbUw7GZai0Yf0u2RhpKCAs3xWKXFnt97GFRF/zmtoEs8vNp9V7lt
         VfqqfHM9mccwbladE7GXn8Ns/1wwiWFEG5CPX/F9jE1/91DppZ61WLg7JN/LBWMZhGCA
         Ptd7f+mpKs6DijkwIUZusStPqFPVGZ4MS8kjFgUh7m5OW29u5V9GhAD03ACPUtaw0MkN
         HBqJC3ZGELjRKIaHco9UdWNTM64dd67giM8JowFDNOovk+EfV0yHMpwni/jTEl6RfL6o
         xibJy1uDOd8LdIQRnI1ewh6y3ITpvYXDCzf1mGBryFGQY8g/NAiDdPS4dmoH0qIMUZVh
         zdHw==
X-Gm-Message-State: AHQUAubFRO4yFPnSRQaPicGXutA8wkmb1fH8/cAa1k0KPWSR9g0aV7pK
	vuPyPAtj8mU40eUxf1v4FyjnTKQWFVGijTlc4YEA1BK7uVT4kYzK1L/krOCKbsukINPiP7mRSHI
	/LBjRMo6Qc3guuHGTapdVGLqUGZ0j51mZpvByLI3R9z1VfrJQhB+DmvvuPj2bFfI=
X-Received: by 2002:a63:730c:: with SMTP id o12mr1515112pgc.270.1550079997661;
        Wed, 13 Feb 2019 09:46:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYrvCgzMiuq4+XYVfuXqJoq+I1LBayaSeqqkrUk7MfgJL1yNu7wuryEX2T5yrGi5o6Zf4gF
X-Received: by 2002:a63:730c:: with SMTP id o12mr1515073pgc.270.1550079997009;
        Wed, 13 Feb 2019 09:46:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550079997; cv=none;
        d=google.com; s=arc-20160816;
        b=oTRcWyTMBb2G1Rwc03YrN1bUn1D0Gci38nuw2ycRHtu6pk47NMY9GnN/sE8QljDckB
         NvPBEtVYKBtzOHgPJ0/EILALoicUeR4s6QLNB2DZfBVymqklF7KRhGQ80bNP6ZIT5JcE
         Uy796tQCqK0M6vz+AcKTewwpPEhhraxwtIkxS61fly9/p3f36EDuRZ2cxRjA8edTPT9b
         9cfj1Q4KYVuO081Ap2iSVbi0+VA57a6F3TMJY3iGeQHukQBs5e2et7lETX9ff4SSmazn
         dycsrLUYE3mi+SnQeFCG+DI5M9INzLXy6v4hir+LMFf/DiyviiI/kMcTM2yfRUkgsoPt
         f6gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EqKUxXuSonkTTvkNlEundh14K2DWfFZ464FMZZAxl7E=;
        b=zQY7tp1gVl9ZtOl+fJdctGwFpL4sMizNndgptfMq6Fmg9q153QyQP6fSsN9aR5hAhi
         4tbmAh3Z1xKfWDgSU1wyQBXvhm80mnb2BgHK5Gk029DN/+XU7O/0a/lDhjowggrzM5BP
         gs4l5YmlN4U6a9Uo5NGdtQuJ+YH1tj3s+ESxkJNUxFLsLNK2SrVYg8URsUAaGQztrywA
         RfZ0vh66y94ENmr0ElRKvj8Yo6GK3q3w2SVKGJVHECa0cO8pYXJM16BPV5fcyIcrDf5K
         28z6mzPEDFZqxs07kGZrHgtGtC1kLMXD6gG/WXmWRZssVr9mstOmtLruK7HP98r+1Y+B
         Pbhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=THQG++2+;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s123si9221148pfb.274.2019.02.13.09.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:37 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=THQG++2+;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=EqKUxXuSonkTTvkNlEundh14K2DWfFZ464FMZZAxl7E=; b=THQG++2+MpmCSvwZtsq9Qoqqqf
	4pcV87lepVdvEDJawizc06v8uTJiifCdLqFWYhdT2wo4PD9BaqH6zGTNiEp4I1icDbm/v2UL84LFW
	I5UqL2g2H2Pl6/sv5Tsvv6pO0pe4rvW135XYLfzY8clFVkZW9YzvAZnUJvCdvHkBAOQYCJfg4ttSc
	0U8FgGhAo9WR3OToYDnniks3nmuixZ9J1jvkgv2/DupTXIq1+zsvahcU2fDanry73ZPvYVSbxdwfK
	MO5KmpsBmOx19exAMgTEt9dwA302YaEAsaG8HnynUyR4xy7Q7WTpW5V4DB6ufo//uv7BsJw1a5yoY
	MWRZjbPQ==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtyc3-0006YY-Vg; Wed, 13 Feb 2019 17:46:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/8] mm: unexport free_reserved_area
Date: Wed, 13 Feb 2019 18:46:14 +0100
Message-Id: <20190213174621.29297-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213174621.29297-1-hch@lst.de>
References: <20190213174621.29297-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This function is only used by built-in code, which makes perfect
sense given the purpose of it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..45f12a42709d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7255,7 +7255,6 @@ unsigned long free_reserved_area(void *start, void *end, int poison, const char
 
 	return pages;
 }
-EXPORT_SYMBOL(free_reserved_area);
 
 #ifdef	CONFIG_HIGHMEM
 void free_highmem_page(struct page *page)
-- 
2.20.1

