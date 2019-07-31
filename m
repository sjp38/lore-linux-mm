Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0223BC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C413E208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C413E208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 418608E0043; Wed, 31 Jul 2019 11:48:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EED48E0042; Wed, 31 Jul 2019 11:48:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 305D88E0043; Wed, 31 Jul 2019 11:48:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5F598E0042
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e9so31544675edv.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y1JUTJoMwtxuP9fpjTlmgOiVx9qaajEKjxesU1OKZaM=;
        b=qR9jvCFu6q014mVefeRSQ6sOqTyntxgsP/4B3Epgsu5gPXGiXlMLNNwCcX7RCj1Px3
         x3aTU//jUG2nzOVZbB+SVuAneX/27Br8Hy/5cLgunzu65Ly+SQCjKAKdqLSdxpX0SOYd
         gzBqqgv4NMuNUUyBWyFmKkf93eDYVN3lww5HLsUWq3hDp7J4k95PQFLSH/ya82wYB826
         JvkJIBTeuv0tdp2SUR8ZrJlk8FpmuIYFjSutRuzs78RixawSPmo2ZoIFB9SYwtcrAvOR
         sZNMq93TUOwnuFZ2NCkK/tq+KU80Kfnn/rwRwDkvQqwjGSezOXHi6IvVBRHJ8MX329PC
         W5Ug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAVPXgbKkdr1Wj2ULTzcWhatdH7D9SL/4VtDtxZBP/0/pI1Y700A
	Ta02qY3CCdY2GUsczfS98lxMIXF+cUX4CzhlKbB7ksjwr3f6aXCE+JVRmHLDteyVQogTehEzv0T
	xHY70mY+c9TYnjTsvIbUhsXB8Ay9ayEFKbyaGPDmppB7cKgwhOALvBONb1tkny32c+A==
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr7235442ejd.262.1564588092443;
        Wed, 31 Jul 2019 08:48:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrtW1qA48DRhwV5L5lTp7ZZlrD6SJI2UV1KM3MWmjWMYY119MpN8vC1VYXQqbym22Y9Yro
X-Received: by 2002:a17:906:19c6:: with SMTP id h6mr7235384ejd.262.1564588091585;
        Wed, 31 Jul 2019 08:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588091; cv=none;
        d=google.com; s=arc-20160816;
        b=iX+EdX4/pCCYb+xAH3Y+s7ghE5VRgaXDzKXKQjDd+Dzltj8j+t1PQFq0HSDL/mBNVn
         0/D2K4QpAYASmIVS5dYb6qRDk24U2h5ZfvnQmXcSVep1I7iRae6a8RFtH1DtTGfycCm+
         MkL8FLBpDCxGgi8JqZjVWCvfs5mvlARK0yzBzfmgGZyEiF+tHIIv6uOpKU6oKMx4fApY
         rlNh1/v1eJXDUPHjs4zpfWFwTzct5QTu9o1bKAc3jkalAgJpTazO5V/jofMohLMrO2Az
         ryX2xVQfdldPLpRqrLtV8mvesyjGdS37eS5OjC5nxKtq7OxvlWPxmIV+wfZUE0ny3Ioy
         8WWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=y1JUTJoMwtxuP9fpjTlmgOiVx9qaajEKjxesU1OKZaM=;
        b=xLl7pkFx2biwLVDYWb05iax3q/I9XE0yOVkF2kEnNk66tp9+g5+JWOAD3hZ5JMBWbD
         jL6zIPIqyV0cZCDn3fPpE01YIK8mu7O/xT9UP0a5uebGC/Xyn9eh2yB7JYpXxVWV0PPs
         N0wP1kB/+pysI0XLZBd9bvmZDvAWi+kR/D4RjhPhlqZeWBqIpFStaNVfVqzu+0trjpFa
         S0Bk9CauCa2xvAt0c3GFyYxpB18874TJQqk/5ro1Mdp0n85oyLosOBDcZysegfIKcWEP
         XTIBpR09fL6ddjoto/Cz/xwEOQImzOTyUPRW6GqaDjYA1U3tSzlPMQ4VSPoh6vrdu6g4
         Y/Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq12si20425835ejb.170.2019.07.31.08.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1CBAEB05E;
	Wed, 31 Jul 2019 15:48:11 +0000 (UTC)
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
Subject: [PATCH 8/8] mm: comment arm64's usage of 'enum zone_type'
Date: Wed, 31 Jul 2019 17:47:51 +0200
Message-Id: <20190731154752.16557-9-nsaenzjulienne@suse.de>
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

arm64 uses both ZONE_DMA and ZONE_DMA32 for the same reasons x86_64
does: peripherals with different DMA addressing limitations. This
updates both ZONE_DMAs comments to inform about the usage.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>

---

 include/linux/mmzone.h | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..8fa6bcf72e7c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -365,23 +365,24 @@ enum zone_type {
 	 *
 	 * Some examples
 	 *
-	 * Architecture		Limit
-	 * ---------------------------
-	 * parisc, ia64, sparc	<4G
-	 * s390, powerpc	<2G
-	 * arm			Various
-	 * alpha		Unlimited or 0-16MB.
+	 * Architecture			Limit
+	 * ----------------------------------
+	 * parisc, ia64, sparc, arm64	<4G
+	 * s390, powerpc		<2G
+	 * arm				Various
+	 * alpha			Unlimited or 0-16MB.
 	 *
 	 * i386, x86_64 and multiple other arches
-	 * 			<16M.
+	 *				<16M.
 	 */
 	ZONE_DMA,
 #endif
 #ifdef CONFIG_ZONE_DMA32
 	/*
-	 * x86_64 needs two ZONE_DMAs because it supports devices that are
-	 * only able to do DMA to the lower 16M but also 32 bit devices that
-	 * can only do DMA areas below 4G.
+	 * x86_64 and arm64 need two ZONE_DMAs because they support devices
+	 * that are only able to DMA a fraction of the 32 bit addressable
+	 * memory area, but also devices that are limited to that whole 32 bit
+	 * area.
 	 */
 	ZONE_DMA32,
 #endif
-- 
2.22.0

