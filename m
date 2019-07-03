Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3628EC4646D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE1C121852
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ucKTI3Jt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE1C121852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2385A8E0001; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2758E0017; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DA188E0001; Wed,  3 Jul 2019 14:45:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A12EC8E0017
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e95so1819424plb.9
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6gkdMJihz+BKdhYSYDXoVp/HUiw1Ip+q05LF7yiN7rY=;
        b=uIxrUh5opHvg/TbCHllvyY7bSj0xDeGsx3FlB4fg1g0R+vhVX2BILUXUsBwuB1x2ro
         LuZvxUEZsJG6gAJKYp9CDWHFYTsyjZcvdGIyma3T5J9VaKh9TzemLzqlCs86Ss9CyB9m
         sxWWTcSVqu2IsL/hMdPFFL11j+8NzQW+oRScciKVBt48xvH+FAjsSmoIP8HS7PIkCvaM
         Sf47eFHRdLGfgGTn0YskLf6fZtCwE3d1DVhkjDaV5+7cYoi+tXG13DnyyMkToczvsI/M
         JJB3mK0j9ASX974Q/LNGe5dYMO+6XqDO/vwh8JKtG01o5rJELzvH5FBt7ncLX8duW076
         R4dQ==
X-Gm-Message-State: APjAAAWLu41vBM9K/aP1IVfXZAr2D5uFBRD/dI4a+wNds070hB/2f8ER
	bwzAu+p1Ve6NVr+k0d3kAN92Y0/lFCPGoKxMaQc137QdfmecM1l8l2O7iHSa/OpjXWvH08egLb2
	fkeYX3J0SA9xRw2oi0A86YIGWZb5G+EfI+3M67IY0BBtEreqg/+S+5DmQh1W5c+o=
X-Received: by 2002:a17:902:8d95:: with SMTP id v21mr43216334plo.225.1562179510235;
        Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJ6v3kqKc6KtWowVj/BNYp1CqyfhRPLvXKkP6TCdb1lbxchk8ZBCEEys6BtCgG/T1HsSr2
X-Received: by 2002:a17:902:8d95:: with SMTP id v21mr43216244plo.225.1562179509154;
        Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179509; cv=none;
        d=google.com; s=arc-20160816;
        b=vwOVqEopM8jjoNQKUiaZzKEX2O5kNYe0qaacG7brmkV5bLC681cIhqeRLltO3++oxS
         RGjn04pQUb+gHMkukdyBhjX0FJI+OoE44orGcnktMXFfe1388mBqUwkYSRUfg4tLyk0P
         5ewzY8ED22CdQYeLNB6fiwtO+Q4XaRrUtwmv4VBcQoXY7iu//+TwtTIz2VQUuxER49Ek
         +HeCJnEeJZLkAuYtsDC0NBaJdk4fQOmRlE1zD7AzOWafcCvH2Jk11ITifKK1TA62AhVt
         6ogvwu6ELVj+gEDs8mj9AhxoGSztYicSO6UlZsShqAjKn0l3N8YKvtIr6gUaaG8TQd6T
         IgVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6gkdMJihz+BKdhYSYDXoVp/HUiw1Ip+q05LF7yiN7rY=;
        b=bK+B3Xciwrh6RE7IadP80JcN+5yhhAo6Z4fbHC/1w74VTjHxKS1qX1r4e6F7kKbNP5
         cyKQ0TUDck1iX2fxId2ELdI3d0Su6pRODcs357rDDtzYmIdYB0cQtsSujrlNXh1Repy3
         qxtT/TZ26MDnETgQuYYXTDXW1xo41Y2wX+GmE3Wee/0XxVRlnhpFjQHEvGOPZkItIilm
         cZU42Nt8+aglZDSCK0l2tb4HEp/9gMK5MY2LbRHh3lD/hY2yrk+yXx2KNtij1fdXGm+/
         We04RWfdIg4GpX+256uRXPiBiZD+Nc7ZRTyeyBMOwavj/sl11jTmOxDp9hLF6fd8g9wD
         kHtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ucKTI3Jt;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v38si2850319plg.277.2019.07.03.11.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ucKTI3Jt;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=6gkdMJihz+BKdhYSYDXoVp/HUiw1Ip+q05LF7yiN7rY=; b=ucKTI3Jt8HPKO6aQAQZ7BDiOrL
	JA4m8aEc2YkLhNz0//fOAOG6Y8t08qWufStZFGqAnWYxKPOi0a76+qnTmd5O02jnsQMB5pruHubyf
	/2+F0XgKJFWuWREiSjqaFDrVOJKlrABvu7R9hLTeiH+ikhD5ICmo7sxkL1FVc71ucDmxQPaEFEyXT
	Ibj/z7a8efuY6jJeoXi/uVQ2G5dcgrA2Efgd5ddEDS4sqPaWFIEnuaEOAns4nwG8p0iebCG9bj478
	2Tqro3odGJdmIAeBqlMIQ3X+fYxnvypX3SWREdvaaSH7rNfG4Y+OliRWm7B5/p0tE6DBihH2aXHBw
	So0kvONg==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFc-0007IN-2j; Wed, 03 Jul 2019 18:45:04 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5/5] mm: remove the legacy hmm_pfn_* APIs
Date: Wed,  3 Jul 2019 11:45:02 -0700
Message-Id: <20190703184502.16234-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703184502.16234-1-hch@lst.de>
References: <20190703184502.16234-1-hch@lst.de>
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
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
 include/linux/hmm.h                    | 34 --------------------------
 2 files changed, 1 insertion(+), 35 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 42c026010938..b9ced2e61667 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -844,7 +844,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 		struct page *page;
 		uint64_t addr;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 657606f48796..cdcd78627393 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -290,40 +290,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
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
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
-- 
2.20.1

