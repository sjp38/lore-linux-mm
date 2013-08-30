Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 042BB6B0039
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:38:09 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 06:38:09 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 39C5F19D803E
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 06:38:06 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UCc5nG197682
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 06:38:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UCc4YU013735
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 06:38:05 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 02/35] mm: Fix the value of fallback_migratetype in
 alloc_extfrag tracepoint
Date: Fri, 30 Aug 2013 18:04:08 +0530
Message-ID: <20130830123406.24352.47995.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
References: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the current code, the value of fallback_migratetype that is printed
using the mm_page_alloc_extfrag tracepoint, is the value of the migratetype
*after* it has been set to the preferred migratetype (if the ownership was
changed). Obviously that wouldn't have been the original intent. (We already
have a separate 'change_ownership' field to tell whether the ownership of the
pageblock was changed from the fallback_migratetype to the preferred type.)

The intent of the fallback_migratetype field is to show the migratetype
from which we borrowed pages in order to satisfy the allocation request.
So fix the code to print that value correctly.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/trace/events/kmem.h |   10 +++++++---
 mm/page_alloc.c             |    5 +++--
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 6bc943e..d0c6134 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -268,11 +268,13 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
 			int alloc_order, int fallback_order,
-			int alloc_migratetype, int fallback_migratetype),
+			int alloc_migratetype, int fallback_migratetype,
+			int change_ownership),
 
 	TP_ARGS(page,
 		alloc_order, fallback_order,
-		alloc_migratetype, fallback_migratetype),
+		alloc_migratetype, fallback_migratetype,
+		change_ownership),
 
 	TP_STRUCT__entry(
 		__field(	struct page *,	page			)
@@ -280,6 +282,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__field(	int,		fallback_order		)
 		__field(	int,		alloc_migratetype	)
 		__field(	int,		fallback_migratetype	)
+		__field(	int,		change_ownership	)
 	),
 
 	TP_fast_assign(
@@ -288,6 +291,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->fallback_order		= fallback_order;
 		__entry->alloc_migratetype	= alloc_migratetype;
 		__entry->fallback_migratetype	= fallback_migratetype;
+		__entry->change_ownership	= change_ownership;
 	),
 
 	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
@@ -299,7 +303,7 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->alloc_migratetype,
 		__entry->fallback_migratetype,
 		__entry->fallback_order < pageblock_order,
-		__entry->alloc_migratetype == __entry->fallback_migratetype)
+		__entry->change_ownership)
 );
 
 #endif /* _TRACE_KMEM_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d4b8198..b86d7e3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1100,8 +1100,9 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			       is_migrate_cma(migratetype)
 			     ? migratetype : start_migratetype);
 
-			trace_mm_page_alloc_extfrag(page, order, current_order,
-				start_migratetype, new_type);
+			trace_mm_page_alloc_extfrag(page, order,
+				current_order, start_migratetype, migratetype,
+				new_type == start_migratetype);
 
 			return page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
