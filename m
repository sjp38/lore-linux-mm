Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts40-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080707204359.FEYU1625.tomts40-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 7 Jul 2008 16:43:59 -0400
Date: Mon, 7 Jul 2008 16:38:55 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC patch 05/12] LTTng instrumentation mm
Message-ID: <20080707203855.GA29295@Krystal>
References: <20080704235207.147809973@polymtl.ca> <20080704235425.792630712@polymtl.ca> <20080705173449.98DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20080705173449.98DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Masami Hiramatsu <mhiramat@redhat.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro (kosaki.motohiro@jp.fujitsu.com) wrote:
> > Memory management core events.
> > 
> > Added tracepoints :
> > 
> > mm_filemap_wait_end
> > mm_filemap_wait_start
> > mm_handle_fault_entry
> > mm_handle_fault_exit
> > mm_huge_page_alloc
> > mm_huge_page_free
> > mm_page_alloc
> > mm_page_free
> > mm_swap_file_close
> > mm_swap_file_open
> > mm_swap_in
> > mm_swap_out
> 

Hi Kosaki,

Thanks for this thorough review, please see comments below. Comments
without response will be addressed in the next tracepoint release.

> Mathieu, this patch is too large and have multiple change.
> memory subsystem have some feature and is developed by many people.
> 
> So, nobody can ack it.
> Could you split to more small patch?
> 
> and, this patch description is very poor.
> 
> I guess
> 
> > mm_filemap_wait_end
> > mm_filemap_wait_start
> 	for latency statics by lock_page delay
> 
> 	if so, we should know who have locking.
> 
> 
> > mm_handle_fault_entry
> > mm_handle_fault_exit
> 	??
> 	please explain.
> 
> > mm_page_alloc
> > mm_page_free
> 	for memory leak track
> 	for memory eater sort out
> 	etc..
> 
> > mm_huge_page_alloc
> > mm_huge_page_free
> 	ditto
> 	(but, huge page is developed by another person against normal page alloc
> 	 so, patch separating is better)
> 
> > mm_swap_file_close
> > mm_swap_file_open
> 	??
> 	What do you suppose usage?
> 
> > mm_swap_in
> > mm_swap_out
> 	for swap usage statics
> 	for swap delay accounting
> 
> 
> and, some tracepoint is putted on performance critical function.
> So, you should write performance result in patch description.
> 

Ok, I'll resend a new splitted version with better descriptions.

> 
> > Index: linux-2.6-lttng/mm/filemap.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/filemap.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/filemap.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -33,6 +33,7 @@
> >  #include <linux/cpuset.h>
> >  #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
> >  #include <linux/memcontrol.h>
> > +#include "mm-trace.h"
> >  #include "internal.h"
> >  
> >  /*
> > @@ -540,9 +541,11 @@ void wait_on_page_bit(struct page *page,
> >  {
> >  	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
> >  
> > +	trace_mm_filemap_wait_start(page, bit_nr);
> >  	if (test_bit(bit_nr, &page->flags))
> >  		__wait_on_bit(page_waitqueue(page), &wait, sync_page,
> >  							TASK_UNINTERRUPTIBLE);
> > +	trace_mm_filemap_wait_end(page, bit_nr);
> >  }
> >  EXPORT_SYMBOL(wait_on_page_bit);
> 
> looks good to me.
> 
> 
> >  
> > Index: linux-2.6-lttng/mm/memory.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/memory.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/memory.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -51,6 +51,7 @@
> >  #include <linux/init.h>
> >  #include <linux/writeback.h>
> >  #include <linux/memcontrol.h>
> > +#include "mm-trace.h"
> >  
> >  #include <asm/pgalloc.h>
> >  #include <asm/uaccess.h>
> > @@ -2201,6 +2202,7 @@ static int do_swap_page(struct mm_struct
> >  		/* Had to read the page from swap area: Major fault */
> >  		ret = VM_FAULT_MAJOR;
> >  		count_vm_event(PGMAJFAULT);
> > +		trace_mm_swap_in(page, entry);
> >  	}
> >  
> >  	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> 
> somebody want get swapin delaying statics.
> (see delayacct_set_flag() and delayacct_clear_flag())
> 
> if swap cache exist, swapin can end very faster.
> otherwise, spend very long time.
> 

