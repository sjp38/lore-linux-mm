Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC067C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9550421726
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9550421726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32D558E000B; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DCE58E0003; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FD978E000B; Wed, 31 Jul 2019 11:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDA8F8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so42629896edd.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mc1SYjLVmi9hQ3qnYxRsBDo5bthKRsGDInhBM/MARCQ=;
        b=bAi7xpJXZY+HbHWHjTDSoKfl+OYL8j7dHJ2orUAl4BuY9voU1Vb2KHjwTfZy+LgT47
         INtaK/ZeSRFgH2ocMLeBu4oqtHLkoni+BW7QJGTfm9q1tvDDYzwE8sOlkDfSOv/YwOZf
         7T0klIP2QMZkeCJpmLUaMaDKF/bdEAAzDqeBLNDHl7zTBlgPqa+6okLX3Na7HMsotUHS
         ld5daVyNyNpjks7OlEo0DaFaH1WLhxGX5GivolQ+DcLjs8GAOVaQiylHSqEhl1zRyIMT
         fsNvNluiDPOYzyZguEMjVJ9KDbyoVYW8BieE539OT5Ks0mLBsD5yYaNtjEffMdbgwNxX
         BBlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAUwEGtZGNcvIimPjSV9xZEaU/9Hac+UNtQQ5ju+aB+Xoc2LaMQt
	ksKwnVvWrC80KDM2u15S6FDScydm2FqojWejrtFBmWGwn8nW5ud/58W1EgyOpUN9DBYnX9v5LSA
	3bqCakM8Qamo3chxJ2VHZjF9TfT3JfV0Akrs/KyfPViU8RzJnD1qr+S40IGlc6trUtw==
X-Received: by 2002:a17:906:b301:: with SMTP id n1mr92591858ejz.246.1564588082489;
        Wed, 31 Jul 2019 08:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9qKK2pGrEHs13ArVCFGGl2fzlLR7vgnhIY/emrZECPnzAE7dJaLr/fRX1ffTZznlPqAlz
X-Received: by 2002:a17:906:b301:: with SMTP id n1mr92591816ejz.246.1564588081754;
        Wed, 31 Jul 2019 08:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588081; cv=none;
        d=google.com; s=arc-20160816;
        b=WcGrx8SeDc12qNQCTmAuRYTauACuETcG4p3HX6nEa7pl0cLaPSGCvfUfr6XT9C5HqV
         SIA5HvjN3BmnhUKbaHBEHI1Kyp14rR2WddsW8684wv6wtOy/DMkCkzu82i2xR5NKUhDD
         3NZ62lIzMjRgQWNrq93rQaPOkjXmM4UedBvOj/3RKKfgn+JTAbXucdYrLVHHZjb0ZBag
         /KPFtvwUW08vcEVa4n7n7kMEXHiVPpwmqilFlswp5EgtJKs6uCjFO34xakSIWuS/Bpm1
         N2wmzH3UdPxcXw0Hgzm/W2ukJhq6Y+QjeVDsi4au6FSMSg+jZe+eeTMLdOiUjA+pOZbp
         Yrqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=mc1SYjLVmi9hQ3qnYxRsBDo5bthKRsGDInhBM/MARCQ=;
        b=DsM6+jgdiDh9Ycc9A3sIW1E3HMOKt20/9Ewl3WEwFUbAgs9/cPr1V7UIVN+F8YjsIf
         AUIugA66bDod39CWxNJelYKJecUGJRHtF15/wEl1OU8NaNpFdW6Dg/h9BOClalBDNXxH
         k6lk5ymadeOHF6NeXbSY6blF1+h3AmYovPKTYqKs67KMQPa2Wb4gkg+DMKxcUcUpgkzi
         aTvd2W8yWF2n0s/ESBPxV8FwmAScL0TWuK+RtDNJkcsEtmwIIIvwVJHZeF2xcgXhk4Ic
         Zvi1f3z6CtQmAMPG1F5NBCMYTR6ECtnHXomSIrBJwNILQIgXUjipdEH14CAbo50P4JhY
         rcfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9si18922164ejx.316.2019.07.31.08.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 57D91AFA5;
	Wed, 31 Jul 2019 15:48:01 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	will@kernel.org,
	robh+dt@kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	frowand.list@gmail.com,
	m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org
Subject: [PATCH 1/8] arm64: mm: use arm64_dma_phys_limit instead of calling max_zone_dma_phys()
Date: Wed, 31 Jul 2019 17:47:44 +0200
Message-Id: <20190731154752.16557-2-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190731154752.16557-1-nsaenzjulienne@suse.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By the time we call zones_sizes_init() arm64_dma_phys_limit already
contains the result of max_zone_dma_phys(). We use the variable instead
of calling the function directly to save some precious cpu time.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/arm64/mm/init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f3c795278def..6112d6c90fa8 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -181,7 +181,7 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  = {0};
 
 #ifdef CONFIG_ZONE_DMA32
-	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(max_zone_dma_phys());
+	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(arm64_dma_phys_limit);
 #endif
 	max_zone_pfns[ZONE_NORMAL] = max;
 
-- 
2.22.0

