Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 97E436B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:10:52 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so72489555pdb.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 03:10:52 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id qr9si48728152pbc.92.2015.06.26.03.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 03:10:51 -0700 (PDT)
Message-ID: <558D24C1.5020901@huawei.com>
Date: Fri, 26 Jun 2015 18:09:05 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix set pageblock migratetype when boot
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, iamjoonsoo.kim@lge.com, David Rientjes <rientjes@google.com>, sasha.levin@oracle.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

memmap_init_zone()
	...
	if ((z->zone_start_pfn <= pfn)
	    && (pfn < zone_end_pfn(z))
	    && !(pfn & (pageblock_nr_pages - 1)))
		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
	...

If the pfn does not align to pageblock, it will not init the migratetype.
So call it for every page, it will takes more time, but it doesn't matter, 
this function will be called only in boot or hotadd memory.

e.g.
[  223.679446]   node   0: [mem 0x00001000-0x00099fff]
[  223.679449]   node   0: [mem 0x00100000-0xbf78ffff]
[  223.680486]   node   0: [mem 0x100000000-0x27fffffff]

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..a1df227 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4210,8 +4210,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * pfn out of zone.
 		 */
 		if ((z->zone_start_pfn <= pfn)
-		    && (pfn < zone_end_pfn(z))
-		    && !(pfn & (pageblock_nr_pages - 1)))
+		    && (pfn < zone_end_pfn(z)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
