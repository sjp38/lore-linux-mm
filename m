Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DD78C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 200B120679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Bvgunk/1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 200B120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76AF66B026C; Tue,  6 Aug 2019 12:06:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F7356B026D; Tue,  6 Aug 2019 12:06:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5714B6B026E; Tue,  6 Aug 2019 12:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19F256B026C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b18so55204621pgg.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4qKgBQZXWXwTBeUsDVCjJZkYmTExx287iM57Vyx6Y0w=;
        b=sYvFKkpN85KFvNuTVicNWAH2DEuF3G9+8fQza7sZCFG9uBlY1dPGg9lFrNhIAHxKSo
         XYqppxpgHaHZZgH9cUx3I+etFUakUuF/jYf1EuVQ/dfn9thvNX2kskZpE1aysUmKiCXa
         BlU7IP/dX+qABXNaIYXqmAtSpTAdbwaFLr/PRQ8//LN1H409sA0yGm3+j1Xeovqmt60M
         4qLy7cx/fUSTlcvynhLuE6PS+xN4KGkYLp3UALovC0tbMSghpE2U8N0g5SSkuVhN4taC
         5Hd4Z+ZmeQ1OnixeUuiKOTBFj5LRJ0zXgV0OuvlLF3YRS75Jsaa4h9x5aaSqxa8GuXWQ
         D0MA==
X-Gm-Message-State: APjAAAUXsqUGX1VLyfPWLc7PefgqcILBLr7xweEumo03LsN+2Jqr5AJs
	nkhE+M/bci5L9kLUx+QTx+czHPYYQh3VSlwlA1CsITOZvsDK4JjgfcDVWIxMSBS3ByVDUsbOk/H
	M3xT8xmBVdbyeXcYZcST0ivy50H6HM43uzu9gjoiRAOxFN08p4fgrKPLEBA4ryyA=
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr4552063pfr.28.1565107593791;
        Tue, 06 Aug 2019 09:06:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAER+UVLTr+/QFtbIPal7LDVtGufR9PL5AsugCQYEIyeK7rgghgV8sYJ/8T07tkgEuQRS8
X-Received: by 2002:aa7:8d88:: with SMTP id i8mr4552006pfr.28.1565107593121;
        Tue, 06 Aug 2019 09:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107593; cv=none;
        d=google.com; s=arc-20160816;
        b=WWfynSD9Nt4IEGCnIgIcs9otWFncVi++RwkZ/c6sTW3mX7IEmZkhVOJu07ZzDANFxD
         kUhNwBi9y6ZzTGR8xbafEQKMQPN8D6eaNw8m+dcX+8y48driX4qBzQwkAdpYfkRNLRyX
         zRioF29RsGA0GEItGpUmfrO3P5iHnvI0o58tdYBWB+jMJMDHcyr2E4PijWVgaizuHGKv
         QaaeG1ow0RTtz90lyeO+bx9QZ184X+/rLHE+nQ1kacJm9S2rtivLuajAI5CfY+Xc8uHM
         T4BCkCg/VCzpK5p1TmcSce6s98+f7URtVSBHiaaM/uf+h6KdkROTPrJWcV5fQu8YHmRk
         VIKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4qKgBQZXWXwTBeUsDVCjJZkYmTExx287iM57Vyx6Y0w=;
        b=iIZUagCKyKS4UXa4bcufThf6y2WrDtuyQsAhOiqkAfeecWRQsgsw81cJkZCYsJPOWO
         hYaHdryuT5/3GY0N7P7oRkN079koFxkw/BVJZp32iQnSvWITakk6jkbeRVAWyvy9DZK7
         Z5+LgYi6eyQvlayaRhbflPUeTVKlRLpA8eKMJmYHsZDD8jnh15v1ifMFotdJ8t/rYSpF
         4VJ0z6QgMcsNUP3RRaMd5mh9hetLmHWFhHsFouPfnrjDsKmXYssTGtmf9O5Ifg+qsd3D
         RSHPnfl16/5Asc4sIfiYf+oVYA74wwBxgqkcXjpUaDxOjKnHTNhFeSmSspreGWx0OqpV
         hUmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bvgunk/1";
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u3si43418278plz.201.2019.08.06.09.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Bvgunk/1";
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=4qKgBQZXWXwTBeUsDVCjJZkYmTExx287iM57Vyx6Y0w=; b=Bvgunk/17so9cVPFtrFvb/oAYe
	utWSSLH8JHbMNSIEnE52z7hb3mMGYEuLsxBPJwPNcL85QDt9s3oMn/8gSdfDI94Vl68ZYF6E2HTmh
	2CSuFc5mHOZpxHvRiBi4XMp/D2Nrz/C5Z8Sd+68h66wQQUEBe8/zuz5nTWImH5N9TH0oaGS0xmLSr
	nQm2HdXrYj1F4tz1jpUu7FGHbc5wwvCOeuDFImiYrzCOcbAZwn5cH6Dcbl32haJzzjJbE8rUkWbeV
	ySHWE4hYGGUpoGRQw0UfImuDAtA/m93vnOxClQ7CeTYmpjAOngizf1+aQKrmD52wW3gMGr5CLn1Md
	UerXxonw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yn-0000dn-PQ; Tue, 06 Aug 2019 16:06:30 +0000
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
Subject: [PATCH 13/15] mm: allow HMM_MIRROR on all architectures with MMU
Date: Tue,  6 Aug 2019 19:05:51 +0300
Message-Id: <20190806160554.14046-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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

