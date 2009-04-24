Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EFF5A6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 16:48:19 -0400 (EDT)
Subject: Re: [Patch] mm tracepoints update - use case.
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <1240487231.4682.27.camel@dhcp47-138.lab.bos.redhat.com>
References: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com>
	 <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com>
	 <20090423092933.F6E9.A69D9226@jp.fujitsu.com>
	 <20090422215055.5be60685.akpm@linux-foundation.org>
	 <20090423084233.GF599@elte.hu>
	 <1240487231.4682.27.camel@dhcp47-138.lab.bos.redhat.com>
Content-Type: multipart/mixed; boundary="=-Em/WKQtCi3AckPJ3q7f5"
Date: Fri, 24 Apr 2009 16:48:25 -0400
Message-Id: <1240606105.11613.95.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?Q?Fr=E9=A6=98=E9=A7=BBic?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>


--=-Em/WKQtCi3AckPJ3q7f5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2009-04-23 at 07:47 -0400, Larry Woodman wrote:
> On Thu, 2009-04-23 at 10:42 +0200, Ingo Molnar wrote:

> > 
> > A balanced number of MM tracepoints, showing the concepts and the 
> > inner dynamics of the MM would be useful. We dont need every little 
> > detail traced (we have the function tracer for that), but a few key 
> > aspects would be nice to capture ...
> 
> I hear you, there is  lot of data coming out of these mm tracepoints as
> well as must of the other tracepoints I've played around with, we have
> to filter them.  I added them in locations that would allow us to debug
> a variety of real running systems such as a Wall St. trading server
> during the heaviest period of the day without rebooting a debug kernel.
> We can collect whatever is needed to figure out whats happening then
> turning it all off when we've collected enough.  We've seen systems
> experiencing performance problems caused by the "inner'ds" of the page
> reclaim code, memory leak problems cause by applications, excessive COW
> faults caused by applications that mmap() gigs of files then fork and
> applications that rely the kernel to flush out every modified page of
> those gigs of mmap()'d file data every 30 seconds via kupdate because
> other kernel do. The list goes on and on...  These tracepoints are in
> the same locations that we've placed debug code in debug kernels in the
> past.
> 
> Larry
> 
 
