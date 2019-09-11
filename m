Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E715FC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 18:25:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FBFC20872
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 18:25:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FBFC20872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E20056B0010; Wed, 11 Sep 2019 14:25:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD1F86B0266; Wed, 11 Sep 2019 14:25:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6A96B0269; Wed, 11 Sep 2019 14:25:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0119.hostedemail.com [216.40.44.119])
	by kanga.kvack.org (Postfix) with ESMTP id AEB246B0010
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:25:53 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 53F818243770
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:25:53 +0000 (UTC)
X-FDA: 75923468586.24.pear15_3360307a2d24d
X-HE-Tag: pear15_3360307a2d24d
X-Filterd-Recvd-Size: 2189
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:25:52 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9B6E6AC50;
	Wed, 11 Sep 2019 18:25:51 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	robh+dt@kernel.org
Cc: f.fainelli@gmail.com,
	will@kernel.org,
	linux-mm@kvack.org,
	robin.murphy@arm.com,
	nsaenzjulienne@suse.de,
	linux-kernel@vger.kernel.org,
	mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org,
	linux-arm-kernel@lists.infradead.org,
	m.szyprowski@samsung.com
Subject: [PATCH v6 1/4] arm64: mm: use arm64_dma_phys_limit instead of calling max_zone_dma_phys()
Date: Wed, 11 Sep 2019 20:25:43 +0200
Message-Id: <20190911182546.17094-2-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190911182546.17094-1-nsaenzjulienne@suse.de>
References: <20190911182546.17094-1-nsaenzjulienne@suse.de>
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


