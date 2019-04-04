Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2967C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:40:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F79205F4
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:40:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F79205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36A566B0007; Thu,  4 Apr 2019 05:40:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F2E96B0008; Thu,  4 Apr 2019 05:40:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BB196B000A; Thu,  4 Apr 2019 05:40:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E36CB6B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:40:16 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w3so848558otg.11
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=F2vJTDUQQPekEsio9ABNwpo/nIflzHrX3NvpI0eAfgE=;
        b=uoc/eLgBQsSPt8g8T3jsBXXb4zxOdEEL3tqvQ4+v1Fn1PwxYqjwKZ38qLiPBibXJv9
         08DcREL6sBvmCTvZOIeVwpbgr5b1jQYLL5A7EzhvVzd1efJ8ZdfsYX9L+Ezo8LsngPNm
         krsCUpSLPjmTnTaihtNEFYzCqVTS8W5gw8KT2aEpHZmL26qUVWXDz1i52BTMPYNJMvmt
         +JFsckZf4zgHbY44VfvA4wloa1pvrfJ8jFzlsm3DFIogBb3iKr/PXQJEjubyKUgnUjQ0
         qyoed4eCS+lrGO3xy3wt1ZARnkBjJwk8dcXT9z8UyvKBJbHX/zh1ipszWiaVC4Jgpxmf
         erDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
X-Gm-Message-State: APjAAAVKC1s+wfjN01x6KaKOnYCh4hE04vpu3v9Kjg2jTSnnkHF7oPKD
	e4RbAMF1Jf4nGcuxtahq9e7umHyyEVcTavS4MjNCvVgFrsmHyfZeycqInPjNIbdm9eCSH4XoIWe
	zrZyiEL0ngMC+mV00CsiLbeHa5uOAycpxe9I2Yb/WMXMJ721VLvvntjGHqqxbxn4M2g==
X-Received: by 2002:aca:bd02:: with SMTP id n2mr2710081oif.70.1554370816618;
        Thu, 04 Apr 2019 02:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBK7Z04YOkXJfca5Y/tSjwY7RMWEvXc81O4C+ndAMmQLmr+NmWqV9wOOJaEMzgeE2CUajp
X-Received: by 2002:aca:bd02:: with SMTP id n2mr2710040oif.70.1554370815345;
        Thu, 04 Apr 2019 02:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554370815; cv=none;
        d=google.com; s=arc-20160816;
        b=E3njQ8TE+Zm7+TCi+5cR8jIi1eUt1IU72royXsMzSJ4YhqSI7IWfKLFeMsMWhEDb4l
         4DmK4t6uJ2no+l+orW1edXT+7gOylhZ16mqC9UDrEXTeqsR6yGzXmvttWY4DyxXWwgdm
         b9FNxZUTODSOxnlCt/IXQBzOoU3DmGf5BhuA1tCJBpx/2C17Mbw7gpDR8hs5WKOF6lsL
         vCxmpX+afXMQaMnE/wppoJD5h6ESJya5WOz1JWy+sV0krBpgsrAmTSY6xF5u2uoHAn6r
         dhOGTGk4jPp6BNAC/YBTKw3OeXgeUsZBXketf1ab7NiRLFe4mUg9GAW4dpWrsgGpnPO7
         m/Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=F2vJTDUQQPekEsio9ABNwpo/nIflzHrX3NvpI0eAfgE=;
        b=Aivqyjj1qayRiiO299dlcH9yFWpbu3uLI7CrFoF2NrDsy4+yZ42OFG9L8rkVSZ27O3
         V7CHY0+nBUyL6BoRcWz7FzrOyKz3jaoL8LS93IPlyNQUy/Wh7nzPKV0ahBdaI4lDDJBM
         tyI0emm9kpRmolezbi/c8MXyqEfknOSHH0Lnsk5cb8G7DIZCzR9leUVA8VdASmapLgdE
         mTNqD0HS+5A43ZCVs8C4Ax4oSjNoTq5I0nafmXQW7u5QNbarIR1c4Soc7pCllS/6ocXy
         z1NoSMbjpeT3LJ7ZHs4D1xh/spbhGkVpYuSZ3q5treVJ1hBHTVD7QaZpFyJ/NiYIDxiu
         9XHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id b25si8235327oti.141.2019.04.04.02.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id DEC05A35646911DE5371;
	Thu,  4 Apr 2019 17:40:09 +0800 (CST)
Received: from huawei.com (10.66.68.70) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.408.0; Thu, 4 Apr 2019
 17:40:09 +0800
From: Linxu Fang <fanglinxu@huawei.com>
To: <akpm@linux-foundation.org>, <mhocko@suse.com>, <vbabka@suse.cz>,
	<pavel.tatashin@microsoft.com>, <osalvador@suse.de>
CC: <linux-mm@kvack.org>
Subject: [PATCH V2] mm: fix node spanned pages when we have a node with only zone_movable
Date: Thu, 4 Apr 2019 17:38:24 +0800
Message-ID: <1554370704-18268-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: git-send-email 2.8.1.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.66.68.70]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

commit <342332e6a925> ("mm/page_alloc.c: introduce kernelcore=mirror
option") and series patches rewrote the calculation of node spanned
pages.
commit <e506b99696a2> (mem-hotplug: fix node spanned pages when we have a
movable node), but the current code still has problems,
when we have a node with only zone_movable and the node id is not zero,
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

Signed-off-by: Linxu Fang <fanglinxu@huawei.com>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3eb01de..5cd0cb2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6233,13 +6233,15 @@ static unsigned long __init zone_spanned_pages_in_node(int nid,
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
1.8.5.6


