Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC992C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9758C206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9758C206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 307778E0034; Wed, 31 Jul 2019 11:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 290528E000D; Wed, 31 Jul 2019 11:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156B98E0034; Wed, 31 Jul 2019 11:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B26188E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so42684136edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1RTLm79+PCTkW78/wyWR1dPnN2NdqNkCsW6ORpXl4gE=;
        b=s5p/JdArYO2QlKZ5n2TyGbFCQyfF562oVHuR/Vu4wig0kOneBcT9nmljUL4dmtaxpq
         SVbXcS2nRccAKTnO5lHVgupPdTGrsDl0RYwZxr1MCAVbBxUe5+ZUv6xX0+YexVitxyMc
         unuGEQ4taotCnmnjBlWK4hCb3QpioDNCD2m4jDasY2pni75EXmqT50e3hPNmJVB49lmZ
         QvKhoddkjY+s6bsLC8DfgovrJxBDXVX9kK6Rdttm9Znk6ZCAhwpFWnSVSL2yuYRP5eT8
         94bk8Ay153UBZFeIj6i/Lp2K7W9owjSfFgaxbAqz0kiFvLJ5bFunu0EzSiTZO+6XrmOu
         rl4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWESpVRFQ1DfvPQBdZKj44fXquLUCJ/nEwtOfo6ZBqlSe1pwi03
	1VEhFd0kDV3nehPSIGWEfvp4Ag1JiHo7U9PYYvuEk24V7e82c2nc525Fy322N6HtQdjYTsSXJWr
	+orQkt8ksFGP5HDoiOU5oB/vi6UPilcFbP4Qo7zes0AF0/ZB56nfwGOAs5PT2Nr+fhw==
X-Received: by 2002:a50:9468:: with SMTP id q37mr106694260eda.163.1564588086329;
        Wed, 31 Jul 2019 08:48:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx46Izd3htrIlZAl+DHA1MBTEQkzEbFvOY+aExsVjd+L0BbmN5/ZC+lszYvLPoHzgkLpVU
X-Received: by 2002:a50:9468:: with SMTP id q37mr106694203eda.163.1564588085645;
        Wed, 31 Jul 2019 08:48:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588085; cv=none;
        d=google.com; s=arc-20160816;
        b=fOFW5eeTt2Zc03XTzfEB4kzJbbeJbD6nT08NiYFeD8fXO5qOWeIDzNohwGV/Hkr9pY
         XfWwWwsW5HlRY+nEAhuZGHhCC57x3A2Ont1ojUejw7YJTdphPuWUWc3cEDPN/u9FFjT6
         5a7zWODFG0ANbLdBcNFwy7yf1pPBfW7eXatVoYVWyMH20vWMqu0yGQBdQC5r8/UEyxBE
         LixeYtkLBWvR1RrH2y/Yr7neU7jzkSmonX5F/qgdfJVfwX2kM7+mWEB62v4S2aOhYFLb
         AhlgwSCYVYTLolRJTbD1WBqWog/rYijY8g3AjR97DijbE9b/DeeWuvfeSJvZvGmmDIdf
         j5LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1RTLm79+PCTkW78/wyWR1dPnN2NdqNkCsW6ORpXl4gE=;
        b=WYd/i9bQxbRfwbDjIm9K+kGelphnfJM9+4AplORn3DN3eVZBzhEa/18fy/Zt+pp6bR
         x01sbb4Inl83tms7rz8TVoiGkVpfVwM0NsOTYBqH7hH9hu8LljQ+oV3P7kh14YbW6t5h
         ndkauuF15C+OUOwDbv4R22XnqYDGipJppOJVQTgGaxht88UNPxkWUusI37bBbxINCwmx
         WM1TGH12qBy2Vb9S19ignhBykVcf7QOd84L2tnzcLB66be7GnLRU5x7u8aaa2lMOMxPF
         b9iRfoK+ItqyGMXOf53DVU4zSPnG7cpmIB1/Yly32AKcSqSBLqJjjPpD1p7pBEvm1mRx
         HQ3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w58si22983642edw.316.2019.07.31.08.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4554EB020;
	Wed, 31 Jul 2019 15:48:05 +0000 (UTC)
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
Subject: [PATCH 4/8] arm64: re-introduce max_zone_dma_phys()
Date: Wed, 31 Jul 2019 17:47:47 +0200
Message-Id: <20190731154752.16557-5-nsaenzjulienne@suse.de>
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

Some devices might have multiple interconnects with different DMA
addressing limitations. This function provides the higher physical
address accessible by all peripherals on the SoC. If such limitation
doesn't exist it'll return 0.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/arm64/mm/init.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 8956c22634dd..1c4ffabbe1cb 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -174,6 +174,19 @@ static phys_addr_t __init max_zone_dma32_phys(void)
 	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
 }
 
+static phys_addr_t __init max_zone_dma_phys(void)
+
+{
+	u64 memory_size = memblock_end_of_DRAM() - memblock_start_of_DRAM();
+	u64 zone_dma_size;
+
+	of_scan_flat_dt(early_init_dt_dma_zone_size, &zone_dma_size);
+	if (zone_dma_size && zone_dma_size < min(memory_size, SZ_4G))
+		return memblock_start_of_DRAM() + zone_dma_size;
+
+	return 0;
+}
+
 #ifdef CONFIG_NUMA
 
 static void __init zone_sizes_init(unsigned long min, unsigned long max)
-- 
2.22.0

