Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 105A86B0008
	for <linux-mm@kvack.org>; Fri,  1 Jan 2016 08:12:44 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so107607097wmb.1
        for <linux-mm@kvack.org>; Fri, 01 Jan 2016 05:12:44 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.73])
        by mx.google.com with ESMTPS id js6si125214297wjb.211.2016.01.01.05.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jan 2016 05:12:42 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mm: avoid unused variables in memmap_init_zone
Date: Fri, 01 Jan 2016 14:12:28 +0100
Message-ID: <35629026.HgC1pGWutd@wuerfel>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Tony Luck <tony.luck@intel.com>, Mel Gorman <mgorman@techsingularity.net>

A quick fix on mm/page_alloc.c introduced a harmless warning:

mm/page_alloc.c: In function 'memmap_init_zone':
mm/page_alloc.c:4617:44: warning: unused variable 'tmp' [-Wunused-variable]
mm/page_alloc.c:4617:26: warning: unused variable 'r' [-Wunused-variable]

This uses another #ifdef to avoid declaring the two variables when the
code is not built.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 4c877dea44c4 ("a")
---
This was obvious for any builds on yesterday's linux-next, so most likely
it has already been submitted and/or fixed. If not, please fold this patch
into the one that caused the warning.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 47457a7a8f1f..cf6437b23bfa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4614,7 +4614,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	unsigned long pfn;
 	struct zone *z;
 	unsigned long nr_initialised = 0;
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	struct memblock_region *r = NULL, *tmp;
+#endif
 
 	if (highest_memmap_pfn < end_pfn - 1)
 		highest_memmap_pfn = end_pfn - 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
