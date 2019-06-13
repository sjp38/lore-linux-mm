Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9CB6C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9911121473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rUn+qQEr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9911121473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FF1D6B0270; Thu, 13 Jun 2019 05:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 860CC6B0271; Thu, 13 Jun 2019 05:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6177C6B0272; Thu, 13 Jun 2019 05:44:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5D76B0270
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:19 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so229331pld.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AuQMTpcqJo62VjhPIKMCZhZk+h6e6THsOZ01qDGPkX8=;
        b=qONZHfzD19SWQCCIdo0LqtP11aOnmBvHfZJQAE7M6lEi+zc7rzKKuzwghVzWQ2vKXT
         7zI9ogjVbMJfKiMBeAWY3Y3MVX+4tOqJY60xoTxauMEJrG+1wV90O9NncGrPEFSnHyD6
         zxPWVedX5VXAMDrhcuQxKtYYU3za+whqHkAX/h09/Cu7B5tSWfJWf3oXhZRxCBQLjstz
         nJr5BY3OvKt6Mcc1Jh7YdvSIJO2JqWwJhx0qTzEH2ZZRD971ROBbNLaUFvIZe4QWC9KO
         oISCOc9MkrOSWmzKb4YFI6ohPS9m7aj9NbA5uP/nz5EAnEHgcCbivENYQFB5Js0lmSMx
         lQGw==
X-Gm-Message-State: APjAAAXoZIx0ekd5q3fx3FPz7d6nbFawD2Tr1EQufIOVIWIgppemJIa5
	NR5t4u8jP7IebQMthR+3o2I6h2fURgt11KWIlr/O1Pr7CdJ+/pztqu93DVQvgbqRUDSAH3gfZc9
	h1xV6f4ZoFvH4InwYPa41m9g/XrG3NYRW5xOoovrpVbPETRfzzWIF+KXB0/BNWVM=
X-Received: by 2002:a63:af44:: with SMTP id s4mr29593710pgo.411.1560419058763;
        Thu, 13 Jun 2019 02:44:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyjqcaEUiMTXYZY2sIvdUvuOFIXR2BbAJRXutdilVlZNo64ZZVR17AEm2W4gHtC0Qba7+N
X-Received: by 2002:a63:af44:: with SMTP id s4mr29593628pgo.411.1560419057927;
        Thu, 13 Jun 2019 02:44:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419057; cv=none;
        d=google.com; s=arc-20160816;
        b=d28jkLosv979n7+i7NlTHayG4dxLHPKbk+UH01TWijY4S96wj13z/q5tt/Aqwueu99
         ZcslIM6dLDg6HKKYlx8obi05J1Qe9I89+3+wnU0zYqiSZAL7JpwcHKbhMvnyzt4Bq5q8
         ZcMiMOEkgJDqbn9sWa0oTZVkZ3yyM/7nuMomDCZFeerUCu60PE1h6IWPUsD2Evp+dQPi
         LPXvL+22Q9cpXpmArxC1YJ1f6dfFvR6xx3J9S4IVppqQKbIceGmKY+2WdPOOIvm6WJPK
         BheRD1wblk1mEtj2uQ6zx/aLB5vP9uK4i9znfMk1t2iHvm8asdcgLQfsYvMLZdanHDmR
         8ziw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AuQMTpcqJo62VjhPIKMCZhZk+h6e6THsOZ01qDGPkX8=;
        b=0h+Dp0mKUu/Lrom38bTNbCJIo+DV5pWjP5jkRfLD1QagnF1pSRFbOIPvoVEm/s2yuZ
         Lp4SSHmkGHjdtgw+wMvmbBuEFfHiXrcdQlT/p1rDBCFRtV9uWAtnebUBGmOkRAa5/GEv
         /feLf1sPepkMPi5nrmQ+7e2oBVBnf2pNqAh2pl1tmaUmhrg9Vnth1Ohlx1ifu9nC9pDb
         XuNrvSlcuZwvIlT/EUqmPgmOR4ja0COoaM1MsyHlEOxeeRc1W2PW2QKDxWZbOsz/3x7c
         EydBdflAqZ4jlVQI43TUexqXWxvY0xeT5y12j1s0hEAZ15J4zLrKi4cC2+O6O7TeEbRP
         1sRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rUn+qQEr;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a22si2492987plm.343.2019.06.13.02.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rUn+qQEr;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=AuQMTpcqJo62VjhPIKMCZhZk+h6e6THsOZ01qDGPkX8=; b=rUn+qQErmwhgGijTtCS+CPfQfX
	C6JSAQ1wYIYTWBE1sk8wIkEnTQn0lkCbB5R+ffY6ISa5sjGbOSw0+7bEyC7m+Qij4zcVeeFUifawM
	Un1Dx3C+QCWSrqmn1w2RLX0JpvUup817a1QufBRSu4NPSt1SswH6b9wJA03REDNoLrDPDc5TclJrr
	xEr8kX7Hqw6gfUzged3ZKit4eyUFtG+CmH6acz3g27hPRgnBplRhZJoO5JRbm+/AUSeySbU2/KzoK
	i4uKJlLh0eU/1N6Uuc+zL/fMMHvYHpiCNP22jqmNO+zDGCudBxJG6+3+BI8MnXE1HOXlORblkJtCC
	FLHmz0jw==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHG-0001u9-ME; Thu, 13 Jun 2019 09:44:15 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 16/22] mm: remove hmm_vma_alloc_locked_page
Date: Thu, 13 Jun 2019 11:43:19 +0200
Message-Id: <20190613094326.24093-17-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only user of it has just been removed, and there wasn't really any need
to wrap a basic memory allocator to start with.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/hmm.h |  3 ---
 mm/hmm.c            | 14 --------------
 2 files changed, 17 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 3c9a59dbfdb8..0e61d830b0a9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -553,9 +553,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
 struct hmm_devmem;
 
-struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
-				       unsigned long addr);
-
 /*
  * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index ff0f9568922b..c15283f9bbf0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1293,20 +1293,6 @@ EXPORT_SYMBOL(hmm_range_dma_unmap);
 
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
-				       unsigned long addr)
-{
-	struct page *page;
-
-	page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
-	if (!page)
-		return NULL;
-	lock_page(page);
-	return page;
-}
-EXPORT_SYMBOL(hmm_vma_alloc_locked_page);
-
-
 static void hmm_devmem_ref_release(struct percpu_ref *ref)
 {
 	struct hmm_devmem *devmem;
-- 
2.20.1

