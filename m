Date: Fri, 11 Jul 2008 17:36:46 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC patch 05/12] LTTng instrumentation mm
In-Reply-To: <20080707203855.GA29295@Krystal>
References: <20080705173449.98DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080707203855.GA29295@Krystal>
Message-Id: <20080711120444.F691.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Masami Hiramatsu <mhiramat@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Mathieu,

sorry for late responce.
I went to business trip few days.


> Hi Kosaki,
> 
> Thanks for this thorough review, please see comments below. Comments
> without response will be addressed in the next tracepoint release.

thanks.


> > > Index: linux-2.6-lttng/mm/memory.c
> > > ===================================================================
> > > --- linux-2.6-lttng.orig/mm/memory.c	2008-07-04 18:26:02.000000000 -0400
> > > +++ linux-2.6-lttng/mm/memory.c	2008-07-04 18:26:37.000000000 -0400
> > > @@ -51,6 +51,7 @@
> > >  #include <linux/init.h>
> > >  #include <linux/writeback.h>
> > >  #include <linux/memcontrol.h>
> > > +#include "mm-trace.h"
> > >  
> > >  #include <asm/pgalloc.h>
> > >  #include <asm/uaccess.h>
> > > @@ -2201,6 +2202,7 @@ static int do_swap_page(struct mm_struct
> > >  		/* Had to read the page from swap area: Major fault */
> > >  		ret = VM_FAULT_MAJOR;
> > >  		count_vm_event(PGMAJFAULT);
> > > +		trace_mm_swap_in(page, entry);
> > >  	}
> > >  
> > >  	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> > 
> > somebody want get swapin delaying statics.
> > (see delayacct_set_flag() and delayacct_clear_flag())
> > 
> > if swap cache exist, swapin can end very faster.
> > otherwise, spend very long time.
> 
> I am not sure what you are asking for here ? A supplementary parameter
> or another trace point ?

Ah, Agreed with my explain is poor.
my intension was "another trace point".



> > > -	if (unlikely(is_vm_hugetlb_page(vma)))
> > > -		return hugetlb_fault(mm, vma, address, write_access);
> > > +	if (unlikely(is_vm_hugetlb_page(vma))) {
> > > +		res = hugetlb_fault(mm, vma, address, write_access);
> > > +		goto end;
> > > +	}
> > >  
> > >  	pgd = pgd_offset(mm, address);
> > >  	pud = pud_alloc(mm, pgd, address);
> > > -	if (!pud)
> > > -		return VM_FAULT_OOM;
> > > +	if (!pud) {
> > > +		res = VM_FAULT_OOM;
> > > +		goto end;
> > > +	}
> > >  	pmd = pmd_alloc(mm, pud, address);
> > > -	if (!pmd)
> > > -		return VM_FAULT_OOM;
> > > +	if (!pmd) {
> > > +		res = VM_FAULT_OOM;
> > > +		goto end;
> > > +	}
> > >  	pte = pte_alloc_map(mm, pmd, address);
> > > -	if (!pte)
> > > -		return VM_FAULT_OOM;
> > > +	if (!pte) {
> > > +		res = VM_FAULT_OOM;
> > > +		goto end;
> > > +	}
> > >  
> > > -	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > > +	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > > +end:
> > > +	trace_mm_handle_fault_exit();
> > > +	return res;
> > >  }
> > 
> > no argument?
> > if two page fault happend in parallel, how do you sort out this two fault?
> > 
> 
> By using the current thread identifier in the probe. A PF entry on a given
> thread must be followed by a matching PF exit for that same thread.
> There may be other events interleaved between the two. Multiple nested
> page faults shouldn't but *could* happen. In this case, the outermost PF
> goes with the outermose PF end, and the innermost PF goes with the
> innermost PF end.

okey.


> > and, IMHO res variable is very important.
> > because it is OOM related.
> > many MM trouble shooting is worked for OOM related.
> > 
> 
> Ok, I'll add "res".

Thanks.



