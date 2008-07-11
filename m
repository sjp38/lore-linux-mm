Received: from toip3.srvr.bell.ca ([209.226.175.86])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080711141727.VDNL1723.tomts16-srv.bellnexxia.net@toip3.srvr.bell.ca>
          for <linux-mm@kvack.org>; Fri, 11 Jul 2008 10:17:27 -0400
Date: Fri, 11 Jul 2008 10:17:21 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC patch 05/12] LTTng instrumentation mm
Message-ID: <20080711141720.GA8520@Krystal>
References: <20080705173449.98DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080707203855.GA29295@Krystal> <20080711120444.F691.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20080711120444.F691.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Masami Hiramatsu <mhiramat@redhat.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro (kosaki.motohiro@jp.fujitsu.com) wrote:
> Hi Mathieu,
> 
> sorry for late responce.
> I went to business trip few days.
> 
> 
> > Hi Kosaki,
> > 
> > Thanks for this thorough review, please see comments below. Comments
> > without response will be addressed in the next tracepoint release.
> 
> thanks.
> 
> 
> > > > Index: linux-2.6-lttng/mm/memory.c
> > > > ===================================================================
> > > > --- linux-2.6-lttng.orig/mm/memory.c	2008-07-04 18:26:02.000000000 -0400
> > > > +++ linux-2.6-lttng/mm/memory.c	2008-07-04 18:26:37.000000000 -0400
> > > > @@ -51,6 +51,7 @@
> > > >  #include <linux/init.h>
> > > >  #include <linux/writeback.h>
> > > >  #include <linux/memcontrol.h>
> > > > +#include "mm-trace.h"
> > > >  
> > > >  #include <asm/pgalloc.h>
> > > >  #include <asm/uaccess.h>
> > > > @@ -2201,6 +2202,7 @@ static int do_swap_page(struct mm_struct
> > > >  		/* Had to read the page from swap area: Major fault */
> > > >  		ret = VM_FAULT_MAJOR;
> > > >  		count_vm_event(PGMAJFAULT);
> > > > +		trace_mm_swap_in(page, entry);
> > > >  	}
> > > >  
> > > >  	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
> > > 
> > > somebody want get swapin delaying statics.
> > > (see delayacct_set_flag() and delayacct_clear_flag())
> > > 
> > > if swap cache exist, swapin can end very faster.
> > > otherwise, spend very long time.
> > 
> > I am not sure what you are asking for here ? A supplementary parameter
> > or another trace point ?
> 
> Ah, Agreed with my explain is poor.
> my intension was "another trace point".
> 

I see. You would like to know the duration of the page fault. Actually,
handle_mm_fault instrumentation gives you both the beginning and end of
page faults. Therefore, instrumenting two locations in swap_in would be
redundant.


