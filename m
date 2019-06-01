Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48485C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3FEE27357
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1Ri8R3uh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3FEE27357
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 987CD6B02A6; Sat,  1 Jun 2019 09:24:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 939736B02A8; Sat,  1 Jun 2019 09:24:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8007D6B02A9; Sat,  1 Jun 2019 09:24:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 413296B02A6
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id cc5so8231773plb.12
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/DBDef6LXs6BZlPfdnMI3LEACxRyIXoa46x8kKYahjk=;
        b=QWlFgXz0ol2lnQNtX0zN8uAUsDSEst8elvQu+GPmJ1JxJPoha1I7V8WcpBGXcZFmr5
         IARrQZ4ZondRAAM6xj1bRY4Ia8K/GYKrEgGVLXM1jTkcmACoS+QeTlRt/Tobia7E7T27
         JKvH078FEaaLpRPDfKyZeIbfaitnOCvl+BkQ3uO5vmXfxSomRmy6XTEYgwfhphCfwJ9L
         ACtFDsrryE+TZGv7euX79nrZF9ZFVkalVhnOmE/sudF0/jW0WN8PstlvIMuDCZ53fZLS
         kV7kPUrlIVpFPWha+4nFHCmA9gITZJuT5WLebqus57Kkuj3P7XCszz+RDN8HwqrC6Ew8
         3edQ==
X-Gm-Message-State: APjAAAVIqaKk8S885qbPe0hLhKDqdD2gJRcAoS/XPq/du6JVYfHXzYO7
	dRDAFhNM79AC9H3qLtu1MbpnWnTyhffYuISraNnzQtvMVoibgxgVm9WlLLv8Qmd1oscknBPkKbr
	sBBgasIjY3dXbv24BpSirQX0SFI4eub9qxCrEHSwjNErrYqPIxaCw/2ClCOhY6dJQpg==
X-Received: by 2002:a17:902:2c43:: with SMTP id m61mr16058459plb.315.1559395450919;
        Sat, 01 Jun 2019 06:24:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyg+0KPUt/Tqu/evWqDSiBYnT88E51PYfe7Q0oRLD0stHvRz4PFPr1c6+ZSm2tPIhc8mqDI
X-Received: by 2002:a17:902:2c43:: with SMTP id m61mr16058396plb.315.1559395450247;
        Sat, 01 Jun 2019 06:24:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395450; cv=none;
        d=google.com; s=arc-20160816;
        b=LMz4ArKm0iWk3h9slTrVy1uoswSZ+gbGfwOd66ddamLJX+LLf2DiqD7qYQztP6OeMy
         SbXvFvzGtgRb6wkvVfG4Ffnxk9uv7J3sd8RryqAZqrKbHyIn/P2uPKA05W0H1BG/60S/
         wpw/m/Gt2+J4g25FJa0eWafzpiX6nHjWhN8kXLcklresrIG+dwCVc86vAOzn6DRk86/X
         nqVrkSnfxg667QTJdKXsdMNNLQKQ7xVSVzXiZz68GEVgbRMaPxyNTSjjsxJl9Lfruor+
         a1mKPuem9iKJNFEm4omeigM570VexYnUQ0zfvYiXGb1ZoSgwjNefg05uF24wz8STrf/m
         AhWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/DBDef6LXs6BZlPfdnMI3LEACxRyIXoa46x8kKYahjk=;
        b=GitvX/XQGiSUfdlgg5XnoU5mhkAhM+BJfBxFf51jF2rD23kjdZ+Ih0fP3uqY3mhNy9
         6Kjn4JWzXyu+V85Fhz1WrwvfvRQJlGk+8AUeWyrfV2XZmyW89GR30mWP3o+lBmTVOEr+
         QOXy2vYwOKSrV54I933atFm18Tcxx1DIvZOPVl6OkIUlf5Czs8a/Jzp3ApVQO/tmqcoF
         6zqql8aNAWEtJV3Ybmw5sB/DHegVBwLRgepquxdGD1wbheKjLSlNBTfoBLAFg67Te+uu
         0wNHlweXoyyCY1FwAURXHMVqTtML2yNx6E4bU0jNI4TmcjVEYetsq5SXUkoNGU87veoC
         AwqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1Ri8R3uh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n26si10653217pgv.264.2019.06.01.06.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1Ri8R3uh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7B8082736E;
	Sat,  1 Jun 2019 13:24:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395449;
	bh=YiYiPtpnEFepbxQPf0DdT4QTwc/B9sjCipaAyV8Th/8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=1Ri8R3uhz9nuuyQnC55f1ynLULPxAkIo7SeQCvLWKlCD1m5NepvmvoF5qvc/wMq+m
	 +qrkZ6E8ANpJkWfFIr+67i7CUug1FL0E7iiWRpO7p6vfdYPNduEKKGWdPmzTHauSt3
	 Hg38tK9T13PPVraUVzpN5bBkMj3HA2mgL7W3io+s=
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
Subject: [PATCH AUTOSEL 4.14 08/99] mem-hotplug: fix node spanned pages when we have a node with only ZONE_MOVABLE
Date: Sat,  1 Jun 2019 09:22:15 -0400
Message-Id: <20190601132346.26558-8-sashal@kernel.org>
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
index 923deb33bf342..6f71518a45587 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5727,13 +5727,15 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
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

