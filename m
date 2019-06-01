Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB421C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E965272DB
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="dNc+7XlD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E965272DB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4ABF56B0282; Sat,  1 Jun 2019 09:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3700E6B0283; Sat,  1 Jun 2019 09:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 211566B0284; Sat,  1 Jun 2019 09:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7BDA6B0282
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r12so9416654pfl.2
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qmPESUkianzQaH5WPSY4wJAvN4Bev3gnQsohlQJt+Q4=;
        b=VwKuMMhFfxMuZ82WFLTe6sgfz6xOn7y0hoZjPd3jVOXFbY8GXJLwK+wBuOPgSjhFar
         Z9Su6hFDEm4LMve/uhGTKVEAnZgEUMTcT5Z4i98aIkXNV5znZvuEe6J5ilchjUjw5Fci
         3/DWaIbrU3frMJjPSUcetuTUYh07ADJjEywggfT48gDAEtMRyuHypUSC/mqC20O+LcoQ
         ETY12JlN3vSyKoSBiXD8/D6xVfObToENx2pP9yTPTNcgfGvr0wePwzd52tiw/Fe8bBR1
         fqkT63G/hmzpL17YXfpgK4dEDnexuIkkjr/UOL8Hi4T12QnxjL7AjdbV98HS8hDLvvhI
         y63A==
X-Gm-Message-State: APjAAAW/u1egSyOwsJ/9C2LWAc4vtxPayZ4gKW55myYhwL4k1/LNxpRP
	XZo1d1zjst4t8iIjy1xd6pslfj2IrPCZJlwWQJ6fVi8KZ8m0lruQiMHZQgAPE74SAhQsfHMzwhS
	kMtrpROqFIauXOakC2P/hZkFu3rSYTXP80jHqabN1WZtjl/9yOq5t+WwXSkV2420EYw==
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr16703002plh.147.1559395224560;
        Sat, 01 Jun 2019 06:20:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/+uUTo5IgzP+4FGjGYGuZs1B1u4ms0S9iqvRmK6G/P8w75tfYmrz2azOGTwPXTJ3Y6QMu
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr16702929plh.147.1559395224002;
        Sat, 01 Jun 2019 06:20:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395223; cv=none;
        d=google.com; s=arc-20160816;
        b=mDsD8BzuWQqZPgMWsZDTk9iG6rAgjxOXqfVycG4vkGkfEymg/nv5RHb4B13dbnECF2
         UCsS5ATOD7ZOvKmTN76yooN7bGmQnhxwK/+FccbaTfIGHfkHdlJawI+e4IF0eEQ73Kpo
         9ozBe/2J2fj6vaaT7bl6W4my4R0yaWyuYY6hPF+TleL8dbVaiem87Xr8c+n53TSkxqSd
         5LaNmpU8/uODPU+jJs9C29GDpzPv2nUzrFtjRaE6g9LBcCbAyUHO5JRrH03HrFEsO5Yl
         TZveMyB4r00Kzg0/ucNxHeDUimRC/S8IMEycx3mx6ZF4KCw2IPunTHiaumHToO6HAysv
         X97Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qmPESUkianzQaH5WPSY4wJAvN4Bev3gnQsohlQJt+Q4=;
        b=YjWla777epsaUeqif6zLHQvA+Eup71IIpGj7aps3CrPGAZuQCUIbd6Wn1dek5jc0PV
         YhGZ7idjKg/Kfb1N2KcQQG//MI+amaTOhI2elQZAt2PvdcAzkIP5KYG0Hpqeaa3v6l/t
         dwFTWUw9QF643klVEWh6jjLfTTm3TLev7swExr9GOQbZIMm99yl0szrbOnGyF09HPzuW
         2i0PQKc5tbJuXVU1zX145rIsgMC1O/C5eTL1sKn9IT2foXVBmnT7ZNKIQkICc6DCQvyD
         osokYIyAt2ry4aZnEzL3XhBAztju5a5J6DmpyVS+RIXn554FShIJlPV8M2lEV4PupZeM
         mBxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dNc+7XlD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x8si10002790pjq.80.2019.06.01.06.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=dNc+7XlD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6CC5C272E2;
	Sat,  1 Jun 2019 13:20:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395223;
	bh=8MS0V5tPfk/9WGLTQwnoxCLz2GwEAguIF5tSrT/drqE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=dNc+7XlDcA2JYbC6KZ/I/xj1hJrjcpa3D2wRfbTGVtLa21hrYFTtv5ghMM5dZ0xx6
	 nEylOu6zdU0JijeU7japd+L0yHy/WSuBZplmhjiQjncMEVB7Odiqs1mwIbJoSzfh98
	 YVTPU8eICJuW0CC79Sl3NDxygbSdXuodQm3RF9Ck=
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
Subject: [PATCH AUTOSEL 5.0 014/173] mm/cma.c: fix crash on CMA allocation if bitmap allocation fails
Date: Sat,  1 Jun 2019 09:16:46 -0400
Message-Id: <20190601131934.25053-14-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
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
index f4f3a8a57d862..f160ce31ef469 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
 
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

