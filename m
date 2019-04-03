Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AF76C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D45D820830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D45D820830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ADB36B0274; Tue,  2 Apr 2019 22:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8344E6B0275; Tue,  2 Apr 2019 22:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FE686B0276; Tue,  2 Apr 2019 22:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 424446B0274
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:54:52 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n2so9519368otk.19
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S2ig1be+sIFgRMbWQ0Djd4ujr3RZdZV0qfjf5c70x20=;
        b=QpBbTERbX62reT2VF2DM7l2ITyUjJ/huVnokwPSmFH8WVy+E8fdxBWt93Xw4ZFxDFm
         QOzwudk3l9T3dLvkvdQTmJc+kCC8WAt7E7SrEuB8SgJDstP5jzfauDp8saFwAoOVLHQB
         3KVjosRdujqZbwm8Ys3VxjrSclowh7ptGKeGUFei7ox6fnknYWPxEJUOKTZ7LxWU9t3P
         X0NoFm04Qvma76/w+i5ztam8uz4iuj4xhOoNblf0KExH55ScmVnvg+JYn3o49IP6E/Gr
         3sSNmBRqeU4rA/6Q5Nqwc3jmr2iJHqxa7zHOBnvZEFTntCOiglK+0kGvGKJtIv5Irzil
         tCBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUcm4LjulsByFVkvDvNyiMQCCKc5BNoFY+giFwkvtXLBO8HDOte
	LCmaIf0cNZLXFC+yDwSm+EeWyQiTdBZd92+nUp6+J/+iDfEHDZdPgzBJzYcsBCNEg2+3Fc1+GTw
	zhiGPlK57mP/aadYjea6geoedjCtDySa0eGohy4gcPIu1g1sVSW18in7WsxSxmxX6lA==
X-Received: by 2002:aca:4085:: with SMTP id n127mr173426oia.93.1554260091908;
        Tue, 02 Apr 2019 19:54:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRoIseUQ8lIDovHTlStNVs/gnnd5cZfUR8qafDWe05ehuifaw2B4pGjI9jBHi2gUEgHMnW
X-Received: by 2002:aca:4085:: with SMTP id n127mr173393oia.93.1554260090963;
        Tue, 02 Apr 2019 19:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554260090; cv=none;
        d=google.com; s=arc-20160816;
        b=mP5yL9XNI8UBzfvrJQqnx92ibP5vW5g57GK9BC7ac3HOHTSzDEP1iX7EiKzn/hSUII
         SvwuatxV2SmA7KIJIH4JQV1qxnetssN9jMVHFGEUMaam5QgVtIgpBcJrdfOzq3RPMvYG
         HFv4Xa+Sef8RVCeYDM485SpzViUcXLpVGEURATyzGCaBpS1zKkrPw9ysia83m9qecEDc
         H/XpC6KV6x2f1XYbUrBK6zm+DDEeSZTZ0pTGkwg67czio9+v1JL4PtKSYaGMiV/MZ1CT
         HoMXs+MxCHAHKW60tAua5fc1LW95dLW+w0dGgX5zSeBXbfpvH+h1BXpZwCmqT2jShiba
         P5jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=S2ig1be+sIFgRMbWQ0Djd4ujr3RZdZV0qfjf5c70x20=;
        b=nm09XlZbJdU2f6YY+foFMPserI+dczj5zOl3UhJcd4qTf3maMKK1zJ2gEOzMsm1nqw
         Ger6PeCsDLvQwPS3SIZFQlaDQca8RLWLupMNbFFnreIuByRuHeLYhYVd5Tbv1chWhyaa
         P9UxCETCtkmdiNAPGBarqHrujy5RAOuPSpZDx8CM/mIRzY+GAIl5Icfbd6OyTmqDLrS4
         Y4K21OJJqzuuOgMEbZMZMVcBzcQDucIkKtNmOf5W1VMeyFPdfxp5RC+OHxeTisus5Pnh
         p5ebk0tZhT+OGmgE4bCt/yPp4EKSj9/gaLJtEqcojphiwres3ZcE1eUC/ocE2xD5IiSz
         Sx6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id t133si6409246oib.55.2019.04.02.19.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [10.3.19.208])
	by Forcepoint Email with ESMTP id 2330B9790E51A53BD62C;
	Wed,  3 Apr 2019 10:54:47 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Wed, 3 Apr 2019 10:54:36 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<ard.biesheuvel@linaro.org>, <takahiro.akashi@linaro.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 3/3] kdump: update Documentation about crashkernel on arm64
Date: Wed, 3 Apr 2019 11:05:46 +0800
Message-ID: <20190403030546.23718-4-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403030546.23718-1-chenzhou10@huawei.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
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
index 27a5f8c..6772f4f 100644
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