> > 
> > pagefaults, allocations, cache-misses, cache flushes and how pages 
> > shift between various queues in the MM would be a good start IMHO.
> > 
> > Anyway, i suspect your answer means a NAK :-( Would be nice if you 
> > would suggest a path out of that NAK.
> > 
> > 	Ingo
> 


I've overhauled the patch so that all page level tracing has been
removed unless it directly causes page reclamation.  At this point trace
individual pagefaults, unmaps and pageouts.  However, for all page
reclaim paths and writeback paths we now traces quantities of pages
activated, deactivated, written, reclaimed, etc,.  Also we now only
trace individual page allocations that cause further page reclamation to
occur.  This still provides the necessary microscopic level of detail
without tracing the movement of all the pageframes:


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--=-Em/WKQtCi3AckPJ3q7f5
Content-Disposition: attachment; filename=mm-tracepoints.patch
Content-Type: text/x-patch; name=mm-tracepoints.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
new file mode 100644
index 0000000..6b1c114
--- /dev/null
+++ b/include/trace/events/mm.h
@@ -0,0 +1,436 @@
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
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+);
+
+TRACE_EVENT(mm_anon_pgin,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_anon_cow,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_anon_userfree,
+
+	TP_PROTO(struct mm_struct *mm,
+			unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_anon_unmap,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_filemap_fault,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address, int flag),
+	TP_ARGS(mm, address, flag),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+		__field(int, flag)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+		__entry->flag = flag;
+	),
+
+	TP_printk("%s: mm=%lx address=%lx",
+		__entry->flag ? "pagein" : "primary fault",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_filemap_cow,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_filemap_unmap,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_filemap_userunmap,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%lx address=%lx",
+		(unsigned long)__entry->mm, __entry->address)
+	);
+
+TRACE_EVENT(mm_pagereclaim_pgout,
+
+	TP_PROTO(struct address_space *mapping, unsigned long offset, int anon),
+
+	TP_ARGS(mapping, offset, anon),
+
+	TP_STRUCT__entry(
+		__field(struct address_space *, mapping)
+		__field(unsigned long, offset)
+		__field(int, anon)
+	),
+
+	TP_fast_assign(
+		__entry->mapping = mapping;
+		__entry->offset = offset;
+		__entry->anon = anon;
+	),
+
+	TP_printk("mapping=%lx, offset=%lx %s",
+		(unsigned long)__entry->mapping, __entry->offset, 
+			__entry->anon ? "anonymous" : "pagecache")
+	);
+
+TRACE_EVENT(mm_pagereclaim_free,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, nr_reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->nr_reclaimed = nr_reclaimed;
+	),
+
+	TP_printk("freed=%ld", __entry->nr_reclaimed)
+	);
+
+TRACE_EVENT(mm_pdflush_bgwriteout,
+
+	TP_PROTO(unsigned long written),
+
+	TP_ARGS(written),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, written)
+	),
+
+	TP_fast_assign(
+		__entry->written = written;
+	),
+
+	TP_printk("written=%ld", __entry->written)
+	);
+
+TRACE_EVENT(mm_pdflush_kupdate,
+
+	TP_PROTO(unsigned long writes),
+
+	TP_ARGS(writes),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, writes)
+	),
+
+	TP_fast_assign(
+		__entry->writes = writes;
+	),
+
+	TP_printk("writes=%ld", __entry->writes)
+	);
+
+TRACE_EVENT(mm_balance_dirty,
+
+	TP_PROTO(unsigned long written),
+
+	TP_ARGS(written),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, written)
+	),
+
+	TP_fast_assign(
+		__entry->written = written;
+	),
+
+	TP_printk("written=%ld", __entry->written)
+	);
+
+TRACE_EVENT(mm_page_allocation,
+
+	TP_PROTO(unsigned long free),
+
+	TP_ARGS(free),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, free)
+	),
+
+	TP_fast_assign(
+		__entry->free = free;
+	),
+
+	TP_printk("zone_free=%ld", __entry->free)
+	);
+
+TRACE_EVENT(mm_kswapd_ran,
+
+	TP_PROTO(struct pglist_data *pgdat, unsigned long reclaimed),
+
+	TP_ARGS(pgdat, reclaimed),
+
+	TP_STRUCT__entry(
+		__field(struct pglist_data *, pgdat)
+		__field(int, node_id)
+		__field(unsigned long, reclaimed)
+	),
+
+	TP_fast_assign(
+		__entry->pgdat = pgdat;
+		__entry->node_id = pgdat->node_id;
+		__entry->reclaimed = reclaimed;
+	),
+
+	TP_printk("node=%d reclaimed=%ld", __entry->node_id, __entry->reclaimed)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimall,
+
+	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(node, reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(int, node)
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->node = node;
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("node=%d reclaimed=%ld priority=%ld", __entry->node, __entry->reclaimed, 
+					__entry->priority)
+	);
+
+TRACE_EVENT(mm_directreclaim_reclaimzone,
+
+	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
+
+	TP_ARGS(node, reclaimed, priority),
+
+	TP_STRUCT__entry(
+		__field(int, node)
+		__field(unsigned long, reclaimed)
+		__field(unsigned long, priority)
+	),
+
+	TP_fast_assign(
+		__entry->node = node;
+		__entry->reclaimed = reclaimed;
+		__entry->priority = priority;
+	),
+
+	TP_printk("node = %d reclaimed=%ld, priority=%ld",
+			__entry->node, __entry->reclaimed, __entry->priority)
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
+	TP_printk("reclaimed=%ld", __entry->reclaimed)
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
+	TP_printk("scanned=%ld, %s, priority=%d",
+		__entry->scanned, __entry->file ? "pagecache" : "anonymous",
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive,
+
+	TP_PROTO(unsigned long scanned, unsigned long reclaimed,
+			int file, int priority),
+
+	TP_ARGS(scanned, reclaimed, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(unsigned long, reclaimed)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->reclaimed = reclaimed;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("scanned=%ld, reclaimed=%ld %s, priority=%d",
+		__entry->scanned, __entry->reclaimed, 
+		__entry->file ? "pagecache" : "anonymous",
+		__entry->priority)
+	);
+
+#endif /* _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..c4424ed 100644
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
+			vmf->flags&FAULT_FLAG_NONLINEAR);
 	return ret | VM_FAULT_LOCKED;
 
 no_cached_page:
diff --git a/mm/memory.c b/mm/memory.c
index cf6873e..27f5e0b 100644
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
@@ -812,15 +815,17 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
-			if (PageAnon(page))
+			if (PageAnon(page)) {
 				anon_rss--;
-			else {
+				trace_mm_anon_userfree(mm, addr);
+			} else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
 				file_rss--;
+				trace_mm_filemap_userunmap(mm, addr);
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -1896,7 +1901,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		spinlock_t *ptl, pte_t orig_pte)
 {
-	struct page *old_page, *new_page;
+	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int reuse = 0, ret = 0;
 	int page_mkwrite = 0;
@@ -2039,9 +2044,12 @@ gotten:
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
+				trace_mm_filemap_cow(mm, address);
 			}
-		} else
+		} else {
 			inc_mm_counter(mm, anon_rss);
+			trace_mm_anon_cow(mm, address);
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2416,7 +2424,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		int write_access, pte_t orig_pte)
 {
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page = NULL;
 	swp_entry_t entry;
 	pte_t pte;
 	struct mem_cgroup *ptr = NULL;
@@ -2517,6 +2525,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
+	trace_mm_anon_pgin(mm, address);
 	return ret;
 out_nomap:
 	mem_cgroup_cancel_charge_swapin(ptr);
@@ -2549,6 +2558,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto oom;
 	__SetPageUptodate(page);
 
+	trace_mm_anon_fault(mm, address);
 	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
 		goto oom_free_page;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 30351f0..a3d469c 100644
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
@@ -574,6 +576,7 @@ static void balance_dirty_pages(struct address_space *mapping)
 		congestion_wait(WRITE, HZ/10);
 	}
 
