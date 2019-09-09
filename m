Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 444F7C49ED7
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 132E32086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 09:58:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 132E32086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F2466B0005; Mon,  9 Sep 2019 05:58:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C9B66B0006; Mon,  9 Sep 2019 05:58:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E0C06B0007; Mon,  9 Sep 2019 05:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7AE6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 05:58:16 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 031FC25714
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:58:16 +0000 (UTC)
X-FDA: 75914931792.03.swing18_deca2f33825a
X-HE-Tag: swing18_deca2f33825a
X-Filterd-Recvd-Size: 2224
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:58:15 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3401ABE3;
	Mon,  9 Sep 2019 09:58:13 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	linux-kernel@vger.kernel.org
Cc: f.fainelli@gmail.com,
	will@kernel.org,
	robin.murphy@arm.com,
	nsaenzjulienne@suse.de,
	mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: [PATCH v5 1/4] arm64: mm: use arm64_dma_phys_limit instead of calling max_zone_dma_phys()
Date: Mon,  9 Sep 2019 11:58:04 +0200
Message-Id: <20190909095807.18709-2-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909095807.18709-1-nsaenzjulienne@suse.de>
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By the time we call zones_sizes_init() arm64_dma_phys_limit already
contains the result of max_zone_dma_phys(). We use the variable instead
of calling the function directly to save some precious cpu time.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/mm/init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f3c795278def..6112d6c90fa8 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -181,7 +181,7 @@ static void __init zone_sizes_init(unsigned long min,=
 unsigned long max)
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  =3D {0};
=20
 #ifdef CONFIG_ZONE_DMA32
-	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(max_zone_dma_phys());
+	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(arm64_dma_phys_limit);
 #endif
 	max_zone_pfns[ZONE_NORMAL] =3D max;
=20
--=20
2.23.0