> > > @@ -510,6 +511,8 @@ static void __free_pages_ok(struct page 
> > >  	int i;
> > >  	int reserved = 0;
> > >  
> > > +	trace_mm_page_free(page, order);
> > > +
> > >  	for (i = 0 ; i < (1 << order) ; ++i)
> > >  		reserved += free_pages_check(page + i);
> > >  	if (reserved)
> > > @@ -966,6 +969,8 @@ static void free_hot_cold_page(struct pa
> > >  	struct per_cpu_pages *pcp;
> > >  	unsigned long flags;
> > >  
> > > +	trace_mm_page_free(page, 0);
> > > +
> > >  	if (PageAnon(page))
> > >  		page->mapping = NULL;
> > >  	if (free_pages_check(page))
> > > @@ -1630,6 +1635,7 @@ nopage:
> > >  		show_mem();
> > >  	}
> > >  got_pg:
> > > +	trace_mm_page_alloc(page, order);
> > >  	return page;
> > >  }
> > >  
> > 
> > please pass current task.
> > I guess somebody need memory allocation tracking.
> > 
> 
> Hrm.. "current" is available in the probe. Actually, it's available
> anywhere in the kernel, do we really want to pass it on the stack ?

you are right.


> > >  static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
> > > @@ -114,6 +115,7 @@ int swap_writepage(struct page *page, st
> > >  		rw |= (1 << BIO_RW_SYNC);
> > >  	count_vm_event(PSWPOUT);
> > >  	set_page_writeback(page);
> > > +	trace_mm_swap_out(page);
> > >  	unlock_page(page);
> > >  	submit_bio(rw, bio);
> > >  out:
> > 
> > this tracepoint probe swapout starting, right.
> > So, Why you don't probe swapout end?
> > 
> 
> Does submit_bio() block in this case or is it done asynchronously ? It's
> of no use to trace swap out "end" when in fact there would be no
> blocking involved.

umm, ok, I should lern LTTng more.


> > > @@ -509,6 +511,7 @@ static struct page *alloc_huge_page(stru
> > >  	if (!IS_ERR(page)) {
> > >  		set_page_refcounted(page);
> > >  		set_page_private(page, (unsigned long) mapping);
> > > +		trace_mm_huge_page_alloc(page);
> > >  	}
> > >  	return page;
> > >  }
> > 
> > this tracepoint probe to HugePages_Free change, right?
> > Why you don't probe HugePages_Total and HugePages_Rsvd change?
> 
> Adding trace_hugetlb_page_reserve(inode, from, to);
> and
> trace_hugetlb_page_unreserve(inode, offset, freed);
> 
> Do you recommend adding another tracing point to monitor the total
> hugepages pool changes ?

Yes.
total number of hugepages can increase by sysctl.

So, it must be logged as swap_on/swap_off.
if it is not logged, freepages of hugepage meaning is ambiguity, IMHO.



> > > @@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
> > >  	swap_map = p->swap_map;
> > >  	p->swap_map = NULL;
> > >  	p->flags = 0;
> > > +	trace_mm_swap_file_close(swap_file);
> > >  	spin_unlock(&swap_lock);
> > >  	mutex_unlock(&swapon_mutex);
> > >  	vfree(swap_map);
> > 
> > Why you choose this point?
> 
> The idea is to monitor swap files so we can eventually know, from a
> trace, which tracefiles were used during the trace and where they were
> located. I also have a "swap file list" tracepoint which extracts all
> the tracefile mappings which I plan to submit later. I normally execute
> it at trace start.

yeah, thank you good explain.


> > and why you don't pass pathname? (you pass it in sys_swapon()) 
> 
> Since this other tracepoint gives me the mapping between file
> descriptor and path name, the pathname becomes unnecessary.

it seems you said only LTTng log analyzer is cool.
but I hope tracepoint mechanism doesn't depent on LTTng.


> > IMHO try_to_unuse cause many memory activity and spend many time and 
> > often cause oom-killer.
> > 
> > I think this point log is needed by somebody.
> 
> Should it be considered as part of swapoff ? 

hmm, okey, you are right.
that is not swapoff.

> If it is the case, then
> maybe should we just move the trace_swap_file_close(swap_file); a little
> be earlier so it is logged before the try_to_unuse() call ?

No.
eventually, I will add to some VM activety tracepoint.
but that can separate swapoff tracepoint.

sorry for my confusion.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
