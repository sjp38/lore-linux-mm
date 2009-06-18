Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 520446B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 03:56:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5I7vuhg022609
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Jun 2009 16:57:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 87BC145DE70
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:57:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BCED45DE6F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:57:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06CC8E08003
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:57:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92033E0800A
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:57:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Patch] mm tracepoints update - use case.
In-Reply-To: <4A36925D.4090000@redhat.com>
References: <20090423092933.F6E9.A69D9226@jp.fujitsu.com> <4A36925D.4090000@redhat.com>
Message-Id: <20090616170811.99A6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Jun 2009 16:57:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

Hi

sorry for the delaying in replay.
your question is always difficult...


> KOSAKI Motohiro wrote:
> >> On Wed, 2009-04-22 at 08:07 -0400, Larry Woodman wrote:
> 
> >> Attached is an example of what the mm tracepoints can be used for:
> > 
> > I have some comment.
> > 
> > 1. Yes, current zone_reclaim have strange behavior. I plan to fix
> >    some bug-like bahavior.
> > 2. your scenario only use the information of "zone_reclaim called".
> >    function tracer already provide it.
> > 3. but yes, you are going to proper direction. we definitely need
> >    some fine grained tracepoint in this area. we are welcome to you.
> >    but in my personal feeling, your tracepoint have worthless argument
> >    a lot. we need more good information.
> >    I think I can help you in this area. I hope to work together.
> 
> Sorry I am replying to a really old email, but exactly
> what information do you believe would be more useful to
> extract from vmscan.c with tracepoints?
> 
> What are the kinds of problems that customer systems
> (which cannot be rebooted into experimental kernels)
> run into, that can be tracked down with tracepoints?
> 
> I can think of a few:
> - excessive CPU use in page reclaim code
> - excessive reclaim latency in page reclaim code
> - unbalanced memory allocation between zones/nodes
> - strange balance problems between reclaiming of page
>    cache and swapping out process pages
> 
> I suspect we would need fairly fine grained tracepoints
> to track down these kinds of problems, with filtering
> and/or interpretation in userspace, but I am always
> interested in easier ways of tracking down these kinds
> of problems :)
> 
> What kinds of tracepoints do you believe we would need?
> 
> Or, using Larry's patch as a starting point, what do you
> believe should be changed?

OK, I recognize we need use-case discussion more.
following scenario are my freqently received issue list.
(perhaps, there are unwritten issue, but I don't recall it now)

Scenario 1. OOM killer happend. why? and who bring it?
Scenario 2. page allocation failure by memory fragmentation
Scenario 3. try_to_free_pages() makes very long latency. why?
Scenario 4. sar output that free memory dramatically reduced at 10 minute ago, and
            it already recover now. What's happen?

  - suspects
    - kernel memory leak
    - userland memory leak
    - stupid driver use too much memory
    - userland application suddenly start to use much memory

  - what information are valuable?
    - slab usage information (kmemtrace already does)
    - page allocator usage information
    - rss of all processes at oom happend
    - why recent try_to_free_pages() can't reclaim any page?
    - recent sycall history
    - buddy fragmentation info


Plus, another requirement here
1. trace page refault distance (likes past Rik's /proc/refault patch)

2. file cache visualizer - Which file use many page-cache?
   - afaik, Wu Fengguang is working on this issue.


--------------------------------------------
And, here is my reviewing comment to his patch.
btw, I haven't full review it yet. perhaps I might be overlooking something.


First, this is general review comment.

- Please don't display mm and/or another kernel raw pointer.
  if we assume non stop system, we can't use kernel-dump. Thus kernel pointer
  logging is not so useful.
  Any userland tools can't parse it. (/proc/kcore don't help this situation,
  the pointer might be freed before parsing)
- Please makes patch series. one big patch is harder review.
- Please write patch description and use-case.
- Please consider how do this feature works on mem-cgroup.
  (IOW, please don't ignore many "if (scanning_global_lru())")
- tracepoint caller shouldn't have any assumption of displaying representation.
  e.g.
    wrong)  trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT, PageAnon(page));
    good)   trace_mm_pagereclaim_pgout(mapping, page)
  that's general and good callback and/or hook manner.




> diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
> new file mode 100644
> index 0000000..1d888a4
> --- /dev/null
> +++ b/include/trace/events/mm.h
> @@ -0,0 +1,436 @@
> +#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_MM_H
> +
> +#include <linux/mm.h>
> +#include <linux/tracepoint.h>
> +
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM mm
> +
> +TRACE_EVENT(mm_anon_fault,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +);
> +
> +TRACE_EVENT(mm_anon_pgin,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_anon_cow,
> +
> +	TP_PROTO(struct mm_struct *mm,
> +			unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_anon_userfree,
> +
> +	TP_PROTO(struct mm_struct *mm,
> +			unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_anon_unmap,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_filemap_fault,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address, int flag),
> +	TP_ARGS(mm, address, flag),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +		__field(int, flag)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +		__entry->flag = flag;
> +	),
> +
> +	TP_printk("%s: mm=%lx address=%lx",
> +		__entry->flag ? "pagein" : "primary fault",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_filemap_cow,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_filemap_unmap,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_filemap_userunmap,
> +
> +	TP_PROTO(struct mm_struct *mm, unsigned long address),
> +
> +	TP_ARGS(mm, address),
> +
> +	TP_STRUCT__entry(
> +		__field(struct mm_struct *, mm)
> +		__field(unsigned long, address)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mm = mm;
> +		__entry->address = address;
> +	),
> +
> +	TP_printk("mm=%lx address=%lx",
> +		(unsigned long)__entry->mm, __entry->address)
> +	);
> +
> +TRACE_EVENT(mm_pagereclaim_pgout,
> +
> +	TP_PROTO(struct address_space *mapping, unsigned long offset, int anon),
> +
> +	TP_ARGS(mapping, offset, anon),
> +
> +	TP_STRUCT__entry(
> +		__field(struct address_space *, mapping)
> +		__field(unsigned long, offset)
> +		__field(int, anon)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->mapping = mapping;
> +		__entry->offset = offset;
> +		__entry->anon = anon;
> +	),
> +
> +	TP_printk("mapping=%lx, offset=%lx %s",
> +		(unsigned long)__entry->mapping, __entry->offset, 
> +			__entry->anon ? "anonymous" : "pagecache")
> +	);
> +
> +TRACE_EVENT(mm_pagereclaim_free,
> +
> +	TP_PROTO(unsigned long nr_reclaimed),
> +
> +	TP_ARGS(nr_reclaimed),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, nr_reclaimed)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nr_reclaimed = nr_reclaimed;
> +	),
> +
> +	TP_printk("freed=%ld", __entry->nr_reclaimed)
> +	);
> +
> +TRACE_EVENT(mm_pdflush_bgwriteout,
> +
> +	TP_PROTO(unsigned long written),
> +
> +	TP_ARGS(written),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, written)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->written = written;
> +	),
> +
> +	TP_printk("written=%ld", __entry->written)
> +	);
> +
> +TRACE_EVENT(mm_pdflush_kupdate,
> +
> +	TP_PROTO(unsigned long writes),
> +
> +	TP_ARGS(writes),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, writes)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->writes = writes;
> +	),
> +
> +	TP_printk("writes=%ld", __entry->writes)
> +	);
> +
> +TRACE_EVENT(mm_balance_dirty,
> +
> +	TP_PROTO(unsigned long written),
> +
> +	TP_ARGS(written),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, written)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->written = written;
> +	),
> +
> +	TP_printk("written=%ld", __entry->written)
> +	);
> +
> +TRACE_EVENT(mm_page_allocation,
> +
> +	TP_PROTO(unsigned long free),
> +
> +	TP_ARGS(free),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, free)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->free = free;
> +	),
> +
> +	TP_printk("zone_free=%ld", __entry->free)
> +	);
> +
> +TRACE_EVENT(mm_kswapd_ran,
> +
> +	TP_PROTO(struct pglist_data *pgdat, unsigned long reclaimed),
> +
> +	TP_ARGS(pgdat, reclaimed),
> +
> +	TP_STRUCT__entry(
> +		__field(struct pglist_data *, pgdat)
> +		__field(int, node_id)
> +		__field(unsigned long, reclaimed)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pgdat = pgdat;
> +		__entry->node_id = pgdat->node_id;
> +		__entry->reclaimed = reclaimed;
> +	),
> +
> +	TP_printk("node=%d reclaimed=%ld", __entry->node_id, __entry->reclaimed)
> +	);
> +
> +TRACE_EVENT(mm_directreclaim_reclaimall,
> +
> +	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
> +
> +	TP_ARGS(node, reclaimed, priority),
> +
> +	TP_STRUCT__entry(
> +		__field(int, node)
> +		__field(unsigned long, reclaimed)
> +		__field(unsigned long, priority)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->node = node;
> +		__entry->reclaimed = reclaimed;
> +		__entry->priority = priority;
> +	),
> +
> +	TP_printk("node=%d reclaimed=%ld priority=%ld", __entry->node, __entry->reclaimed, 
> +					__entry->priority)
> +	);
> +
> +TRACE_EVENT(mm_directreclaim_reclaimzone,
> +
> +	TP_PROTO(int node, unsigned long reclaimed, unsigned long priority),
> +
> +	TP_ARGS(node, reclaimed, priority),
> +
> +	TP_STRUCT__entry(
> +		__field(int, node)
> +		__field(unsigned long, reclaimed)
> +		__field(unsigned long, priority)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->node = node;
> +		__entry->reclaimed = reclaimed;
> +		__entry->priority = priority;
> +	),
> +
> +	TP_printk("node = %d reclaimed=%ld, priority=%ld",
> +			__entry->node, __entry->reclaimed, __entry->priority)
> +	);
> +TRACE_EVENT(mm_pagereclaim_shrinkzone,
> +
> +	TP_PROTO(unsigned long reclaimed, unsigned long priority),
> +
> +	TP_ARGS(reclaimed, priority),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, reclaimed)
> +		__field(unsigned long, priority)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->reclaimed = reclaimed;
> +		__entry->priority = priority;
> +	),
> +
> +	TP_printk("reclaimed=%ld priority=%ld",
> +			__entry->reclaimed, __entry->priority)
> +	);
> +
> +TRACE_EVENT(mm_pagereclaim_shrinkactive,
> +
> +	TP_PROTO(unsigned long scanned, int file, int priority),
> +
> +	TP_ARGS(scanned, file, priority),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, scanned)
> +		__field(int, file)
> +		__field(int, priority)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->scanned = scanned;
> +		__entry->file = file;
> +		__entry->priority = priority;
> +	),
> +
> +	TP_printk("scanned=%ld, %s, priority=%d",
> +		__entry->scanned, __entry->file ? "pagecache" : "anonymous",
> +		__entry->priority)
> +	);
> +
> +TRACE_EVENT(mm_pagereclaim_shrinkinactive,
> +
> +	TP_PROTO(unsigned long scanned, unsigned long reclaimed,
> +			int priority),
> +
> +	TP_ARGS(scanned, reclaimed, priority),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, scanned)
> +		__field(unsigned long, reclaimed)
> +		__field(int, priority)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->scanned = scanned;
> +		__entry->reclaimed = reclaimed;
> +		__entry->priority = priority;
> +	),
> +
> +	TP_printk("scanned=%ld, reclaimed=%ld, priority=%d",
> +		__entry->scanned, __entry->reclaimed, 
> +		__entry->priority)
> +	);
> +
> +#endif /* _TRACE_MM_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1b60f30..af4a964 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -34,6 +34,7 @@
>  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
>  #include <linux/memcontrol.h>
>  #include <linux/mm_inline.h> /* for page_is_file_cache() */
> +#include <trace/events/mm.h>
>  #include "internal.h"
>  
>  /*
> @@ -1568,6 +1569,8 @@ retry_find:
>  	 */
>  	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
>  	vmf->page = page;
> +	trace_mm_filemap_fault(vma->vm_mm, (unsigned long)vmf->virtual_address,
> +			vmf->flags&FAULT_FLAG_NONLINEAR);
>  	return ret | VM_FAULT_LOCKED;
>
>  no_cached_page:
> diff --git a/mm/memory.c b/mm/memory.c
> index 4126dd1..a4a580c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -61,6 +61,7 @@
>  #include <asm/tlb.h>
>  #include <asm/tlbflush.h>
>  #include <asm/pgtable.h>
> +#include <trace/events/mm.h>
>  
>  #include "internal.h"
>  
> @@ -812,15 +813,17 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  						addr) != page->index)
>  				set_pte_at(mm, addr, pte,
>  					   pgoff_to_pte(page->index));
> -			if (PageAnon(page))
> +			if (PageAnon(page)) {
>  				anon_rss--;
> -			else {
> +				trace_mm_anon_userfree(mm, addr);
> +			} else {
>  				if (pte_dirty(ptent))
>  					set_page_dirty(page);
>  				if (pte_young(ptent) &&
>  				    likely(!VM_SequentialReadHint(vma)))
>  					mark_page_accessed(page);
>  				file_rss--;
> +				trace_mm_filemap_userunmap(mm, addr);
>  			}
>  			page_remove_rmap(page);
>  			if (unlikely(page_mapcount(page) < 0))
> @@ -1896,7 +1899,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pte_t *page_table, pmd_t *pmd,
>  		spinlock_t *ptl, pte_t orig_pte)
>  {
> -	struct page *old_page, *new_page;
> +	struct page *old_page, *new_page = NULL;
>  	pte_t entry;
>  	int reuse = 0, ret = 0;
>  	int page_mkwrite = 0;
> @@ -2050,9 +2053,12 @@ gotten:
>  			if (!PageAnon(old_page)) {
>  				dec_mm_counter(mm, file_rss);
>  				inc_mm_counter(mm, anon_rss);
> +				trace_mm_filemap_cow(mm, address);
>  			}
> -		} else
> +		} else {
>  			inc_mm_counter(mm, anon_rss);
> +			trace_mm_anon_cow(mm, address);
> +		}
>  		flush_cache_page(vma, address, pte_pfn(orig_pte));
>  		entry = mk_pte(new_page, vma->vm_page_prot);
>  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> @@ -2449,7 +2455,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		int write_access, pte_t orig_pte)
>  {
>  	spinlock_t *ptl;
> -	struct page *page;
> +	struct page *page = NULL;
>  	swp_entry_t entry;
>  	pte_t pte;
>  	struct mem_cgroup *ptr = NULL;
> @@ -2549,6 +2555,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  out:
> +	trace_mm_anon_pgin(mm, address);
>  	return ret;
>  out_nomap:
>  	mem_cgroup_cancel_charge_swapin(ptr);

In swapin, you trace "mm" and "virtual address". but in swap-out, you trace "mapping" and
"virtual address".

Oh well, we can't compare swap-in and swap-out log. Please consider to make input and output synmetric.


> @@ -2582,6 +2589,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		goto oom;
>  	__SetPageUptodate(page);
>  
> +	trace_mm_anon_fault(mm, address);
>  	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))
>  		goto oom_free_page;
>  
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index bb553c3..ef92a97 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -34,6 +34,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/buffer_head.h>
>  #include <linux/pagevec.h>
> +#include <trace/events/mm.h>
>  
>  /*
>   * The maximum number of pages to writeout in a single bdflush/kupdate
> @@ -574,6 +575,7 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		congestion_wait(WRITE, HZ/10);
>  	}
>  
> +	trace_mm_balance_dirty(pages_written);

perhaps, you need to explain why this tracepoint is useful.
I haven't use this log on my past debugging.

perhaps, if you only need number of written pages, new vmstat field is
more useful?


>  	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
>  			bdi->dirty_exceeded)
>  		bdi->dirty_exceeded = 0;
> @@ -716,6 +718,7 @@ static void background_writeout(unsigned long _min_pages)
>  				break;
>  		}
>  	}
> +	trace_mm_pdflush_bgwriteout(_min_pages);
>  }

ditto.


>  
>  /*
> @@ -776,6 +779,7 @@ static void wb_kupdate(unsigned long arg)
>  	nr_to_write = global_page_state(NR_FILE_DIRTY) +
>  			global_page_state(NR_UNSTABLE_NFS) +
>  			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
> +	trace_mm_pdflush_kupdate(nr_to_write);
>  	while (nr_to_write > 0) {
>  		wbc.more_io = 0;
>  		wbc.encountered_congestion = 0;

ditto.


> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0727896..ca9355e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -48,6 +48,7 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kmemleak.h>
> +#include <trace/events/mm.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -1440,6 +1441,7 @@ zonelist_scan:
>  				mark = zone->pages_high;
>  			if (!zone_watermark_ok(zone, order, mark,
>  				    classzone_idx, alloc_flags)) {
> +				trace_mm_page_allocation(zone_page_state(zone, NR_FREE_PAGES));
>  				if (!zone_reclaim_mode ||
>  				    !zone_reclaim(zone, gfp_mask, order))
>  					goto this_zone_full;

bad name.
it is not the notification of allocation. 

Plus, this is wrong place too. it doesn't mean allocation failure.

it only mean a zone is not sufficient memory.
However this tracepoint don't have zone argument. then it is totally unuseful.

Plus, NR_FREE_PAGES is not sufficient informantion. the most common reason
of allocation failure is not low NR_FREE_PAGES. it is buddy fragmentation.




> diff --git a/mm/rmap.c b/mm/rmap.c
> index 23122af..f2156ca 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -50,6 +50,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/migrate.h>
> +#include <trace/events/mm.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1025,6 +1026,7 @@ static int try_to_unmap_anon(struct page *page, int unlock, int migration)
>  			if (mlocked)
>  				break;	/* stop if actually mlocked page */
>  		}
> +		trace_mm_anon_unmap(vma->vm_mm, vma->vm_start+page->index);
>  	}
>  
>  	page_unlock_anon_vma(anon_vma);
> @@ -1152,6 +1154,7 @@ static int try_to_unmap_file(struct page *page, int unlock, int migration)
>  					goto out;
>  			}
>  			vma->vm_private_data = (void *) max_nl_cursor;
> +			trace_mm_filemap_unmap(vma->vm_mm, vma->vm_start+page->index);
>  		}
>  		cond_resched_lock(&mapping->i_mmap_lock);
>  		max_nl_cursor += CLUSTER_SIZE;

