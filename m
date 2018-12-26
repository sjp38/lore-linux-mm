Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12ACBC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD783218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD783218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936AF8E0003; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D5698E000C; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB90D8E000C; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADE7B8E000E
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p9so17807808pfj.3
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=AU3CNRHe4j8llGakV2TMFwGlbQws6UPjl/4IO2w5qSU=;
        b=l79K4X+5PzdklSXzQAUlKKn8taeIrePHtwaiMpOcC57IVR4qbC52ZcK0UI3eFK3JMI
         lmxkpztbm7jnxGp1UAiYTBF9iKGyzHHGWMY27L9bN/+2PWlmS16t+D0GYPm9bMP2V0UP
         DQ5cebg16pqR5c+8ZLM62UKcuGXqgM3LxO28IA8Tp990z1wO+XXTSvQMK5jJbz3PwAqj
         cWsPb8uibM5oNJVkeYXtynCydOImHHTBaEHmAqAUmCYW9MdTzKKSUiMC0RRqJdoAoG9/
         3lBuMWEpCPo8Mn7cmAILQEPic6DRKP/jQg3nvHGKptpvRekDXxv+J5aLiGgiZ5/Sz+tV
         wU0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfbh/0a3cnDcDE066xp03mer3ZyZzloSTt7y9QDJKNFHjWKKtbw
	bWru3WMJVtEVbA1rgUk7W5uYIyPhkSZSbNk8gEO5FxYe70XR0URs45OObsKKT3SmViFASKr0tdJ
	3mVkHR6EMRuWutaeHPO65p1FIqJFJBGmLvFzA02bp18HgEPSP0gfL7XUW8bPXewwxig==
X-Received: by 2002:a63:c42:: with SMTP id 2mr19079772pgm.372.1545831427410;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN42dKw6qvjrCcjVjH1+RLdTT70fyLQuyOfxZ1nIdqCuEyDyyUAcG8kFtb0ZbqkMFJUUskAD
X-Received: by 2002:a63:c42:: with SMTP id 2mr19079748pgm.372.1545831426901;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=jM6eHZ6wmL7MUXPv//ebEhDmEmofxM1bvkOl2IZL2DSPEBeudsV2LSLflqv7Clu/mo
         wpV9ydpl55AXAGESXLfzf3HHnPUjPx2fLPorNXKqlZBknfYefF4+DmHzLUR7htAsIEwP
         AHAKYgG9J42RilXkXZfeZ8jz7LuGZ1+pLTwCM+RWgLCJxUv5n8xXFvZUrLro3PTggZqZ
         iMoPgIr2RWcrtLTq9T6yf1aZGpezmAU7uf0jfhDnLwc4YOZtZZ9SCWJE3BajheNXi9Zn
         FEVRkWy4tSxT0XBuuqAjy3+fqvYehH5Zsb4idbX7l1vZh9CnPfl3qzuDg6U/0ih/kPyU
         0B9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=AU3CNRHe4j8llGakV2TMFwGlbQws6UPjl/4IO2w5qSU=;
        b=YTIJYwNp7daKlH/2i8BXIOyGb9kHVkSFEnvdmE8lzAtO54YqroCnbu84qNIvD41mVH
         rdUvKf2KApelYr8W//6zZrcIjPISziE3T92jumz2v4g5yf390Ok3jK2NgtQGPsHh0PqN
         U+fWMxrIZ66iT4PdmaYnsp92wboyyCXynovsFyGEubQgx0RLWtVwW72H+dLfiYpNomk0
         b2hpWd7Tlow9MJW4YKwO+su8fb4ctca7kkaCfvcK+Pkfh+/XcywPTeICiCr3nSfkD00t
         aXB6ZHRmmSoTK4Hp08JK98u9qv3MHYLoqXtt6Wmno178wgv9lZ/hi2yk+utgLFm1Hza/
         3j0w==
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
   d="scan'208";a="113358935"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005OH-Ae; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.410639437@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 06/21] x86,numa: update numa node type
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0004-x86-numa-Update-numa-node-type.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131452.kvrrxPv9e68_uzCaWKj22hWn_h1LZtPzejzsNFhNt5k@z>

From: Fan Du <fan.du@intel.com>

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/mm/numa.c |    1 +
 1 file changed, 1 insertion(+)

--- linux.orig/arch/x86/mm/numa.c	2018-12-23 19:38:17.363582512 +0800
+++ linux/arch/x86/mm/numa.c	2018-12-23 19:38:17.363582512 +0800
@@ -594,6 +594,7 @@ static int __init numa_register_memblks(
 			continue;
 
 		alloc_node_data(nid);
+		set_node_type(nid);
 	}
 
 	/* Dump memblock with node info and return. */


