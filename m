Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC0EBC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67E8C222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="GQS/bI26";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="s6OKUXHN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67E8C222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CA6A8E0012; Fri, 15 Feb 2019 17:09:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2519D8E0009; Fri, 15 Feb 2019 17:09:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118D08E0012; Fri, 15 Feb 2019 17:09:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9EFC8E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:26 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so10451233qtq.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=r9i3vSlxWDPjuGqrZdOfoK2Xh9axnIDanzNb86muQ/I=;
        b=tiWqlp9Fg72iDtDYT+LGfV9hcBY0tomNSv+unuoN8A0FU9j2tx70x1TT5/UxF0xXii
         oETkXYQ013jvYriGhYGpOPlJU/G3vCEyOvnfkCjpUjyOVOdh97kAzdzWwutvLGX/DRCR
         E2ANN4LoAGas7jhI94LageTvdYyi3jfExdMpum/jkyv4ARLIlwczYZsBg3Nsdp0i2xkd
         3U49sipehkLn0TzmiVNDpVoIK5TJWprEoUDZ53Fbi09RzWeHMYQh5tmu/VXoYyp4gZrC
         obXg49QrmYHNrZDAuZdSOINJoHWQp5R7L1U+KbRRTRqMUGDeydeif/Nt44lnOHj0GTnT
         18sA==
X-Gm-Message-State: AHQUAua39DUgwPPL6Sqjl/IjvIbFi7IbH/S41IEO4NahQI9vM9T3uqAr
	wwSHLyrfmdjGLOeqOWfcv/trB91pJCHMme/ut0wM5mrdmpGjjeEGhxNVZkTFEqHLQ4YmdK6njA2
	6fWCO7H6s58ze0fuy3Vqqw3v5sYGTV4qE0qQt25XxS7z77L0ORTB4sObPEt4A3AiQlw==
X-Received: by 2002:a0c:b4ae:: with SMTP id c46mr2251327qve.91.1550268566684;
        Fri, 15 Feb 2019 14:09:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibx0GBRVeQ4vnroHS9My8uiQhrCaqmhnkdbiDgsmgdnSyoopcqiW4RtJkJPNSrQEWo3uYMt
