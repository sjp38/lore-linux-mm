Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26DC4C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDB7F20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 10:43:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDB7F20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=pengutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45AED6B000D; Wed, 29 May 2019 06:43:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 431846B000E; Wed, 29 May 2019 06:43:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 347876B0010; Wed, 29 May 2019 06:43:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEE5C6B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 06:43:28 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z202so444905wmc.9
        for <linux-mm@kvack.org>; Wed, 29 May 2019 03:43:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=fzpjFpWtW4cn4Ss889ONrxtqSc7C+B6SWSLiGLQnKJA=;
        b=cbl+fVSvDLV3m4j1iA9TwLisLjP1LZLJO4mdK8NlwjEAyUmZsczONN/1LZOVU0QSGz
         Q9w4nYjpvW5Cw1Gmruh2004eHun+gM03sMOjllB2tPO8LGP+Gd+iCliK5lXKkKZktLt9
         4WIL/uJ0tu7AkTRVXfgD9tBt4fGepBG4Rnr5vaI5N0//rJTVAJ4X7sP4pUdp07nebfXq
         j/R0JkEf1A1+sT7cLKAFpt93n+CFFRqrhwQuaxfwbNdbrRQ0xSDxw/ewex46UPFN79IV
         62RrA4YghIywGP7Hx4S2urZWqU3giGoxtKQAoZ5R+f3nSFu+wpNxbyql5hjnOtSjbckb
         phkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
X-Gm-Message-State: APjAAAVogJIqTle5C8NL27L5tAV16ZpI/5MUKojZQhCrdvF8aRLJknZ3
	VyPoEpdbKSVaoSooDuXAWLFFWZAyu1mBnATbSbpwrV28BVXqJeZ1MdHIS+a/atw5sC/6BzUBrk/
	W4rP2gNtUOZv/q2tGnwF6Yry6GuX7TdiIvSrLusW1ZIbz5Kp8LlPbfiGegz1zsf5pEQ==
X-Received: by 2002:a1c:a00a:: with SMTP id j10mr6332411wme.41.1559126608505;
        Wed, 29 May 2019 03:43:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziQfF11H3Gmi+ZgFJuKWwoVqTCfCGpw2qbhDt5Ii+tXeOibyE6qjgGr319lyEi5yD1oQ8r
X-Received: by 2002:a1c:a00a:: with SMTP id j10mr6332368wme.41.1559126607523;
        Wed, 29 May 2019 03:43:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559126607; cv=none;
        d=google.com; s=arc-20160816;
        b=DI/kf8jQjxsGE+p0k1VbPLxoVfnhJUuOaRFiPXqEwa3/R0NPFk6SkDMj/ejKyrAVAT
         v0oV/YRtwrQXsu+VyTEizUolDdEPKZTFq6TJlklManiPwcnTyaHTeh/18b5ct2iMW/9/
         lMW/Ce6NExtbYTYHJv2kFEocCH6g2NM9kTIWW8NAKssg5I2WLAAFp9QW+Jef4JX8Fexn
         MnGHId1hAl1afV9qYovtIgenXUwfO8QYiTOlrevY1zE2M0YC4d3MW1iP5eGZxoE1W2Zs
         cVUUk+AIVItRp8DJANm1tNFMYGKRkXWlsrpu+nKi+ABdMYq2vi4oGHbjwNVJfQE65WjI
         jl6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=fzpjFpWtW4cn4Ss889ONrxtqSc7C+B6SWSLiGLQnKJA=;
        b=MQCD7bF4XqYnZd16D9rC8dvjubfz3SZL5x/egV5P53LVgARZYFnwvU5CcNcGwEzaFR
         l6wBeS1oGHkuiZFTmvt3N9R2BZjZXPLwnkP11X1QwfshFBE+YmkJ2inDMLb3EK4eOMi8
         7drHzYW+YWBgvo2WtohuSsB/upibm4cRRh0wbUoXoq7bf3ZGET8HBCmnMg+evGx8MzNi
         PEEADXlXtkrGEoPNusbFdzrTMn5aCQu1j0S4+h+3r5IfFiROx1hODYer0xhR9fsMfEyu
         taJ07a4A3OAL7eVhcMsiimfnVkGuXbhmP8l6bD+kaMLSQJ641s63CHxMx8mMTevNgYQT
         4Etg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id x3si3876195wmc.117.2019.05.29.03.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 03:43:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) client-ip=2001:67c:670:201:290:27ff:fe1d:cc33;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of l.stach@pengutronix.de designates 2001:67c:670:201:290:27ff:fe1d:cc33 as permitted sender) smtp.mailfrom=l.stach@pengutronix.de
Received: from dude02.hi.pengutronix.de ([2001:67c:670:100:1d::28] helo=dude02.pengutronix.de.)
	by metis.ext.pengutronix.de with esmtp (Exim 4.89)
	(envelope-from <l.stach@pengutronix.de>)
	id 1hVw3A-00016K-AI; Wed, 29 May 2019 12:43:16 +0200
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
Subject: [PATCH 1/2] mm: cma: export functions to get CMA base and size
Date: Wed, 29 May 2019 12:43:11 +0200
Message-Id: <20190529104312.27835-1-l.stach@pengutronix.de>
X-Mailer: git-send-email 2.20.1
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

Make them usable in modules. Some drivers want to know where their
device CMA area is located to make better decisions about the DMA
programming.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 mm/cma.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 3340ef34c154..191c89bf038d 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -44,11 +44,13 @@ phys_addr_t cma_get_base(const struct cma *cma)
 {
 	return PFN_PHYS(cma->base_pfn);
 }
+EXPORT_SYMBOL_GPL(cma_get_base);
 
 unsigned long cma_get_size(const struct cma *cma)
 {
 	return cma->count << PAGE_SHIFT;
 }
+EXPORT_SYMBOL_GPL(cma_get_size);
 
 const char *cma_get_name(const struct cma *cma)
 {
-- 
2.20.1

