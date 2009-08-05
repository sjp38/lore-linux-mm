Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8D316B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 03:41:25 -0400 (EDT)
Date: Wed, 5 Aug 2009 09:41:03 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090805074103.GD19322@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org> <4A787D84.2030207@redhat.com> <20090804121332.46df33a7.akpm@linux-foundation.org> <20090804204857.GA32092@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090804204857.GA32092@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

[...]
> > Is there a plan to add the rest later on?
> 
> Depending on how this goes, I will attempt to do a similar set of 
> trace points for tracking kswapd and direct reclaim with the view 
> to identifying when stalls occur due to reclaim, when lumpy 
> reclaim is kicking in, how long it's taken and how often is 
> succeeds/fails.
> 
> > Or are these nine more a proof-of-concept demonstration-code 
> > thing?  If so, is it expected that developers will do an ad-hoc 
> > copy-n-paste to solve a particular short-term problem and will 
> > then toss the tracepoint away?  I guess that could be useful, 
> > although you can do the same with vmstat.
> 
> Adding and deleting tracepoints, rebuilding and rebooting the 
> kernel is obviously usable by developers but not a whole pile of 
> use if recompiling the kernel is not an option or you're trying to 
> debug a difficult-to-reproduce-but-is-happening-now type of 
> problem.
> 
> Of the CC list, I believe Larry Woodman has the most experience 
> with these sort of problems in the field so I'm hoping he'll make 
> some sort of comment.

Yes. FYI, Larry's last set of patches (which Andrew essentially 
NAK-ed) can be found attached below.

My general impression is that these things are very clearly useful, 
but that it would also be nice to see a more structured plan about 
what we want to instrument in the MM and what not so that a general 
decision can be made instead of a creeping stream of ad-hoc 
tracepoints with no end in sight.

I.e. have a full cycle set of tracepoints based on a high level 
description - one (incomplete) sub-set i outlined here for example:

  http://lkml.org/lkml/2009/3/24/435

Adding a document about the page allocator and perhaps comment on 
precisely what we want to trace would definitely be useful in 
addressing Andrew's scepticism i think.

I.e. we'd have your patch in the end, but also with some feel-good 
thoughts made about it on a higher level, so that we can be 
reasonably sure that we have a meaningful set of tracepoints.

	Ingo

----- Forwarded message from Larry Woodman <lwoodman@redhat.com> -----

Date: Tue, 21 Apr 2009 18:45:15 -0400
From: Larry Woodman <lwoodman@redhat.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com,
	mingo@elte.hu, rostedt@goodmis.org
Subject: [Patch] mm tracepoints update


I've cleaned up the mm tracepoints to track page allocation and
freeing, various types of pagefaults and unmaps, and critical page
reclamation routines.  This is useful for debugging memory allocation
issues and system performance problems under heavy memory loads.


----------------------------------------------------------------------


# tracer: mm
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         pdflush-624   [004]   184.293169: wb_kupdate:
mm_pdflush_kupdate count=3e48
         pdflush-624   [004]   184.293439: get_page_from_freelist:
mm_page_allocation pfn=447c27 zone_free=1940910
        events/6-33    [006]   184.962879: free_hot_cold_page:
mm_page_free pfn=44bba9
      irqbalance-8313  [001]   188.042951: unmap_vmas:
mm_anon_userfree mm=ffff88044a7300c0 address=7f9a2eb70000 pfn=24c29a
             cat-9122  [005]   191.141173: filemap_fault:
mm_filemap_fault primary fault: mm=ffff88024c9d8f40 address=3cea2dd000
pfn=44d68e
             cat-9122  [001]   191.143036: handle_mm_fault:
mm_anon_fault mm=ffff88024c8beb40 address=7fffbde99f94 pfn=24ce22
-------------------------------------------------------------------------

Signed-off-by: Larry Woodman <lwoodman@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>


The patch applies to ingo's latest tip tree:



>From 7189889a6978d9fe46a803c94ae7a1d700bdf2ef Mon Sep 17 00:00:00 2001
From: lwoodman <lwoodman@dhcp-100-19-50.bos.redhat.com>
Date: Tue, 21 Apr 2009 14:34:35 -0400
Subject: [PATCH] Merge mm tracepoints into upstream tip tree.