try_to_unmap() and try_to_unlock() are pretty difference.
maybe, we only need try_to_unmap() case?




> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 95c08a8..bed7125 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -40,6 +40,8 @@
>  #include <linux/memcontrol.h>
>  #include <linux/delayacct.h>
>  #include <linux/sysctl.h>
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/mm.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -417,6 +419,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  			ClearPageReclaim(page);
>  		}
>  		inc_zone_page_state(page, NR_VMSCAN_WRITE);
> +		trace_mm_pagereclaim_pgout(mapping, page->index<<PAGE_SHIFT,
> +						PageAnon(page));

I don't think it this useful information.

for file-mapped)
  [mapping, offset] pair represent which portion is pointed this cache page.
for swa-backed)
  [process, virtual_address] ..


Plus, I have one question. How do we combine this information and blktrace?
if we can't see I/O activity relationship, this is really unuseful.


>  		return PAGE_SUCCESS;
>  	}
>  
> @@ -796,6 +800,7 @@ keep:
>  	if (pagevec_count(&freed_pvec))
>  		__pagevec_free(&freed_pvec);
>  	count_vm_events(PGACTIVATE, pgactivate);
> +	trace_mm_pagereclaim_free(nr_reclaimed);
>  	return nr_reclaimed;
>  }

No.
if administrator only need number of free pages.
/proc/meminfo and /proc/vmstat already provide it.

