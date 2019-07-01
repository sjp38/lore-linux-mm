Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3B0BC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0CC8217F9
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gymyO8jY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0CC8217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583AF6B026A; Mon,  1 Jul 2019 02:21:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 535568E000E; Mon,  1 Jul 2019 02:21:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B48B8E000D; Mon,  1 Jul 2019 02:21:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id ECC9A6B026A
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:21:15 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id f2so6765200plr.0
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8byVWDDjomwL6qH7S0OtanLtekPodjhPaEDKqBoEUGs=;
        b=iM+k4TQ9y/HCDiUPetTSk/Q4pvARJD3tFcDnlrh3itLdPJ0Bj03ph0o8ulCLA9PfZp
         ikb9QqVg0B8ciT0So2lVNrwa/PL+DjocFjUj6YOv+KdOq85iq3TcdyTWepLfV1mPRCAe
         SWzMwZR1Uav+kLZboPULT/tNK4kYkwCvNrfXYMK9lNb6+cM0/qhL+ZNstrzlXYCN2yHs
         /M+KoQuT5vtW5CAP6BWZTDy6+MzTu6DUypubgfCwPfWS0cXa/cNxt4KUMhFI3KuPvm9A
         dtxnp30Ewez31og1whVbv/WTqKxUlaMhMT2mxD96kgt9fvUfIdG0pN7i/xcg4E3+H7/M
         ZHJw==
X-Gm-Message-State: APjAAAXigobMBlQcefvFugrWZLSr0UoRMzXScds8AEMyIetiurVtaa/7
	xVatbhOK5a4zD3ipVDAqOAm4y7im3iixWcN0maJ3boJ6R4Qd3AHwYGN7pwihQn/glrTpcLMwY5G
	ZgQx1QdBSmrgXNbuuWSxvKgDMkGT1copPN/UA16Nkp/1fcOPHhYCipmc/pIiGRAE=
X-Received: by 2002:a63:f346:: with SMTP id t6mr23902861pgj.203.1561962075574;
        Sun, 30 Jun 2019 23:21:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfb1K3by0iHTgkArt2MsTrN9EYQE793rd8KnRhWOCiuzwuEueSzPRbr77tludB9rIKLaTN
X-Received: by 2002:a63:f346:: with SMTP id t6mr23902776pgj.203.1561962074494;
        Sun, 30 Jun 2019 23:21:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962074; cv=none;
        d=google.com; s=arc-20160816;
        b=zQToYprBoLNqdm/mVmx6KBBjGtgm5XqsVsC8ZGIVRE9AVW5OpkWKBSrT+4Tw8gHmy6
         u5TmwkAehap1HyTITbbw7dLbCuO8wN+c5C0kweIFGzGJdxss9jWuY/c8gcZCMzuH8L+W
         FLJsnqgm8DgM12q5j0rxR3G59Px25j6JkXqlqfiOzjM0djWko6fVGORWkT9cYcm4QK6B
         4weaO6a725q3R2LBnp04GEa+ltnE5BVfREc+aZDQWxlFdosAHCS/owJcCTMFl6OH+tOK
         0+ngFWvbcmBnATF86GJoxc/WIuVfsK8UFwloAvYxPR7nNuv5YTzaSbgVC0ySfqhQcGkJ
         xDDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8byVWDDjomwL6qH7S0OtanLtekPodjhPaEDKqBoEUGs=;
        b=OzrfnIqYAEXVaM1G31kRCokObe4Y01GKMnXWP+yn8ZQtqVvXWBphHaDD2kxom7DC65
         82RGiUNH6sNXWJBOtF6M7dWpr7ksTkzCDP5Icf1gCwVngbev1qY7VmqpLxWXoa+a9OJF
         nFZuMP7DplANUw/UX2YI1rrHx9y5ydCAnpnUfJUJw33V6NHDyS/q97OInEsvORqV1zHG
         tA4wydE0LXYX9rKePbKouAz/+eTEWDoEIPI/X2dlgAFcsz/CUYx1NgxlcmpTVKIo3Sdx
         yqI69tpJbaSG6JflFATPSxnnPqXYhdX8UyiJiLkOddv1HMarXLeAu5FA7zIU2pF26lF2
         dx4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gymyO8jY;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x12si7260142plo.64.2019.06.30.23.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:21:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gymyO8jY;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=8byVWDDjomwL6qH7S0OtanLtekPodjhPaEDKqBoEUGs=; b=gymyO8jYdkpQB45FPyoqo5QVRO
	pxdxLE/pukS1Gk+9MEFhUMYN00wWfJtK9mHMqd13ChvWkK6i3fJFh5i3DGPvBqQ37V8+yF0igt9nN
	Y9V4N/egahV3v/1fcDcj6gtqMt3/1tKmCmBZNUOPuZDmSMXGT7uyE2F/3McRlbRBhxwK2jh6sWGos
	ctgD/8HuEKjDbXkk6fDiLK/fGApomgUO2pe9gIo2ZW5OLFiUrBVFWmZ11yFMq+imU7W5vNvpz+ObV
	JvmhVL1Q0WzgqBRzkrgih94Su6CSqN/FTPUhjuxgRAK49QrB82cKbelNL+xMhaE0alH06JPe6B65V
	JIyEF0zw==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgd-0003Y2-QA; Mon, 01 Jul 2019 06:21:12 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 22/22] mm: remove the legacy hmm_pfn_* APIs
Date: Mon,  1 Jul 2019 08:20:20 +0200
Message-Id: <20190701062020.19239-23-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch the one remaining user in nouveau over to its replacement,
and remove all the wrappers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
 include/linux/hmm.h                    | 36 --------------------------
 2 files changed, 1 insertion(+), 37 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 40c47d6a7d78..534069ffe20a 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -853,7 +853,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 		struct page *page;
 		uint64_t addr;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 3457cf9182e5..9799fde71f2e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -290,42 +290,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
 		range->flags[HMM_PFN_VALID];
 }
 
-/*
- * Old API:
- * hmm_pfn_to_page()
- * hmm_pfn_to_pfn()
- * hmm_pfn_from_page()
- * hmm_pfn_from_pfn()
- *
- * This are the OLD API please use new API, it is here to avoid cross-tree
- * merge painfullness ie we convert things to new API in stages.
- */
-static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_page(range, pfn);
-}
-
-static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_pfn(range, pfn);
-}
-
-static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
-					 struct page *page)
-{
-	return hmm_device_entry_from_page(range, page);
-}
-
-static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
-					unsigned long pfn)
-{
-	return hmm_device_entry_from_pfn(range, pfn);
-}
-
-
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
-- 
2.20.1

