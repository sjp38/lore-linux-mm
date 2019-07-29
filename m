Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EE70C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBE77217D4
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PoRZVZGW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBE77217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98E868E000E; Mon, 29 Jul 2019 10:29:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93FD18E0009; Mon, 29 Jul 2019 10:29:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BAF38E000E; Mon, 29 Jul 2019 10:29:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44AA08E0009
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m17so29409232pgh.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ADCug91zuoANeBM/f4yCo270YqgttY1AZGH+RTcphSg=;
        b=LYpYCG6TI9/rZDp/u4XrCANbpTwIW0LOqGwyPz6MKTFgV6H8//oVvGrIBMnfH9yCAr
         BECgYxsmSVUSdqPuhaoTGeYcyT94XAIw0dEljEbSYJSMcjxtPD1m0cHAhmQ6fJZh0raO
         oO2oY50i1whXndDJEJPhDRSglcFEKHWWuc8VhTK48EEdBn04IUQiuKBHXHEN+pWmJTNl
         JKgvUXB00Ld+na3jqHEdjrXuPPRRG2dWnLglCFjd+dVZ2LEDXe//XLEU62zyFIUTkGCU
         EGYUWnqPaoQidkIDqNGtGNaEDhFPQVcN1lbrxsQ+t3m1MJFaES3yfYNGL+IS8hrPKLSj
         Epmw==
X-Gm-Message-State: APjAAAVoxTaEAUqPJv4dpE6Ym6Einpmiz+RVamRY560m1Ii/EogZAGk2
	z8ZBOmrtRZ4837Fz0nMpzqlKuGCgFzL6AyOQiTKWb0frB8OEH7yCgHySweX6/kSfW+3nmNF3w9x
	MJIFZckqSIVMDuyvtyO3WoUossvn7jvxyuXVvdZ31riUe3LH6aIO2SHJ8Rx56iVE=
X-Received: by 2002:a17:90a:26e4:: with SMTP id m91mr112646445pje.93.1564410557982;
        Mon, 29 Jul 2019 07:29:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUzTFTR4/zYCFwuKaOFxaTbm4F9FBzW2PC0os/2SP/OXTt0jaDaIXSGA6/HagBZLtLRPRF
X-Received: by 2002:a17:90a:26e4:: with SMTP id m91mr112646410pje.93.1564410557312;
        Mon, 29 Jul 2019 07:29:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410557; cv=none;
        d=google.com; s=arc-20160816;
        b=WxXysQAb++/iSiZnBJNRuU6J0Tidp6rp8qDHa/3khnYfxK1w2dwYgKoSgbhb4v8D6y
         PejILhRtlH0C4I2s5bAtcvJ6PMcGgRIdtv7C2u/M8V55XdHs1bZoolgm+dNHLv1R0n1k
         4SCOmP7yQFHHUOUty/lwWO+xIxj7q9sIVvb1BWq6S9dKl1iD2UDDilJwnbqSlsnAHL9Z
         EMT66uTUF1IMW2TDbYCNg+p8iIQGggF/Qzej6Hysa6JIxwH/ynPXidSw5Th6QTMAe9Tw
         wx0cAK5aLQKIW+2qntuHorqnjvaVYP2/wae9u+ezIrSTvMV0SYZABQY2SFJsE4ZqDnCD
         3HpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ADCug91zuoANeBM/f4yCo270YqgttY1AZGH+RTcphSg=;
        b=qtJjGzBYMTitPv3FfN7X9A4bXCBDC8JKnhOFy7jxZ/JN86ZvGU16Ce6FR5N+S2SaU2
         CwmZaDVwCe4SA2rUXKLN8R/4u+Yco+v0XJNfyjmOGuxlcmC1cSi/0g9aD04152hgD3Ka
         62W23DMkwpCUUBAbGOWYcHHL/8z6NqFrA3flO0Mloumfv7fJ2YRiURw19Wsc+7iQNtPG
         7H3Ak4MRn2SUw8a7Q9GQBL+qvoG9e1RI2RRTG4NL1lVL4haZTAisiCJ7Xu5ftqj96mfJ
         QeJAh+ncXx9W0PvLNCGKU0ZonbapWWcF7lVmYnkNW0TnvJOdei0Rqdo3g++hi0x7OtRo
         d4ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PoRZVZGW;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m2si26299413pll.374.2019.07.29.07.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PoRZVZGW;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ADCug91zuoANeBM/f4yCo270YqgttY1AZGH+RTcphSg=; b=PoRZVZGWUXTPpfSubNbeDA1LdQ
	b1LU/fQcfLbyytc2sKwhS9XHDPhN/gAt57LwReU5qOooafXp0ZDGWpFF/2t4PTI/oaQv6W14tY4mb
	rza6MeZTZ9XBJh/slw1Y3bcBA1QSUV+n4ZlZw0NYQfKPrQTDFtZI5E9tOFs20qu0RAJJTghI3SRgm
	YgD2M6gbXV0E6tWBxPYGCgN/DTlYlaMlgZrQe+O/igafLpjEuov7/uqXg2nCrGYgEePTo7BvTg3Gz
	k3Lax/R6rvcpq4mDKiz84UhDA+aZJS5tGJi7fwLDd/1s0vbKGIGuHFzxXh6MbT37dORGy06wuzQKy
	8BoJHZmQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6eI-0006N3-7M; Mon, 29 Jul 2019 14:29:14 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 7/9] mm: remove the unused MIGRATE_PFN_ERROR flag
Date: Mon, 29 Jul 2019 17:28:41 +0300
Message-Id: <20190729142843.22320-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142843.22320-1-hch@lst.de>
References: <20190729142843.22320-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't use this flag anymore, so remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/migrate.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 093d67fcf6dd..229153c2c496 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -167,7 +167,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
 #define MIGRATE_PFN_DEVICE	(1UL << 4)
-#define MIGRATE_PFN_ERROR	(1UL << 5)
 #define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
-- 
2.20.1

