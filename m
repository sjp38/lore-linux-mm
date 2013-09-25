Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF476B0075
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:23:08 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so476399pab.15
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:23:07 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:53:03 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 5CDB2E0053
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:06 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNMwRs45088988
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:58 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNMx5w022444
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:00 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 22/40] mm: Propagate the sorted-buddy bias for picking
 free regions, to region allocator
Date: Thu, 26 Sep 2013 04:48:53 +0530
Message-ID: <20130925231852.26184.31885.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The sorted-buddy page allocator keeps the buddy freelists sorted region-wise,
and tries to pick lower numbered regions while allocating pages. The idea is
to allocate regions in the increasing order of region number.

Propagate the same bias to the region allocator as well. That is, make it
favor lower numbered regions while allocating regions to the page allocator.
To do this efficiently, add a bitmap to represent the regions in the region
allocator, and use bitmap operations to manage these regions and to pick the
lowest numbered free region efficiently.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |   19 ++++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7c87518..49c8926 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -125,6 +125,7 @@ struct mem_region {
 struct region_allocator {
 	struct mem_region	region[MAX_NR_ZONE_REGIONS];
 	int			next_region;
+	DECLARE_BITMAP(ralloc_mask, MAX_NR_ZONE_REGIONS);
 };
 
 struct pglist_data;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee6c098..d5acea7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -935,7 +935,7 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 	struct free_area_region *reg_area;
 	struct list_head *ralloc_list;
 	unsigned long nr_pages;
-	int order;
+	int order, *next_region;
 
 	if (WARN_ON(list_empty(&free_list->list)))
 		return;
@@ -952,6 +952,13 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 
 	WARN_ON(reg_area->nr_free != 0);
 	reg_area->nr_free += nr_pages;
+
+	set_bit(region_id, reg_alloc->ralloc_mask);
+	next_region = &reg_alloc->next_region;
+
+	if ((*next_region < 0) ||
+			(*next_region > 0 && region_id < *next_region))
+		*next_region = region_id;
 }
 
 /* Delete freepages from the region allocator and add them to buddy freelists */
@@ -982,6 +989,16 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 	reg_area->nr_free -= nr_pages;
 	WARN_ON(reg_area->nr_free != 0);
 
+	/* Pick a new next_region */
+	clear_bit(next_region, reg_alloc->ralloc_mask);
+	next_region = find_first_bit(reg_alloc->ralloc_mask,
+				     MAX_NR_ZONE_REGIONS);
+
+	if (next_region >= MAX_NR_ZONE_REGIONS)
+		next_region = -1; /* No free regions available */
+
+	reg_alloc->next_region = next_region;
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
