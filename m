Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4B36B0088
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:24:19 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so313643pbb.14
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:24:19 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:54:14 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DE7D5394004D
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:55 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNO97q47317180
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:09 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNOAJV020557
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:11 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 28/40] mm: Provide a mechanism to check if a given page
 is in the region allocator
Date: Thu, 26 Sep 2013 04:50:04 +0530
Message-ID: <20130925232002.26184.73188.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With the introduction of the region allocator, a freepage can be either
in one of the buddy freelists or in the region allocator. In cases where we
want to move freepages to a given migratetype's freelists, we will need to
know where they were originally located. So provide a helper to distinguish
whether the freepage resides in the region allocator or the buddy freelists.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca7b959..ac04b45 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1048,6 +1048,37 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 }
 
 /*
+ * Return 1 if the page is in the region allocator, else return 0
+ * (which usually means that the page is in the buddy freelists).
+ */
+static int page_in_region_allocator(struct page *page)
+{
+	struct region_allocator *reg_alloc;
+	struct free_area_region *reg_area;
+	int order, region_id;
+
+	/* We keep only MAX_ORDER-1 pages in the region allocator */
+	order = page_order(page);
+	if (order != MAX_ORDER-1)
+		return 0;
+
+	/*
+	 * It is sufficient to check if (any of) the pages belonging to
+	 * that region are in the region allocator, because a page resides
+	 * in the region allocator if and only if all the pages of that
+	 * region are also in the region allocator.
+	 */
+	region_id = page_zone_region_id(page);
+	reg_alloc = &page_zone(page)->region_allocator;
+	reg_area = &reg_alloc->region[region_id].region_area[order];
+
+	if (reg_area->nr_free)
+		return 1;
+
+	return 0;
+}
+
+/*
  * Freeing function for a buddy system allocator.
  *
  * The concept of a buddy system is to maintain direct-mapped table

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
