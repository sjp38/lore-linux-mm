Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 754E8C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 303A2218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:38:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="nh59hCcu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 303A2218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0BD56B0007; Tue, 23 Apr 2019 16:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABBF96B0008; Tue, 23 Apr 2019 16:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D3176B000A; Tue, 23 Apr 2019 16:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3736B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:38:48 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id j20so7437179qta.23
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=If9b8Hhg6rb9qfMxJ/D8pVjl9Kc21wX/xW/OU60oUvo=;
        b=bgeAou6PXwv0amchnVUjtHs0OGeFlxWj84pgL/eO5pFjfvIJVDt/LfwS0r5ubb/lFz
         tSJZkE69elDPCirQF79qro/mLK6tYslr0Py3a4fUgd60ocnSezv1XE6los18+ydA1w2E
         lIU01FzRvaVNB28XZ+gAegNSkuJIQYE4XhPU7jVoaSyabbi8yREUKZVk3Wfus5KgmVWx
         rRITQmzb0CwHK9+8zDmOzw+rM1j2z54sEn3gjvCEnJ6oa0WvVZmEYwmIpvD7RdpBvw1G
         i1jINCsUU0J9wbnP1kkwwuNtFLtZCYB2nU7dfhtqsqNYjoEvrEYwjo9p7lIaY1G9H4vf
         H1+Q==
X-Gm-Message-State: APjAAAXvQ6TbJDHFBVXwINuz3edSMEcY3KJsKly4pJZG+nWOv6rXvRTg
	Y1GzlrPca74pyeGN8berGobBDYbSveEMabmuBmmMj+QiXWL94Iz5IJbuct2dFlyHd2ax4DLYKHN
	UzUC83xzcyFH1Cne1Nj7cgcbljURo7jDGRlv3PbsabQgAUEOmDDW5tw0Td1IuqK75PA==
X-Received: by 2002:a0c:9004:: with SMTP id o4mr1402636qvo.175.1556051928202;
        Tue, 23 Apr 2019 13:38:48 -0700 (PDT)
X-Received: by 2002:a0c:9004:: with SMTP id o4mr1402559qvo.175.1556051927073;
        Tue, 23 Apr 2019 13:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556051927; cv=none;
        d=google.com; s=arc-20160816;
        b=hRRTu8MdS2r6agZkC7OqQ9mHeNVQHSChZJc/oOHusnr0kpLSCpTWS7MxErXFzNkhYv
         Gg4epecmeR8GX22XLUoLd2cbmBpBRbtzq0/pXc4FsPkwtRYSrPXR/HfEVd9rh08gWIte
         eFVJ3cWhAQlRwDySyn0MzQK5tpXgddbeDkpW1QmGzNXrOQeMUV3w+N/LNZ+DbfZ3Mgbo
         z9eiTCgEaL6gQpB1ezFkwIJ9D0K2yOOBmGqFOA2269suHCBSqKncP7MzHF1htkP+av5g
         4UC7SuyrT6T6tT9NlTwiVQ9lJNHwCmCOltAb61rG1U9vIBuN6MAAn2bhzymQFXijQJRE
         /cpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:dkim-signature;
        bh=If9b8Hhg6rb9qfMxJ/D8pVjl9Kc21wX/xW/OU60oUvo=;
        b=iPPe9SUFv5gLcW9ml5YhNtjUIjvTxmYNdA8zSt1fQSCxnWh4PsapseWJ9+maq1HSg6
         s/PZvrGlaY4duWjFUff/kEZg90wiMP8ae7w1sBkKu3gib3ySFPiWqkfmbZxlWlHlOndN
         rTGIZYDUvhDIMbB/kkQZNfdt/RPOMpCNfu7c0pCb5MRSfdt+YG8hGuk+q2Yt0GIKCtIQ
         eJ/JAqUwQJ3v63JzUxlC0paDp7hkEw2ze77HqrRXD1IV724E11uBNwW0XGymYPZxTlg8
         /e2Z4TxW9kwSWs/Fo3CBdpbj7aSrf9AjEsIaI8QE81LaFszmRV5pL8T68+4/DGOErbIz
         ko7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=nh59hCcu;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15sor9544356qkg.33.2019.04.23.13.38.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 13:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=nh59hCcu;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=If9b8Hhg6rb9qfMxJ/D8pVjl9Kc21wX/xW/OU60oUvo=;
        b=nh59hCcuNy+/enpUAvjmC5tL0AH4ZTxKbIs40ewzwMpIXhaHejxqetkdbduolHyW85
         OrJJauDYMJuthPLeEwRqnqKS6E2KvoU/T/wV7tQVwJGM5pLdhhgpXUzIqbYsPXBsG63/
         nVrBl4eQhwbLdyyPAsmLw67TSjZr+YrTdB4J4kr9Yodd2Ndr0WG+yst7PIZGhDpVDLaO
         MjP/5QPGwkw8RFqYRvnkqyorAlRul9eR8bBYQ3k2YnJ3W9d6/bEosMKWO8+zYoP0znUY
         9agdqwJInYYuUt98tt94D4YK+RdBG+sXgXzZDDMRNw/g944Xd89BI8x0AVG43h036KkX
         7awQ==
