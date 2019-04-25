Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B189AC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73FAB206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73FAB206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4FF6B0008; Wed, 24 Apr 2019 21:42:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FBC86B000A; Wed, 24 Apr 2019 21:42:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 751766B000C; Wed, 24 Apr 2019 21:42:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AEB76B0008
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 33so13228566pgv.17
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=cjRxgUuUWVSMsnI9DqRNDNjwymo67GiiFEu+mWS/lr8=;
        b=uDOTYa8BHsWoiuCpzEeZ2Ca1dSHB0QfNKsQTE6iXwNU1g0m1bumxO24O5Oz24MlUt7
         BH1SgAoYhm/scVAfBPIb4+0N3N844K7ztZzePOW+nkjIImBf/tkI8gqS12E/w6Ct5i9L
         TTG0g6cUfH6Oa9DPCpM8yfwpKvk6JOapZnVltig4ma4Z3sQMxkY4r4X/hLXN4w42RtuR
         L83cmuwkfHLdGVxvV7y7PtAsT70CSFQ0rQJZkxocNwk53lbU8fI4b0LEjlLEDjDiMCQb
         vUp8GDgdTj0uNgvkvl8iGXVK/CXeUNkBHg6a0/CwOtCDKuw0gHnBUpq8W7gREcALaOVd
         JjqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWPj0Vz088GLlSbsqKwVrRx22KSnr4XyVry7eJJwkS9Ply8YY+q
	JNMQm5e+RM+ol9Lz0edSHwpZ4XBtf0dmOPdC6kWLulSgcckROiRmXB00wTsBaP6jWldqW9JYzkb
	sGaaVjNifr8mMwaRBjuj53CuZz3S366mCQUiO+KfQBE5vJxE2Ln+YDM50A9qDgZidlw==
X-Received: by 2002:a63:8f49:: with SMTP id r9mr27464321pgn.306.1556156568000;
        Wed, 24 Apr 2019 18:42:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhTKYUdlB4UjZkpJnC0T5NI9ZpVvTwxByF1enImVVYduHKiV+MWIbvrIOns2KpsGINl5CG
X-Received: by 2002:a63:8f49:: with SMTP id r9mr27464268pgn.306.1556156567197;
        Wed, 24 Apr 2019 18:42:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156567; cv=none;
        d=google.com; s=arc-20160816;
        b=YI+bPT8PPjp53+LJu3jp/V/3qv2lXlcTN8KLv1Fa4l1roa9C9VbeACzzwun1wxkBh9
         D2fHGxj+v0KNDWLVIPpYcgDiS51qPeon+KuvBeErpAGtE36loGnE5Ax9F1DaIQik1L3n
         hYUYFo1BOAa8rGVsMFgYTCKdlOojOwKZAkwayegCgdV7159vAOk5yDc6Qc5BGG/cFcwP
         6BQtEiL7eX490spNvCpSHmNflRkSYjeeJRC6YlA8HTx5RGBCwm5nFJ3IaysykThi6Djy
         KHvzqOQCvKGviUAfaHZLKXPTX3GHKtJVZ1xQxT/qxHjdsvtV+fmim49bRHsbu04h05rt
         AwPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=cjRxgUuUWVSMsnI9DqRNDNjwymo67GiiFEu+mWS/lr8=;
        b=TrQWAIoKta4vk+7NFP4hN99D+Irk3rE89Hr9t9XSyA4E0fQmE6usJww3bxpFD6zi01
         ltGTbNnMfh7HR8fzN7kOcw5A24psZ+qNibrmxDedr7WvRLPwDRCepQ+7CBX1nzi/kPrL
         0B9ZAovJsDg6lrcGkdeyqD04LnpodGaQrlNzgeSkFKF5uSswNxPOux+VYzComfegOUM1
         D6exdhvktoPSPNqvpRCo2J4UL5a4V0p/bzLwrq8tgr3NUb+SRPK3iYMw9GKlyqmXtFdh
         9XE/xbaR5tGbs+I3A+qzzqI7t6b1HzL0nFTl3J3cIGtSS1Dgy6Hr7LqPBZjvGxo8VH06
         evbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134226"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:45 -0700
From: Fan Du <fan.du@intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	fengguang.wu@intel.com,
	dan.j.williams@intel.com,
	dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com,
	ying.huang@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Fan Du <fan.du@intel.com>
Subject: [RFC PATCH 3/5] x86,numa: update numa node type
Date: Thu, 25 Apr 2019 09:21:33 +0800
Message-Id: <1556155295-77723-4-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Give the newly created node a type per SRAT attribution.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 arch/x86/mm/numa.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 3c3a1f5..ff8ad63 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -590,6 +590,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			continue;
 
 		alloc_node_data(nid);
+		set_node_type(nid);
 	}
 
 	/* Dump memblock with node info and return. */
-- 
1.8.3.1

