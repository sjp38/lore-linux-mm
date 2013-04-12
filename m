Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 86FD56B006E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:39 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:38 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0A252C90028
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:36 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EZU448758982
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:35 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EZ3B025704
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:35 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 15/25] page_alloc: use dnuma to transplant newly freed pages in free_hot_cold_page()
Date: Thu, 11 Apr 2013 18:13:47 -0700
Message-Id: <1365729237-29711-16-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

free_hot_cold_page() is used for order == 0 pages, and is where the
page's zone is decided.

In the normal case, these pages are freed to the per-cpu lists. When a
page needs transplanting (ie: the actual node it belongs to has changed,
and it needs to be moved to another zone), the pcp lists are skipped &
the page is freed via free_one_page().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8ae178..98ac7c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1357,6 +1357,7 @@ void mark_free_pages(struct zone *zone)
  */
 void free_hot_cold_page(struct page *page, int cold)
 {
+	int dest_nid;
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
@@ -1370,6 +1371,15 @@ void free_hot_cold_page(struct page *page, int cold)
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 
+	dest_nid = dnuma_page_needs_move(page);
+	if (dest_nid != NUMA_NO_NODE) {
+		struct zone *dest_zone = nid_zone(dest_nid, page_zonenum(page));
+		dnuma_prior_free_to_new_zone(page, 0, dest_zone, dest_nid);
+		free_one_page(dest_zone, page, 0, migratetype);
+		dnuma_post_free_to_new_zone(0);
+		goto out;
+	}
+
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
 	 * Free ISOLATE pages back to the allocator because they are being
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
