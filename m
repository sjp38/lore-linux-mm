Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C20DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:15:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 540BA21B1C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:15:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 540BA21B1C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4A118E00F8; Mon, 11 Feb 2019 11:15:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD3098E00F6; Mon, 11 Feb 2019 11:15:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC2D38E00F8; Mon, 11 Feb 2019 11:15:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1568E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:15:42 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u19so9797744eds.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:15:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fC1fZt+IZT11l29dIaesmc+ItFE/dY5U8P2pwMDCNrs=;
        b=Nf/WaDgMWKNJDhZSiHMqdKZ2WMDbYJKmV/BK5OdMULs/oZaJeEAdvopyZiiPAt3Le0
         o0Xt+aBCHQgQBZErRc2YaROqC/YawrZ4YnqpcsmrmyGXL44rcuKaWI5FtKhi1GdGforu
         wP8AZF7InPOI/imFfzp4oT7p50/nx+0kL07m44eeHu53zDTaWLjiLQI0N/GNOOEHNwyw
         XxDlmU/viaIIj2cdFyNVFqY9R5221Ayu9HesrQYWLXs6LoaG/dxSZ7VS2gKl+InMoBqm
         RaOLDRsODmM23kQuedsu1JVgMj8IxED65j0VlzZReCkKkENVS9IuwiXqieNkKgFibAXR
         IhWw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAubk27qEM/p7uJwtF5fZswVDUh35NMXjzNfoGzu/4rTT3+NSl9Hc
	vhSYBHJEsQWbqIqRnitvBkgQwRm2Xx48xW1xQD+wUbR6T5ShUR6T7iA8H6WggJJ5MvK2zmyh9qO
	ULfM1VaPTRMzOPCgv4as2gmjqYuZhOsbp0+6XpND8R+I6RLahmv9NO1dIIFwrDao=
X-Received: by 2002:a50:d4d2:: with SMTP id e18mr29442350edj.127.1549901741936;
        Mon, 11 Feb 2019 08:15:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4vx+goMLrV+cEHKRK2jkoOezncHVv8oaKl3qs6Ah1O1JZlvuwQQwVvKiLkN/YQ082+wa7
X-Received: by 2002:a50:d4d2:: with SMTP id e18mr29442298edj.127.1549901741048;
        Mon, 11 Feb 2019 08:15:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549901741; cv=none;
        d=google.com; s=arc-20160816;
        b=s9xNR9gsc56bwiFzkRTsb60nBBZNLignPZisiVk1cN+7LcmI+653GvMvVCeZ5ntdIK
         hZifmZf0omjyxGNIuuAptcfBLPD0yl9Nql/H2y2kmNqPs7ohgq0yebuAAsfFwPnV6p2K
         ddG2FQDlmd0nTY2RULKnqJim2kI6PE3Cdzpb62x/E31XNQovu9HvLWOGxfisXh4PL47X
         hWxm5GdYsoGOFt5P7fy3Y4AI/f7HPmkGOXuMSmRznoFQ+T6Lgj9g1XCmnUyGMZcSGHb+
         1YXVFFHdcI7Swu1UwZzNnU/JxZmrv2JDE6x2zfh00nF0YnpA14oAYT8QN21Fmp/PCMkW
         k3ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=fC1fZt+IZT11l29dIaesmc+ItFE/dY5U8P2pwMDCNrs=;
        b=clq/pVvSrKcKlmcx5oPlBcrcY1k+xi5JZ+1paCxpkJ/0ezrx1aCj4HO+0byb+884f+
         vYrDp1z4Cb8z8HerUc1MD4o/Lry1KlgKmmB8ir+YbpLi/LGoYHKsGVBfgs2ftl+wzd5u
         rkd+9n6L5ogetYGzCTIkgsZOUa2dOQfxOeZpvVnwRvtVslxmVAymgov4LtThaRiljCfC
         p3uHYl8nTGWZQIc5jILWkKQoDbaYHingybEGDT/LlIayPUfz34rlQhRXkyf0Ctr/Udsn
         85wqIUvKw4XXPngzM/9glbaYY0MjDZK0WSG6DIqBZQhtgDdmCz08989tcb5y/Sm8muTB
         17Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h35si240000ede.274.2019.02.11.08.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:15:40 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6684CAC8D;
	Mon, 11 Feb 2019 16:15:40 +0000 (UTC)
Date: Mon, 11 Feb 2019 08:15:29 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Bjorn Topel <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>, netdev@vger.kernel.org,
	Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH v2] xsk: share the mmap_sem for page pinning
Message-ID: <20190211161529.uskq5ca7y3j5522i@linux-r8p5>
Mail-Followup-To: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Bjorn Topel <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>, netdev@vger.kernel.org,
	Davidlohr Bueso <dbueso@suse.de>
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-2-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190207053740.26915-2-dave@stgolabs.net>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Holding mmap_sem exclusively for a gup() is an overkill.
Lets share the lock and replace the gup call for gup_longterm(),
as it is better suited for the lifetime of the pinning.

Cc: David S. Miller <davem@davemloft.net>
Cc: Bjorn Topel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
CC: netdev@vger.kernel.org
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 net/xdp/xdp_umem.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 5ab236c5c9a5..e7fa8d0d7090 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -265,10 +265,10 @@ static int xdp_umem_pin_pages(struct xdp_umem *umem)
 	if (!umem->pgs)
 		return -ENOMEM;
 
-	down_write(&current->mm->mmap_sem);
-	npgs = get_user_pages(umem->address, umem->npgs,
+	down_read(&current->mm->mmap_sem);
+	npgs = get_user_pages_longterm(umem->address, umem->npgs,
 			      gup_flags, &umem->pgs[0], NULL);
-	up_write(&current->mm->mmap_sem);
+	up_read(&current->mm->mmap_sem);
 
 	if (npgs != umem->npgs) {
 		if (npgs >= 0) {
-- 
2.16.4

