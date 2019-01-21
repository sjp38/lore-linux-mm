Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDAADC282F6
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 09:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B2E52085A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 09:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B2E52085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4167B8E0007; Mon, 21 Jan 2019 04:38:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C5A98E0001; Mon, 21 Jan 2019 04:38:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 267A48E0007; Mon, 21 Jan 2019 04:38:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D59FD8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:38:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so15567090pfj.15
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:38:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=40fkhlvKt3exakgkZBKxTVwjvkc8X48HNmJX/i05Pkk=;
        b=N6XhQMMF+Y388TVletq7gfPu2ILkwWMZ9h0yRUJCMA1kTKO3/S0zW0TKtE6GmO8vjX
         6Y/bH3PxNxrq6nN+KoZu4j51ZjECS1axK139kolg4+CiGxOxKw1xy3CA95oSRJUOVPId
         eFKwCtiQlmo5mgyKYmekWw/tTHAu4xbslYUG3Pl1/5oOJUxYXRHUTuAs74uxSaBl2m43
         MOKb2e5UaoQsUvwtvBr+EeBJsyoA7ljgA/ZmUoBlq9fu0vQEnvGnGYtw/kdMoiQvsF4p
         tM6h+Kt0WVV2dNkYlzw/48TxL3DG/NdffeDLJZ+DfzuDqEv6RAeUmJhG14HNR7EzuW27
         J7/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukdkAVNS64WIx557naXaoOrAjOA8rfDpi7YVZIxozq/C1D5B9g1N
	vTBstpqrOUOy3neb3lG7p8Ir9X4Z3IkaFRmIzcMc1Ccs4GdGsvjhxyP4bqWwVsV6+bf0PJLKVaX
	bjuq52gL9L2AZjKoQ/WRSG9mtismC/wXqjWZ23IIeRc0376JIK9QESehr1dFQmAa6Mg==
X-Received: by 2002:a65:434d:: with SMTP id k13mr27824030pgq.269.1548063504551;
        Mon, 21 Jan 2019 01:38:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4mq3I/Zk/niQRTruEPb3P8FCpxEi6yf/Q0vjYNjvXdxL6VyXem/UzeNTKREPI/AWoXuuHP
X-Received: by 2002:a65:434d:: with SMTP id k13mr27823995pgq.269.1548063503853;
        Mon, 21 Jan 2019 01:38:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548063503; cv=none;
        d=google.com; s=arc-20160816;
        b=N+LqFT+pVbk/1fFRFnWtSkNK2NpplI4ijgyCK1crrwH4QEpmuWbgyb1JbG+UDlFWDw
         DgMLKE9ATFWjwNNCFnKTez4PBEJVqAV1Gmfz6StsH7o8NKRq33ajer7OqtNEvVfselVL
         rQGuatIWXB2Yy0/aGBjEqM1Rubnc2BOLd7ndGKFfUm7CuabeaFSP3GumzkDrmmXrvO98
         g9AZ79cXwqXnd3pK3GARKwmNppFphoqcbVIQsqtQIFQ2969fKnDp2gUI5bSd2IWnuOfb
         7Pv+R4ma71gmmpHANpSAEtlzzj6yNJDO8K+S85vlI+CyNFpA94l7Vs8ynnpct/Lgze8j
         hC+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=40fkhlvKt3exakgkZBKxTVwjvkc8X48HNmJX/i05Pkk=;
        b=fsm5x6N98sa07LEBGmDAZFvS1SsAN+/HsjyEq8H292K5Q6kNZ+dU1fn4XrSNPP39NB
         0O7ykED17frB8/9KK/naCxrBC6lYwx+23AZLxRbQryB9QyW/OWcgC4W4GejT7FHHdWwn
         UNNihi04Y9T2afOaWgxtYMJcSRG/Vvj+RsA++UP5HNv2fIxoQaSNGoCQajwDFtpeCTjh
         I8KNNgTeAiQhG6lweIdxtR3z4Ajqb2Emn6yK3X55gBFPD7OVDHt0krxjWLFx5/yQ3A2M
         GMtz5UMXkeRvwD0QzgTmCEHB4TRqJSusUtzRLftslYKvr1Li/K0BxidT2Pd0vsYFroi3
         Qszw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id e69si11679964pfg.137.2019.01.21.01.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:38:23 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: e39555a8435f4724bbf3fb08b876d1b3-20190121
X-UUID: e39555a8435f4724bbf3fb08b876d1b3-20190121
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1215981584; Mon, 21 Jan 2019 17:38:14 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 21 Jan 2019 17:38:12 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 21 Jan 2019 17:38:12 +0800
From: <miles.chen@mediatek.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew
 Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, Miles Chen <miles.chen@mediatek.com>
Subject: [PATCH] mm/slub: use WARN_ON() for some slab errors
Date: Mon, 21 Jan 2019 17:38:10 +0800
Message-ID: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
X-Mailer: git-send-email 1.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-TM-SNTS-SMTP:
	22854B56D5FA26CFEBB0D7CFF0AD17A8FEB7B10791F002CBBB518968530C57542000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121093810.dRNQl2F9uM_XMaEDKikrcgJ3QzimgBID_Jg4g3971oA@z>

From: Miles Chen <miles.chen@mediatek.com>

When debugging with slub.c, sometimes we have to trigger a panic in
order to get the coredump file. To do that, we have to modify slub.c and
rebuild kernel. To make debugging easier, use WARN_ON() for these slab
errors so we can dump stack trace by default or set panic_on_warn to
trigger a panic.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/slub.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..e48c3bb30c93 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -684,7 +684,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		print_section(KERN_ERR, "Padding ", p + off,
 			      size_from_object(s) - off);
 
-	dump_stack();
+	WARN_ON(1);
 }
 
 void object_err(struct kmem_cache *s, struct page *page,
@@ -705,7 +705,7 @@ static __printf(3, 4) void slab_err(struct kmem_cache *s, struct page *page,
 	va_end(args);
 	slab_bug(s, "%s", buf);
 	print_page_info(page);
-	dump_stack();
+	WARN_ON(1);
 }
 
 static void init_object(struct kmem_cache *s, void *object, u8 val)
@@ -1690,7 +1690,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		flags &= ~GFP_SLAB_BUG_MASK;
 		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
 				invalid_mask, &invalid_mask, flags, &flags);
-		dump_stack();
+		WARN_ON(1);
 	}
 
 	return allocate_slab(s,
-- 
2.18.0

