Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CC58C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 294B0272E7
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uRTQcvKU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 294B0272E7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E3F06B0280; Sat,  1 Jun 2019 09:20:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 545856B0281; Sat,  1 Jun 2019 09:20:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40ED56B0282; Sat,  1 Jun 2019 09:20:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00E956B0280
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so8236826pla.7
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TWOU0K/hrU4ngO3PuvwByHo2BTlSzcDB8Zj6yl53G6I=;
        b=FbD7xDaWX9pUduKT1a39/+hXu6swgr5bSM7+zBfzW6+VmIHV1Dmj0aH8vpjkzUYco/
         hLRkPOY6vMagd92w4Y7Ihn5xmMdVJ67QZS0QhCbl2v3/+ucDlbUSO4bGv06hw6pPBtDs
         LDwfAVBK7XSHT/xDa+3P+m+WLkc0rCBuqDRbKeVYHwj/LVtSFFCpxzAFeJIG4VIcrfqK
         uuNvy+4Y7nIqs7LmZKn6HaQT9tF1Uvq8cXSSCRuYt1iNdU7BxV7mSZNzZY3izZuiWMT5
         30yYwn0/hIowgikw5x4G3vlFibuOO+SZLN+TVhx/DbrEvUNNgFz02V+p94zDy+t9oe2F
         WEqQ==
X-Gm-Message-State: APjAAAUctdYRFztvIsOzjBQJqqS318rHdi/mfE6WfRmdmLEUZtborA6O
	jBSZJccjFX9XmSB2JkGCDgzIEnxKi05a7rDPwa53DWsR4SwQx9tDX3df8CdaQpzgjiYBmgF41Xa
	z6arqmMLrDKLWNx1yusr5+97ecA7Xuy5vYb0bgjQoW1sBRlvUzogpflD4EAfY4w5xCA==
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr16571599plb.6.1559395221662;
        Sat, 01 Jun 2019 06:20:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+K2c3cOboRyi+uvT8SKjoGpjyaBwtUfH1Us4Z4PWpYDEu7J/OtJN0Rh5FNc7yPltxCSPT
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr16571529plb.6.1559395221027;
        Sat, 01 Jun 2019 06:20:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395221; cv=none;
        d=google.com; s=arc-20160816;
        b=heu80UH+6Ezywuh4AXwzpvjp4phqOcLLvqaVi5thij6YhNzRIUIQz6INy1MTTMjRME
         QAGHjjx5bahioaCc1SsQHViVvzMV4qDl2a2iZ609BFg/KP6t5S1vCYNeXBgrmpePnebk
         XtG7o3oieSNSAQudRzs16m4raE31uId6ZzeapNp4/4oWjM0USW4epmLfldWoSKBkE5MU
         jKPR1iUZc7Lx/twySPfTlHtq3PE7zBM/ScDeppikp7t3nKcBSUi9Ww67raHsA/VbbLSF
         f2dp2BToyBu4HmXH12OCUNY60utP9G7esz8RM9IWqpE5y7/DXI3vO3xuSf3I6QajZG5w
         j7WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TWOU0K/hrU4ngO3PuvwByHo2BTlSzcDB8Zj6yl53G6I=;
        b=EGVE5fuCxz5WpwCy4kqxLjBKz+TnhKifuxvNwkdTJR7Z9GfQsL362p5onjzkKGkUw9
         3L/AitH97AAwdZMFU5j79zGs65+z8ZVaD7xpd75oaSFynBZuex5G0OUVATkzpKg/t/ju
         JCSlB50Xqh8/T/Bltl09YbJEoIN+KT459DYwqwEEh8rVNmaLEid2ZtLX3bORFKYbX5Dd
         4w+udOIrnNZWM1uAQIIuhWp2g3w9QPTVhs/rcElIpF5RRsREnYn4VH+GH7GgGsdGeYgp
         Cer2n6Y89foaSNEKe9FTUD+P7zoI9cnK8taR9wwjz6x57bYQtyGkYR6m03MvLbKKN50w
         lG6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uRTQcvKU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y13si2116691pfm.34.2019.06.01.06.20.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uRTQcvKU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 60D26272E4;
	Sat,  1 Jun 2019 13:20:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395220;
	bh=i4Yu/3MTaldNHtJo+VKdVtRs33iUDUWR/V3xo/Zz3Lg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=uRTQcvKUTLEWl/CTApCvSDTRkzDag9dq9Ni/qRUHikROWBJvuW/ze1ZHilQ6U+6T+
	 1Isc5efo9S/j8fLua3gT3eYoWABxaz2GryN0aPgKsSE5MR9cnKcu7I+rXJ0uRpGoTj
	 +3Zxfhb5zm0eAG5xsAPASVTwyn7a7kPGUtRR3NIg=
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
Subject: [PATCH AUTOSEL 5.0 013/173] mem-hotplug: fix node spanned pages when we have a node with only ZONE_MOVABLE
Date: Sat,  1 Jun 2019 09:16:45 -0400
Message-Id: <20190601131934.25053-13-sashal@kernel.org>
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
index d59be95ba45cf..140acb4b69aae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6182,13 +6182,15 @@ static unsigned long __init zone_spanned_pages_in_node(int nid,
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

