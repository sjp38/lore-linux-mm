Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C256C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAB2C21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="L3WbZ0JS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAB2C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C10616B000D; Thu, 13 Jun 2019 05:43:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A88E56B000E; Thu, 13 Jun 2019 05:43:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83E7B6B0010; Thu, 13 Jun 2019 05:43:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41F0C6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j21so14098538pff.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:43:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FEkGt+ty/uGWp0o9n/p7YTGA7bk3QKQR9GKnB3yrWi0=;
        b=XdwKYWw6TQu2WFLmwZqkJpJ2/nT+RKGuDQj5Vzw+IM/NhsGM8B7t90kYeTb4TGCi2c
         Cm0RZr97ijYf8cWllmCocHX4qks5QBNFUKkn7yzDb0yj1erCFLmZXTOH8hBH6EzkU/Tq
         fmE5lfsRdRW+QbRSpyFLFM9+QNhdO9KN4zuWxiOBFdbN56wmFK3++j4SEBLWEBFjje48
         JdGnCRR1+L3J/FLm3164UBW3XSc9IwkIN6tqxVomUBWyG3u6Prnwfjhdn2Z3pS0bQjP8
         tHXE81ZyZVyB1tliII7uQO0M2Tu6P4wOkiJQ+NG8EMFWd4wyC36ODkJ3N1VLI7MbMf0g
         ufDQ==
X-Gm-Message-State: APjAAAXW1zrQaKNe2vG33HyxTitpjmffNXWGUc4P+RzjrhbpW4FffPmJ
	jFJSxAV39C5UWPjt5HUVLJ86JXO+IWB+IGCiF4WsKih28OFI4SFFpWfWUyVgNf+GNUgYN5W92xW
	IwntFQuWbkLne21G6TcOzik98iwPHvL2yRkRUTx1wVgdumXbmpy/t9pCudpQ7RH8=
X-Received: by 2002:a17:902:9b81:: with SMTP id y1mr62646796plp.194.1560419026946;
        Thu, 13 Jun 2019 02:43:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+rdyMeRPLCHteL5Q1CI+wW1V0nnmnyz5EW2QJvmEfuZSHr3aARoObL3Od2xjY7Rw4cwt5
X-Received: by 2002:a17:902:9b81:: with SMTP id y1mr62646722plp.194.1560419026324;
        Thu, 13 Jun 2019 02:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419026; cv=none;
        d=google.com; s=arc-20160816;
        b=TIdPQiBR6DzpXMHvPmF0lll2PBZBUW3Vs6Q2bG4rDGgtIaVH1dkFja2ReGD1j2AyaO
         wNT439hI+2+rnM3Xex/5hxzxnzD30QqOmldriPGV4QFYAJJFaXmfBV79EfGlu15TfSSn
         AFSZB22qPYuqOtR3FkB4wj5mW1aI4iUofpkssTUefYR/rUxCW53iSOrpgCxAjO4K8LGw
         Bk/lvOYTqzXxV7YSsHBAQzeV8SrhEdmHf9JUqMIE6XBuQLuwH4GolAJv7AFFn7h6QYgw
         pzeC9FxqLVVgFXd7FuxUD0wdA4pnGGd5DY1lL0Ep/sy7xkDP7GCFYQf/o7B3RjV7mHjL
         c5bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=FEkGt+ty/uGWp0o9n/p7YTGA7bk3QKQR9GKnB3yrWi0=;
        b=NbzFtNvpnRZHMCnFz63ciqVprEjg+5/c/Y+edvH2ZaoMGtX+FIfyTwHQzq1Lx+RK5M
         JYoggnyxu77JyIkYD5C9/G838oQIb/HkzwGXcbi0zZ/pzaC2B4SRqFxfBNSbwox6tnWw
         29AfJ8IMRdtVt2xyljCo9r+z8jYcqRv2KKByWP7G/KZObrifCZmz2c9nvuReDgmr+buf
         IZUEB/nVDflJwCPFWVWhAC0ezoWcWGyAXZLqH8e1lJnSJp/3lD0fqSy8rrLqz45LiOfD
         5LaUL2M6BpwsYO1cAZSPirG0+tmpcXzm1sq3Lo5ppcLVE8BO5WScvaAz8mbVHGtG72/P
         STTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=L3WbZ0JS;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h96si2519259plb.281.2019.06.13.02.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:43:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=L3WbZ0JS;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=FEkGt+ty/uGWp0o9n/p7YTGA7bk3QKQR9GKnB3yrWi0=; b=L3WbZ0JSiDvBXJFsDUCJ02wcbX
	BVJRpc0UiDSz8hdf9PGCQmrkNO9cC3Ct9Euv83j64Pvqa+bMG7zPftv6Qc47ddagd0apxJ3S9LtxK
	YL0Gd6JRejUQjbVJguc5cGI104IqQQmLmGxj/QrnU1/8eCRFXHiVtvxgGKwlwToPy+mfQe5RgeuNc
	7YyFcHDGYRl8yFp9cwxZhKia1V56GYhuyZqZJ3NB32yZYe7DQM/hr05KkwXqr/uf34lWIk5VMshTf
	CpMaS4eanmRpQSDsR1G7yDdfQpx78Otwq1ePYvSywGpRHwk4jd2yXAVh0H6em6K2SgA7+4HrNyFnG
	Se1/PImw==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMGl-0001l6-GH; Thu, 13 Jun 2019 09:43:43 +0000
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
Subject: [PATCH 05/22] mm: export alloc_pages_vma
Date: Thu, 13 Jun 2019 11:43:08 +0200
Message-Id: <20190613094326.24093-6-hch@lst.de>
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

noveau is currently using this through an odd hmm wrapper, and I plan
to switch it to the real thing later in this series.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/mempolicy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01600d80ae01..f9023b5fba37 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 out:
 	return page;
 }
+EXPORT_SYMBOL_GPL(alloc_pages_vma);
 
 /**
  * 	alloc_pages_current - Allocate pages.
-- 
2.20.1

