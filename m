Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 53F996B000A
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:15 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 16:27:10 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B6672C9001D
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:06 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLR6v429229224
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:27:06 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLR6Zo003562
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 18:27:06 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 17/24] page_alloc: use dnuma to transplant newly freed pages in __free_pages_ok()
Date: Thu, 28 Feb 2013 13:26:14 -0800
Message-Id: <1362086781-16725-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362086781-16725-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

__free_pages_ok() handles higher order (order != 0) pages. Transplant
hook is added here as this is where the struct zone to free to is
decided.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5eeb547..5c7930f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/migrate.h>
 #include <linux/page-debug-flags.h>
 #include <linux/sched/rt.h>
+#include <linux/dnuma.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -739,6 +740,13 @@ static void __free_pages_ok(struct page *page, unsigned int order)
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
@@ -747,7 +755,11 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	__count_vm_events(PGFREE, 1 << order);
 	migratetype = get_pageblock_migratetype(page);
 	set_freepage_migratetype(page, migratetype);
-	free_one_page(page_zone(page), page, order, migratetype);
+	if (dest_nid != NUMA_NO_NODE)
+		dnuma_prior_free_to_new_zone(page, order, zone, dest_nid);
+	free_one_page(zone, page, order, migratetype);
+	if (dest_nid != NUMA_NO_NODE)
+		dnuma_post_free_to_new_zone(page, order);
 	local_irq_restore(flags);
 }
 
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