---
 include/trace/events/mm.h |  510 +++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c              |    4 +
 mm/memory.c               |   24 ++-
 mm/page-writeback.c       |    4 +
 mm/page_alloc.c           |    8 +-
 mm/rmap.c                 |    4 +
 mm/vmscan.c               |   17 ++-
 7 files changed, 564 insertions(+), 7 deletions(-)
 create mode 100644 include/trace/events/mm.h

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
new file mode 100644
index 0000000..ca959f6
--- /dev/null
+++ b/include/trace/events/mm.h
@@ -0,0 +1,510 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/mm.h>
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+TRACE_EVENT(mm_anon_fault,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+);
+
+TRACE_EVENT(mm_anon_pgin,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_anon_cow,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_anon_userfree,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_anon_unmap,
+
+	TP_PROTO(unsigned long pfn, int success),
+
+	TP_ARGS(pfn, success),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, success)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->success = success;
+	),
+
+	TP_printk("%s: pfn=%lx",
+		__entry->success ? "succeeded" : "failed", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_filemap_fault,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address,
+			unsigned long pfn, int flag),
+	TP_ARGS(mm, address, pfn, flag),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+		__field(int, flag)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+		__entry->flag = flag;
+	),
+
+	TP_printk("%s: mm=%lx address=%lx pfn=%lx",
+		__entry->flag ? "pagein" : "primary fault",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_filemap_cow,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_filemap_unmap,
+
+	TP_PROTO(unsigned long pfn, int success),
+
+	TP_ARGS(pfn, success),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, success)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->success = success;
+	),
+
+	TP_printk("%s: pfn=%lx",
+		__entry->success ? "succeeded" : "failed", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_filemap_userunmap,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address, unsigned long pfn),
+
+	TP_ARGS(mm, address, pfn),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("mm=%lx address=%lx pfn=%lx",
+		(unsigned long)__entry->mm, __entry->address, __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pagereclaim_pgout,
+
+	TP_PROTO(unsigned long pfn, int anon),
+
+	TP_ARGS(pfn, anon),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, anon)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->anon = anon;
+	),
+
+	TP_printk("%s: pfn=%lx",
+		__entry->anon ? "anonymous" : "pagecache", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pagereclaim_free,
+
+	TP_PROTO(unsigned long pfn, int anon),
+
+	TP_ARGS(pfn, anon),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, anon)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->anon = anon;
+	),
+
+	TP_printk("%s: pfn=%lx",
+		__entry->anon ? "anonymous" : "pagecache", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pdflush_bgwriteout,
+
+	TP_PROTO(unsigned long count),
+
+	TP_ARGS(count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, count)
+	),
+
+	TP_fast_assign(
+		__entry->count = count;
+	),
+
+	TP_printk("count=%lx", __entry->count)
+	);
+
+TRACE_EVENT(mm_pdflush_kupdate,
+
+	TP_PROTO(unsigned long count),
+
+	TP_ARGS(count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, count)
+	),
+
+	TP_fast_assign(
+		__entry->count = count;
+	),
+
+	TP_printk("count=%lx", __entry->count)
+	);
+
+TRACE_EVENT(mm_page_allocation,
+
+	TP_PROTO(unsigned long pfn, unsigned long free),
+
+	TP_ARGS(pfn, free),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned long, free)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->free = free;
+	),
+
+	TP_printk("pfn=%lx zone_free=%ld", __entry->pfn, __entry->free)
+	);
+
+TRACE_EVENT(mm_kswapd_runs,
+
+	TP_PROTO(unsigned long reclaimed),
+
+	TP_ARGS(reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->reclaimed = reclaimed;
+	),
+
+	TP_printk("reclaimed=%lx", __entry->reclaimed)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimall,
+
+	TP_PROTO(unsigned long priority),
+
+	TP_ARGS(priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->priority = priority;
+	),
+
+	TP_printk("priority=%lx", __entry->priority)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimzone,
+
+	TP_PROTO(unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("reclaimed=%lx, priority=%lx",
+			__entry->reclaimed, __entry->priority)
+	);
+TRACE_EVENT(mm_pagereclaim_shrinkzone,
+
+	TP_PROTO(unsigned long reclaimed),
+
+	TP_ARGS(reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->reclaimed = reclaimed;
+	),
+
+	TP_printk("reclaimed=%lx", __entry->reclaimed)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkactive,
+
+	TP_PROTO(unsigned long scanned, int file, int priority),
+
+	TP_ARGS(scanned, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("scanned=%lx, %s, priority=%d",
+		__entry->scanned, __entry->file ? "anonymous" : "pagecache",
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkactive_a2a,
+
+	TP_PROTO(unsigned long pfn),
+
+	TP_ARGS(pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("pfn=%lx", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkactive_a2i,
+
+	TP_PROTO(unsigned long pfn),
+
+	TP_ARGS(pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("pfn=%lx", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive,
+
+	TP_PROTO(unsigned long scanned, int file, int priority),
+
+	TP_ARGS(scanned, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("scanned=%lx, %s, priority=%d",
+		__entry->scanned, __entry->file ? "anonymous" : "pagecache",
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive_i2a,
+
+	TP_PROTO(unsigned long pfn),
+
+	TP_ARGS(pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("pfn=%lx", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive_i2i,
+
+	TP_PROTO(unsigned long pfn),
+
+	TP_ARGS(pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("pfn=%lx", __entry->pfn)
+	);
+
+TRACE_EVENT(mm_page_free,
+
+	TP_PROTO(unsigned long pfn),
+
+	TP_ARGS(pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+	),
+
+	TP_printk("pfn=%lx", __entry->pfn)
+	);
+
+#endif /* _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..4ff804c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,8 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/ftrace.h>
+#include <trace/events/mm.h>
 #include "internal.h"
 
 /*
@@ -1568,6 +1570,8 @@ retry_find:
 	 */
 	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
 	vmf->page = page;
+	trace_mm_filemap_fault(vma->vm_mm, (unsigned long)vmf->virtual_address,
+			page_to_pfn(page), vmf->flags&FAULT_FLAG_NONLINEAR);
 	return ret | VM_FAULT_LOCKED;
 
 no_cached_page:
diff --git a/mm/memory.c b/mm/memory.c
index cf6873e..abd28d8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -55,6 +55,7 @@
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/ftrace.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -64,6 +65,8 @@
 
 #include "internal.h"
 
+#include <trace/events/mm.h>
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -812,15 +815,19 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
-			if (PageAnon(page))
+			if (PageAnon(page)) {
 				anon_rss--;
-			else {
+				trace_mm_anon_userfree(mm, addr,
+							page_to_pfn(page));
+			} else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
 				file_rss--;
+				trace_mm_filemap_userunmap(mm, addr,
+							page_to_pfn(page));
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -1896,7 +1903,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		spinlock_t *ptl, pte_t orig_pte)
 {
-	struct page *old_page, *new_page;
+	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int reuse = 0, ret = 0;
 	int page_mkwrite = 0;
@@ -2039,9 +2046,14 @@ gotten:
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
+				trace_mm_filemap_cow(mm, address,
+					page_to_pfn(new_page));
 			}
-		} else
+		} else {
 			inc_mm_counter(mm, anon_rss);
+			trace_mm_anon_cow(mm, address,
+					page_to_pfn(new_page));
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2416,7 +2428,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		int write_access, pte_t orig_pte)
 {
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page = NULL;
 	swp_entry_t entry;
 	pte_t pte;
 	struct mem_cgroup *ptr = NULL;
@@ -2517,6 +2529,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
+	trace_mm_anon_pgin(mm, address, page_to_pfn(page));
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge_swapin(ptr);
@@ -2549,6 +2562,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto oom;
 	__SetPageUptodate(page);
 
+	trace_mm_anon_fault(mm, address, page_to_pfn(page));
 	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 30351f0..122cad4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,8 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/ftrace.h>
+#include <trace/events/mm.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -716,6 +718,7 @@ static void background_writeout(unsigned long _min_pages)
 				break;
 		}
 	}
+	trace_mm_pdflush_bgwriteout(_min_pages);
 }
 
 /*
@@ -776,6 +779,7 @@ static void wb_kupdate(unsigned long arg)
 	nr_to_write = global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
+	trace_mm_pdflush_kupdate(nr_to_write);
 	while (nr_to_write > 0) {
 		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a3df888..5c175fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -47,6 +47,8 @@
 #include <linux/page-isolation.h>
 #include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
+#include <linux/ftrace.h>
+#include <trace/events/mm.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1007,6 +1009,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 	if (free_pages_check(page))
 		return;
 
+	trace_mm_page_free(page_to_pfn(page));
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
 		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
@@ -1450,8 +1453,11 @@ zonelist_scan:
 		}
 
 		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
-		if (page)
+		if (page) {
+			trace_mm_page_allocation(page_to_pfn(page),
+					zone_page_state(zone, NR_FREE_PAGES));
 			break;
+		}
 this_zone_full:
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);
diff --git a/mm/rmap.c b/mm/rmap.c
index 1652166..ae8882b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -50,6 +50,8 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/ftrace.h>
+#include <trace/events/mm.h>
 
 #include <asm/tlbflush.h>
 
@@ -1034,6 +1036,7 @@ static int try_to_unmap_anon(struct page *page, int unlock, int migration)
 	else if (ret == SWAP_MLOCK)
 		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
 
+	trace_mm_anon_unmap(page_to_pfn(page), ret == SWAP_SUCCESS);
 	return ret;
 }
 
@@ -1170,6 +1173,7 @@ out:
 		ret = SWAP_MLOCK;	/* actually mlocked the page */
 	else if (ret == SWAP_MLOCK)
 		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
+	trace_mm_filemap_unmap(page_to_pfn(page), ret == SWAP_SUCCESS);
 	return ret;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 99155b7..cc73c89 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,9 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/ftrace.h>
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -414,6 +417,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		trace_mm_pagereclaim_pgout(page_to_pfn(page), PageAnon(page));
 		return PAGE_SUCCESS;
 	}
 
@@ -765,6 +769,7 @@ free_it:
 			__pagevec_free(&freed_pvec);
 			pagevec_reinit(&freed_pvec);
 		}
+		trace_mm_pagereclaim_free(page_to_pfn(page), PageAnon(page));
 		continue;
 
 cull_mlocked:
@@ -781,10 +786,12 @@ activate_locked:
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
 		pgactivate++;
+		trace_mm_pagereclaim_shrinkinactive_i2a(page_to_pfn(page));
 keep_locked:
 		unlock_page(page);
 keep:
 		list_add(&page->lru, &ret_pages);
+		trace_mm_pagereclaim_shrinkinactive_i2i(page_to_pfn(page));
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 	list_splice(&ret_pages, page_list);
@@ -1177,6 +1184,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 done:
 	local_irq_enable();
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkinactive(nr_reclaimed, file, priority);
 	return nr_reclaimed;
 }
 
@@ -1254,6 +1262,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
 		if (unlikely(!page_evictable(page, NULL))) {
 			putback_lru_page(page);
+			trace_mm_pagereclaim_shrinkactive_a2a(page_to_pfn(page));
 			continue;
 		}
 
@@ -1263,6 +1272,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			pgmoved++;
 
 		list_add(&page->lru, &l_inactive);
+		trace_mm_pagereclaim_shrinkactive_a2i(page_to_pfn(page));
 	}
 
 	/*
@@ -1311,6 +1321,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkactive(pgscanned, file, priority);
 }
 
 static int inactive_anon_is_low_global(struct zone *zone)
@@ -1511,6 +1522,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	}
 
 	sc->nr_reclaimed = nr_reclaimed;
+	trace_mm_pagereclaim_shrinkzone(nr_reclaimed);
 
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
@@ -1571,6 +1583,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 							priority);
 		}
 
+		trace_mm_directreclaim_reclaimall(priority);
 		shrink_zone(priority, zone, sc);
 	}
 }
@@ -1942,6 +1955,7 @@ out:
 		goto loop_again;
 	}
 
+	trace_mm_kswapd_runs(sc.nr_reclaimed);
 	return sc.nr_reclaimed;
 }
 
@@ -2294,7 +2308,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
+	int priority = ZONE_RECLAIM_PRIORITY;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2360,6 +2374,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	trace_mm_directreclaim_reclaimzone(sc.nr_reclaimed, priority);
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