> 
> 
> > > > -	if (unlikely(is_vm_hugetlb_page(vma)))
> > > > -		return hugetlb_fault(mm, vma, address, write_access);
> > > > +	if (unlikely(is_vm_hugetlb_page(vma))) {
> > > > +		res = hugetlb_fault(mm, vma, address, write_access);
> > > > +		goto end;
> > > > +	}
> > > >  
> > > >  	pgd = pgd_offset(mm, address);
> > > >  	pud = pud_alloc(mm, pgd, address);
> > > > -	if (!pud)
> > > > -		return VM_FAULT_OOM;
> > > > +	if (!pud) {
> > > > +		res = VM_FAULT_OOM;
> > > > +		goto end;
> > > > +	}
> > > >  	pmd = pmd_alloc(mm, pud, address);
> > > > -	if (!pmd)
> > > > -		return VM_FAULT_OOM;
> > > > +	if (!pmd) {
> > > > +		res = VM_FAULT_OOM;
> > > > +		goto end;
> > > > +	}
> > > >  	pte = pte_alloc_map(mm, pmd, address);
> > > > -	if (!pte)
> > > > -		return VM_FAULT_OOM;
> > > > +	if (!pte) {
> > > > +		res = VM_FAULT_OOM;
> > > > +		goto end;
> > > > +	}
> > > >  
> > > > -	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > > > +	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> > > > +end:
> > > > +	trace_mm_handle_fault_exit();
> > > > +	return res;
> > > >  }
> > > 
> > > no argument?
> > > if two page fault happend in parallel, how do you sort out this two fault?
> > > 
> > 
> > By using the current thread identifier in the probe. A PF entry on a given
> > thread must be followed by a matching PF exit for that same thread.
> > There may be other events interleaved between the two. Multiple nested
> > page faults shouldn't but *could* happen. In this case, the outermost PF
> > goes with the outermose PF end, and the innermost PF goes with the
> > innermost PF end.
> 
> okey.
> 
> 
> > > and, IMHO res variable is very important.
> > > because it is OOM related.
> > > many MM trouble shooting is worked for OOM related.
> > > 
> > 
> > Ok, I'll add "res".
> 
> Thanks.
> 
> 
> 
> > > > @@ -510,6 +511,8 @@ static void __free_pages_ok(struct page 
> > > >  	int i;
> > > >  	int reserved = 0;
> > > >  
> > > > +	trace_mm_page_free(page, order);
> > > > +
> > > >  	for (i = 0 ; i < (1 << order) ; ++i)
> > > >  		reserved += free_pages_check(page + i);
> > > >  	if (reserved)
> > > > @@ -966,6 +969,8 @@ static void free_hot_cold_page(struct pa
> > > >  	struct per_cpu_pages *pcp;
> > > >  	unsigned long flags;
> > > >  
> > > > +	trace_mm_page_free(page, 0);
> > > > +
> > > >  	if (PageAnon(page))
> > > >  		page->mapping = NULL;
> > > >  	if (free_pages_check(page))
> > > > @@ -1630,6 +1635,7 @@ nopage:
> > > >  		show_mem();
> > > >  	}
> > > >  got_pg:
> > > > +	trace_mm_page_alloc(page, order);
> > > >  	return page;
> > > >  }
> > > >  
> > > 
> > > please pass current task.
> > > I guess somebody need memory allocation tracking.
> > > 
> > 
> > Hrm.. "current" is available in the probe. Actually, it's available
> > anywhere in the kernel, do we really want to pass it on the stack ?
> 
> you are right.
> 
> 
> > > >  static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
> > > > @@ -114,6 +115,7 @@ int swap_writepage(struct page *page, st
> > > >  		rw |= (1 << BIO_RW_SYNC);
> > > >  	count_vm_event(PSWPOUT);
> > > >  	set_page_writeback(page);
> > > > +	trace_mm_swap_out(page);
> > > >  	unlock_page(page);
> > > >  	submit_bio(rw, bio);
> > > >  out:
> > > 
> > > this tracepoint probe swapout starting, right.
> > > So, Why you don't probe swapout end?
> > > 
> > 
> > Does submit_bio() block in this case or is it done asynchronously ? It's
> > of no use to trace swap out "end" when in fact there would be no
> > blocking involved.
> 
> umm, ok, I should lern LTTng more.
> 
> 
> > > > @@ -509,6 +511,7 @@ static struct page *alloc_huge_page(stru
> > > >  	if (!IS_ERR(page)) {
> > > >  		set_page_refcounted(page);
> > > >  		set_page_private(page, (unsigned long) mapping);
> > > > +		trace_mm_huge_page_alloc(page);
> > > >  	}
> > > >  	return page;
> > > >  }
> > > 
> > > this tracepoint probe to HugePages_Free change, right?
> > > Why you don't probe HugePages_Total and HugePages_Rsvd change?
> > 
> > Adding trace_hugetlb_page_reserve(inode, from, to);
> > and
> > trace_hugetlb_page_unreserve(inode, offset, freed);
> > 
> > Do you recommend adding another tracing point to monitor the total
> > hugepages pool changes ?
> 
> Yes.
> total number of hugepages can increase by sysctl.
> 
> So, it must be logged as swap_on/swap_off.
> if it is not logged, freepages of hugepage meaning is ambiguity, IMHO.
> 

Ok, so I am adding :


static struct page *alloc_huge_page(struct vm_area_struct *vma,
                                    unsigned long addr)
  trace_hugetlb_page_alloc(page);

int hugetlb_reserve_pages(struct inode *inode, long from, long to)
  trace_hugetlb_pages_reserve(inode, from, to, ret);

void hugetlb_unreserve_pages(struct inode *inode, long offset, long
    freed)
  trace_hugetlb_pages_unreserve(inode, offset, freed);

static void update_and_free_page(struct page *page)
  trace_hugetlb_page_release(page);

static void free_huge_page(struct page *page)
  trace_hugetlb_page_free(page);

static struct page *alloc_fresh_huge_page_node(int nid)
  trace_hugetlb_page_grab(page);

static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
                                                unsigned long address)
  trace_hugetlb_buddy_pgalloc(page);


static struct page *alloc_huge_page(struct vm_area_struct *vma,
                                    unsigned long addr)
  trace_hugetlb_page_alloc(page);


It tracks pages taken from the page allocator and from the buddy
allocator, page released, pages reserved/unreserved and page alloc/free
within hugetlb. Does it seem more appropriate ? The only thing it does
not track is "surplus_huge_pages", which seems to be rather internal to
hugetlb. Do you think tracking it would be useful ?

> 
> 
> > > > @@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
> > > >  	swap_map = p->swap_map;
> > > >  	p->swap_map = NULL;
> > > >  	p->flags = 0;
> > > > +	trace_mm_swap_file_close(swap_file);
> > > >  	spin_unlock(&swap_lock);
> > > >  	mutex_unlock(&swapon_mutex);
> > > >  	vfree(swap_map);
> > > 
> > > Why you choose this point?
> > 
> > The idea is to monitor swap files so we can eventually know, from a
> > trace, which tracefiles were used during the trace and where they were
> > located. I also have a "swap file list" tracepoint which extracts all
> > the tracefile mappings which I plan to submit later. I normally execute
> > it at trace start.
> 
> yeah, thank you good explain.
> 
> 
> > > and why you don't pass pathname? (you pass it in sys_swapon()) 
> > 
> > Since this other tracepoint gives me the mapping between file
> > descriptor and path name, the pathname becomes unnecessary.
> 
> it seems you said only LTTng log analyzer is cool.
> but I hope tracepoint mechanism doesn't depent on LTTng.
> 

No, the tracepoints are meant to be used by any in-kernel specialized or
module-based generic tracer, which includes ftrace and eventually
blktrace too.

> 
> > > IMHO try_to_unuse cause many memory activity and spend many time and 
> > > often cause oom-killer.
> > > 
> > > I think this point log is needed by somebody.
> > 
> > Should it be considered as part of swapoff ? 
> 
> hmm, okey, you are right.
> that is not swapoff.
> 
> > If it is the case, then
> > maybe should we just move the trace_swap_file_close(swap_file); a little
> > be earlier so it is logged before the try_to_unuse() call ?
> 
> No.
> eventually, I will add to some VM activety tracepoint.
> but that can separate swapoff tracepoint.
> 
> sorry for my confusion.
> 

No problem, thanks for the review!

Mathieu

> 
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
