Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D36A1C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:40:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AA8320675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:40:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eMYCK3wt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AA8320675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40DA66B0269; Tue,  7 May 2019 01:40:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BDEF6B026A; Tue,  7 May 2019 01:40:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4706B026B; Tue,  7 May 2019 01:40:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAC616B0269
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:40:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t1so9513776pfa.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:40:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pMrSWKQu3YJDZWB1FILG46dQwF92H/0EQLiS6uJmPcs=;
        b=KGbxWzlHKgUzvQsUi/vURwcJDqsIwNDB6C+AiRppfKfGWW5OaVasOj98Sk93GdKCx6
         z55nvpA6AgIF+UOygZ8vdi7oIPOTTy685y6p0kqr6s3Mp7W0/T0mkVZ2t9Y9P3cOTGAt
         KX1GXHNJ7ExjPw39TGxzP9eCtXcZ2BtNqh36YRyL2rBXsWTGMwd/YahC/A8bJmCZpPk0
         mhxjgbFByCQtD2G5yEVzJ8h+WTWzNdpUAO17D2x0jh5P4fYVeAuOwsX2fqc3uiKcWk63
         1SzTiGjeAzkTYM+jvfsZgsRYmG4aY8pYLs8WfCnWKG6B15frGLdn5GmLj1gYe+zadJzp
         3e/A==
X-Gm-Message-State: APjAAAV1tppytOm8RLNjmFg9sQTy6Dssry9Cey3nq7jQCM7V5xw88JRx
	NtkGdiW1jSxsUDdL0dXHeOmua33XTb2fu54EpWYZYPZnAmu4xFME32x4rN688xV6DYXR80WpZWr
	eNd8oCat5Uhbs1yBbeLRDgOO/QBUAOzDVF8t7tlum9Pu5jfS+pkRYcsQFalel0f9ptw==
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr38882512pfa.223.1557207638579;
        Mon, 06 May 2019 22:40:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEo9EjmepzKtMVgcVrseYr51v7bRg/3rCnE7J0nPYVsaf4nucCM0zWqWcuaxdk5IrXDkSs
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr38882447pfa.223.1557207637860;
        Mon, 06 May 2019 22:40:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207637; cv=none;
        d=google.com; s=arc-20160816;
        b=g9OGYUmrcN2fhL9505qGP7DVnC4zvd4QEfThKbnW+P1/d1IdjE9qGLjHAiUtYIPKTo
         bUxBL337eu7771LVlN0oh/09cbMIm7ZYPQy3qfzFRMgdYDfIcufojZrKXWB+lY4rsKnU
         +Owj9E7/LD4HNtsVRew1G+m7LnzyKR8dNIM80jpbAjClxc2OLONWZHgcj548YIOkHVkR
         gkOm4A53cNwnqiVAZ1pAWvZyQ0ok9zxWnNFxTx3xYKpxl5/BZoLLdq3zrwg3scb3gNm8
         EM5EDSXRGUyWcHURVuhgIQZzD3tOQVn7mzl9AwgPyi2G6mMmylqOZuXrGwjOn9a+PW9M
         UOiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pMrSWKQu3YJDZWB1FILG46dQwF92H/0EQLiS6uJmPcs=;
        b=ZLCuKOYVE8gh3D68TlXY1fSQ4R5oI/0CCVzPtif432QCx7Gns7/k1YURA2Z7IWNs0l
         GQYCkguJ2/QkvrQ6UkgX1F8Ura4KHYVF0y8QFst5d4v0qhgk7x0ea/SZoDQZ4xMWTBg+
         DbVlQKPrKtdjdxv6S0CD9yc7R2NhfOE/IltYMClp1hJkcwvC17Pznvi/SPCwvsjBTN8S
         s2GRpTpJektlnSGVEMO9AhiEyjoMRdO9xefie1SxkBLZ/lVPwnEcoZx/Wthv/6uQwRZJ
         LejHVHE+anRKUpg2uwv786pd4nfLSJa/63tK9KYuSl1exsvBKNN3rBASXJ3Kr/AqoVOY
         /vMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eMYCK3wt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h69si17740981pfc.100.2019.05.06.22.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:40:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eMYCK3wt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A5A4A20578;
	Tue,  7 May 2019 05:40:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207637;
	bh=pNoHONEm1X9opg3xl9NbGvRfo6Og1Tx2dproK5eTanU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=eMYCK3wtrE7IvV0gQzSlZL/zBwGU4POxkmXUxvS/CdJf6YshP3/f0idjABTj0iA64
	 Iz/DycLKqufCQCaVgTKDvSnX9BWVy/jhwjEioqkb1+LBobrBFintNYnINk+M7XzyNb
	 aWViDuA0uxQNKoRQh+DsCTFWlt4vRo7VCCxisSgs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>,
	Robert Shteynfeld <robert.shteynfeld@gmail.com>,
	stable@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 71/95] Revert "mm, memory_hotplug: initialize struct pages for the full memory section"
Date: Tue,  7 May 2019 01:38:00 -0400
Message-Id: <20190507053826.31622-71-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053826.31622-1-sashal@kernel.org>
References: <20190507053826.31622-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

[ Upstream commit 4aa9fc2a435abe95a1e8d7f8c7b3d6356514b37a ]

This reverts commit 2830bf6f05fb3e05bc4743274b806c821807a684.

The underlying assumption that one sparse section belongs into a single
numa node doesn't hold really. Robert Shteynfeld has reported a boot
failure. The boot log was not captured but his memory layout is as
follows:

  Early memory node ranges
    node   1: [mem 0x0000000000001000-0x0000000000090fff]
    node   1: [mem 0x0000000000100000-0x00000000dbdf8fff]
    node   1: [mem 0x0000000100000000-0x0000001423ffffff]
    node   0: [mem 0x0000001424000000-0x0000002023ffffff]

This means that node0 starts in the middle of a memory section which is
also in node1.  memmap_init_zone tries to initialize padding of a
section even when it is outside of the given pfn range because there are
code paths (e.g.  memory hotplug) which assume that the full worth of
memory section is always initialized.

In this particular case, though, such a range is already intialized and
most likely already managed by the page allocator.  Scribbling over
those pages corrupts the internal state and likely blows up when any of
those pages gets used.

Reported-by: Robert Shteynfeld <robert.shteynfeld@gmail.com>
Fixes: 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full memory section")
Cc: stable@kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 mm/page_alloc.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 16c20d9e771f..923deb33bf34 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5348,18 +5348,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			__init_single_pfn(pfn, zone, nid);
 		}
 	}
-#ifdef CONFIG_SPARSEMEM
-	/*
-	 * If the zone does not span the rest of the section then
-	 * we should at least initialize those pages. Otherwise we
-	 * could blow up on a poisoned page in some paths which depend
-	 * on full sections being initialized (e.g. memory hotplug).
-	 */
-	while (end_pfn % PAGES_PER_SECTION) {
-		__init_single_page(pfn_to_page(end_pfn), end_pfn, zone, nid);
-		end_pfn++;
-	}
-#endif
 }
 
 static void __meminit zone_init_free_lists(struct zone *zone)
-- 
2.20.1

