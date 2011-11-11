Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D45A76B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:40:09 -0500 (EST)
Received: by mail-bw0-f41.google.com with SMTP id 17so2911873bke.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 04:40:08 -0800 (PST)
Subject: [PATCH v3 3/4] mm-tracepoint: rename page-free events
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 11 Nov 2011 16:40:05 +0300
Message-ID: <20111111124005.7371.63176.stgit@zurg>
In-Reply-To: <20110729075837.12274.58405.stgit@localhost6>
References: <20110729075837.12274.58405.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>

Rename mm_page_free_direct into mm_page_free
and mm_pagevec_free into mm_page_free_batched

Since v2.6.33-5426-gc475dab kernel trigger mm_page_free_direct for all freed pages,
not only for directly freed. So, let's name it properly.
For pages freed via page-list we also trigger mm_page_free_batched event.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 Documentation/trace/events-kmem.txt                |   12 ++++++------
 .../postprocess/trace-pagealloc-postprocess.pl     |   20 ++++++++++----------
 include/trace/events/kmem.h                        |    4 ++--
 mm/page_alloc.c                                    |    4 ++--
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/Documentation/trace/events-kmem.txt b/Documentation/trace/events-kmem.txt
index aa82ee4..1948004 100644
--- a/Documentation/trace/events-kmem.txt
+++ b/Documentation/trace/events-kmem.txt
@@ -40,8 +40,8 @@ but the call_site can usually be used to extrapolate that information.
 ==================
 mm_page_alloc		  page=%p pfn=%lu order=%d migratetype=%d gfp_flags=%s
 mm_page_alloc_zone_locked page=%p pfn=%lu order=%u migratetype=%d cpu=%d percpu_refill=%d
-mm_page_free_direct	  page=%p pfn=%lu order=%d
-mm_pagevec_free		  page=%p pfn=%lu order=%d cold=%d
+mm_page_free		  page=%p pfn=%lu order=%d
+mm_page_free_batched	  page=%p pfn=%lu order=%d cold=%d
 
 These four events deal with page allocation and freeing. mm_page_alloc is
 a simple indicator of page allocator activity. Pages may be allocated from
@@ -53,13 +53,13 @@ amounts of activity imply high activity on the zone->lock. Taking this lock
 impairs performance by disabling interrupts, dirtying cache lines between
 CPUs and serialising many CPUs.
 
-When a page is freed directly by the caller, the mm_page_free_direct event
+When a page is freed directly by the caller, the only mm_page_free event
 is triggered. Significant amounts of activity here could indicate that the
 callers should be batching their activities.
 
-When pages are freed using a pagevec, the mm_pagevec_free is
-triggered. Broadly speaking, pages are taken off the LRU lock in bulk and
-freed in batch with a pagevec. Significant amounts of activity here could
+When pages are freed in batch, the also mm_page_free_batched is triggered.
+Broadly speaking, pages are taken off the LRU lock in bulk and
+freed in batch with a page list. Significant amounts of activity here could
 indicate that the system is under memory pressure and can also indicate
 contention on the zone->lru_lock.
 
diff --git a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
index 7df50e8..0a120aa 100644
--- a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
@@ -17,8 +17,8 @@ use Getopt::Long;
 
 # Tracepoint events
 use constant MM_PAGE_ALLOC		=> 1;
-use constant MM_PAGE_FREE_DIRECT 	=> 2;
-use constant MM_PAGEVEC_FREE		=> 3;
+use constant MM_PAGE_FREE		=> 2;
+use constant MM_PAGE_FREE_BATCHED	=> 3;
 use constant MM_PAGE_PCPU_DRAIN		=> 4;
 use constant MM_PAGE_ALLOC_ZONE_LOCKED	=> 5;
 use constant MM_PAGE_ALLOC_EXTFRAG	=> 6;
