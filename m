Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EC9896B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:20:44 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:20:44 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2709E1FF001D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:20:42 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDKg4J183562
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:20:42 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDKaWx003908
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:20:40 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 09/35] mm: Track the freepage migratetype of pages
 accurately
Date: Fri, 30 Aug 2013 18:46:38 +0530
Message-ID: <20130830131635.4947.81565.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index 398b62c..b4b1275 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -947,6 +947,13 @@ static inline void expand(struct zone *zone, struct page *page,
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