X-Google-Smtp-Source: APXvYqykWYZqHb2524ThL5IEsi/KMdqhj/ZzHVclC22Op4Z56+nOuuGZD3hYblG8+xPiTnn/YtlTfw==
X-Received: by 2002:ae9:c005:: with SMTP id u5mr10795603qkk.179.1556051926698;
        Tue, 23 Apr 2019 13:38:46 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id 6sm11296020qtt.8.2019.04.23.13.38.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 13:38:45 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	catalin.marinas@arm.com,
	will.deacon@arm.com,
	rppt@linux.vnet.ibm.com,
	ard.biesheuvel@linaro.org,
	andrew.murray@arm.com,
	james.morse@arm.com,
	marc.zyngier@arm.com,
	sboyd@kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH] arm64: configurable sparsemem section size
Date: Tue, 23 Apr 2019 16:38:43 -0400
Message-Id: <20190423203843.2898-1-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sparsemem section size determines the maximum size and alignment that
is allowed to offline/online memory block. The bigger the size the less
the clutter in /sys/devices/system/memory/*. On the other hand, however,
there is less flexability in what granules of memory can be added and
removed.

Recently, it was enabled in Linux to hotadd persistent memory that
can be either real NV device, or reserved from regular System RAM
and has identity of devdax.

The problem is that because ARM64's section size is 1G, and devdax must
have 2M label section, the first 1G is always missed when device is
attached, because it is not 1G aligned.

Allow, better flexibility by making section size configurable.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/Kconfig                 | 10 ++++++++++
 arch/arm64/include/asm/sparsemem.h |  2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index b5d8cf57e220..a0c5b9d13a7f 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -801,6 +801,16 @@ config ARM64_PA_BITS
 	default 48 if ARM64_PA_BITS_48
 	default 52 if ARM64_PA_BITS_52
 
+config ARM64_SECTION_SIZE_BITS
+	int "sparsemem section size shift"
+	range 27 30
+	default "30"
+	depends on SPARSEMEM
+	help
+	  Specify section size in bits. Section size determines the hotplug
+	  hotremove granularity. The current size can be determined from
+	  /sys/devices/system/memory/block_size_bytes
+
 config CPU_BIG_ENDIAN
        bool "Build big-endian kernel"
        help
diff --git a/arch/arm64/include/asm/sparsemem.h b/arch/arm64/include/asm/sparsemem.h
index b299929fe56c..810db34d7038 100644
--- a/arch/arm64/include/asm/sparsemem.h
+++ b/arch/arm64/include/asm/sparsemem.h
@@ -18,7 +18,7 @@
 
 #ifdef CONFIG_SPARSEMEM
 #define MAX_PHYSMEM_BITS	CONFIG_ARM64_PA_BITS
-#define SECTION_SIZE_BITS	30
+#define SECTION_SIZE_BITS	CONFIG_ARM64_SECTION_SIZE_BITS
 #endif
 
 #endif
-- 
2.21.0

