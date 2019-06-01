Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 785BEC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3445924870
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EW9DuTtZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3445924870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC98E6B0010; Sat,  1 Jun 2019 09:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A50D86B0266; Sat,  1 Jun 2019 09:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87E806B0269; Sat,  1 Jun 2019 09:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46A926B0010
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s25so4610750pfd.21
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oR9rV7mIeR6mdlhFzu/0Y6SfTsiZf/SqP8cDevm0QW4=;
        b=TkOCdxIaQPBWU9UY+j8du2hdUP/H1e13e7SKegZ9YusMlwxJlCT2shWDJxYlF4gG31
         208zOf2tuDpia9X4OSq2GoMicfKJNywewTJsHSYpLJWOwZa+cBpHUXr1dPx7mCkqR1w1
         sR2zg+W6U48vLWKaXpV5reTk3UUL6vRj5eBgV/Nk7BS5Hkh2fRj2BoVVHf6rc223RDNZ
         xthZewQQt1zeU/y7htmH/ynsnjpahY7gAaH2oiGjpM9GXj1a2XrVM47PC5BGiHNA3sjx
         XNeH40h4/Zprcvhq9EEAr4vQGHyWUdPOOHtOyDxKUH82TyDw1tgi5hv4iPasW9ki/URW
         qMlw==
X-Gm-Message-State: APjAAAVuA0jzl7f8dEsmhh4Cu7/QICPHUmGfussXkKGIgNvew59sHN56
	51IrA94AjmJZa16hEXlFTip+bT7YZXIpiUM8/itpnV9Yby+t0KTKBqINEakZyX+af8sLqeKkl8k
	fdR6FdPFwIxb8uwgf3f1TRbjlEblOTErOjnf+8qNAt0FAQ1tBV47sIBi3KHFgQgYT0g==
X-Received: by 2002:aa7:8a95:: with SMTP id a21mr17265970pfc.215.1559395058922;
        Sat, 01 Jun 2019 06:17:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxtRgKEkLVnyZT6qDTU9PhKI3XsR7oSl1u/ZUi0JCK5OdQWfj0We/gUiliWdyKoTHiGua3
X-Received: by 2002:aa7:8a95:: with SMTP id a21mr17265889pfc.215.1559395058222;
        Sat, 01 Jun 2019 06:17:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395058; cv=none;
        d=google.com; s=arc-20160816;
        b=ln7aLBu/tWUzdEnpP6StFAOTSDrBbTWUtrW1oG0Ot2+3UxtEsT6KJYX8bLZCfRkler
         joMxB73O7pq5dP/h2INDIFnuhm7ef/LFdKUR6zZ4EpkvZ65iq/R70Pbrnbot2nZASASz
         640tad+/aSFbCIzxkRXD5pORYWGeKuhiY4D8kqbVzL/XHGhYcCCyjx+mDA9aGx6Zgfd9
         Qs2Q01UeyS6ZT8wgHZmpOEOiojIMLnS2J5v6NIx34xAfQPlT1aUZHXlI5klX6Z8++rmC
         CiGiQ7IkR8gaXFNAKcu1D0RuKdsAHfiuAUIUgi16iiCUe3CH0nQ8fqxr0DwUcVENNWdG
         MmtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oR9rV7mIeR6mdlhFzu/0Y6SfTsiZf/SqP8cDevm0QW4=;
        b=dfe3wrQHPzdkFZFsTwh6eawU3JSaQx0wHo3stvKuFJjB/sEWjetKC7OjkDFT9sPWnr
         /v0F5RBP5NxoGQ1W3LY/ULMgHmM+Lr7kJAHWoAWAfM0RzSfTu8NcRDi0fHoMuKfNXFMB
         ezHq7CRqLiK2HtjDw8ZVPVNX/Q8DE8hIvZwsDpPMpRI3r/vg3OQHDPWf0pCqJgV1Svx8
         gCCpYPRJ0V1tuozl9XVuhnpjsQGSgp+yG4ajkjGoMkncJ7EZ0p/LHJlA3i0s5vNrftkz
         FD2h/2EG1/hDKkjj670SN2phT4/lLoNzcwVhk9+wKie9AfiVC2kWEdr4KPqqFCHl5Ya9
         C/JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EW9DuTtZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h5si9703279pjs.96.2019.06.01.06.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EW9DuTtZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9520D23ACA;
	Sat,  1 Jun 2019 13:17:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395057;
	bh=uSBsOaOMUpFUg+IRNQO+uYVn3J96JfULcdCwGMsLu6o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=EW9DuTtZG7FG+a7ZwzJdx95Abndub9KkldTtnzi3+7QRJQ0vJk2Pla4ToGrbnKHHK
	 tra1rZ4T5WDzjdsN8U66F/DFPmTZ4FVb5db59mcM6JXaPHaoZJsnnyTXoApsUInrAS
	 B1mqBVCfy9p0JXsJqVhpByAfUJGIld+AMSO2n2y8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linxu Fang <fanglinxu@huawei.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Xishi Qiu <qiuxishi@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 014/186] mem-hotplug: fix node spanned pages when we have a node with only ZONE_MOVABLE
Date: Sat,  1 Jun 2019 09:13:50 -0400
Message-Id: <20190601131653.24205-14-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linxu Fang <fanglinxu@huawei.com>

[ Upstream commit 299c83dce9ea3a79bb4b5511d2cb996b6b8e5111 ]

342332e6a925 ("mm/page_alloc.c: introduce kernelcore=mirror option") and
later patches rewrote the calculation of node spanned pages.

e506b99696a2 ("mem-hotplug: fix node spanned pages when we have a movable
node"), but the current code still has problems,

When we have a node with only zone_movable and the node id is not zero,
the size of node spanned pages is double added.

That's because we have an empty normal zone, and zone_start_pfn or
zone_end_pfn is not between arch_zone_lowest_possible_pfn and
arch_zone_highest_possible_pfn, so we need to use clamp to constrain the
range just like the commit <96e907d13602> (bootmem: Reimplement
__absent_pages_in_range() using for_each_mem_pfn_range()).

e.g.
Zone ranges:
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x000000023fffffff]
Movable zone start for each node
  Node 0: 0x0000000100000000
  Node 1: 0x0000000140000000
Early memory node ranges
  node   0: [mem 0x0000000000001000-0x000000000009efff]
  node   0: [mem 0x0000000000100000-0x00000000bffdffff]
  node   0: [mem 0x0000000100000000-0x000000013fffffff]
  node   1: [mem 0x0000000140000000-0x000000023fffffff]

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0x100000    present:0x100000	absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 2097152
node_spanned_pages:2097152
Memory: 6967796K/12582392K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 5614596K reserved, 0K
cma-reserved)

It shows that the current memory of node 1 is double added.
After this patch, the problem is fixed.

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0	    present:0		absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 1048576
node_spanned_pages:1048576
memory: 6967796K/8388088K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 1420292K reserved, 0K
cma-reserved)

Link: http://lkml.kernel.org/r/1554178276-10372-1-git-send-email-fanglinxu@huawei.com
Signed-off-by: Linxu Fang <fanglinxu@huawei.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c02cff1ed56eb..475ca5b1a8244 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6244,13 +6244,15 @@ static unsigned long __init zone_spanned_pages_in_node(int nid,
 					unsigned long *zone_end_pfn,
 					unsigned long *ignored)
 {
+	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
+	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
 	/* Get the start and end of the zone */
-	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
-	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	*zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
+	*zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 				node_start_pfn, node_end_pfn,
 				zone_start_pfn, zone_end_pfn);
-- 
2.20.1

