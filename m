Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8DA5C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D7A320C01
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nqj2e5EI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D7A320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B3588E0012; Tue, 30 Jul 2019 01:52:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 665A38E0003; Tue, 30 Jul 2019 01:52:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 507228E0012; Tue, 30 Jul 2019 01:52:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19EFB8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so39832843pgc.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oeVqzqKgfl2aD6OHsHwpo1ch5592YFZchzgyQdMtYkM=;
        b=Kyjpc3REhGp9YhLx8y+0f2odtrovQetjbh80uOdXIewiJukcUjS6CGnVm+WVY62fZz
         BWxoODst0KDiqWr2RDq+3a7ldMkCelAFk2mTi3tf5w/oS8vnN4beCT65/i88E5fsxmtc
         L/l0GhqRXohOMQ/kaTfmSdmjFGto9mHyBWbt2cRUSqODAZQQoVwl37/lqOHe5SvVmKgy
         t2YBzyD4dZMijNp5GpBKW8zvWYkFIA5GHx/s3fgAoYtkMH4onBDpz04+dF4Pm/l8BZsp
         83MzAaLlDYb8vVRsmNwEt1jc+6UhQGEW3joEEPCkkNrfIle8VFLW3qK+mQg2SkfS3mF5
         kkBw==
X-Gm-Message-State: APjAAAWbS9su7TMuSoSo2VzX5w9cvYUSKdaOO6NSMonRrMW01kDTW88a
	Rc9mroxB65M5mzmMpyg4f940IpX0YmrzzCQmi4H42p1TlwwEMXSXKne/mrmjl0/S12toOo8GnfS
	x4Lllo8w/uAGsQeRiLpYRl4UEGnooV1M96dLpl5fnrRrh404FHzBqGU1efaNSfSA=
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr115830184pjd.122.1564465977811;
        Mon, 29 Jul 2019 22:52:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3VlGYGqUFfU2cfgdR++dIDAcqErBFCYf57Ax3CyetY245jOZFH2/iIgy7KdOqkn1bBf0L
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr115830161pjd.122.1564465977166;
        Mon, 29 Jul 2019 22:52:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465977; cv=none;
        d=google.com; s=arc-20160816;
        b=OBvBajB1ncWwbGY8ESY0PJrbt9Cs9RG52WitLYjjFS+zI9BkRjIgQSseKHRlk3pfgT
         2Smkf1En0hXfnGUS7p6JcFQhl7tnmHHjhbCL6QFt/rw0E0TTZAUIkvjVnh0iDB/g7BwU
         q18uNHqCs1RqTghAP0WBga8r0qectTaP1wdB5RjveQ3nS2skCvoc5gPuAtdM8CE49ax+
         NF53I9+9f9nsi1Yjl3HNJ2wkBl1ftK5npkquFCzkcKnIhAo0ZsD8qCtPwCBpOZm9A0hh
         3x8DsxIJLUhRrDl+oWp0QT2vUE3uLs+BOr4fvI3r+VEyv9KSIfq9y3BIvm7EzFzEQnqn
         j4hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oeVqzqKgfl2aD6OHsHwpo1ch5592YFZchzgyQdMtYkM=;
        b=j2YBxECFQIdAskunZMun1Jbth3viXnP+gGIy/GQ8rijY9eKYCA+QWV5nKY54vHKASP
         Qk9ekeVXR9Kyz8LdSFTXUOkIj3IRiEuaNSqyS9b+Iqu4TcQK9c5qnHxmTwBK3KvyC4xQ
         cqbw7c3e0TiGU5CXmLA7QXL/tzVSGtrHPqyp+CpbrQdSsDQ1dDJZNZwfI0TnROeYoAuf
         BWiXblfaut9psPrb2SJ0QFP4c7lPJwPtytCtjraP41YWMoJQ302C17DQ4ldieuY8oCe+
         mVhA5k/eBxWyDTaJSYAGsSfqy7w18QGlPBk/J+d18FWcXn1FMgA9n6fe7ZqCL1wItgIz
         srxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nqj2e5EI;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o8si27392429pgc.179.2019.07.29.22.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nqj2e5EI;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=oeVqzqKgfl2aD6OHsHwpo1ch5592YFZchzgyQdMtYkM=; b=nqj2e5EIZMkVf+8w9hLeGVYCxs
	wdgEDivjCVoIGZbSaAkz3m0Aa7F44xnNI9z9ymc+9rjF5EAY5xgPXlBSUFqXLwPFeeVU3p8Kny9Ci
	fVesCkD2VXf5mq/sNI7dWav6POKUDEzzF4PFZkU+Sp4ftE+haMVcYARlpyIu8wUu3FtqOLhPpXRx4
	rD/U9jRX3Vp4sKK2FXFKTxABMdp8hILpluwAqHq1MSeceWcuDL5ShI5QKZN89NMwkOt6aavp3OD+F
	/euujoS2VqYYiPfYoUIBTNX2wbHkZ3H2aeas2hZTAbQ5Gzd5tys/swezApCF2bDC6z1pzrN2v5hnW
	AibQy3Zg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL49-0001W7-9f; Tue, 30 Jul 2019 05:52:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/13] mm: allow HMM_MIRROR on all architectures with MMU
Date: Tue, 30 Jul 2019 08:52:03 +0300
Message-Id: <20190730055203.28467-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't really any architecture specific code in this page table
walk implementation, so drop the dependencies.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 56cec636a1fc..b18782be969c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -677,8 +677,7 @@ config DEV_PAGEMAP_OPS
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
-	depends on (X86_64 || PPC64)
-	depends on MMU && 64BIT
+	depends on MMU
 	select MMU_NOTIFIER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-- 
2.20.1

