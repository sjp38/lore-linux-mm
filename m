Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15D06C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:43:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8FEA20B7C
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:43:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8FEA20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=pengutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654EB6B000E; Wed, 29 May 2019 06:43:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 607F26B0010; Wed, 29 May 2019 06:43:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CE6F6B0266; Wed, 29 May 2019 06:43:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 041C46B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:43:35 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id b79so859103wme.5
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:43:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=We4P0EFUyDAKiCU8ARtGsC7AJfJgPUcMxyrvg+1j4ho=;
        b=VeD9ZtXtOtnjoWbqnKAKvwlmflNVoFAp2R1fUD6/RI7aVM5QEisV5cEfmYcqmpsdD/
         RU2v979h2WoRXB99XPKLvnkDYcJB8hA+rnaTaLbUhecbDzraQnptKZAMiXZR+ExBst8s
         71y+qbMEKaFsIhWMybyhIAWtP7dfHbQCZoVHfjR5bsn7190BoMP8l78ED9YKz4eSuJsx
         scWGTRYwIlQeGehdJQszJ8gU48BK4FHhycqwRN6WMLoJScjPwMKvAfNYA5uDBcW3sEO5
         OfkEzi8n+XFxQRodz34f32r1I8byNTx+4D8vCfiHDrGQjR2IhkXvP0vGQ5m8/JGrBmJZ
         lx1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
X-Gm-Message-State: APjAAAVaNCV1lLO/fI0X3HVCubdItDJ2zObPx6SktESda5qwE+ozhRAW
	k4zi3MVg4/LVS5vTPcLwHrnaBhqpx3v7ajhIReju/DPCvQglIbZ/uB1np2jASXL28sy7L/b7NBC
	g4Qlyv8hjfJDi2/6YYocg3dWB9jsNqTnljsYyKF3bkMTgn5Y1G36fTYuYxWFerE6Ipw==
X-Received: by 2002:a5d:4310:: with SMTP id h16mr39666355wrq.331.1559126614489;
        Wed, 29 May 2019 03:43:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVWhqrvLBKlfqPY1n3xyIHUDHuI0EFq8frkRrMwzsQTWux/huT6PBpDwaCA2avwTBUXYei
X-Received: by 2002:a5d:4310:: with SMTP id h16mr39666017wrq.331.1559126608428;
        Wed, 29 May 2019 03:43:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559126608; cv=none;
        d=google.com; s=arc-20160816;
        b=svEGtgP93A2Z++WxGRbXO4KRCgtHsf6jU68jjvrWO46IAO4aGAtS1wVotCWZFtYMa8
         PYMZ4u+zUOcam0x4CLEBxaeLw9thxfPQ88ttCmhGVhA0SNofBJPnnPUQ0CFzyzbaqMXm
         rbUmyyOCFCUpd/chnKW34htykIjXRaydOk0jZMz+Mv2ZBnTK8aYv6/LqzmfAFlOVJtjc
         m5+5XHsV959AqGjYiUZBSFQMDtQYnUrbEJeHE2qs1zcXjORkrEYGnHmlFMf1T6rN4SKV
         CfH9Thr8kebzRyvpa5JoqwxUGS8dbcL31RSV0iH1YCmY8xQL1ZGTsR7fn94/ttipVJ3f
         Lxhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=We4P0EFUyDAKiCU8ARtGsC7AJfJgPUcMxyrvg+1j4ho=;
        b=pZYUgTCkvc66G744iyBoYTf7uMuBEbQl54OBojLuLGN1cnaX2lIbs2OsKtoNwU+CWk
         Wjnpy0ujkGaYln/coDHDfJmeN2pWNeebhesjNV+41yqJLNvxEwQ+feTnbpr8ech1YJ60
         SjhMV170/EQlMmjUjsAsO16p9CD7AboaU6Gf9oLURYGPv47ZpKyjp+7oJybC4502ppOw
         uGXwbdU8CkZSfrlYE6NC5lpniKI61sBx45z3dd+vBRUtkCAFEu21mare26fv8kqeM59V
         0HC3UvqhbCgaWYZUxlXg3NKGDpRJiSQatx8QyfKOMHp2zdvSOylSbZNKLFcb0NIJ7K13
         +fvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id o9si2060984wrq.241.2019.05.29.03.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 03:43:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) client-ip=2001:67c:670:201:290:27ff:fe1d:cc33;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
