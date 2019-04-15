Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66A69C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 350B420684
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 350B420684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C386A6B000C; Mon, 15 Apr 2019 06:47:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBE656B000D; Mon, 15 Apr 2019 06:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFB906B000E; Mon, 15 Apr 2019 06:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 850136B000C
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:47:15 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 64so8801954ota.18
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=uHQ2SbMW02xpWhVeh+MWbPrNRsaAQ6EW0Gg8x7r8ELM9kZpkAagGhmwPCDs0ZX0AAe
         WeeY7wM5oXWU4To46ImwJIlsCiFsnysfSNDk6eu/+C1+u9CVhs/Bbm2qTzuFV9zqvdBB
         5asGOdu1v492IGRUSOO9nPKGK5LmP0KeRFTpQRkIHVuXUIZNtVGQLZkY/+QXSOpk6svZ
         KbXM3iH+BjpAOYPPC3WvQWi/X2r/RASy1oOp45YkXAmv2YfaOMBfTTS2ChsRve2UiQcN
         aamyjJiY94Pys+o+spgR/A3ALZucmqRGWw+5BDNh6Zj6v54aU6vub/JUZ8hTRKT18wP1
         ekiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUhmU6Afvh++PIy/zWtIrJHG7EKt2mh+4FqlZB0RCyGv2JYTiXv
	SRYp0MLsPuo7NDOpgwQu+MLHJ26cM2mHZTmCpR/iOlJqEQuWD9Mnb9oQonxODwRPClntT08JBsb
	XJcTDBFWGgo3fTUHeI3/KJPxFflvDUQS6J5sBooQ2nsimuW9uxNyOrFRtlWs5NJC6rA==
X-Received: by 2002:a9d:51ca:: with SMTP id d10mr44928854oth.83.1555325235260;
        Mon, 15 Apr 2019 03:47:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynVOnSHOY3IsWYoRTt6DWO45/Cw6ZcT5NunAg3BqWyQlOqtOVG0qSqkc3xtwG7gzVPPKkf
X-Received: by 2002:a9d:51ca:: with SMTP id d10mr44928801oth.83.1555325233975;
        Mon, 15 Apr 2019 03:47:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555325233; cv=none;
        d=google.com; s=arc-20160816;
        b=uXY29TbqZFZdDmjpPHDVpIecLyoS0GD0IV0Hnng+yphlXDRTPMv9SjwOjJzGFCQZ4b
         LyhXKxY41rz+RgoW6W1egdBOQHWl3kuLiEtHBXZj9k74PUpdALuNND12NDib6DzcXeXf
         rVPmHcjz4kbg80wWByDhwTPVoIHSRHCmbBMCahXxwKuL0uqTELpSjAXGxWAvEZwdAOz1
         LWWTrV/a5GgnWgtxmDNSGbcYIrJkqT4JOisxjVaCb2sgf12qgUQlPiN+oK2u13ws2cco
         LJMZZd8+7fRYkUaypORbbIJeo9zePTAJAiySkW8eaxJQmM9jEdYW+jFnG+AH5uH4OnCw
         rrVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=s3cqLnZ8ikaGliCL7mUmXmKsHQTifOzyfKPhb+L5V7k=;
        b=o1PucjRUrrRbJ8qenui1/SXZvhXuvnEUrghYCq5Hg2eQruUsIfORxUHfOT3akdOQ++
         l+nNuucWYLc7P7SP5BKi2lpT1KBY8l2qgzM2KoN2zchBV8YDK3SxfoT3elzzMyOh0BUQ
         F8U10atiXU+Es6FN6D6zONba87EB5NA60R0NiffH2HgDe2BtI8nVZsgHsDncviyFHNCG
         TyfYYy/4AYvLEzy158TtKWnPRbkXED+3sYc7KmH0G4n/KYAO3A/uJw6U6J4q33vUaiyG
         4Wx7OZQMfI4keI09i+c+JtnxJHABCvd65OfjGivoWE3xrTdY9KJvQTNMrfad3D5x5BBV
         CD/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id j185si22999546oia.117.2019.04.15.03.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:47:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 8810C6B0925E761BECE1;
	Mon, 15 Apr 2019 18:47:08 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Mon, 15 Apr 2019 18:46:58 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v4 5/5] kdump: update Documentation about crashkernel on arm64
Date: Mon, 15 Apr 2019 18:57:25 +0800
Message-ID: <20190415105725.22088-6-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190415105725.22088-1-chenzhou10@huawei.com>
References: <20190415105725.22088-1-chenzhou10@huawei.com>
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
index 308af3b..a055983 100644
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

