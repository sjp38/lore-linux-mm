Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F18F1C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6EBE27358
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ad5valh9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6EBE27358
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DE926B02A8; Sat,  1 Jun 2019 09:24:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58E016B02AA; Sat,  1 Jun 2019 09:24:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BA4D6B02AB; Sat,  1 Jun 2019 09:24:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E534B6B02A8
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so8242532pla.7
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CH3X0g3mdg7qZt/bzl2KQF3RHLgMe+gPOEv7AcQuZXE=;
        b=nErsIuGYdHu4zs3x+d4ZJcdeAlRUhamwQyODcL4WKtbcsXA/CCch3PYGQl5lli+H9o
         csL0r8sg19Hi6U4pgonepuPmX/6ULaS8Ze6A86SSfWgbm0TxlIv4lWS5yZsFXXBTZnLD
         TgPL6RorXB0gK7xb3PHDwpg+aSZt+KYR5ncppRJNy0L01kfBz4nOW5GKFfRafakvPvK1
         GHzWAljIVkBAgrdXw9rcq1R1Sifp8s1XUDe43gTBtTnsxI5Voq3XTqzv00JDfu+5Rlgy
         1YNsU/YF+jZOvQh5dyFDx7jazkQfaxI05G//HTd8tZ0gjbWgZoB7FAtsfhVnFNHJxNRQ
         vFfg==
X-Gm-Message-State: APjAAAWLiXQbTOSsV4xQUiauuEJV9T9WiRah6A6CVdjtlJVJwa+w/3Re
	H7N5z7O3sjf5MsaAKeIUB7SzteNrHAovGMACZwO/uNUzAMgYzN6FPw8qxqMJ7xFrrh7Fl9k2L/1
	EGL0PZmUqtvEGBiYjsKL52DgGlFztbFwgF5pV3Iub9uJ6nMkCZUTMOEi0OHyKcv4sZA==
X-Received: by 2002:a63:6848:: with SMTP id d69mr15808675pgc.0.1559395453573;
        Sat, 01 Jun 2019 06:24:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+ks0OUYZwiLc0mmxZoVi+y1dNtCqGKSeYH/rRi6szGDrE7LFIHvtlxgAHzZB35PKUlQI6
X-Received: by 2002:a63:6848:: with SMTP id d69mr15808619pgc.0.1559395452980;
        Sat, 01 Jun 2019 06:24:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395452; cv=none;
        d=google.com; s=arc-20160816;
        b=mUDzDY/2boGkEqOeWK1FcGHqee0VZMTeR9dNRUrdUwIy6fwgoWKJ3x2fAbHwq0kGlG
         PJw/ZBOvodNJuYDivlE2AJVf/x4tv4LmJSRzN38oeTnr7PGvpGLS+zghaw+NDy89zOq2
         XxDFBtswp9hmrXhdJs37X90G3Ml+H1g9aHSx7zNdLOj13bC4IM5Eio0ye21Wuqt4e4Lg
         wTeItOmDi1SChIntD+6dMO2OWIUrQEJoKzW5x53nX08OqM9U22aBV9v29KPxg6gb9cc9
         M4KAA1vPxjQebuOyc8ZjqztZ0gjyMLcABrXKWUY1ggH0O7fhn+LtcIrVkHbc4TZZrMtM
         pQyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CH3X0g3mdg7qZt/bzl2KQF3RHLgMe+gPOEv7AcQuZXE=;
        b=eKvZI1KXpP9g3YSWINNjAJx+jH0skFNd+6i/hsmnJyicOiw0/pXgUanb/9DRgm8W0r
         nVe7jsUliKoJebNcdpQNRVGy0gEJzVR0blbH4DDL77veuwKLGAuGvh+7sSAHILdPOhCU
         QB4Ivy8PLQ6zu5dUDtEVcQzT3zSPK3PLYlrCMh+3PH7JlX/S5oy7HdlFULIAK22mu+q3
         dRjRtaBkEOZC4lbD+f/DBrm5dz60Py1OOQMdvrVTpGsUbOMP/map9SD+CnXBrg3lrLrL
         MvbFqeT+h4D0KlIVah53fdApQF487HBrXLAr334E0f3YMiYGIDAGL049PvVwTV/E+Fl1
         sgBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ad5valh9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e7si1538171pjw.44.2019.06.01.06.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ad5valh9;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 75CB724C2E;
	Sat,  1 Jun 2019 13:24:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395452;
	bh=JX7cXTsUkmGV1mJ7r9klX/mRdipXfa7dpWAhCWyvSRM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ad5valh9xIcIDCGMD250Uamm5kLvcLzZNIxtMs2a7eitJRHFychJLXz/+bvaHzzkq
	 r8JeWIQ0giJNElFzqYfYytfWBh1sKaGq815C/Kpb5UxnUx86wWhaLF91aczek443ZS
	 WoCMeAd5DjkOH6xvzho9JXVpcynlmrWC6XI3DLeM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Laura Abbott <labbott@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 09/99] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:22:16 -0400
Message-Id: <20190601132346.26558-9-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132346.26558-1-sashal@kernel.org>
References: <20190601132346.26558-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 1df3a339074e31db95c4790ea9236874b13ccd87 ]

f022d8cb7ec7 ("mm: cma: Don't crash on allocation if CMA area can't be
activated") fixes the crash issue when activation fails via setting
cma->count as 0, same logic exists if bitmap allocation fails.

Link: http://lkml.kernel.org/r/20190325081309.6004-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 5749c9b3b5d02..cba4fe1b284c8 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -105,8 +105,10 @@ static int __init cma_activate_area(struct cma *cma)
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
-	if (!cma->bitmap)
+	if (!cma->bitmap) {
+		cma->count = 0;
 		return -ENOMEM;
+	}
 
 	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
-- 
2.20.1