but I don't think it is sufficient information.
May I ask when do you use this tracepoint? and why?



>  
> @@ -1182,6 +1187,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
>  done:
>  	local_irq_enable();
>  	pagevec_release(&pvec);
> +	trace_mm_pagereclaim_shrinkinactive(nr_scanned, nr_reclaimed,
> +				priority);
>  	return nr_reclaimed;
>  }
>  
> @@ -1316,6 +1323,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	if (buffer_heads_over_limit)
>  		pagevec_strip(&pvec);
>  	pagevec_release(&pvec);
> +	trace_mm_pagereclaim_shrinkactive(pgscanned, file, priority);
>  }
>  
>  static int inactive_anon_is_low_global(struct zone *zone)
> @@ -1516,6 +1524,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  	}
>  
>  	sc->nr_reclaimed = nr_reclaimed;
> +	trace_mm_pagereclaim_shrinkzone(nr_reclaimed, priority);
>  
>  	/*
>  	 * Even if we did not try to evict anon pages at all, we want to
> @@ -1678,6 +1687,8 @@ out:
>  	if (priority < 0)
>  		priority = 0;
>  
> +	trace_mm_directreclaim_reclaimall(zonelist[0]._zonerefs->zone->node,
> +						sc->nr_reclaimed, priority);
>  	if (scanning_global_lru(sc)) {
>  		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
>  

Why do you want to log to node? Why not zone itself?

Plus, Why you ignore try_to_free_pages() latency?



> @@ -1947,6 +1958,7 @@ out:
>  		goto loop_again;
>  	}
>  
> +	trace_mm_kswapd_ran(pgdat, sc.nr_reclaimed);
>  	return sc.nr_reclaimed;
>  }
>  

equal to kswapd_steal field in /proc/vmstat?


> @@ -2299,7 +2311,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	const unsigned long nr_pages = 1 << order;
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
> -	int priority;
> +	int priority = ZONE_RECLAIM_PRIORITY;
>  	struct scan_control sc = {
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>  		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> @@ -2366,6 +2378,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  
>  	p->reclaim_state = NULL;
>  	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
> +	trace_mm_directreclaim_reclaimzone(zone->node,
> +				sc.nr_reclaimed, priority);
>  	return sc.nr_reclaimed >= nr_pages;
>  }

this is _zone_ reclaim. but the code pass node.
Plus, if we consider to log page allocation and reclaim, we shouldn't ignore
gfp_mask.

it cause to change many allocation/reclaim behavior.


----
My current conclusion is, nobody use this patch on his own system.
the patch have many unclear useful tracepoint.

At least, patch splitting is needed for productive discussion.
  e.g.
   - reclaim IO activity tracing
   - memory fragmentation visualizer
   - per i-node page cache visualizer (likes Wu's filecache patch)
   - reclaim failure reason tracing and aggregation ftrace plugin
   - reclaim latency tracing


I'm glad if larry resubmit this effort.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
