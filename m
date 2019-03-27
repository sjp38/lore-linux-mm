Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B36CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40F2D21738
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qKJDa9lq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40F2D21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C356A6B026F; Wed, 27 Mar 2019 14:03:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4D06B0270; Wed, 27 Mar 2019 14:03:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AACFF6B0271; Wed, 27 Mar 2019 14:03:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAD76B026F
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m37so4801517plg.22
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k0AkTHPgA2O6nUBi3XOpT5HZUMd9XCxodgd3dbhYSMw=;
        b=scnQqdWXGPGXc/iyH1a+BHua4J68ffbji+12GzIYAdgBiL2YUi/4qCXsLEml9otPdO
         LjfCC9SqOXCZBnbmKo9dCsEGeDQrYHpHfAXW+BLaLamb8fUGMcMFkPEnE4Inh8WIhxVE
         vQB0n8r+z1ED/wWoDTews/ddvO7pCOP8UhhzdrtcMNknKlT+9OHXOBk8zKaZnemwsEBa
         h+uQfVvHgE6VhOMHesTWoMSEi3GfNpcBQ1RyTLkDFMYppXYGqlKBzoi465SkIavAalLb
         56swzoWJyuxGsr0M4BFAPbaobFhZyIomGAxzjqtV8MGw+KcAwfEeneP9ShSucNxv6Dt5
         xlSA==
X-Gm-Message-State: APjAAAVvNCc0JTrDwgjbhl774JH2u6WYTimqsrkkUEvic15fOiJ7hk97
	FVuHr58pbFu3tFLsCp2pwMpYbnRwC7NoV3e/u5WSK5EyzYQ4kp3pOHJ1xUtZFLyVkGB0cREo45j
	9RiyY6pm9M+3Qfl/6NvLF5AhDWkyGXwM6nkydTjphTCoKl66VTTukbZJMwmkdx+b8ZA==
X-Received: by 2002:a62:e418:: with SMTP id r24mr37154259pfh.52.1553709828071;
        Wed, 27 Mar 2019 11:03:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3pRq6F78259P4BECq3sjOjVJQ1kYbD4TpWn1kwlzTToYoUZ0jx3y7MLm6/sgdUgzHa2zs
X-Received: by 2002:a62:e418:: with SMTP id r24mr37154181pfh.52.1553709827301;
        Wed, 27 Mar 2019 11:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709827; cv=none;
        d=google.com; s=arc-20160816;
        b=us50X7pQLRyTxMuM2ECSly8Ve4UoZmUA6cxBa9Ith4up+yeKSlUtXuOy5jYzwPTOgK
         DooGgyQtMZvvt9gvDpRvTrorW773tUUYOI7v6kPI5K4No+P8LU/KzOjtQh32eiguMtzK
         Vn5aXn4JQtB0jSzxzdFQApMSsYdD3nTKffkObiAX2LDjCUsfJ3Mb/3L67zFIZAijyzVA
         rcyg7E0ga4NS9ndMHUtsvL/gF3X11WkLgdApOBZUu5wPStSSvpq3L9D2UvLQ4inFhBah
         PsnlRc1SglVyzLvmMNPPg/M2ugJL1GlYe2TJa5IxZP8/OvsHHFG/YAG9cTXFXrNKkap4
         Zf0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=k0AkTHPgA2O6nUBi3XOpT5HZUMd9XCxodgd3dbhYSMw=;
        b=IHuP+G1NOPkPmaNicnLSwJWiW502KtSSJywMSYvbk6Kh8OMuaIgDqGGfI5ODQyCVQp
         eClqylvyHmTDq6G1hkNc51aA+swtLwamrzCyuQQGdluBDSBGgPKN+omoQFzZbhkEKkp8
         zN1T3uqCMjMZTT+Byolwpwf+cDmNlHdiC39LqKPGfpZwOQv/x8s5z819S2mVT+wd2Yve
         JJDNNq4DaY7zExVr+/6QVmg0T4S+snomgxRoa2w0q05XR1rBmQFIxIBx+ckFUMOyRfj7
         jzKQ3azxcLupZXM2SDH/qogNmvRdHv0AwnEYMfd3AJNaGM7l/QmhDP3ZSuMXlQ6AFAnE
         jbeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qKJDa9lq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 5si8006722pgg.505.2019.03.27.11.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qKJDa9lq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A9AB42087C;
	Wed, 27 Mar 2019 18:03:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709827;
	bh=MGfIoXnzyNJ/KAFrw5ZJrFi7P/sOO+b797C3j3DpCrs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=qKJDa9lqPCT5FrQKRqlbe33Y1Ye8nJS7oPjbXYzBZXdORbP2sT2Gk9qQ/a+zaOe+r
	 56eY7JaZIzN0iAPiS8P7be/uC6PxgIAFcyBrhSvdPoWSPmaep2ZwWuIFnw4qKCwHN4
	 ZhUQpFgGkEsWbo2bsOhgFsFweXmOBPHTka2uJitQ=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Jiang <dave.jiang@intel.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Vishal Verma <vishal.l.verma@intel.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	linux-nvdimm@lists.01.org,
	linux-mm@kvack.org,
	Huang Ying <ying.huang@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>,
	Takashi Iwai <tiwai@suse.de>,
	Jerome Glisse <jglisse@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	Keith Busch <keith.busch@intel.com>,
	Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 5.0 061/262] mm/resource: Return real error codes from walk failures
Date: Wed, 27 Mar 2019 13:58:36 -0400
Message-Id: <20190327180158.10245-61-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit 5cd401ace914dc68556c6d2fcae0c349444d5f86 ]

walk_system_ram_range() can return an error code either becuase
*it* failed, or because the 'func' that it calls returned an
error.  The memory hotplug does the following:

	ret = walk_system_ram_range(..., func);
        if (ret)
		return ret;

and 'ret' makes it out to userspace, eventually.  The problem
s, walk_system_ram_range() failues that result from *it* failing
(as opposed to 'func') return -1.  That leads to a very odd
-EPERM (-1) return code out to userspace.

Make walk_system_ram_range() return -EINVAL for internal
failures to keep userspace less confused.

This return code is compatible with all the callers that I
audited.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Keith Busch <keith.busch@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 kernel/resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 915c02e8e5dd..ca7ed5158cff 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -382,7 +382,7 @@ static int __walk_iomem_res_desc(resource_size_t start, resource_size_t end,
 				 int (*func)(struct resource *, void *))
 {
 	struct resource res;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
@@ -462,7 +462,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	unsigned long flags;
 	struct resource res;
 	unsigned long pfn, end_pfn;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	start = (u64) start_pfn << PAGE_SHIFT;
 	end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-- 
2.19.1

