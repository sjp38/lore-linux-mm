Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 86A646B0075
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:24:36 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:24:35 +0100
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CDB6A6E803C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:24:31 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDOVJZ34013270
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:24:31 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDORFP031868
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:24:31 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 21/35] mm: Provide a mechanism to release free memory
 to the region allocator
Date: Fri, 30 Aug 2013 18:50:27 +0530
Message-ID: <20130830132015.4947.83016.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Implement helper functions to release freepages from the buddy freelists to
the region allocator.

For simplicity, all operations related to the region allocator are performed
at the granularity of entire memory regions. That is, when we release freepages
to the region allocator, we free all the pages belonging to that region.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5227ac3..d407caf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -918,6 +918,26 @@ static void move_page_freelist(struct page *page, struct free_list *old_list,
 	add_to_freelist(page, new_list, order);
 }
 
+/* Add pages from the given buddy freelist to the region allocator */
+static void add_to_region_allocator(struct zone *z, struct free_list *free_list,
+				    int region_id)
+{
+	struct region_allocator *reg_alloc;
+	struct list_head *ralloc_list;
+	int order;
+
+	if (WARN_ON(list_empty(&free_list->list)))
+		return;
+
+	order = page_order(list_first_entry(&free_list->list,
+					    struct page, lru));
+
+	reg_alloc = &z->region_allocator;
+	ralloc_list = &reg_alloc->region[region_id].region_area[order].list;
+
+	del_from_freelist_bulk(ralloc_list, free_list, order, region_id);
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
