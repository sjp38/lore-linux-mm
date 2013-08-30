Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4C5B96B0096
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:28:25 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 14:28:24 +0100
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 239A238C8087
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:28:20 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDSJP510420300
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:28:19 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDSI3U020850
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 10:28:19 -0300
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 33/35] mm: Never change migratetypes of pageblocks
 during freepage stealing
Date: Fri, 30 Aug 2013 18:54:23 +0530
Message-ID: <20130830132421.4947.9280.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We would like to keep large chunks of memory (of the size of memory regions)
populated by allocations of a single migratetype. This helps in influencing
allocation/reclaim decisions at a per-migratetype basis, which would also
automatically respect memory region boundaries.

For example, if a region is known to contain only MIGRATE_UNMOVABLE pages,
we can skip trying targeted compaction on that region. Similarly, if a region
has only MIGRATE_MOVABLE pages, then the likelihood of successful targeted
evacuation of that region is higher, as opposed to having a few unmovable
pages embedded in a region otherwise containing mostly movable allocations.
Thus, it is beneficial to try and keep memory allocations homogeneous (in
terms of the migratetype) in region-sized chunks of memory.

Changing the migratetypes of pageblocks during freepage stealing comes in the
way of this effort, since it fragments the ownership of memory segments.
So never change the ownership of pageblocks during freepage stealing.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   36 ++++++++++--------------------------
 1 file changed, 10 insertions(+), 26 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3ce0c61..e303351 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1648,14 +1648,16 @@ static void change_pageblock_range(struct page *pageblock_page,
 /*
  * If breaking a large block of pages, move all free pages to the preferred
  * allocation list. If falling back for a reclaimable kernel allocation, be
- * more aggressive about taking ownership of free pages.
+ * more aggressive about borrowing the free pages.
  *
- * On the other hand, never change migration type of MIGRATE_CMA pageblocks
- * nor move CMA pages to different free lists. We don't want unmovable pages
- * to be allocated from MIGRATE_CMA areas.
+ * On the other hand, never move CMA pages to different free lists. We don't
+ * want unmovable pages to be allocated from MIGRATE_CMA areas.
  *
- * Returns the new migratetype of the pageblock (or the same old migratetype
- * if it was unchanged).
+ * Also, we *NEVER* change the pageblock migratetype of any block of memory.
+ * (IOW, we only try to _loan_ the freepages from a fallback list, but never
+ * try to _own_ them.)
+ *
+ * Returns the migratetype of the fallback list.
  */
 static int try_to_steal_freepages(struct zone *zone, struct page *page,
 				  int start_type, int fallback_type)
@@ -1665,28 +1667,10 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 	if (is_migrate_cma(fallback_type))
 		return fallback_type;
 
-	/* Take ownership for orders >= pageblock_order */
-	if (current_order >= pageblock_order) {
-		change_pageblock_range(page, current_order, start_type);
-		return start_type;
-	}
-
 	if (current_order >= pageblock_order / 2 ||
 	    start_type == MIGRATE_RECLAIMABLE ||
-	    page_group_by_mobility_disabled) {
-		int pages;
-
-		pages = move_freepages_block(zone, page, start_type);
-
-		/* Claim the whole block if over half of it is free */
-		if (pages >= (1 << (pageblock_order-1)) ||
-				page_group_by_mobility_disabled) {
-
-			set_pageblock_migratetype(page, start_type);
-			return start_type;
-		}
-
-	}
+	    page_group_by_mobility_disabled)
+		move_freepages_block(zone, page, start_type);
 
 	return fallback_type;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
