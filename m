Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 088E0C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2C1821473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SIOUKYPA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2C1821473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 813F86B0005; Thu, 13 Jun 2019 05:43:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C6166B0006; Thu, 13 Jun 2019 05:43:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 665FD6B0007; Thu, 13 Jun 2019 05:43:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33E346B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so14078503pfv.18
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kaMWV25JLh2oaHk6KDUPHO1aktYAmWaT94i0RYQYzUw=;
        b=uWqjbscCu0rtf7JCR3ePpCSVtC6rMSxefKz4/6r2ZGVjDJscYmANDJ4rJOrKlmZqdm
         XE2RgaWqR0PwUXdyvDyN8nF7EGOx6OsTGrIESKDB22whZD2qlfwKbTtZzmwTWg5TmUvb
         HB2PUSeZ65KCi46i4X9wLC9cN6qTHG6jG0XCA/JHIDlgFugoq9GsQCHdjoXtDP0qUjEK
         GBlztPgpLC79h3jpQCb3oNd/7x63PTn3WMOo4WU19yTPiAEPoTgVmIKHP+Nk99SAx3nK
         UVAIuDBD/CLsGaBXldlGUUnQ+7PAdNVIYV09bEhp/tZSaE/HsAosUh6/zRRxjcLRRH+E
         /AfA==
X-Gm-Message-State: APjAAAVDqfkQoK16xEENkqCUiY4y8MeVdN30TYSByyferOvDJgi6zUYJ
	cNTNsWQeK2IYeyBAJOMQdHmVm5tE1AwC9CkBgHlRz19OgPQ95WAtDKwKmN6NULEB0fkq+mhJLd3
	CvECODlpLET8gmGxGl0TfYkQk7QbAo4Plv4qS+Si+GJFx4XgAIwKJHcVIKe26CO8=
X-Received: by 2002:a65:624f:: with SMTP id q15mr29518977pgv.436.1560419017772;
        Thu, 13 Jun 2019 02:43:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVhf+yBHALIj8vG5Tpjhi06GGlRVpl+cdCg8yXqMBL5bU5/3N7nRhPjoPc2RRp9yrxvN0a
X-Received: by 2002:a65:624f:: with SMTP id q15mr29518871pgv.436.1560419016683;
        Thu, 13 Jun 2019 02:43:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419016; cv=none;
        d=google.com; s=arc-20160816;
        b=jq31rAn4uSoP65Zff3hsaRBSgo9vhfxP929+VM0HaoBB+sEef7S+dcEPTXPTEvNi+I
         AbZGYzE6ieXtMeStp9pi5yChLuK+fpDOmZhFhd5vSc0whB1Qc+NcDxqGInYvZDHNkJhB
         Px/QpsdFRm4LLF/fYibC8F+7mWF4mitiPzP+KHdEqwqja10Y0d58rTQjHJ3aTKbP/ypY
         HVxMrc2mAfKtYwsu1VbP1Ogk1MoNj84v55z4uYErM1dpXewSZlEuSk7+Z7yLDQGtXtrX
         Wd79ahB16GSarCFu9Gq5GU3w0w/j1PQgCqR2kMGbeg9KRsWWxW75O9tggFBBcfZ59xZi
         pwiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=kaMWV25JLh2oaHk6KDUPHO1aktYAmWaT94i0RYQYzUw=;
        b=dLUIgC6Q7ex9b927ZG+F3S3ju0kMOsR3T6aqa6kjFCFIpjTL+/GVBqd3yxEFJQVqZZ
         J5pg9WPFYKz/sgGdmKoUMVsdrGJrlg7BB6s3YKo2LdNID95mjG1kNtnxlkt/nMSPMUwX
         7m0+iM+e1bZOBh2fv+/d8Gtj+1iMcjeH8YSDAIiFR4L1R8DmjhkAq3OK75dJCpcXyRBU
         pwEDc3TJWJPLvDqOdQsbhxd3LVPJ7+BMnRXpK9Tyt/nC+a/qaWH6KBS3RQqnvN9jbNt2
         jR4UD2aQ0WujAbFE7CfYfl3qT2295Bl/jXuqxFUGTG9CKZXm4HAqBSXlZYqmTDRSKZHN
         YNlw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SIOUKYPA;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c8si2627276pje.30.2019.06.13.02.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SIOUKYPA;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=kaMWV25JLh2oaHk6KDUPHO1aktYAmWaT94i0RYQYzUw=; b=SIOUKYPAoDNdv7dWJhGfW0ob9k
	SLpR4leODIPqaX5ZslP+W4SJcJ9U7DECzPF7id4CLr1TIXVk0TrdeRnB2mSBfkwHV0BwXM9hz+pAg
	MRIkDGTi/GEKbHR7IahvnzYVCFrGOql4J+HQbbAxBYnBDBvqLJf14fWFUzQPYx6sWG+RncvSxlFHs
	UVuWutw1NZcBceRsSHnUv96ep8AN6pJSCjApiFhahvIwVDcAXbo2avAu2oiRkulO4cM29bofUBPE/
	aJ6WgM8we7zOD5oK498LUnb7YTFkOzfiKswyBFy1ZCZiC3yGAwDX1/fPAToXlZJ0IO1qvMnAWyaKu
	nuFh1UuA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGa-0001jn-7o; Thu, 13 Jun 2019 09:43:32 +0000
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
Subject: [PATCH 01/22] mm: remove the unused ARCH_HAS_HMM_DEVICE Kconfig option
Date: Thu, 13 Jun 2019 11:43:04 +0200
Message-Id: <20190613094326.24093-2-hch@lst.de>
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

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/Kconfig | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..0d2ba7e1f43e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -675,16 +675,6 @@ config ARCH_HAS_HMM_MIRROR
 	depends on (X86_64 || PPC64)
 	depends on MMU && 64BIT
 
-config ARCH_HAS_HMM_DEVICE
-	bool
-	default y
-	depends on (X86_64 || PPC64)
-	depends on MEMORY_HOTPLUG
-	depends on MEMORY_HOTREMOVE
-	depends on SPARSEMEM_VMEMMAP
-	depends on ARCH_HAS_ZONE_DEVICE
-	select XARRAY_MULTI
-
 config ARCH_HAS_HMM
 	bool
 	default y
-- 
2.20.1

