Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 3AC256B009C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:28:42 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:28:41 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9C38D1FF001A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:38 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDScmq198488
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDSaZ3014485
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:38 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 34/35] mm: Set pageblock migratetype when allocating
 regions from region allocator
Date: Fri, 30 Aug 2013 18:54:40 +0530
Message-ID: <20130830132437.4947.12826.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We would like to maintain memory regions such that all memory pertaining to
given a memory region serves allocations of a single migratetype. IOW, we
don't want to permanently mix allocations of different migratetypes within
the same region.

So, when allocating a region from the region allocator to the page allocator,
set the pageblock migratetype of all that memory to the migratetype for which
the page allocator requested memory.

Note that this still allows temporary sharing of pages between different
migratetypes; it just ensures that there is no *permanent* mixing of
migratetypes within a given memory region.

An important advantage to be noted here is that the region allocator doesn't
have to manage memory in a granularity lesser than a memory region, in *any*
situation. This is because the freepage migratetype and the fallback mechanism
allows temporary sharing of free memory between different migratetypes when
the system is short on memory, but eventually all the memory gets freed to
the original migratetype (because we set the pageblock migratetype of all the
freepages appropriately when allocating regions).

This greatly simplifies the design of the region allocator, since it doesn't
have to keep track of memory in smaller chunks than a memory region.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e303351..1312546 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1016,8 +1016,10 @@ static void __del_from_region_allocator(struct zone *zone, unsigned int order,
 	reg_area = &reg_alloc->region[region_id].region_area[order];
 	ralloc_list = &reg_area->list;
 
-	list_for_each_entry(page, ralloc_list, lru)
+	list_for_each_entry(page, ralloc_list, lru) {
 		set_freepage_migratetype(page, migratetype);
+		set_pageblock_migratetype(page, migratetype);
+	}
 
 	free_list = &zone->free_area[order].free_list[migratetype];
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
