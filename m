Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1EE76B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 10:43:48 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so109649149pgc.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:43:48 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 5si1012657plc.226.2017.02.06.07.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 07:43:47 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 204so9391787pge.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:43:47 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/page_alloc: return 0 in case this node has no page within the zone
Date: Mon,  6 Feb 2017 23:43:14 +0800
Message-Id: <20170206154314.15705-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

The whole memory space is divided into several zones and nodes may have no
page in some zones. In this case, the __absent_pages_in_range() would
return 0, since the range it is searching for is an empty range.

Also this happens more often to those nodes with higher memory range when
there are more nodes, which is a trend for future architectures.

This patch checks the zone range after clamp and adjustment, return 0 if
the range is an empty range.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..51c60c0eadcb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5521,6 +5521,11 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 			node_start_pfn, node_end_pfn,
 			&zone_start_pfn, &zone_end_pfn);
+
+	/* If this node has no page within this zone, return 0. */
+	if (zone_start_pfn == zone_end_pfn)
+		return 0;
+
 	nr_absent = __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
 
 	/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
