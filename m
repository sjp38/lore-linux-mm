Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D27C96B005A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:22:45 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so317854pde.23
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:22:45 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:52:40 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 04C69E0053
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:42 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNOrZe37617792
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:54:54 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNMZtP016130
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:52:36 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 20/40] mm: Provide a mechanism to request free memory
 from the region allocator
Date: Thu, 26 Sep 2013 04:48:29 +0530
Message-ID: <20130925231828.26184.18736.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Implement helper functions to request freepages from the region allocator
in order to add them to the buddy freelists.

For simplicity, all operations related to the region allocator are performed
at the granularity of entire memory regions. That is, when the buddy
allocator requests freepages from the region allocator, the latter picks a
free region and always allocates all the freepages belonging to that entire
region.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c727bba..d71d671 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -939,6 +939,29 @@ static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
 	del_from_freelist_bulk(ralloc_list, free_list, order, region_id);
 }
 
+/* Delete freepages from the region allocator and add them to buddy freelists */
+static int del_from_region_allocator(struct zone *zone, unsigned int order,
+				     int migratetype)
+{
+	struct region_allocator *reg_alloc;
+	struct list_head *ralloc_list;
+	struct free_list *free_list;
+	int next_region;
+
+	reg_alloc = &zone->region_allocator;
+
+	next_region = reg_alloc->next_region;
+	if (next_region < 0)
+		return -ENOMEM;
+
+	ralloc_list = &reg_alloc->region[next_region].region_area[order].list;
+	free_list = &zone->free_area[order].free_list[migratetype];
+
+	add_to_freelist_bulk(ralloc_list, free_list, order, next_region);
+
+	return 0;
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