+	trace_mm_balance_dirty(pages_written);
 	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
 			bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
@@ -716,6 +719,7 @@ static void background_writeout(unsigned long _min_pages)
 				break;
 		}
 	}
+	trace_mm_pdflush_bgwriteout(_min_pages);
 }
 
 /*
@@ -776,6 +780,7 @@ static void wb_kupdate(unsigned long arg)
 	nr_to_write = global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
+	trace_mm_pdflush_kupdate(nr_to_write);
 	while (nr_to_write > 0) {
 		wbc.more_io = 0;
 		wbc.encountered_congestion = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a3df888..73576cf 100644
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
@@ -1443,6 +1445,7 @@ zonelist_scan:
 				mark = zone->pages_high;
 			if (!zone_watermark_ok(zone, order, mark,
 				    classzone_idx, alloc_flags)) {
+				trace_mm_page_allocation(zone_page_state(zone, NR_FREE_PAGES));
 				if (!zone_reclaim_mode ||
 				    !zone_reclaim(zone, gfp_mask, order))
 					goto this_zone_full;
diff --git a/mm/rmap.c b/mm/rmap.c
index 1652166..8f2b43f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -50,6 +50,8 @@
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
 #include <linux/migrate.h>
+#include <linux/ftrace.h>
+#include <trace/events/mm.h>
 
 #include <asm/tlbflush.h>
 
@@ -1025,6 +1027,7 @@ static int try_to_unmap_anon(struct page *page, int unlock, int migration)
 			if (mlocked)
 				break;	/* stop if actually mlocked page */
 		}
+		trace_mm_anon_unmap(vma->vm_mm, vma->vm_start+page->index);
 	}
 
 	page_unlock_anon_vma(anon_vma);
@@ -1152,6 +1155,7 @@ static int try_to_unmap_file(struct page *page, int unlock, int migration)
 					goto out;
 			}
 			vma->vm_private_data = (void *) max_nl_cursor;
+			trace_mm_filemap_unmap(vma->vm_mm, vma->vm_start+page->index);
 		}
 		cond_resched_lock(&mapping->i_mmap_lock);
 		max_nl_cursor += CLUSTER_SIZE;
@@ -1170,6 +1174,7 @@ out:
 		ret = SWAP_MLOCK;	/* actually mlocked the page */
 	else if (ret == SWAP_MLOCK)
 		ret = SWAP_AGAIN;	/* saw VM_LOCKED vma */
+
 	return ret;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eac9577..6f3a543 100644
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
@@ -417,6 +420,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT,
+						PageAnon(page));
 		return PAGE_SUCCESS;
 	}
 
@@ -794,6 +799,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	trace_mm_pagereclaim_free(nr_reclaimed);
 	return nr_reclaimed;
 }
 
@@ -1180,6 +1186,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 done:
 	local_irq_enable();
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkinactive(nr_scanned, nr_reclaimed,
+				file, priority);
 	return nr_reclaimed;
 }
 
@@ -1314,6 +1322,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkactive(pgscanned, file, priority);
 }
 
 static int inactive_anon_is_low_global(struct zone *zone)
@@ -1514,6 +1523,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	}
 
 	sc->nr_reclaimed = nr_reclaimed;
+	trace_mm_pagereclaim_shrinkzone(nr_reclaimed);
 
 	/*
 	 * Even if we did not try to evict anon pages at all, we want to
@@ -1676,6 +1686,8 @@ out:
 	if (priority < 0)
 		priority = 0;
 
+	trace_mm_directreclaim_reclaimall(zonelist[0]._zonerefs->zone->node,
+						sc->nr_reclaimed, priority);
 	if (scanning_global_lru(sc)) {
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 
@@ -1945,6 +1957,7 @@ out:
 		goto loop_again;
 	}
 
+	trace_mm_kswapd_ran(pgdat, sc.nr_reclaimed);
 	return sc.nr_reclaimed;
 }
 
@@ -2297,7 +2310,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
+	int priority = ZONE_RECLAIM_PRIORITY;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2364,6 +2377,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
+	trace_mm_directreclaim_reclaimzone(zone->node,
+				sc.nr_reclaimed, priority);
 	return sc.nr_reclaimed >= nr_pages;
 }
 

--=-Em/WKQtCi3AckPJ3q7f5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
