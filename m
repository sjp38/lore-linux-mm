Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A257FC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C67A20833
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:21:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C67A20833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E4CD6B0008; Tue,  9 Apr 2019 03:21:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06CBC6B000C; Tue,  9 Apr 2019 03:21:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E76DF6B000D; Tue,  9 Apr 2019 03:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA7D56B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:21:06 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v1so7012023oif.12
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ok8I24TtxuWgDq0ME4RBGiLUC2kWpehBcB4g0fC0unk=;
        b=eq/tPTgQto8uLbV676B8BlV7Wo/XElyDsq7bdWNvpebxN8PnMAqMKwy6IZTmq7XZpC
         RP3HoTQY1LfUvZG7Kg5E9VdsFlF2BY6/vhS005FvBtH7QARSmayYA/ehbo3X0T6DTnff
         3ZjPi8KXzpczbMZrm60sXCg2LVQTOMc/Ciu2o/4Isjelm5MmMzKV66A1Wfo/Z/+pDzzz
         6nhJvOgUbuSegAyeSkzNbAr2VpP4rgS2bTh8yB89ajlZ/WuaiwjVL1kHS24W0Tkf9H+r
         YEPCCc8EOS4aqXMryasb5a9mlVVH8jJDkoBKN0gTN1qM03omBWXkQ2MWEBNp4JP+I94N
         6N4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVWuLDSDanlUYMAQjOEn9TV8ouYJComNi+kTUxeiR4LlH1F3gSs
	yQ9+jiWma81LRVMUqT9JKIYHsLmBIla99B50YnR8PvnzeKVBlIZvgFxvGS6Al0vRlhgH5dSrIqr
	TmPRoNr9FlJ44Eqk+v11Sj55Iwjcjt4AHOfF1iLVEh8govefFtJJmRSgs8S9ZltUgNg==
X-Received: by 2002:a9d:76cf:: with SMTP id p15mr22575031otl.310.1554794466419;
        Tue, 09 Apr 2019 00:21:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG+9Povlv8P+Fcqh4pFasSnzjRw25sQmlnJVHcSzaEyhQoM2bCfpHviXCYgA+sviiTkeBA
X-Received: by 2002:a9d:76cf:: with SMTP id p15mr22575007otl.310.1554794465736;
        Tue, 09 Apr 2019 00:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554794465; cv=none;
        d=google.com; s=arc-20160816;
        b=rcB5HD5MQ6BUFt/bvg7B8PmOj7VyAmDYZShHkaAI+fM+mk5mBCF19ew4DJZFn+HlEL
         ZTCUIN9yyIxfXvEXSK5v8R2EQ1UO9CT6hBz6I2+eeTspsvRsc7Y3FBSjK8cgLjvYs5AV
         0wvJ/TnWjDoEBpB5vY58DiwfG9/JqfmPWDv1/clRqCO/yqolhmf8LrEJ0sWsRRsgu+3R
         PKNFZ8omeA7+JtHZ5CLmDoZmvJAi33KINGn6A9nTQlqD4Qg5fW7VtjvdAkRz4C4YLdQm
         PFP1VQrdnjOkVpK9PN7Hj+0GRwM5C3zBpI0qSZQ4eNKzIh6f2xV3MLSArEOoj5GuX+J4
         9OYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ok8I24TtxuWgDq0ME4RBGiLUC2kWpehBcB4g0fC0unk=;
        b=DMbUgYZMN4MD0Wh4D/BxZEM2S20W/uRRIglWnA9j2V5h/Dd6CV831klBc6LJBw5aET
         reTBAZEN9Tu95V46G+7rXF28T8GwkA/e64sUnN25Y4XbfGbFebAnX0Q/uxpArtJwv8Jh
         n4fdJGQXY04XYZYghGAE6UV2ejfAuU41olyTaZso/CfoBvztxZT5P4DJ45R4qDXS0Ws2
         WFVGBPlHIHSucHSTDtA1MPjdwUwuTOAU+1thluKn1DibvQJFUfE7YA3/jEzN7+UjAwxi
         49GE85HWfBcR3mxbwU2kcNVwlUcF0ofk2x5/q/p+WHsPR8KKoOe90DB/BIsCgN3AJNsf
         c9iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id p21si15294724oto.291.2019.04.09.00.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 00:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 8C0E77D3C200B2A62F21;
	Tue,  9 Apr 2019 15:21:00 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 15:20:54 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <rppt@linux.ibm.com>, <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v2 3/3] kdump: update Documentation about crashkernel on arm64
Date: Tue, 9 Apr 2019 15:31:43 +0800
Message-ID: <20190409073143.75808-4-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409073143.75808-1-chenzhou10@huawei.com>
References: <20190409073143.75808-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we support crashkernel=X,[high,low] on arm64, update the
Documentation.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 Documentation/admin-guide/kernel-parameters.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 060482d..d5c65e1 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -715,14 +715,14 @@
 			Documentation/kdump/kdump.txt for an example.
 
 	crashkernel=size[KMG],high
-			[KNL, x86_64] range could be above 4G. Allow kernel
+			[KNL, x86_64, arm64] range could be above 4G. Allow kernel
 			to allocate physical memory region from top, so could
 			be above 4G if system have more than 4G ram installed.
 			Otherwise memory region will be allocated below 4G, if
 			available.
 			It will be ignored if crashkernel=X is specified.
 	crashkernel=size[KMG],low
-			[KNL, x86_64] range under 4G. When crashkernel=X,high
+			[KNL, x86_64, arm64] range under 4G. When crashkernel=X,high
 			is passed, kernel could allocate physical memory region
 			above 4G, that cause second kernel crash on system
 			that require some amount of low memory, e.g. swiotlb
-- 
2.7.4

