Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id m9RGnPaN010491
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 16:49:25 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RGnOoO1982698
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:49:24 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RGnOsJ016126
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:49:24 +0100
Message-ID: <4905F114.3030406@de.ibm.com>
Date: Mon, 27 Oct 2008 17:49:24 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
MIME-Version: 1.0
Subject: [PATCH] memory hotplug: fix page_zone() calculation in test_pages_isolated()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

My last bugfix here (adding zone->lock) introduced a new problem: Using
pfn_to_page(pfn) to get the zone after the for() loop is wrong. pfn then
points to the first pfn after end_pfn, which may be in a different zone
or not present at all. This may lead to an addressing exception in
page_zone() or spin_lock_irqsave().

Using the last valid page that was found inside the for() loop, instead
of pfn_to_page(), should fix this.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

---
mm/page_isolation.c |    6 +++---
1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/page_isolation.c
===================================================================
--- linux-2.6.orig/mm/page_isolation.c
+++ linux-2.6/mm/page_isolation.c
@@ -115,7 +115,7 @@ __test_page_isolated_in_pageblock(unsign
int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
{
	unsigned long pfn, flags;
-	struct page *page;
+	struct page *page = NULL;
	struct zone *zone;
	int ret;

@@ -130,10 +130,10 @@ int test_pages_isolated(unsigned long st
		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
			break;
	}
-	if (pfn < end_pfn)
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
