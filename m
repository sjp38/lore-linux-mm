Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 513606B0008
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 02:14:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so7185789pff.5
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 23:14:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x69sor16864767pgx.20.2018.11.11.23.14.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 23:14:39 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: skip zone who has no managed_pages in calculate_totalreserve_pages()
Date: Mon, 12 Nov 2018 15:14:04 +0800
Message-Id: <20181112071404.13620-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: mgorman@techsingularity.net, linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

Zone with no managed_pages doesn't contribute totalreserv_pages. And the
more nodes we have, the more empty zones there are.

This patch skip the zones to save some cycles.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5cb3c8..567de15e1106 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7246,6 +7246,9 @@ static void calculate_totalreserve_pages(void)
 			struct zone *zone = pgdat->node_zones + i;
 			long max = 0;
 
+			if (!managed_zone(zone))
+				continue;
+
 			/* Find valid and maximum lowmem_reserve in the zone */
 			for (j = i; j < MAX_NR_ZONES; j++) {
 				if (zone->lowmem_reserve[j] > max)
-- 
2.15.1
