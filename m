Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F57C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 597A1217FA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 597A1217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A6D28E0134; Mon, 11 Feb 2019 15:17:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308EE8E0155; Mon, 11 Feb 2019 15:17:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21D408E0134; Mon, 11 Feb 2019 15:17:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D77088E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:17:07 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q20so149760pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:17:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TQHg6IwR4b8K0pvszG7K7RRZo2PTFOf0OotO1RrVbyU=;
        b=RJTB5xrUVk5+MUXwjGM0PwWdv45OD0KESRsIa0MHEao+LrNM39/8Et2A7J1nDsVgoi
         xdgAqzSIFTVFWou/iUagZ4ES3TQOy1ZtZnpssBo2mVa9LOThNomURLEfqobkgUBzVoAz
         yVdk5zU+yMh35YeKjr2HtXTbszs3hrnqrksLMwcJtErlL11KW4FwFbxOBQNQp/tVNbZC
         yuH7D6uji0Z/OOP1X81L+w9nNjgBQGKre2nhtvB3TST4LQ/tKDOtQB72xOxBdAUWjjPV
         0P0uBFZnOQsoltDEGMKLcZmGlbmOkx01UaVZH6ytRFT/JPk/Xxu63F9rdBN9an1NaVy8
         YujA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYjGPQu4bAhcOmLEWFCpOTncy/HLLB4NCdBgWDC6X/qztDSnMdu
	F/L/ImG04q5AjMW1Iw4jva7bDRGr+IRFbVXyPQ3Gn6KOBmh5GYDQ03SfnO0hleYuyMRe5cuYOxB
	JPkWLI/SYtm96jaxRXmre7twdo3h6EqTXFb+ENnixuMksNvCEsgPrAidG9p3Z5uxzvg==
X-Received: by 2002:a63:2d43:: with SMTP id t64mr14300912pgt.155.1549916227569;
        Mon, 11 Feb 2019 12:17:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYq2T+FuwjusBN7VdP/bKKilFYIbXpox4+iiEaBaieV46mAzaK4dfKFsSdpIpoT63jl/0N+
X-Received: by 2002:a63:2d43:: with SMTP id t64mr14300875pgt.155.1549916226907;
        Mon, 11 Feb 2019 12:17:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549916226; cv=none;
        d=google.com; s=arc-20160816;
        b=b1G/DVaMeWni1b8mfCgaPjdWtf/xdFKKyEL4o4KtOj8IXR4zj/pu2WQwnKxC8y22EQ
         Do2TNtXQhrZaXOUz9wUZiVUsNuchB+L2reCEeLx0CJFNPN3L5icAVyoL8+duTZO9RPaA
         Ex3WPrropLJETv0epWpSvG65nN3VKm4wVnV4qdgpUXV/RzBDdYAzpoFadmjPRhRtLKNP
         f0mHN4m01vSZRh/HmIFItgbAy2eyh5/Y22YilSKzJ/hBq3A/4ZSsHw5qkRQOJsU4TplR
         iUNZsuBKa9q27hatWpKgiyfYZFBHYYHlRgcNp2nT7Iwt8nqxmSwGfpvVJ8VFPlr5t3vL
         Hjaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TQHg6IwR4b8K0pvszG7K7RRZo2PTFOf0OotO1RrVbyU=;
        b=MyEqh2cNwnSJRQ5J32Hc4BJttmPiDBXlR/e/4kxrwKIAykOPBSDgInDTlL4T3a1dR0
         0KWiDgBqP83IxQJUW9OYzDN/hQJ1womATyaUweVjY7bSmJ120Xhhk+tBVuW7qNAYaHGR
         ueoTIkxORKIna2+rdQ2C/g4WSJmJNEHUh7YihB7h//Mc+MFi6bxDzwcaltnhz3hpxinq
         xnB3jY3ZjWO3+L549z0+NyiXYw7+zJnvOhc6SqI0PsLwxh3EA2X3c2YEG34IXmobVpIR
         BlcQYor32m2+eBX3TU5b7Ul5O/LPT0bDFCUaOQk23E02bwhwrOFKUNPaRvxbq/VBrW2j
         BknA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v1si10376043plp.12.2019.02.11.12.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:17:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 12:17:06 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="319498292"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 11 Feb 2019 12:17:06 -0800
From: ira.weiny@intel.com
To: linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	netdev@vger.kernel.org
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 3/3] IB/HFI1: Use new get_user_pages_fast_longterm()
Date: Mon, 11 Feb 2019 12:16:43 -0800
Message-Id: <20190211201643.7599-4-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211201643.7599-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Use the new get_user_pages_fast_longterm() call to protect against
FS DAX pages being mapped.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 drivers/infiniband/hw/hfi1/user_pages.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 24b592c6522e..b94ab5385a09 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -105,7 +105,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 {
 	int ret;
 
-	ret = get_user_pages_fast(vaddr, npages, writable, pages);
+	ret = get_user_pages_fast_longterm(vaddr, npages, writable, pages);
 	if (ret < 0)
 		return ret;
 
-- 
2.20.1

