Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id B3ED36B0062
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:36 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:36 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9AE223E40039
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:20 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EX4V157372
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:33 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EWqg029544
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:33 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 14/25] page_alloc: use dnuma to transplant newly freed pages in __free_pages_ok()
Date: Thu, 11 Apr 2013 18:13:46 -0700
Message-Id: <1365729237-29711-15-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

__free_pages_ok() handles higher order (order != 0) pages. Transplant
hook is added here as this is where the struct zone to free to is
decided.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4628443..f8ae178 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
 #include <linux/sched/rt.h>
+#include <linux/dnuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -732,6 +733,13 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
 	int migratetype;
+	int dest_nid = dnuma_page_needs_move(page);
+	struct zone *zone;
+
+	if (dest_nid != NUMA_NO_NODE)
+		zone = nid_zone(dest_nid, page_zonenum(page));
+	else
+		zone = page_zone(page);
 
 	if (!free_pages_prepare(page, order))
 		return;
@@ -740,7 +748,11 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	__count_vm_events(PGFREE, 1 << order);
 	migratetype = get_pageblock_migratetype(page);
 	set_freepage_migratetype(page, migratetype);
-	free_one_page(page_zone(page), page, order, migratetype);
+	if (dest_nid != NUMA_NO_NODE)
+		dnuma_prior_free_to_new_zone(page, order, zone, dest_nid);
+	free_one_page(zone, page, order, migratetype);
+	if (dest_nid != NUMA_NO_NODE)
+		dnuma_post_free_to_new_zone(order);
 	local_irq_restore(flags);
 }
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