I am not sure what you are asking for here ? A supplementary parameter
or another trace point ?

> 
> > +	trace_mm_handle_fault_entry(address, write_access);
> > +
> >  	__set_current_state(TASK_RUNNING);
> >  
> >  	count_vm_event(PGFAULT);
> 
> mm or vma passing is better?
> otherwise, adress is ambiguity.
> 

Adding both mm and vma.


> > -	if (unlikely(is_vm_hugetlb_page(vma)))
> > -		return hugetlb_fault(mm, vma, address, write_access);
> > +	if (unlikely(is_vm_hugetlb_page(vma))) {
> > +		res = hugetlb_fault(mm, vma, address, write_access);
> > +		goto end;
> > +	}
> >  
> >  	pgd = pgd_offset(mm, address);
> >  	pud = pud_alloc(mm, pgd, address);
> > -	if (!pud)
> > -		return VM_FAULT_OOM;
> > +	if (!pud) {
> > +		res = VM_FAULT_OOM;
> > +		goto end;
> > +	}
> >  	pmd = pmd_alloc(mm, pud, address);
> > -	if (!pmd)
> > -		return VM_FAULT_OOM;
> > +	if (!pmd) {
> > +		res = VM_FAULT_OOM;
> > +		goto end;
> > +	}
> >  	pte = pte_alloc_map(mm, pmd, address);
> > -	if (!pte)
> > -		return VM_FAULT_OOM;
> > +	if (!pte) {
> > +		res = VM_FAULT_OOM;
> > +		goto end;
> > +	}
> >  
> > -	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > +	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > +end:
> > +	trace_mm_handle_fault_exit();
> > +	return res;
> >  }
> 
> no argument?
> if two page fault happend in parallel, how do you sort out this two fault?
> 

By using the current thread identifier in the probe. A PF entry on a given
thread must be followed by a matching PF exit for that same thread.
There may be other events interleaved between the two. Multiple nested
page faults shouldn't but *could* happen. In this case, the outermost PF
goes with the outermose PF end, and the innermost PF goes with the
innermost PF end.

> and, IMHO res variable is very important.
> because it is OOM related.
> many MM trouble shooting is worked for OOM related.
> 

Ok, I'll add "res".

> 
> >  #ifndef __PAGETABLE_PUD_FOLDED
> > Index: linux-2.6-lttng/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/page_alloc.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/page_alloc.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -46,6 +46,7 @@
> >  #include <linux/page-isolation.h>
> >  #include <linux/memcontrol.h>
> >  #include <linux/debugobjects.h>
> > +#include "mm-trace.h"
> >  
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -510,6 +511,8 @@ static void __free_pages_ok(struct page 
> >  	int i;
> >  	int reserved = 0;
> >  
> > +	trace_mm_page_free(page, order);
> > +
> >  	for (i = 0 ; i < (1 << order) ; ++i)
> >  		reserved += free_pages_check(page + i);
> >  	if (reserved)
> > @@ -966,6 +969,8 @@ static void free_hot_cold_page(struct pa
> >  	struct per_cpu_pages *pcp;
> >  	unsigned long flags;
> >  
> > +	trace_mm_page_free(page, 0);
> > +
> >  	if (PageAnon(page))
> >  		page->mapping = NULL;
> >  	if (free_pages_check(page))
> > @@ -1630,6 +1635,7 @@ nopage:
> >  		show_mem();
> >  	}
> >  got_pg:
> > +	trace_mm_page_alloc(page, order);
> >  	return page;
> >  }
> >  
> 
> please pass current task.
> I guess somebody need memory allocation tracking.
> 

Hrm.. "current" is available in the probe. Actually, it's available
anywhere in the kernel, do we really want to pass it on the stack ?

