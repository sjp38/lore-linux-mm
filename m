Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF2E6B0008
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 07:48:54 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id c26so4821372qtj.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 04:48:54 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c197si122582qkb.295.2018.03.01.04.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 04:48:53 -0800 (PST)
From: Daniel Vacek <neelx@redhat.com>
Subject: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Date: Thu,  1 Mar 2018 13:47:45 +0100
Message-Id: <1519908465-12328-1-git-send-email-neelx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, Daniel Vacek <neelx@redhat.com>, stable@vger.kernel.org

In move_freepages() a BUG_ON() can be triggered on uninitialized page structures
due to pageblock alignment. Aligning the skipped pfns in memmap_init_zone() the
same way as in move_freepages_block() simply fixes those crashes.

Fixes: b92df1de5d28 ("[mm] page_alloc: skip over regions of invalid pfns where possible")
Signed-off-by: Daniel Vacek <neelx@redhat.com>
Cc: stable@vger.kernel.org
---
 mm/page_alloc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb416723538f..9edee36e6a74 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5359,9 +5359,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			/*
 			 * Skip to the pfn preceding the next valid one (or
 			 * end_pfn), such that we hit a valid pfn (or end_pfn)
-			 * on our next iteration of the loop.
+			 * on our next iteration of the loop. Note that it needs
+			 * to be pageblock aligned even when the region itself
+			 * is not as move_freepages_block() can shift ahead of
+			 * the valid region but still depends on correct page
+			 * metadata.
 			 */
-			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
+			pfn = (memblock_next_valid_pfn(pfn, end_pfn) &
+						~(pageblock_nr_pages-1)) - 1;
 #endif
 			continue;
 		}
-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
