Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFDB6B006E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:30:14 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so5922418pdb.5
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:30:14 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ch5si3901325pdb.158.2015.02.11.23.30.10
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:10 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 05/16] mm/vmstat: watch out zone range overlap
Date: Thu, 12 Feb 2015 16:32:09 +0900
Message-Id: <1423726340-4084-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, new zone, ZONE_CMA, will be introduced and
it would be overlapped with other zones. Currently, many places
iterating pfn range doesn't consider possibility of zone overlap and
this would cause a problem such as printing wrong statistics information.
To prevent this situation, this patch add some code to consider zone
overlapping before adding ZONE_CMA.

pagetypeinfo_showblockcount_print() prints zone's statistics so should
consider zone overlap.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1b12d39..7a4ac8e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -984,6 +984,8 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 			continue;
 
 		page = pfn_to_page(pfn);
+		if (page_zone(page) != zone)
+			continue;
 
 		/* Watch for unexpected holes punched in the memmap */
 		if (!memmap_valid_within(pfn, page, zone))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
