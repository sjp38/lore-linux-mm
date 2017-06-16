Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E308C83292
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 05:24:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g78so33031357pfg.4
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:24:09 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id x84si1585271pgx.145.2017.06.16.02.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 02:24:09 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id y7so5291014pfd.3
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 02:24:09 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm/memory_hotplug: remove duplicate call for set_page_links
Date: Fri, 16 Jun 2017 17:23:35 +0800
Message-Id: <20170616092335.5177-2-richard.weiyang@gmail.com>
In-Reply-To: <20170616092335.5177-1-richard.weiyang@gmail.com>
References: <20170616092335.5177-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Wei Yang <richard.weiyang@gmail.com>

In function move_pfn_range_to_zone(), memmap_init_zone() will call
set_page_links for each page. This means we don't need to call it on each
page explicitly.

This patch just removes the loop.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memory_hotplug.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d61509752112..4fb1fb2b2b53 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -914,10 +914,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 	 * are reserved so nobody should be touching them so we should be safe
 	 */
 	memmap_init_zone(nr_pages, nid, zone_idx(zone), start_pfn, MEMMAP_HOTPLUG);
-	for (i = 0; i < nr_pages; i++) {
-		unsigned long pfn = start_pfn + i;
-		set_page_links(pfn_to_page(pfn), zone_idx(zone), nid, pfn);
-	}
 
 	set_zone_contiguous(zone);
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
