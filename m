Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7746B0005
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:11:45 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id z22-v6so8543771pfi.0
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 19:11:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10-v6sor21459604plp.27.2018.11.12.19.11.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 19:11:43 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: skip to set lowmem_reserve[] for empty zones
Date: Tue, 13 Nov 2018 11:11:15 +0800
Message-Id: <20181113031115.18050-1-richard.weiyang@gmail.com>
In-Reply-To: <20181112071404.13620-1-richard.weiyang@gmail.com>
References: <20181112071404.13620-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

lowmem_reserve[] is used to make sure to keep some memory when
allocating memory for a higher zone. In case one zone is empty, no
managed_pages, this zone will never picked up by page allocator. Which
means its lowmem_reserve[] is never used.

Also, since its managed_pages is 0, it will not contribute to lower
zone's lowmem_reserve[] in case there is non empty lower zone.

This patch skip the zones to save some cycles.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..495feff1e5e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7291,6 +7291,9 @@ static void setup_per_zone_lowmem_reserve(void)
 				idx--;
 				lower_zone = pgdat->node_zones + idx;
 
+				if (!lower_zone->managed_pages)
+					continue;
+
 				if (sysctl_lowmem_reserve_ratio[idx] < 1) {
 					sysctl_lowmem_reserve_ratio[idx] = 0;
 					lower_zone->lowmem_reserve[j] = 0;
-- 
2.15.1
