Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 34E456B0036
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:41:03 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 06:41:02 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6D93A6E804C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:40:58 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UCewxY27918564
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 12:40:58 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UCevL0002867
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:40:58 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 09/35] mm: Track the freepage migratetype of pages
 accurately
Date: Fri, 30 Aug 2013 18:07:01 +0530
Message-ID: <20130830123655.24352.97744.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
References: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