@@ -223,10 +223,10 @@ EVENT_PROCESS:
 		# Perl Switch() sucks majorly
 		if ($tracepoint eq "mm_page_alloc") {
 			$perprocesspid{$process_pid}->{MM_PAGE_ALLOC}++;
-		} elsif ($tracepoint eq "mm_page_free_direct") {
-			$perprocesspid{$process_pid}->{MM_PAGE_FREE_DIRECT}++;
-		} elsif ($tracepoint eq "mm_pagevec_free") {
-			$perprocesspid{$process_pid}->{MM_PAGEVEC_FREE}++;
+		} elsif ($tracepoint eq "mm_page_free") {
+			$perprocesspid{$process_pid}->{MM_PAGE_FREE}++
+		} elsif ($tracepoint eq "mm_page_free_batched") {
+			$perprocesspid{$process_pid}->{MM_PAGE_FREE_BATCHED}++;
 		} elsif ($tracepoint eq "mm_page_pcpu_drain") {
 			$perprocesspid{$process_pid}->{MM_PAGE_PCPU_DRAIN}++;
 			$perprocesspid{$process_pid}->{STATE_PCPU_PAGES_DRAINED}++;
@@ -336,8 +336,8 @@ sub dump_stats {
 			$process_pid,
 			$stats{$process_pid}->{MM_PAGE_ALLOC},
 			$stats{$process_pid}->{MM_PAGE_ALLOC_ZONE_LOCKED},
-			$stats{$process_pid}->{MM_PAGE_FREE_DIRECT},
-			$stats{$process_pid}->{MM_PAGEVEC_FREE},
+			$stats{$process_pid}->{MM_PAGE_FREE},
+			$stats{$process_pid}->{MM_PAGE_FREE_BATCHED},
 			$stats{$process_pid}->{MM_PAGE_PCPU_DRAIN},
 			$stats{$process_pid}->{HIGH_PCPU_DRAINS},
 			$stats{$process_pid}->{HIGH_PCPU_REFILLS},
@@ -364,8 +364,8 @@ sub aggregate_perprocesspid() {
 
 		$perprocess{$process}->{MM_PAGE_ALLOC} += $perprocesspid{$process_pid}->{MM_PAGE_ALLOC};
 		$perprocess{$process}->{MM_PAGE_ALLOC_ZONE_LOCKED} += $perprocesspid{$process_pid}->{MM_PAGE_ALLOC_ZONE_LOCKED};
-		$perprocess{$process}->{MM_PAGE_FREE_DIRECT} += $perprocesspid{$process_pid}->{MM_PAGE_FREE_DIRECT};
-		$perprocess{$process}->{MM_PAGEVEC_FREE} += $perprocesspid{$process_pid}->{MM_PAGEVEC_FREE};
+		$perprocess{$process}->{MM_PAGE_FREE} += $perprocesspid{$process_pid}->{MM_PAGE_FREE};
+		$perprocess{$process}->{MM_PAGE_FREE_BATCHED} += $perprocesspid{$process_pid}->{MM_PAGE_FREE_BATCHED};
 		$perprocess{$process}->{MM_PAGE_PCPU_DRAIN} += $perprocesspid{$process_pid}->{MM_PAGE_PCPU_DRAIN};
 		$perprocess{$process}->{HIGH_PCPU_DRAINS} += $perprocesspid{$process_pid}->{HIGH_PCPU_DRAINS};
 		$perprocess{$process}->{HIGH_PCPU_REFILLS} += $perprocesspid{$process_pid}->{HIGH_PCPU_REFILLS};
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index a9c87ad..5f889f1 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -147,7 +147,7 @@ DEFINE_EVENT(kmem_free, kmem_cache_free,
 	TP_ARGS(call_site, ptr)
 );
 
-TRACE_EVENT(mm_page_free_direct,
+TRACE_EVENT(mm_page_free,
 
 	TP_PROTO(struct page *page, unsigned int order),
 
@@ -169,7 +169,7 @@ TRACE_EVENT(mm_page_free_direct,
 			__entry->order)
 );
 
-TRACE_EVENT(mm_pagevec_free,
+TRACE_EVENT(mm_page_free_batched,
 
 	TP_PROTO(struct page *page, int cold),
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0562d85..2104e23 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -654,7 +654,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	int i;
 	int bad = 0;
 
-	trace_mm_page_free_direct(page, order);
+	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
 
 	if (PageAnon(page))
@@ -1218,7 +1218,7 @@ void free_hot_cold_page_list(struct list_head *list, int cold)
 	struct page *page, *next;
 
 	list_for_each_entry_safe(page, next, list, lru) {
-		trace_mm_pagevec_free(page, cold);
+		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page(page, cold);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
