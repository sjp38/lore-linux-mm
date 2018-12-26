Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18060C43444
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4431218FC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4431218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB92E8E000D; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD32E8E0014; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FDC68E000B; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 522698E0008
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so17734186pfa.18
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=65FA41VLdlPtPOOJtgzAErEZDKqpBZV5hcSbMKUAFtQ=;
        b=TrpG3auKZuNch4U8E/ri4wqD7hkm4PyB2nna2ckpCam+BNKLRiXmynW+z4PFaDZRnS
         pD+SXwtwDEx71RPDnMOAn1OK0jkshbW6xaajpiBiIb7uFGn9MBJhO4NLoYgRExEb2Gu1
         wVMvOFksvuc7AV0+1/clTHpq0T9imZ0eOlj7L/QQ/yvBP563Lue1bnIp9xo+i9B25W0g
         Dhdn4SS9apiu2ltDa4Sw4fzRl0V2NZOs/c9t8X+MJ8hCgwgoRf1vmvbUe+lm9LrfCByj
         LSuYSFKjgtSsLwLtcEDfHUO2DHlWJm/hqqe6RBFOWrfrjF49fuFkrQBaGa3AFKF7ftxe
         wt1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWYojHMbwfefx0Ypwlvy4RBaQYmbR3HbNtSrji+T15fn5Ffn7A/j
	cJufDnMaVoF5Mjzkw6yiCvXLx+CeC2CY5gbGbGrQDHmXSTr7K59zWPu6bobJStZlr7izXdJe9L0
	mSak0ByGhwmLwW5ulDm2Qj16TjDBaPaetr2uXjJ7p76k7SVHW6456N4b71co0gYNG7w==
X-Received: by 2002:a62:4886:: with SMTP id q6mr20793806pfi.182.1545831427009;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WTkA0qJgvn02GtHzs8wBULK68frMrCC5uHcP3rqRITO7NnACi28diqlqn8x+6rlhI9uajD
X-Received: by 2002:a62:4886:: with SMTP id q6mr20793769pfi.182.1545831426376;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=s5aVniss+0Xus8g4eGIJn9JmiDIRUVx9Sk6q9UT9RMdMjiQ7FC3ekmJtvD+5OxSHZu
         qxb8bEZ9MfxGsLMvTdEL6zmQ1hbyZl8NF3NPFDRe7ObC4iw5s2CYhldeBKy06oO5cC9I
         yKEukCT3TKcH1gEvmfOahoILvNp7mFpyBMJ5crn0MBz1dhGJtVoa7HGJJAD57M15Jw4w
         g2hYwaJ98tuWv4490ZnbTSzq36Wq+SMKaTI6zNF/pzYN9aoy2H844QSKaWrZt0JBqhwg
         g4sT/r+uZHAtdfDuNb0WcsaDVqvYCrD9AA9mjgb5pUylyao6J7fWVsDZxrrL86G+wzTB
         8vtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=65FA41VLdlPtPOOJtgzAErEZDKqpBZV5hcSbMKUAFtQ=;
        b=btDeXWesdskot4v4JITCyBcOTGSL7RfTqEYab+fELRxrd2Ukv2T2OwtPqEnbryGvrZ
         mR775TG18cudRUvn7t84Gp5qus0pcvqWgLVKUboyIBS4ZJ0QQl4styAS2vCDed04cBdn
         ucBWp36vr/2fFLu/n7kz/1oz8ShUWetmoKwCWKBk8NDWIc9xVCwlH/xRcEITZ1xL5e0z
         /6jJ2x+4TCaBpPDR3Cxeoh733IrAyobH9BSo+Cqz+7tHhsbTIBhXYummrf69I3/5wnP9
         WtI+EyhAPeEhRmy8TEd1v7ChSXczg1h35EzWF0rwicajPgLBWCQrQ622+UwBSp7TBw9Q
         w8ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358929"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Oj-Em; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.703380444@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:57 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Yao Yuan <yuan.yao@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 11/21] kvm: allocate page table pages from DRAM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0001-kvm-allocate-page-table-pages-from-DRAM.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131457.bWqd1N4sF4vlHkm0TEevXqhPwU2ikE4UJjD-xZ8e9f8@z>

From: Yao Yuan <yuan.yao@intel.com>

Signed-off-by: Yao Yuan <yuan.yao@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
arch/x86/kvm/mmu.c |   12 +++++++++++-
1 file changed, 11 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.846720344 +0800
+++ linux/arch/x86/kvm/mmu.c	2018-12-26 20:54:48.842719614 +0800
@@ -950,6 +950,16 @@ static void mmu_free_memory_cache(struct
 		kmem_cache_free(cache, mc->objects[--mc->nobjs]);
 }
 
+static unsigned long __get_dram_free_pages(gfp_t gfp_mask)
+{
+       struct page *page;
+
+       page = __alloc_pages(GFP_KERNEL_ACCOUNT, 0, numa_node_id());
+       if (!page)
+	       return 0;
+       return (unsigned long) page_address(page);
+}
+
 static int mmu_topup_memory_cache_page(struct kvm_mmu_memory_cache *cache,
 				       int min)
 {
@@ -958,7 +968,7 @@ static int mmu_topup_memory_cache_page(s
 	if (cache->nobjs >= min)
 		return 0;
 	while (cache->nobjs < ARRAY_SIZE(cache->objects)) {
-		page = (void *)__get_free_page(GFP_KERNEL_ACCOUNT);
+		page = (void *)__get_dram_free_pages(GFP_KERNEL_ACCOUNT);
 		if (!page)
 			return cache->nobjs >= min ? 0 : -ENOMEM;
 		cache->objects[cache->nobjs++] = page;


