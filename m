Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 855DF6B0288
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:39 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 18:01:38 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id CF27EC90046
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:34 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301Z3Q253028
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:35 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301YDt005870
	for <linux-mm@kvack.org>; Thu, 2 May 2013 21:01:34 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 21/31] page_alloc: use dnuma to transplant newly freed pages in free_hot_cold_page()
Date: Thu,  2 May 2013 17:00:53 -0700
Message-Id: <1367539263-19999-22-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

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
index f33f1bf..38a2161 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1358,6 +1358,7 @@ void mark_free_pages(struct zone *zone)
  */
 void free_hot_cold_page(struct page *page, int cold)
 {
+	int dest_nid;
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
@@ -1371,6 +1372,15 @@ void free_hot_cold_page(struct page *page, int cold)
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
