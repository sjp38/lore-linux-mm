Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B216C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3405222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:09:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="BQ6h4EMP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="3v/Qhodh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3405222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38F9F8E000D; Fri, 15 Feb 2019 17:09:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 314778E0009; Fri, 15 Feb 2019 17:09:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DBB78E000D; Fri, 15 Feb 2019 17:09:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8B028E0009
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:09:18 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id c9so2510259qte.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:09:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=jPUMl05hp4GyYNPKyUU/j1/LhtwQWzBCTR2KiGtIjhE=;
        b=HUeVbpD1FUvfBBXm1GZOFbhbsud+TNonGQwf/Vy6zhu0WsuWJsKPli77bQCgIzDudr
         b649XafSwVayG435mqGsmMzfbD1scpamLp4wz3b9LRs7uTKKiWcKHi3h0fNSLK372dfD
         IkkKPIU6zxiHaBgTzGMLqax0Ip+FQOddZr1BEzTW04XiKcgCDl4zkdhFUZVQfl+3Yh/c
         Bj2jtid2Rs+yMs1Ipy8rtFldej5QgMSy8blPD6PQY+pVEXCJMm+VIgEWN+iBNiZ7Uom2
         2/qDcGthnIOOOAnEePGvbwO0CG5Ga9sZBGhqe6ssAEijp2nVq7w0CGIRgVAlWj7fFy7L
         dJug==
X-Gm-Message-State: AHQUAuY6sJhq/vh3vRS2sQu5D0V1EI12NmnOb4sN4ptRPYr0oA+LvSRh
	iTOaT3m6lLgIVyYDqH2ImiYJKBSrlZL0xBq+AynQbmAcHRT2i+J6K7x+adTo1U+AmJ6Sm4J1XqJ
	K4NQ0/eODvA0oevVwNE+sgcSnVe/NX6zduFOukxoLiFH4WDq4TSwxaFAdFIUPstOcLQ==
X-Received: by 2002:ac8:396b:: with SMTP id t40mr9188508qtb.159.1550268558754;
        Fri, 15 Feb 2019 14:09:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ1l5A6MeKFGEzqxVhYGI/N5VWAgGcYqP5RXDrwD44ENI3cJvtZAbGdrAhsY0eX2bV0PrHy
