Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D46966B003B
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:19:30 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so319967pdj.15
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:19:30 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:19:26 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 833ED2CE8051
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:23 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PN2gOo44433624
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:02:43 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNJL77013064
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:22 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 07/40] mm: Track the freepage migratetype of pages
 accurately
Date: Thu, 26 Sep 2013 04:45:12 +0530
Message-ID: <20130925231510.26184.13440.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Due to the region-wise ordering of the pages in the buddy allocator's
free lists, whenever we want to delete a free pageblock from a free list
(for ex: when moving blocks of pages from one list to the other), we need
to be able to tell the buddy allocator exactly which migratetype it belongs
to. For that purpose, we can use the page's freepage migratetype (which is
maintained in the page's ->index field).

So, while splitting up higher order pages into smaller ones as part of buddy
operations, keep the new head pages updated with the correct freepage
migratetype information (because we depend on tracking this info accurately,
as outlined above).

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d48eb04..e31daf4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -950,6 +950,13 @@ static inline void expand(struct zone *zone, struct page *page,
 		add_to_freelist(&page[size], &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
+
+		/*
+		 * Freepage migratetype is tracked using the index field of the
+		 * first page of the block. So we need to update the new first
+		 * page, when changing the page order.
+		 */
+		set_freepage_migratetype(&page[size], migratetype);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