> 
> 
> > Index: linux-2.6-lttng/mm/page_io.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/page_io.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/page_io.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -17,6 +17,7 @@
> >  #include <linux/bio.h>
> >  #include <linux/swapops.h>
> >  #include <linux/writeback.h>
> > +#include "mm-trace.h"
> >  #include <asm/pgtable.h>
> >  
> >  static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
> > @@ -114,6 +115,7 @@ int swap_writepage(struct page *page, st
> >  		rw |= (1 << BIO_RW_SYNC);
> >  	count_vm_event(PSWPOUT);
> >  	set_page_writeback(page);
> > +	trace_mm_swap_out(page);
> >  	unlock_page(page);
> >  	submit_bio(rw, bio);
> >  out:
> 
> this tracepoint probe swapout starting, right.
> So, Why you don't probe swapout end?
> 

Does submit_bio() block in this case or is it done asynchronously ? It's
of no use to trace swap out "end" when in fact there would be no
blocking involved.


> 
> 
> > Index: linux-2.6-lttng/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/hugetlb.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/hugetlb.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -14,6 +14,7 @@
> >  #include <linux/mempolicy.h>
> >  #include <linux/cpuset.h>
> >  #include <linux/mutex.h>
> > +#include "mm-trace.h"
> >  
> >  #include <asm/page.h>
> >  #include <asm/pgtable.h>
> > @@ -141,6 +142,7 @@ static void free_huge_page(struct page *
> >  	int nid = page_to_nid(page);
> >  	struct address_space *mapping;
> >  
> > +	trace_mm_huge_page_free(page);
> >  	mapping = (struct address_space *) page_private(page);
> >  	set_page_private(page, 0);
> >  	BUG_ON(page_count(page));
> > @@ -509,6 +511,7 @@ static struct page *alloc_huge_page(stru
> >  	if (!IS_ERR(page)) {
> >  		set_page_refcounted(page);
> >  		set_page_private(page, (unsigned long) mapping);
> > +		trace_mm_huge_page_alloc(page);
> >  	}
> >  	return page;
> >  }
> 
> this tracepoint probe to HugePages_Free change, right?
> Why you don't probe HugePages_Total and HugePages_Rsvd change?
> 

Adding trace_hugetlb_page_reserve(inode, from, to);
and
trace_hugetlb_page_unreserve(inode, offset, freed);

Do you recommend adding another tracing point to monitor the total
hugepages pool changes ?

> 
> > Index: linux-2.6-lttng/mm/swapfile.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/swapfile.c	2008-07-04 18:26:02.000000000 -0400
> > +++ linux-2.6-lttng/mm/swapfile.c	2008-07-04 18:26:37.000000000 -0400
> > @@ -32,6 +32,7 @@
> >  #include <asm/pgtable.h>
> >  #include <asm/tlbflush.h>
> >  #include <linux/swapops.h>
> > +#include "mm-trace.h"
> >  
> >  DEFINE_SPINLOCK(swap_lock);
> >  unsigned int nr_swapfiles;
> 
> > @@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
> >  	swap_map = p->swap_map;
> >  	p->swap_map = NULL;
> >  	p->flags = 0;
> > +	trace_mm_swap_file_close(swap_file);
> >  	spin_unlock(&swap_lock);
> >  	mutex_unlock(&swapon_mutex);
> >  	vfree(swap_map);
> 
> Why you choose this point?

The idea is to monitor swap files so we can eventually know, from a
trace, which tracefiles were used during the trace and where they were
located. I also have a "swap file list" tracepoint which extracts all
the tracefile mappings which I plan to submit later. I normally execute
it at trace start.

> and why you don't pass pathname? (you pass it in sys_swapon()) 
> 

Since this other tracepoint gives me the mapping between file
descriptor and path name, the pathname becomes unnecessary.

> IMHO try_to_unuse cause many memory activity and spend many time and 
> often cause oom-killer.
> 
> I think this point log is needed by somebody.
> 

Should it be considered as part of swapoff ? If it is the case, then
maybe should we just move the trace_swap_file_close(swap_file); a little
be earlier so it is logged before the try_to_unuse() call ?

Mathieu

> 
> > @@ -1695,6 +1697,7 @@ asmlinkage long sys_swapon(const char __
> >  	} else {
> >  		swap_info[prev].next = p - swap_info;
> >  	}
> > +	trace_mm_swap_file_open(swap_file, name);
> >  	spin_unlock(&swap_lock);
> >  	mutex_unlock(&swapon_mutex);
> >  	error = 0;
> 
> 
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
