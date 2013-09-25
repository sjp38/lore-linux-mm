Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8F2A6B003C
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:24:06 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so308430pbb.24
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:24:06 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:54:02 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 0A829E0057
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:55:05 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNQFFg44564692
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:56:15 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNNwMF029202
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:59 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 27/40] mm: Update the freepage migratetype of pages
 during region allocation
Date: Thu, 26 Sep 2013 04:49:53 +0530
Message-ID: <20130925231951.26184.19429.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The freepage migratetype is used to determine which freelist a given
page should be added to, upon getting freed. To ensure that the page
goes to the right freelist, set the freepage migratetype of all
the pages of a region, when allocating freepages from the region allocator.

This helps ensure that upon freeing the pages or during buddy expansion,
the pages are added back to the freelists of the migratetype for which
the pages were originally requested from the region allocator.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d73134..ca7b959 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1023,6 +1023,9 @@ static int del_from_region_allocator(struct zone *zone, unsigned int order,
 	reg_area = &reg_alloc->region[next_region].region_area[order];
 	ralloc_list = &reg_area->list;
 
+	list_for_each_entry(page, ralloc_list, lru)
+		set_freepage_migratetype(page, migratetype);
+
 	free_list = &zone->free_area[order].free_list[migratetype];
 
 	nr_pages = add_to_freelist_bulk(ralloc_list, free_list, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