X-Received: by 2002:a0c:b4ae:: with SMTP id c46mr2251297qve.91.1550268566179;
        Fri, 15 Feb 2019 14:09:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268566; cv=none;
        d=google.com; s=arc-20160816;
        b=VBCSL81QfUX4TtvPJzp4IDstKUB6iMHiDdcl0QLkvSiNNJO75matbR92egS4BTChR8
         YHCxzcKl4mh+VZMsFj7DpzLOkH+uuyXJ1e8RQeAnK9IO2di+345f5yckNDBXAheggG6B
         Tta8wz0esxfgTkqzg+zTen+n8HYSNPhjZBHv+S6pG+gN+XDjpddeMaIdf4tDKIBWSEOv
         vEovkpyjgjOmSGDT+gDWvhSvjp8sZWLvFt9+3N+BkbOtZ5xgdJN5TuT1skRhRy7M8LcK
         uU+2BjYXTgKg8j3PTNG6U3Drwfx9al1QbH3x/KdSAjYb1Y7hH9kjyjBjD6IfZh1i1Zdw
         GsMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=r9i3vSlxWDPjuGqrZdOfoK2Xh9axnIDanzNb86muQ/I=;
        b=iad/pF71jCzNeR56epYRlmiNmNJpJKWSqF/ig3agBTv/XSVqgXjA6YVvo/eOkyl1N9
         632LhCzdHffdu/sXUufOYL2SjTvMfQduGBjGjeI+Y5kcqKRxcuHPvl74nVbk0a2KXtHz
         m+Y2+n8Sc7luBj4AAmrwvcDXrqhSb85H+kOn64GpqbicvJgPtJwmhjKdK4Pti0buHfJc
         mA9/FeEuB2+T+6Ct9gTX+dLDUZPwESYS5duirMNYDSQNUy7U8vBGcKIACKk66fg6PYmT
         UGwSVyS4D2aGSYc/n570ajJv3Wh3tIiwe9ZbDAjp4kvJ7rrYeLOhEUzqIL+8+fpIVHwI
         4nsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="GQS/bI26";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=s6OKUXHN;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id w90si4410947qvw.209.2019.02.15.14.09.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:26 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b="GQS/bI26";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=s6OKUXHN;
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 6A54F31CA;
	Fri, 15 Feb 2019 17:09:24 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:25 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=r9i3vSlxWDPju
	GqrZdOfoK2Xh9axnIDanzNb86muQ/I=; b=GQS/bI26wmmBEUSWTQc1KDie06qmf
	dHHS6bcITudgOzKWqJm+bTQa3Yn9q/a8KZZie2M7okmXpoNg4mPOmHJnTgZEapT4
	BgXIhIm7O+Lxd+tFgWjRjyP2bFFU0X80GNp5O0liDYXW1PmjqBctKETvUOk/IQli
	oZ39kVtke9F4FjDhff4fN2MeHyDTPMN8V1P9kNVhs1G5HR0RD7IC1f+Dbmj6iONa
	+BoWnCBMscCLCtTJF34/l8cKOadaYaJp3bRsCGvfZB+NYghl07+fuNL1KTPUdzxZ
	6B8Kn245uznBC8SaduoZVmlsGRYOVR+WTD8si2rtIZe4oY1a1+RKQsMrg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=r9i3vSlxWDPjuGqrZdOfoK2Xh9axnIDanzNb86muQ/I=; b=s6OKUXHN
	jGHg3CnPH6ajnJDQiWl02z+FyKMZpcL3YW6nPFe0amZCViM856OiTgK5pKfVti7r
	yqzFmInVcouPviwuKTx0+TdplJVscLvUVrUFEcHm5LezqdWiznR32XB6XeKF8kld
	YOoT/HYs1pnx3VlLFcUm8qT0Qt96R1JHEPwyvZXcfgZQPWEe9juedl+5bh3xVeCG
	5W5lAYTWYuFwc1DwqPXI8gRPD+PdVcklgNhWCcQke7AovVLMaz/JklW5MCjf5cVP
	9q6EQN3eNeKRoJjGnCeLLXuvF7C6o/YdyEtuW88Nac7btKprHbwSCXQa5+7FXEV5
	/9xgaAJ/UhxJ1Q==
X-ME-Sender: <xms:kzhnXCGkeqKF5j47MmAuN2m-J83awpjWIjiTX_b1Gc7sy1WFAQ3Qwg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpedufe
X-ME-Proxy: <xmx:kzhnXE2k4AtCSNnuNV3Zhg1DQEwcjp5Wk7DoHituV80d34A1BW-axQ>
    <xmx:kzhnXEyxV9R5CCP_oaOtKRTx-4nItHPNyA_MxS0hz-ep32kM0a88qg>
    <xmx:kzhnXOHXCdL6FoORRs_bxd70H253rk2Aznc6BD1NNASr6RIzaJgvVw>
    <xmx:lDhnXI4zKei7BqJSiy7WUR3Sx2LXfGihVcj7xrDm9FFEJwpvou0eEA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 74384E462B;
	Fri, 15 Feb 2019 17:09:22 -0500 (EST)
From: Zi Yan <zi.yan@sent.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 16/31] mm: thp: check compound_mapcount of PMD-mapped PUD THPs at free time.
Date: Fri, 15 Feb 2019 14:08:41 -0800
Message-Id: <20190215220856.29749-17-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220856.29749-1-zi.yan@sent.com>
References: <20190215220856.29749-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

PMD mappings on a PUD THP should be zero when the page is freed.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/page_alloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dbcccc022b30..b87a2ca0a97c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1007,8 +1007,10 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 		/* sub_compound_map_ptr store here */
 		if (compound_order(head_page) == HPAGE_PUD_ORDER &&
 			(page - head_page) % HPAGE_PMD_NR == 3) {
-			if (unlikely(atomic_read(&page->compound_mapcount) != -1))
+			if (unlikely(atomic_read(&page->compound_mapcount) != -1)) {
+				pr_err("sub_compound_mapcount: %d\n", atomic_read(&page->compound_mapcount) + 1);
 				bad_page(page, "nonzero sub_compound_mapcount", 0);
+			}
 			break;
 		}
 		if (page->mapping != TAIL_MAPPING) {
-- 
2.20.1