X-Received: by 2002:ac8:396b:: with SMTP id t40mr9188469qtb.159.1550268558135;
        Fri, 15 Feb 2019 14:09:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268558; cv=none;
        d=google.com; s=arc-20160816;
        b=d87r28LgYNdd7tXj5Ya7jlPcbd5O/AdQqI7y2anAyV+DAwm6pTDl1R71mcnwXATpJM
         OUoWu+YWcPcQL2iIUB1dL8ISd6gl0Qrle13eMImq503KQHAtT0PuWfiFqjAl6JRVbGes
         RgGvnjaSkhoCSCEYvZTO++KyAYT9g/XCMwf0IWS0aBrZP0PMqT4Bt2jB7b358mTpJ9iP
         060bIlxZC4OwMXl0JMhOHJsHQ6NVXA7mTOwGoBl5+zWNSHHdDirjwyuXA/7EUn6jUr66
         RnvZFxMJeb1alWE0OKpx2fJRq2haWh1O+KGeUF5mGzJovo5n0otPc+c3ILdSgsPsLn9I
         +C6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=jPUMl05hp4GyYNPKyUU/j1/LhtwQWzBCTR2KiGtIjhE=;
        b=n/VpN1k2J8QEBVKGyiVnMJ+s8S4YJfFtffWq1sQKPHQVQ9bvcfZxhO6FLSF1+TG7J5
         j6RxU2oxNRu40PHXYwtDjpDa78JlNvxOvUIXe9LjuffPf/8A6JwK7NZNga7/aomQliGT
         HMFDjunqp3x2wSaTp9Uv9rpbxLgIhl2okFloMuWs4CIOcoe+frE79y/gt803KfBvf2Ev
         MAGr2uQD0Mw8rSymw2X9Hc6IcBws6OfNFpaxjdHxAce/BvoM+LXret8ppGK8Sc7KACBl
         O0e6eesrgXX8maH2S/NkRCPCphqX0SwPfaJ8ThdHmhKDZrAdX+zf3ODl3qmnJk1Sx9Kn
         w8uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=BQ6h4EMP;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="3v/Qhodh";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id l15si4605480qti.7.2019.02.15.14.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:09:18 -0800 (PST)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm2 header.b=BQ6h4EMP;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="3v/Qhodh";
       spf=pass (google.com: domain of zi.yan@sent.com designates 64.147.123.25 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 4C83B31E4;
	Fri, 15 Feb 2019 17:09:16 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Fri, 15 Feb 2019 17:09:17 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm2; bh=jPUMl05hp4GyY
	NPKyUU/j1/LhtwQWzBCTR2KiGtIjhE=; b=BQ6h4EMPTg4jJ0R72Qup5JbWpeCpy
	dzOaqn8Ww8vNnPWA3Gsra+/513+QVm3TnPdfFClO5KVwub/InOwz/Mnx+T3N6UKN
	/zRSRUSUzkx8O9RHe9QTJM4nfusej/0Ti0wJrf5Sl6JgqKJ+B54Xy3qM0E3BqAX8
	rmKpUXAZCFfpVvSoATLHZdgBtA6r1XW823RVM9iqQ+4PZfU4RF5yNVGIzGo++IJz
	HMLLR4odcMaEAp126CPnk0kJXug+Apz9T1VpbD/iYyYitRDC+NoJgXgeJMTT+6OW
	47thcQNkT0SIPHA4jQAeZSBheymoaWDiQ1y8jJb3iA1HRWuqR0RfYdkXw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=jPUMl05hp4GyYNPKyUU/j1/LhtwQWzBCTR2KiGtIjhE=; b=3v/Qhodh
	InEnJMOf3bLckfH9lSJhVQmHnWX/0B2Q4Y2ByWqwrlIcXJI1yMDZA4FMUEpAz6Kx
	sfD4ukW/MRGzTnI79jbXaeyWKo2EQZGiANrOZuQYzvQD6rYitA4xMo6t5vS6ahzJ
	3I9793OkBllaXj2mne6aJa3FsPJOcenUyqAnotNAri7k6anYgC4rvS/19Pj/XCA1
	aVNGKgwn/IzSH5TefCaI3OM0otU2R8Y7nSWLtwDINEAvFntb5FWDjla1Jgy4A2IZ
	JkxolW+rRHnJxQMfM4ms+Avce8xytqW+AcfcBqskAyhcUP9ue4lvzQRCp2zTONBk
	AP4rId/C4vq3rA==
X-ME-Sender: <xms:izhnXI2VS_dBz3PTw5P-TXklNjLd6zOWXhdreeZRjPzC1vLC1OQrTg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledruddtjedgudehkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecu
    fedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkf
    fojghfrhgggfestdekredtredttdenucfhrhhomhepkghiucgjrghnuceoiihirdihrghn
    sehsvghnthdrtghomheqnecukfhppedvudeirddvvdekrdduuddvrddvvdenucfrrghrrg
    hmpehmrghilhhfrhhomhepiihirdihrghnsehsvghnthdrtghomhenucevlhhushhtvghr
    ufhiiigvpeel
X-ME-Proxy: <xmx:izhnXOmkVow0n8y0cz-_ZyaQGo2NgB2uPKL0XTzY0LqmvA0n64DazA>
    <xmx:izhnXH7Qrf3gF0SLW019gYpvTUzhv4lfKKKE8aHfhkFNuNfBFtb03w>
    <xmx:izhnXKz_Tx3reWpKobQgpVDDOwIVxBdhjb2hSgR7ly3WfRRYDmd2sA>
    <xmx:izhnXG99W0ghHBSXKoI7-i4_UBblNpSFENIUXYo-iou4aRgks6ne9g>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id E04D5E4680;
	Fri, 15 Feb 2019 17:09:13 -0500 (EST)
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
Subject: [RFC PATCH 10/31] mm: proc: add 1GB THP kpageflag.
Date: Fri, 15 Feb 2019 14:08:35 -0800
Message-Id: <20190215220856.29749-11-zi.yan@sent.com>
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

Bit 27 is used to identify 1GB THP.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 fs/proc/page.c                         | 2 ++
 include/uapi/linux/kernel-page-flags.h | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 40b05e0d4274..5d1471a6082a 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -138,6 +138,8 @@ u64 stable_page_flags(struct page *page)
 			u |= 1 << KPF_ZERO_PAGE;
 			u |= 1 << KPF_THP;
 		}
+		if (compound_order(head) == HPAGE_PUD_ORDER)
+			u |= 1 << KPF_PUD_THP;
 	} else if (is_zero_pfn(page_to_pfn(page)))
 		u |= 1 << KPF_ZERO_PAGE;
 
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index 21b9113c69da..743bd730917d 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -36,5 +36,7 @@
 #define KPF_ZERO_PAGE		24
 #define KPF_IDLE		25
 #define KPF_PGTABLE		26
+#define KPF_PUD_THP		27
+
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
-- 
2.20.1

