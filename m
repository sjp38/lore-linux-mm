Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 136216B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:03:17 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id x19so11854167ier.20
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 15:03:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n4si7787118ige.9.2014.12.15.15.03.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Dec 2014 15:03:15 -0800 (PST)
Date: Mon, 15 Dec 2014 15:03:14 -0800
From: akpm@linux-foundation.org
Subject: [patch 1/6] mm: page_isolation: check pfn validity before access
Message-ID: <548f68b2.K9HkeqWVHZ6daibm%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, weijie.yang@samsung.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, mhocko@suse.cz, mina86@mina86.com, minchan@kernel.org, stable@vger.kernel.org

From: Weijie Yang <weijie.yang@samsung.com>
Subject: mm: page_isolation: check pfn validity before access

In the undo path of start_isolate_page_range(), we need to check the pfn
validity before accessing its page, or it will trigger an addressing
exception if there is hole in the zone.

This issue is found by code-review not a test-trigger.  In
"CONFIG_HOLES_IN_ZONE" environment, there is a certain chance that it
would casue an addressing exception when start_isolate_page_range()
fails, this could affect CMA, hugepage and memory-hotplug function.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_isolation.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff -puN mm/page_isolation.c~mm-page_isolation-check-pfn-validity-before-access mm/page_isolation.c
--- a/mm/page_isolation.c~mm-page_isolation-check-pfn-validity-before-access
+++ a/mm/page_isolation.c
@@ -176,8 +176,11 @@ int start_isolate_page_range(unsigned lo
 undo:
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
-	     pfn += pageblock_nr_pages)
-		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
+	     pfn += pageblock_nr_pages) {
+		page = __first_valid_page(pfn, pageblock_nr_pages);
+		if (page)
+			unset_migratetype_isolate(page, migratetype);
+	}
 
 	return -EBUSY;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
