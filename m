Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 452F9C282E3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DCDE206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:07:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DCDE206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED6F66B0006; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E85B86B0007; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D751B6B0008; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD866B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:07:44 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id n6so2457272lfe.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:07:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X0/+2BMi/4gWHNjoTTFh3N0tTHjFTWGReBAP9LdRGHM=;
        b=fRFHbq7dcTrmr/W5mNZT3YbKZDxo8aM6RXNO4y447WE1WSpTlUf7plxndzTUpPOo2d
         2uKy+xII/ng6jOoGA8JksApwI22F97ICDkI+WYdEYIq3DA2UCOUCW2acNs2NvQJQRfYF
         TLOYHaOXpHHwNmHR4CNwRwtslgNCTx4mKSNGuiXKnBzGatDCQZiiuY6kTABFHu4iuc4t
         S38lzaha0tgHFZHMkFvl+EcVaJfSr25osv5RbxdgBYlraZVVd2ZXMACfDS5NLSu8x4I7
         xnExdqd89MmHAAxriIQNPPWp0zao1nWaf66FCKZeqPh4UshrdZAXkzvdE3KM94s/fmdg
         6J0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAU/MRlpiE24X/IM/e/fV53Cb7ctQfhhPR8/vyDojQPBzYEWLmtz
	KgasB7tWDSmGvW2rYN2mTdrlT2ze1bIKXJNOOmU8G3pBs9fVJND/EqeuTCcKQJPm/dK8gtzI1Dk
	a6ZSn6W4OleyfsygZnR9RtJigO+ADYByVNlP7kICc4j+K6wEreu5khYy4AfOVjS5gtA==
X-Received: by 2002:a2e:8648:: with SMTP id i8mr14084911ljj.166.1556021263886;
        Tue, 23 Apr 2019 05:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAjY4dTRezG+l/344ZZNdPWhZlIjaPSven+o90PcUsBKbhPBdOtNRaxoLfekhzvcoUxX2b
X-Received: by 2002:a2e:8648:: with SMTP id i8mr14084854ljj.166.1556021262449;
        Tue, 23 Apr 2019 05:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556021262; cv=none;
        d=google.com; s=arc-20160816;
        b=DqB5ONB3iXYQPcJ6lLwZFLOQHLoMSntOwNL+E8d3BbRb35XdXdip4vr51b30jWYQxT
         C9Os0istPv2YlwRUc0W1AgnuQEyhSZo7vRwRqzPhpjnhMjkycXOHj3phTipnBCn+FIyT
         O5MpSKyKh22C+WwnhAja7H4O4XFnjGWoYcHGy9bslXeoWzPwnXy1cUO7S+AjURonEvsY
         bAVIXeTyvZCPbmy3Vo5ZzbDWvcdhSe7nc02iarZvhFs5B5wyUeP3iCgeo80yBPp67GFo
         fpcUP1OsX6911/2Q3wuKyEvoQwr/yYzx72ISZ/WYGHgZb8QflHc9/9xu23zF2RKTwi/H
         Un5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X0/+2BMi/4gWHNjoTTFh3N0tTHjFTWGReBAP9LdRGHM=;
        b=vzCMHA7JP8Hsa2QS6CDm4cJYomx6FRO6fFLVfbwhmF9j6HDQQviXbso8K/HoPNeGkR
         oZpwwvlH9KVfRcx1uY6S928QTYLRmJUkQys7XuR9vNwwWgS/0WKIOYQJeWKbPGKpHdiL
         Tjx4R9s1KYoSYb4Y+OE5KtsxaLo2t5HyFNXNWkZXdLhvCh5mDwTzrWVFxfdG94c9/FQP
         HlOYLSHvIWCz895cUA6iZxtod463yS74rECLUXJdxXfds753y7FcCGoPx0vTsJ6VG4vb
         LDZ8pjio9IB42ww6YckprRHGu/t6dV93BvSeiE2bzdatMC/eLJOnPdbRMGP2PgyRkFuI
         sGdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id c24si11662545ljd.53.2019.04.23.05.07.42
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
	id 1hIuD5-0000jI-Pt; Tue, 23 Apr 2019 15:07:39 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Date: Tue, 23 Apr 2019 15:08:06 +0300
Message-Id: <20190423120806.3503-2-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190423120806.3503-1-aryabinin@virtuozzo.com>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.

Fixes: 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b2c7065102f..a85b8252c5ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3465,7 +3465,7 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 		return alloc_flags;
 
 	if (zone_idx(zone) != ZONE_NORMAL)
-		goto out;
+		return alloc_flags;
 
 	/*
 	 * If ZONE_DMA32 exists, assume it is the one after ZONE_NORMAL and
@@ -3474,9 +3474,9 @@ alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
 	 */
 	BUILD_BUG_ON(ZONE_NORMAL - ZONE_DMA32 != 1);
 	if (nr_online_nodes > 1 && !populated_zone(--zone))
-		goto out;
+		return alloc_flags;
 
-out:
+	alloc_flags |= ALLOC_NOFRAGMENT;
 #endif /* CONFIG_ZONE_DMA32 */
 	return alloc_flags;
 }
-- 
2.21.0

