Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id m9TEPcMO023108
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:25:38 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9TEPcAf3268634
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 15:25:38 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9TEPbab025961
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 15:25:38 +0100
Subject: [PATCH] memory hotplug: fix page_zone() calculation in
	test_pages_isolated()
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
Content-Type: text/plain
Date: Wed, 29 Oct 2008 15:25:30 +0100
Message-Id: <1225290330.10021.7.camel@t60p>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

My last bugfix here (adding zone->lock) introduced a new problem: Using
page_zone(pfn_to_page(pfn)) to get the zone after the for() loop is wrong.
pfn will then be >= end_pfn, which may be in a different zone or not
present at all. This may lead to an addressing exception in page_zone()
or spin_lock_irqsave().

Now I use __first_valid_page() again after the loop to find a valid page
for page_zone().

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

---
 mm/page_isolation.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/page_isolation.c
===================================================================
--- linux-2.6.orig/mm/page_isolation.c
+++ linux-2.6/mm/page_isolation.c
@@ -130,10 +130,11 @@ int test_pages_isolated(unsigned long st
 		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 			break;
 	}
-	if (pfn < end_pfn)
+	page = __first_valid_page(start_pfn, end_pfn - start_pfn);
+	if ((pfn < end_pfn) || !page)
 		return -EBUSY;
 	/* Check all pages are free or Marked as ISOLATED */
-	zone = page_zone(pfn_to_page(pfn));
+	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
 	ret = __test_page_isolated_in_pageblock(start_pfn, end_pfn);
 	spin_unlock_irqrestore(&zone->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