Received: from dude02.hi.pengutronix.de ([2001:67c:670:100:1d::28] helo=dude02.pengutronix.de.)
	by metis.ext.pengutronix.de with esmtp (Exim 4.89)
	(envelope-from <l.stach@pengutronix.de>)
	id 1hVw3A-00016K-Ch; Wed, 29 May 2019 12:43:16 +0200
From: Lucas Stach <l.stach@pengutronix.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Yue Hu <huyue2@yulong.com>,
	=?UTF-8?q?Micha=C5=82=20Nazarewicz?= <mina86@mina86.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Dmitry Vyukov <dvyukov@google.com>
Cc: etnaviv@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	kernel@pengutronix.de,
	patchwork-lst@pengutronix.de
Subject: [PATCH 2/2] drm/etnaviv: use CMA area to compute linear window offset if possible
Date: Wed, 29 May 2019 12:43:12 +0200
Message-Id: <20190529104312.27835-2-l.stach@pengutronix.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190529104312.27835-1-l.stach@pengutronix.de>
References: <20190529104312.27835-1-l.stach@pengutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SA-Exim-Connect-IP: 2001:67c:670:100:1d::28
X-SA-Exim-Mail-From: l.stach@pengutronix.de
X-SA-Exim-Scanned: No (on metis.ext.pengutronix.de); SAEximRunCond expanded to false
X-PTX-Original-Recipient: linux-mm@kvack.org
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dma_required_mask might overestimate the memory size, or might not match
up with the CMA area placement for other reasons. Get the information about
CMA area placement directly from CMA where it is available, but keep the
dma_required_mask as an approximate fallback for architectures where CMA is
not available.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 drivers/gpu/drm/etnaviv/etnaviv_gpu.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gpu.c b/drivers/gpu/drm/etnaviv/etnaviv_gpu.c
index 72d01e873160..b144f1bbbb3c 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gpu.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gpu.c
@@ -4,7 +4,9 @@
  */
 
 #include <linux/clk.h>
+#include <linux/cma.h>
 #include <linux/component.h>
+#include <linux/dma-contiguous.h>
 #include <linux/dma-fence.h>
 #include <linux/moduleparam.h>
 #include <linux/of_device.h>
@@ -724,11 +726,18 @@ int etnaviv_gpu_init(struct etnaviv_gpu *gpu)
 	 */
 	if (!(gpu->identity.features & chipFeatures_PIPE_3D) ||
 	    (gpu->identity.minor_features0 & chipMinorFeatures0_MC20)) {
-		u32 dma_mask = (u32)dma_get_required_mask(gpu->dev);
-		if (dma_mask < PHYS_OFFSET + SZ_2G)
+		struct cma *cma = dev_get_cma_area(gpu->dev);
+		phys_addr_t end_mask;
+
+		if (cma)
+			end_mask = cma_get_base(cma) - 1 + cma_get_size(cma);
+		else
+			end_mask = dma_get_required_mask(gpu->dev);
+
+		if (end_mask < PHYS_OFFSET + SZ_2G)
 			gpu->memory_base = PHYS_OFFSET;
 		else
-			gpu->memory_base = dma_mask - SZ_2G + 1;
+			gpu->memory_base = end_mask - SZ_2G + 1;
 	} else if (PHYS_OFFSET >= SZ_2G) {
 		dev_info(gpu->dev, "Need to move linear window on MC1.0, disabling TS\n");
 		gpu->memory_base = PHYS_OFFSET;
-- 
2.20.1

