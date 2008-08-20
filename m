Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7KH8se6005309
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 13:08:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7KH8sQX228622
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 13:08:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7KH8rjK008656
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 13:08:53 -0400
Subject: [BUG] Make setup_zone_migrate_reserve() aware of overlapping nodes
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1218837685.12953.11.camel@localhost.localdomain>
References: <1218837685.12953.11.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 20 Aug 2008 12:08:54 -0500
Message-Id: <1219252134.13885.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

I have gotten to the root cause of the hugetlb badness I reported back
on August 15th.  My system has the following memory topology (note the
overlapping node):

	i>>?Node 0 Memory: 0x8000000-0x44000000
	i>>?Node 1 Memory: 0x0-0x8000000 0x44000000-0x80000000

setup_zone_migrate_reserve() scans the address range 0x0-0x8000000
looking for a pageblock to move onto the MIGRATE_RESERVE list.  Finding
no candidates, it happily continues the scan into 0x8000000-0x44000000.
When a pageblock is found, the pages are moved to the MIGRATE_RESERVE
list on the wrong zone.  Oops.

(Andrew: once the proper fix is agreed upon, this should also be a
candidate for -stable.)

setup_zone_migrate_reserve() should skip pageblocks in overlapping
nodes.

Signed-off-by: Adam Litke <agl@us.ibm.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index af982f7..f297a9b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2512,6 +2512,10 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 							pageblock_order;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		/* Watch out for overlapping nodes */
+		if (!early_pfn_in_nid(pfn, zone->node))
+			continue;
+
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
