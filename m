Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49DE9C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03F9823FF3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0I7yIx6m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03F9823FF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A25916B0294; Sat,  1 Jun 2019 09:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FDC76B0296; Sat,  1 Jun 2019 09:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 850546B0297; Sat,  1 Jun 2019 09:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD5D6B0294
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so6215764pfy.9
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OWc1kTwB0fMWMaD+HRgpTNUnH04/U13qtFB17wIfYBU=;
        b=dIVogYcUKjKy6fALVUh3EOhI6Ne5F8AXC3IXxiH6vApQqp7VsDZCtvF76xoj91pqG4
         QvEMdoJWJF/VVrf7nlbwSMePfR5JWpqdsG+teaks4sjeLvU8o4CVjUh4nWMirc/YOJq9
         wZr/VwHnpNRaoVdUKcNLhAM3FUMqpRWPbxVIXVsGI9c5cwg3NMkDmLh8SDDMX7yuvrm8
         TqofWTnu1k6Kydo5wPVA9pJE4G8/YcHNWlLexmCZflMTQuyIbcDWZM/Hc+AVjxCgKVWm
         u7QsDi7C3iR4Jw3LZXGHHVs996hLFDvhZjYb6Unv8t9M7XzTqrY9rf7YZJOtmKdAViMM
         tZ2A==
X-Gm-Message-State: APjAAAV0LTkffVpLzkDNDU/Te/U2ok0wCIjdMtfHgTX7Cbmyspp59wf9
	1AT6V02pqwb9+pmUkLcVVLGx8E3SEVLy7hFX3F/j8qWOHxZTv/EKaCuvw8J0HMQTfGTYPyBlGzm
	Fz2mI4b8YtqtA+BZxHAvO9a9Y9kcQKDtZzr8Cfxr5nByvGWXfk05F7+SrzxsIgdge9w==
X-Received: by 2002:a62:e90a:: with SMTP id j10mr16924883pfh.147.1559395343936;
        Sat, 01 Jun 2019 06:22:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIpL2NDaMsOnRZTZ0vRKvfGMw8wsH/QdKWxYo+qNuFoRAZvZdJ9mD/teEOjIEtsujxdjIe
X-Received: by 2002:a62:e90a:: with SMTP id j10mr16924811pfh.147.1559395343239;
        Sat, 01 Jun 2019 06:22:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395343; cv=none;
        d=google.com; s=arc-20160816;
        b=fJmAIpD0Ol2dfnbFBD4FphRnn64zGUc0/JOcfVaoj3O1ifwgtXmPwFpCVPJ+p3QRJh
         Hd76K2Iz0nOeUs/sLRJs+RbWv8mRg5gpmI+405b63tU/yg217THnXDdtLfS3IM/IxdR5
         DANHlqyA8K58WLirmhKRH4tJ/E26zwB+4YAVTGMkF7ZrTwQhHPaWa/44LR/1EieXQZO5
         Yqg0KVyQF+Zht6osWCuMsXSm/OpwBhFuRqrUUujN9jspyB4ARUuENMyH1raQaulFR3+R
         WC8qll6uV6WUbhTbPTM0emQGmKFzcP7V6VEO3XA0WOZtOKYG6whtWNiwMRayMmY2U4Aq
         ybbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=OWc1kTwB0fMWMaD+HRgpTNUnH04/U13qtFB17wIfYBU=;
        b=kkxKVWFG/+0F4hmty5WGUMGx2sTjC3GnS0z3xE8UgXzd0Gum4T7XlbKqFg7yTx9H9a
         aoZXNPsYfmAIbIsmU/d5Qg0s7zo4LLI1EkuYi2AK0CH0LAzhp3kof2yUSrUIzBUy6Jhv
         mWxSBb+d/9QQHSOnR7t5dgzt2pnvZsw41Ni5Rrlkig483K6pdJgNPmAI5vF7GG8Ng46Z
         Fwa4KdXmf/vCQBizjGuYhfnf4x/oK0i7lmCsYISEVF8m2ZaTV0kcOXAQdjHNlsYu7412
         6dN/QcKiFgO/YtRXspfT4I88vlVkgg8Mn6FjbwZbJKoSPpd1ZMJ7cBjIzNyY6sB+ffjt
         ewoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0I7yIx6m;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s20si10415757pgj.63.2019.06.01.06.22.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0I7yIx6m;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9D7EB27332;
	Sat,  1 Jun 2019 13:22:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395342;
	bh=3/W9B79kcjbgSKblNyV8ZM25Nliu0LB0SKO6QQp74H8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=0I7yIx6mvBzgvnm3Msz5ubxvDVmUr7vIS3yIT49oZFM9o+fmGA/TcafC6XWxBQxVy
	 7CSgukNjBbhItGjy7KMs8WKSxWqBWQiFkQntGXKOih/KpAP6R0djVc8EJzFSEvQnjw
	 qyFUFlX4wsPwOUg8M5UIhc24aXJkARy1l/Q5F0pw=
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
Subject: [PATCH AUTOSEL 4.19 009/141] mem-hotplug: fix node spanned pages when we have a node with only ZONE_MOVABLE
Date: Sat,  1 Jun 2019 09:19:45 -0400
Message-Id: <20190601132158.25821-9-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
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
index 8e6932a140b82..2d04bd2e1ced7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5937,13 +5937,15 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
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

