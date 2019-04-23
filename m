Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0915C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46FE0206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:07:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46FE0206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9A36B0003; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A67D96B0007; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96A9A6B0008; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0636B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id j8so2337336lja.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:07:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=T857UWl4vW/mMLkowhYpmmGUf62PJOrVKCTWr9tpU4g=;
        b=JzMe3FlFIpNSl6ghsjK2Ayy8p/bH8NVESs9uZHU9eO+3rC0RRR8YPvj1U9KEa22CEh
         ImVFOJaw9FyOg5wIiIie+toFEGSlnHKqteKfWrw/UPP3Dr2FysY9eDB1B/lIWGK26xcO
         I8eaxLX6eHiO5AVV9S/dO43dBuNLvF58KD3tkpLh1uOEsbSqTFT/TTcchegrWQt2o9a7
         nCb9c9xttbX4jTOAqq6VAp63SQzp/fFMt9qm6W48FNbFsmOVgq1/v3TmXNxj95nLsk/l
         w2GhAJ8cXMwYUJ6VFr1zG7FkwR30m2zGYvmBr4fVw2e0wno5ctdK4pCofAp9gRO8y0KX
         f0pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUk9XHajdQbjM1Nt+WxLd9sHV6VIs1uBY3lNVztrMRsbxBJXRpa
	pUpidovDjAjn9at2u04y6OrKzklEJpWhskBExphPwlVrNiHeeDWJDeVwRzborhB7p8GD8f+5RAY
	TlvhHigbsz6Jc9YT8Ap4t6L0aLCFfQdjL0a+0RH++BpSjaBjPKntnqpnreeeM/elUmA==
X-Received: by 2002:a2e:8794:: with SMTP id n20mr14083809lji.76.1556021263587;
        Tue, 23 Apr 2019 05:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqza+dm4C7Y+IqZEopa7k2+WHLDRXPVXCgdUrp3KGkqSi4xWWkCDhiP/mIl88tmHfeSzEdIE
X-Received: by 2002:a2e:8794:: with SMTP id n20mr14083761lji.76.1556021262449;
        Tue, 23 Apr 2019 05:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556021262; cv=none;
        d=google.com; s=arc-20160816;
        b=K+zJ8ulUvfSwScXhXaGx1yYzDOZzm2TY9fRv1/A50flZkU/SXJKJaxxmmENZYjbLX8
         x4SzppBFtFBLEe4kSV4UJ2Rm3b+l/BkJN9qwKMPn03V4Ngy4nTo5mNCEvSBexqdxmSu2
         zLs2JzyGph5sfUInjwDU5ztnhU+I5PuTAWvAJumre0uoJecsJt/j4CaL6YwKZZb1ELBs
         pxwGWozchGMvROuL/aQ6bGcnA29GujTDE0ULG06HLljMWzDX+jo3+Mzd+ZBXFd5JOjfh
         GNN9oTbGqaeuVK1AV61WqjQY974Zf/2A8NpLG6ptDSQPa8nI11OSi7UoX4MGdog6j+6r
         Fuvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=T857UWl4vW/mMLkowhYpmmGUf62PJOrVKCTWr9tpU4g=;
        b=YXBG+VAB+GC6JTIiloMVRLGswkIc4p+PVboMo9em/c+aq6NZvsvJUl4saH/8aq9oCa
         H4gV1uHLFEzwTiUmip5N07hz8YhQ0iW25pb4u4QOyEHmMY7c/RKEjHwdmAnILFA3Cvjs
         g0worpWeHJscWh4kZPNinZimAtntnSg5bLAuREWHh8v5Ca2gmrYFostv2CQar2Na55JW
         /YYRzLMX3qSP7sYdUnEV8gJckXqM2Tz5ygztuoqwgpFJzmq2JgLLRv60zsxSJr7deCy2
         q/CL24bO9zEaepj8of9pkWiKNnlPplk+Wd0vYNVuPTjzq1XMzp1vjpTq04SqJhmkiyNj
         phSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j10si11316307lja.107.2019.04.23.05.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 05:07:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hIuD5-0000jI-Hi; Tue, 23 Apr 2019 15:07:39 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/2] mm/page_alloc: avoid potential NULL pointer dereference
Date: Tue, 23 Apr 2019 15:08:05 +0300
Message-Id: <20190423120806.3503-1-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ac.preferred_zoneref->zone passed to alloc_flags_nofragment() can be NULL.
'zone' pointer unconditionally derefernced in alloc_flags_nofragment().
Bail out on NULL zone to avoid potential crash.
Currently we don't see any crashes only because alloc_flags_nofragment()
has another bug which allows compiler to optimize away all accesses to
'zone'.

Fixes: 6bb154504f8b ("mm, page_alloc: spread allocations across zones before introducing fragmentation")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 933bd42899e8..2b2c7065102f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3461,6 +3461,9 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 		alloc_flags |= ALLOC_KSWAPD;
 
 #ifdef CONFIG_ZONE_DMA32
+	if (!zone)
+		return alloc_flags;
+
 	if (zone_idx(zone) != ZONE_NORMAL)
 		goto out;
 
-- 
2.21.0

