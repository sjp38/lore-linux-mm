Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B3AFC04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1613620835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1613620835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F2456B000A; Mon,  6 May 2019 23:42:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A3306B000C; Mon,  6 May 2019 23:42:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2202A6B000E; Mon,  6 May 2019 23:42:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB45D6B000A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:42:22 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id q15so8563267otl.8
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cEalju8d9sYCGCsaQbM4UqqlSjYWHHV47oeviVAwqmU=;
        b=XoItsMmRq6WudY+A+uA6A+10etpAUhr2dlKQ3QJZl0NzUPZd1Omk3K0a7/RsxRo1Jg
         G/IahpTEZ4iJhPnZsZ4jXinxXz0s3RqucIBhZM9ndmKxOCEwhJJ5Bgpri0O2YWnztEI9
         UCSQrGd2RnJAJTYfgDhm3QppJ8WUwwAzvDQrqO/hSXFz2BwX8b0DoWVk/lW8lK3goROl
         JbukZFCoxiFN2EAZXORO0dbVZZzea+mA2uL+CqICsYUAeZ4icjx6yddPUVWsClA7HjUN
         UUDFGllAykie7UDXDkH/nzNZKxZILDMj6V5Gs5hE3QqmMmHwDxDR9C3034LMFHHaieZG
         AmcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUaH4py37bCgX0fLeU5N6WRfN1w0JM5/F5tw4CC8QNPOQ3FT2DK
	9TcuGMy5u+f1CbBjHcTsD910IIYwi6oQ5m1Ai5xtLqkui+ZIg76sB+gxPplA8DK02JpUUdVZbUu
	PevRpWmqwG6zrts1UDMxHMqC7KwSjPkcWJmalRbQIIbW6k/mrOc5dUljZuHDThjPRNA==
X-Received: by 2002:a9d:4ef:: with SMTP id 102mr20884322otm.302.1557200542544;
        Mon, 06 May 2019 20:42:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXZ7n9+ncG77368j2PRXo2G9e9ge9yer14f082HdfxSCVS+QsHUrClL+XWZLS1CDKTfUhj
X-Received: by 2002:a9d:4ef:: with SMTP id 102mr20884268otm.302.1557200541111;
        Mon, 06 May 2019 20:42:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557200541; cv=none;
        d=google.com; s=arc-20160816;
        b=wUpEbeTXlQ5Xkit0lsqVUURXk9qHOshBNhruQBgKeYu2FCVzFlidaAJcD/zR6SbddQ
         pIq5evDDIjADD2WoJRoZGaN4P7SQ83eIjiujK0JLNFvQmWrCMvqTVMtr+6SmzlE43qP3
         2qDfyIQed5TIFoVRDb9sqZgtB+juzbG/OGw7a7kMhGt1hBVTcsk6LIB1NFmYSgZAgx4W
         aFG+oGBJYTkqLECqvpZOw+hn5cuP37O7qft+Lms+CS9hijMKp0z7FxfMfWXWXW7pqn1+
         IM3nNUwVARXn1Dy7IppZiz6B0nRAgp/aafmrtlHdG8hyFcbb8NONSgoBBDG99DVrbxCF
         +A/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cEalju8d9sYCGCsaQbM4UqqlSjYWHHV47oeviVAwqmU=;
        b=AMZ/P/SZjIQ10YBzJURTRf1wNomnru1PNShJx/5RVlmx+xA4Ytbpol0xAyjQx9NxED
         OPt/VwDhdbPbdcGQp85wXeCPO70SAHpDsXG/oFRBBFA/77AG/Lcl6VH23fikSZy9Xo4T
         0RGpqkA4RdfAHiLU2H+9iLjYRVAmNVEBIosVlUep3KAcGYNRV1WhVhYQCZxyGmxSy6iw
         ArB4xD+2MQVN05oUDcklcz5sv+4UykVTiiptCztRqwfkKgepOUfX8fWk03pYhahi0He3
         mLLeAfkl2ynZz2nZzQFITHEpzIAbBnMw4OGuLm4Ogs2qlx/52GRZI8gqyxdMMuD8roRF
         0g/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u84si6923434oib.82.2019.05.06.20.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:42:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 74D60BC3975760A175A1;
	Tue,  7 May 2019 11:42:15 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS403-HUB.china.huawei.com (10.3.19.203) with Microsoft SMTP Server id
 14.3.439.0; Tue, 7 May 2019 11:42:07 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 4/4] kdump: update Documentation about crashkernel on arm64
Date: Tue, 7 May 2019 11:50:58 +0800
Message-ID: <20190507035058.63992-5-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507035058.63992-1-chenzhou10@huawei.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
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
 Documentation/admin-guide/kernel-parameters.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 268b10a..03a08aa 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -705,7 +705,7 @@
 			memory region [offset, offset + size] for that kernel
 			image. If '@offset' is omitted, then a suitable offset
 			is selected automatically.
-			[KNL, x86_64] select a region under 4G first, and
+			[KNL, x86_64, arm64] select a region under 4G first, and
 			fall back to reserve region above 4G when '@offset'
 			hasn't been specified.
 			See Documentation/kdump/kdump.txt for further details.
@@ -718,14 +718,14 @@
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

